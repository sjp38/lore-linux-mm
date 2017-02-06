Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 265036B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 07:52:45 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so19075223wmv.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 04:52:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j83si7946981wmj.140.2017.02.06.04.52.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 04:52:43 -0800 (PST)
Date: Mon, 6 Feb 2017 13:52:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v4] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170206125240.GB10298@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 06-02-17 17:54:09, Vinayak Menon wrote:
> During global reclaim, the nr_reclaimed passed to vmpressure includes the
> pages reclaimed from slab.  But the corresponding scanned slab pages is
> not passed.  This can cause total reclaimed pages to be greater than
> scanned, causing an unsigned underflow in vmpressure resulting in a
> critical event being sent to root cgroup.

If you switched the ordering then this wouldn't be a problem, right?

> It was also noticed that, apart
> from the underflow, there is an impact to the vmpressure values because of
> this. While moving from kernel version 3.18 to 4.4, a difference is seen
> in the vmpressure values for the same workload resulting in a different
> behaviour of the vmpressure consumer. One such case is of a vmpressure
> based lowmemorykiller. It is observed that the vmpressure events are
> received late and less in number resulting in tasks not being killed at
> the right time. The following numbers show the impact on reclaim activity
> due to the change in behaviour of lowmemorykiller on a 4GB device. The test
> launches a number of apps in sequence and repeats it multiple times.
>                       v4.4           v3.18
> pgpgin                163016456      145617236
> pgpgout               4366220        4188004
> workingset_refault    29857868       26781854
> workingset_activate   6293946        5634625
> pswpin                1327601        1133912
> pswpout               3593842        3229602
> pgalloc_dma           99520618       94402970
> pgalloc_normal        104046854      98124798
> pgfree                203772640      192600737
> pgmajfault            2126962        1851836
> pgsteal_kswapd_dma    19732899       18039462
> pgsteal_kswapd_normal 19945336       17977706
> pgsteal_direct_dma    206757         131376
> pgsteal_direct_normal 236783         138247
> pageoutrun            116622         108370
> allocstall            7220           4684
> compact_stall         931            856

>From this numbers it seems that the memory pressure was higher in 4.4.
There is ~5% more allocations in 4.4 while we hit the direct reclaim 50%
more times.

But the above doesn't say anything about the number and levels of 
vmpressure events. Without that it is hard to draw any conclusion here.

It would be also more than useful to say how much the slab reclaim
really contributed.

> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
> invoke slab shrinkers from shrink_zone()").

I am not really sure this is a regression, though. Maybe your heuristic
which consumes events is just too fragile?

> So do not consider reclaimed slab pages for vmpressure calculation. The
> reclaimed pages from slab can be excluded because the freeing of a page
> by slab shrinking depends on each slab's object population, making the
> cost model (i.e. scan:free) different from that of LRU.  Also, not every
> shrinker accounts the pages it reclaims.

Yeah, this is really messy and not 100% correct. The reclaim cost model
for slab is completely different to the reclaim but the concern here is
that we can trigger higher vmpressure levels even though there _is_ a
reclaim progress. This should be at least mentioned in the changelog so
that people know that this aspect has been considered.

> Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
> Acked-by: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
> Cc: Shiraz Hashim <shashim@codeaurora.org>
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  mm/vmscan.c | 17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 947ab6f..8969f8e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2594,16 +2594,23 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				    sc->nr_scanned - nr_scanned,
>  				    node_lru_pages);
>  
> +		/*
> +		 * Record the subtree's reclaim efficiency. The reclaimed
> +		 * pages from slab is excluded here because the corresponding
> +		 * scanned pages is not accounted. Moreover, freeing a page
> +		 * by slab shrinking depends on each slab's object population,
> +		 * making the cost model (i.e. scan:free) different from that
> +		 * of LRU.
> +		 */
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
> +			   sc->nr_scanned - nr_scanned,
> +			   sc->nr_reclaimed - nr_reclaimed);
> +
>  		if (reclaim_state) {
>  			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>  			reclaim_state->reclaimed_slab = 0;
>  		}
>  
> -		/* Record the subtree's reclaim efficiency */
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
> -			   sc->nr_scanned - nr_scanned,
> -			   sc->nr_reclaimed - nr_reclaimed);
> -
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  
> -- 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
