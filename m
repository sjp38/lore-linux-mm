Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E10DB6B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 01:35:28 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so16646086pab.2
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 22:35:28 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-250.mail.alibaba.com. [205.204.113.250])
        by mx.google.com with ESMTP id ui5si12113172pab.130.2015.01.08.22.35.24
        for <linux-mm@kvack.org>;
        Thu, 08 Jan 2015 22:35:27 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH -mm v3 3/9] vmscan: per memory cgroup slab shrinkers
Date: Fri, 09 Jan 2015 14:33:46 +0800
Message-ID: <063c01d02bd6$38c64ce0$aa52e6a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vladimir Davydov' <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.cz>, 'Greg Thelen' <gthelen@google.com>, 'Glauber Costa' <glommer@gmail.com>, 'Dave Chinner' <david@fromorbit.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>  static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			bool is_classzone)
>  {
> +	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long nr_reclaimed, nr_scanned;
>  	bool reclaimable = false;
> 
> @@ -2318,16 +2357,22 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> 
>  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
>  		do {
> -			unsigned long lru_pages;
> +			unsigned long lru_pages, scanned;
>  			struct lruvec *lruvec;
>  			int swappiness;
> 
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  			swappiness = mem_cgroup_swappiness(memcg);
> +			scanned = sc->nr_scanned;
> 
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
>  			zone_lru_pages += lru_pages;
> 
> +			if (memcg && is_classzone)
> +				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
> +					    memcg, sc->nr_scanned - scanned,
> +					    lru_pages);
> +
Looks sc->nr_reclaimed has to be updated for "limit reclaim".

Hillf
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2350,19 +2395,14 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		 * Shrink the slab caches in the same proportion that
>  		 * the eligible LRU pages were scanned.
>  		 */
> -		if (global_reclaim(sc) && is_classzone) {
> -			struct reclaim_state *reclaim_state;
> -
> -			shrink_node_slabs(sc->gfp_mask, zone_to_nid(zone),
> -					  sc->nr_scanned - nr_scanned,
> -					  zone_lru_pages);
> -
> -			reclaim_state = current->reclaim_state;
> -			if (reclaim_state) {
> -				sc->nr_reclaimed +=
> -					reclaim_state->reclaimed_slab;
> -				reclaim_state->reclaimed_slab = 0;
> -			}
> +		if (global_reclaim(sc) && is_classzone)
> +			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
> +				    sc->nr_scanned - nr_scanned,
> +				    zone_lru_pages);
> +
> +		if (reclaim_state) {
> +			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> +			reclaim_state->reclaimed_slab = 0;
>  		}
> 
>  		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> --
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
