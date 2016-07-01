Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1FB6B025E
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:38:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so21781824wme.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:38:09 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id pl3si4008934wjb.188.2016.07.01.08.38.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 08:38:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 1883798E73
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:38:07 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/31] mm, vmstat: add infrastructure for per-node vmstats
Date: Fri,  1 Jul 2016 16:37:16 +0100
Message-Id: <1467387466-10022-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Series: "Move LRU page reclaim from zones to nodes v7"

This is the latest version of a series that moves LRUs from the zones to
the node that is based upon 4.6-rc3 plus the page allocator optimisation
series. Conceptually, this is simple but there are a lot of details. Some
of the broad motivations for this are;

1. The residency of a page partially depends on what zone the page was
   allocated from.  This is partially combatted by the fair zone allocation
   policy but that is a partial solution that introduces overhead in the
   page allocator paths.

2. Currently, reclaim on node 0 behaves slightly different to node 1. For
   example, direct reclaim scans in zonelist order and reclaims even if
   the zone is over the high watermark regardless of the age of pages
   in that LRU. Kswapd on the other hand starts reclaim on the highest
   unbalanced zone. A difference in distribution of file/anon pages due
   to when they were allocated results can result in a difference in
   again. While the fair zone allocation policy mitigates some of the
   problems here, the page reclaim results on a multi-zone node will
   always be different to a single-zone node.
   it was scheduled on as a result.

3. kswapd and the page allocator scan zones in the opposite order to
   avoid interfering with each other but it's sensitive to timing.  This
   mitigates the page allocator using pages that were allocated very recently
   in the ideal case but it's sensitive to timing. When kswapd is allocating
   from lower zones then it's great but during the rebalancing of the highest
   zone, the page allocator and kswapd interfere with each other. It's worse
   if the highest zone is small and difficult to balance.

4. slab shrinkers are node-based which makes it harder to identify the exact
   relationship between slab reclaim and LRU reclaim.

The reason we have zone-based reclaim is that we used to have
large highmem zones in common configurations and it was necessary
to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
less of a concern as machines with lots of memory will (or should) use
64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
rare. Machines that do use highmem should have relatively low highmem:lowmem
ratios than we worried about in the past.

Conceptually, moving to node LRUs should be easier to understand. The
page allocator plays fewer tricks to game reclaim and reclaim behaves
similarly on all nodes.

The series has been tested on a 16 core UMA machine and a 2-socket 48 core
NUMA machine. The UMA results are presented in most cases as the NUMA machine
behaved similarly.

pagealloc
---------

This is a microbenchmark that shows the benefit of removing the fair zone
allocation policy. It was tested uip to order-4 but only orders 0 and 1 are
shown as the other orders were comparable.

                                           4.7.0-rc3                  4.7.0-rc3
                                      mmotm-20160615              nodelru-v7r17
Min      total-odr0-1               485.00 (  0.00%)           462.00 (  4.74%)
Min      total-odr0-2               354.00 (  0.00%)           341.00 (  3.67%)
Min      total-odr0-4               285.00 (  0.00%)           277.00 (  2.81%)
Min      total-odr0-8               249.00 (  0.00%)           240.00 (  3.61%)
Min      total-odr0-16              230.00 (  0.00%)           224.00 (  2.61%)
Min      total-odr0-32              222.00 (  0.00%)           215.00 (  3.15%)
Min      total-odr0-64              216.00 (  0.00%)           210.00 (  2.78%)
Min      total-odr0-128             214.00 (  0.00%)           208.00 (  2.80%)
Min      total-odr0-256             248.00 (  0.00%)           233.00 (  6.05%)
Min      total-odr0-512             277.00 (  0.00%)           270.00 (  2.53%)
Min      total-odr0-1024            294.00 (  0.00%)           284.00 (  3.40%)
Min      total-odr0-2048            308.00 (  0.00%)           298.00 (  3.25%)
Min      total-odr0-4096            318.00 (  0.00%)           307.00 (  3.46%)
Min      total-odr0-8192            322.00 (  0.00%)           308.00 (  4.35%)
Min      total-odr0-16384           324.00 (  0.00%)           309.00 (  4.63%)
Min      total-odr1-1               729.00 (  0.00%)           686.00 (  5.90%)
Min      total-odr1-2               533.00 (  0.00%)           520.00 (  2.44%)
Min      total-odr1-4               434.00 (  0.00%)           415.00 (  4.38%)
Min      total-odr1-8               390.00 (  0.00%)           364.00 (  6.67%)
Min      total-odr1-16              359.00 (  0.00%)           335.00 (  6.69%)
Min      total-odr1-32              356.00 (  0.00%)           327.00 (  8.15%)
Min      total-odr1-64              356.00 (  0.00%)           321.00 (  9.83%)
Min      total-odr1-128             356.00 (  0.00%)           333.00 (  6.46%)
Min      total-odr1-256             354.00 (  0.00%)           337.00 (  4.80%)
Min      total-odr1-512             366.00 (  0.00%)           340.00 (  7.10%)
Min      total-odr1-1024            373.00 (  0.00%)           354.00 (  5.09%)
Min      total-odr1-2048            375.00 (  0.00%)           354.00 (  5.60%)
Min      total-odr1-4096            374.00 (  0.00%)           354.00 (  5.35%)
Min      total-odr1-8192            370.00 (  0.00%)           355.00 (  4.05%)

This shows a steady improvement throughout. The primary benefit is from
reduced system CPU usage which is obvious from the overall times;

           4.7.0-rc3   4.7.0-rc3
        mmotm-20160615 nodelru-v7
User          174.06      174.58
System       2656.78     2485.21
Elapsed      2885.07     2713.67

The vmstats also showed that the fair zone allocation policy was definitely
removed as can be seen here;

                             4.7.0-rc3   4.7.0-rc3
                          mmotm-20160615nodelru-v7r17
DMA32 allocs               28794408561           0
Normal allocs              48431969998 77226313470
Movable allocs                       0           0

tiobench on ext4
----------------

tiobench is a benchmark that artifically benefits if old pages remain resident
while new pages get reclaimed. The fair zone allocation policy mitigates this
problem so pages age fairly. While the benchmark has problems, it is important
that tiobench performance remains constant as it implies that page aging
problems that the fair zone allocation policy fixes are not re-introduced.

                                         4.7.0-rc3             4.7.0-rc3
                                    mmotm-20160615         nodelru-v7r17
Min      PotentialReadSpeed        90.24 (  0.00%)       90.14 ( -0.11%)
Min      SeqRead-MB/sec-1          80.63 (  0.00%)       83.09 (  3.05%)
Min      SeqRead-MB/sec-2          71.91 (  0.00%)       72.44 (  0.74%)
Min      SeqRead-MB/sec-4          75.20 (  0.00%)       74.32 ( -1.17%)
Min      SeqRead-MB/sec-8          65.30 (  0.00%)       65.21 ( -0.14%)
Min      SeqRead-MB/sec-16         62.62 (  0.00%)       62.12 ( -0.80%)
Min      RandRead-MB/sec-1          0.90 (  0.00%)        0.94 (  4.44%)
Min      RandRead-MB/sec-2          0.96 (  0.00%)        0.97 (  1.04%)
Min      RandRead-MB/sec-4          1.43 (  0.00%)        1.41 ( -1.40%)
Min      RandRead-MB/sec-8          1.67 (  0.00%)        1.72 (  2.99%)
Min      RandRead-MB/sec-16         1.77 (  0.00%)        1.86 (  5.08%)
Min      SeqWrite-MB/sec-1         78.12 (  0.00%)       79.78 (  2.12%)
Min      SeqWrite-MB/sec-2         72.74 (  0.00%)       73.23 (  0.67%)
Min      SeqWrite-MB/sec-4         79.40 (  0.00%)       78.32 ( -1.36%)
Min      SeqWrite-MB/sec-8         73.18 (  0.00%)       71.40 ( -2.43%)
Min      SeqWrite-MB/sec-16        75.82 (  0.00%)       75.24 ( -0.76%)
Min      RandWrite-MB/sec-1         1.18 (  0.00%)        1.15 ( -2.54%)
Min      RandWrite-MB/sec-2         1.05 (  0.00%)        0.99 ( -5.71%)
Min      RandWrite-MB/sec-4         1.00 (  0.00%)        0.96 ( -4.00%)
Min      RandWrite-MB/sec-8         0.91 (  0.00%)        0.92 (  1.10%)
Min      RandWrite-MB/sec-16        0.92 (  0.00%)        0.92 (  0.00%)

This shows that the series has little or not impact on tiobench which is
desirable. It indicates that the fair zone allocation policy was removed
in a manner that didn't reintroduce one class of page aging bug. There
were only minor differences in overall reclaim activity

                             4.7.0-rc3   4.7.0-rc3
                          mmotm-20160615nodelru-v7r17
Minor Faults                    640992      640721
Major Faults                       728         623
Swap Ins                             0           0
Swap Outs                            0           0
DMA allocs                           0           0
DMA32 allocs                  46174282    44219717
Normal allocs                 77949344    79858024
Movable allocs                       0           0
Allocation stalls                   38          76
Direct pages scanned             17463       34865
Kswapd pages scanned          93331163    93302388
Kswapd pages reclaimed        93328173    93299677
Direct pages reclaimed           17463       34865
Kswapd efficiency                  99%         99%
Kswapd velocity              13729.855   13755.612
Direct efficiency                 100%        100%
Direct velocity                  2.569       5.140
Percentage direct scans             0%          0%
Page writes by reclaim               0           0
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate              54          36

kswapd activity was roughly comparable. There was slight differences
in direct reclaim activity but negligible in the context of the overall
workload (velocity of 5 pages per second with the patches applied, 2 pages
per second in the baseline kernel).

pgbench read-only large configuration on ext4
---------------------------------------------

pgbench is a database benchmark that can be sensitive to page reclaim
decisions. This also checks if removing the fair zone allocation policy
is safe

pgbench Transactions
                        4.7.0-rc3             4.7.0-rc3
                   mmotm-20160615         nodelru-v7r17
Hmean    1       191.00 (  0.00%)      193.67 (  1.40%)
Hmean    5       338.59 (  0.00%)      336.99 ( -0.47%)
Hmean    12      374.03 (  0.00%)      386.15 (  3.24%)
Hmean    21      372.24 (  0.00%)      372.02 ( -0.06%)
Hmean    30      383.98 (  0.00%)      370.69 ( -3.46%)
Hmean    32      431.01 (  0.00%)      438.47 (  1.73%)

Negligible differences again. As with tiobench, overall reclaim activity
was comparable.

bonnie++ on ext4
----------------

No interesting performance difference, negligible differences on reclaim
stats.

paralleldd on ext4
------------------

This workload uses varying numbers of dd instances to read large amounts of
data from disk.

paralleldd
                               4.7.0-rc3             4.7.0-rc3
                          mmotm-20160615         nodelru-v7r17
Amean    Elapsd-1       181.57 (  0.00%)      179.63 (  1.07%)
Amean    Elapsd-3       188.29 (  0.00%)      183.68 (  2.45%)
Amean    Elapsd-5       188.02 (  0.00%)      181.73 (  3.35%)
Amean    Elapsd-7       186.07 (  0.00%)      184.11 (  1.05%)
Amean    Elapsd-12      188.16 (  0.00%)      183.51 (  2.47%)
Amean    Elapsd-16      189.03 (  0.00%)      181.27 (  4.10%)

           4.7.0-rc3   4.7.0-rc3
        mmotm-20160615nodelru-v7r17
User         1439.23     1433.37
System       8332.31     8216.01
Elapsed      3619.80     3532.69

There is a slight gain in performance, some of which is from the reduced system
CPU usage. There areminor differences in reclaim activity but nothing significant

                             4.7.0-rc3   4.7.0-rc3
                          mmotm-20160615nodelru-v7r17
Minor Faults                    362486      358215
Major Faults                      1143        1113
Swap Ins                            26           0
Swap Outs                         2920         482
DMA allocs                           0           0
DMA32 allocs                  31568814    28598887
Normal allocs                 46539922    49514444
Movable allocs                       0           0
Allocation stalls                    0           0
Direct pages scanned                 0           0
Kswapd pages scanned          40886878    40849710
Kswapd pages reclaimed        40869923    40835207
Direct pages reclaimed               0           0
Kswapd efficiency                  99%         99%
Kswapd velocity              11295.342   11563.344
Direct efficiency                 100%        100%
Direct velocity                  0.000       0.000
Slabs scanned                   131673      126099
Direct inode steals                 57          60
Kswapd inode steals                762          18

It basically shows that kswapd was active at roughly the same rate in
both kernels. There was also comparable slab scanning activity and direct
reclaim was avoided in both cases. There appears to be a large difference
in numbers of inodes reclaimed but the workload has few active inodes and
is likely a timing artifact. It's interesting to note that the node-lru
did not swap in any pages but given the low swap activity, it's unlikely
to be significant.

stutter
-------

stutter simulates a simple workload. One part uses a lot of anonymous
memory, a second measures mmap latency and a third copies a large file.
The primary metric is checking for mmap latency.

stutter
                             4.7.0-rc3             4.7.0-rc3
                        mmotm-20160615         nodelru-v7r17
Min         mmap     16.8422 (  0.00%)     15.9821 (  5.11%)
1st-qrtle   mmap     57.8709 (  0.00%)     58.0794 ( -0.36%)
2nd-qrtle   mmap     58.4335 (  0.00%)     59.4286 ( -1.70%)
3rd-qrtle   mmap     58.6957 (  0.00%)     59.6862 ( -1.69%)
Max-90%     mmap     58.9388 (  0.00%)     59.8759 ( -1.59%)
Max-93%     mmap     59.0505 (  0.00%)     59.9333 ( -1.50%)
Max-95%     mmap     59.1877 (  0.00%)     59.9844 ( -1.35%)
Max-99%     mmap     60.3237 (  0.00%)     60.2337 (  0.15%)
Max         mmap    285.6454 (  0.00%)    135.6006 ( 52.53%)
Mean        mmap     57.8366 (  0.00%)     58.4884 ( -1.13%)

This shows that there is a slight impact on mmap latency but that
the worst-case outlier is much improved. As the problem with this
benchmark used to be that the kernel stalled for minutes, this
difference is negligible.

Some of the vmstats are interesting

                             4.7.0-rc3   4.7.0-rc3
                          mmotm-20160615nodelru-v7r17
Swap Ins                            58          42
Swap Outs                            0           0
Allocation stalls                   16           0
Direct pages scanned              1374           0
Kswapd pages scanned          42454910    41782544
Kswapd pages reclaimed        41571035    41781833
Direct pages reclaimed            1167           0
Kswapd efficiency                  97%         99%
Kswapd velocity              14774.479   14223.796
Direct efficiency                  84%        100%
Direct velocity                  0.478       0.000
Percentage direct scans             0%          0%
Page writes by reclaim          696918           0
Page writes file                696918           0
Page writes anon                     0           0
Page reclaim immediate            2940         137
Sector Reads                  81644424    81699544
Sector Writes                 99193620    98862160
Page rescued immediate               0           0
Slabs scanned                  1279838       22640

kswapd and direct reclaim activity are similar but the node LRU series
did not attempt to trigger any page writes from reclaim context.

This series is not without its hazards. There are at least three areas
that I'm concerned with even though I could not reproduce any problems in
that area.

1. Reclaim/compaction is going to be affected because the amount of reclaim is
   no longer targetted at a specific zone. Compaction works on a per-zone basis
   so there is no guarantee that reclaiming a few THP's worth page pages will
   have a positive impact on compaction success rates.

2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
   are called is now different. This may or may not be a problem but if it
   is, it'll be because shrinkers are not called enough and some balancing
   is required.

3. The anon/file reclaim ratio may be affected. Pages about to be dirtied are
   distributed between zones and the fair zone allocation policy used to do
   something very similar for anon. The distribution is now different but not
   necessarily in any way that matters but it's still worth bearing in mind.

This patch (of 27):

VM statistic counters for reclaim decisions are zone-based.  If the kernel
is to reclaim on a per-node basis then we need to track per-node
statistics but there is no infrastructure for that.  The most notable
change is that the old node_page_state is renamed to
sum_zone_node_page_state.  The new node_page_state takes a pglist_data and
uses per-node stats but none exist yet.  There is some renaming such as
vm_stat to vm_zone_stat and the addition of vm_node_stat and the renaming
of mod_state to mod_zone_state.  Otherwise, this is mostly a mechanical
patch with no functional change.  There is a lot of similarity between the
node and zone helpers which is unfortunate but there was no obvious way of
reusing the code and maintaining type safety.

Link: http://lkml.kernel.org/r/1466518566-30034-2-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/base/node.c    |  76 +++++++------
 include/linux/mm.h     |   5 +
 include/linux/mmzone.h |  13 +++
 include/linux/vmstat.h |  92 +++++++++++++---
 mm/page_alloc.c        |  10 +-
 mm/vmstat.c            | 282 +++++++++++++++++++++++++++++++++++++++++++++----
 mm/workingset.c        |   9 +-
 7 files changed, 411 insertions(+), 76 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ed0ef0f69489..92d8e090c5b3 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -74,16 +74,16 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
-				node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON) +
-				node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
-		       nid, K(node_page_state(nid, NR_MLOCK)));
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON) +
+				sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON) +
+				sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
 	n += sprintf(buf + n,
@@ -117,31 +117,31 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
 			,
-		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
-		       nid, K(node_page_state(nid, NR_WRITEBACK)),
-		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
-		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
-		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_DIRTY)),
+		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_MAPPED)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(i.sharedram),
-		       nid, node_page_state(nid, NR_KERNEL_STACK) *
+		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
-		       nid, K(node_page_state(nid, NR_PAGETABLE)),
-		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
-		       nid, K(node_page_state(nid, NR_BOUNCE)),
-		       nid, K(node_page_state(nid, NR_WRITEBACK_TEMP)),
-		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
-				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_PAGETABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_UNSTABLE_NFS)),
+		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK_TEMP)),
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
+				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(nid, NR_ANON_THPS) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(nid, NR_SHMEM_THPS) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(nid, NR_SHMEM_PMDMAPPED) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
@@ -160,12 +160,12 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       node_page_state(dev->id, NUMA_HIT),
-		       node_page_state(dev->id, NUMA_MISS),
-		       node_page_state(dev->id, NUMA_FOREIGN),
-		       node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
-		       node_page_state(dev->id, NUMA_LOCAL),
-		       node_page_state(dev->id, NUMA_OTHER));
+		       sum_zone_node_page_state(dev->id, NUMA_HIT),
+		       sum_zone_node_page_state(dev->id, NUMA_MISS),
+		       sum_zone_node_page_state(dev->id, NUMA_FOREIGN),
+		       sum_zone_node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       sum_zone_node_page_state(dev->id, NUMA_LOCAL),
+		       sum_zone_node_page_state(dev->id, NUMA_OTHER));
 }
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
@@ -173,12 +173,18 @@ static ssize_t node_read_vmstat(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	int i;
 	int n = 0;
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
-			     node_page_state(nid, i));
+			     sum_zone_node_page_state(nid, i));
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		n += sprintf(buf+n, "%s %lu\n",
+			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+			     node_page_state(pgdat, i));
 
 	return n;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b21e5f30378e..dd79aa2800a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -933,6 +933,11 @@ static inline struct zone *page_zone(const struct page *page)
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
 }
 
+static inline pg_data_t *page_pgdat(const struct page *page)
+{
+	return NODE_DATA(page_to_nid(page));
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 19425e988bdc..078ecb81e209 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -160,6 +160,10 @@ enum zone_stat_item {
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
+enum node_stat_item {
+	NR_VM_NODE_STAT_ITEMS
+};
+
 /*
  * We do arithmetic on the LRU lists in various places in the code,
  * so it is important to keep the active lists LRU_ACTIVE higher in
@@ -267,6 +271,11 @@ struct per_cpu_pageset {
 #endif
 };
 
+struct per_cpu_nodestat {
+	s8 stat_threshold;
+	s8 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
+};
+
 #endif /* !__GENERATING_BOUNDS.H */
 
 enum zone_type {
@@ -695,6 +704,10 @@ typedef struct pglist_data {
 	struct list_head split_queue;
 	unsigned long split_queue_len;
 #endif
+
+	/* Per-node vmstats */
+	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
+	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index d2da8e053210..d1744aa3ab9c 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -106,20 +106,38 @@ static inline void vm_events_fold_cpu(int cpu)
 		zone_idx(zone), delta)
 
 /*
- * Zone based page accounting with per cpu differentials.
+ * Zone and node-based page accounting with per cpu differentials.
  */
-extern atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
+extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
+extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
 
 static inline void zone_page_state_add(long x, struct zone *zone,
 				 enum zone_stat_item item)
 {
 	atomic_long_add(x, &zone->vm_stat[item]);
-	atomic_long_add(x, &vm_stat[item]);
+	atomic_long_add(x, &vm_zone_stat[item]);
+}
+
+static inline void node_page_state_add(long x, struct pglist_data *pgdat,
+				 enum node_stat_item item)
+{
+	atomic_long_add(x, &pgdat->vm_stat[item]);
+	atomic_long_add(x, &vm_node_stat[item]);
 }
 
 static inline unsigned long global_page_state(enum zone_stat_item item)
 {
-	long x = atomic_long_read(&vm_stat[item]);
+	long x = atomic_long_read(&vm_zone_stat[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
+static inline unsigned long global_node_page_state(enum node_stat_item item)
+{
+	long x = atomic_long_read(&vm_node_stat[item]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -161,31 +179,44 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 }
 
 #ifdef CONFIG_NUMA
-
-extern unsigned long node_page_state(int node, enum zone_stat_item item);
-
+extern unsigned long sum_zone_node_page_state(int node,
+						enum zone_stat_item item);
+extern unsigned long node_page_state(struct pglist_data *pgdat,
+						enum node_stat_item item);
 #else
-
-#define node_page_state(node, item) global_page_state(item)
-
+#define sum_zone_node_page_state(node, item) global_page_state(item)
+#define node_page_state(node, item) global_node_page_state(item)
 #endif /* CONFIG_NUMA */
 
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
+#define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
+#define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
 
 #ifdef CONFIG_SMP
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
 void __dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void __mod_node_page_state(struct pglist_data *, enum node_stat_item item, long);
+void __inc_node_page_state(struct page *, enum node_stat_item);
+void __dec_node_page_state(struct page *, enum node_stat_item);
+
 void mod_zone_page_state(struct zone *, enum zone_stat_item, long);
 void inc_zone_page_state(struct page *, enum zone_stat_item);
 void dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void mod_node_page_state(struct pglist_data *, enum node_stat_item, long);
+void inc_node_page_state(struct page *, enum node_stat_item);
+void dec_node_page_state(struct page *, enum node_stat_item);
+
 extern void inc_zone_state(struct zone *, enum zone_stat_item);
+extern void inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void __inc_zone_state(struct zone *, enum zone_stat_item);
+extern void __inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
+extern void __dec_node_state(struct pglist_data *, enum node_stat_item);
 
 void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
@@ -213,16 +244,34 @@ static inline void __mod_zone_page_state(struct zone *zone,
 	zone_page_state_add(delta, zone, item);
 }
 
+static inline void __mod_node_page_state(struct pglist_data *pgdat,
+			enum node_stat_item item, int delta)
+{
+	node_page_state_add(delta, pgdat, item);
+}
+
 static inline void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_inc(&zone->vm_stat[item]);
-	atomic_long_inc(&vm_stat[item]);
+	atomic_long_inc(&vm_zone_stat[item]);
+}
+
+static inline void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	atomic_long_inc(&pgdat->vm_stat[item]);
+	atomic_long_inc(&vm_node_stat[item]);
 }
 
 static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_dec(&zone->vm_stat[item]);
-	atomic_long_dec(&vm_stat[item]);
+	atomic_long_dec(&vm_zone_stat[item]);
+}
+
+static inline void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	atomic_long_dec(&pgdat->vm_stat[item]);
+	atomic_long_dec(&vm_node_stat[item]);
 }
 
 static inline void __inc_zone_page_state(struct page *page,
@@ -231,12 +280,26 @@ static inline void __inc_zone_page_state(struct page *page,
 	__inc_zone_state(page_zone(page), item);
 }
 
+static inline void __inc_node_page_state(struct page *page,
+			enum node_stat_item item)
+{
+	__inc_node_state(page_pgdat(page), item);
+}
+
+
 static inline void __dec_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
 	__dec_zone_state(page_zone(page), item);
 }
 
+static inline void __dec_node_page_state(struct page *page,
+			enum node_stat_item item)
+{
+	__dec_node_state(page_pgdat(page), item);
+}
+
+
 /*
  * We only use atomic operations to update counters. So there is no need to
  * disable interrupts.
@@ -245,7 +308,12 @@ static inline void __dec_zone_page_state(struct page *page,
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
 
+#define inc_node_page_state __inc_node_page_state
+#define dec_node_page_state __dec_node_page_state
+#define mod_node_page_state __mod_node_page_state
+
 #define inc_zone_state __inc_zone_state
+#define inc_node_state __inc_node_state
 #define dec_zone_state __dec_zone_state
 
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 403c5dcd24da..34e46c02a406 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4247,8 +4247,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = node_page_state(nid, NR_SHMEM);
-	val->freeram = node_page_state(nid, NR_FREE_PAGES);
+	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
@@ -5373,6 +5373,11 @@ static void __meminit setup_zone_pageset(struct zone *zone)
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
 	for_each_possible_cpu(cpu)
 		zone_pageset_init(zone, cpu);
+
+	if (!zone->zone_pgdat->per_cpu_nodestats) {
+		zone->zone_pgdat->per_cpu_nodestats =
+			alloc_percpu(struct per_cpu_nodestat);
+	}
 }
 
 /*
@@ -6078,6 +6083,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
+	pgdat->per_cpu_nodestats = NULL;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 	pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7997f52935c9..90b0737ee4be 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -86,8 +86,10 @@ void vm_events_fold_cpu(int cpu)
  *
  * vm_stat contains the global counters
  */
-atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
-EXPORT_SYMBOL(vm_stat);
+atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
+atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
+EXPORT_SYMBOL(vm_zone_stat);
+EXPORT_SYMBOL(vm_node_stat);
 
 #ifdef CONFIG_SMP
 
@@ -172,13 +174,17 @@ void refresh_zone_stat_thresholds(void)
 	int threshold;
 
 	for_each_populated_zone(zone) {
+		struct pglist_data *pgdat = zone->zone_pgdat;
 		unsigned long max_drift, tolerate_drift;
 
 		threshold = calculate_normal_threshold(zone);
 
-		for_each_online_cpu(cpu)
+		for_each_online_cpu(cpu) {
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
+							= threshold;
+		}
 
 		/*
 		 * Only set percpu_drift_mark if there is a danger that
@@ -238,6 +244,26 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(__mod_zone_page_state);
 
+void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+				long delta)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	long x;
+	long t;
+
+	x = delta + __this_cpu_read(*p);
+
+	t = __this_cpu_read(pcp->stat_threshold);
+
+	if (unlikely(x > t || x < -t)) {
+		node_page_state_add(x, pgdat, item);
+		x = 0;
+	}
+	__this_cpu_write(*p, x);
+}
+EXPORT_SYMBOL(__mod_node_page_state);
+
 /*
  * Optimized increment and decrement functions.
  *
@@ -277,12 +303,34 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s8 v, t;
+
+	v = __this_cpu_inc_return(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v > t)) {
+		s8 overstep = t >> 1;
+
+		node_page_state_add(v + overstep, pgdat, item);
+		__this_cpu_write(*p, -overstep);
+	}
+}
+
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__inc_zone_state(page_zone(page), item);
 }
 EXPORT_SYMBOL(__inc_zone_page_state);
 
+void __inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	__inc_node_state(page_pgdat(page), item);
+}
+EXPORT_SYMBOL(__inc_node_page_state);
+
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
@@ -299,12 +347,34 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s8 v, t;
+
+	v = __this_cpu_dec_return(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v < - t)) {
+		s8 overstep = t >> 1;
+
+		node_page_state_add(v - overstep, pgdat, item);
+		__this_cpu_write(*p, overstep);
+	}
+}
+
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__dec_zone_state(page_zone(page), item);
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
 
+void __dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	__dec_node_state(page_pgdat(page), item);
+}
+EXPORT_SYMBOL(__dec_node_page_state);
+
 #ifdef CONFIG_HAVE_CMPXCHG_LOCAL
 /*
  * If we have cmpxchg_local support then we do not need to incur the overhead
@@ -318,8 +388,8 @@ EXPORT_SYMBOL(__dec_zone_page_state);
  *     1       Overstepping half of threshold
  *     -1      Overstepping minus half of threshold
 */
-static inline void mod_state(struct zone *zone, enum zone_stat_item item,
-			     long delta, int overstep_mode)
+static inline void mod_zone_state(struct zone *zone,
+       enum zone_stat_item item, long delta, int overstep_mode)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -359,26 +429,88 @@ static inline void mod_state(struct zone *zone, enum zone_stat_item item,
 void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 			 long delta)
 {
-	mod_state(zone, item, delta, 0);
+	mod_zone_state(zone, item, delta, 0);
 }
 EXPORT_SYMBOL(mod_zone_page_state);
 
 void inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	mod_state(zone, item, 1, 1);
+	mod_zone_state(zone, item, 1, 1);
 }
 
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	mod_state(page_zone(page), item, 1, 1);
+	mod_zone_state(page_zone(page), item, 1, 1);
 }
 EXPORT_SYMBOL(inc_zone_page_state);
 
 void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	mod_state(page_zone(page), item, -1, -1);
+	mod_zone_state(page_zone(page), item, -1, -1);
 }
 EXPORT_SYMBOL(dec_zone_page_state);
+
+static inline void mod_node_state(struct pglist_data *pgdat,
+       enum node_stat_item item, int delta, int overstep_mode)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	long o, n, t, z;
+
+	do {
+		z = 0;  /* overflow to node counters */
+
+		/*
+		 * The fetching of the stat_threshold is racy. We may apply
+		 * a counter threshold to the wrong the cpu if we get
+		 * rescheduled while executing here. However, the next
+		 * counter update will apply the threshold again and
+		 * therefore bring the counter under the threshold again.
+		 *
+		 * Most of the time the thresholds are the same anyways
+		 * for all cpus in a node.
+		 */
+		t = this_cpu_read(pcp->stat_threshold);
+
+		o = this_cpu_read(*p);
+		n = delta + o;
+
+		if (n > t || n < -t) {
+			int os = overstep_mode * (t >> 1) ;
+
+			/* Overflow must be added to node counters */
+			z = n + os;
+			n = -os;
+		}
+	} while (this_cpu_cmpxchg(*p, o, n) != o);
+
+	if (z)
+		node_page_state_add(z, pgdat, item);
+}
+
+void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+					long delta)
+{
+	mod_node_state(pgdat, item, delta, 0);
+}
+EXPORT_SYMBOL(mod_node_page_state);
+
+void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	mod_node_state(pgdat, item, 1, 1);
+}
+
+void inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	mod_node_state(page_pgdat(page), item, 1, 1);
+}
+EXPORT_SYMBOL(inc_node_page_state);
+
+void dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	mod_node_state(page_pgdat(page), item, -1, -1);
+}
+EXPORT_SYMBOL(dec_node_page_state);
 #else
 /*
  * Use interrupt disable to serialize counter updates
@@ -424,21 +556,69 @@ void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(dec_zone_page_state);
-#endif
 
+void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_node_state(pgdat, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(inc_node_state);
+
+void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+					long delta)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_node_page_state(pgdat, item, delta);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(mod_node_page_state);
+
+void inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	unsigned long flags;
+	struct pglist_data *pgdat;
+
+	pgdat = page_pgdat(page);
+	local_irq_save(flags);
+	__inc_node_state(pgdat, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(inc_node_page_state);
+
+void dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__dec_node_page_state(page, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(dec_node_page_state);
+#endif
 
 /*
  * Fold a differential into the global counters.
  * Returns the number of counters updated.
  */
-static int fold_diff(int *diff)
+static int fold_diff(int *zone_diff, int *node_diff)
 {
 	int i;
 	int changes = 0;
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (diff[i]) {
-			atomic_long_add(diff[i], &vm_stat[i]);
+		if (zone_diff[i]) {
+			atomic_long_add(zone_diff[i], &vm_zone_stat[i]);
+			changes++;
+	}
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		if (node_diff[i]) {
+			atomic_long_add(node_diff[i], &vm_node_stat[i]);
 			changes++;
 	}
 	return changes;
@@ -462,9 +642,11 @@ static int fold_diff(int *diff)
  */
 static int refresh_cpu_vm_stats(bool do_pagesets)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
-	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
 	for_each_populated_zone(zone) {
@@ -477,7 +659,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			if (v) {
 
 				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+				global_zone_diff[i] += v;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				__this_cpu_write(p->expire, 3);
@@ -516,7 +698,22 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 		}
 #endif
 	}
-	changes += fold_diff(global_diff);
+
+	for_each_online_pgdat(pgdat) {
+		struct per_cpu_nodestat __percpu *p = pgdat->per_cpu_nodestats;
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			int v;
+
+			v = this_cpu_xchg(p->vm_node_stat_diff[i], 0);
+			if (v) {
+				atomic_long_add(v, &pgdat->vm_stat[i]);
+				global_node_diff[i] += v;
+			}
+		}
+	}
+
+	changes += fold_diff(global_zone_diff, global_node_diff);
 	return changes;
 }
 
@@ -527,9 +724,11 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
  */
 void cpu_vm_stats_fold(int cpu)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
-	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -543,11 +742,27 @@ void cpu_vm_stats_fold(int cpu)
 				v = p->vm_stat_diff[i];
 				p->vm_stat_diff[i] = 0;
 				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+				global_zone_diff[i] += v;
 			}
 	}
 
-	fold_diff(global_diff);
+	for_each_online_pgdat(pgdat) {
+		struct per_cpu_nodestat *p;
+
+		p = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			if (p->vm_node_stat_diff[i]) {
+				int v;
+
+				v = p->vm_node_stat_diff[i];
+				p->vm_node_stat_diff[i] = 0;
+				atomic_long_add(v, &pgdat->vm_stat[i]);
+				global_node_diff[i] += v;
+			}
+	}
+
+	fold_diff(global_zone_diff, global_node_diff);
 }
 
 /*
@@ -563,16 +778,19 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 			int v = pset->vm_stat_diff[i];
 			pset->vm_stat_diff[i] = 0;
 			atomic_long_add(v, &zone->vm_stat[i]);
-			atomic_long_add(v, &vm_stat[i]);
+			atomic_long_add(v, &vm_zone_stat[i]);
 		}
 }
 #endif
 
 #ifdef CONFIG_NUMA
 /*
- * Determine the per node value of a stat item.
+ * Determine the per node value of a stat item. This function
+ * is called frequently in a NUMA machine, so try to be as
+ * frugal as possible.
  */
-unsigned long node_page_state(int node, enum zone_stat_item item)
+unsigned long sum_zone_node_page_state(int node,
+				 enum zone_stat_item item)
 {
 	struct zone *zones = NODE_DATA(node)->node_zones;
 	int i;
@@ -584,6 +802,19 @@ unsigned long node_page_state(int node, enum zone_stat_item item)
 	return count;
 }
 
+/*
+ * Determine the per node value of a stat item.
+ */
+unsigned long node_page_state(struct pglist_data *pgdat,
+				enum node_stat_item item)
+{
+	long x = atomic_long_read(&pgdat->vm_stat[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
 #endif
 
 #ifdef CONFIG_COMPACTION
@@ -1287,6 +1518,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
+			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
@@ -1301,6 +1533,10 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		v[i] = global_node_page_state(i);
+	v += NR_VM_NODE_STAT_ITEMS;
+
 	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
 			    v + NR_DIRTY_THRESHOLD);
 	v += NR_VM_WRITEBACK_STAT_ITEMS;
@@ -1390,7 +1626,7 @@ int vmstat_refresh(struct ctl_table *table, int write,
 	if (err)
 		return err;
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
-		val = atomic_long_read(&vm_stat[i]);
+		val = atomic_long_read(&vm_zone_stat[i]);
 		if (val < 0) {
 			switch (i) {
 			case NR_ALLOC_BATCH:
diff --git a/mm/workingset.c b/mm/workingset.c
index 8252de4566e9..ba972ac2dfdd 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -351,12 +351,13 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	if (memcg_kmem_enabled())
+	if (memcg_kmem_enabled()) {
 		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
 						     LRU_ALL_FILE);
-	else
-		pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
-			node_page_state(sc->nid, NR_INACTIVE_FILE);
+	} else {
+		pages = sum_zone_node_page_state(sc->nid, NR_ACTIVE_FILE) +
+			sum_zone_node_page_state(sc->nid, NR_INACTIVE_FILE);
+	}
 
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
