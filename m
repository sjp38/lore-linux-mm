Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB506B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 11:42:52 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id n39so7944929wrn.0
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:42:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si24566829wrz.292.2017.02.20.08.42.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 08:42:50 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due
 to mismatched classzone_idx
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f9720ed6-f834-5b64-de0a-ea0e72bf548b@suse.cz>
Date: Mon, 20 Feb 2017 17:42:49 +0100
MIME-Version: 1.0
In-Reply-To: <20170215092247.15989-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 02/15/2017 10:22 AM, Mel Gorman wrote:
> kswapd is woken to reclaim a node based on a failed allocation request
> from any eligible zone. Once reclaiming in balance_pgdat(), it will
> continue reclaiming until there is an eligible zone available for the
> zone it was woken for. kswapd tracks what zone it was recently woken for
> in pgdat->kswapd_classzone_idx. If it has not been woken recently, this
> zone will be 0.
> 
> However, the decision on whether to sleep is made on kswapd_classzone_idx
> which is 0 without a recent wakeup request and that classzone does not
> account for lowmem reserves.  This allows kswapd to sleep when a low
> small zone such as ZONE_DMA is balanced for a GFP_DMA request even if
> a stream of allocations cannot use that zone. While kswapd may be woken
> again shortly in the near future there are two consequences -- the pgdat
> bits that control congestion are cleared prematurely and direct reclaim
> is more likely as kswapd slept prematurely.
> 
> This patch flips kswapd_classzone_idx to default to MAX_NR_ZONES (an invalid
> index) when there has been no recent wakeups. If there are no wakeups,
> it'll decide whether to sleep based on the highest possible zone available
> (MAX_NR_ZONES - 1). It then becomes critical that the "pgdat balanced"
> decisions during reclaim and when deciding to sleep are the same. If there is
> a mismatch, kswapd can stay awake continually trying to balance tiny zones.
> 
> simoop was used to evaluate it again. Two of the preparation patches regressed
> the workload so they are included as the second set of results. Otherwise
> this patch looks artifically excellent
> 
>                                          4.10.0-rc7            4.10.0-rc7            4.10.0-rc7
>                                      mmots-20170209           clear-v1r25       keepawake-v1r25
> Amean    p50-Read             22325202.49 (  0.00%) 19491134.58 ( 12.69%) 22092755.48 (  1.04%)
> Amean    p95-Read             26102988.80 (  0.00%) 24294195.20 (  6.93%) 26101849.04 (  0.00%)
> Amean    p99-Read             30935176.53 (  0.00%) 30397053.16 (  1.74%) 29746220.52 (  3.84%)
> Amean    p50-Write                 976.44 (  0.00%)     1077.22 (-10.32%)      952.73 (  2.43%)
> Amean    p95-Write               15471.29 (  0.00%)    36419.56 (-135.40%)     3140.27 ( 79.70%)
> Amean    p99-Write               35108.62 (  0.00%)   102000.36 (-190.53%)     8843.73 ( 74.81%)
> Amean    p50-Allocation          76382.61 (  0.00%)    87485.22 (-14.54%)    76349.22 (  0.04%)
> Amean    p95-Allocation         127777.39 (  0.00%)   204588.52 (-60.11%)   108630.26 ( 14.98%)
> Amean    p99-Allocation         187937.39 (  0.00%)   631657.74 (-236.10%)   139094.26 ( 25.99%)
> 
> With this patch on top, all the latencies relative to the baseline are
> improved, particularly write latencies. The read latencies are still high
> for the number of threads but it's worth noting that this is mostly due
> to the IO scheduler and not directly related to reclaim. The vmstats are
> a bit of a mix but the relevant ones are as follows;
> 
>                             4.10.0-rc7  4.10.0-rc7  4.10.0-rc7
>                           mmots-20170209 clear-v1r25keepawake-v1r25
> Swap Ins                             0           0           0
> Swap Outs                            0         608           0
> Direct pages scanned           6910672     3132699     6357298
> Kswapd pages scanned          57036946    82488665    56986286
> Kswapd pages reclaimed        55993488    63474329    55939113
> Direct pages reclaimed         6905990     2964843     6352115

These stats are confusing me. The earlier description suggests that this patch
should cause less direct reclaim and more kswapd reclaim, but compared to
"clear-v1r25" it does the opposite? Was clear-v1r25 overreclaiming then? (when
considering direct + kswapd combined)

> Kswapd efficiency                  98%         76%         98%
> Kswapd velocity              12494.375   17597.507   12488.065
> Direct efficiency                  99%         94%         99%
> Direct velocity               1513.835     668.306    1393.148
> Page writes by reclaim           0.000 4410243.000       0.000
> Page writes file                     0     4409635           0
> Page writes anon                     0         608           0
> Page reclaim immediate         1036792    14175203     1042571
> 
> Swap-outs are equivalent to baseline
> Direct reclaim is reduced but not eliminated. It's worth noting
> 	that there are two periods of direct reclaim for this workload. The
> 	first is when it switches from preparing the files for the actual
> 	test itself. It's a lot of file IO followed by a lot of allocs
> 	that reclaims heavily for a brief window. After that, direct
> 	reclaim is intermittent when the workload spawns a number of
> 	threads periodically to do work. kswapd simply cannot wake and
> 	reclaim fast enough between the low and min watermarks. It could
> 	be mitigated using vm.watermark_scale_factor but not through
> 	special tricks in kswapd.
> Page writes from reclaim context are at 0 which is the ideal
> Pages immediately reclaimed after IO completes is back at the baseline
> 
> On UMA, there is almost no change so this is not expected to be a universal
> win.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

[...]

> @@ -3328,6 +3330,22 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  	return sc.order;
>  }
>  
> +/*
> + * pgdat->kswapd_classzone_idx is the highest zone index that a recent
> + * allocation request woke kswapd for. When kswapd has not woken recently,
> + * the value is MAX_NR_ZONES which is not a valid index. This compares a
> + * given classzone and returns it or the highest classzone index kswapd
> + * was recently woke for.
> + */
> +static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
> +					   enum zone_type classzone_idx)
> +{
> +	if (pgdat->kswapd_classzone_idx == MAX_NR_ZONES)
> +		return classzone_idx;
> +
> +	return max(pgdat->kswapd_classzone_idx, classzone_idx);

A bit paranoid comment: this should probably read pgdat->kswapd_classzone_idx to
a local variable with READ_ONCE(), otherwise something can set it to
MAX_NR_ZONES between the check and max(), and compiler can decide to reread.
Probably not an issue with current callers, but I'd rather future-proof it.

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
