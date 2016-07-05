Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6716B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 02:23:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so430789656pfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 23:23:53 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 69si2460935pfr.155.2016.07.04.23.23.51
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 23:23:52 -0700 (PDT)
Date: Tue, 5 Jul 2016 15:24:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 12/31] mm, vmscan: make shrink_node decisions more
 node-centric
Message-ID: <20160705062436.GE28164@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-13-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1467403299-25786-13-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:20PM +0100, Mel Gorman wrote:
> Earlier patches focused on having direct reclaim and kswapd use data that
> is node-centric for reclaiming but shrink_node() itself still uses too
> much zone information.  This patch removes unnecessary zone-based
> information with the most important decision being whether to continue
> reclaim or not.  Some memcg APIs are adjusted as a result even though
> memcg itself still uses some zone information.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/memcontrol.h | 19 ++++++++--------
>  include/linux/mmzone.h     |  4 ++--
>  include/linux/swap.h       |  2 +-
>  mm/memcontrol.c            |  4 ++--
>  mm/page_alloc.c            |  2 +-
>  mm/vmscan.c                | 57 ++++++++++++++++++++++++++--------------------
>  mm/workingset.c            |  6 ++---
>  7 files changed, 51 insertions(+), 43 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1927dcb6921e..48b43c709ed7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -325,22 +325,23 @@ mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
>  }
>  
>  /**
> - * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
> + * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
> + * @node: node of the wanted lruvec
>   * @zone: zone of the wanted lruvec
>   * @memcg: memcg of the wanted lruvec
>   *
> - * Returns the lru list vector holding pages for the given @zone and
> - * @mem.  This can be the global zone lruvec, if the memory controller
> + * Returns the lru list vector holding pages for a given @node or a given
> + * @memcg and @zone. This can be the node lruvec, if the memory controller
>   * is disabled.
>   */
> -static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> -						    struct mem_cgroup *memcg)
> +static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
> +				struct zone *zone, struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup_per_zone *mz;
>  	struct lruvec *lruvec;
>  
>  	if (mem_cgroup_disabled()) {
> -		lruvec = zone_lruvec(zone);
> +		lruvec = node_lruvec(pgdat);
>  		goto out;
>  	}
>  
> @@ -610,10 +611,10 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
>  {
>  }
>  
> -static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> -						    struct mem_cgroup *memcg)
> +static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
> +				struct zone *zone, struct mem_cgroup *memcg)
>  {
> -	return zone_lruvec(zone);
> +	return node_lruvec(pgdat);
>  }
>  
>  static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index eb74e63df5cf..f88cbbb476c8 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -739,9 +739,9 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
>  	return &zone->zone_pgdat->lru_lock;
>  }
>  
> -static inline struct lruvec *zone_lruvec(struct zone *zone)
> +static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
>  {
> -	return &zone->zone_pgdat->lruvec;
> +	return &pgdat->lruvec;
>  }
>  
>  static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 916e2eddecd6..0ad616d7c381 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -316,7 +316,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  						  unsigned long nr_pages,
>  						  gfp_t gfp_mask,
>  						  bool may_swap);
> -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> +extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
>  						struct zone *zone,
>  						unsigned long *nr_scanned);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 50c86ad121bc..c9ebec98e92a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1432,8 +1432,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
>  			}
>  			continue;
>  		}
> -		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
> -						     zone, &nr_scanned);
> +		total += mem_cgroup_shrink_node(victim, gfp_mask, false,
> +					zone, &nr_scanned);
>  		*total_scanned += nr_scanned;
>  		if (!soft_limit_excess(root_memcg))
>  			break;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f58548139bf2..b76ea2527c09 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5954,6 +5954,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  #endif
>  	pgdat_page_ext_init(pgdat);
>  	spin_lock_init(&pgdat->lru_lock);
> +	lruvec_init(node_lruvec(pgdat));
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
> @@ -6016,7 +6017,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		/* For bootup, initialized properly in watermark setup */
>  		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
>  
> -		lruvec_init(zone_lruvec(zone));
>  		if (!size)
>  			continue;
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2f898ba2ee2e..b8e0f76b6e00 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2226,10 +2226,11 @@ static inline void init_tlb_ubc(void)
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
         
                      per-node freer

trivial:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
