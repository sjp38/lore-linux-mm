Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4F76B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 07:58:24 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id q59so14494972wes.8
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 04:58:23 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id gg3si32081868wib.6.2015.01.15.04.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 04:58:23 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id n3so3768892wiv.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 04:58:23 -0800 (PST)
Date: Thu, 15 Jan 2015 13:58:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm v2] vmscan: move reclaim_state handling to shrink_slab
Message-ID: <20150115125820.GE7000@dhcp22.suse.cz>
References: <1421311073-28130-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421311073-28130-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-01-15 11:37:53, Vladimir Davydov wrote:
> current->reclaim_state is only used to count the number of slab pages
> reclaimed by shrink_slab(). So instead of initializing it before we are
> 
> Note that after this patch try_to_free_mem_cgroup_pages() will count not
> only reclaimed user pages, but also slab pages, which is expected,
> because it can reclaim kmem from kmem-active sub cgroups.

Except that reclaim_state counts all freed slab objects that have
current->reclaim_state != NULL AFAIR. This includes also kfreed pages
from interrupt context and who knows what else and those pages might be
from a different memcgs, no?

Besides that I am not sure this makes any difference in the end. No
try_to_free_mem_cgroup_pages caller really cares about the exact
number of reclaimed pages. We care only about whether there was any
progress done - and even that not exactly (e.g. try_charge checks
mem_cgroup_margin before retry/oom so if sufficient kmem pages were
uncharged then we will notice that).

That being said, I haven't read the patch yet, but the above assumption
doesn't sound correct to me. reclaim_state is nasty and relying on it for
something that is targeted might lead to unexpected results.

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
> Changes in v2:
>  - do not change shrink_slab() return value to the number of reclaimed
>    slab pages, because it can make drop_slab() abort beforehand (Andrew)
> 
>  mm/page_alloc.c |    4 ----
>  mm/vmscan.c     |   43 +++++++++++++++++--------------------------
>  2 files changed, 17 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e1963ea0684a..f528e4ba91b5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2448,7 +2448,6 @@ static int
>  __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
>  		  nodemask_t *nodemask)
>  {
> -	struct reclaim_state reclaim_state;
>  	int progress;
>  
>  	cond_resched();
> @@ -2457,12 +2456,9 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
>  	cpuset_memory_pressure_bump();
>  	current->flags |= PF_MEMALLOC;
>  	lockdep_set_current_reclaim_state(gfp_mask);
> -	reclaim_state.reclaimed_slab = 0;
> -	current->reclaim_state = &reclaim_state;
>  
>  	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
>  
> -	current->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
>  	current->flags &= ~PF_MEMALLOC;
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 16f3e45742d6..26fdcc6c747d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -367,13 +367,18 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>   * the ->seeks setting of the shrink function, which indicates the
>   * cost to recreate an object relative to that of an LRU page.
>   *
> - * Returns the number of reclaimed slab objects.
> + * Returns the number of reclaimed slab objects. The number of reclaimed slab
> + * pages is added to *@ret_nr_reclaimed.
>   */
>  static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  				 struct mem_cgroup *memcg,
>  				 unsigned long nr_scanned,
> -				 unsigned long nr_eligible)
> +				 unsigned long nr_eligible,
> +				 unsigned long *ret_nr_reclaimed)
>  {
> +	struct reclaim_state reclaim_state = {
> +		.reclaimed_slab = 0,
> +	};
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> @@ -394,6 +399,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  		goto out;
>  	}
>  
> +	current->reclaim_state = &reclaim_state;
> +
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
>  		struct shrink_control sc = {
>  			.gfp_mask = gfp_mask,
> @@ -410,6 +417,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
>  	}
>  
> +	current->reclaim_state = NULL;
> +	*ret_nr_reclaimed += reclaim_state.reclaimed_slab;
> +
>  	up_read(&shrinker_rwsem);
>  out:
>  	cond_resched();
> @@ -419,6 +429,7 @@ out:
>  void drop_slab_node(int nid)
>  {
>  	unsigned long freed;
> +	unsigned long nr_reclaimed = 0;
>  
>  	do {
>  		struct mem_cgroup *memcg = NULL;
> @@ -426,9 +437,9 @@ void drop_slab_node(int nid)
>  		freed = 0;
>  		do {
>  			freed += shrink_slab(GFP_KERNEL, nid, memcg,
> -					     1000, 1000);
> +					     1000, 1000, &nr_reclaimed);
>  		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
> -	} while (freed > 10);
> +	} while (freed);
>  }
>  
>  void drop_slab(void)
> @@ -2339,7 +2350,6 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			bool is_classzone)
>  {
> -	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long nr_reclaimed, nr_scanned;
>  	bool reclaimable = false;
>  
> @@ -2371,7 +2381,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			if (memcg && is_classzone)
>  				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
>  					    memcg, sc->nr_scanned - scanned,
> -					    lru_pages);
> +					    lru_pages, &sc->nr_reclaimed);
>  
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
> @@ -2398,12 +2408,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		if (global_reclaim(sc) && is_classzone)
>  			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
>  				    sc->nr_scanned - nr_scanned,
> -				    zone_lru_pages);
> -
> -		if (reclaim_state) {
> -			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> -			reclaim_state->reclaimed_slab = 0;
> -		}
> +				    zone_lru_pages, &sc->nr_reclaimed);
>  
>  		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
>  			   sc->nr_scanned - nr_scanned,
> @@ -3367,17 +3372,12 @@ static int kswapd(void *p)
>  	int balanced_classzone_idx;
>  	pg_data_t *pgdat = (pg_data_t*)p;
>  	struct task_struct *tsk = current;
> -
> -	struct reclaim_state reclaim_state = {
> -		.reclaimed_slab = 0,
> -	};
>  	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
>  
>  	lockdep_set_current_reclaim_state(GFP_KERNEL);
>  
>  	if (!cpumask_empty(cpumask))
>  		set_cpus_allowed_ptr(tsk, cpumask);
> -	current->reclaim_state = &reclaim_state;
>  
>  	/*
>  	 * Tell the memory management that we're a "memory allocator",
> @@ -3449,7 +3449,6 @@ static int kswapd(void *p)
>  	}
>  
>  	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
> -	current->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
>  
>  	return 0;
> @@ -3492,7 +3491,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>   */
>  unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  {
> -	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = nr_to_reclaim,
>  		.gfp_mask = GFP_HIGHUSER_MOVABLE,
> @@ -3508,12 +3506,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  
>  	p->flags |= PF_MEMALLOC;
>  	lockdep_set_current_reclaim_state(sc.gfp_mask);
> -	reclaim_state.reclaimed_slab = 0;
> -	p->reclaim_state = &reclaim_state;
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>  
> -	p->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
>  	p->flags &= ~PF_MEMALLOC;
>  
> @@ -3678,7 +3673,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	/* Minimum pages needed in order to stay on node */
>  	const unsigned long nr_pages = 1 << order;
>  	struct task_struct *p = current;
> -	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
> @@ -3697,8 +3691,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	 */
>  	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
>  	lockdep_set_current_reclaim_state(gfp_mask);
> -	reclaim_state.reclaimed_slab = 0;
> -	p->reclaim_state = &reclaim_state;
>  
>  	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
>  		/*
> @@ -3710,7 +3702,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
>  	}
>  
> -	p->reclaim_state = NULL;
>  	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
>  	lockdep_clear_current_reclaim_state();
>  	return sc.nr_reclaimed >= nr_pages;
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
