Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 734C96B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 03:47:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9F81B3EE0BD
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:47:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 827E845DE6F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:47:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B4145DE5D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:47:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5696A1DB8059
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:47:28 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F03A31DB8050
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:47:27 +0900 (JST)
Message-ID: <51593B70.6080003@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 16:46:56 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-22-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-22-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

(2013/03/29 18:14), Glauber Costa wrote:
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
>   include/linux/memcontrol.h | 17 +++++++++++++++++
>   include/linux/shrinker.h   |  4 ++++
>   mm/memcontrol.c            | 16 +++++++++++++++-
>   mm/vmscan.c                | 46 +++++++++++++++++++++++++++++++++++++++++++---
>   4 files changed, 79 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d6183f0..4c24249 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -199,6 +199,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>   bool mem_cgroup_bad_page_check(struct page *page);
>   void mem_cgroup_print_bad_page(struct page *page);
>   #endif
> +
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone);
>   #else /* CONFIG_MEMCG */
>   struct mem_cgroup;
>   
> @@ -377,6 +380,12 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>   				struct page *newpage)
>   {
>   }
> +
> +static inline unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	return 0;
> +}
>   #endif /* CONFIG_MEMCG */
>   
>   #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
> @@ -429,6 +438,8 @@ static inline bool memcg_kmem_enabled(void)
>   	return static_key_false(&memcg_kmem_enabled_key);
>   }
>   
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg);
> +
>   /*
>    * In general, we'll do everything in our power to not incur in any overhead
>    * for non-memcg users for the kmem functions. Not even a function call, if we
> @@ -562,6 +573,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>   	return __memcg_kmem_get_cache(cachep, gfp);
>   }
>   #else
> +
> +static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +{
> +	return false;
> +}
> +
>   #define for_each_memcg_cache_index(_idx)	\
>   	for (; NULL; )
>   
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index d4636a0..4e9e53b 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -20,6 +20,9 @@ struct shrink_control {
>   
>   	/* shrink from these nodes */
>   	nodemask_t nodes_to_scan;
> +
> +	/* reclaim from this memcg only (if not NULL) */
> +	struct mem_cgroup *target_mem_cgroup;
>   };

Does this works only with kmem ? If so, please rename to some explicit
name for now.

  shrink_slab_memcg_target or some ?


>   
>   /*
> @@ -45,6 +48,7 @@ struct shrinker {
>   
>   	int seeks;	/* seeks to recreate an obj */
>   	long batch;	/* reclaim batch size, 0 = default */
> +	bool memcg_shrinker; /* memcg-aware shrinker */
>   
>   	/* These are for internal use */
>   	struct list_head list;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2b55222..ecdae39 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -386,7 +386,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
>   	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>   }
>   
> -static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>   {
>   	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>   }
> @@ -942,6 +942,20 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
>   	return ret;
>   }
>   
> +unsigned long
> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +	unsigned long val;
> +
> +	val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
> +	if (do_swap_account)
> +		val += mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> +						    LRU_ALL_ANON);
> +	return val;
> +}
> +
>   static unsigned long
>   mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>   			int nid, unsigned int lru_mask)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 232dfcb..43928fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -138,11 +138,42 @@ static bool global_reclaim(struct scan_control *sc)
>   {
>   	return !sc->target_mem_cgroup;
>   }
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

Is this test hierarchy aware ?

For example, in following case,

  A      no kmem limit
   \
    B    kmem limit=XXX
     \
      C  kmem limit=XXX

what happens when A is the target.

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
