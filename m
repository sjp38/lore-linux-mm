Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 982E96B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:18 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so210742666wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:18 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id lp7si10615411wjb.73.2016.02.23.05.45.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 05:45:17 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id AC6E198E41
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:16 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Date: Tue, 23 Feb 2016 13:44:49 +0000
Message-Id: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is a revisit of an RFC series from last year that moves LRUs from
the zones to the node. It is based on mmotm from February 9th as it had
to be rebased on top of work there and will not apply cleanly to 4.5-rc*
Conceptually, this is simple but there are a lot of details. Some of the
broad motivations for this are;

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

It was tested on a UMA (16 cores single socket) and a NUMA machine (48 cores,
2 sockets). However, many of these results are from the UMA machine as the
NUMA machine had a bug that was causing numa balancing to push everything
out to swap. A fix for that issue has already been posted.

In many benchmarks, there is an obvious difference in the number of
allocations from each zone as the fair zone allocation policy is removed
towards the end of the series. For example, this is the allocation stats
when running blogbench that showed no difference in headling performance

                          mmotm-20160209   nodelru-v2
DMA allocs                           0           0
DMA32 allocs                   7218763      608067
Normal allocs                 12701806    18821286
Movable allocs                       0           0

bonnie
------

This was configured to do an IO test with a working set 2*RAM using the
ext4 filesystem.  For both machines, there was no significant performance
difference between them but this is the result for the UMA machine


bonnie
                                           4.5.0-rc3                   4.5.0-rc3
                                      mmotm-20160209                  nodelru-v2
Hmean    SeqOut Char            85457.62 (  0.00%)        85376.69 ( -0.09%)
Hmean    SeqOut Block           87031.13 (  0.00%)        87523.40 (  0.57%)
Hmean    SeqOut Rewrite         36685.66 (  0.00%)        36006.64 ( -1.85%)
Hmean    SeqIn  Char            76766.34 (  0.00%)        75935.63 ( -1.08%)
Hmean    SeqIn  Block          105405.02 (  0.00%)       105513.21 (  0.10%)
Hmean    Random seeks             333.03 (  0.00%)          332.82 ( -0.07%)
Hmean    SeqCreate ops              5.00 (  0.00%)            4.62 ( -7.69%)
Hmean    SeqCreate read             4.62 (  0.00%)            4.62 (  0.00%)
Hmean    SeqCreate del           1622.44 (  0.00%)         1633.46 (  0.68%)
Hmean    RandCreate ops             5.00 (  0.00%)            5.00 (  0.00%)
Hmean    RandCreate read            4.62 (  0.00%)            4.62 (  0.00%)
Hmean    RandCreate del          1664.51 (  0.00%)         1672.79 (  0.50%)

           4.5.0-rc3   4.5.0-rc3
        mmotm-20160209   nodelru-v2
User          892.43      896.96
System        160.86      156.56
Elapsed      5990.52     6005.04

However, the overall VM stats are interesting


                             4.5.0-rc3   4.5.0-rc3
                          mmotm-20160209   nodelru-v2
Swap Ins                             8           0
Swap Outs                          705          52
Allocation stalls                 6480           0
DMA allocs                           0           0
DMA32 allocs                  38287801    35274742
Normal allocs                 64983682    67494335
Movable allocs                       0           0
Direct pages scanned           1334296           0
Kswapd pages scanned          77617741    78643061
Kswapd pages reclaimed        77493866    78481909
Direct pages reclaimed         1334220           0
Kswapd efficiency                  99%         99%
Kswapd velocity              12956.762   13096.176
Direct efficiency                  99%        100%
Direct velocity                222.735       0.000
Percentage direct scans             1%          0%

Note that there were no allocation stalls with this patch applied and no
direct reclaim activity.

tiobench
--------

tiobench is a flawed benchmark but it's very important in this case. tiobench
benefited from a bug prior to the fair zone allocation policy that allowed
old pages to be artificially preserved. The visible impact was that performance
exceeded the physical capabilities of the disk. With this patch applied the results are

tiobench Throughput
                                               4.5.0-rc3                   4.5.0-rc3
                                          mmotm-20160209                  nodelru-v2
Hmean    PotentialReadSpeed        91.27 (  0.00%)       89.89 ( -1.51%)
Hmean    SeqRead-MB/sec-1          84.97 (  0.00%)       84.33 ( -0.75%)
Hmean    SeqRead-MB/sec-2          75.18 (  0.00%)       75.02 ( -0.20%)
Hmean    SeqRead-MB/sec-4          77.05 (  0.00%)       77.07 (  0.03%)
Hmean    SeqRead-MB/sec-8          68.13 (  0.00%)       67.90 ( -0.33%)
Hmean    SeqRead-MB/sec-16         61.64 (  0.00%)       61.99 (  0.57%)
Hmean    RandRead-MB/sec-1          0.92 (  0.00%)        0.86 ( -6.49%)
Hmean    RandRead-MB/sec-2          1.06 (  0.00%)        1.09 (  2.53%)
Hmean    RandRead-MB/sec-4          1.49 (  0.00%)        1.47 ( -1.54%)
Hmean    RandRead-MB/sec-8          1.64 (  0.00%)        1.73 (  5.72%)
Hmean    RandRead-MB/sec-16         2.02 (  0.00%)        1.91 ( -5.45%)
Hmean    SeqWrite-MB/sec-1         83.03 (  0.00%)       82.91 ( -0.15%)
Hmean    SeqWrite-MB/sec-2         77.46 (  0.00%)       77.43 ( -0.03%)
Hmean    SeqWrite-MB/sec-4         80.92 (  0.00%)       80.90 ( -0.02%)
Hmean    SeqWrite-MB/sec-8         77.71 (  0.00%)       77.36 ( -0.45%)
Hmean    SeqWrite-MB/sec-16        79.23 (  0.00%)       79.36 (  0.17%)
Hmean    RandWrite-MB/sec-1         1.19 (  0.00%)        1.16 ( -2.29%)
Hmean    RandWrite-MB/sec-2         1.00 (  0.00%)        1.07 (  7.03%)
Hmean    RandWrite-MB/sec-4         0.96 (  0.00%)        1.05 (  8.67%)
Hmean    RandWrite-MB/sec-8         0.94 (  0.00%)        0.97 (  2.76%)
Hmean    RandWrite-MB/sec-16        0.95 (  0.00%)        0.93 ( -2.42%)

Note that the performance is almost identical allowing us to conclude that
the correct reclaim behaviour granted by the fair zone allocation policy
is preserved.

stutter
-------

stutter simulates a simple workload. One part uses a lot of anonymous
memory, a second measures mmap latency and a third copies a large file.
The primary metric is checking for mmap latency.

stutter
                             4.5.0-rc3             4.5.0-rc3
                        mmotm-20160209            nodelru-v2
Min         mmap     12.5114 (  0.00%)     13.5315 ( -8.15%)
1st-qrtle   mmap     14.4985 (  0.00%)     14.3907 (  0.74%)
2nd-qrtle   mmap     14.7093 (  0.00%)     14.5478 (  1.10%)
3rd-qrtle   mmap     15.7381 (  0.00%)     14.7581 (  6.23%)
Max-90%     mmap     16.4561 (  0.00%)     15.6516 (  4.89%)
Max-93%     mmap     16.9571 (  0.00%)     15.8844 (  6.33%)
Max-95%     mmap     17.2948 (  0.00%)     16.3679 (  5.36%)
Max-99%     mmap     21.1054 (  0.00%)     19.9593 (  5.43%)
Max         mmap   2815.7509 (  0.00%)   2717.4201 (  3.49%)
Mean        mmap     16.6965 (  0.00%)     14.9653 ( 10.37%)

There is a consistent improvement in mmap latency and some of this may be due
to less direct reclaim and more kswapd activity

                             4.5.0-rc3   4.5.0-rc3
                          mmotm-20160209   nodelru-v2
Minor Faults                  89868559    78842249
Major Faults                      1037         899
Swap Ins                           362         583
Swap Outs                            0           0
Allocation stalls                65758       31410
DMA allocs                           0           0
DMA32 allocs                1196649783  2633682376
Normal allocs               2227851590  1110162400
Movable allocs                       0           0
Direct pages scanned          28776006    15074415
Kswapd pages scanned          13051818    30529292
Kswapd pages reclaimed        12936208    26704609
Direct pages reclaimed        28774473    15074044

Best1%Mean  mmap     14.0438 (  0.00%)     13.7945 (  1.77%)

Other pagereclaim workloads were tested but the results are often repetitive

lmbench lat_mmap: no major performance difference, less direct reclaim scanning
parallelio: This measures how much an anonymous memory workload is affected by
	large amounts of background IO. Impact on workload is roughly comparable.
fsmark: This created large numbers of zero-length files to target the shrinkers.
	Shrinker activity was comparable.

Page allocator intensive workloads showed little difference as the cost
of the fair zone allocation policy does not dominate from a userspace perspective
but a microbench of just the allocator shows a difference

                                           4.5.0-rc3                  4.5.0-rc3
                                      mmotm-20160209                 nodelru-v2
Min      total-odr0-1              1075.00 (  0.00%)           606.00 ( 43.63%)
Min      total-odr0-2               786.00 (  0.00%)           456.00 ( 41.98%)
Min      total-odr0-4               383.00 (  0.00%)           377.00 (  1.57%)
Min      total-odr0-8               355.00 (  0.00%)           554.00 (-56.06%)
Min      total-odr0-16              312.00 (  0.00%)           293.00 (  6.09%)
Min      total-odr0-32              309.00 (  0.00%)           284.00 (  8.09%)
Min      total-odr0-64              283.00 (  0.00%)           269.00 (  4.95%)
Min      total-odr0-128             292.00 (  0.00%)           274.00 (  6.16%)
Min      total-odr0-256             305.00 (  0.00%)           292.00 (  4.26%)
Min      total-odr0-512             335.00 (  0.00%)           333.00 (  0.60%)
Min      total-odr0-1024            347.00 (  0.00%)           347.00 (  0.00%)
Min      total-odr0-2048            361.00 (  0.00%)           356.00 (  1.39%)
Min      total-odr0-4096            371.00 (  0.00%)           366.00 (  1.35%)
Min      total-odr0-8192            376.00 (  0.00%)           368.00 (  2.13%)
Min      total-odr0-16384           377.00 (  0.00%)           368.00 (  2.39%)

 Documentation/cgroup-v1/memcg_test.txt    |   4 +-
 Documentation/cgroup-v1/memory.txt        |   4 +-
 arch/s390/appldata/appldata_mem.c         |   2 +-
 arch/tile/mm/pgtable.c                    |  18 +-
 drivers/base/node.c                       |  73 +--
 drivers/staging/android/lowmemorykiller.c |  12 +-
 fs/fs-writeback.c                         |   4 +-
 fs/fuse/file.c                            |   8 +-
 fs/nfs/internal.h                         |   2 +-
 fs/nfs/write.c                            |   2 +-
 fs/proc/meminfo.c                         |  14 +-
 include/linux/backing-dev.h               |   2 +-
 include/linux/memcontrol.h                |  30 +-
 include/linux/mm_inline.h                 |   4 +-
 include/linux/mm_types.h                  |   2 +-
 include/linux/mmzone.h                    | 156 +++---
 include/linux/swap.h                      |  15 +-
 include/linux/topology.h                  |   2 +-
 include/linux/vm_event_item.h             |  11 +-
 include/linux/vmstat.h                    | 106 +++-
 include/linux/writeback.h                 |   2 +-
 include/trace/events/vmscan.h             |  40 +-
 include/trace/events/writeback.h          |  10 +-
 kernel/power/snapshot.c                   |  10 +-
 kernel/sysctl.c                           |   4 +-
 mm/backing-dev.c                          |  15 +-
 mm/compaction.c                           |  28 +-
 mm/filemap.c                              |  14 +-
 mm/huge_memory.c                          |  14 +-
 mm/internal.h                             |  11 +-
 mm/memcontrol.c                           | 235 ++++-----
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   7 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  35 +-
 mm/mlock.c                                |  12 +-
 mm/mmap.c                                 |   4 +-
 mm/nommu.c                                |   4 +-
 mm/page-writeback.c                       | 119 ++---
 mm/page_alloc.c                           | 269 +++++-----
 mm/page_idle.c                            |   4 +-
 mm/rmap.c                                 |  15 +-
 mm/shmem.c                                |  12 +-
 mm/swap.c                                 |  66 +--
 mm/swap_state.c                           |   4 +-
 mm/vmscan.c                               | 828 ++++++++++++++----------------
 mm/vmstat.c                               | 363 ++++++++++---
 mm/workingset.c                           |  51 +-
 48 files changed, 1455 insertions(+), 1198 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
