Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1A75E6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 20:40:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 743533EE0C1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:40:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C63B145DEB3
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:40:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A476045DEB7
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:40:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 706A21DB803C
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:40:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15F7F1DB803F
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:40:07 +0900 (JST)
Date: Thu, 16 Feb 2012 10:38:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: rework inactive_ratio logic
Message-Id: <20120216103842.0c3e9258.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120215162442.13588.21790.stgit@zurg>
References: <20120215162442.13588.21790.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 15 Feb 2012 20:24:42 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch adds mem_cgroup->inactive_ratio calculated from hierarchical memory limit.
> It updated at each limit change before shrinking cgroup to this new limit.
> Ratios for all child cgroups are updated too, because parent limit can affect them.
> Update precedure can be greatly optimized if its performance becomes the problem.
> Inactive ratio for unlimited or huge limit does not matter, because we'll never hit it.
> 
> At global reclaim always use global ratio from zone->inactive_ratio.
> At mem-cgroup reclaim use inactive_ratio from target memory cgroup,
> this is cgroup which hit its limit and cause this reclaimer invocation.
> 
> Thus, global memory reclaimer will try to keep ratio for all lru lists in zone
> above one mark, this guarantee that total ratio in this zone will be above too.
> Meanwhile mem-cgroup will do the same thing for its lru lists in all zones, and
> for all lru lists in all sub-cgroups in hierarchy.
> 
> Also this patch removes some redundant code.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Hmm, the main purpose of this patch is to remove calculation per get_scan_ratio() ?




> ---
>  include/linux/memcontrol.h |   16 ++------
>  mm/memcontrol.c            |   85 ++++++++++++++++++++++++--------------------
>  mm/vmscan.c                |   82 +++++++++++++++++++++++-------------------
>  3 files changed, 93 insertions(+), 90 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4d34356..453a3dd 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -113,10 +113,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
>  /*
>   * For memory reclaim.
>   */
> -int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
> -				    struct zone *zone);
> -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
> -				    struct zone *zone);
> +unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg);
>  int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  					int nid, int zid, unsigned int lrumask);
> @@ -319,16 +316,9 @@ static inline bool mem_cgroup_disabled(void)
>  	return true;
>  }
>  
> -static inline int
> -mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
> -{
> -	return 1;
> -}
> -
> -static inline int
> -mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
> +static inline unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg)
>  {
> -	return 1;
> +	return 0;
>  }
>  
>  static inline unsigned long
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6728a7a..343324a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -212,6 +212,8 @@ struct mem_cgroup_eventfd_list {
>  
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> +static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
> +		unsigned long long *mem_limit, unsigned long long *memsw_limit);
>  
>  /*
>   * The memory controller data structure. The memory controller controls both
> @@ -256,6 +258,10 @@ struct mem_cgroup {
>  	atomic_t	refcnt;
>  
>  	int	swappiness;
> +
> +	/* The target ratio of ACTIVE_ANON to INACTIVE_ANON pages */
> +	unsigned int inactive_ratio;
> +
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> @@ -1155,44 +1161,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> -int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
> -{
> -	unsigned long inactive_ratio;
> -	int nid = zone_to_nid(zone);
> -	int zid = zone_idx(zone);
> -	unsigned long inactive;
> -	unsigned long active;
> -	unsigned long gb;
> -
> -	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> -						BIT(LRU_INACTIVE_ANON));
> -	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> -					      BIT(LRU_ACTIVE_ANON));
> -
> -	gb = (inactive + active) >> (30 - PAGE_SHIFT);
> -	if (gb)
> -		inactive_ratio = int_sqrt(10 * gb);
> -	else
> -		inactive_ratio = 1;
> -
> -	return inactive * inactive_ratio < active;
> -}
> -
> -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
> -{
> -	unsigned long active;
> -	unsigned long inactive;
> -	int zid = zone_idx(zone);
> -	int nid = zone_to_nid(zone);
> -
> -	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> -						BIT(LRU_INACTIVE_FILE));
> -	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> -					      BIT(LRU_ACTIVE_FILE));
> -
> -	return (active > inactive);
> -}
> -
>  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone)
>  {
> @@ -3373,6 +3341,32 @@ void mem_cgroup_print_bad_page(struct page *page)
>  
>  static DEFINE_MUTEX(set_limit_mutex);
>  
> +/*
> + * Update inactive_ratio accoring to new memory limit
> + */
> +static void mem_cgroup_update_inactive_ratio(struct mem_cgroup *memcg,
> +					     unsigned long long target)
> +{
> +	unsigned long long mem_limit, memsw_limit, gb;
> +	struct mem_cgroup *iter;
> +
> +	for_each_mem_cgroup_tree(iter, memcg) {
> +		memcg_get_hierarchical_limit(iter, &mem_limit, &memsw_limit);
> +		mem_limit = min(mem_limit, target);
> +
> +		gb = mem_limit >> 30;
> +		if (gb && 10 * gb < INT_MAX)
> +			iter->inactive_ratio = int_sqrt(10 * gb);
> +		else
> +			iter->inactive_ratio = 1;
> +	}
> +}
> +
> +unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg)
> +{
> +	return memcg->inactive_ratio;
> +}
> +
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
> @@ -3422,6 +3416,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  			else
>  				memcg->memsw_is_minimum = false;
>  		}
> +		mem_cgroup_update_inactive_ratio(memcg, val);
>  		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
> @@ -3439,6 +3434,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  	if (!ret && enlarge)
>  		memcg_oom_recover(memcg);
>  
> +	if (ret) {
> +		mutex_lock(&set_limit_mutex);
> +		mem_cgroup_update_inactive_ratio(memcg, RESOURCE_MAX);
> +		mutex_unlock(&set_limit_mutex);
> +	}

Why RESOUECE_MAX ?

Thanks,
-Kame

> +
>  	return ret;
>  }
>  
> @@ -4155,6 +4156,8 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  	}
>  
>  #ifdef CONFIG_DEBUG_VM
> +	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
> +
>  	{
>  		int nid, zid;
>  		struct mem_cgroup_per_zone *mz;
> @@ -4936,8 +4939,12 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);
>  
> -	if (parent)
> +	if (parent) {
>  		memcg->swappiness = mem_cgroup_swappiness(parent);
> +		memcg->inactive_ratio = parent->inactive_ratio;
> +	} else
> +		memcg->inactive_ratio = 1;
> +
>  	atomic_set(&memcg->refcnt, 1);
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4061e91..531abcc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1788,19 +1788,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  }
>  
>  #ifdef CONFIG_SWAP
> -static int inactive_anon_is_low_global(struct zone *zone)
> -{
> -	unsigned long active, inactive;
> -
> -	active = zone_page_state(zone, NR_ACTIVE_ANON);
> -	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> -
> -	if (inactive * zone->inactive_ratio < active)
> -		return 1;
> -
> -	return 0;
> -}
> -
>  /**
>   * inactive_anon_is_low - check if anonymous pages need to be deactivated
>   * @zone: zone to check
> @@ -1809,8 +1796,12 @@ static int inactive_anon_is_low_global(struct zone *zone)
>   * Returns true if the zone does not have enough inactive anon pages,
>   * meaning some active anon pages need to be deactivated.
>   */
> -static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
> +static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
> +				struct scan_control *sc)
>  {
> +	unsigned long active, inactive;
> +	unsigned int ratio;
> +
>  	/*
>  	 * If we don't have swap space, anonymous page deactivation
>  	 * is pointless.
> @@ -1818,29 +1809,33 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
>  	if (!total_swap_pages)
>  		return 0;
>  
> -	if (!scanning_global_lru(mz))
> -		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
> -						       mz->zone);
> +	if (global_reclaim(sc))
> +		ratio = mz->zone->inactive_ratio;
> +	else
> +		ratio = mem_cgroup_inactive_ratio(sc->target_mem_cgroup);
>  
> -	return inactive_anon_is_low_global(mz->zone);
> +	if (scanning_global_lru(mz)) {
> +		active = zone_page_state(mz->zone, NR_ACTIVE_ANON);
> +		inactive = zone_page_state(mz->zone, NR_INACTIVE_ANON);
> +	} else {
> +		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
> +				zone_to_nid(mz->zone), zone_idx(mz->zone),
> +				BIT(LRU_ACTIVE_ANON));
> +		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
> +				zone_to_nid(mz->zone), zone_idx(mz->zone),
> +				BIT(LRU_INACTIVE_ANON));
> +	}
> +
> +	return inactive * ratio < active;
>  }
>  #else
> -static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
> +static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
> +				       struct scan_control *sc)
>  {
>  	return 0;
>  }
>  #endif
>  
> -static int inactive_file_is_low_global(struct zone *zone)
> -{
> -	unsigned long active, inactive;
> -
> -	active = zone_page_state(zone, NR_ACTIVE_FILE);
> -	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> -
> -	return (active > inactive);
> -}
> -
>  /**
>   * inactive_file_is_low - check if file pages need to be deactivated
>   * @mz: memory cgroup and zone to check
> @@ -1857,19 +1852,30 @@ static int inactive_file_is_low_global(struct zone *zone)
>   */
>  static int inactive_file_is_low(struct mem_cgroup_zone *mz)
>  {
> -	if (!scanning_global_lru(mz))
> -		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
> -						       mz->zone);
> +	unsigned long active, inactive;
> +
> +	if (scanning_global_lru(mz)) {
> +		active = zone_page_state(mz->zone, NR_ACTIVE_FILE);
> +		inactive = zone_page_state(mz->zone, NR_INACTIVE_FILE);
> +	} else {
> +		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
> +				zone_to_nid(mz->zone), zone_idx(mz->zone),
> +				BIT(LRU_ACTIVE_FILE));
> +		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
> +				zone_to_nid(mz->zone), zone_idx(mz->zone),
> +				BIT(LRU_INACTIVE_FILE));
> +	}
>  
> -	return inactive_file_is_low_global(mz->zone);
> +	return inactive < active;
>  }
>  
> -static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
> +static int inactive_list_is_low(struct mem_cgroup_zone *mz,
> +				struct scan_control *sc, int file)
>  {
>  	if (file)
>  		return inactive_file_is_low(mz);
>  	else
> -		return inactive_anon_is_low(mz);
> +		return inactive_anon_is_low(mz, sc);
>  }
>  
>  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> @@ -1879,7 +1885,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	int file = is_file_lru(lru);
>  
>  	if (is_active_lru(lru)) {
> -		if (inactive_list_is_low(mz, file))
> +		if (inactive_list_is_low(mz, sc, file))
>  			shrink_active_list(nr_to_scan, mz, sc, priority, file);
>  		return 0;
>  	}
> @@ -2129,7 +2135,7 @@ restart:
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (inactive_anon_is_low(mz))
> +	if (inactive_anon_is_low(mz, sc))
>  		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
>  
>  	/* reclaim/compaction might need reclaim to continue */
> @@ -2558,7 +2564,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
>  			.zone = zone,
>  		};
>  
> -		if (inactive_anon_is_low(&mz))
> +		if (inactive_anon_is_low(&mz, sc))
>  			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
>  					   sc, priority, 0);
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
