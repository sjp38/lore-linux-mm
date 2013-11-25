Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0175D6B00C6
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 11:27:23 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so2135631bkj.10
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 08:27:23 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yh8si9738974bkb.320.2013.11.25.08.27.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 08:27:22 -0800 (PST)
Date: Mon, 25 Nov 2013 11:27:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v11 03/15] vmscan: also shrink slab in memcg pressure
Message-ID: <20131125162714.GA22729@cmpxchg.org>
References: <cover.1385377616.git.vdavydov@parallels.com>
 <f9fd0a25d8caa1416c5f54201259aa8021185746.1385377616.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9fd0a25d8caa1416c5f54201259aa8021185746.1385377616.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

On Mon, Nov 25, 2013 at 04:07:36PM +0400, Vladimir Davydov wrote:
> From: Glauber Costa <glommer@openvz.org>
> 
> Without the surrounding infrastructure, this patch is a bit of a hammer:
> it will basically shrink objects from all memcgs under memcg pressure.
> At least, however, we will keep the scan limited to the shrinkers marked
> as per-memcg.
> 
> Future patches will implement the in-shrinker logic to filter objects
> based on its memcg association.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h |   17 +++++++++++++++
>  include/linux/shrinker.h   |    6 +++++-
>  mm/memcontrol.c            |   16 +++++++++++++-
>  mm/vmscan.c                |   50 +++++++++++++++++++++++++++++++++++++++-----
>  4 files changed, 82 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b3e7a66..d16ba51 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -231,6 +231,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>  bool mem_cgroup_bad_page_check(struct page *page);
>  void mem_cgroup_print_bad_page(struct page *page);
>  #endif
> +
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone);
>  #else /* CONFIG_MEMCG */
>  struct mem_cgroup;
>  
> @@ -427,6 +430,12 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>  				struct page *newpage)
>  {
>  }
> +
> +static inline unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_MEMCG */
>  
>  #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
> @@ -479,6 +488,8 @@ static inline bool memcg_kmem_enabled(void)
>  	return static_key_false(&memcg_kmem_enabled_key);
>  }
>  
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg);
> +
>  /*
>   * In general, we'll do everything in our power to not incur in any overhead
>   * for non-memcg users for the kmem functions. Not even a function call, if we
> @@ -612,6 +623,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>  	return __memcg_kmem_get_cache(cachep, gfp);
>  }
>  #else
> +
> +static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +{
> +	return false;
> +}
> +
>  #define for_each_memcg_cache_index(_idx)	\
>  	for (; NULL; )
>  
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 68c0970..7d462b1 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -22,6 +22,9 @@ struct shrink_control {
>  	nodemask_t nodes_to_scan;
>  	/* current node being shrunk (for NUMA aware shrinkers) */
>  	int nid;
> +
> +	/* reclaim from this memcg only (if not NULL) */
> +	struct mem_cgroup *target_mem_cgroup;
>  };
>  
>  #define SHRINK_STOP (~0UL)
> @@ -63,7 +66,8 @@ struct shrinker {
>  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
>  
>  /* Flags */
> -#define SHRINKER_NUMA_AWARE (1 << 0)
> +#define SHRINKER_NUMA_AWARE	(1 << 0)
> +#define SHRINKER_MEMCG_AWARE	(1 << 1)
>  
>  extern int register_shrinker(struct shrinker *);
>  extern void unregister_shrinker(struct shrinker *);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 144cb4c..8924ff1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -358,7 +358,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
>  	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
>  
> -static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>  {
>  	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
> @@ -958,6 +958,20 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
>  	return ret;
>  }
>  
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)

If the prototype does not fit, please wrap the argument list, not the
return value.  We are not consistent, but most functions are like this
in memcontrol.c and vmscan.c.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eea668d..652dfa3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -140,11 +140,41 @@ static bool global_reclaim(struct scan_control *sc)
>  {
>  	return !sc->target_mem_cgroup;
>  }
> +
> +/*
> + * kmem reclaim should usually not be triggered when we are doing targetted
> + * reclaim. It is only valid when global reclaim is triggered, or when the
> + * underlying memcg has kmem objects.
> + */
> +static bool has_kmem_reclaim(struct scan_control *sc)
> +{
> +	return !sc->target_mem_cgroup ||
> +		memcg_kmem_is_active(sc->target_mem_cgroup);
> +}

Please opencode these checks in the callsite, they are more
descriptive than the name of this function.

> +static unsigned long
> +zone_nr_reclaimable_pages(struct scan_control *sc, struct zone *zone)
> +{
> +	if (global_reclaim(sc))
> +		return zone_reclaimable_pages(zone);
> +	return memcg_zone_reclaimable_pages(sc->target_mem_cgroup, zone);
> +}

So we have zone_reclaimable_pages() and zone_nr_reclaimable_pages()
with completely different signatures and usecases.  Not good.

The intersection between a zone and a memcg is called an lruvec,
please use that.  Look up an lruvec as early as possible, then
implement lruvec_reclaimable_pages() etc. for use during reclaim.

> @@ -352,6 +382,15 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
>  	}
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
> +		/*
> +		 * If we don't have a target mem cgroup, we scan them all.
> +		 * Otherwise we will limit our scan to shrinkers marked as
> +		 * memcg aware
> +		 */
> +		if (shrinkctl->target_mem_cgroup &&
> +		    !(shrinker->flags & SHRINKER_MEMCG_AWARE))
> +			continue;
> +
>  		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
>  			if (!node_online(shrinkctl->nid))
>  				continue;
> @@ -2399,11 +2438,11 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  
>  		/*
>  		 * Don't shrink slabs when reclaiming memory from over limit
> -		 * cgroups but do shrink slab at least once when aborting
> -		 * reclaim for compaction to avoid unevenly scanning file/anon
> -		 * LRU pages over slab pages.
> +		 * cgroups unless we know they have kmem objects. But do shrink
> +		 * slab at least once when aborting reclaim for compaction to
> +		 * avoid unevenly scanning file/anon LRU pages over slab pages.
>  		 */
> -		if (global_reclaim(sc)) {
> +		if (has_kmem_reclaim(sc)) {
>  			unsigned long lru_pages = 0;
>  
>  			nodes_clear(shrink->nodes_to_scan);
> @@ -2412,7 +2451,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  					continue;
>  
> -				lru_pages += zone_reclaimable_pages(zone);
> +				lru_pages += zone_nr_reclaimable_pages(sc, zone);
>  				node_set(zone_to_nid(zone),
>  					 shrink->nodes_to_scan);
>  			}
> @@ -2669,6 +2708,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	};
>  	struct shrink_control shrink = {
>  		.gfp_mask = sc.gfp_mask,
> +		.target_mem_cgroup = memcg,
>  	};
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
