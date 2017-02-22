Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F28156B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 05:43:08 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v77so2616196wmv.5
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 02:43:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l95si1239732wrc.30.2017.02.22.02.43.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 02:43:07 -0800 (PST)
Date: Wed, 22 Feb 2017 11:43:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch added
 to -mm tree
Message-ID: <20170222104303.GH5753@dhcp22.suse.cz>
References: <58a38a94.nb3wSoo24sv+3Kju%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58a38a94.nb3wSoo24sv+3Kju%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vinmenon@codeaurora.org, anton.vorontsov@linaro.org, hannes@cmpxchg.org, mgorman@techsingularity.net, minchan@kernel.org, riel@redhat.com, shashim@codeaurora.org, vbabka@suse.cz, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 14-02-17 14:54:12, akpm@linux-foundation.org wrote:
> From: Vinayak Menon <vinmenon@codeaurora.org>
> Subject: mm: vmscan: do not pass reclaimed slab to vmpressure
> 
> During global reclaim, the nr_reclaimed passed to vmpressure includes the
> pages reclaimed from slab.  But the corresponding scanned slab pages is
> not passed.  There is an impact to the vmpressure values because of this. 
> While moving from kernel version 3.18 to 4.4, a difference is seen in the
> vmpressure values for the same workload resulting in a different behaviour
> of the vmpressure consumer.  One such case is of a vmpressure based
> lowmemorykiller.  It is observed that the vmpressure events are received
> late and less in number resulting in tasks not being killed at the right
> time.  The following numbers show the impact on reclaim activity due to
> the change in behaviour of lowmemorykiller on a 4GB device.  The test
> launches a number of apps in sequence and repeats it multiple times.
> 
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
> 
> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
> invoke slab shrinkers from shrink_zone()").
> 
> So do not consider reclaimed slab pages for vmpressure calculation.  The
> reclaimed pages from slab can be excluded because the freeing of a page by
> slab shrinking depends on each slab's object population, making the cost
> model (i.e.  scan:free) different from that of LRU.  Also, not every
> shrinker accounts the pages it reclaims.  But ideally the pages reclaimed
> from slab should be passed to vmpressure, otherwise higher vmpressure
> levels can be triggered even when there is a reclaim progress.  But
> accounting only the reclaimed slab pages without the scanned, and adding
> something which does not fit into the cost model just adds noise to the
> vmpressure values.

I believe there are still some of my questions which are not answered by
the changelog update. Namely
- vmstat numbers without mentioning vmpressure events for those 2
  kernels have basically no meaning.
- the changelog doesn't mention that the test case basically benefits
  from as many lmk interventions as possible. Does this represent a real
  life workload? If not is there any real life workload which would
  benefit from the new behavior.
- I would be also very careful calling this a regression without having
  any real workload as an example
- Arguments about the cost model is are true but the resulting code is
  not a 100% win either and the changelog should be explicit about the
  consequences - aka more critical events can fire early while there is
  still slab making a reclaim progress.
 
> Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
> Link: http://lkml.kernel.org/r/1486641577-11685-2-git-send-email-vinmenon@codeaurora.org
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
> Cc: Shiraz Hashim <shashim@codeaurora.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmscan.c |   17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff -puN mm/vmscan.c~mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure
> +++ a/mm/vmscan.c
> @@ -2603,16 +2603,23 @@ static bool shrink_node(pg_data_t *pgdat
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
> _
> 
> Patches currently in -mm which might be from vinmenon@codeaurora.org are
> 
> mm-vmpressure-fix-sending-wrong-events-on-underflow.patch
> mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
