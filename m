Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 25D586B0039
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:57:27 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so3179170wes.3
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:57:25 -0700 (PDT)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id z7si9067938wiu.91.2014.07.17.06.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 06:57:24 -0700 (PDT)
Received: by mail-we0-f175.google.com with SMTP id t60so3153428wes.34
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:57:23 -0700 (PDT)
Date: Thu, 17 Jul 2014 15:57:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
Message-ID: <20140717135721.GC8011@dhcp22.suse.cz>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
 <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141240200.17669@eggly.anvils>
 <20140717132604.GF29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140717132604.GF29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 17-07-14 09:26:04, Johannes Weiner wrote:
> From bbe8c1645c77297a96ecd5d64d659ddcd6984d03 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 14 Jul 2014 08:51:54 -0400
> Subject: [patch] mm: vmscan: clean up struct scan_control
> 
> Reorder the members by input and output, then turn the individual
> integers for may_writepage, may_unmap, may_swap, compaction_ready,
> hibernation_mode into bit fields to save stack space:
> 
> +72/-296 -224
> kswapd                                       104     176     +72
> try_to_free_pages                             80      56     -24
> try_to_free_mem_cgroup_pages                  80      56     -24
> shrink_all_memory                             88      64     -24
> reclaim_clean_pages_from_list                168     144     -24
> mem_cgroup_shrink_node_zone                  104      80     -24
> __zone_reclaim                               176     152     -24
> balance_pgdat                                152       -    -152
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks nice to me.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/vmscan.c | 99 ++++++++++++++++++++++++++++---------------------------------
>  1 file changed, 46 insertions(+), 53 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c28b8981e56a..81dd858b9d17 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -59,35 +59,20 @@
>  #include <trace/events/vmscan.h>
>  
>  struct scan_control {
> -	/* Incremented by the number of inactive pages that were scanned */
> -	unsigned long nr_scanned;
> -
> -	/* Number of pages freed so far during a call to shrink_zones() */
> -	unsigned long nr_reclaimed;
> -
> -	/* One of the zones is ready for compaction */
> -	int compaction_ready;
> -
>  	/* How many pages shrink_list() should reclaim */
>  	unsigned long nr_to_reclaim;
>  
> -	unsigned long hibernation_mode;
> -
>  	/* This context's GFP mask */
>  	gfp_t gfp_mask;
>  
> -	int may_writepage;
> -
> -	/* Can mapped pages be reclaimed? */
> -	int may_unmap;
> -
> -	/* Can pages be swapped as part of reclaim? */
> -	int may_swap;
> -
> +	/* Allocation order */
>  	int order;
>  
> -	/* Scan (total_size >> priority) pages at once */
> -	int priority;
> +	/*
> +	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> +	 * are scanned.
> +	 */
> +	nodemask_t	*nodemask;
>  
>  	/*
>  	 * The memory cgroup that hit its limit and as a result is the
> @@ -95,11 +80,27 @@ struct scan_control {
>  	 */
>  	struct mem_cgroup *target_mem_cgroup;
>  
> -	/*
> -	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> -	 * are scanned.
> -	 */
> -	nodemask_t	*nodemask;
> +	/* Scan (total_size >> priority) pages at once */
> +	int priority;
> +
> +	unsigned int may_writepage:1;
> +
> +	/* Can mapped pages be reclaimed? */
> +	unsigned int may_unmap:1;
> +
> +	/* Can pages be swapped as part of reclaim? */
> +	unsigned int may_swap:1;
> +
> +	unsigned int hibernation_mode:1;
> +
> +	/* One of the zones is ready for compaction */
> +	unsigned int compaction_ready:1;
> +
> +	/* Incremented by the number of inactive pages that were scanned */
> +	unsigned long nr_scanned;
> +
> +	/* Number of pages freed so far during a call to shrink_zones() */
> +	unsigned long nr_reclaimed;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -2668,15 +2669,14 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  {
>  	unsigned long nr_reclaimed;
>  	struct scan_control sc = {
> +		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
> +		.order = order,
> +		.nodemask = nodemask,
> +		.priority = DEF_PRIORITY,
>  		.may_writepage = !laptop_mode,
> -		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.may_unmap = 1,
>  		.may_swap = 1,
> -		.order = order,
> -		.priority = DEF_PRIORITY,
> -		.target_mem_cgroup = NULL,
> -		.nodemask = nodemask,
>  	};
>  
>  	/*
> @@ -2706,14 +2706,11 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
>  						unsigned long *nr_scanned)
>  {
>  	struct scan_control sc = {
> -		.nr_scanned = 0,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> +		.target_mem_cgroup = memcg,
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
> -		.order = 0,
> -		.priority = 0,
> -		.target_mem_cgroup = memcg,
>  	};
>  	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  	int swappiness = mem_cgroup_swappiness(memcg);
> @@ -2748,16 +2745,14 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	unsigned long nr_reclaimed;
>  	int nid;
>  	struct scan_control sc = {
> -		.may_writepage = !laptop_mode,
> -		.may_unmap = 1,
> -		.may_swap = !noswap,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.order = 0,
> -		.priority = DEF_PRIORITY,
> -		.target_mem_cgroup = memcg,
> -		.nodemask = NULL, /* we don't care the placement */
>  		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
> +		.target_mem_cgroup = memcg,
> +		.priority = DEF_PRIORITY,
> +		.may_writepage = !laptop_mode,
> +		.may_unmap = 1,
> +		.may_swap = !noswap,
>  	};
>  
>  	/*
> @@ -3015,12 +3010,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  	unsigned long nr_soft_scanned;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
> +		.order = order,
>  		.priority = DEF_PRIORITY,
> +		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = 1,
> -		.may_writepage = !laptop_mode,
> -		.order = order,
> -		.target_mem_cgroup = NULL,
>  	};
>  	count_vm_event(PAGEOUTRUN);
>  
> @@ -3401,14 +3395,13 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  {
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> +		.nr_to_reclaim = nr_to_reclaim,
>  		.gfp_mask = GFP_HIGHUSER_MOVABLE,
> -		.may_swap = 1,
> -		.may_unmap = 1,
> +		.priority = DEF_PRIORITY,
>  		.may_writepage = 1,
> -		.nr_to_reclaim = nr_to_reclaim,
> +		.may_unmap = 1,
> +		.may_swap = 1,
>  		.hibernation_mode = 1,
> -		.order = 0,
> -		.priority = DEF_PRIORITY,
>  	};
>  	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
>  	struct task_struct *p = current;
> @@ -3588,13 +3581,13 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> -		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> -		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> -		.may_swap = 1,
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
>  		.order = order,
>  		.priority = ZONE_RECLAIM_PRIORITY,
> +		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> +		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> +		.may_swap = 1,
>  	};
>  	struct shrink_control shrink = {
>  		.gfp_mask = sc.gfp_mask,
> -- 
> 2.0.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
