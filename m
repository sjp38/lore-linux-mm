Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D5CF76B009A
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:39:17 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWY00L40TTFOL80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:16 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWY008XZTTEMO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:15 +0000 (GMT)
Date: Thu, 29 Dec 2011 13:39:01 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv18 0/11] Contiguous Memory Allocator
Message-id: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

Welcome everyone last time in 2011!

We finally managed to finish (yet) another release of the Contiguous
Memory Allocator patches. This version resolves a lot of issues reported
in the previous version and improves the reliability of the memory
allocation.

The most important changes are code cleanup after a review from Mel
Gorman, fixing of the anoying bugs (like HIGHMEM crash on ARM) and
adding allocation retry procedure in case of temporary migration fail.
This version should finally solve all the issues that are a result of
changing the migration code base from memory hotplug to memory
compaction.

ARM integration code has not been changed since last two versions, it
provides implementation of all the ideas that has been discussed during
Linaro Sprint meeting. Here are the details:

  This version provides a solution for complete integration of CMA to
  DMA mapping subsystem on ARM architecture. The issue caused by double
  dma pages mapping and possible aliasing in coherent memory mapping has
  been finally resolved, both for GFP_ATOMIC case (allocations comes from
  coherent memory pool) and non-GFP_ATOMIC case (allocations comes from
  CMA managed areas).

  For coherent, nommu, ARMv4 and ARMv5 systems the current DMA-mapping
  implementation has been kept.

  For ARMv6+ systems, CMA has been enabled and a special pool of coherent
  memory for atomic allocations has been created. The size of this pool
  defaults to DEFAULT_CONSISTEN_DMA_SIZE/8, but can be changed with
  coherent_pool kernel parameter (if really required).

  All atomic allocations are served from this pool. I've did a little
  simplification here, because there is no separate pool for writecombine
  memory - such requests are also served from coherent pool. I don't
  think that such simplification is a problem here - I found no driver
  that use dma_alloc_writecombine with GFP_ATOMIC flags.

  All non-atomic allocation are served from CMA area. Kernel mapping is
  updated to reflect required memory attributes changes. This is possible
  because during early boot, all CMA area are remapped with 4KiB pages in
  kernel low-memory.

  This version have been tested on Samsung S5PC110 based Goni machine and
  Exynos4 UniversalC210 board with various V4L2 multimedia drivers.

  Coherent atomic allocations has been tested by manually enabling the dma
  bounce for the s3c-sdhci device.

All patches are prepared for Linux Kernel v3.2-rc7.

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

   For more information you can refer to nice LWN articles: 
   http://lwn.net/Articles/447405/ and http://lwn.net/Articles/450286/
   as well as links to previous versions of the CMA framework.

   The CMA framework has been initially developed by Michal Nazarewicz
   at Samsung Poland R&D Center. Since version 9, I've taken over the
   development, because Michal has left the company.

TODO (optional):
- implement support for contiguous memory areas placed in HIGHMEM zone
- resolve issue with movable pages with pending io operations

I would also like to with everyone a Happy New Year! See You again in
2012!

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Links to previous versions of the patchset:
v17: <http://www.spinics.net/lists/arm-kernel/msg148499.html>
v16: <http://www.spinics.net/lists/linux-mm/msg25066.html>
v15: <http://www.spinics.net/lists/linux-mm/msg23365.html>
v14: <http://www.spinics.net/lists/linux-media/msg36536.html>
v13: (internal, intentionally not released)
v12: <http://www.spinics.net/lists/linux-media/msg35674.html>
v11: <http://www.spinics.net/lists/linux-mm/msg21868.html>
v10: <http://www.spinics.net/lists/linux-mm/msg20761.html>
 v9: <http://article.gmane.org/gmane.linux.kernel.mm/60787>
 v8: <http://article.gmane.org/gmane.linux.kernel.mm/56855>
 v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
 v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
 v5: (intentionally left out as CMA v5 was identical to CMA v4)
 v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
 v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
 v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
 v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>


Changelog:

v18:
    1. Addressed comments and suggestions from Mel Godman related to changes
       in memory compaction code, most important points:
	- removed "mm: page_alloc: handle MIGRATE_ISOLATE in free_pcppages_bulk()"
	  and moved all the logic to set_migratetype_isolate - see
	  "mm: page_alloc: set_migratetype_isolate: drain PCP prior to isolating"
	  patch
	- code in "mm: compaction: introduce isolate_{free,migrate}pages_range()"
	  patch have been simplified and improved
	- removed "mm: mmzone: introduce zone_pfn_same_memmap()" patch

    2. Fixed crash on initialization if HIGHMEM is available on ARM platforms

    3. Fixed problems with allocation of contiguous memory if all free pages
       are occupied by page cache and reclaim is required.

    4. Added a workaround for temporary migration failures (now CMA tries
       to allocate different memory block in such case), what heavily increased
       reliability of the CMA.

    5. Minor cleanup here and there.

    6. Rebased onto v3.2-rc7 kernel tree.

v17:
    1. Replaced whole CMA core memory migration code to the new one kindly
       provided by Michal Nazarewicz. The new code is based on memory
       compaction framework not the memory hotplug, like it was before. This
       change has been suggested by Mel Godman.

    2. Addressed most of the comments from Andrew Morton and Mel Gorman in
       the rest of the CMA code.

    3. Fixed broken initialization on ARM systems with DMA zone enabled.

    4. Rebased onto v3.2-rc2 kernel.

v16:
    1. merged a fixup from Michal Nazarewicz to address comments from Dave
       Hansen about checking if pfns belong to the same memory zone

    2. merged a fix from Michal Nazarewicz for incorrect handling of pages
       which belong to page block that is in MIGRATE_ISOLATE state, in very
       rare cases the migrate type of page block might have been changed
       from MIGRATE_CMA to MIGRATE_MOVABLE because of this bug

    3. moved some common code to include/asm-generic

    4. added support for x86 DMA-mapping framework for pci-dma hardware,
       CMA can be now even more widely tested on KVM/QEMU and a lot of common
       x86 boxes

    5. rebased onto next-20111005 kernel tree, which includes changes in ARM
       DMA-mapping subsystem (CONSISTENT_DMA_SIZE removal)

    6. removed patch for CMA s5p-fimc device private regions (served only as
       example) and provided the one that matches real life case - s5p-mfc
       device

v15:
    1. fixed calculation of the total memory after activating CMA area (was
       broken from v12)

    2. more code cleanup in drivers/base/dma-contiguous.c

    3. added address limit for default CMA area

    4. rewrote ARM DMA integration:
	- removed "ARM: DMA: steal memory for DMA coherent mappings" patch
	- kept current DMA mapping implementation for coherent, nommu and
	  ARMv4/ARMv5 systems
	- enabled CMA for all ARMv6+ systems
	- added separate, small pool for coherent atomic allocations, defaults
	  to CONSISTENT_DMA_SIZE/8, but can be changed with kernel parameter
	  coherent_pool=[size]

v14:
    1. Merged with "ARM: DMA: steal memory for DMA coherent mappings" 
       patch, added support for GFP_ATOMIC allocations.

    2. Added checks for NULL device pointer

v13: (internal, intentionally not released)

v12:
    1. Fixed 2 nasty bugs in dma-contiguous allocator:
       - alignment argument was not passed correctly
       - range for dma_release_from_contiguous was not checked correctly

    2. Added support for architecture specfic dma_contiguous_early_fixup()
       function

    3. CMA and DMA-mapping integration for ARM architechture has been
       rewritten to take care of the memory aliasing issue that might
       happen for newer ARM CPUs (mapping of the same pages with different
       cache attributes is forbidden). TODO: add support for GFP_ATOMIC
       allocations basing on the "ARM: DMA: steal memory for DMA coherent
       mappings" patch and implement support for contiguous memory areas
       that are placed in HIGHMEM zone

v11:
    1. Removed genalloc usage and replaced it with direct calls to
       bitmap_* functions, dropped patches that are not needed
       anymore (genalloc extensions)

    2. Moved all contiguous area management code from mm/cma.c
       to drivers/base/dma-contiguous.c

    3. Renamed cm_alloc/free to dma_alloc/release_from_contiguous

    4. Introduced global, system wide (default) contiguous area
       configured with kernel config and kernel cmdline parameters

    5. Simplified initialization to just one function:
       dma_declare_contiguous()

    6. Added example of device private memory contiguous area

v10:
    1. Rebased onto 3.0-rc2 and resolved all conflicts

    2. Simplified CMA to be just a pure memory allocator, for use
       with platfrom/bus specific subsystems, like dma-mapping.
       Removed all device specific functions are calls.

    3. Integrated with ARM DMA-mapping subsystem.

    4. Code cleanup here and there.

    5. Removed private context support.

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

Marek Szyprowski (5):
  mm: add optional memory reclaim in split_free_page()
  drivers: add Contiguous Memory Allocator
  X86: integrate CMA with DMA-mapping subsystem
  ARM: integrate CMA with DMA-mapping subsystem
  ARM: Samsung: use CMA for 2 memory banks for s5p-mfc device

Michal Nazarewicz (6):
  mm: page_alloc: set_migratetype_isolate: drain PCP prior to isolating
  mm: compaction: introduce isolate_{free,migrate}pages_range().
  mm: compaction: export some of the functions
  mm: page_alloc: introduce alloc_contig_range()
  mm: mmzone: MIGRATE_CMA migration type added
  mm: page_isolation: MIGRATE_CMA isolation functions added

 Documentation/kernel-parameters.txt   |    9 +
 arch/Kconfig                          |    3 +
 arch/arm/Kconfig                      |    2 +
 arch/arm/include/asm/dma-contiguous.h |   16 ++
 arch/arm/include/asm/mach/map.h       |    1 +
 arch/arm/kernel/setup.c               |    9 +-
 arch/arm/mm/dma-mapping.c             |  368 +++++++++++++++++++++-----
 arch/arm/mm/init.c                    |   22 ++-
 arch/arm/mm/mm.h                      |    3 +
 arch/arm/mm/mmu.c                     |   29 ++-
 arch/arm/plat-s5p/dev-mfc.c           |   51 +---
 arch/x86/Kconfig                      |    1 +
 arch/x86/include/asm/dma-contiguous.h |   13 +
 arch/x86/include/asm/dma-mapping.h    |    4 +
 arch/x86/kernel/pci-dma.c             |   18 ++-
 arch/x86/kernel/pci-nommu.c           |    8 +-
 arch/x86/kernel/setup.c               |    2 +
 drivers/base/Kconfig                  |   89 +++++++
 drivers/base/Makefile                 |    1 +
 drivers/base/dma-contiguous.c         |  404 ++++++++++++++++++++++++++++
 include/asm-generic/dma-contiguous.h  |   27 ++
 include/linux/device.h                |    4 +
 include/linux/dma-contiguous.h        |  110 ++++++++
 include/linux/mm.h                    |    2 +-
 include/linux/mmzone.h                |   41 +++-
 include/linux/page-isolation.h        |   27 ++-
 mm/Kconfig                            |    2 +-
 mm/Makefile                           |    3 +-
 mm/compaction.c                       |  467 +++++++++++++++++++--------------
 mm/internal.h                         |   35 +++
 mm/memory-failure.c                   |    2 +-
 mm/memory_hotplug.c                   |    6 +-
 mm/page_alloc.c                       |  403 +++++++++++++++++++++++++----
 mm/page_isolation.c                   |   15 +-
 mm/vmstat.c                           |    1 +
 35 files changed, 1773 insertions(+), 425 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-contiguous.h
 create mode 100644 arch/x86/include/asm/dma-contiguous.h
 create mode 100644 drivers/base/dma-contiguous.c
 create mode 100644 include/asm-generic/dma-contiguous.h
 create mode 100644 include/linux/dma-contiguous.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
