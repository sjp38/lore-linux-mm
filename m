From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/12] Group pages of related mobility together to reduce external fragmentation v28
Date: Thu,  1 Mar 2007 10:02:29 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is the latest revision of the anti-fragmentation patches. Of
particular note in this version is special treatment of high-order atomic
allocations. Care is taken to group them together and avoid grouping pages
of other types near them. Artifical tests imply that it works. I'm trying to
get the hardware together that would allow setting up of a "real" test. If
anyone already has a setup and test that can trigger the atomic-allocation
problem, I'd appreciate a test of these patches and a report.  The second
major change is that these patches will apply cleanly with patches that
implement anti-fragmentation through zones.

kernbench shows effectively no performance difference varying between -0.2%
and +2% on a variety of test machines. Success rates for huge page allocation
are dramatically increased. For example, on a ppc64 machine, the vanilla
kernel was only able to allocate 1% of memory as a hugepage and this was
due to a single hugepage reserved as min_free_kbytes. With these patches
applied, 17% was allocatable as superpages.  With reclaim-related fixes from
Andy Whitcroft, it was 40% and further reclaim-related improvements should
increase this further.

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

The purpose of these patches is to reduce external fragmentation by grouping
pages of related types together. When pages are migrated (or reclaimed under
memory pressure), large contiguous pages will be freed. 

This patch works by categorising allocations by their ability to migrate;

Movable - The pages may be moved with the page migration mechanism. These are
	generally userspace pages. 

Reclaimable - These are allocations for some kernel caches that are
	reclaimable or allocations that are known to be very short-lived.

Unmovable - These are pages that are allocated by the kernel that
	are not trivially reclaimed. For example, the memory allocated for a
	loaded module would be in this category. By default, allocations are
	considered to be of this type

HighAtomic - These are high-order allocations belonging to callers that
	cannot sleep or perform any IO. In practice, this is restricted to
	jumbo frame allocation for network receive. It is assumed that the
	allocations are short-lived

Instead of having one MAX_ORDER-sized array of free lists in struct free_area,
there is one for each type of reclaimability. Once a 2^MAX_ORDER block of
pages is split for a type of allocation, it is added to the free-lists for
that type, in effect reserving it. Hence, over time, pages of the different
types can be clustered together.

When the preferred freelists are expired, the largest possible block is taken
from an alternative list. Buddies that are split from that large block are
placed on the preferred allocation-type freelists to mitigate fragmentation.

This implementation gives best-effort for low fragmentation in all zones.
Ideally, min_free_kbytes needs to be set to a value equal to
4 * (1 << (MAX_ORDER-1)) pages in most cases. This would be 16384 on x86
and x86_64 for example.

Our tests show that about 60-70% of physical memory can be allocated on
a desktop after a few days uptime. In benchmarks and stress tests, we are
finding that 80% of memory is available as contiguous blocks at the end of
the test. To compare, a standard kernel was getting < 1% of memory as large
pages on a desktop and about 8-12% of memory as large pages at the end of
stress tests.

Following this email are 12 patches that implement thie page grouping
feature. The first patch introduces a mechanism for storing flags related
to a whole block of pages. Then allocations are split between movable and
all other allocations.  Following that are patches to deal with per-cpu
pages and make the mechanism configurable. The next patch moves free pages
between lists when partially allocated blocks are used for pages of another
migrate type. The second last patch groups reclaimable kernel allocations
such as inode caches together. The final patch related to groupings keeps
high-order atomic allocations.

The last two patches are more concerned with control of fragmentation. The
second last patch biases placement of non-movable allocations towards the
start of memory. This is with a view of supporting memory hot-remove of
DIMMs with higher PFNs in the future. The biasing could be enforced a lot
heavier but it would cost. The last patch agressively clusters reclaimable
pages like inode caches together.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
