Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 84B7E62000E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:01 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/12] Memory Compaction v2r12
Date: Fri, 12 Feb 2010 12:00:47 +0000
Message-Id: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

===== CUT HERE =====

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

The series is in 12 patches

Patch 1 adds documentation on /proc/pagetypeinfo which is extended later
	in the series
Patch 2 allows CONFIG_MIGRATION to be set without CONFIG_NUMA
Patch 3 exports a "unusable free space index" via /proc/pagetypeinfo. It's
	a measure of external fragmentation that takes the size of the
	allocation request into account. It can also be calculated from
	userspace so can be dropped if requested
Patch 4 exports a "fragmentation index" which only has meaning when an
	allocation request fails. It determines if an allocation failure
	would be due to a lack of memory or external fragmentation.
Patch 5 is the compaction mechanism although it's unreachable at this point
Patch 6 adds a means of compacting all of memory with a proc trgger
Patch 7 adds a means of compacting a specific node with a sysfs trigger
Patch 8 adds "direct compaction" before "direct reclaim" if it is
	determined there is a good chance of success.
Patch 9 temporarily disables compaction if an allocation failure occurs
	after compaction.
Patches 10 and 11 address two race conditions within rmap_walk_anon where the
	VMAs or anon_vma can disappear unexpectedly due to the way locks
	are acquired. It's not clear why it was ever safe although the
	strongest possibility is that currently processes migrated only
	their own pages where the anon_vma and VMAs would be guaranteed to
	exist during migration.
Patch 12 is disturbing. It only occurred on ppc64 but it looks like a
	use-after-free race. It's probably something to do with locking
	around page migration but a few more eyes looking at it before
	I start really digging would be helpful.

Testing of compaction was in three stages.  For the test, debugging, preempt,
the sleep watchdog and lockdep were all enabled but nothing nasty popped
out. min_free_kbytes was tuned as recommended by hugeadm to help fragmentation
avoidance and high-order allocations. It was only tested on X86-64 due to
the lack of availability of an X86 and PPC64 test machine for the moment.

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

X86-64
				vanilla		compaction
Final page count:                   896		       898 (attempted 1002)
Total pages reclaimed:           131419		     42851
Total blocks compacted:               0		      1474
Total compact pages alloced:          0		       265

Compaction allocated slightly more pages but reclaimed a lot less - 88568
fewer pages or approximately 346MB worth of IO.

PPC64
				vanilla		compaction
Final page count:                    95                 95 (attempted 110)
Total pages reclaimed:           131419		     42851
Total blocks compacted:               0		      1474
Total compact pages alloced:          0		       265

Similar to X86-64. No more huge pages were allocated byt a lot less was
reclaimed - about 345MB in this case.

The second tests were all performance related - kernbench, netperf, iozone
and sysbench. None showed anything too remarkable.

The last test was a high-order allocation stress test. Many kernel compiles
are started to fill memory with a pressured mix of kernel and movable
allocations. During this, an attempt is made to allocate 90% of memory
as huge pages - one at a time with small delays between attempts to avoid
flooding the IO queue. Funningly, previous tests would have attempted 100%
of memory but compaction pushed up the allocation success rates just enough
that the machine would really go OOM.

                                             vanilla   compaction
Percentage of request allocated X86-64         94.00        97.00
Percentage of request allocated PPC64          67.00        84.00

Compaction had slightly higher success rates on X86-64 but helped
significantly on PPC64 with the much larger huge pages and greater opportunity
for racers between direct reclaimers and page allocators. The main impact
is expected to be in latencies.

This link shows the mean latency between allocation attempts as time goes
by. The Y axis is the average latency and the X axis is the allocation
attempt (whether it succeeded or failed). Three kernels are shown. The
vanilla 2.6.33-rc6 kernel. compaction-v2r12 is this series of patches and
compaction-disabled is this series of patches but CONFIG_COMPACTION is
not set. In those graphs, hydra is the x86-64 machine and powyah is the
ppc64 machine.

http://www.csn.ul.ie/~mel/postings/compaction-20100212/highalloc-interlatency-hydra-compaction-v2r12-mean.ps

The vanilla and compaction-disabled kernels were roughly similar. The
fact that compaction-disabled started with lower latencies is just a
co-incidence. The nature of the test means that luck is a factor. While
the overall success rates between test runs is repeatable, the timings
generally are not. With compaction enabled though, the latencies remain
very low until almost 50% of the allocation requests are made. This lower
latency when memory is available is consistent. At that point, lumpy reclaim
presumably starts being used and latencies increase.

http://www.csn.ul.ie/~mel/postings/compaction-20100212/highalloc-interlatency-powyah-compaction-v2r12-mean.ps

Again, the vanilla and compaction-disabled kernels are roughly similar. With
compaction, latencies remain low and more successful allocations are made.


While the average latencies are good, the standard deviation is also
interesting;

http://www.csn.ul.ie/~mel/postings/compaction-20100212/highalloc-interlatency-hydra-compaction-v2r12-stddev.ps
http://www.csn.ul.ie/~mel/postings/compaction-20100212/highalloc-interlatency-poaysh-compaction-v2r12-stddev.ps

Without compaction, there are very large variances between allocation
attempts. With compaction, they are all steadily low variances until lumpy
reclaim starts being used.

Overall, functional testing did not show up any problems and the performance
is as-expected. However, the three patches related to the page migration
core need careful review to determine why they are necessary at all.

The next stage is figuring out what to do with rmap_walk_anon VMA, if the
set is a merge candidate and if not, what additional work is required or
if the concept is acceptable or not.  Any comment?

 Documentation/filesystems/proc.txt |   66 +++++-
 Documentation/sysctl/vm.txt        |   11 +
 drivers/base/node.c                |    3 +
 include/linux/compaction.h         |   70 +++++
 include/linux/mm.h                 |    1 +
 include/linux/mmzone.h             |    7 +
 include/linux/swap.h               |    5 +
 include/linux/vmstat.h             |    2 +
 kernel/sysctl.c                    |   11 +
 mm/Kconfig                         |   20 +-
 mm/Makefile                        |    1 +
 mm/compaction.c                    |  543 ++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                    |   66 +++++
 mm/rmap.c                          |   19 ++-
 mm/vmscan.c                        |    5 -
 mm/vmstat.c                        |  179 ++++++++++++
 scripts/kconfig/conf.c             |    1 -
 17 files changed, 998 insertions(+), 12 deletions(-)
 create mode 100644 include/linux/compaction.h
 create mode 100644 mm/compaction.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
