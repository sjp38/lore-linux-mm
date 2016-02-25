Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF6CE6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:45:35 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so44471508wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:45:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m3si5858557wmb.52.2016.02.25.11.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 11:45:34 -0800 (PST)
Date: Thu, 25 Feb 2016 14:45:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225194524.GA3370@cmpxchg.org>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 05:12:19PM +0000, Mel Gorman wrote:
> This patch only makes sense on mmotm because it's heavily relying on an
> existing swapping-related fix and indirectly relying on the kcompactd
> patches. Even though the kernel says "4.4.0", the swapping and kcompactd
> patches have been cherry-picked from mmotm for the purposes of testing.
> 
> THP defrag is enabled by default to direct reclaim/compact but not wake
> kswapd in the event of a THP allocation failure. The problem is that THP
> allocation requests potentially enter reclaim/compaction. This potentially
> incurs a severe stall that is not guaranteed to be offset by reduced TLB
> misses. While there has been considerable effort to reduce the impact
> of reclaim/compaction, it is still a high cost and workloads that should
> fit in memory fail to do so. Specifically, a simple anon/file streaming
> workload will enter direct reclaim on NUMA at least even though the working
> set size is 80% of RAM. It's been years and it's time to throw in the towel.
> 
> First, this patch redefines what THP defrag means;
> 
> o GFP_TRANSHUGE by default will neither reclaim/compact nor wake kswapd
> o For faults, defrag will not direct/reclaim but will wake kswapd
> o For khugepaged, defrag will enter direct/reclaim but not wake kswapd
> 
> This means that a THP fault will no longer stall but may incur
> reclaim/compaction via kswapd reclaiming and kcompactd compacting. This
> is potentially destructive so the patch disables THP defrag by default.
> THP defrag for khugepaged remains enabled and will enter direct/reclaim
> but no wakeup kswapd or kcompactd.
> 
> After this patch a THP allocation failure will quickly fallback and rely
> on khugepaged to recover the situation at some time in the future. In
> some cases, this will reduce THP usage but the benefit of THP is hard to
> measure and not a universal win where as a stall to reclaim/compaction is
> definitely measurable and can be painful.
> 
> The first test for this is using "usemem" to read a large file and write
> a large anonymous mapping (to avoid the zero page) multiple times. The
> total size of the mappings is 80% of RAM and the benchmark simply measures
> how long it takes to complete. It uses multiple threads to see if that
> is a factor. On UMA, the performance is almost identical so is not reported
> but on NUMA, we see this
> 
> usemem
>                                    4.4.0                 4.4.0
>                           kcompactd-v1r1         nodefrag-v1r3
> Amean    System-1       102.86 (  0.00%)       46.81 ( 54.50%)
> Amean    System-4        37.85 (  0.00%)       34.02 ( 10.12%)
> Amean    System-7        48.12 (  0.00%)       46.89 (  2.56%)
> Amean    System-12       51.98 (  0.00%)       56.96 ( -9.57%)
> Amean    System-21       80.16 (  0.00%)       79.05 (  1.39%)
> Amean    System-30      110.71 (  0.00%)      107.17 (  3.20%)
> Amean    System-48      127.98 (  0.00%)      124.83 (  2.46%)
> Amean    Elapsd-1       185.84 (  0.00%)      105.51 ( 43.23%)
> Amean    Elapsd-4        26.19 (  0.00%)       25.58 (  2.33%)
> Amean    Elapsd-7        21.65 (  0.00%)       21.62 (  0.16%)
> Amean    Elapsd-12       18.58 (  0.00%)       17.94 (  3.43%)
> Amean    Elapsd-21       17.53 (  0.00%)       16.60 (  5.33%)
> Amean    Elapsd-30       17.45 (  0.00%)       17.13 (  1.84%)
> Amean    Elapsd-48       15.40 (  0.00%)       15.27 (  0.82%)
> 
> For a single thread, the benchmark completes 43.23% faster with
> this patch applied with smaller benefits as the thread increases.
> Similar, notice the large reduction in most cases in system CPU
> usage. The overall CPU time is
> 
>                4.4.0       4.4.0
>         kcompactd-v1r1 nodefrag-v1r3
> User        10357.65    10438.33
> System       3988.88     3543.94
> Elapsed      2203.01     1634.41
> 
> Which is substantial. Now, the reclaim figures
> 
>                                  4.4.0       4.4.0
>                           kcompactd-v1r1nodefrag-v1r3
> Minor Faults                 128458477   278352931
> Major Faults                   2174976         225
> Swap Ins                      16904701           0
> Swap Outs                     17359627           0
> Allocation stalls                43611           0
> DMA allocs                           0           0
> DMA32 allocs                  19832646    19448017
> Normal allocs                614488453   580941839
> Movable allocs                       0           0
> Direct pages scanned          24163800           0
> Kswapd pages scanned                 0           0
> Kswapd pages reclaimed               0           0
> Direct pages reclaimed        20691346           0
> Compaction stalls                42263           0
> Compaction success                 938           0
> Compaction failures              41325           0
> 
> This patch eliminates almost all swapping and direct reclaim activity. There
> is still overhead but it's from NUMA balancing which does not identify that
> it's pointless trying to do anything with this workload.
> 
> I also tried the thpscale benchmark which forces a corner case where compaction
> can be used heavily and measures the latency of whether base or huge pages were
> used
> 
> thpscale Fault Latencies
>                                        4.4.0                 4.4.0
>                               kcompactd-v1r1         nodefrag-v1r3
> Amean    fault-base-1      5288.84 (  0.00%)     2817.12 ( 46.73%)
> Amean    fault-base-3      6365.53 (  0.00%)     3499.11 ( 45.03%)
> Amean    fault-base-5      6526.19 (  0.00%)     4363.06 ( 33.15%)
> Amean    fault-base-7      7142.25 (  0.00%)     4858.08 ( 31.98%)
> Amean    fault-base-12    13827.64 (  0.00%)    10292.11 ( 25.57%)
> Amean    fault-base-18    18235.07 (  0.00%)    13788.84 ( 24.38%)
> Amean    fault-base-24    21597.80 (  0.00%)    24388.03 (-12.92%)
> Amean    fault-base-30    26754.15 (  0.00%)    19700.55 ( 26.36%)
> Amean    fault-base-32    26784.94 (  0.00%)    19513.57 ( 27.15%)
> Amean    fault-huge-1      4223.96 (  0.00%)     2178.57 ( 48.42%)
> Amean    fault-huge-3      2194.77 (  0.00%)     2149.74 (  2.05%)
> Amean    fault-huge-5      2569.60 (  0.00%)     2346.95 (  8.66%)
> Amean    fault-huge-7      3612.69 (  0.00%)     2997.70 ( 17.02%)
> Amean    fault-huge-12     3301.75 (  0.00%)     6727.02 (-103.74%)
> Amean    fault-huge-18     6696.47 (  0.00%)     6685.72 (  0.16%)
> Amean    fault-huge-24     8000.72 (  0.00%)     9311.43 (-16.38%)
> Amean    fault-huge-30    13305.55 (  0.00%)     9750.45 ( 26.72%)
> Amean    fault-huge-32     9981.71 (  0.00%)    10316.06 ( -3.35%)
> 
> The average time to fault pages is substantially reduced in the
> majority of caseds but with the obvious caveat that fewer THPs
> are actually used in this adverse workload
> 
>                                    4.4.0                 4.4.0
>                           kcompactd-v1r1         nodefrag-v1r3
> Percentage huge-1         0.71 (  0.00%)       14.04 (1865.22%)
> Percentage huge-3        10.77 (  0.00%)       33.05 (206.85%)
> Percentage huge-5        60.39 (  0.00%)       38.51 (-36.23%)
> Percentage huge-7        45.97 (  0.00%)       34.57 (-24.79%)
> Percentage huge-12       68.12 (  0.00%)       40.07 (-41.17%)
> Percentage huge-18       64.93 (  0.00%)       47.82 (-26.35%)
> Percentage huge-24       62.69 (  0.00%)       44.23 (-29.44%)
> Percentage huge-30       43.49 (  0.00%)       55.38 ( 27.34%)
> Percentage huge-32       50.72 (  0.00%)       51.90 (  2.35%)
> 
>                                  4.4.0       4.4.0
>                           kcompactd-v1r1nodefrag-v1r3
> Minor Faults                  37429143    47564000
> Major Faults                      1916        1558
> Swap Ins                          1466        1079
> Swap Outs                      2936863      149626
> Allocation stalls                62510           3
> DMA allocs                           0           0
> DMA32 allocs                   6566458     6401314
> Normal allocs                216361697   216538171
> Movable allocs                       0           0
> Direct pages scanned          25977580       17998
> Kswapd pages scanned                 0     3638931
> Kswapd pages reclaimed               0      207236
> Direct pages reclaimed         8833714          88
> Compaction stalls               103349           5
> Compaction success                 270           4
> Compaction failures             103079           1
> 
> Note again that while this does swap as it's an aggressive workload,
> the direct relcim activity and allocation stalls is substantially
> reduced. There is some kswapd activity but ftrace showed that the
> kswapd activity was due to normal wakeups from 4K pages being
> allocated. Compaction-related stalls and activity are almost
> eliminated.
> 
> I also tried the stutter benchmark. For this, I do not have figures for
> NUMA but it's something that does impact UMA so I'll report what is available
> 
> stutter
>                                  4.4.0                 4.4.0
>                         kcompactd-v1r1         nodefrag-v1r3
> Min         mmap      7.3571 (  0.00%)      7.3438 (  0.18%)
> 1st-qrtle   mmap      7.5278 (  0.00%)     17.9200 (-138.05%)
> 2nd-qrtle   mmap      7.6818 (  0.00%)     21.6055 (-181.25%)
> 3rd-qrtle   mmap     11.0889 (  0.00%)     21.8881 (-97.39%)
> Max-90%     mmap     27.8978 (  0.00%)     22.1632 ( 20.56%)
> Max-93%     mmap     28.3202 (  0.00%)     22.3044 ( 21.24%)
> Max-95%     mmap     28.5600 (  0.00%)     22.4580 ( 21.37%)
> Max-99%     mmap     29.6032 (  0.00%)     25.5216 ( 13.79%)
> Max         mmap   4109.7289 (  0.00%)   4813.9832 (-17.14%)
> Mean        mmap     12.4474 (  0.00%)     19.3027 (-55.07%)
> 
> This benchmark is trying to fault an anonymous mapping while there is
> a heavy IO load -- a scenario that desktop users used to complain about
> frequently. This shows a mix because the ideal case of mapping with THP
> is not hit as often. However, note that 99% of the mappings complete
> 13.79% faster. The CPU usage here is particularly interesting
> 
>                4.4.0       4.4.0
>         kcompactd-v1r1nodefrag-v1r3
> User           67.50        0.99
> System       1327.88       91.30
> Elapsed      2079.00     2128.98
> 
> And once again we look at the reclaim figures
> 
>                                  4.4.0       4.4.0
>                           kcompactd-v1r1nodefrag-v1r3
> Minor Faults                 335241922  1314582827
> Major Faults                       715         819
> Swap Ins                             0           0
> Swap Outs                            0           0
> Allocation stalls               532723           0
> DMA allocs                           0           0
> DMA32 allocs                1822364341  1177950222
> Normal allocs               1815640808  1517844854
> Movable allocs                       0           0
> Direct pages scanned          21892772           0
> Kswapd pages scanned          20015890    41879484
> Kswapd pages reclaimed        19961986    41822072
> Direct pages reclaimed        21892741           0
> Compaction stalls              1065755           0
> Compaction success                 514           0
> Compaction failures            1065241           0
> 
> Allocation stalls and all direct reclaim activity is eliminated as well
> as compaction-related stalls.
> 
> THP gives impressive gains in some cases but only if they are quickly
> available.  We're not going to reach the point where they are completely
> free so lets take the costs out of the fast paths finally and defer the
> cost to kswapd, kcompactd and khugepaged where it belongs.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

The cornercases Rik pointed out aside, if the mapping isn't long-lived
enough that it can wait for khugepaged, what are the odds that the
defrag work will be offset by the TLB savings? However, for mappings
where it would pay off, having to do the same defrag work but doing it
at a later time is actually a net loss. Should we consider keeping
direct reclaim and compaction as a configurable option as least?

Regardless, this looks like much saner defaults than what we have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
