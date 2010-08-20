Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E7C936B02F9
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:51:47 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7G00DIN3E76D50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 10:51:43 +0100 (BST)
Received: from pikus.localdomain ([10.89.8.241])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7G008IB3CR4S@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 10:51:43 +0100 (BST)
Date: Fri, 20 Aug 2010 11:50:40 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-id: <cover.1282286941.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org
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


Links to the previous versions of the patchsets:
v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573/>
v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986/>
v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669/>


v4: 1. The "asterisk" flag has been removed in favour of requiring
       that platform will provide a "*=<regions>" rule in the map
       attribute.

    2. The terminology has been changed slightly renaming "kind" to
       "type" of memory.  In the previous revisions, the documentation
       indicated that device drivers define memory kinds and now,

v3: 1. The command line parameters have been removed (and moved to
       a separate patch, the fourth one).  As a consequence, the
       cma_set_defaults() function has been changed -- it no longer
       accepts a string with list of regions but an array of regions.

    2. The "asterisk" attribute has been removed.  Now, each region
       has an "asterisk" flag which lets one specify whether this
       region should by considered "asterisk" region.

    3. SysFS support has been moved to a separate patch (the third one
       in the series) and now also includes list of regions.

v2: 1. The "cma_map" command line have been removed.  In exchange,
       a SysFS entry has been created under kernel/mm/contiguous.

       The intended way of specifying the attributes is
       a cma_set_defaults() function called by platform initialisation
       code.  "regions" attribute (the string specified by "cma"
       command line parameter) can be overwritten with command line
       parameter; the other attributes can be changed during run-time
       using the SysFS entries.

    2. The behaviour of the "map" attribute has been modified
       slightly.  Currently, if no rule matches given device it is
       assigned regions specified by the "asterisk" attribute.  It is
       by default built from the region names given in "regions"
       attribute.

    3. Devices can register private regions as well as regions that
       can be shared but are not reserved using standard CMA
       mechanisms.  A private region has no name and can be accessed
       only by devices that have the pointer to it.

    4. The way allocators are registered has changed.  Currently,
       a cma_allocator_register() function is used for that purpose.
       Moreover, allocators are attached to regions the first time
       memory is registered from the region or when allocator is
       registered which means that allocators can be dynamic modules
       that are loaded after the kernel booted (of course, it won't be
       possible to allocate a chunk of memory from a region if
       allocator is not loaded).

    5. Index of new functions:

    +static inline dma_addr_t __must_check
    +cma_alloc_from(const char *regions, size_t size,
    +               dma_addr_t alignment)

    +static inline int
    +cma_info_about(struct cma_info *info, const const char *regions)

    +int __must_check cma_region_register(struct cma_region *reg);

    +dma_addr_t __must_check
    +cma_alloc_from_region(struct cma_region *reg,
    +                      size_t size, dma_addr_t alignment);

    +static inline dma_addr_t __must_check
    +cma_alloc_from(const char *regions,
    +               size_t size, dma_addr_t alignment);

    +int cma_allocator_register(struct cma_allocator *alloc);


Michal Nazarewicz (6):
  lib: rbtree: rb_root_init() function added
  mm: cma: Contiguous Memory Allocator added
  mm: cma: Added SysFS support
  mm: cma: Added command line parameters support
  mm: cma: Test device and application added
  arm: Added CMA to Aquila and Goni

 Documentation/00-INDEX                             |    2 +
 .../ABI/testing/sysfs-kernel-mm-contiguous         |   53 +
 Documentation/contiguous-memory.txt                |  620 +++++++++
 Documentation/kernel-parameters.txt                |    7 +
 arch/arm/mach-s5pv210/mach-aquila.c                |   31 +
 arch/arm/mach-s5pv210/mach-goni.c                  |   31 +
 drivers/misc/Kconfig                               |    8 +
 drivers/misc/Makefile                              |    1 +
 drivers/misc/cma-dev.c                             |  185 +++
 include/linux/cma.h                                |  468 +++++++
 include/linux/rbtree.h                             |   11 +
 mm/Kconfig                                         |   54 +
 mm/Makefile                                        |    2 +
 mm/cma-best-fit.c                                  |  407 ++++++
 mm/cma.c                                           | 1376 ++++++++++++++++++++
 tools/cma/cma-test.c                               |  373 ++++++
 16 files changed, 3629 insertions(+), 0 deletions(-)
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
