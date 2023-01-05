ARG VER=20.04

FROM nvidia/cuda:11.8.0-devel-ubuntu${VER}

ARG FFMPEG_VERSION

ARG NVENC_VERSION

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

ENV FFMPEG_VERSION ${FFMPEG_VERSION}
ENV NVENC_VERSION ${NVENC_VERSION}
ENV VER ${VER}

RUN apt-get update \
    && apt-get -y --no-install-recommends install software-properties-common build-essential curl ca-certificates libva-dev libdevil-dev \
    python3 python3-pip ninja-build git-core libass-dev libfreetype6-dev libunistring-dev wget \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && update-ca-certificates


RUN pip3 install meson

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y

RUN apt update && apt install gcc-11 g++-11 -y

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg
COPY ./ldd.sh /app/ldd.sh
COPY ./copyfiles.sh /app/copyfiles.sh

RUN /app/build-ffmpeg --build --enable-gpl-and-non-free

RUN /app/workspace/bin/ffmpeg --help

