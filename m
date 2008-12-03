Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mB3DwDVq028862
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:28:13 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3DwEcC4141192
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:28:14 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id mB3DwDZI017769
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 00:58:13 +1100
Date: Wed, 3 Dec 2008 19:28:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 07/11] memcg: make mem_cgroup_zone_nr_pages()
Message-ID: <20081203135811.GF17701@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211545.1CDF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081201211545.1CDF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2008-12-01 21:16:48]:

> introduce mem_cgroup_zone_nr_pages().
> it is called by zone_nr_pages() helper function.
> 
> 
> this patch doesn't have any behavior change.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   11 +++++++++++
>  mm/memcontrol.c            |   12 +++++++++++-
>  mm/vmscan.c                |    3 +++
>  3 files changed, 25 insertions(+), 1 deletion(-)
> 
> Index: b/include/linux/memcontrol.h
> ===================================================================
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -92,6 +92,9 @@ extern long mem_cgroup_calc_reclaim(stru
>  					int priority, enum lru_list lru);
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
>  				    struct zone *zone);
> +unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> +				       struct zone *zone,
> +				       enum lru_list lru);
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> @@ -250,6 +253,14 @@ mem_cgroup_inactive_anon_is_low(struct m
>  	return 1;
>  }
> 
> +static inline unsigned long
> +mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> +			 enum lru_list lru)
> +{
> +	return 0;
> +}
> +
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -186,7 +186,6 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>  	0, /* FORCE */
>  };
> 
> -
>  /* for encoding cft->private value on file */
>  #define _MEM			(0)
>  #define _MEMSWAP		(1)
> @@ -448,6 +447,17 @@ int mem_cgroup_inactive_anon_is_low(stru
>  	return 0;
>  }
> 
> +unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> +				       struct zone *zone,
> +				       enum lru_list lru)
> +{
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +
> +	return MEM_CGROUP_ZSTAT(mz, lru);
> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -140,6 +140,9 @@ static struct zone_reclaim_stat *get_rec
>  static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
>  				   enum lru_list lru)
>  {
> +	if (!scan_global_lru(sc))
> +		return mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone, lru);
> +
>  	return zone_page_state(zone, NR_LRU_BASE + lru);
>  }
>

Seems reasonable

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
