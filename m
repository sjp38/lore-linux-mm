Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 93F936007FA
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 10:10:31 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L66006ZX4PEK9@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 26 Jul 2010 15:10:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6600L6Z4PEMA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 26 Jul 2010 15:10:26 +0100 (BST)
Date: Mon, 26 Jul 2010 16:11:40 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv2 0/4] The Contiguous Memory Allocator
Message-id: <cover.1280151963.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk, Hiremath Vaibhav <hvaibhav@ti.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Zach Pfeffer <zpfeffer@codeaurora.org>, Kyungmin Park <kyungmin.park@samsung.com>, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello everyone,

The following patchset implements a Contiguous Memory Allocator.  For
those who have not yet stumbled across CMA an excerpt from
documentation:

   The Contiguous Memory Allocator (CMA) is a framework, which allows
   setting up a machine-specific configuration for physically-contiguous
   memory management. Memory for devices is then allocated according
   to that configuration.

   The main role of the framework is not to allocate memory, but to
   parse and manage memory configurations, as well as to act as an
   in-between between device drivers and pluggable allocators. It is
   thus not tied to any memory allocation method or strategy.

For more information please refer to the second patch from the
patchset which contains the documentation.


This is the second version of the patchset.  All of the changes are
concentrated in the second patch -- the other patches are almost
identical.

Major observable changes are:

1. The "cma_map" command line have been removed.  In exchange, a SysFS
   entry has been created under kernel/mm/contiguous.
   
   The configuration strings passed to CMA are now called attributes
   in the documentation.

   The intended way of specifying the attributes is
   a cma_set_defaults() function called by platform initialisation
   code.  "regions" attribute (the string specified by "cma" command
   line parameter) can be overwritten with command line parameter; the
   other attributes can be changed during run-time using the SysFS
   entries.

   (I still believe that the other attributes should have their own
   command line arguments as well but since they posed a lot of
   controversy (and many stopped reading after encountering them)
   "cma_map" have been removed.)

2. The behaviour of the "map" attribute has been modified slightly.
   Currently, if no rule matches given device it is assigned regions
   specified by the "asterisk" attribute.  It is by default built from
   the region names given in "regions" attribute.

   This also means that if no "map" is specified all devices use all
   the regions specified in the "regions" attribute.  This should be
   a handy default.

3. Devices can register private regions as well as regions that can be
   shared but are not reserved using standard CMA mechanisms.
   A private region has no name and can be accessed only by devices
   that have the pointer to it.

   Moreover, if device manages to run its code early enough it can
   register an "early region".  An early region is one memory has not
   been reserved for.  At one point, platform initialisation code
   reserves memory for all registered early regions and if this
   succeeds those regions are registered as normal regions that can be
   used with the standard API.  This may be handy for devices that
   need some private region but don't want to worry about reserving
   it.

4. The way allocators are registered has changed.  Currently,
   a cma_allocator_register() function is used for that purpose.
   Moreover, allocators are attached to regions the first time memory
   is registered from the region or when allocator is registered which
   means that allocators can be dynamic modules that are loaded after
   the kernel booted (of course, it won't be possible to allocate
   a chunk of memory from a region if allocator is not loaded).


Index of new functions:

+static inline dma_addr_t __must_check
+cma_alloc_from(const char *regions, size_t size, dma_addr_t alignment)

+static inline int
+cma_info_about(struct cma_info *info, const const char *regions)

+int __must_check cma_region_register(struct cma_region *reg);

+dma_addr_t __must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, dma_addr_t alignment);

+static inline dma_addr_t __must_check
+cma_alloc_from(const char *regions,
+               size_t size, dma_addr_t alignment);

+int cma_allocator_register(struct cma_allocator *alloc);


The patches in the patchset include:

Michal Nazarewicz (4):
  lib: rbtree: rb_root_init() function added

    The rb_root_init() function initialises an RB tree with a single
    node placed in the root.  This is more convenient then
    initialising an empty tree and then adding an element.

  mm: cma: Contiguous Memory Allocator added

    This patch is the main patchset that implements the CMA framework
    including the best-fit allocator.  It also adds a documentation.

  mm: cma: Test device and application added

    This patch adds a misc device that works as a proxy to the CMA
    framework and a simple testing application.  This lets one test
    the whole framework from user space as well as reply an recorded
    allocate/free sequence.

  arm: Added CMA to Aquila and Goni

    This patch adds the CMA platform initialisation code to two ARM
    platforms.  It serves as an example of how this is achieved.

 Documentation/00-INDEX                             |    2 +
 .../ABI/testing/sysfs-kernel-mm-contiguous         |    9 +
 Documentation/contiguous-memory.txt                |  646 +++++++++++
 Documentation/kernel-parameters.txt                |    4 +
 arch/arm/mach-s5pv210/mach-aquila.c                |   13 +
 arch/arm/mach-s5pv210/mach-goni.c                  |   13 +
 drivers/misc/Kconfig                               |    8 +
 drivers/misc/Makefile                              |    1 +
 drivers/misc/cma-dev.c                             |  184 +++
 include/linux/cma.h                                |  475 ++++++++
 include/linux/rbtree.h                             |   11 +
 mm/Kconfig                                         |   34 +
 mm/Makefile                                        |    3 +
 mm/cma-best-fit.c                                  |  407 +++++++
 mm/cma.c                                           | 1170 ++++++++++++++++++++
 tools/cma/cma-test.c                               |  373 +++++++
 16 files changed, 3353 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-contiguous
 create mode 100644 Documentation/contiguous-memory.txt
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma-best-fit.c
 create mode 100644 mm/cma.c
 create mode 100644 tools/cma/cma-test.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
