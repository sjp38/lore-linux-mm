Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 461916B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 02:57:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU7vZp1020430
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 16:57:35 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE0E445DE6F
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:57:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82A0445DE60
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:57:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06217E38009
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:57:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6740DEF8001
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:57:27 +0900 (JST)
Date: Tue, 30 Nov 2010 16:51:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
Message-Id: <20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291099785-5433-4-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 22:49:44 -0800
Ying Han <yinghan@google.com> wrote:

> The current implementation of memcg only supports direct reclaim and this
> patch adds the support for background reclaim. Per cgroup background reclaim
> is needed which spreads out the memory pressure over longer period of time
> and smoothes out the system performance.
> 
> There is a kswapd kernel thread for each memory node. We add a different kswapd
> for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
> field of a kswapd descriptor.
> 
> The kswapd() function now is shared between global and per cgroup kswapd thread.
> It is passed in with the kswapd descriptor which contains the information of
> either node or cgroup. Then the new function balance_mem_cgroup_pgdat is invoked
> if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs a
> priority loop similar to global reclaim. In each iteration it invokes
> balance_pgdat_node for all nodes on the system, which is a new function performs
> background reclaim per node. After reclaiming each node, it checks
> mem_cgroup_watermark_ok() and breaks the priority loop if returns true. A per
> memcg zone will be marked as "unreclaimable" if the scanning rate is much
> greater than the reclaiming rate on the per cgroup LRU. The bit is cleared when
> there is a page charged to the cgroup being freed. Kswapd breaks the priority
> loop if all the zones are marked as "unreclaimable".
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/memcontrol.h |   30 +++++++
>  mm/memcontrol.c            |  182 ++++++++++++++++++++++++++++++++++++++-
>  mm/page_alloc.c            |    2 +
>  mm/vmscan.c                |  205 +++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 416 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 90fe7fe..dbed45d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -127,6 +127,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>  
> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zone);
> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
> +					unsigned long nr_scanned);
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> @@ -299,6 +305,25 @@ static inline void mem_cgroup_update_file_mapped(struct page *page,
>  {
>  }
>  
> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
> +						struct zone *zone,
> +						unsigned long nr_scanned)
> +{
> +}
> +
> +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
> +							struct zone *zone)
> +{
> +}
> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
> +		struct zone *zone)
> +{
> +}
> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
> +						struct zone *zone)
> +{
> +}
> +
>  static inline
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  					    gfp_t gfp_mask)
> @@ -312,6 +337,11 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
>  	return 0;
>  }
>  
> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
> +								int zid)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a0c6ed9..1d39b65 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -48,6 +48,8 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
> +#include <linux/kthread.h>
> +
>  #include "internal.h"
>  
>  #include <asm/uaccess.h>
> @@ -118,7 +120,10 @@ struct mem_cgroup_per_zone {
>  	bool			on_tree;
>  	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
>  						/* use container_of	   */
> +	unsigned long		pages_scanned;	/* since last reclaim */
> +	int			all_unreclaimable;	/* All pages pinned */
>  };
> +
>  /* Macro for accessing counter */
>  #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
>  
> @@ -372,6 +377,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>  static void drain_all_stock_async(void);
>  static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
> +static inline void wake_memcg_kswapd(struct mem_cgroup *mem);
>  
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> @@ -1086,6 +1092,106 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return &mz->reclaim_stat;
>  }
>  
> +unsigned long mem_cgroup_zone_reclaimable_pages(
> +					struct mem_cgroup_per_zone *mz)
> +{
> +	int nr;
> +	nr = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
> +		MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
> +
> +	if (nr_swap_pages > 0)
> +		nr += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) +
> +			MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
> +
> +	return nr;
> +}
> +
> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
> +						unsigned long nr_scanned)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
> +	if (!mem)
> +		return;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz)
> +		mz->pages_scanned += nr_scanned;
> +}
> +
> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +
> +	if (!mem)
> +		return 0;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz)
> +		return mz->pages_scanned <
> +				mem_cgroup_zone_reclaimable_pages(mz) * 6;
> +	return 0;
> +}
> +
> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
> +	if (!mem)
> +		return 0;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz)
> +		return mz->all_unreclaimable;
> +
> +	return 0;
> +}
> +
> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
> +	if (!mem)
> +		return;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz)
> +		mz->all_unreclaimable = 1;
> +}
> +
> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zone)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +	struct mem_cgroup *mem = NULL;
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +	struct page_cgroup *pc = lookup_page_cgroup(page);
> +
> +	if (unlikely(!pc))
> +		return;
> +
> +	rcu_read_lock();
> +	mem = pc->mem_cgroup;

This is incorrect. you have to do css_tryget(&mem->css) before rcu_read_unlock.

> +	rcu_read_unlock();
> +
> +	if (!mem)
> +		return;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz) {
> +		mz->pages_scanned = 0;
> +		mz->all_unreclaimable = 0;
> +	}
> +
> +	return;
> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> @@ -1887,6 +1993,20 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
>  	struct res_counter *fail_res;
>  	unsigned long flags = 0;
>  	int ret;
> +	unsigned long min_free_kbytes = 0;
> +
> +	min_free_kbytes = get_min_free_kbytes(mem);
> +	if (min_free_kbytes) {
> +		ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_LOW,
> +					&fail_res);
> +		if (likely(!ret)) {
> +			return CHARGE_OK;
> +		} else {
> +			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> +									res);
> +			wake_memcg_kswapd(mem_over_limit);
> +		}
> +	}

I think this check can be moved out to periodic-check as threshould notifiers.



>  
>  	ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_MIN, &fail_res);
>  
> @@ -3037,6 +3157,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  			else
>  				memcg->memsw_is_minimum = false;
>  		}
> +		setup_per_memcg_wmarks(memcg);
>  		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
> @@ -3046,7 +3167,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  						MEM_CGROUP_RECLAIM_SHRINK);
>  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>  		/* Usage is reduced ? */
> -  		if (curusage >= oldusage)
> +		if (curusage >= oldusage)
>  			retry_count--;
>  		else
>  			oldusage = curusage;

What's changed here ?

> @@ -3096,6 +3217,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  			else
>  				memcg->memsw_is_minimum = false;
>  		}
> +		setup_per_memcg_wmarks(memcg);
>  		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
> @@ -4352,6 +4474,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  static void __mem_cgroup_free(struct mem_cgroup *mem)
>  {
>  	int node;
> +	struct kswapd *kswapd_p;
> +	wait_queue_head_t *wait;
>  
>  	mem_cgroup_remove_from_trees(mem);
>  	free_css_id(&mem_cgroup_subsys, &mem->css);
> @@ -4360,6 +4484,15 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
>  		free_mem_cgroup_per_zone_info(mem, node);
>  
>  	free_percpu(mem->stat);
> +
> +	wait = mem->kswapd_wait;
> +	kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> +	if (kswapd_p) {
> +		if (kswapd_p->kswapd_task)
> +			kthread_stop(kswapd_p->kswapd_task);
> +		kfree(kswapd_p);
> +	}
> +
>  	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
>  		kfree(mem);
>  	else
> @@ -4421,6 +4554,39 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
>  	return ret;
>  }
>  
> +static inline
> +void wake_memcg_kswapd(struct mem_cgroup *mem)
> +{
> +	wait_queue_head_t *wait;
> +	struct kswapd *kswapd_p;
> +	struct task_struct *thr;
> +	static char memcg_name[PATH_MAX];
> +
> +	if (!mem)
> +		return;
> +
> +	wait = mem->kswapd_wait;
> +	kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> +	if (!kswapd_p->kswapd_task) {
> +		if (mem->css.cgroup)
> +			cgroup_path(mem->css.cgroup, memcg_name, PATH_MAX);
> +		else
> +			sprintf(memcg_name, "no_name");
> +
> +		thr = kthread_run(kswapd, kswapd_p, "kswapd%s", memcg_name);

I don't think reusing the name of "kswapd" isn't good. and this name cannot
be long as PATH_MAX...IIUC, this name is for comm[] field which is 16bytes long.

So, how about naming this as

  "memcg%d", mem->css.id ?

Exporing css.id will be okay if necessary.



> +		if (IS_ERR(thr))
> +			printk(KERN_INFO "Failed to start kswapd on memcg %d\n",
> +				0);
> +		else
> +			kswapd_p->kswapd_task = thr;
> +	}

Hmm, ok, then, kswapd-for-memcg is created when someone go over watermark.
Why this new kswapd will not exit() until memcg destroy ?

I think there are several approaches.

  1. create/destroy a thread at memcg create/destroy
  2. create/destroy a thread at watermarks.
  3. use thread pool for watermarks.
  4. use workqueue for watermaks.

The good point of "1" is that we can control a-thread-for-kswapd by cpu
controller but it will use some resource.
The good point of "2" is that we can avoid unnecessary resource usage.

3 and 4 is not very good, I think. 

I'd like to vote for "1"...I want to avoid "stealing" other container's cpu
by bad application in a container uses up memory.




> +
> +	if (!waitqueue_active(wait)) {
> +		return;
> +	}
> +	wake_up_interruptible(wait);
> +}
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
> @@ -4452,6 +4618,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	struct mem_cgroup *mem, *parent;
>  	long error = -ENOMEM;
>  	int node;
> +	struct kswapd *kswapd_p = NULL;
>  
>  	mem = mem_cgroup_alloc();
>  	if (!mem)
> @@ -4499,6 +4666,19 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	spin_lock_init(&mem->reclaim_param_lock);
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
> +
> +	if (!mem_cgroup_is_root(mem)) {
> +		kswapd_p = kmalloc(sizeof(struct kswapd), GFP_KERNEL);
> +		if (!kswapd_p) {
> +			printk(KERN_INFO "Failed to kmalloc kswapd_p %d\n", 0);
> +			goto free_out;
> +		}
> +		memset(kswapd_p, 0, sizeof(struct kswapd));
> +		init_waitqueue_head(&kswapd_p->kswapd_wait);
> +		mem->kswapd_wait = &kswapd_p->kswapd_wait;
> +		kswapd_p->kswapd_mem = mem;
> +	}
> +
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a15bc1c..dc61f2a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -615,6 +615,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  
>  		do {
>  			page = list_entry(list->prev, struct page, lru);
> +			mem_cgroup_clear_unreclaimable(page, zone);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> @@ -632,6 +633,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  	spin_lock(&zone->lock);
>  	zone->all_unreclaimable = 0;
>  	zone->pages_scanned = 0;
> +	mem_cgroup_clear_unreclaimable(page, zone);
>  
>  	__free_one_page(page, zone, order, migratetype);
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6d5702b..f8430c4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -100,6 +100,8 @@ struct scan_control {
>  	 * are scanned.
>  	 */
>  	nodemask_t	*nodemask;
> +
> +	int priority;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -2380,6 +2382,201 @@ out:
>  	return sc.nr_reclaimed;
>  }
>  

Because you write all codes below, I don't think merging with kswapd is
not necessary..


> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * TODO: the same function is used for global LRU and memcg LRU. For global
> + * LRU, the kswapd is done until all this node's zones are at
> + * high_wmark_pages(zone) or zone->all_unreclaimable.
> + */
> +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> +					struct scan_control *sc)
> +{
> +	int i, end_zone;
> +	unsigned long total_scanned;
> +	struct mem_cgroup *mem_cont = sc->mem_cgroup;
> +	int priority = sc->priority;
> +	int nid = pgdat->node_id;
> +
> +	/*
> +	 * Scan in the highmem->dma direction for the highest
> +	 * zone which needs scanning
> +	 */
> +	for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> +		struct zone *zone = pgdat->node_zones + i;
> +
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> +				priority != DEF_PRIORITY)
> +			continue;
> +		/*
> +		 * Do some background aging of the anon list, to give
> +		 * pages a chance to be referenced before reclaiming.
> +		 */
> +		if (inactive_anon_is_low(zone, sc))
> +			shrink_active_list(SWAP_CLUSTER_MAX, zone,
> +							sc, priority, 0);
> +
> +		end_zone = i;
> +		goto scan;
> +	}
> +	return;
> +
> +scan:
> +	total_scanned = 0;
> +	/*
> +	 * Now scan the zone in the dma->highmem direction, stopping
> +	 * at the last zone which needs scanning.
> +	 *
> +	 * We do this because the page allocator works in the opposite
> +	 * direction.  This prevents the page allocator from allocating
> +	 * pages behind kswapd's direction of progress, which would
> +	 * cause too much scanning of the lower zones.
> +	 */
> +	for (i = 0; i <= end_zone; i++) {
> +		struct zone *zone = pgdat->node_zones + i;
> +
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> +			priority != DEF_PRIORITY)
> +			continue;
> +
> +		sc->nr_scanned = 0;
> +		shrink_zone(priority, zone, sc);
> +		total_scanned += sc->nr_scanned;
> +
> +		if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
> +			continue;
> +
> +		if (!mem_cgroup_zone_reclaimable(mem_cont, nid, i))
> +			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
> +
> +		/*
> +		 * If we've done a decent amount of scanning and
> +		 * the reclaim ratio is low, start doing writepage
> +		 * even in laptop mode
> +		 */
> +		if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> +		    total_scanned > sc->nr_reclaimed + sc->nr_reclaimed / 2) {
> +			sc->may_writepage = 1;
> +		}
> +	}
> +
> +	sc->nr_scanned = total_scanned;
> +	return;
> +}
> +
> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> +					      int order)
> +{
> +	unsigned long total_scanned = 0;
> +	int i;
> +	int priority;
> +	int wmark_ok, nid;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +		/*
> +		 * kswapd doesn't want to be bailed out while reclaim. because
> +		 * we want to put equal scanning pressure on each zone.
> +		 * TODO: this might not be true for the memcg background
> +		 * reclaim.
> +		 */
> +		.nr_to_reclaim = ULONG_MAX,
> +		.swappiness = vm_swappiness,
> +		.order = order,
> +		.mem_cgroup = mem_cont,
> +	};
> +	DECLARE_BITMAP(do_nodes, MAX_NUMNODES);
> +
> +	/*
> +	 * bitmap to indicate which node to reclaim pages from. Initially we
> +	 * assume all nodes need reclaim.
> +	 */
> +	bitmap_fill(do_nodes, MAX_NUMNODES);
> +

Hmm..

> +loop_again:
> +	sc.may_writepage = !laptop_mode;
> +	sc.nr_reclaimed = 0;
> +	total_scanned = 0;
> +
> +	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +		sc.priority = priority;
> +
> +		/* The swap token gets in the way of swapout... */
> +		if (!priority)
> +			disable_swap_token();
> +
> +
> +		for_each_online_node(nid) {
> +			pg_data_t *pgdat = NODE_DATA(nid);
> +
> +			wmark_ok = 1;
> +
> +			if (!test_bit(nid, do_nodes))
> +				continue;
> +

Then, always start reclaim from node "0"....it's not good.

If using bitmap, could you add fairness among nodes ?

as:
  node = select_next_victim_node(mem);

This function will select the next scan node considering fairness
between nodes.
(Because memcg doesn't take care of NODE placement and just takes care of
 "amount", we don't know the best node to be reclaimed.)


> +			balance_pgdat_node(pgdat, order, &sc);
> +			total_scanned += sc.nr_scanned;
> +
> +			for (i = pgdat->nr_zones - 1; i >= 0; i++) {
> +				struct zone *zone = pgdat->node_zones + i;
> +
> +				if (!populated_zone(zone))
> +					continue;
> +
> +				if (!mem_cgroup_mz_unreclaimable(mem_cont,
> +								zone)) {
> +					__set_bit(nid, do_nodes);
> +					break;
> +				}
> +			}
> +
> +			if (i < 0)
> +				__clear_bit(nid, do_nodes);
> +
> +			if (!mem_cgroup_watermark_ok(sc.mem_cgroup,
> +							CHARGE_WMARK_HIGH))
> +				wmark_ok = 0;
> +
> +			if (wmark_ok) {
> +				goto out;
> +			}
> +		}
> +
> +		if (wmark_ok)
> +			break;
> +
> +		if (total_scanned && priority < DEF_PRIORITY - 2)
> +			congestion_wait(WRITE, HZ/10);
> +
> +		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> +			break;
> +	}
> +
> +out:
> +	if (!wmark_ok) {
> +		cond_resched();
> +
> +		try_to_freeze();
> +
> +		goto loop_again;
> +	}
> +
> +	return sc.nr_reclaimed;
> +}
> +#else
> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> +							int order)
> +{
> +	return 0;
> +}
> +#endif
> +
>  /*
>   * The background pageout daemon, started as a kernel thread
>   * from the init process.
> @@ -2497,8 +2694,12 @@ int kswapd(void *p)
>  		 * after returning from the refrigerator
>  		 */
>  		if (!ret) {
> -			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> -			balance_pgdat(pgdat, order);
> +			if (pgdat) {
> +				trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> +								order);
> +				balance_pgdat(pgdat, order);
> +			} else
> +				balance_mem_cgroup_pgdat(mem, order);

mem_cgroup's order is always 0.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
