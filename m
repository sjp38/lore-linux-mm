Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E4D156B0098
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:21:52 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so1819003wib.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:21:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id az9si10410100wib.86.2014.11.06.07.21.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 07:21:52 -0800 (PST)
Date: Thu, 6 Nov 2014 10:21:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm v2 3/9] vmscan: shrink slab on memcg pressure
Message-ID: <20141106152135.GA17628@phnom.home.cmpxchg.org>
References: <cover.1414145862.git.vdavydov@parallels.com>
 <68df6349e5cecdf8b2950e8eb2c27965163a110b.1414145863.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <68df6349e5cecdf8b2950e8eb2c27965163a110b.1414145863.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 24, 2014 at 02:37:34PM +0400, Vladimir Davydov wrote:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a384339bf718..2cf6b04a4e0c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -339,6 +339,26 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
>  	return freed;
>  }
>  
> +static unsigned long
> +run_shrinker(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> +	     unsigned long nr_pages_scanned, unsigned long lru_pages)
> +{
> +	unsigned long freed = 0;
> +
> +	if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
> +		shrinkctl->nid = 0;
> +		return shrink_slab_node(shrinkctl, shrinker,
> +					nr_pages_scanned, lru_pages);
> +	}
> +
> +	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
> +		if (node_online(shrinkctl->nid))
> +			freed += shrink_slab_node(shrinkctl, shrinker,
> +						  nr_pages_scanned, lru_pages);
> +	}
> +	return freed;
> +}

The slab shrinking logic accumulates the lru pages, as well as the
nodes_to_scan mask, when going over the zones, only to go over the
zones here again using the accumulated node information.  Why not just
invoke the thing per-zone instead in the first place?  Kswapd already
does that (although it could probably work with the per-zone lru_pages
and nr_scanned deltas) and direct reclaim should as well.  It would
simplify the existing code as well as your series a lot.

> +		/*
> +		 * For memcg-aware shrinkers iterate over the target memcg
> +		 * hierarchy and run the shrinker on each kmem-active memcg
> +		 * found in the hierarchy.
> +		 */
> +		shrinkctl->memcg = shrinkctl->target_mem_cgroup;
> +		do {
> +			if (!shrinkctl->memcg ||
> +			    memcg_kmem_is_active(shrinkctl->memcg))
> +				freed += run_shrinker(shrinkctl, shrinker,
>  						nr_pages_scanned, lru_pages);
> -
> -		}
> +		} while ((shrinkctl->memcg =
> +			  mem_cgroup_iter(shrinkctl->target_mem_cgroup,
> +					  shrinkctl->memcg, NULL)) != NULL);

More symptoms of the above.  This hierarchy walk is duplicative and
potentially quite expensive.

> @@ -2381,6 +2414,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	gfp_t orig_mask;
>  	struct shrink_control shrink = {
>  		.gfp_mask = sc->gfp_mask,
> +		.target_mem_cgroup = sc->target_mem_cgroup,
>  	};
>  	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
>  	bool reclaimable = false;
> @@ -2400,18 +2434,22 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
>  		if (!populated_zone(zone))
>  			continue;
> +
> +		if (global_reclaim(sc) &&
> +		    !cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> +			continue;
> +
> +		lru_pages += global_reclaim(sc) ?
> +				zone_reclaimable_pages(zone) :
> +				mem_cgroup_zone_reclaimable_pages(zone,
> +						sc->target_mem_cgroup);
> +		node_set(zone_to_nid(zone), shrink.nodes_to_scan);

And yet another costly hierarchy walk.

The reclaim code walks zonelists according to a nodemask, and within
each zone it walks lruvecs according to the memcg hierarchy.  The
shrinkers are wrong in making up an ad-hoc concept of NUMA nodes that
otherwise does not exist anywhere in the VM.  Please integrate them
properly instead of adding more duplication on top.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
