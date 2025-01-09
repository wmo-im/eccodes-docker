###############################################################################
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
###############################################################################

FROM ubuntu:jammy

ARG BUILD_PACKAGES="build-essential cmake gfortran python3-dev linux-libc-dev" \
    ECCODES_VER=2.39.0

ENV DEBIAN_FRONTEND="noninteractive" \
    TZ="Etc/UTC" \
    ECCODES_DIR=/opt/eccodes \
    PATH="$PATH:/opt/eccodes/bin"

WORKDIR /tmp/eccodes

# compile eccodes binaries from source, install python-eccodes-modules, add cmd line editors
RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | cat > /etc/apt/apt.conf.d/10no--check-valid-until \
    && apt-get update -y \
    && apt-get install -y ${BUILD_PACKAGES} python3 python3-pip curl \
    && curl https://confluence.ecmwf.int/download/attachments/45757960/eccodes-${ECCODES_VER}-Source.tar.gz --output eccodes-${ECCODES_VER}-Source.tar.gz \
    && tar xzf eccodes-${ECCODES_VER}-Source.tar.gz \
    && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=${ECCODES_DIR} -DENABLE_AEC=OFF ../eccodes-${ECCODES_VER}-Source && make && ctest && make install # \
    && cd / && rm -rf /tmp/eccodes \
    && apt-get install python3-eccodes vim vi emacs nano \ 
    && apt-get remove --purge -y ${BUILD_PACKAGES} \
    && apt autoremove -y  \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
# Clean up
RUN rm -rf /tmp/eccodes
