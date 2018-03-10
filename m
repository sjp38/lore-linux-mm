Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA686B0008
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:58 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 184so3651444qki.0
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:58 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d5si2188799qte.389.2018.03.09.19.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:56 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Date: Fri,  9 Mar 2018 22:21:28 -0500
Message-Id: <20180310032141.6096-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

(mm is cced just to allow exposure of device driver work without ccing
a long list of peoples. I do not think there is anything usefull to
discuss from mm point of view but i might be wrong, so just for the
curious :)).

git://people.freedesktop.org/~glisse/linux branch: nouveau-hmm-v00
https://cgit.freedesktop.org/~glisse/linux/log/?h=nouveau-hmm-v00

This patchset adds SVM (Share Virtual Memory) using HMM (Heterogeneous
Memory Management) to the nouveau driver. SVM means that GPU threads
spawn by GPU driver for a specific user process can access any valid
CPU address in that process. A valid pointer is a pointer inside an
area coming from mmap of private, share or regular file. Pointer to
a mmap of a device file or special file are not supported.

This is an RFC for few reasons technical reasons listed below and also
because we are still working on a proper open source userspace (namely
a OpenCL 2.0 for nouveau inside mesa). Open source userspace being a
requirement for the DRM subsystem. I pushed in [1] a simple standalone
program that can be use to test SVM through HMM with nouveau. I expect
we will have a somewhat working userspace in the coming weeks, work
being well underway and some patches have already been posted on mesa
mailing list.

They are two aspect that need to sorted before this can be considered
ready. First we want to decide how to update GPU page table from HMM.
In this patchset i added new methods to vmm to allow GPU page table to
be updated without nvkm_memory or nvkm_vma object (see patch 7 and 8
special mapping method for HMM). It just take an array of pages and
flags. It allow for both system and device private memory to be
interleaved.

The second aspect is how to create a HMM enabled channel. Channel is
a term use for NVidia GPU command queue, each process using nouveau
have at least one channel, it can have multiple channels. They are
not created by process directly but rather by device driver backend
of common library like OpenGL, OpenCL or Vulkan.

They are work underway to revamp nouveau channel creation with a new
userspace API. So we might want to delay upstreaming until this lands.
We can stil discuss one aspect specific to HMM here namely the issue
around GEM objects used for some specific part of the GPU. Some engine
inside the GPU (engine are a GPU block like the display block which
is responsible of scaning memory to send out a picture through some
connector for instance HDMI or DisplayPort) can only access memory
with virtual address below (1 << 40). To accomodate those we need to
create a "hole" inside the process address space. This patchset have
a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
device file offset so that process can mmap this range with PROT_NONE
to create a hole (process must make sure the hole is below 1 << 40).
I feel un-easy of doing it this way but maybe it is ok with other
folks.


Note that this patchset do not show usage of device private memory as
it depends on other architectural changes to nouveau. However it is
very easy to add it with some gross hack so if people would like to
see it i can also post an RFC for that. As a preview it only adds two
new ioctl which allow userspace to ask for migration of a range of
virtual address, expectation is that the userspace library will know
better where to place thing and kernel will try to sastify this (with
no guaranty, it is a best effort).


As usual comments and questions are welcome.

Cheers,
JA(C)rA'me Glisse

[1] https://cgit.freedesktop.org/~glisse/moche

Ben Skeggs (4):
  drm/nouveau/core: define engine for handling replayable faults
  drm/nouveau/mmu/gp100: allow gcc/tex to generate replayable faults
  drm/nouveau/mc/gp100-: handle replayable fault interrupt
  drm/nouveau/fault/gp100: initial implementation of MaxwellFaultBufferA

JA(C)rA'me Glisse (9):
  drm/nouveau/vmm: enable page table iterator over non populated range
  drm/nouveau/core/memory: add some useful accessor macros
  drm/nouveau: special mapping method for HMM
  drm/nouveau: special mapping method for HMM (user interface)
  drm/nouveau: add SVM through HMM support to nouveau client
  drm/nouveau: add HMM area creation
  drm/nouveau: add HMM area creation user interface
  drm/nouveau: HMM area creation helpers for nouveau client
  drm/nouveau: HACK FOR HMM AREA

 drivers/gpu/drm/nouveau/Kbuild                     |   3 +
 drivers/gpu/drm/nouveau/include/nvif/class.h       |   2 +
 drivers/gpu/drm/nouveau/include/nvif/clb069.h      |   8 +
 drivers/gpu/drm/nouveau/include/nvif/if000c.h      |  26 ++
 drivers/gpu/drm/nouveau/include/nvif/vmm.h         |   4 +
 drivers/gpu/drm/nouveau/include/nvkm/core/device.h |   3 +
 drivers/gpu/drm/nouveau/include/nvkm/core/memory.h |   8 +
 .../gpu/drm/nouveau/include/nvkm/engine/fault.h    |   5 +
 drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h  |  10 +
 drivers/gpu/drm/nouveau/nouveau_drm.c              |   5 +
 drivers/gpu/drm/nouveau/nouveau_drv.h              |   3 +
 drivers/gpu/drm/nouveau/nouveau_hmm.c              | 367 +++++++++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_hmm.h              |  64 ++++
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |   9 +-
 drivers/gpu/drm/nouveau/nouveau_vmm.c              |  83 +++++
 drivers/gpu/drm/nouveau/nouveau_vmm.h              |  12 +
 drivers/gpu/drm/nouveau/nvif/vmm.c                 |  80 +++++
 drivers/gpu/drm/nouveau/nvkm/core/subdev.c         |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/Kbuild         |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/base.c  |   8 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h  |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/user.c  |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild   |   4 +
 drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c   | 116 +++++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c  |  61 ++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h   |  29 ++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c   | 136 ++++++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h   |   7 +
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c     |  20 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c     |   2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h      |   2 +
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c     |  88 ++++-
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c      | 241 ++++++++++++--
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h      |   8 +
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c |  78 ++++-
 35 files changed, 1463 insertions(+), 33 deletions(-)
 create mode 100644 drivers/gpu/drm/nouveau/include/nvif/clb069.h
 create mode 100644 drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hmm.c
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hmm.h
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h

-- 
2.14.3
