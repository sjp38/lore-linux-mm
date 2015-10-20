Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 297566B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 08:19:34 -0400 (EDT)
Received: by lbbes7 with SMTP id es7so13708789lbb.2
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 05:19:33 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id s7si2041998lfe.134.2015.10.20.05.19.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 05:19:32 -0700 (PDT)
Date: Tue, 20 Oct 2015 15:19:20 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: vmscan: count slab shrinking results after each
 shrink_slab()
Message-ID: <20151020121920.GE18351@esperanza>
References: <1445278415-21138-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445278415-21138-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 19, 2015 at 02:13:35PM -0400, Johannes Weiner wrote:
> cb731d6 ("vmscan: per memory cgroup slab shrinkers") sought to
> optimize accumulating slab reclaim results in sc->nr_reclaimed only
> once per zone, but the memcg hierarchy walk itself uses
> sc->nr_reclaimed as an exit condition. This can lead to overreclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 27d580b..a02654e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2441,11 +2441,18 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
>  			zone_lru_pages += lru_pages;
>  
> -			if (memcg && is_classzone)
> +			if (memcg && is_classzone) {
>  				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> +				if (reclaim_state) {

current->reclaim_state is only set on global reclaim, so when performing
memcg reclaim we'll never get here. Hence, since we check nr_reclaimed
in the loop only on memcg reclaim, this patch doesn't change anything.

Setting current->reclaim_state on memcg reclaim doesn't seem to be an
option, because it accounts objects freed by any cgroup (e.g. via RCU
callback) - see https://lkml.org/lkml/2015/1/20/91

About overreclaim that might happen due to the current behavior. Inodes
and dentries are small and usually freed by RCU so not accounting them
to nr_reclaimed shouldn't make much difference. The only reason I see
why overreclaim can happen is ignoring eviction of an inode full of page
cache, speaking of which makes me wonder if it'd be better to refrain
from dropping inodes which have page cache left, at least unless the
scan priority is low?

Thanks,
Vladimir

> +					sc->nr_reclaimed +=
> +						reclaim_state->reclaimed_slab;
> +					reclaim_state->reclaimed_slab = 0;
> +				}
> +			}
> +
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2467,14 +2474,16 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		 * Shrink the slab caches in the same proportion that
>  		 * the eligible LRU pages were scanned.
>  		 */
> -		if (global_reclaim(sc) && is_classzone)
> +		if (global_reclaim(sc) && is_classzone) {
>  			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
>  				    sc->nr_scanned - nr_scanned,
>  				    zone_lru_pages);
>  
> -		if (reclaim_state) {
> -			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> -			reclaim_state->reclaimed_slab = 0;
> +			if (reclaim_state) {
> +				sc->nr_reclaimed +=
> +					reclaim_state->reclaimed_slab;
> +				reclaim_state->reclaimed_slab = 0;
> +			}
>  		}
>  
>  		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
