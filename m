Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 98C976B0259
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 07:37:08 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so67505765lbb.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 04:37:07 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c10si18393224lfc.148.2015.11.14.04.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 04:37:06 -0800 (PST)
Date: Sat, 14 Nov 2015 15:36:50 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 02/14] mm: vmscan: simplify memcg vs. global shrinker
 invocation
Message-ID: <20151114123650.GH31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:21PM -0500, Johannes Weiner wrote:
...
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a4507ec..e4f5b3c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -411,6 +411,10 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> +	/* Global shrinker mode */
> +	if (memcg == root_mem_cgroup)
> +		memcg = NULL;
> +
>  	if (memcg && !memcg_kmem_is_active(memcg))
>  		return 0;
>  
> @@ -2410,11 +2414,22 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
>  			zone_lru_pages += lru_pages;
>  
> -			if (memcg && is_classzone)
> +			/*
> +			 * Shrink the slab caches in the same proportion that
> +			 * the eligible LRU pages were scanned.
> +			 */
> +			if (is_classzone) {
>  				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> +				if (reclaim_state) {
> +					sc->nr_reclaimed +=
> +						reclaim_state->reclaimed_slab;
> +					reclaim_state->reclaimed_slab = 0;
> +				}
> +			}
> +
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2432,20 +2447,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			}
>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>  
> -		/*
> -		 * Shrink the slab caches in the same proportion that
> -		 * the eligible LRU pages were scanned.
> -		 */
> -		if (global_reclaim(sc) && is_classzone)
> -			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
> -				    sc->nr_scanned - nr_scanned,
> -				    zone_lru_pages);
> -
> -		if (reclaim_state) {
> -			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> -			reclaim_state->reclaimed_slab = 0;
> -		}
> -

AFAICS this patch deadly breaks memcg-unaware shrinkers vs LRU balance:
currently we scan (*total* LRU scanned / *total* LRU pages) of all such
objects; with this patch we'd use the numbers from the root cgroup
instead. If most processes reside in memory cgroups, the root cgroup
will have only a few LRU pages and hence the pressure exerted upon such
objects will be unfairly severe.

Thanks,
Vladimir

>  		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
>  			   sc->nr_scanned - nr_scanned,
>  			   sc->nr_reclaimed - nr_reclaimed);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
