Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2B196B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:35:54 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so184104093pac.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 23:35:54 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id on7si4896249pac.140.2016.06.23.23.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 23:35:52 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 66so8470127pfy.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 23:35:52 -0700 (PDT)
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <3c062233-1ef7-bc85-5079-255f61f57c7d@gmail.com>
Date: Fri, 24 Jun 2016 16:35:45 +1000
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>



On 22/06/16 00:15, Mel Gorman wrote:
> (sorry for resend, the previous attempt didn't go through fully for
> some reason)
> 
> The bulk of the updates are in response to review from Vlastimil Babka
> and received a lot more testing than v6.
> 
> Changelog since v6
> o Correct reclaim_idx when direct reclaiming for memcg
> o Also account LRU pages per zone for compaction/reclaim
> o Add page_pgdat helper with more efficient lookup
> o Init pgdat LRU lock only once
> o Slight optimisation to wake_all_kswapds
> o Always wake kcompactd when kswapd is going to sleep
> o Rebase to mmotm as of June 15th, 2016
> 
> Changelog since v5
> o Rebase and adjust to changes
> 
> Changelog since v4
> o Rebase on top of v3 of page allocator optimisation series
> 
> Changelog since v3
> o Rebase on top of the page allocator optimisation series
> o Remove RFC tag
> 
> This is the latest version of a series that moves LRUs from the zones to
> the node that is based upon 4.6-rc3 plus the page allocator optimisation
> series. Conceptually, this is simple but there are a lot of details. Some
> of the broad motivations for this are;
> 
> 1. The residency of a page partially depends on what zone the page was
>    allocated from.  This is partially combatted by the fair zone allocation
>    policy but that is a partial solution that introduces overhead in the
>    page allocator paths.
> 
> 2. Currently, reclaim on node 0 behaves slightly different to node 1. For
>    example, direct reclaim scans in zonelist order and reclaims even if
>    the zone is over the high watermark regardless of the age of pages
>    in that LRU. Kswapd on the other hand starts reclaim on the highest
>    unbalanced zone. A difference in distribution of file/anon pages due
>    to when they were allocated results can result in a difference in 
>    again. While the fair zone allocation policy mitigates some of the
>    problems here, the page reclaim results on a multi-zone node will
>    always be different to a single-zone node.
>    it was scheduled on as a result.
> 
> 3. kswapd and the page allocator scan zones in the opposite order to
>    avoid interfering with each other but it's sensitive to timing.  This
>    mitigates the page allocator using pages that were allocated very recently
>    in the ideal case but it's sensitive to timing. When kswapd is allocating
>    from lower zones then it's great but during the rebalancing of the highest
>    zone, the page allocator and kswapd interfere with each other. It's worse
>    if the highest zone is small and difficult to balance.
> 
> 4. slab shrinkers are node-based which makes it harder to identify the exact
>    relationship between slab reclaim and LRU reclaim.
> 
> The reason we have zone-based reclaim is that we used to have
> large highmem zones in common configurations and it was necessary
> to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
> less of a concern as machines with lots of memory will (or should) use
> 64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
> rare. Machines that do use highmem should have relatively low highmem:lowmem
> ratios than we worried about in the past.
> 
> Conceptually, moving to node LRUs should be easier to understand. The
> page allocator plays fewer tricks to game reclaim and reclaim behaves
> similarly on all nodes. 
> 
> The series has been tested on a 16 core UMA machine and a 2-socket 48 core
> NUMA machine. The UMA results are presented in most cases as the NUMA machine
> behaved similarly.
> 
> pagealloc
> ---------
> 
> This is a microbenchmark that shows the benefit of removing the fair zone
> allocation policy. It was tested uip to order-4 but only orders 0 and 1 are
> shown as the other orders were comparable.
> 
>                                            4.7.0-rc3                  4.7.0-rc3
>                                       mmotm-20160615              nodelru-v7r17
> Min      total-odr0-1               485.00 (  0.00%)           462.00 (  4.74%)
> Min      total-odr0-2               354.00 (  0.00%)           341.00 (  3.67%)
> Min      total-odr0-4               285.00 (  0.00%)           277.00 (  2.81%)
> Min      total-odr0-8               249.00 (  0.00%)           240.00 (  3.61%)
> Min      total-odr0-16              230.00 (  0.00%)           224.00 (  2.61%)
> Min      total-odr0-32              222.00 (  0.00%)           215.00 (  3.15%)
> Min      total-odr0-64              216.00 (  0.00%)           210.00 (  2.78%)
> Min      total-odr0-128             214.00 (  0.00%)           208.00 (  2.80%)
> Min      total-odr0-256             248.00 (  0.00%)           233.00 (  6.05%)
> Min      total-odr0-512             277.00 (  0.00%)           270.00 (  2.53%)
> Min      total-odr0-1024            294.00 (  0.00%)           284.00 (  3.40%)
> Min      total-odr0-2048            308.00 (  0.00%)           298.00 (  3.25%)
> Min      total-odr0-4096            318.00 (  0.00%)           307.00 (  3.46%)
> Min      total-odr0-8192            322.00 (  0.00%)           308.00 (  4.35%)
> Min      total-odr0-16384           324.00 (  0.00%)           309.00 (  4.63%)
> Min      total-odr1-1               729.00 (  0.00%)           686.00 (  5.90%)
> Min      total-odr1-2               533.00 (  0.00%)           520.00 (  2.44%)
> Min      total-odr1-4               434.00 (  0.00%)           415.00 (  4.38%)
> Min      total-odr1-8               390.00 (  0.00%)           364.00 (  6.67%)
> Min      total-odr1-16              359.00 (  0.00%)           335.00 (  6.69%)
> Min      total-odr1-32              356.00 (  0.00%)           327.00 (  8.15%)
> Min      total-odr1-64              356.00 (  0.00%)           321.00 (  9.83%)
> Min      total-odr1-128             356.00 (  0.00%)           333.00 (  6.46%)
> Min      total-odr1-256             354.00 (  0.00%)           337.00 (  4.80%)
> Min      total-odr1-512             366.00 (  0.00%)           340.00 (  7.10%)
> Min      total-odr1-1024            373.00 (  0.00%)           354.00 (  5.09%)
> Min      total-odr1-2048            375.00 (  0.00%)           354.00 (  5.60%)
> Min      total-odr1-4096            374.00 (  0.00%)           354.00 (  5.35%)
> Min      total-odr1-8192            370.00 (  0.00%)           355.00 (  4.05%)
> 
> This shows a steady improvement throughout. The primary benefit is from
> reduced system CPU usage which is obvious from the overall times;
> 
>            4.7.0-rc3   4.7.0-rc3
>         mmotm-20160615 nodelru-v7
> User          174.06      174.58
> System       2656.78     2485.21
> Elapsed      2885.07     2713.67
> 
> The vmstats also showed that the fair zone allocation policy was definitely
> removed as can be seen here;
> 
>                              4.7.0-rc3   4.7.0-rc3
>                           mmotm-20160615nodelru-v7r17
> DMA32 allocs               28794408561           0
> Normal allocs              48431969998 77226313470
> Movable allocs                       0           0
> 
> tiobench on ext4
> ----------------
> 
> tiobench is a benchmark that artifically benefits if old pages remain resident
> while new pages get reclaimed. The fair zone allocation policy mitigates this
> problem so pages age fairly. While the benchmark has problems, it is important
> that tiobench performance remains constant as it implies that page aging
> problems that the fair zone allocation policy fixes are not re-introduced.
> 
>                                          4.7.0-rc3             4.7.0-rc3
>                                     mmotm-20160615         nodelru-v7r17
> Min      PotentialReadSpeed        90.24 (  0.00%)       90.14 ( -0.11%)
> Min      SeqRead-MB/sec-1          80.63 (  0.00%)       83.09 (  3.05%)
> Min      SeqRead-MB/sec-2          71.91 (  0.00%)       72.44 (  0.74%)
> Min      SeqRead-MB/sec-4          75.20 (  0.00%)       74.32 ( -1.17%)
> Min      SeqRead-MB/sec-8          65.30 (  0.00%)       65.21 ( -0.14%)
> Min      SeqRead-MB/sec-16         62.62 (  0.00%)       62.12 ( -0.80%)
> Min      RandRead-MB/sec-1          0.90 (  0.00%)        0.94 (  4.44%)
> Min      RandRead-MB/sec-2          0.96 (  0.00%)        0.97 (  1.04%)
> Min      RandRead-MB/sec-4          1.43 (  0.00%)        1.41 ( -1.40%)
> Min      RandRead-MB/sec-8          1.67 (  0.00%)        1.72 (  2.99%)
> Min      RandRead-MB/sec-16         1.77 (  0.00%)        1.86 (  5.08%)
> Min      SeqWrite-MB/sec-1         78.12 (  0.00%)       79.78 (  2.12%)
> Min      SeqWrite-MB/sec-2         72.74 (  0.00%)       73.23 (  0.67%)
> Min      SeqWrite-MB/sec-4         79.40 (  0.00%)       78.32 ( -1.36%)
> Min      SeqWrite-MB/sec-8         73.18 (  0.00%)       71.40 ( -2.43%)
> Min      SeqWrite-MB/sec-16        75.82 (  0.00%)       75.24 ( -0.76%)
> Min      RandWrite-MB/sec-1         1.18 (  0.00%)        1.15 ( -2.54%)
> Min      RandWrite-MB/sec-2         1.05 (  0.00%)        0.99 ( -5.71%)
> Min      RandWrite-MB/sec-4         1.00 (  0.00%)        0.96 ( -4.00%)
> Min      RandWrite-MB/sec-8         0.91 (  0.00%)        0.92 (  1.10%)
> Min      RandWrite-MB/sec-16        0.92 (  0.00%)        0.92 (  0.00%)
> 
> This shows that the series has little or not impact on tiobench which is
> desirable. It indicates that the fair zone allocation policy was removed
> in a manner that didn't reintroduce one class of page aging bug. There
> were only minor differences in overall reclaim activity
> 
>                              4.7.0-rc3   4.7.0-rc3
>                           mmotm-20160615nodelru-v7r17
> Minor Faults                    640992      640721
> Major Faults                       728         623
> Swap Ins                             0           0
> Swap Outs                            0           0
> DMA allocs                           0           0
> DMA32 allocs                  46174282    44219717
> Normal allocs                 77949344    79858024
> Movable allocs                       0           0
> Allocation stalls                   38          76
> Direct pages scanned             17463       34865
> Kswapd pages scanned          93331163    93302388
> Kswapd pages reclaimed        93328173    93299677
> Direct pages reclaimed           17463       34865
> Kswapd efficiency                  99%         99%
> Kswapd velocity              13729.855   13755.612
> Direct efficiency                 100%        100%
> Direct velocity                  2.569       5.140
> Percentage direct scans             0%          0%
> Page writes by reclaim               0           0
> Page writes file                     0           0
> Page writes anon                     0           0
> Page reclaim immediate              54          36
> 
> kswapd activity was roughly comparable. There was slight differences
> in direct reclaim activity but negligible in the context of the overall
> workload (velocity of 5 pages per second with the patches applied, 2 pages
> per second in the baseline kernel).
> 
> pgbench read-only large configuration on ext4
> ---------------------------------------------
> 
> pgbench is a database benchmark that can be sensitive to page reclaim
> decisions. This also checks if removing the fair zone allocation policy
> is safe
> 
> pgbench Transactions
>                         4.7.0-rc3             4.7.0-rc3
>                    mmotm-20160615         nodelru-v7r17
> Hmean    1       191.00 (  0.00%)      193.67 (  1.40%)
> Hmean    5       338.59 (  0.00%)      336.99 ( -0.47%)
> Hmean    12      374.03 (  0.00%)      386.15 (  3.24%)
> Hmean    21      372.24 (  0.00%)      372.02 ( -0.06%)
> Hmean    30      383.98 (  0.00%)      370.69 ( -3.46%)
> Hmean    32      431.01 (  0.00%)      438.47 (  1.73%)
> 
> Negligible differences again. As with tiobench, overall reclaim activity
> was comparable.
> 
> bonnie++ on ext4
> ----------------
> 
> No interesting performance difference, negligible differences on reclaim
> stats.
> 
> paralleldd on ext4
> ------------------
> 
> This workload uses varying numbers of dd instances to read large amounts of
> data from disk.
> 
> paralleldd
>                                4.7.0-rc3             4.7.0-rc3
>                           mmotm-20160615         nodelru-v7r17
> Amean    Elapsd-1       181.57 (  0.00%)      179.63 (  1.07%)
> Amean    Elapsd-3       188.29 (  0.00%)      183.68 (  2.45%)
> Amean    Elapsd-5       188.02 (  0.00%)      181.73 (  3.35%)
> Amean    Elapsd-7       186.07 (  0.00%)      184.11 (  1.05%)
> Amean    Elapsd-12      188.16 (  0.00%)      183.51 (  2.47%)
> Amean    Elapsd-16      189.03 (  0.00%)      181.27 (  4.10%)
> 
>            4.7.0-rc3   4.7.0-rc3
>         mmotm-20160615nodelru-v7r17
> User         1439.23     1433.37
> System       8332.31     8216.01
> Elapsed      3619.80     3532.69
> 
> There is a slight gain in performance, some of which is from the reduced system
> CPU usage. There areminor differences in reclaim activity but nothing significant
> 
>                              4.7.0-rc3   4.7.0-rc3
>                           mmotm-20160615nodelru-v7r17
> Minor Faults                    362486      358215
> Major Faults                      1143        1113
> Swap Ins                            26           0
> Swap Outs                         2920         482
> DMA allocs                           0           0
> DMA32 allocs                  31568814    28598887
> Normal allocs                 46539922    49514444
> Movable allocs                       0           0
> Allocation stalls                    0           0
> Direct pages scanned                 0           0
> Kswapd pages scanned          40886878    40849710
> Kswapd pages reclaimed        40869923    40835207
> Direct pages reclaimed               0           0
> Kswapd efficiency                  99%         99%
> Kswapd velocity              11295.342   11563.344
> Direct efficiency                 100%        100%
> Direct velocity                  0.000       0.000
> Slabs scanned                   131673      126099
> Direct inode steals                 57          60
> Kswapd inode steals                762          18
> 
> It basically shows that kswapd was active at roughly the same rate in
> both kernels. There was also comparable slab scanning activity and direct
> reclaim was avoided in both cases. There appears to be a large difference
> in numbers of inodes reclaimed but the workload has few active inodes and
> is likely a timing artifact. It's interesting to note that the node-lru
> did not swap in any pages but given the low swap activity, it's unlikely
> to be significant.
> 
> stutter
> -------
> 
> stutter simulates a simple workload. One part uses a lot of anonymous
> memory, a second measures mmap latency and a third copies a large file.
> The primary metric is checking for mmap latency.
> 
> stutter
>                              4.7.0-rc3             4.7.0-rc3
>                         mmotm-20160615         nodelru-v7r17
> Min         mmap     16.8422 (  0.00%)     15.9821 (  5.11%)
> 1st-qrtle   mmap     57.8709 (  0.00%)     58.0794 ( -0.36%)
> 2nd-qrtle   mmap     58.4335 (  0.00%)     59.4286 ( -1.70%)
> 3rd-qrtle   mmap     58.6957 (  0.00%)     59.6862 ( -1.69%)
> Max-90%     mmap     58.9388 (  0.00%)     59.8759 ( -1.59%)
> Max-93%     mmap     59.0505 (  0.00%)     59.9333 ( -1.50%)
> Max-95%     mmap     59.1877 (  0.00%)     59.9844 ( -1.35%)
> Max-99%     mmap     60.3237 (  0.00%)     60.2337 (  0.15%)
> Max         mmap    285.6454 (  0.00%)    135.6006 ( 52.53%)
> Mean        mmap     57.8366 (  0.00%)     58.4884 ( -1.13%)
> 
> This shows that there is a slight impact on mmap latency but that
> the worst-case outlier is much improved. As the problem with this
> benchmark used to be that the kernel stalled for minutes, this
> difference is negligible.
> 
> Some of the vmstats are interesting
> 
>                              4.7.0-rc3   4.7.0-rc3
>                           mmotm-20160615nodelru-v7r17
> Swap Ins                            58          42
> Swap Outs                            0           0
> Allocation stalls                   16           0
> Direct pages scanned              1374           0
> Kswapd pages scanned          42454910    41782544
> Kswapd pages reclaimed        41571035    41781833
> Direct pages reclaimed            1167           0
> Kswapd efficiency                  97%         99%
> Kswapd velocity              14774.479   14223.796
> Direct efficiency                  84%        100%
> Direct velocity                  0.478       0.000
> Percentage direct scans             0%          0%
> Page writes by reclaim          696918           0
> Page writes file                696918           0
> Page writes anon                     0           0
> Page reclaim immediate            2940         137
> Sector Reads                  81644424    81699544
> Sector Writes                 99193620    98862160
> Page rescued immediate               0           0
> Slabs scanned                  1279838       22640
> 
> kswapd and direct reclaim activity are similar but the node LRU series
> did not attempt to trigger any page writes from reclaim context.
> 
> This series is not without its hazards. There are at least three areas
> that I'm concerned with even though I could not reproduce any problems in
> that area.
> 
> 1. Reclaim/compaction is going to be affected because the amount of reclaim is
>    no longer targetted at a specific zone. Compaction works on a per-zone basis
>    so there is no guarantee that reclaiming a few THP's worth page pages will
>    have a positive impact on compaction success rates.
> 
> 2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
>    are called is now different. This may or may not be a problem but if it
>    is, it'll be because shrinkers are not called enough and some balancing
>    is required.
> 
> 3. The anon/file reclaim ratio may be affected. Pages about to be dirtied are
>    distributed between zones and the fair zone allocation policy used to do
>    something very similar for anon. The distribution is now different but not
>    necessarily in any way that matters but it's still worth bearing in mind.
> 


Sorry, I am late in reading the thread and the patches, but I am trying to understand
the key benefits? Is it simplification and consistency of the mm subsystem? I know that
zones have grown to be overloaded to mean many things now. What is the contention impact
of moving the LRU from zone to nodes? Your benchmark shows almost no impact with
the micro benchmarks

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
