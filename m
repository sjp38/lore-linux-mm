Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id mB3E6wQ4020636
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:36:58 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3E6AdK4182200
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:36:10 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mB3E6vMf020705
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 01:06:57 +1100
Date: Wed, 3 Dec 2008 19:36:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/11] memcg: make zone_reclaim_stat
Message-ID: <20081203140655.GG17701@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211646.1CE2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081201211646.1CE2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2008-12-01 21:17:44]:

> introduce mem_cgroup_per_zone::reclaim_stat member and its statics collecting
> function.
> 
> Now, get_scan_ratio() can calculate correct value although memcg reclaim.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   16 ++++++++++++++++
>  mm/memcontrol.c            |   23 +++++++++++++++++++++++
>  mm/swap.c                  |   14 ++++++++++++++
>  mm/vmscan.c                |   27 +++++++++++++--------------
>  4 files changed, 66 insertions(+), 14 deletions(-)
> 
> Index: b/include/linux/memcontrol.h
> ===================================================================
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -95,6 +95,10 @@ int mem_cgroup_inactive_anon_is_low(stru
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>  				       struct zone *zone,
>  				       enum lru_list lru);
> +struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> +						      struct zone *zone);
> +struct zone_reclaim_stat*
> +mem_cgroup_get_reclaim_stat_by_page(struct page *page);
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> @@ -261,6 +265,18 @@ mem_cgroup_zone_nr_pages(struct mem_cgro
>  }
> 
> 
> +static inline struct zone_reclaim_stat*
> +mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	return NULL;
> +}
> +
> +static inline struct zone_reclaim_stat*
> +mem_cgroup_get_reclaim_stat_by_page(struct page *page)
> +{
> +	return NULL;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -103,6 +103,8 @@ struct mem_cgroup_per_zone {
>  	 */
>  	struct list_head	lists[NR_LRU_LISTS];
>  	unsigned long		count[NR_LRU_LISTS];
> +
> +	struct zone_reclaim_stat reclaim_stat;
>  };
>  /* Macro for accessing counter */
>  #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
> @@ -458,6 +460,27 @@ unsigned long mem_cgroup_zone_nr_pages(s
>  	return MEM_CGROUP_ZSTAT(mz, lru);
>  }
> 
> +struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> +						      struct zone *zone)
> +{
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +
> +	return &mz->reclaim_stat;
> +}
> +
> +struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat_by_page(struct page *page)
> +{

I would prefer to use stat_from_page instead of stat_by_page, by page
is confusing.

> +	struct page_cgroup *pc = lookup_page_cgroup(page);
> +	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> +
> +	if (!mz)
> +		return NULL;
> +
> +	return &mz->reclaim_stat;
> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> Index: b/mm/swap.c
> ===================================================================
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -158,6 +158,7 @@ void activate_page(struct page *page)
>  {
>  	struct zone *zone = page_zone(page);
>  	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
> +	struct zone_reclaim_stat *memcg_reclaim_stat;
> 
>  	spin_lock_irq(&zone->lru_lock);
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> @@ -172,6 +173,12 @@ void activate_page(struct page *page)
> 
>  		reclaim_stat->recent_rotated[!!file]++;
>  		reclaim_stat->recent_scanned[!!file]++;
> +
> +		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
> +		if (memcg_reclaim_stat) {
> +			memcg_reclaim_stat->recent_rotated[!!file]++;
> +			memcg_reclaim_stat->recent_scanned[!!file]++;
> +		}

Does it make sense to write two inline routines like

update_recent_rotated(page)
{
        zone = page_zone(page);

        zone->reclaim_stat->recent_rotated[!!file]++;
        mem_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
        if (mem_reclaim_stat)
                mem_cg_reclaim_stat->recent_rotated[!!file]++;
        ...

}

and similarly update_recent_reclaimed(page)

>  	}
>  	spin_unlock_irq(&zone->lru_lock);
>  }
> @@ -400,6 +407,7 @@ void ____pagevec_lru_add(struct pagevec 
>  	int i;
>  	struct zone *zone = NULL;
>  	struct zone_reclaim_stat *reclaim_stat = NULL;
> +	struct zone_reclaim_stat *memcg_reclaim_stat = NULL;
> 
>  	VM_BUG_ON(is_unevictable_lru(lru));
> 
> @@ -413,6 +421,8 @@ void ____pagevec_lru_add(struct pagevec 
>  				spin_unlock_irq(&zone->lru_lock);
>  			zone = pagezone;
>  			reclaim_stat = &zone->reclaim_stat;
> +			memcg_reclaim_stat =
> +				mem_cgroup_get_reclaim_stat_by_page(page);
>  			spin_lock_irq(&zone->lru_lock);
>  		}
>  		VM_BUG_ON(PageActive(page));
> @@ -421,9 +431,13 @@ void ____pagevec_lru_add(struct pagevec 
>  		SetPageLRU(page);
>  		file = is_file_lru(lru);
>  		reclaim_stat->recent_scanned[file]++;
> +		if (memcg_reclaim_stat)
> +			memcg_reclaim_stat->recent_scanned[file]++;
>  		if (is_active_lru(lru)) {
>  			SetPageActive(page);
>  			reclaim_stat->recent_rotated[file]++;
> +			if (memcg_reclaim_stat)
> +				memcg_reclaim_stat->recent_rotated[file]++;
>  		}
>  		add_page_to_lru_list(zone, page, lru);
>  	}
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -134,6 +134,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
>  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
>  						  struct scan_control *sc)
>  {
> +	if (!scan_global_lru(sc))
> +		mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);

What do we gain by just calling mem_cgroup_get_reclaim_stat? Where do
we return/use this value?

> +
>  	return &zone->reclaim_stat;
>  }
> 
> @@ -1141,17 +1144,14 @@ static unsigned long shrink_inactive_lis
>  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
>  						-count[LRU_INACTIVE_ANON]);
> 
> -		if (scan_global_lru(sc)) {
> +		if (scan_global_lru(sc))
>  			zone->pages_scanned += nr_scan;
> -			reclaim_stat->recent_scanned[0] +=
> -						      count[LRU_INACTIVE_ANON];
> -			reclaim_stat->recent_scanned[0] +=
> -						      count[LRU_ACTIVE_ANON];
> -			reclaim_stat->recent_scanned[1] +=
> -						      count[LRU_INACTIVE_FILE];
> -			reclaim_stat->recent_scanned[1] +=
> -						      count[LRU_ACTIVE_FILE];
> -		}
> +
> +		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
> +		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
> +		reclaim_stat->recent_scanned[1] += count[LRU_INACTIVE_FILE];
> +		reclaim_stat->recent_scanned[1] += count[LRU_ACTIVE_FILE];
> +
>  		spin_unlock_irq(&zone->lru_lock);
> 
>  		nr_scanned += nr_scan;
> @@ -1209,7 +1209,7 @@ static unsigned long shrink_inactive_lis
>  			SetPageLRU(page);
>  			lru = page_lru(page);
>  			add_page_to_lru_list(zone, page, lru);
> -			if (PageActive(page) && scan_global_lru(sc)) {
> +			if (PageActive(page)) {
>  				int file = !!page_is_file_cache(page);
>  				reclaim_stat->recent_rotated[file]++;
>  			}
> @@ -1289,8 +1289,8 @@ static void shrink_active_list(unsigned 
>  	 */
>  	if (scan_global_lru(sc)) {
>  		zone->pages_scanned += pgscanned;
> -		reclaim_stat->recent_scanned[!!file] += pgmoved;
>  	}
> +	reclaim_stat->recent_scanned[!!file] += pgmoved;
> 
>  	if (file)
>  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
> @@ -1323,8 +1323,7 @@ static void shrink_active_list(unsigned 
>  	 * This helps balance scan pressure between file and anonymous
>  	 * pages in get_scan_ratio.
>  	 */
> -	if (scan_global_lru(sc))
> -		reclaim_stat->recent_rotated[!!file] += pgmoved;
> +	reclaim_stat->recent_rotated[!!file] += pgmoved;
> 
>  	/*
>  	 * Move the pages to the [file or anon] inactive list.
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
