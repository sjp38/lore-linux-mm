Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 661D56B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 11:06:48 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so6926004pdi.2
        for <linux-mm@kvack.org>; Fri, 28 Nov 2014 08:06:48 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rw1si16809180pbc.114.2014.11.28.08.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Nov 2014 08:06:46 -0800 (PST)
Date: Fri, 28 Nov 2014 19:06:37 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Message-ID: <20141128160637.GH6948@esperanza>
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Johannes,

The patch generally looks good to me, because it simplifies the code
flow significantly and makes it easier for me to introduce per memcg
slab reclaim (thanks!). However, it has one serious flaw. Please see the
comment inline.

On Tue, Nov 25, 2014 at 01:23:50PM -0500, Johannes Weiner wrote:
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a384339bf718..8c2b45bfe610 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
[...]
> @@ -2376,12 +2407,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	struct zone *zone;
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
> -	unsigned long lru_pages = 0;
> -	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	gfp_t orig_mask;
> -	struct shrink_control shrink = {
> -		.gfp_mask = sc->gfp_mask,
> -	};
>  	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
>  	bool reclaimable = false;
>  
> @@ -2394,10 +2420,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	if (buffer_heads_over_limit)
>  		sc->gfp_mask |= __GFP_HIGHMEM;
>  
> -	nodes_clear(shrink.nodes_to_scan);
> -
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -					gfp_zone(sc->gfp_mask), sc->nodemask) {
> +					requested_highidx, sc->nodemask) {
>  		if (!populated_zone(zone))
>  			continue;
>  		/*
> @@ -2409,9 +2433,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  						 GFP_KERNEL | __GFP_HARDWALL))
>  				continue;
>  
> -			lru_pages += zone_reclaimable_pages(zone);
> -			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
> -
>  			if (sc->priority != DEF_PRIORITY &&
>  			    !zone_reclaimable(zone))
>  				continue;	/* Let kswapd poll it */
> @@ -2450,7 +2471,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			/* need some check for avoid more shrink_zone() */
>  		}
>  
> -		if (shrink_zone(zone, sc))
> +		if (shrink_zone(zone, sc, zone_idx(zone) == requested_highidx))
>  			reclaimable = true;
>  
>  		if (global_reclaim(sc) &&

If the highest zone (zone_idx=requested_highidx) is not populated, we
won't scan slab caches on direct reclaim, which may result in OOM kill
even if there are plenty of freeable dentries available.

It's especially relevant for VMs, which often have less than 4G of RAM,
in which case we will only have ZONE_DMA and ZONE_DMA32 populated and
empty ZONE_NORMAL on x86_64.

What about distributing the pressure proportionally to the number of
present pages on the zone? Something like this:
