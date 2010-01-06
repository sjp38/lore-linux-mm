Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 39D5D6B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:26:16 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC-PATCH 0/7] Memory Compaction v1
Date: Wed,  6 Jan 2010 16:26:02 +0000
Message-Id: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I spent yesterday rebasing the memory compaction code and doing some
additional work on it. It was previously against 2.6.21 but the VM has
changed a bit since then so there are a number of snarl points, places where
it can be improved and places where it may be outright wrong because of
core changes. As a result, I've dropped any acks I had and am starting over.

This basically works on X86-64 flatmem and on qemu-i386. It still needs to
be tested for other architectures, SPARSEMEM and on machine configurations
with memory holes in a zone. I'm posting this now before it's fully ready
because I'm offline all of next week and didn't want to delay it two weeks
when there is something that can be looked at now.

===== CUT HERE =====

This is a prototype of a memory compaction mechanism that reduces external
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

Memory compaction can be triggered in one of two ways. It may be triggered
explicitly by writing a node number to /proc/sys/vm/compact_node. When a
process fails to allocate a high-order page, it may compact memory in an
attempt to satisfy the allocation instead of entering direct reclaim. Explicit
compaction does not finish until the two scanners meet and direct compaction
ends if a suitable page becomes available that would meet watermarks.

The series is in 7 patches

Patch 1 allows CONFIG_MIGRATION to be set without CONFIG_NUMA
Patch 2 exports a "unusable free space index" via /proc/pagetypeinfo. It's
	a measure of external fragmentation that takes the size of the
	allocation request into account. It can also be calculated from
	userspace so can be dropped if requested
Patch 3 exports a "fragmentation index" which only has meaning when an
	allocation request fails. It determines if an allocation failure
	would be due to a lack of memory or external fragmentation.
Patch 4 is the compaction mechanism although it's unreachable code at this
	point
Patch 5 allows the triggering of memory compaction from /proc to aid
	debugging and observe its impact. It always performs a full
	compaction.
Patch 6 tries "direct compaction" before "direct reclaim" if it is
	determined there is a good chance of success.
Patch 7 temporarily disables compaction if an allocation failure occurs
	after compaction.

I did not test with CONFIG_COMPACTION not set so there might be gremlins
there.  Testing of compaction was primitive and represents one of the
easiest cases that can be faced for lumpy reclaim or memory compaction.

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

For the test, I enabled debugging, preempt, the sleep watchdog and lockdep
but nothing nasty popped out. The results were;

2.6.33-rc2 Vanilla
Starting page count: 0
Requesting at each increment: 50 huge pages
1: 50 pages Success time:0.11 rclm:16883 cblock:0 csuccess:0 alloc: 50/50
2: 100 pages Success time:0.10 rclm:13752 cblock:0 csuccess:0 alloc: 50/50
3: 150 pages Success time:0.05 rclm:13303 cblock:0 csuccess:0 alloc: 50/50
4: 200 pages Success time:0.09 rclm:11257 cblock:0 csuccess:0 alloc: 50/50
5: 250 pages Success time:0.07 rclm:14319 cblock:0 csuccess:0 alloc: 50/50
6: 300 pages Success time:0.05 rclm:11158 cblock:0 csuccess:0 alloc: 50/50
7: 350 pages Success time:0.07 rclm:12244 cblock:0 csuccess:0 alloc: 50/50
8: 400 pages Success time:0.14 rclm:8553 cblock:0 csuccess:0 alloc: 50/50
9: 450 pages Success time:0.02 rclm:236 cblock:0 csuccess:0 alloc: 50/50
10: 500 pages Success time:0.03 rclm:142 cblock:0 csuccess:0 alloc: 50/50
11: 550 pages Success time:0.03 rclm:183 cblock:0 csuccess:0 alloc: 50/50
12: 600 pages Success time:0.01 rclm:330 cblock:0 csuccess:0 alloc: 50/50
13: 650 pages Success time:0.01 rclm:182 cblock:0 csuccess:0 alloc: 50/50
14: 700 pages Success time:0.02 rclm:215 cblock:0 csuccess:0 alloc: 50/50
15: 750 pages Success time:0.00 rclm:0 cblock:0 csuccess:0 alloc: 50/50
16: 800 pages Success time:0.02 rclm:0 cblock:0 csuccess:0 alloc: 50/50
17: 850 pages Success time:0.01 rclm:85 cblock:0 csuccess:0 alloc: 50/50
18: 867 pages Success time:0.42 rclm:116 cblock:0 csuccess:0 alloc: 17/50
19: 869 pages Success time:0.81 rclm:85 cblock:0 csuccess:0 alloc: 2/50
20: 870 pages Success time:1.62 rclm:170 cblock:0 csuccess:0 alloc: 1/50
21: 879 pages Success time:0.31 rclm:106 cblock:0 csuccess:0 alloc: 9/50
22: 879 pages Failed time:0.22 rclm:104 cblock:0 csuccess:0
23: 880 pages Success time:1.11 rclm:143 cblock:0 csuccess:0 alloc: 1/50
24: 880 pages Failed time:0.71 rclm:264 cblock:0 csuccess:0
25: 881 pages Success time:1.36 rclm:206 cblock:0 csuccess:0 alloc: 1/50
26: 881 pages Failed time:0.75 rclm:176 cblock:0 csuccess:0
27: 881 pages Failed time:0.94 rclm:284 cblock:0 csuccess:0
28: 881 pages Failed time:0.25 rclm:112 cblock:0 csuccess:0
29: 881 pages Failed time:1.48 rclm:318 cblock:0 csuccess:0
30: 881 pages Failed time:0.96 rclm:206 cblock:0 csuccess:0
Final page count:            881
Total pages reclaimed:       105132
Total blocks compacted:      0
Total compact pages alloced: 0

2.6.33-rc2 Compaction V1
Starting page count: 0
Requesting at each increment: 50 huge pages
1: 50 pages Success time:0.12 rclm:0 cblock:180 csuccess:43 alloc: 50/50
2: 100 pages Success time:0.04 rclm:9976 cblock:24 csuccess:6 alloc: 50/50
3: 150 pages Success time:0.05 rclm:995 cblock:144 csuccess:35 alloc: 50/50
4: 200 pages Success time:0.07 rclm:9054 cblock:60 csuccess:12 alloc: 50/50
5: 250 pages Success time:0.05 rclm:8096 cblock:60 csuccess:12 alloc: 50/50
6: 300 pages Success time:0.04 rclm:4855 cblock:39 csuccess:9 alloc: 50/50
7: 350 pages Success time:0.04 rclm:6375 cblock:23 csuccess:6 alloc: 50/50
8: 400 pages Success time:0.02 rclm:6656 cblock:6 csuccess:4 alloc: 50/50
9: 450 pages Success time:0.04 rclm:3943 cblock:117 csuccess:26 alloc: 50/50
10: 500 pages Success time:0.04 rclm:1534 cblock:136 csuccess:30 alloc: 50/50
11: 527 pages Success time:0.02 rclm:1021 cblock:37 csuccess:6 alloc: 27/50
12: 577 pages Success time:0.10 rclm:6566 cblock:55 csuccess:9 alloc: 50/50
13: 627 pages Success time:0.02 rclm:0 cblock:19 csuccess:19 alloc: 50/50
14: 677 pages Success time:0.01 rclm:0 cblock:5 csuccess:13 alloc: 50/50
15: 727 pages Success time:0.00 rclm:0 cblock:0 csuccess:5 alloc: 50/50
16: 777 pages Success time:0.01 rclm:0 cblock:7 csuccess:12 alloc: 50/50
17: 827 pages Success time:0.01 rclm:0 cblock:6 csuccess:14 alloc: 50/50
18: 877 pages Success time:0.11 rclm:0 cblock:26 csuccess:20 alloc: 50/50
19: 912 pages Success time:18.90 rclm:5958 cblock:218 csuccess:9 alloc: 35/50
20: 913 pages Success time:9.99 rclm:2668 cblock:114 csuccess:1 alloc: 1/50
21: 915 pages Success time:18.20 rclm:4338 cblock:96 csuccess:1 alloc: 2/50
22: 917 pages Success time:6.54 rclm:1827 cblock:42 csuccess:0 alloc: 2/50
23: 917 pages Failed time:4.82 rclm:1327 cblock:54 csuccess:0
24: 919 pages Success time:17.97 rclm:4109 cblock:132 csuccess:2 alloc: 2/50
25: 919 pages Failed time:29.67 rclm:5681 cblock:118 csuccess:0
26: 919 pages Failed time:32.81 rclm:7248 cblock:100 csuccess:0
27: 921 pages Success time:57.01 rclm:12690 cblock:179 csuccess:1 alloc: 2/50
28: 921 pages Failed time:33.72 rclm:7413 cblock:115 csuccess:0
29: 921 pages Failed time:25.91 rclm:5845 cblock:126 csuccess:0
30: 921 pages Failed time:0.48 rclm:334 cblock:41 csuccess:0
31: 921 pages Failed time:0.06 rclm:103 cblock:15 csuccess:0
32: 921 pages Failed time:0.36 rclm:341 cblock:58 csuccess:0
Final page count:            921
Total pages reclaimed:       118953
Total blocks compacted:      2352
Total compact pages alloced: 295

The time differences are marginal but bear in mind that this is an ideal
case of mostly unmapped buffer pages. On nice set of results is between
allocations 13-18 where no pages were reclaimed, some compaction occured
and 300 huge pages were allocated in 0.16 seconds. Furthermore, compaction
allocated a high higher percentage of memory (91% of RAM as huge pages).

The downside appears to be that the compaction kernel reclaimed even more
pages than the vanilla kernel. However, take the cut-off point of 880 pages
that both kernels succeeded. The vanilla kernel had reclaimed 105132 pages
at that point. The kernel with compaction had reclaimed 59071, less than
half of what the vanilla kernel reclaimed. i.e. the bulk of pages reclaimed
with the compaction kernel were to get from 87% of memory allocated to 91%
as huge pages.

These results would appear to be an encouraging enough start.

Comments?

 include/linux/compaction.h |   26 +++
 include/linux/mm.h         |    1 +
 include/linux/mmzone.h     |    7 +
 include/linux/swap.h       |    5 +
 include/linux/vmstat.h     |    2 +
 kernel/sysctl.c            |   11 +
 mm/Kconfig                 |   12 +-
 mm/Makefile                |    1 +
 mm/compaction.c            |  508 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |   74 +++++++
 mm/vmscan.c                |    5 -
 mm/vmstat.c                |  179 ++++++++++++++++
 12 files changed, 825 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/compaction.h
 create mode 100644 mm/compaction.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
