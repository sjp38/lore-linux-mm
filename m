Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 20C176B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 11:48:54 -0400 (EDT)
Received: by pxi10 with SMTP id 10so1150334pxi.8
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 08:48:49 -0700 (PDT)
Date: Fri, 10 Jun 2011 00:48:39 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609154839.GF4878@barrios-laptop>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hannes,

I have a comment.
Please look at bottom line.

On Wed, Jun 01, 2011 at 08:25:13AM +0200, Johannes Weiner wrote:
> When a memcg hits its hard limit, hierarchical target reclaim is
> invoked, which goes through all contributing memcgs in the hierarchy
> below the offending memcg and reclaims from the respective per-memcg
> lru lists.  This distributes pressure fairly among all involved
> memcgs, and pages are aged with respect to their list buddies.
> 
> When global memory pressure arises, however, all this is dropped
> overboard.  Pages are reclaimed based on global lru lists that have
> nothing to do with container-internal age, and some memcgs may be
> reclaimed from much more than others.
> 
> This patch makes traditional global reclaim consider container
> boundaries and no longer scan the global lru lists.  For each zone
> scanned, the memcg hierarchy is walked and pages are reclaimed from
> the per-memcg lru lists of the respective zone.  For now, the
> hierarchy walk is bounded to one full round-trip through the
> hierarchy, or if the number of reclaimed pages reach the overall
> reclaim target, whichever comes first.
> 
> Conceptually, global memory pressure is then treated as if the root
> memcg had hit its limit.  Since all existing memcgs contribute to the
> usage of the root memcg, global reclaim is nothing more than target
> reclaim starting from the root memcg.  The code is mostly the same for
> both cases, except for a few heuristics and statistics that do not
> always apply.  They are distinguished by a newly introduced
> global_reclaim() primitive.
> 
> One implication of this change is that pages have to be linked to the
> lru lists of the root memcg again, which could be optimized away with
> the old scheme.  The costs are not measurable, though, even with
> worst-case microbenchmarks.
> 
> As global reclaim no longer relies on global lru lists, this change is
> also in preparation to remove those completely.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |   15 ++++
>  mm/memcontrol.c            |  176 ++++++++++++++++++++++++++++----------------
>  mm/vmscan.c                |  121 ++++++++++++++++++++++--------
>  3 files changed, 218 insertions(+), 94 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5e9840f5..332b0a6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -101,6 +101,10 @@ mem_cgroup_prepare_migration(struct page *page,
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	struct page *oldpage, struct page *newpage, bool migration_ok);
>  
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
> +					     struct mem_cgroup *);
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup *);
> +
>  /*
>   * For memory reclaim.
>   */
> @@ -321,6 +325,17 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return NULL;
>  }
>  
> +static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *r,
> +							   struct mem_cgroup *m)
> +{
> +	return NULL;
> +}
> +
> +static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
> +						  struct mem_cgroup *m)
> +{
> +}
> +
>  static inline void
>  mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5ab87..850176e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -313,8 +313,8 @@ static bool move_file(void)
>  }
>  
>  /*
> - * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> - * limit reclaim to prevent infinite loops, if they ever occur.
> + * Maximum loops in reclaim, used for soft limit reclaim to prevent
> + * infinite loops, if they ever occur.
>   */
>  #define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
>  #define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
> @@ -340,7 +340,7 @@ enum charge_type {
>  #define OOM_CONTROL		(0)
>  
>  /*
> - * Reclaim flags for mem_cgroup_hierarchical_reclaim
> + * Reclaim flags
>   */
>  #define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
>  #define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
> @@ -846,8 +846,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	VM_BUG_ON(list_empty(&pc->lru));
>  	list_del_init(&pc->lru);
>  }
> @@ -872,13 +870,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	/* unused or root page is not rotated. */
> +	/* unused page is not rotated. */
>  	if (!PageCgroupUsed(pc))
>  		return;
>  	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>  	smp_rmb();
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	list_move_tail(&pc->lru, &mz->lists[lru]);
>  }
> @@ -892,13 +888,11 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	/* unused or root page is not rotated. */
> +	/* unused page is not rotated. */
>  	if (!PageCgroupUsed(pc))
>  		return;
>  	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>  	smp_rmb();
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	list_move(&pc->lru, &mz->lists[lru]);
>  }
> @@ -920,8 +914,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
>  	SetPageCgroupAcctLRU(pc);
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	list_add(&pc->lru, &mz->lists[lru]);
>  }
>  
> @@ -1381,6 +1373,97 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  	return min(limit, memsw);
>  }
>  
> +/**
> + * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy
> + * @root: starting point of the hierarchy
> + * @prev: previous position or NULL
> + *
> + * Caller must hold a reference to @root.  While this function will
> + * return @root as part of the walk, it will never increase its
> + * reference count.
> + *
> + * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it
> + * stops the walk potentially before the full round trip.
> + */
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> +					     struct mem_cgroup *prev)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	if (!root)
> +		root = root_mem_cgroup;
> +	/*
> +	 * Even without hierarchy explicitely enabled in the root
> +	 * memcg, it is the ultimate parent of all memcgs.
> +	 */
> +	if (!(root == root_mem_cgroup || root->use_hierarchy))
> +		return root;
> +	if (prev && prev != root)
> +		css_put(&prev->css);
> +	do {
> +		int id = root->last_scanned_child;
> +		struct cgroup_subsys_state *css;
> +
> +		rcu_read_lock();
> +		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> +		if (css && (css == &root->css || css_tryget(css)))
> +			mem = container_of(css, struct mem_cgroup, css);
> +		rcu_read_unlock();
> +		if (!css)
> +			id = 0;
> +		root->last_scanned_child = id;
> +	} while (!mem);
> +	return mem;
> +}
> +
> +/**
> + * mem_cgroup_stop_hierarchy_walk - clean up after partial hierarchy walk
> + * @root: starting point in the hierarchy
> + * @mem: last position during the walk
> + */
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
> +				    struct mem_cgroup *mem)
> +{
> +	if (mem && mem != root)
> +		css_put(&mem->css);
> +}
> +
> +static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
> +					gfp_t gfp_mask,
> +					unsigned long flags)
> +{
> +	unsigned long total = 0;
> +	bool noswap = false;
> +	int loop;
> +
> +	if ((flags & MEM_CGROUP_RECLAIM_NOSWAP) || mem->memsw_is_minimum)
> +		noswap = true;
> +	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> +		drain_all_stock_async();
> +		total += try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap,
> +						      get_swappiness(mem));
> +		/*
> +		 * Avoid freeing too much when shrinking to resize the
> +		 * limit.  XXX: Shouldn't the margin check be enough?
> +		 */
> +		if (total && (flags & MEM_CGROUP_RECLAIM_SHRINK))
> +			break;
> +		if (mem_cgroup_margin(mem))
> +			break;
> +		/*
> +		 * If we have not been able to reclaim anything after
> +		 * two reclaim attempts, there may be no reclaimable
> +		 * pages in this hierarchy.
> +		 */
> +		if (loop && !total)
> +			break;
> +	}
> +	return total;
> +}
> +
>  /*
>   * Visit the first child (need not be the first child as per the ordering
>   * of the cgroup list, since we track last_scanned_child) of @mem and use
> @@ -1418,29 +1501,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>  	return ret;
>  }
>  
> -/*
> - * Scan the hierarchy if needed to reclaim memory. We remember the last child
> - * we reclaimed from, so that we don't end up penalizing one child extensively
> - * based on its position in the children list.
> - *
> - * root_mem is the original ancestor that we've been reclaim from.
> - *
> - * We give up and return to the caller when we visit root_mem twice.
> - * (other groups can be removed while we're walking....)
> - *
> - * If shrink==true, for avoiding to free too much, this returns immedieately.
> - */
> -static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> -						struct zone *zone,
> -						gfp_t gfp_mask,
> -						unsigned long reclaim_options)
> +static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
> +				   struct zone *zone,
> +				   gfp_t gfp_mask)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
>  	int loop = 0;
> -	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> -	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> -	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> +	bool noswap = false;
>  	unsigned long excess;
>  
>  	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> @@ -1461,7 +1529,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  				 * anything, it might because there are
>  				 * no reclaimable pages under this hierarchy
>  				 */
> -				if (!check_soft || !total) {
> +				if (!total) {
>  					css_put(&victim->css);
>  					break;
>  				}
> @@ -1483,26 +1551,11 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  			css_put(&victim->css);
>  			continue;
>  		}
> -		/* we use swappiness of local cgroup */
> -		if (check_soft)
> -			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -				noswap, get_swappiness(victim), zone);
> -		else
> -			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -						noswap, get_swappiness(victim));
> +		ret = mem_cgroup_shrink_node_zone(victim, gfp_mask, noswap,
> +						  get_swappiness(victim), zone);
>  		css_put(&victim->css);
> -		/*
> -		 * At shrinking usage, we can't check we should stop here or
> -		 * reclaim more. It's depends on callers. last_scanned_child
> -		 * will work enough for keeping fairness under tree.
> -		 */
> -		if (shrink)
> -			return ret;
>  		total += ret;
> -		if (check_soft) {
> -			if (!res_counter_soft_limit_excess(&root_mem->res))
> -				return total;
> -		} else if (mem_cgroup_margin(root_mem))
> +		if (!res_counter_soft_limit_excess(&root_mem->res))
>  			return total;
>  	}
>  	return total;
> @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
>  	if (!(gfp_mask & __GFP_WAIT))
>  		return CHARGE_WOULDBLOCK;
>  
> -	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -					      gfp_mask, flags);
> +	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>  	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>  		return CHARGE_RETRY;
>  	/*
> @@ -3085,7 +3137,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  
>  /*
>   * A call to try to shrink memory usage on charge failure at shmem's swapin.
> - * Calling hierarchical_reclaim is not enough because we should update
> + * Calling reclaim is not enough because we should update
>   * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
>   * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
>   * not from the memcg which this page would be charged to.
> @@ -3167,7 +3219,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  	int enlarge;
>  
>  	/*
> -	 * For keeping hierarchical_reclaim simple, how long we should retry
> +	 * For keeping reclaim simple, how long we should retry
>  	 * is depends on callers. We set our retry-count to be function
>  	 * of # of children which we should visit in this loop.
>  	 */
> @@ -3210,8 +3262,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -						MEM_CGROUP_RECLAIM_SHRINK);
> +		mem_cgroup_reclaim(memcg, GFP_KERNEL,
> +				   MEM_CGROUP_RECLAIM_SHRINK);
>  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>  		/* Usage is reduced ? */
>    		if (curusage >= oldusage)
> @@ -3269,9 +3321,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -						MEM_CGROUP_RECLAIM_NOSWAP |
> -						MEM_CGROUP_RECLAIM_SHRINK);
> +		mem_cgroup_reclaim(memcg, GFP_KERNEL,
> +				   MEM_CGROUP_RECLAIM_NOSWAP |
> +				   MEM_CGROUP_RECLAIM_SHRINK);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
> @@ -3311,9 +3363,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  		if (!mz)
>  			break;
>  
> -		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
> -						gfp_mask,
> -						MEM_CGROUP_RECLAIM_SOFT);
> +		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone, gfp_mask);
>  		nr_reclaimed += reclaimed;
>  		spin_lock(&mctz->lock);
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8bfd450..7e9bfca 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -104,7 +104,16 @@ struct scan_control {
>  	 */
>  	reclaim_mode_t reclaim_mode;
>  
> -	/* Which cgroup do we reclaim from */
> +	/*
> +	 * The memory cgroup that hit its hard limit and is the
> +	 * primary target of this reclaim invocation.
> +	 */
> +	struct mem_cgroup *target_mem_cgroup;
> +
> +	/*
> +	 * The memory cgroup that is currently being scanned as a
> +	 * child and contributor to the usage of target_mem_cgroup.
> +	 */
>  	struct mem_cgroup *mem_cgroup;
>  
>  	/*
> @@ -154,9 +163,36 @@ static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -#define scanning_global_lru(sc)	(!(sc)->mem_cgroup)
> +/**
> + * global_reclaim - whether reclaim is global or due to memcg hard limit
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool global_reclaim(struct scan_control *sc)
> +{
> +	return !sc->target_mem_cgroup;
> +}
> +/**
> + * scanning_global_lru - whether scanning global lrus or per-memcg lrus
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> +	/*
> +	 * Unless memory cgroups are disabled on boot, the traditional
> +	 * global lru lists are never scanned and reclaim will always
> +	 * operate on the per-memcg lru lists.
> +	 */
> +	return mem_cgroup_disabled();
> +}
>  #else
> -#define scanning_global_lru(sc)	(1)
> +static bool global_reclaim(struct scan_control *sc)
> +{
> +	return true;
> +}
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> +	return true;
> +}
>  #endif
>  
>  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> @@ -1228,7 +1264,7 @@ static int too_many_isolated(struct zone *zone, int file,
>  	if (current_is_kswapd())
>  		return 0;
>  
> -	if (!scanning_global_lru(sc))
> +	if (!global_reclaim(sc))
>  		return 0;
>  
>  	if (file) {
> @@ -1397,13 +1433,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, 0, file);
> -		zone->pages_scanned += nr_scanned;
> -		if (current_is_kswapd())
> -			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
> -					       nr_scanned);
> -		else
> -			__count_zone_vm_events(PGSCAN_DIRECT, zone,
> -					       nr_scanned);
>  	} else {
>  		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
>  			&page_list, &nr_scanned, sc->order,
> @@ -1411,10 +1440,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, sc->mem_cgroup,
>  			0, file);
> -		/*
> -		 * mem_cgroup_isolate_pages() keeps track of
> -		 * scanned pages on its own.
> -		 */
> +	}
> +
> +	if (global_reclaim(sc)) {
> +		zone->pages_scanned += nr_scanned;
> +		if (current_is_kswapd())
> +			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
> +					       nr_scanned);
> +		else
> +			__count_zone_vm_events(PGSCAN_DIRECT, zone,
> +					       nr_scanned);
>  	}
>  
>  	if (nr_taken == 0) {
> @@ -1520,18 +1555,16 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  						&pgscanned, sc->order,
>  						ISOLATE_ACTIVE, zone,
>  						1, file);
> -		zone->pages_scanned += pgscanned;
>  	} else {
>  		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
>  						&pgscanned, sc->order,
>  						ISOLATE_ACTIVE, zone,
>  						sc->mem_cgroup, 1, file);
> -		/*
> -		 * mem_cgroup_isolate_pages() keeps track of
> -		 * scanned pages on its own.
> -		 */
>  	}
>  
> +	if (global_reclaim(sc))
> +		zone->pages_scanned += pgscanned;
> +
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> @@ -1752,7 +1785,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
>  	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
>  		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
>  
> -	if (scanning_global_lru(sc)) {
> +	if (global_reclaim(sc)) {
>  		free  = zone_page_state(zone, NR_FREE_PAGES);
>  		/* If we have very few page cache pages,
>  		   force-scan anon pages. */
> @@ -1889,8 +1922,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> -static void shrink_zone(int priority, struct zone *zone,
> -				struct scan_control *sc)
> +static void do_shrink_zone(int priority, struct zone *zone,
> +			   struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
>  	unsigned long nr_to_scan;
> @@ -1943,6 +1976,31 @@ restart:
>  	throttle_vm_writeout(sc->gfp_mask);
>  }
>  
> +static void shrink_zone(int priority, struct zone *zone,
> +			struct scan_control *sc)
> +{
> +	unsigned long nr_reclaimed_before = sc->nr_reclaimed;
> +	struct mem_cgroup *root = sc->target_mem_cgroup;
> +	struct mem_cgroup *first, *mem = NULL;
> +
> +	first = mem = mem_cgroup_hierarchy_walk(root, mem);
> +	for (;;) {
> +		unsigned long nr_reclaimed;
> +
> +		sc->mem_cgroup = mem;
> +		do_shrink_zone(priority, zone, sc);
> +
> +		nr_reclaimed = sc->nr_reclaimed - nr_reclaimed_before;
> +		if (nr_reclaimed >= sc->nr_to_reclaim)
> +			break;
> +
> +		mem = mem_cgroup_hierarchy_walk(root, mem);
> +		if (mem == first)
> +			break;
> +	}
> +	mem_cgroup_stop_hierarchy_walk(root, mem);
> +}
> +
>  /*
>   * This is the direct reclaim path, for page-allocating processes.  We only
>   * try to reclaim pages from zones which will satisfy the caller's allocation
> @@ -1973,7 +2031,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  		 * Take care memory controller reclaiming has small influence
>  		 * to global LRU.
>  		 */
> -		if (scanning_global_lru(sc)) {
> +		if (global_reclaim(sc)) {
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
>  			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
> @@ -2038,7 +2096,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	get_mems_allowed();
>  	delayacct_freepages_start();
>  
> -	if (scanning_global_lru(sc))
> +	if (global_reclaim(sc))
>  		count_vm_event(ALLOCSTALL);
>  
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> @@ -2050,7 +2108,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		 * Don't shrink slabs when reclaiming memory from
>  		 * over limit cgroups
>  		 */
> -		if (scanning_global_lru(sc)) {
> +		if (global_reclaim(sc)) {
>  			unsigned long lru_pages = 0;
>  			for_each_zone_zonelist(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask)) {
> @@ -2111,7 +2169,7 @@ out:
>  		return 0;
>  
>  	/* top priority shrink_zones still had more to do? don't OOM, then */
> -	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
> +	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
>  		return 1;
>  
>  	return 0;
> @@ -2129,7 +2187,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.may_swap = 1,
>  		.swappiness = vm_swappiness,
>  		.order = order,
> -		.mem_cgroup = NULL,
> +		.target_mem_cgroup = NULL,
>  		.nodemask = nodemask,
>  	};
>  
> @@ -2158,6 +2216,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  		.may_swap = !noswap,
>  		.swappiness = swappiness,
>  		.order = 0,
> +		.target_mem_cgroup = mem,
>  		.mem_cgroup = mem,
>  	};
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> @@ -2174,7 +2233,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  	 * will pick up pages from other mem cgroup's as well. We hack
>  	 * the priority and make it zero.
>  	 */
> -	shrink_zone(0, zone, &sc);
> +	do_shrink_zone(0, zone, &sc);
>  
>  	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>  
> @@ -2195,7 +2254,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.swappiness = swappiness,
>  		.order = 0,
> -		.mem_cgroup = mem_cont,
> +		.target_mem_cgroup = mem_cont,
>  		.nodemask = NULL, /* we don't care the placement */
>  	};
>  
> @@ -2333,7 +2392,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		.nr_to_reclaim = ULONG_MAX,
>  		.swappiness = vm_swappiness,
>  		.order = order,
> -		.mem_cgroup = NULL,
> +		.target_mem_cgroup = NULL,
>  	};
>  loop_again:
>  	total_scanned = 0;
> -- 
> 1.7.5.2
> 

I didn't look at all, still. You might change the logic later patches.
If I understand this patch right, it does round-robin reclaim in all memcgs
when global memory pressure happens.

Let's consider this memcg size unbalance case.

If A-memcg has lots of LRU pages, scanning count for reclaim would be bigger
so the chance to reclaim the pages would be higher.
If we reclaim A-memcg, we can reclaim the number of pages we want easily and break.
Next reclaim will happen at some time and reclaim will start the B-memcg of A-memcg
we reclaimed successfully before. But unfortunately B-memcg has small lru so
scanning count would be small and small memcg's LRU aging is higher than bigger memcg.
It means small memcg's working set can be evicted easily than big memcg.
my point is that we should not set next memcg easily.
We have to consider memcg LRU size.

It is big change compared to old LRU aging.
I think LRU is meaningful when we have lots of pages globally.
I really like unify global and memcg but if we break old,
we have to prove that it doesn't hurt old LRU aging.

I hope I miss something.
-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
