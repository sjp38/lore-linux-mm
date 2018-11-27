Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 226586B481C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:20:33 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so10427673edc.13
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:20:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8-v6si1860600ejj.94.2018.11.27.05.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 05:20:31 -0800 (PST)
Subject: Re: [PATCH 5/5] mm: Stall movable allocations until kswapd progresses
 during serious external fragmentation event
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-6-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e0867205-e5f1-b007-5dc7-bb4655f6e5c1@suse.cz>
Date: Tue, 27 Nov 2018 14:20:30 +0100
MIME-Version: 1.0
In-Reply-To: <20181123114528.28802-6-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 11/23/18 12:45 PM, Mel Gorman wrote:
> An event that potentially causes external fragmentation problems has
> already been described but there are degrees of severity.  A "serious"
> event is defined as one that steals a contiguous range of pages of an order
> lower than fragment_stall_order (PAGE_ALLOC_COSTLY_ORDER by default). If a
> movable allocation request that is allowed to sleep needs to steal a small
> block then it schedules until kswapd makes progress or a timeout passes.
> The watermarks are also boosted slightly faster so that kswapd makes
> greater effort to reclaim enough pages to avoid the fragmentation event.
> 
> This stall is not guaranteed to avoid serious fragmentation events.
> If memory pressure is high enough, the pages freed by kswapd may be
> reallocated or the free pages may not be in pageblocks that contain
> only movable pages. Furthermore an allocation request that cannot stall
> (e.g. atomic allocations) or unmovable/reclaimable allocations will still
> proceed without stalling. The reason is that movable allocations can be
> migrated and stalling for kswapd to make progress means that compaction
> has targets. Unmovable/reclaimable allocations on the other hand do not
> benefit from stalling as their pages cannot move.
> 
> The worst-case scenario for stalling is a combination of both high memory
> pressure where kswapd is having trouble keeping free pages over the
> pfmemalloc_reserve and movable allocations are fragmenting memory. In this
> case, an allocation request may sleep for longer. There are both vmstats
> to identify stalls are happening and a tracepoint to quantify what the
> stall durations are. Note that the granularity of the stall detection is
> a jiffy so the delay accounting is not precise.
> 
> 1-socket Skylake machine
> config-global-dhp__workload_thpfioscale XFS (no special madvise)
> 4 fio threads, 1 THP allocating thread
> --------------------------------------
> 
> 4.20-rc3 extfrag events < order 9:   804694
> 4.20-rc3+patch:                      408912 (49% reduction)
> 4.20-rc3+patch1-4:                    18421 (98% reduction)
> 4.20-rc3+patch1-5:                    16788 (98% reduction)
> 
>                                    4.20.0-rc3             4.20.0-rc3
>                                    boost-v5r8             stall-v5r8
> Amean     fault-base-1      652.71 (   0.00%)      651.40 (   0.20%)
> Amean     fault-huge-1      178.93 (   0.00%)      174.49 *   2.48%*
> 
> thpfioscale Percentage Faults Huge
>                               4.20.0-rc3             4.20.0-rc3
>                               boost-v5r8             stall-v5r8
> Percentage huge-1        5.12 (   0.00%)        5.56 (   8.77%)
> 
> Fragmentation events are further reduced. Note that in previous versions,
> it was reduced to negligible levels but the logic has been corrected
> to avoid exceessive reclaim and slab shrinkage in the meantime to avoid
> IO regressions that may not be tolerable.
> 
> The latencies and allocation success rates are roughly similar.  Over the
> course of 16 minutes, there were 2 stalls due to fragmentation avoidance
> for 8 microseconds.
> 
> 1-socket Skylake machine
> global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
> -----------------------------------------------------------------
> 
> 4.20-rc3 extfrag events < order 9:  291392
> 4.20-rc3+patch:                     191187 (34% reduction)
> 4.20-rc3+patch1-4:                   13464 (95% reduction)
> 4.20-rc3+patch1-5:                   15089 (99.7% reduction)
> 
>                                    4.20.0-rc3             4.20.0-rc3
>                                    boost-v5r8             stall-v5r8
> Amean     fault-base-1     1481.67 (   0.00%)        0.00 * 100.00%*
> Amean     fault-huge-1     1063.88 (   0.00%)      540.81 *  49.17%*
> 
>                               4.20.0-rc3             4.20.0-rc3
>                               boost-v5r8             stall-v5r8
> Percentage huge-1       83.46 (   0.00%)      100.00 (  19.82%)
> 
> The fragmentation events were increased which is bad, but this is offset
> by the fact that THP allocation rates had a lower latency and a perfect
> allocation success rate. There were 102 stalls over the course of 16
> minutes for a total stall time of roughly 0.4 seconds.
> 
> 2-socket Haswell machine
> config-global-dhp__workload_thpfioscale XFS (no special madvise)
> 4 fio threads, 5 THP allocating threads
> ----------------------------------------------------------------
> 
> 4.20-rc3 extfrag events < order 9:  215698
> 4.20-rc3+patch:                     200210 (7% reduction)
> 4.20-rc3+patch1-4:                   14263 (93% reduction)
> 4.20-rc3+patch1-5:                   11702 (95% reduction)
> 
>                                    4.20.0-rc3             4.20.0-rc3
>                                    boost-v5r8             stall-v5r8
> Amean     fault-base-5     1306.87 (   0.00%)     1340.96 (  -2.61%)
> Amean     fault-huge-5     1348.94 (   0.00%)     2089.44 ( -54.89%)
> 
>                               4.20.0-rc3             4.20.0-rc3
>                               boost-v5r8             stall-v5r8
> Percentage huge-5        7.91 (   0.00%)        2.43 ( -69.26%)
> 
> There is a slight reduction in fragmentation events but it's slight
> enough that it may be due to luck. Unfortunately, both the latencies
> and success rates were lower. However, this is highly likely to be due
> to luck given that there were just 12 stalls for 76 microseconds. Direct
> reclaim was also eliminated but that is likely a co-incidence.
> 
> 2-socket Haswell machine
> global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
> -----------------------------------------------------------------
> 
> 4.20-rc3 extfrag events < order 9: 166352
> 4.20-rc3+patch:                    147463 (11% reduction)
> 4.20-rc3+patch1-4:                  11095 (93% reduction)
> 4.20-rc3+patch1-5:                  10677 (94% reduction)
> 
> thpfioscale Fault Latencies
>                                    4.20.0-rc3             4.20.0-rc3
>                                    boost-v5r8             stall-v5r8
> Amean     fault-base-5     7419.67 (   0.00%)     6853.97 (   7.62%)
> Amean     fault-huge-5     3263.80 (   0.00%)     1799.26 *  44.87%*
> 
>                               4.20.0-rc3             4.20.0-rc3
>                               boost-v5r8             stall-v5r8
> Percentage huge-5       87.98 (   0.00%)       98.97 (  12.49%)
> 
> The fragmentation events are slightly reduced with the latencies and
> allocation success rates much improved.  There were 462 stalls over the
> course of 68 minutes with a total stall time of roughly 1.9 seconds.
> 
> This patch has a marginal rate on fragmentation rates as it's rare for
> the stall logic to actually trigger but the small stalls can be enough for
> kswapd to catch up. How much that helps is variable but probably worthwhile
> for long-term allocation success rates. It is possible to eliminate
> fragmentation events entirely with tuning due to this patch although that
> would require careful evaluation to determine if it's worthwhile.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

The gains here are relatively smaller and noisier than for the previous
patches. Also I'm afraid that once antifrag loses against the ultimate
adversary workload (see the "Caching/buffers become useless after some
time" thread), then this might result in adding stalls to a workload
that has no other options but to allocate movable pages from partially
filled unmovable blocks, because that's simply the majority of
pageblocks in the system, and the stalls can't help the situation. If
that proves to be true, we could revert, but then there's the new
user-visible tunable... and that all makes it harder for me to decide
about this patch :) If only we could find out early while this is in
linux-mm/linux-next...
