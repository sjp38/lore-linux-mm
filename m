Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D2A756B01F6
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 12:02:49 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/14] Memory Compaction v7
Date: Fri,  2 Apr 2010 17:02:34 +0100
Message-Id: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The only change is relatively minor and is around the migration of unmapped
PageSwapCache pages. Specifically, it's not safe to access anon_vma for
these pages when remapping after migration completes so the last patch
makes sure we don't.

Are there any further obstacles to merging?

Changelog since V6
  o Avoid accessing anon_vma when migrating unmapped PageSwapCache pages

Changelog since V5
  o Rebase to mmotm-2010-03-24-14-48
  o Add more reviewed-by's
  o Correct one spelling in vmstat.c and some leader clarifications
  o Split the LRU isolation modes into a separate path
  o Correct a NID change
  o Call migrate_prep less frequently
  o Remove unnecessary inlining
  o Do not interfere with memory hot-remove
  o Do not compact for orders <= PAGE_ALLOC_COSTLY_ORDER
  o page_mapped instead of page_mapcount and allow swapcache to migrate
  o Avoid too many pages being isolated for migration
  o Handle PageSwapCache pages during migration

Changelog since V4
  o Remove unnecessary check for PageLRU and PageUnevictable
  o Fix isolated accounting
  o Close race window between page_mapcount and rcu_read_lock
  o Added a lot more Reviewed-by tags

Changelog since V3
  o Document sysfs entries (subseqently, merged independently)
  o COMPACTION should depend on MMU
  o Comment updates
  o Ensure proc/sysfs triggering of compaction fully completes
  o Rename anon_vma refcount to external_refcount
  o Rebase to mmotm on top of 2.6.34-rc1

Changelog since V2
  o Move unusable and fragmentation indices to separate proc files
  o Express indices as being between 0 and 1
  o Update copyright notice for compaction.c
  o Avoid infinite loop when split free page fails
  o Init compact_resume at least once (impacted x86 testing)
  o Fewer pages are isolated during compaction.
  o LRU lists are no longer rotated when page is busy
  o NR_ISOLATED_* is updated to avoid isolating too many pages
  o Update zone LRU stats correctly when isolating pages
  o Reference count anon_vma instead of insufficient locking with
    use-after-free races in memory compaction
  o Watch for unmapped anon pages during migration
  o Remove unnecessary parameters on a few functions
  o Add Reviewed-by's. Note that I didn't add the Acks and Reviewed
    for the proc patches as they have been split out into separate
    files and I don't know if the Acks are still valid.

Changelog since V1
  o Update help blurb on CONFIG_MIGRATION
  o Max unusable free space index is 100, not 1000
  o Move blockpfn forward properly during compaction
  o Cleanup CONFIG_COMPACTION vs CONFIG_MIGRATION confusion
  o Permissions on /proc and /sys files should be 0200
  o Reduce verbosity
  o Compact all nodes when triggered via /proc
  o Add per-node compaction via sysfs
  o Move defer_compaction out-of-line
  o Fix lock oddities in rmap_walk_anon
  o Add documentation

This patchset is a memory compaction mechanism that reduces external
fragmentation memory by moving GFP_MOVABLE pages to a fewer number of
pageblocks. The term "compaction" was chosen as there are is a number of
mechanisms that are not mutually exclusive that can be used to defragment
memory. For example, lumpy reclaim is a form of defragmentation as was slub
"defragmentation" (really a form of targeted reclaim). Hence, this is called
"compaction" to distinguish it from other forms of defragmentation.

In this implementation, a full compaction run involves two scanners operating
within a zone - a migration and a free scanner. The migration scanner
starts at the beginning of a zone and finds all movable pages within one
pageblock_nr_pages-sized area and isolates them on a migratepages list. The
free scanner begins at the end of the zone and searches on a per-area
basis for enough free pages to migrate all the pages on the migratepages
list. As each area is respectively migrated or exhausted of free pages,
the scanners are advanced one area.  A compaction run completes within a
zone when the two scanners meet.

This method is a bit primitive but is easy to understand and greater
sophistication would require maintenance of counters on a per-pageblock
basis. This would have a big impact on allocator fast-paths to improve
compaction which is a poor trade-off.

It also does not try relocate virtually contiguous pages to be physically
contiguous. However, assuming transparent hugepages were in use, a
hypothetical khugepaged might reuse compaction code to isolate free pages,
split them and relocate userspace pages for promotion.

Memory compaction can be triggered in one of three ways. It may be triggered
explicitly by writing any value to /proc/sys/vm/compact_memory and compacting
all of memory. It can be triggered on a per-node basis by writing any
value to /sys/devices/system/node/nodeN/compact where N is the node ID to
be compacted. When a process fails to allocate a high-order page, it may
compact memory in an attempt to satisfy the allocation instead of entering
direct reclaim. Explicit compaction does not finish until the two scanners
meet and direct compaction ends if a suitable page becomes available that
would meet watermarks.

The series is in 14 patches. The first three are not "core" to the series
but are important pre-requisites.

Patch 1 reference counts anon_vma for rmap_walk_anon(). Without this
	patch, it's possible to use anon_vma after free if the caller is
	not holding a VMA or mmap_sem for the pages in question. While
	there should be no existing user that causes this problem,
	it's a requirement for memory compaction to be stable. The patch
	is at the start of the series for bisection reasons.
Patch 2 skips over anon pages during migration that are no longer mapped
	because there still appeared to be a small window between when
	a page was isolated and migration started during which anon_vma
	could disappear.
Patch 3 merges the KSM and migrate counts. It could be merged with patch 1
	but would be slightly harder to review.
Patch 4 allows CONFIG_MIGRATION to be set without CONFIG_NUMA
Patch 5 exports a "unusable free space index" via /proc/pagetypeinfo. It's
	a measure of external fragmentation that takes the size of the
	allocation request into account. It can also be calculated from
	userspace so can be dropped if requested
Patch 6 exports a "fragmentation index" which only has meaning when an
	allocation request fails. It determines if an allocation failure
	would be due to a lack of memory or external fragmentation.
Patch 7 moves the definition for LRU isolation modes for use by compaction
Patch 8 is the compaction mechanism although it's unreachable at this point
Patch 9 adds a means of compacting all of memory with a proc trgger
Patch 10 adds a means of compacting a specific node with a sysfs trigger
Patch 11 adds "direct compaction" before "direct reclaim" if it is
	determined there is a good chance of success.
Patch 12 adds a sysctl that allows tuning of the threshold at which the
	kernel will compact or direct reclaim
Patch 13 temporarily disables compaction if an allocation failure occurs
	after compaction.
Patch 14 allows the migration of PageSwapCache pages. This patch was not
	as straight-forward as rmap_walk and migration needed extra
	smarts to avoid problems under heavy memory pressure. It's possible
	that memory hot-remove could be affected.

Testing of compaction was in three stages.  For the test, debugging, preempt,
the sleep watchdog and lockdep were all enabled but nothing nasty popped
out. min_free_kbytes was tuned as recommended by hugeadm to help fragmentation
avoidance and high-order allocations. It was tested on X86, X86-64 and PPC64.

Ths first test represents one of the easiest cases that can be faced for
lumpy reclaim or memory compaction.

1. Machine freshly booted and configured for hugepage usage with
	a) hugeadm --create-global-mounts
	b) hugeadm --pool-pages-max DEFAULT:8G
	c) hugeadm --set-recommended-min_free_kbytes
	d) hugeadm --set-recommended-shmmax

	The min_free_kbytes here is important. Anti-fragmentation works best
	when pageblocks don't mix. hugeadm knows how to calculate a value that
	will significantly reduce the worst of external-fragmentation-related
	events as reported by the mm_page_alloc_extfrag tracepoint.

2. Load up memory
	a) Start updatedb
	b) Create in parallel a X files of pagesize*128 in size. Wait
	   until files are created. By parallel, I mean that 4096 instances
	   of dd were launched, one after the other using &. The crude
	   objective being to mix filesystem metadata allocations with
	   the buffer cache.
	c) Delete every second file so that pageblocks are likely to
	   have holes
	d) kill updatedb if it's still running

	At this point, the system is quiet, memory is full but it's full with
	clean filesystem metadata and clean buffer cache that is unmapped.
	This is readily migrated or discarded so you'd expect lumpy reclaim
	to have no significant advantage over compaction but this is at
	the POC stage.

3. In increments, attempt to allocate 5% of memory as hugepages.
	   Measure how long it took, how successful it was, how many
	   direct reclaims took place and how how many compactions. Note
	   the compaction figures might not fully add up as compactions
	   can take place for orders other than the hugepage size

X86				vanilla		compaction
Final page count                    915                916 (attempted 1002)
pages reclaimed                   88872               2942

X86-64				vanilla		compaction
Final page count:                   901                902 (attempted 1002)
Total pages reclaimed:           137573              50655

PPC64				vanilla		compaction
Final page count:                    89                 92 (attempted 110)
Total pages reclaimed:            84727               9345

There was not a dramatic improvement in success rates but it wouldn't be
expected in this case either. What was important is that far fewer pages
were reclaimed in all cases reducing the amount of IO required to satisfy
a huge page allocation.

The second tests were all performance related - kernbench, netperf, iozone
and sysbench. None showed anything too remarkable.

The last test was a high-order allocation stress test. Many kernel compiles
are started to fill memory with a pressured mix of unmovable and movable
allocations. During this, an attempt is made to allocate 90% of memory
as huge pages - one at a time with small delays between attempts to avoid
flooding the IO queue.

                                             vanilla   compaction
Percentage of request allocated X86               96           99
Percentage of request allocated X86-64            96           98
Percentage of request allocated PPC64             51           79

Success rates are a little higher, particularly on PPC64 with the larger
huge pages. What is most interesting is the latency when allocating huge
pages.

X86:    http://www.csn.ul.ie/~mel/postings/compaction-20100402/highalloc-interlatency-arnold-compaction-stress-v7r12-mean.ps
X86_64: http://www.csn.ul.ie/~mel/postings/compaction-20100402/highalloc-interlatency-hydra-compaction-stress-v7r12-mean.ps
PPC64: http://www.csn.ul.ie/~mel/postings/compaction-20100402/highalloc-interlatency-powyah-compaction-stress-v7r12-mean.ps

X86 latency is reduced the least but it is depending heavily on the HIGHMEM
zone to allocate many of its huge pages which is a relatively straight-forward
job. X86-64 and PPC64 both show reductions in average time taken to allocate
huge pages. It is not reduced to zero because the system is under enough
memory pressure that reclaim is still required for some of the allocations.

What is also enlightening in the same directory is the "stddev" files. Each
of them show that the variance between allocation times is heavily reduced.

 Documentation/ABI/testing/sysfs-devices-node |    7 +
 Documentation/filesystems/proc.txt           |   25 +-
 Documentation/sysctl/vm.txt                  |   29 ++-
 drivers/base/node.c                          |    3 +
 include/linux/compaction.h                   |   81 ++++
 include/linux/mm.h                           |    1 +
 include/linux/mmzone.h                       |    7 +
 include/linux/rmap.h                         |   27 +-
 include/linux/swap.h                         |    6 +
 include/linux/vmstat.h                       |    2 +
 kernel/sysctl.c                              |   25 ++
 mm/Kconfig                                   |   18 +-
 mm/Makefile                                  |    1 +
 mm/compaction.c                              |  589 ++++++++++++++++++++++++++
 mm/ksm.c                                     |    4 +-
 mm/migrate.c                                 |   48 ++-
 mm/page_alloc.c                              |   73 ++++
 mm/rmap.c                                    |   10 +-
 mm/vmscan.c                                  |    5 -
 mm/vmstat.c                                  |  218 ++++++++++
 20 files changed, 1145 insertions(+), 34 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-devices-node
 create mode 100644 include/linux/compaction.h
 create mode 100644 mm/compaction.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
