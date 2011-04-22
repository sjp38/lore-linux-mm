Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2188D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:13:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EF9D43EE0BD
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:13:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C156945DF18
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:13:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7BFD45DF13
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:13:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 979CEE18005
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:13:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AAA51DB803C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:13:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 8/9] Add per-memcg zone "unreclaimable"
In-Reply-To: <1303446260-21333-9-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com> <1303446260-21333-9-git-send-email-yinghan@google.com>
Message-Id: <20110422151420.FA72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 15:13:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 98fc7ed..3370c5a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1526,6 +1526,7 @@ struct task_struct {
>  		struct mem_cgroup *memcg; /* target memcg of uncharge */
>  		unsigned long nr_pages;	/* uncharged usage */
>  		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
> +		struct zone *zone; /* a zone page is last uncharged */

"zone" is bad name for task_struct. :-/


>  	} memcg_batch;
>  #endif
>  };
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a062f0b..b868e597 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -159,6 +159,8 @@ enum {
>  	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
>  };
>  
> +#define ZONE_RECLAIMABLE_RATE 6
> +

Need comment?


>  #define SWAP_CLUSTER_MAX 32
>  #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 41eaa62..9e535b2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -135,7 +135,10 @@ struct mem_cgroup_per_zone {
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
> @@ -1162,6 +1165,103 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return &mz->reclaim_stat;
>  }
>  
> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone *zone,
> +						unsigned long nr_scanned)

this names sound like pages_scanned value getting helper function.


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
> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone *zone)
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
> +		return mz->pages_scanned <
> +				mem_cgroup_zone_reclaimable_pages(mem, zone) *
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
> +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
> +				       struct zone *zone)
> +{
> +	struct mem_cgroup_per_zone *mz = NULL;
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
> +	if (!mem)
> +		return;
> +
> +	mz = mem_cgroup_zoneinfo(mem, nid, zid);
> +	if (mz) {
> +		mz->pages_scanned = 0;
> +		mz->all_unreclaimable = false;
> +	}
> +
> +	return;
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
> @@ -2709,6 +2809,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
>  
>  static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
>  				   unsigned int nr_pages,
> +				   struct page *page,
>  				   const enum charge_type ctype)
>  {
>  	struct memcg_batch_info *batch = NULL;
> @@ -2726,6 +2827,10 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
>  	 */
>  	if (!batch->memcg)
>  		batch->memcg = mem;
> +
> +	if (!batch->zone)
> +		batch->zone = page_zone(page);
> +
>  	/*
>  	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
>  	 * In those cases, all pages freed continously can be expected to be in
> @@ -2747,12 +2852,17 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
>  	 */
>  	if (batch->memcg != mem)
>  		goto direct_uncharge;
> +
> +	if (batch->zone != page_zone(page))
> +		mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
> +
>  	/* remember freed charge and uncharge it later */
>  	batch->nr_pages++;
>  	if (uncharge_memsw)
>  		batch->memsw_nr_pages++;
>  	return;
>  direct_uncharge:
> +	mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
>  	res_counter_uncharge(&mem->res, nr_pages * PAGE_SIZE);
>  	if (uncharge_memsw)
>  		res_counter_uncharge(&mem->memsw, nr_pages * PAGE_SIZE);
> @@ -2834,7 +2944,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  		mem_cgroup_get(mem);
>  	}
>  	if (!mem_cgroup_is_root(mem))
> -		mem_cgroup_do_uncharge(mem, nr_pages, ctype);
> +		mem_cgroup_do_uncharge(mem, nr_pages, page, ctype);
>  
>  	return mem;
>  
> @@ -2902,6 +3012,10 @@ void mem_cgroup_uncharge_end(void)
>  	if (batch->memsw_nr_pages)
>  		res_counter_uncharge(&batch->memcg->memsw,
>  				     batch->memsw_nr_pages * PAGE_SIZE);
> +	if (batch->zone)
> +		mem_cgroup_mz_clear_unreclaimable(batch->memcg, batch->zone);
> +	batch->zone = NULL;
> +
>  	memcg_oom_recover(batch->memcg);
>  	/* forget this pointer (for sanity check) */
>  	batch->memcg = NULL;
> @@ -4667,6 +4781,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  		mz->usage_in_excess = 0;
>  		mz->on_tree = false;
>  		mz->mem = mem;
> +		mz->pages_scanned = 0;
> +		mz->all_unreclaimable = false;
>  	}
>  	return 0;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ba03a10..87653d6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, sc->mem_cgroup,
>  			0, file);
> +
> +		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
> +
>  		/*
>  		 * mem_cgroup_isolate_pages() keeps track of
>  		 * scanned pages on its own.
> @@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  		 * mem_cgroup_isolate_pages() keeps track of
>  		 * scanned pages on its own.
>  		 */
> +		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
>  	}
>  
>  	reclaim_stat->recent_scanned[file] += nr_taken;
> @@ -1989,7 +1993,8 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  
>  static bool zone_reclaimable(struct zone *zone)
>  {
> -	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> +	return zone->pages_scanned < zone_reclaimable_pages(zone) *
> +					ZONE_RECLAIMABLE_RATE;
>  }
>  
>  /*
> @@ -2651,10 +2656,20 @@ static void shrink_memcg_node(pg_data_t *pgdat, int order,
>  		if (!scan)
>  			continue;
>  
> +		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> +			priority != DEF_PRIORITY)
> +			continue;
> +
>  		sc->nr_scanned = 0;
>  		shrink_zone(priority, zone, sc);
>  		total_scanned += sc->nr_scanned;
>  
> +		if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
> +			continue;
> +
> +		if (!mem_cgroup_zone_reclaimable(mem_cont, zone))
> +			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
> +
>  		/*
>  		 * If we've done a decent amount of scanning and
>  		 * the reclaim ratio is low, start doing writepage
> @@ -2716,10 +2731,16 @@ static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
>  			shrink_memcg_node(pgdat, order, &sc);
>  			total_scanned += sc.nr_scanned;
>  
> +			/*
> +			 * Set the node which has at least one reclaimable
> +			 * zone
> +			 */
>  			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
>  				struct zone *zone = pgdat->node_zones + i;
>  
> -				if (populated_zone(zone))
> +				if (populated_zone(zone) &&
> +				    !mem_cgroup_mz_unreclaimable(mem_cont,
> +								zone))
>  					break;

global reclaim call shrink_zone() when priority==DEF_PRIORITY even if 
all_unreclaimable is set. Is this intentional change?
If so, please add some comments.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
