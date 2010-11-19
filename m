Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 914C26B0098
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:35 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JDI31FUQ20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC500EJY31BR0@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:57:58 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 00/13] The Contiguous Memory Allocator framework
Message-id: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

A few people asked about CMA at the LPC, so even though the I have not
yet finished working on the new CMA here it is so that all
interested parties can take a look and decide if it can be used for
their use case.

In particular, this version adds not yet completed support for memory
migration and cma_pin()/cma_unpin() calls.


For those who have not yet stumbled across CMA an excerpt from
documentation:
 
   The Contiguous Memory Allocator (CMA) is a framework, which allows
   setting up a machine-specific configuration for physically-contiguous
   memory management. Memory for devices is then allocated according
   to that configuration.
 
   The main role of the framework is not to allocate memory, but to
   parse and manage memory configurations, as well as to act as an
   in-between between device drivers and pluggable allocators. It is
   thus not tied to any memory allocation method or strategy.
 
For more information please refer to the fourth patch from the
patchset which contains the documentation. 


Links to the previous versions of the patch set:
v5: (intentionally left out as CMA v5 was identical to CMA v4)
v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010/>
v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573/>
v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986/>
v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669/>


Changelog:

v6: 1. Most importantly, v6 introduces support for memory migration.
       The implementation is not yet complete though.

       Migration support means that when CMA is not using memory
       reserved for it, page allocator can allocate pages from it.
       When CMA wants to use the memory, the pages have to be moved
       and/or evicted as to make room for CMA.

       To make it possible it must be guaranteed that only movable and
       reclaimable pages are allocated in CMA controlled regions.
       This is done by introducing a MIGRATE_CMA migrate type that
       guarantees exactly that.

       Some of the migration code is "borrowed" from Kamezawa
       Hiroyuki's alloc_contig_pages() implementation.  The main
       difference is that thanks to MIGRATE_CMA migrate type CMA
       assumes that memory controlled by CMA are is always movable or
       reclaimable so that it makes allocation decisions regardless of
       the whether some pages are actually allocated and migrates them
       if needed.

       The most interesting patches from the patchset that implement
       the functionality are:

         09/13: mm: alloc_contig_free_pages() added
         10/13: mm: MIGRATE_CMA migration type added
         11/13: mm: MIGRATE_CMA isolation functions added
         12/13: mm: cma: Migration support added [wip]

       Currently, kernel panics in some situations which I am trying
       to investigate.

    2. cma_pin() and cma_unpin() functions has been added (after
       a conversation with Johan Mossberg).  The idea is that whenever
       hardware does not use the memory (no transaction is on) the
       chunk can be moved around.  This would allow defragmentation to
       be implemented if desired.  No defragmentation algorithm is
       provided at this time.

    3. Sysfs support has been replaced with debugfs.  I always felt
       unsure about the sysfs interface and when Greg KH pointed it
       out I finally got to rewrite it to debugfs.
    

v5: (intentionally left out as CMA v5 was identical to CMA v4)


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


The whole patch set includes the following patches:

  lib: rbtree: rb_root_init() function added
  lib: bitmap: Added alignment offset for bitmap_find_next_zero_area()
  lib: genalloc: Generic allocator improvements

    The above three are not really related to the CMA as such, they
    only modify various library routines which are then used by CMA.

  mm: cma: Contiguous Memory Allocator added

    This is the main file implementing CMA.  No migration support
    here.  Half of the patch is documentation and header file with
    kernel-doc so it may be worth a while reading if you're
    interested.

  mm: cma: debugfs support added

    This adds debugfs support to CMA.  This patch is not really
    important so you can safely skip it if you are in a hurry. ;)

  mm: cma: Best-fit algorithm added

    This adds a best-fit allocator.  Again, this patch is not that
    important even though it shows how a custom allocator can be
    implemented and added to the CMA framework.

  mm: cma: Test device and application added

    A simple "testing" device and application.  This lets allocate
    chunks form user space as to test basic functionality.  Once
    again, you may safely ignore this patch.

  mm: move some functions to page_isolation.c

    This is Kamezawa Hiroyuki's patch.  It moves some code migration
    related code from mm/memory_hotplug.c to mm/page_isolation.c so
    that it can be used even if memory hotplug is not enabled.

  mm: alloc_contig_free_pages() added

    This is taken from KAMEZAWA Hiroyuki's patch.  It implements an
    alloc_contig_free_pages() and free_contig_pages() functions.  The
    first one allocates a range of pages and the second frees them.
    The pages that are allocated must be in buddy system.

  mm: MIGRATE_CMA migration type added

    This patch adds a new migration type: MIGRATE_CMA.  It's
    characteristics is that only movable and reclaimable pages can be
    allocated from MIGRATE_CMA marked pageblock and once pageblokc's
    migrate type is set to MIGRATE_CMA it is never changed by page
    allocator to anything else.

  mm: MIGRATE_CMA isolation functions added

    This changes several functions that change pageblock migrate type
    to MIGRATE_MOVABLE to take an argument which specifies what type
    to change pageblock's migrate type to.  This is then used with
    MIGRATE_CMA pageblocks.

  mm: cma: Migration support added [wip]

    This adds support for migrating pages from CMA managed regions.
    This means, that when CMA is not using part of the region it is
    given to the page allocator to use.

  ARM: cma: Added CMA to Aquila, Goni and c210 universal boards

    This commit adds support for CMA to three ARM boards.

 Documentation/00-INDEX                      |    2 +
 Documentation/contiguous-memory.txt         |  577 +++++++++
 arch/arm/mach-s5pv210/mach-aquila.c         |   26 +
 arch/arm/mach-s5pv210/mach-goni.c           |   26 +
 arch/arm/mach-s5pv310/mach-universal_c210.c |   17 +
 drivers/misc/Kconfig                        |    8 +
 drivers/misc/Makefile                       |    1 +
 drivers/misc/cma-dev.c                      |  263 +++++
 include/linux/bitmap.h                      |   24 +-
 include/linux/cma.h                         |  569 +++++++++
 include/linux/genalloc.h                    |   46 +-
 include/linux/mmzone.h                      |   30 +-
 include/linux/page-isolation.h              |   47 +-
 include/linux/rbtree.h                      |   11 +
 lib/bitmap.c                                |   22 +-
 lib/genalloc.c                              |  182 ++--
 mm/Kconfig                                  |   98 ++
 mm/Makefile                                 |    2 +
 mm/cma-best-fit.c                           |  382 ++++++
 mm/cma.c                                    | 1671 +++++++++++++++++++++++++++
 mm/compaction.c                             |   10 +
 mm/internal.h                               |    3 +
 mm/memory_hotplug.c                         |  108 --
 mm/page_alloc.c                             |  131 ++-
 mm/page_isolation.c                         |  126 ++-
 tools/cma/cma-test.c                        |  459 ++++++++
 26 files changed, 4575 insertions(+), 266 deletions(-)
 create mode 100644 Documentation/contiguous-memory.txt
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma-best-fit.c
 create mode 100644 mm/cma.c
 create mode 100644 tools/cma/cma-test.c

-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
