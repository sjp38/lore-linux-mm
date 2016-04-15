Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB79828E4
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:13:46 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so64051712lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:13:46 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id ch4si15658368wjb.189.2016.04.15.02.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:13:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 160D41C1BF1
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:13:44 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/27] Move LRU page reclaim from zones to nodes v5
Date: Fri, 15 Apr 2016 10:13:06 +0100
Message-Id: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v4
o Rebase on top of v3 of page allocator optimisation series

Changelog since v3
o Rebase on top of the page allocator optimisation series
o Remove RFC tag

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

It was tested on a UMA (16 cores single socket) and a NUMA machine (48
cores, 2 sockets). In most cases, only the UMA results are presented as
the NUMA machine takes an excessive amount of time to complete tests.

There may be an obvious difference in the number of
allocations from each zone as the fair zone allocation policy is removed
towards the end of the series. In cases where the working set exceeds memory,
the differences will be small but on small workloads it'll be very obvious.
For example, these are the allocation stats on a workload that is doing small
amounts of dd.

                             4.6.0-rc1   4.6.0-rc1
                               vanilla  nodelru-v3
DMA allocs                           0           0
DMA32 allocs                   1961196           0
Normal allocs                  3355799     5247180
Movable allocs                       0           0

The key reason why this is not a problem is that kswapd will sleep if any
applicable zone for a classzone is free. If it tried to balance all zones
then there would be excessive reclaim.

bonnie
------

This was configured to do an IO test with a working set 2*RAM using the
ext4 filesystem.  For both machines, there was no significant performance
difference between them but this is the result for the UMA machine

bonnie
                                           4.6.0-rc1                   4.6.0-rc1
                                             vanilla               nodelru-v3r10
Hmean    SeqOut Char            53306.32 (  0.00%)        79027.86 ( 48.25%)
Hmean    SeqOut Block           87796.15 (  0.00%)        87881.69 (  0.10%)
Hmean    SeqOut Rewrite         35996.31 (  0.00%)        36355.59 (  1.00%)
Hmean    SeqIn  Char            38789.17 (  0.00%)        76356.20 ( 96.85%)
Hmean    SeqIn  Block          105315.39 (  0.00%)       105514.07 (  0.19%)
Hmean    Random seeks             329.80 (  0.00%)          334.36 (  1.38%)
Hmean    SeqCreate ops              4.62 (  0.00%)            4.62 (  0.00%)
Hmean    SeqCreate read             4.62 (  0.00%)            4.62 (  0.00%)
Hmean    SeqCreate del            599.29 (  0.00%)         1580.23 (163.68%)
Hmean    RandCreate ops             5.00 (  0.00%)            5.00 (  0.00%)
Hmean    RandCreate read            5.00 (  0.00%)            4.62 ( -7.69%)
Hmean    RandCreate del           629.51 (  0.00%)         1634.55 (159.66%)

           4.6.0-rc1   4.6.0-rc1
             vanillanodelru-v3r10
User         2049.02     1078.82
System        294.25      181.00
Elapsed      6960.58     6021.58

Note that the massive gains shown here are possible an anomaly. It has been noted
that in some cases, bonnie gets an artifical boost due to dumb reclaim luck. There
is no guarantee this result would be reproducible on the same machine let alone
any other machine. That said, the VM stats are interesting;

However, the overall VM stats are interesting


                             4.5.0-rc3   4.5.0-rc3
                          mmotm-20160209   nodelru-v2
Swap Ins                            14           0
Swap Outs                          873           0
DMA allocs                           0           0
DMA32 allocs                  38259888    36320496
Normal allocs                 64762073    66488556
Movable allocs                       0           0
Allocation stalls                 3584           0
Direct pages scanned            736769           0
Kswapd pages scanned          77818637    78836064
Kswapd pages reclaimed        77782378    78812260
Direct pages reclaimed          736548           0
Kswapd efficiency                  99%         99%
Kswapd velocity              11179.907   13092.256
Direct efficiency                  99%        100%
Direct velocity                105.849       0.000

The series does not swap the workload and it never stalls on direct reclaim. There
is a slight increase in kswapd scans but it's offset by the elimination of direct
scans and the overall scanning velocity is not noticably higher. While it's not
reported here, the overall IO stats and CPU usage over time are very similar. kswapd
CPU usage is slightly elevated but (0.5% usage to roughly 1.2% usage over time) but
that is acceptable given the lack of direct reclaim.

tiobench
--------

tiobench is a flawed benchmark but it's very important in this case. tiobench
benefited from a bug prior to the fair zone allocation policy that allowed
old pages to be artificially preserved. The visible impact was that performance
exceeded the physical capabilities of the disk. With this patch applied the results are

tiobench Throughput
tiobench Throughput
                                         4.6.0-rc1             4.6.0-rc1
                                           vanilla            nodelru-v3
Hmean    PotentialReadSpeed        85.84 (  0.00%)       86.20 (  0.42%)
Hmean    SeqRead-MB/sec-1          84.48 (  0.00%)       84.60 (  0.14%)
Hmean    SeqRead-MB/sec-2          75.69 (  0.00%)       75.44 ( -0.34%)
Hmean    SeqRead-MB/sec-4          77.35 (  0.00%)       77.62 (  0.35%)
Hmean    SeqRead-MB/sec-8          68.29 (  0.00%)       68.58 (  0.43%)
Hmean    SeqRead-MB/sec-16         62.82 (  0.00%)       62.72 ( -0.15%)
Hmean    RandRead-MB/sec-1          0.93 (  0.00%)        0.88 ( -4.69%)
Hmean    RandRead-MB/sec-2          1.11 (  0.00%)        1.08 ( -3.20%)
Hmean    RandRead-MB/sec-4          1.52 (  0.00%)        1.48 ( -2.86%)
Hmean    RandRead-MB/sec-8          1.70 (  0.00%)        1.70 ( -0.26%)
Hmean    RandRead-MB/sec-16         1.96 (  0.00%)        1.91 ( -2.49%)
Hmean    SeqWrite-MB/sec-1         83.01 (  0.00%)       83.07 (  0.07%)
Hmean    SeqWrite-MB/sec-2         77.80 (  0.00%)       78.20 (  0.52%)
Hmean    SeqWrite-MB/sec-4         81.68 (  0.00%)       81.72 (  0.05%)
Hmean    SeqWrite-MB/sec-8         78.17 (  0.00%)       78.41 (  0.31%)
Hmean    SeqWrite-MB/sec-16        80.08 (  0.00%)       80.08 (  0.01%)
Hmean    RandWrite-MB/sec-1         1.17 (  0.00%)        1.17 ( -0.03%)
Hmean    RandWrite-MB/sec-2         1.02 (  0.00%)        1.06 (  4.21%)
Hmean    RandWrite-MB/sec-4         1.02 (  0.00%)        1.04 (  2.32%)
Hmean    RandWrite-MB/sec-8         0.95 (  0.00%)        0.97 (  1.75%)
Hmean    RandWrite-MB/sec-16        0.95 (  0.00%)        0.96 (  0.97%)

Note that the performance is almost identical allowing us to conclude that
the correct reclaim behaviour granted by the fair zone allocation policy
is preserved.

stutter
-------

stutter simulates a simple workload. One part uses a lot of anonymous
memory, a second measures mmap latency and a third copies a large file.
The primary metric is checking for mmap latency.

stutter
                             4.6.0-rc1             4.6.0-rc1
                               vanilla            nodelru-v3
Min         mmap     13.4442 (  0.00%)     13.6705 ( -1.68%)
1st-qrtle   mmap     38.0442 (  0.00%)     37.7842 (  0.68%)
2nd-qrtle   mmap     78.5109 (  0.00%)     40.3648 ( 48.59%)
3rd-qrtle   mmap     86.7806 (  0.00%)     46.2499 ( 46.70%)
Max-90%     mmap     89.7028 (  0.00%)     86.5790 (  3.48%)
Max-93%     mmap     90.6776 (  0.00%)     89.5367 (  1.26%)
Max-95%     mmap     91.1678 (  0.00%)     90.3138 (  0.94%)
Max-99%     mmap     92.0036 (  0.00%)     93.2003 ( -1.30%)
Max         mmap    167.0073 (  0.00%)     94.5935 ( 43.36%)
Mean        mmap     68.7672 (  0.00%)     48.9853 ( 28.77%)
Best99%Mean mmap     68.5246 (  0.00%)     48.5354 ( 29.17%)
Best95%Mean mmap     67.5540 (  0.00%)     46.7102 ( 30.86%)
Best90%Mean mmap     66.2798 (  0.00%)     44.3547 ( 33.08%)
Best50%Mean mmap     50.7730 (  0.00%)     37.1298 ( 26.87%)
Best10%Mean mmap     35.8311 (  0.00%)     33.6910 (  5.97%)
Best5%Mean  mmap     34.0159 (  0.00%)     31.4259 (  7.61%)
Best1%Mean  mmap     22.1306 (  0.00%)     24.8851 (-12.45%)

           4.6.0-rc1   4.6.0-rc1
             vanillanodelru-v3r10
User            1.51        0.97
System        138.03      122.58
Elapsed      2420.90     2394.80

The VM stats in this case were not that intresting and are very roughly comparable.

Page allocator intensive workloads showed few differences as the cost
of the fair zone allocation policy does not dominate from a userspace
perspective but a microbench of just the allocator shows a difference

                                           4.6.0-rc1                   4.6.0-rc1
                                             vanilla                 nodelru-v3
Min      total-odr0-1               725.00 (  0.00%)           697.00 (  3.86%)
Min      total-odr0-2               559.00 (  0.00%)           527.00 (  5.72%)
Min      total-odr0-4               459.00 (  0.00%)           436.00 (  5.01%)
Min      total-odr0-8               403.00 (  0.00%)           391.00 (  2.98%)
Min      total-odr0-16              329.00 (  0.00%)           366.00 (-11.25%)
Min      total-odr0-32              365.00 (  0.00%)           355.00 (  2.74%)
Min      total-odr0-64              297.00 (  0.00%)           348.00 (-17.17%)
Min      total-odr0-128             752.00 (  0.00%)           344.00 ( 54.26%)
Min      total-odr0-256             385.00 (  0.00%)           379.00 (  1.56%)
Min      total-odr0-512             899.00 (  0.00%)           414.00 ( 53.95%)
Min      total-odr0-1024            763.00 (  0.00%)           530.00 ( 30.54%)
Min      total-odr0-2048            982.00 (  0.00%)           469.00 ( 52.24%)
Min      total-odr0-4096            928.00 (  0.00%)           526.00 ( 43.32%)
Min      total-odr0-8192           1007.00 (  0.00%)           768.00 ( 23.73%)
Min      total-odr0-16384           375.00 (  0.00%)           366.00 (  2.40%)

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
 include/linux/swap.h                      |  13 +-
 include/linux/topology.h                  |   2 +-
 include/linux/vm_event_item.h             |  14 +-
 include/linux/vmstat.h                    | 111 +++-
 include/linux/writeback.h                 |   2 +-
 include/trace/events/vmscan.h             |  40 +-
 include/trace/events/writeback.h          |  10 +-
 kernel/power/snapshot.c                   |  10 +-
 kernel/sysctl.c                           |   4 +-
 mm/backing-dev.c                          |  14 +-
 mm/compaction.c                           |  24 +-
 mm/filemap.c                              |  14 +-
 mm/huge_memory.c                          |  14 +-
 mm/internal.h                             |  11 +-
 mm/memcontrol.c                           | 235 ++++-----
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   7 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  35 +-
 mm/mlock.c                                |  12 +-
 mm/page-writeback.c                       | 119 ++---
 mm/page_alloc.c                           | 289 +++++-----
 mm/page_idle.c                            |   4 +-
 mm/rmap.c                                 |  15 +-
 mm/shmem.c                                |  12 +-
 mm/swap.c                                 |  66 +--
 mm/swap_state.c                           |   4 +-
 mm/util.c                                 |   4 +-
 mm/vmscan.c                               | 847 ++++++++++++++----------------
 mm/vmstat.c                               | 369 ++++++++++---
 mm/workingset.c                           |  53 +-
 47 files changed, 1476 insertions(+), 1221 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
