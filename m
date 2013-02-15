Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 460CC6B0007
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 20:27:25 -0500 (EST)
Received: by mail-ye0-f202.google.com with SMTP id r9so310697yen.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 17:27:24 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 1/7] vmscan: also shrink slab in memcg pressure
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
	<1360328857-28070-2-git-send-email-glommer@parallels.com>
Date: Thu, 14 Feb 2013 17:27:22 -0800
Message-ID: <xr93mwv6nz7p.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Feb 08 2013, Glauber Costa wrote:

> Without the surrounding infrastructure, this patch is a bit of a hammer:
> it will basically shrink objects from all memcgs under memcg pressure.
> At least, however, we will keep the scan limited to the shrinkers marked
> as per-memcg.
>
> Future patches will implement the in-shrinker logic to filter objects
> based on its memcg association.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h | 16 ++++++++++++++++
>  include/linux/shrinker.h   |  4 ++++
>  mm/memcontrol.c            | 11 ++++++++++-
>  mm/vmscan.c                | 41 ++++++++++++++++++++++++++++++++++++++---
>  4 files changed, 68 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 0108a56..b7de557 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -200,6 +200,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>  bool mem_cgroup_bad_page_check(struct page *page);
>  void mem_cgroup_print_bad_page(struct page *page);
>  #endif
> +
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone);
>  #else /* CONFIG_MEMCG */
>  struct mem_cgroup;
>  
> @@ -384,6 +387,11 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>  				struct page *newpage)
>  {
>  }
> +
> +static inline unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
> +{

	return 0;

> +}
>  #endif /* CONFIG_MEMCG */
>  
>  #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
> @@ -436,6 +444,8 @@ static inline bool memcg_kmem_enabled(void)
>  	return static_key_false(&memcg_kmem_enabled_key);
>  }
>  
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg);
> +
>  /*
>   * In general, we'll do everything in our power to not incur in any overhead
>   * for non-memcg users for the kmem functions. Not even a function call, if we
> @@ -569,6 +579,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
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
> index d4636a0..a767f2e 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -20,6 +20,9 @@ struct shrink_control {
>  
>  	/* shrink from these nodes */
>  	nodemask_t nodes_to_scan;
> +
> +	/* reclaim from this memcg only (if not NULL) */
> +	struct mem_cgroup *target_mem_cgroup;
>  };
>  
>  /*
> @@ -45,6 +48,7 @@ struct shrinker {
>  
>  	int seeks;	/* seeks to recreate an obj */
>  	long batch;	/* reclaim batch size, 0 = default */
> +	bool memcg_shrinker;
>  
>  	/* These are for internal use */
>  	struct list_head list;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3817460..b1d4dfa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -442,7 +442,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
>  	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
>  
> -static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>  {
>  	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
> @@ -991,6 +991,15 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
>  	return ret;
>  }
>  
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
> +	return mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL);

Without swap enabled it seems like LRU_ALL_FILE is more appropriate.
Maybe something like test_mem_cgroup_node_reclaimable().

> +}
> +
>  static unsigned long
>  mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>  			int nid, unsigned int lru_mask)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6d96280..8af0e2b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -138,11 +138,42 @@ static bool global_reclaim(struct scan_control *sc)
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
> +	(sc->target_mem_cgroup && memcg_kmem_is_active(sc->target_mem_cgroup));

Isn't this the same as:
	return !sc->target_mem_cgroup ||
		memcg_kmem_is_active(sc->target_mem_cgroup);

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
