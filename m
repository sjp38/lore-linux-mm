From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/7] Memory Compaction v2
Date: Mon, 18 Jun 2007 10:28:21 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is V2 for the memory compaction patches. They depend on the two starting
patches from the memory hot-remove patchset which I've included here as the
first patch. All comments are welcome and they should be in a state useful
for wider testing.

Changelog since V1
o Bug fix when checking if a given node ID is valid or not
o Using latest patch from Kame-san to compact memory in-kernel
o Added trigger for direct compaction instead of direct reclaim
o Obey watermarks in split_pagebuddy_pages()
o Do not call lru_add_drain_all() frequently

The patchset implements memory compaction for the page allocator reducing
external fragmentation so that free memory exists as fewer, but larger
contiguous blocks. Instead of being a full defragmentation solution,
this focuses exclusively on pages that are movable via the page migration
mechanism.

The compaction mechanism operates within a zone and moves movable pages
towards the higher PFNs. Grouping pages by mobility biases the location
of unmovable pages is biased towards the lower addresses, so the strategies
work in conjunction.

A full compaction run involves two scanners operating within a zone - a
migration and a free scanner. The migration scanner starts at the beginning
of a zone and finds all movable pages within one pageblock_nr_pages-sized
area and isolates them on a migratepages list. The free scanner begins at
the end of the zone and searches on a per-area basis for enough free pages to
migrate all the pages on the migratepages list. As each area is respecively
migrated or exhaused of free pages, the scanners are advanced one area.
A compaction run completes within a zone when the two scanners meet.

This is what /proc/buddyinfo looks like before and after a compaction run.

mel@arnold:~/results$ cat before-buddyinfo.txt 
Node 0, zone      DMA    150     33      6      4      2      1      1      1      1      0      0 
Node 0, zone   Normal   7901   3005   2205   1511    758    245     34      3      0      1      0 

mel@arnold:~/results$ cat after-buddyinfo.txt 
Node 0, zone      DMA    150     33      6      4      2      1      1      1      1      0      0 
Node 0, zone   Normal   1900   1187    609    325    228    178    110     32      6      4     24 

Memory compaction may be triggered explicitly by writing a node number to
/proc/sys/vm/compact_node. When a process fails to allocate a high-order
page, it may compact memory in an attempt to satisfy the allocation. Explicit
compaction does not finish until the two scanners meet. Direct compaction
ends if a suitable page becomes available.

The first patch is a rollup from the memory hot-remove patchset. The two
patches after that are changes to page migration. The second patch allows
CONFIG_MIGRATION to be set without CONFIG_NUMA.  The third patch allows
LRU pages to be isolated in batch instead of acquiring and releasing the
LRU lock a lot.

The fourth patch exports some metrics on external fragmentation which
are relevant to memory compaction. The fifth patch is what implements
memory compaction for a single zone. The sixth patch enables a node to be
compacted explicitly by writing to a special file in /proc and the final
patch implements direct compaction.

This version of the patchset should be usable on all machines and I
consider it ready for testing. It's passed tests here on x86, x86_64 and
ppc64 machines.

Here are some outstanding items on a TODO list in
no particular order.

o Have split_pagebuddy_order make blocks MOVABLE when the free page order
  is greater than pageblock_order
o Avoid racing with other allocators when direct compaction by taking the page
  the moment it becomes free
o Implement compaction_debug boot-time option like slub_debug
o Implement compaction_disable boot-time option just in case
o Investigate using debugfs as the manual compaction trigger instead of proc

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
