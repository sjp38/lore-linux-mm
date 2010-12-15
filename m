Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C13B6B0099
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:40 -0500 (EST)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH0063HLCCZQ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH003K9LCB8J@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:36 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:20 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 00/12] Contiguous Memory Allocator
Message-id: <cover.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

This is yet another version of CMA this time stripped from a lot of
code and with working migration implementation.

   The Contiguous Memory Allocator (CMA) makes it possible for
   device drivers to allocate big contiguous chunks of memory after
   the system has booted.

For more information see 7th patch in the set.


This version fixes some things Kamezawa suggested plus it separates
code that uses MIGRATE_CMA from the rest of the code.  This I hope
will help to grasp the overall idea of CMA.


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


Links to previous versions of the patchset:
v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
v5: (intentionally left out as CMA v5 was identical to CMA v4)
v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>


Changelog:

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

  mm: migrate.c: fix compilation error

    I had some strange compilation error; this patch fixed them.

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
    that one uses a ZONE_MOVABLE.  I must admit I have not test that
    setup yet but I don't see any reasons why it should not work.

  mm: MIGRATE_CMA migration type added
  mm: MIGRATE_CMA isolation functions added
  mm: MIGRATE_CMA support added to CMA

    Introduction of the new migratetype and support for it in CMA.
    MIGRATE_CMA works similar to ZONE_MOVABLE expect almost any
    memory range can be marked as one.

  mm: cma: Test device and application added

    Test device and application.  Not really for merging; just for
    testing really.

  ARM: cma: Added CMA to Aquila, Goni and c210 universal boards

    A stub integration with some ARM machines.  Mostly to get the cma
    testing device working.  Again, not for merging, just an example.


 arch/arm/mach-s5pv210/Kconfig               |    2 +
 arch/arm/mach-s5pv210/mach-aquila.c         |    2 +
 arch/arm/mach-s5pv210/mach-goni.c           |    2 +
 arch/arm/mach-s5pv310/Kconfig               |    1 +
 arch/arm/mach-s5pv310/mach-universal_c210.c |    2 +
 arch/arm/plat-s5p/Makefile                  |    2 +
 arch/arm/plat-s5p/cma-stub.c                |   49 +++
 arch/arm/plat-s5p/include/plat/cma-stub.h   |   21 ++
 drivers/misc/Kconfig                        |   28 ++
 drivers/misc/Makefile                       |    1 +
 drivers/misc/cma-dev.c                      |  238 ++++++++++++++
 include/linux/bitmap.h                      |   24 ++-
 include/linux/cma.h                         |  290 +++++++++++++++++
 include/linux/genalloc.h                    |   46 ++--
 include/linux/mmzone.h                      |   43 ++-
 include/linux/page-isolation.h              |   50 +++-
 lib/bitmap.c                                |   22 +-
 lib/genalloc.c                              |  182 ++++++-----
 mm/Kconfig                                  |   36 ++
 mm/Makefile                                 |    1 +
 mm/cma.c                                    |  455 ++++++++++++++++++++++++++
 mm/compaction.c                             |   10 +
 mm/internal.h                               |    3 +
 mm/memory_hotplug.c                         |  108 -------
 mm/migrate.c                                |    2 +
 mm/page_alloc.c                             |  286 +++++++++++++++--
 mm/page_isolation.c                         |  126 +++++++-
 tools/cma/cma-test.c                        |  457 +++++++++++++++++++++++++++
 28 files changed, 2219 insertions(+), 270 deletions(-)
 create mode 100644 arch/arm/plat-s5p/cma-stub.c
 create mode 100644 arch/arm/plat-s5p/include/plat/cma-stub.h
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 include/linux/cma.h
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
