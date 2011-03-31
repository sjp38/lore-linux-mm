Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9CB2F8D0047
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:16:14 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LIX006AHBIYFT50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:10 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LIX00AIWBIXHW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:09 +0100 (BST)
Date: Thu, 31 Mar 2011 15:15:56 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv9 0/12] Contiguous Memory Allocator
Message-id: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

Hello everyone,

There have been a bit quiet about Contiguous Memory Allocator for last
months. This is mainly caused by the fact that Michal (the author of CMA
patches) has left our team and we needed some time to takeover the
development.

This version is mainly a rebase and adaptation for 2.6.39-rc1 kernel
release. I've also managed to fix a bunch of nasty bugs that caused
problems if the allocation failed.

A few words for these who see CMA for the first time:

   The Contiguous Memory Allocator (CMA) makes it possible for device
   drivers to allocate big contiguous chunks of memory after the system
   has booted. 

   The main difference from the similar frameworks is the fact that CMA
   allows to transparently reuse memory region reserved for the big
   chunk allocation as a system memory, so no memory is wasted when no
   big chunk is allocated. Once the alloc request is issued, the
   framework will migrate system pages to create a required big chunk of
   physically contiguous memory.

   For more information see the changelog and links to previous versions
   of CMA framework.

The current version is just an allocator that handles allocation of
contiguous memory blocks.  The difference between this patchset and
Kamezawa's alloc_contig_pages() are:

1. alloc_contig_pages() requires MAX_ORDER alignment of allocations
   which may be unsuitable for embeded systems where a few MiBs are
   required.

   Lack of the requirement on the alignment means that several threads
   might try to access the same pageblock/page.  To prevent this from
   happening CMA uses a mutex so that only one cm_alloc()/cm_free()
   function may run at one point.

2. CMA may use its own migratetype (MIGRATE_CMA) which behaves
   similarly to ZONE_MOVABLE but can be put in arbitrary places.

   This is required for us since we need to define two disjoint memory
   ranges inside system RAM.  (ie. in two memory banks (do not confuse
   with nodes)).

3. alloc_contig_pages() scans memory in search for range that could be
   migrated.  CMA on the other hand maintains its own allocator to
   decide where to allocate memory for device drivers and then tries
   to migrate pages from that part if needed.  This is not strictly
   required but I somehow feel it might be faster.

The current version doesn't handle any DMA mapping for the allocated
chunks. This topic will be handled by a separate patch series in the
future.

Despite that, we were able to test this version with real multimedia
hardware on Samsung S5PC110 platform. We used V4L2 drivers that already
contain support for CMA-based memory allocator in videobuf2 framework.
Please refer to last 3 patches of this series to get the idea how it can
be used.


Links to previous versions of the patchset:
v8: <http://article.gmane.org/gmane.linux.kernel.mm/56855>
v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
v5: (intentionally left out as CMA v5 was identical to CMA v4)
v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>


Changelog:

v9: 1. Rebased onto 2.6.39-rc1 and resolved all conflicts

    2. Fixed a bunch of nasty bugs that happened when the allocation
       failed (mainly kernel oops due to NULL ptr dereference).

    3. Introduced testing code: cma-regions compatibility layer and
       videobuf2-cma memory allocator module.

v8: 1. The alloc_contig_range() function has now been separated from
       CMA and put in page_allocator.c.  This function tries to
       migrate all LRU pages in specified range and then allocate the
       range using alloc_contig_freed_pages().

    2. Support for MIGRATE_CMA has been separated from the CMA code.
       I have not tested if CMA works with ZONE_MOVABLE but I see no
       reasons why it shouldn't.

    3. I have added a @private argument when creating CMA contexts so
       that one can reserve memory and not share it with the rest of
       the system.  This way, CMA acts only as allocation algorithm.

v7: 1. A lot of functionality that handled driver->allocator_context
       mapping has been removed from the patchset.  This is not to say
       that this code is not needed, it's just not worth posting
       everything in one patchset.

       Currently, CMA is "just" an allocator.  It uses it's own
       migratetype (MIGRATE_CMA) for defining ranges of pageblokcs
       which behave just like ZONE_MOVABLE but dispite the latter can
       be put in arbitrary places.

    2. The migration code that was introduced in the previous version
       actually started working.


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


Patches in this patchset:

  lib: bitmap: Added alignment offset for bitmap_find_next_zero_area()
  lib: genalloc: Generic allocator improvements

    Some improvements to genalloc API (most importantly possibility to
    allocate memory with alignment requirement).

  mm: move some functions from memory_hotplug.c to page_isolation.c
  mm: alloc_contig_freed_pages() added

    Code "stolen" from Kamezawa.  The first patch just moves code
    around and the second provide function for "allocates" already
    freed memory.

  mm: alloc_contig_range() added

    This is what Kamezawa asked: a function that tries to migrate all
    pages from given range and then use alloc_contig_freed_pages()
    (defined by the previous commit) to allocate those pages. 

  mm: cma: Contiguous Memory Allocator added

    The CMA code but with no MIGRATE_CMA support yet.  This assues
    that one uses a ZONE_MOVABLE.

  mm: MIGRATE_CMA migration type added
  mm: MIGRATE_CMA isolation functions added
  mm: MIGRATE_CMA support added to CMA

    Introduction of the new migratetype and support for it in CMA.
    MIGRATE_CMA works similar to ZONE_MOVABLE expect almost any
    memory range can be marked as one.

  mm: cma: add CMA 'regions style' API (for testing)

    This is a compatiblity layer with older CMA v1 API. It is mostly
    intended to test the CMA framework with multimedia drivers
    that we have available for Samsung S5PC110 platform. Not for
    merging, just an example.

  v4l: videobuf2: add CMA allocator (for testing)

    Main client of CMA 'region style' framework. Updated to latest
    changes in cma and cma-regions API. Used for testing multimedia
    drivers that we have available for Samsung S5PC110 platform. 
    Not for merging, just an example.

  ARM: S5PC110: Added CMA regions to Aquila and Goni boards

    A stub integration with some ARM machines.  Mostly to get the cma
    testing device working.  Not for merging, just an example.



Patch summary:

KAMEZAWA Hiroyuki (2):
  mm: move some functions from memory_hotplug.c to page_isolation.c
  mm: alloc_contig_freed_pages() added

Marek Szyprowski (3):
  mm: cma: add CMA 'regions style' API (for testing)
  v4l: videobuf2: add CMA allocator (for testing)
  ARM: cma: Added CMA regions to Aquila and Goni boards

Michal Nazarewicz (7):
  lib: bitmap: Added alignment offset for bitmap_find_next_zero_area()
  lib: genalloc: Generic allocator improvements
  mm: alloc_contig_range() added
  mm: cma: Contiguous Memory Allocator added
  mm: MIGRATE_CMA migration type added
  mm: MIGRATE_CMA isolation functions added
  mm: MIGRATE_CMA support added to CMA

 arch/arm/mach-s5pv210/mach-aquila.c |   31 ++
 arch/arm/mach-s5pv210/mach-goni.c   |   31 ++
 drivers/media/video/Kconfig         |    6 +
 drivers/media/video/Makefile        |    1 +
 drivers/media/video/videobuf2-cma.c |  227 +++++++++++
 include/linux/bitmap.h              |   24 +-
 include/linux/cma-regions.h         |  340 ++++++++++++++++
 include/linux/cma.h                 |  264 ++++++++++++
 include/linux/genalloc.h            |   46 ++-
 include/linux/mmzone.h              |   43 ++-
 include/linux/page-isolation.h      |   50 ++-
 include/media/videobuf2-cma.h       |   40 ++
 lib/bitmap.c                        |   22 +-
 lib/genalloc.c                      |  182 +++++----
 mm/Kconfig                          |   34 ++
 mm/Makefile                         |    1 +
 mm/cma-regions.c                    |  759 +++++++++++++++++++++++++++++++++++
 mm/cma.c                            |  457 +++++++++++++++++++++
 mm/compaction.c                     |   10 +
 mm/internal.h                       |    3 +
 mm/memory_hotplug.c                 |  109 -----
 mm/page_alloc.c                     |  292 +++++++++++++-
 mm/page_isolation.c                 |  126 ++++++-
 23 files changed, 2827 insertions(+), 271 deletions(-)
 create mode 100644 drivers/media/video/videobuf2-cma.c
 create mode 100644 include/linux/cma-regions.h
 create mode 100644 include/linux/cma.h
 create mode 100644 include/media/videobuf2-cma.h
 create mode 100644 mm/cma-regions.c
 create mode 100644 mm/cma.c

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
