From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/13] Reduce external fragmentation by grouping pages by mobility v30
Date: Mon, 10 Sep 2007 12:20:11 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Here is a restacked version of the grouping pages by mobility patches
based on the patches currently in your tree. It should be  a drop-in
replacement for what is in 2.6.23-rc4-mm1 and is what I propose for merging
to mainline. The change from what you have already is that the redundant
patches are removed. For example, the patches that made grouping pages by
mobility configurable and later removed that ability do not exist in this
set. Simiarly, the patches for grouping high-order atomic allocations together
does not exist. Also note that the first patch related to IA-64 in this set
appears unrelated but it's required by patches and having the change at the
start makes the patchset more comprehensible in terms of dependencies. This
rebasing work is largely the work of Andy Whitcroft. Thanks Andy.

The patches replaced in -mm are as follows;

add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages.patch
split-the-free-lists-for-movable-and-unmovable-allocations.patch
choose-pages-from-the-per-cpu-list-based-on-migration-type.patch
add-a-configure-option-to-group-pages-by-mobility.patch
drain-per-cpu-lists-when-high-order-allocations-fail.patch
move-free-pages-between-lists-on-steal.patch
group-short-lived-and-reclaimable-kernel-allocations.patch
group-high-order-atomic-allocations.patch
do-not-group-pages-by-mobility-type-on-low-memory-systems.patch
bias-the-placement-of-kernel-pages-at-lower-pfns.patch
be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback.patch
fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2.patch
fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2-fix.patch
fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2-fix-fix.patch
bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch
remove-page_group_by_mobility.patch
dont-group-high-order-atomic-allocations.patch
fix-calculation-in-move_freepages_block-for-counting-pages.patch
do-not-depend-on-max_order-when-grouping-pages-by-mobility.patch
print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo.patch

Note that the patch
breakout-page_order-to-internalh-to-avoid-special-knowledge-of-the-buddy-allocator.patch
is not in the list and remains in -mm as part of page-owner tracking. In
the series file, the breakout patch is placed after this new patchset.

To refresh;

The objective of this patchset is to keep the system in a state where actions
such as page reclaim or memory compaction will reduce external fragmentation
in the system. It works by grouping pages of similar mobility together in
PAGEBLOCK_NR_PAGES areas. The types of mobility are

UNMOVABLE - Pages that cannot be trivially reclaimed or moved
MOVABLE - Pages that can be moved using the page migration mechanism
RECLAIMABLE - Pages that the kernel can often directly reclaim such as
	those used for inode caches
RESERVE - The areas where min_free_kbyte-related pages should be stored

Instead of having one MAX_ORDER-sized array of free lists in struct free_area,
there is one for each type of mobility.  Once a 2^pageblock_order (typically
the size of the system large page) area of pages is split for a type of
allocation, the remaining unused portion is placed on the free-lists for
that type prioritising its use for compatible mobility allocations.  Hence,
over time, pages of the different types can be clustered together.

When the preferred freelists are expired, the largest possible block is
taken from an alternative list. Again, the unused portion is placed on the
free lists of the preferred allocation-type.

This grouping clearly requires additional work in the page allocator.
kernbench shows effectively no performance difference varying between -0.2%
and +1% on a variety of test machines.  Success rates for huge page allocation
are dramatically increased.  For example, on a ppc64 machine, the vanilla
kernel was only able to allocate 1% of memory as a hugepage and this was
due to a single hugepage reserved as min_free_kbytes.  With these patches
applied, 40% was allocatable as superpages.

These patches work in conjunction with the ZONE_MOVABLE patches that were
merged for 2.6.23-rc1, particularly the allocations that have already been
flagged as __GFP_MOVABLE.

Changelog Since V29
o Remove redundant patches
o Keep min_free_pages contiguous as much as possible
o Agressively group RECLAIMABLE pages together
o Bug fixes that were applied during the time in -mm

Changelog Since V28
o Group high-order atomic allocations together
o It is no longer required to set min_free_kbytes to 10% of memory. A value
  of 16384 in most cases will be sufficient
o Now applied with zone-based anti-fragmentation
o Fix incorrect VM_BUG_ON within buffered_rmqueue()
o Reorder the stack so later patches do not back out work from earlier patches
o Fix bug were journal pages were being treated as movable
o Bias placement of non-movable pages to lower PFNs
o More agressive clustering of reclaimable pages in reactions to workloads
  like updatedb that flood the size of inode caches

Changelog Since V27

o Renamed anti-fragmentation to Page Clustering. Anti-fragmentation was giving
  the mistaken impression that it was the 100% solution for high order
  allocations. Instead, it greatly increases the chances high-order
  allocations will succeed and lays the foundation for defragmentation and
  memory hot-remove to work properly
o Redefine page groupings based on ability to migrate or reclaim instead of
  basing on reclaimability alone
o Get rid of spurious inits
o Per-cpu lists are no longer split up per-type. Instead the per-cpu list is
  searched for a page of the appropriate type
o Added more explanation commentary
o Fix up bug in pageblock code where bitmap was used before being initalised

Changelog Since V26
o Fix double init of lists in setup_pageset

Changelog Since V25
o Fix loop order of for_each_rclmtype_order so that order of loop matches args
o gfpflags_to_rclmtype uses gfp_t instead of unsigned long
o Rename get_pageblock_type() to get_page_rclmtype()
o Fix alignment problem in move_freepages()
o Add mechanism for assigning flags to blocks of pages instead of page->flags
o On fallback, do not examine the preferred list of free pages a second time

Following this email are 14 patches that implement the page grouping feature.
These apply to mainline but can also act as a drop-in replacement for the
patches that are in -mm.

The first patch changes how IA-64 parses the hugepagesz parameter so that
is occurs before memory initialisation. The second patch adds a bitmap that
stores flags per PAGEBLOCK_NR_PAGES block in the system. The third patch
is a fix to the pageblock flags patch that still exists due to it being
developed by Bob Picco.

The fourth patch splits the free lists between movable and all other
allocations.  Following that is a patch that deals with per-cpu pages so that
the free-lists are not containimated by pages of the wrong mobility type.
Next is patch to group temporary and reclaimable pages together in the
same areas and the last functionality patch drains the per-cpu lists when
a high-order allocation fails.

The remaining patches in the set deal with controlling the situations that
can lead to external fragmentation later. They include biasing the location of
unmovable pages to the lower PFNs and being more aggressive about clustering
reclaimable pages together rather than letting them get scattered throughout
the address space that would happen during such activities as updatedb.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
