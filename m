From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/7] [RFC] Memory Compaction v1
Date: Tue, 29 May 2007 18:36:09 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is a prototype for compacting memory to reduce external fragmentation
so that free memory exists as fewer, but larger contiguous blocks. Rather
than being a full defragmentation solution, this focuses exclusively on
pages that are movable via the page migration mechanism.

The compaction mechanism operates within a zone and moves movable pages
towards the end of.  Grouping pages by mobility already biases the location
of unmovable pages is biased towards the lower addresses, so these strategies
work in conjunction.

A single compaction run involves two scanners operating within a zone - a
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

In this patchset, memory is never compacted automatically and is only triggered
by writing a node number to /proc/sys/vm/compact_node. This version of the
patchset is mainly concerned with getting the compaction mechanism correct.

The first patch is a roll-up patch of changes to grouping pages by mobility
posted to the linux-mm list but not merged into -mm yet. The second patch
is from the memory hot-remove patchset which memory compaction can use.

The two patches after that are changes to page migration. The third patch
allows CONFIG_MIGRATION to be set without CONFIG_NUMA.  The fourth patch
allows LRU pages to be isolated in batch instead of acquiring and releasing
the LRU lock a lot.

The fifth patch exports some metrics on external fragmentation which are
relevant to memory compaction. The sixth patch is what implements memory
compaction for a single zone. The final patch enables a node to be compacted
explicitly by writing to a special file in /proc.

This patchset has been tested based on 2.6.22-rc2-mm1 with the following;

o x86 with one CPU, 512MB RAM, FLATMEM
o x86 with four CPUs, 2GB RAM, FLATMEM
o x86_64 with four CPUs, 1GB of RAM, FLATMEM
o x86_64 with four CPUs, 8GB of RAM, DISCONTIG NUMA with 4 nodes
o ppc64 with two CPUs, 2GB of RAM, SPARSEMEM
o IA64 with four CPUs, 1GB of RAM, FLATMEM + VIRTUAL_MEM_MAP

The x86 with one CPU is the only machine that has been tested under
stress. The others was a minimal boot-test followed by compaction under
no load.

This patchset is incomplete. Here some outstanding items on a TODO list in
no particular order.

o Have pageblock_suitable_migration() check the number of free pages properly
o Do not call lru_add_drain_all() on every update
o Add trigger to directly compact before reclaiming for high orders
o Make the fragmentation statistics independent of CONFIG_MIGRATION
o Obey watermarks in split_pagebuddy_page
o Handle free pages intelligently when they are larger than pageblock_order
o Implement compaction_debug boot-time option like slub_debug
o Implement compaction_disable boot-time option just in case
o Investigate using debugfs as the manual compaction trigger instead of proc
o Deal with MIGRATE_RESERVE during compaction properly
o Build test to verify correctness and behaviour under load

Any comments on this first version are welcome.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
