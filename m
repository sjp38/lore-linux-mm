Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCE46B0253
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:37:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so21753545wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:37:59 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id 124si4563495wmd.50.2016.07.01.08.37.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 08:37:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id C0C9698B2F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:37:56 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Date: Fri,  1 Jul 2016 16:37:15 +0100
Message-Id: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Previous releases double accounted LRU stats on the zone and the node
because it was required by should_reclaim_retry. The last patch in the
series removes the double accounting. It's not integrated with the series
as reviewers may not like the solution. If not, it can be safely dropped
without a major impact to the results.

Changelog since v7
o Rebase onto current mmots
o Avoid double accounting of stats in node and zone
o Kswapd will avoid more reclaim if an eligible zone is available
o Remove some duplications of sc->reclaim_idx and classzone_idx
o Print per-node stats in zoneinfo

Changelog since v6
o Correct reclaim_idx when direct reclaiming for memcg
o Also account LRU pages per zone for compaction/reclaim
o Add page_pgdat helper with more efficient lookup
o Init pgdat LRU lock only once
o Slight optimisation to wake_all_kswapds
o Always wake kcompactd when kswapd is going to sleep
o Rebase to mmotm as of June 15th, 2016

Changelog since v5
o Rebase and adjust to changes

Changelog since v4
o Rebase on top of v3 of page allocator optimisation series

Changelog since v3
o Rebase on top of the page allocator optimisation series
o Remove RFC tag

This is the latest version of a series that moves LRUs from the zones to
the node that is based upon 4.7-rc4 with Andrew's tree applied. While this
is a current rebase, the test results were based on mmotm as of June 23rd.
Conceptually, this series is simple but there are a lot of details. Some
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

The series has been tested on a 16 core UMA machine and a 2-socket 48
core NUMA machine. The UMA results are presented in most cases as the NUMA
machine behaved similarly.

pagealloc
---------

This is a microbenchmark that shows the benefit of removing the fair zone
allocation policy. It was tested uip to order-4 but only orders 0 and 1 are
shown as the other orders were comparable.

                                           4.7.0-rc4                  4.7.0-rc4
                                      mmotm-20160623                 nodelru-v8
Min      total-odr0-1               490.00 (  0.00%)           463.00 (  5.51%)
Min      total-odr0-2               349.00 (  0.00%)           325.00 (  6.88%)
Min      total-odr0-4               288.00 (  0.00%)           272.00 (  5.56%)
Min      total-odr0-8               250.00 (  0.00%)           235.00 (  6.00%)
Min      total-odr0-16              234.00 (  0.00%)           222.00 (  5.13%)
Min      total-odr0-32              223.00 (  0.00%)           205.00 (  8.07%)
Min      total-odr0-64              217.00 (  0.00%)           202.00 (  6.91%)
Min      total-odr0-128             214.00 (  0.00%)           207.00 (  3.27%)
Min      total-odr0-256             242.00 (  0.00%)           242.00 (  0.00%)
Min      total-odr0-512             272.00 (  0.00%)           265.00 (  2.57%)
Min      total-odr0-1024            290.00 (  0.00%)           283.00 (  2.41%)
Min      total-odr0-2048            302.00 (  0.00%)           296.00 (  1.99%)
Min      total-odr0-4096            311.00 (  0.00%)           306.00 (  1.61%)
Min      total-odr0-8192            314.00 (  0.00%)           309.00 (  1.59%)
Min      total-odr0-16384           315.00 (  0.00%)           309.00 (  1.90%)
Min      total-odr1-1               741.00 (  0.00%)           716.00 (  3.37%)
Min      total-odr1-2               565.00 (  0.00%)           524.00 (  7.26%)
Min      total-odr1-4               457.00 (  0.00%)           427.00 (  6.56%)
Min      total-odr1-8               408.00 (  0.00%)           371.00 (  9.07%)
Min      total-odr1-16              383.00 (  0.00%)           344.00 ( 10.18%)
Min      total-odr1-32              378.00 (  0.00%)           334.00 ( 11.64%)
Min      total-odr1-64              383.00 (  0.00%)           334.00 ( 12.79%)
Min      total-odr1-128             376.00 (  0.00%)           342.00 (  9.04%)
Min      total-odr1-256             381.00 (  0.00%)           343.00 (  9.97%)
Min      total-odr1-512             388.00 (  0.00%)           349.00 ( 10.05%)
Min      total-odr1-1024            386.00 (  0.00%)           356.00 (  7.77%)
Min      total-odr1-2048            389.00 (  0.00%)           362.00 (  6.94%)
Min      total-odr1-4096            389.00 (  0.00%)           362.00 (  6.94%)
Min      total-odr1-8192            389.00 (  0.00%)           362.00 (  6.94%)

This shows a steady improvement throughout. The primary benefit is from
reduced system CPU usage which is obvious from the overall times;

           4.7.0-rc4   4.7.0-rc4
        mmotm-20160623nodelru-v8
User          191.39      191.61
System       2651.24     2504.48
Elapsed      2904.40     2757.01

The vmstats also showed that the fair zone allocation policy was definitely
removed as can be seen here;


                             4.7.0-rc3   4.7.0-rc3
                          mmotm-20160623 nodelru-v8
DMA32 allocs               28794771816           0
Normal allocs              48432582848 77227356392
Movable allocs                       0           0

tiobench on ext4
----------------

tiobench is a benchmark that artifically benefits if old pages remain resident
while new pages get reclaimed. The fair zone allocation policy mitigates this
problem so pages age fairly. While the benchmark has problems, it is important
that tiobench performance remains constant as it implies that page aging
problems that the fair zone allocation policy fixes are not re-introduced.

                                         4.7.0-rc4             4.7.0-rc4
                                    mmotm-20160623            nodelru-v8
Min      PotentialReadSpeed        89.65 (  0.00%)       90.34 (  0.77%)
Min      SeqRead-MB/sec-1          82.68 (  0.00%)       83.13 (  0.54%)
Min      SeqRead-MB/sec-2          72.76 (  0.00%)       72.15 ( -0.84%)
Min      SeqRead-MB/sec-4          75.13 (  0.00%)       74.23 ( -1.20%)
Min      SeqRead-MB/sec-8          64.91 (  0.00%)       65.25 (  0.52%)
Min      SeqRead-MB/sec-16         62.24 (  0.00%)       62.76 (  0.84%)
Min      RandRead-MB/sec-1          0.88 (  0.00%)        0.95 (  7.95%)
Min      RandRead-MB/sec-2          0.95 (  0.00%)        0.94 ( -1.05%)
Min      RandRead-MB/sec-4          1.43 (  0.00%)        1.46 (  2.10%)
Min      RandRead-MB/sec-8          1.61 (  0.00%)        1.58 ( -1.86%)
Min      RandRead-MB/sec-16         1.80 (  0.00%)        1.93 (  7.22%)
Min      SeqWrite-MB/sec-1         76.41 (  0.00%)       78.84 (  3.18%)
Min      SeqWrite-MB/sec-2         74.11 (  0.00%)       73.35 ( -1.03%)
Min      SeqWrite-MB/sec-4         80.05 (  0.00%)       78.69 ( -1.70%)
Min      SeqWrite-MB/sec-8         72.88 (  0.00%)       71.38 ( -2.06%)
Min      SeqWrite-MB/sec-16        75.91 (  0.00%)       75.81 ( -0.13%)
Min      RandWrite-MB/sec-1         1.18 (  0.00%)        1.12 ( -5.08%)
Min      RandWrite-MB/sec-2         1.02 (  0.00%)        1.02 (  0.00%)
Min      RandWrite-MB/sec-4         1.05 (  0.00%)        0.99 ( -5.71%)
Min      RandWrite-MB/sec-8         0.89 (  0.00%)        0.92 (  3.37%)
Min      RandWrite-MB/sec-16        0.92 (  0.00%)        0.89 ( -3.26%)

This shows that the series has little or not impact on tiobench which is
desirable. It indicates that the fair zone allocation policy was removed
in a manner that didn't reintroduce one class of page aging bug. There
were only minor differences in overall reclaim activity

                             4.7.0-rc4   4.7.0-rc4
                          mmotm-20160623nodelru-v8
Minor Faults                    645838      644036
Major Faults                       573         593
Swap Ins                             0           0
Swap Outs                            0           0
Allocation stalls                   24           0
DMA allocs                           0           0
DMA32 allocs                  46041453    44154171
Normal allocs                 78053072    79865782
Movable allocs                       0           0
Direct pages scanned             10969       54504
Kswapd pages scanned          93375144    93250583
Kswapd pages reclaimed        93372243    93247714
Direct pages reclaimed           10969       54504
Kswapd efficiency                  99%         99%
Kswapd velocity              13741.015   13711.950
Direct efficiency                 100%        100%
Direct velocity                  1.614       8.014
Percentage direct scans             0%          0%
Zone normal velocity          8641.875   13719.964
Zone dma32 velocity           5100.754       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate              37          54

kswapd activity was roughly comparable. There were differences in direct
reclaim activity but negligible in the context of the overall workload
(velocity of 8 pages per second with the patches applied, 1.6 pages per
second in the baseline kernel).

pgbench read-only large configuration on ext4
---------------------------------------------

pgbench is a database benchmark that can be sensitive to page reclaim
decisions. This also checks if removing the fair zone allocation policy
is safe

pgbench Transactions
                        4.7.0-rc4             4.7.0-rc4
                   mmotm-20160623            nodelru-v8
Hmean    1       188.26 (  0.00%)      189.78 (  0.81%)
Hmean    5       330.66 (  0.00%)      328.69 ( -0.59%)
Hmean    12      370.32 (  0.00%)      380.72 (  2.81%)
Hmean    21      368.89 (  0.00%)      369.00 (  0.03%)
Hmean    30      382.14 (  0.00%)      360.89 ( -5.56%)
Hmean    32      428.87 (  0.00%)      432.96 (  0.95%)

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
                             4.7.0-rc4             4.7.0-rc4
                        mmotm-20160623            nodelru-v8
Min         mmap     16.6283 (  0.00%)     16.1394 (  2.94%)
1st-qrtle   mmap     54.7570 (  0.00%)     55.2975 ( -0.99%)
2nd-qrtle   mmap     57.3163 (  0.00%)     57.5230 ( -0.36%)
3rd-qrtle   mmap     58.9976 (  0.00%)     58.0537 (  1.60%)
Max-90%     mmap     59.7433 (  0.00%)     58.3910 (  2.26%)
Max-93%     mmap     60.1298 (  0.00%)     58.4801 (  2.74%)
Max-95%     mmap     73.4112 (  0.00%)     58.5537 ( 20.24%)
Max-99%     mmap     92.8542 (  0.00%)     58.9673 ( 36.49%)
Max         mmap   1440.6569 (  0.00%)    137.6875 ( 90.44%)
Mean        mmap     59.3493 (  0.00%)     55.5153 (  6.46%)
Best99%Mean mmap     57.2121 (  0.00%)     55.4194 (  3.13%)
Best95%Mean mmap     55.9113 (  0.00%)     55.2813 (  1.13%)
Best90%Mean mmap     55.6199 (  0.00%)     55.1044 (  0.93%)
Best50%Mean mmap     53.2183 (  0.00%)     52.8330 (  0.72%)
Best10%Mean mmap     45.9842 (  0.00%)     42.3740 (  7.85%)
Best5%Mean  mmap     43.2256 (  0.00%)     38.8660 ( 10.09%)
Best1%Mean  mmap     32.9388 (  0.00%)     27.7577 ( 15.73%)

This shows a number of improvements with the worst-case outlier greatly
improved.

Some of the vmstats are interesting

                             4.7.0-rc4   4.7.0-rc4
                          mmotm-20160623nodelru-v8
Swap Ins                           163         239
Swap Outs                            0           0
Allocation stalls                 2603           0
DMA allocs                           0           0
DMA32 allocs                 618719206  1303037965
Normal allocs                891235743   229914091
Movable allocs                       0           0
Direct pages scanned            216787        3173
Kswapd pages scanned          50719775    41732250
Kswapd pages reclaimed        41541765    41731168
Direct pages reclaimed          209159        3173
Kswapd efficiency                  81%         99%
Kswapd velocity              16859.554   14231.043
Direct efficiency                  96%        100%
Direct velocity                 72.061       1.082
Percentage direct scans             0%          0%
Zone normal velocity          8431.777   14232.125
Zone dma32 velocity           8499.838       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim     6215049.000       0.000
Page writes file               6215049           0
Page writes anon                     0           0
Page reclaim immediate           70673         143
Sector Reads                  81940800    81489388
Sector Writes                100158984    99161860
Page rescued immediate               0           0
Slabs scanned                  1366954       21196

While this is not guaranteed in all cases, this particular test showed
a large reduction in direct reclaim activity. It's also worth noting
that no page writes were issued from reclaim context.

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

 Documentation/cgroup-v1/memcg_test.txt        |   4 +-
 Documentation/cgroup-v1/memory.txt            |   4 +-
 arch/s390/appldata/appldata_mem.c             |   2 +-
 arch/tile/mm/pgtable.c                        |  18 +-
 drivers/base/node.c                           |  77 ++-
 drivers/staging/android/lowmemorykiller.c     |  12 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c |   6 +-
 fs/fs-writeback.c                             |   4 +-
 fs/fuse/file.c                                |   8 +-
 fs/nfs/internal.h                             |   2 +-
 fs/nfs/write.c                                |   2 +-
 fs/proc/meminfo.c                             |  20 +-
 include/linux/backing-dev.h                   |   2 +-
 include/linux/memcontrol.h                    |  61 +-
 include/linux/mm.h                            |   5 +
 include/linux/mm_inline.h                     |  35 +-
 include/linux/mm_types.h                      |   2 +-
 include/linux/mmzone.h                        | 155 +++--
 include/linux/swap.h                          |  24 +-
 include/linux/topology.h                      |   2 +-
 include/linux/vm_event_item.h                 |  14 +-
 include/linux/vmstat.h                        | 111 +++-
 include/linux/writeback.h                     |   2 +-
 include/trace/events/vmscan.h                 |  63 +-
 include/trace/events/writeback.h              |  10 +-
 kernel/power/snapshot.c                       |  10 +-
 kernel/sysctl.c                               |   4 +-
 mm/backing-dev.c                              |  15 +-
 mm/compaction.c                               |  50 +-
 mm/filemap.c                                  |  16 +-
 mm/huge_memory.c                              |  12 +-
 mm/internal.h                                 |  11 +-
 mm/khugepaged.c                               |  14 +-
 mm/memcontrol.c                               | 215 +++----
 mm/memory-failure.c                           |   4 +-
 mm/memory_hotplug.c                           |   7 +-
 mm/mempolicy.c                                |   2 +-
 mm/migrate.c                                  |  35 +-
 mm/mlock.c                                    |  12 +-
 mm/page-writeback.c                           | 123 ++--
 mm/page_alloc.c                               | 371 +++++------
 mm/page_idle.c                                |   4 +-
 mm/rmap.c                                     |  26 +-
 mm/shmem.c                                    |  14 +-
 mm/swap.c                                     |  64 +-
 mm/swap_state.c                               |   4 +-
 mm/util.c                                     |   4 +-
 mm/vmscan.c                                   | 879 +++++++++++++-------------
 mm/vmstat.c                                   | 398 +++++++++---
 mm/workingset.c                               |  54 +-
 50 files changed, 1674 insertions(+), 1319 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
