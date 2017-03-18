Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA5286B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o135so86963231qke.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:00 -0700 (PDT)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id 12si7700761qke.64.2017.03.17.17.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:54:59 -0700 (PDT)
Received: by mail-qk0-f176.google.com with SMTP id v127so77339312qkb.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:54:59 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 00/21] Ion clean in preparation for moving out of staging
Date: Fri, 17 Mar 2017 17:54:32 -0700
Message-Id: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Hi,

This is v2 of the series to do some serious Ion clean up in preparation for
moving out of staging. I got good feedback last time so this series mostly
attempts to address that feedback and do more still more cleanup. Highlights:

- All calls to DMA APIs should now be with a real actual proper device
  structure
- Patch to stop setting sg_dma_address manually now included
- Fix for a bug in the query interface
- Removal of custom ioctl interface
- Removal of import interface
- Removal of any notion of using Ion as an in kernel interface.
- Cleanup of ABI so compat interface is no longer needed
- Deletion of a bit more platform code
- Combined heap enumeration and heap registration code up so there are fewer
  layers of abstraction
- Some general cleanup and header reduction.
- Removal of both the ion_client and ion_handle structures since these mostly
  become redundant. As a result, Ion only returns a dma_buf fd. The overall
  result is that the only Ion interfaces are the query ioctl and the alloc
  ioctl.

The following are still TODOs/open problems:
- Sumit's comments about the CMA naming.
- Bindings/platform for chunk and carveout heap
- There was some discussion about making the sg_table duplication generic. I
  got bogged down in handling some of the edge cases for generic handling
  so I put this aside. Making it generic is still something that should happen.
- More fine-grained support for restricting heap access. There are good
  arguments to be made for having a way for having good integration with
  selinux and other policy mechanisms.
- While not on the original list, there is still no good good test standalone
  test framework. I noticed that the existing ion_test was fairly generic so I
  proposed moving it to dma_buf. Daniel Vetter suggested just using the VGEM
  module instead. Ideally, the tests can live as part of some other existing
  test set (drm tests maybe?)

Feedback appreciated as always.

Thanks,
Laura

Laura Abbott (21):
  cma: Store a name in the cma structure
  cma: Introduce cma_for_each_area
  staging: android: ion: Remove dmap_cnt
  staging: android: ion: Remove alignment from allocation field
  staging: android: ion: Duplicate sg_table
  staging: android: ion: Call dma_map_sg for syncing and mapping
  staging: android: ion: Remove page faulting support
  staging: android: ion: Remove crufty cache support
  staging: android: ion: Remove custom ioctl interface
  staging: android: ion: Remove import interface
  staging: android: ion: Remove duplicate ION_IOC_MAP
  staging: android: ion: Remove old platform support
  staging: android: ion: Use CMA APIs directly
  staging: android: ion: Stop butchering the DMA address
  staging: android: ion: Break the ABI in the name of forward progress
  staging: android: ion: Get rid of ion_phys_addr_t
  staging: android: ion: Collapse internal header files
  staging: android: ion: Rework heap registration/enumeration
  staging: android: ion: Drop ion_map_kernel interface
  staging: android: ion: Remove ion_handle and ion_client
  staging: android: ion: Set query return value

 drivers/base/dma-contiguous.c                      |    5 +-
 drivers/staging/android/ion/Kconfig                |   56 +-
 drivers/staging/android/ion/Makefile               |   18 +-
 drivers/staging/android/ion/compat_ion.c           |  195 ----
 drivers/staging/android/ion/compat_ion.h           |   29 -
 drivers/staging/android/ion/hisilicon/Kconfig      |    5 -
 drivers/staging/android/ion/hisilicon/Makefile     |    1 -
 drivers/staging/android/ion/hisilicon/hi6220_ion.c |  113 --
 drivers/staging/android/ion/ion-ioctl.c            |   85 +-
 drivers/staging/android/ion/ion.c                  | 1164 +++-----------------
 drivers/staging/android/ion/ion.h                  |  393 +++++--
 drivers/staging/android/ion/ion_carveout_heap.c    |   37 +-
 drivers/staging/android/ion/ion_chunk_heap.c       |   27 +-
 drivers/staging/android/ion/ion_cma_heap.c         |  125 +--
 drivers/staging/android/ion/ion_dummy_driver.c     |  156 ---
 drivers/staging/android/ion/ion_heap.c             |   68 --
 drivers/staging/android/ion/ion_of.c               |  184 ----
 drivers/staging/android/ion/ion_of.h               |   37 -
 drivers/staging/android/ion/ion_page_pool.c        |    6 +-
 drivers/staging/android/ion/ion_priv.h             |  473 --------
 drivers/staging/android/ion/ion_system_heap.c      |   53 +-
 drivers/staging/android/ion/ion_test.c             |  305 -----
 drivers/staging/android/ion/tegra/Makefile         |    1 -
 drivers/staging/android/ion/tegra/tegra_ion.c      |   80 --
 drivers/staging/android/uapi/ion.h                 |   86 +-
 drivers/staging/android/uapi/ion_test.h            |   69 --
 include/linux/cma.h                                |    6 +-
 mm/cma.c                                           |   25 +-
 mm/cma.h                                           |    1 +
 mm/cma_debug.c                                     |    2 +-
 30 files changed, 610 insertions(+), 3195 deletions(-)
 delete mode 100644 drivers/staging/android/ion/compat_ion.c
 delete mode 100644 drivers/staging/android/ion/compat_ion.h
 delete mode 100644 drivers/staging/android/ion/hisilicon/Kconfig
 delete mode 100644 drivers/staging/android/ion/hisilicon/Makefile
 delete mode 100644 drivers/staging/android/ion/hisilicon/hi6220_ion.c
 delete mode 100644 drivers/staging/android/ion/ion_dummy_driver.c
 delete mode 100644 drivers/staging/android/ion/ion_of.c
 delete mode 100644 drivers/staging/android/ion/ion_of.h
 delete mode 100644 drivers/staging/android/ion/ion_priv.h
 delete mode 100644 drivers/staging/android/ion/ion_test.c
 delete mode 100644 drivers/staging/android/ion/tegra/Makefile
 delete mode 100644 drivers/staging/android/ion/tegra/tegra_ion.c
 delete mode 100644 drivers/staging/android/uapi/ion_test.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
