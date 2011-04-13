Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFAF900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 05:05:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BF0F63EE0BD
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:05:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1A2945DE73
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:05:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 74CB145DE6D
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:05:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EE58E18009
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:05:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E651DB803E
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:05:17 +0900 (JST)
Date: Wed, 13 Apr 2011 17:58:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 5/7] Per-memcg background reclaim.
Message-Id: <20110413175842.36938786.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302678187-24154-6-git-send-email-yinghan@google.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-6-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 13 Apr 2011 00:03:05 -0700
Ying Han <yinghan@google.com> wrote:

> This is the main loop of per-memcg background reclaim which is implemented in
> function balance_mem_cgroup_pgdat().
> 
> The function performs a priority loop similar to global reclaim. During each
> iteration it invokes balance_pgdat_node() for all nodes on the system, which
> is another new function performs background reclaim per node. A fairness
> mechanism is implemented to remember the last node it was reclaiming from and
> always start at the next one. After reclaiming each node, it checks
> mem_cgroup_watermark_ok() and breaks the priority loop if it returns true. The
> per-memcg zone will be marked as "unreclaimable" if the scanning rate is much
> greater than the reclaiming rate on the per-memcg LRU. The bit is cleared when
> there is a page charged to the memcg being freed. Kswapd breaks the priority
> loop if all the zones are marked as "unreclaimable".
> 

Hmm, bigger than expected. I'm glad if you can divide this into small pieces.
see below.


> changelog v3..v2:
> 1. change mz->all_unreclaimable to be boolean.
> 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg reclaim.
> 3. some more clean-up.
> 
> changelog v2..v1:
> 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> reclaim.
> 3. name the per-memcg memcg as "memcg-id" (css->id). And the global kswapd
> keeps the same name.
> 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be accessed
> after freeing.
> 5. add the fairness in zonelist where memcg remember the last zone reclaimed
> from.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/memcontrol.h |   33 +++++++
>  include/linux/swap.h       |    2 +
>  mm/memcontrol.c            |  136 +++++++++++++++++++++++++++++
>  mm/vmscan.c                |  208 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 379 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f7ffd1f..a8159f5 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
>  				  struct kswapd *kswapd_p);
>  extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
>  extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
> +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> +					const nodemask_t *nodes);
>  
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> @@ -152,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page);
> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
> +				unsigned long nr_scanned);
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
> @@ -342,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
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
> @@ -360,6 +388,11 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
>  {
>  }
>  
> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
> +								int zid)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 17e0511..319b800 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -160,6 +160,8 @@ enum {
>  	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
>  };
>  
> +#define ZONE_RECLAIMABLE_RATE 6
> +
>  #define SWAP_CLUSTER_MAX 32
>  #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index acd84a8..efeade3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {
>  	bool			on_tree;
>  	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
>  						/* use container_of	   */
> +	unsigned long		pages_scanned;	/* since last reclaim */
> +	bool			all_unreclaimable;	/* All pages pinned */
>  };
> +
>  /* Macro for accessing counter */
>  #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
>  
> @@ -275,6 +278,11 @@ struct mem_cgroup {
>  
>  	int wmark_ratio;
>  
> +	/* While doing per cgroup background reclaim, we cache the
> +	 * last node we reclaimed from
> +	 */
> +	int last_scanned_node;
> +
>  	wait_queue_head_t *kswapd_wait;
>  };
>  
> @@ -1129,6 +1137,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return &mz->reclaim_stat;
>  }
>  
> +static unsigned long mem_cgroup_zone_reclaimable_pages(
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
> +				mem_cgroup_zone_reclaimable_pages(mz) *
> +				ZONE_RECLAIMABLE_RATE;
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
> +		return false;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz)
> +		return mz->all_unreclaimable;
> +
> +	return false;
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
> +		mz->all_unreclaimable = true;
> +}
> +
> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +
> +	if (!mem)
> +		return;
> +
> +	mz = page_cgroup_zoneinfo(mem, page);
> +	if (mz) {
> +		mz->pages_scanned = 0;
> +		mz->all_unreclaimable = false;
> +	}
> +
> +	return;
> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> @@ -1545,6 +1643,32 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  }
>  
>  /*
> + * Visit the first node after the last_scanned_node of @mem and use that to
> + * reclaim free pages from.
> + */
> +int
> +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *nodes)
> +{
> +	int next_nid;
> +	int last_scanned;
> +
> +	last_scanned = mem->last_scanned_node;
> +
> +	/* Initial stage and start from node0 */
> +	if (last_scanned == -1)
> +		next_nid = 0;
> +	else
> +		next_nid = next_node(last_scanned, *nodes);
> +
> +	if (next_nid == MAX_NUMNODES)
> +		next_nid = first_node(*nodes);
> +
> +	mem->last_scanned_node = next_nid;
> +
> +	return next_nid;
> +}
> +
> +/*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
>   */
> @@ -2779,6 +2903,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	 * special functions.
>  	 */
>  
> +	mem_cgroup_clear_unreclaimable(mem, page);

Hmm, do we this always at uncharge ? 

I doubt we really need mz->all_unreclaimable ....

Anyway, I'd like to see this all_unreclaimable logic in an independet patch.
Because direct-relcaim pass should see this, too.

So, could you devide this pieces into

1. record last node .... I wonder this logic should be used in direct-reclaim pass, too.
                        
2. all_unreclaimable .... direct reclaim will be affected, too.

3. scanning core.



>  	unlock_page_cgroup(pc);
>  	/*
>  	 * even after unlock, we have mem->res.usage here and this memcg
> @@ -4501,6 +4626,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  		mz->usage_in_excess = 0;
>  		mz->on_tree = false;
>  		mz->mem = mem;
> +		mz->pages_scanned = 0;
> +		mz->all_unreclaimable = false;
>  	}
>  	return 0;
>  }
> @@ -4651,6 +4778,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
>  	return mem->kswapd_wait;
>  }
>  
> +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
> +{
> +	if (!mem)
> +		return -1;
> +
> +	return mem->last_scanned_node;
> +}
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
> @@ -4726,6 +4861,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		res_counter_init(&mem->memsw, NULL);
>  	}
>  	mem->last_scanned_child = 0;
> +	mem->last_scanned_node = -1;
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
>  	if (parent)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a1a1211..6571eb8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -47,6 +47,8 @@
>  
>  #include <linux/swapops.h>
>  
> +#include <linux/res_counter.h>
> +
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -111,6 +113,8 @@ struct scan_control {
>  	 * are scanned.
>  	 */
>  	nodemask_t	*nodemask;
> +
> +	int priority;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -1410,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, sc->mem_cgroup,
>  			0, file);
> +
> +		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
> +
>  		/*
>  		 * mem_cgroup_isolate_pages() keeps track of
>  		 * scanned pages on its own.
> @@ -1529,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  		 * mem_cgroup_isolate_pages() keeps track of
>  		 * scanned pages on its own.
>  		 */
> +		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
>  	}
>  
>  	reclaim_stat->recent_scanned[file] += nr_taken;
> @@ -2632,11 +2640,211 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
>  	finish_wait(wait_h, &wait);
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * The function is used for per-memcg LRU. It scanns all the zones of the
> + * node and returns the nr_scanned and nr_reclaimed.
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

I don't want to see zone balancing logic in memcg.
It should be a work of global lru.

IOW, even if we remove global LRU finally, we should
implement zone balancing logic in _global_ (per node) kswapd.
(kswapd can pass zone mask to each memcg.)

If you want some clever logic for memcg specail, I think it should be
deteciting 'which node should be victim' logic rather than round-robin.
(But yes, starting from easy round robin makes sense.)

So, could you add more simple one ?

  do {
    select victim node
    do reclaim
  } while (need_stop)

zone balancing should be done other than memcg.

what we really need to improve is 'select victim node'.

Thanks,
-Kame


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
> +/*
> + * Per cgroup background reclaim.
> + * TODO: Take off the order since memcg always do order 0
> + */
> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> +					      int order)
> +{
> +	int i, nid;
> +	int start_node;
> +	int priority;
> +	bool wmark_ok;
> +	int loop;
> +	pg_data_t *pgdat;
> +	nodemask_t do_nodes;
> +	unsigned long total_scanned;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +		.nr_to_reclaim = ULONG_MAX,
> +		.swappiness = vm_swappiness,
> +		.order = order,
> +		.mem_cgroup = mem_cont,
> +	};
> +
> +loop_again:
> +	do_nodes = NODE_MASK_NONE;
> +	sc.may_writepage = !laptop_mode;
> +	sc.nr_reclaimed = 0;
> +	total_scanned = 0;
> +
> +	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +		sc.priority = priority;
> +		wmark_ok = false;
> +		loop = 0;
> +
> +		/* The swap token gets in the way of swapout... */
> +		if (!priority)
> +			disable_swap_token();
> +
> +		if (priority == DEF_PRIORITY)
> +			do_nodes = node_states[N_ONLINE];
> +
> +		while (1) {
> +			nid = mem_cgroup_select_victim_node(mem_cont,
> +							&do_nodes);
> +
> +			/* Indicate we have cycled the nodelist once
> +			 * TODO: we might add MAX_RECLAIM_LOOP for preventing
> +			 * kswapd burning cpu cycles.
> +			 */
> +			if (loop == 0) {
> +				start_node = nid;
> +				loop++;
> +			} else if (nid == start_node)
> +				break;
> +
> +			pgdat = NODE_DATA(nid);
> +			balance_pgdat_node(pgdat, order, &sc);
> +			total_scanned += sc.nr_scanned;
> +
> +			/* Set the node which has at least
> +			 * one reclaimable zone
> +			 */
> +			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> +				struct zone *zone = pgdat->node_zones + i;
> +
> +				if (!populated_zone(zone))
> +					continue;
> +
> +				if (!mem_cgroup_mz_unreclaimable(mem_cont,
> +								zone))
> +					break;
> +			}
> +			if (i < 0)
> +				node_clear(nid, do_nodes);
> +
> +			if (mem_cgroup_watermark_ok(mem_cont,
> +							CHARGE_WMARK_HIGH)) {
> +				wmark_ok = true;
> +				goto out;
> +			}
> +
> +			if (nodes_empty(do_nodes)) {
> +				wmark_ok = true;
> +				goto out;
> +			}
> +		}
> +
> +		/* All the nodes are unreclaimable, kswapd is done */
> +		if (nodes_empty(do_nodes)) {
> +			wmark_ok = true;
> +			goto out;
> +		}
> +
> +		if (total_scanned && priority < DEF_PRIORITY - 2)
> +			congestion_wait(WRITE, HZ/10);
> +
> +		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> +			break;
> +	}
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
>  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
>  							int order)
>  {
>  	return 0;
>  }
> +#endif
>  
>  /*
>   * The background pageout daemon, started as a kernel thread
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
