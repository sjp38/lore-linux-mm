Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9476B0055
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 23:55:10 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so416300pbc.13
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:55:10 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ub3si215811pac.153.2014.04.07.18.19.04
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 18:19:06 -0700 (PDT)
Message-ID: <53434E41.1010306@cn.fujitsu.com>
Date: Tue, 8 Apr 2014 09:17:53 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page_alloc: Do not cache reclaim distances
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <1396910068-11637-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1396910068-11637-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2014 06:34 AM, Mel Gorman wrote:
> pgdat->reclaim_nodes tracks if a remote node is allowed to be reclaimed by
> zone_reclaim due to its distance. As it is expected that zone_reclaim_mode
> will be rarely enabled it is unreasonable for all machines to take a penalty.
> Fortunately, the zone_reclaim_mode() path is already slow and it is the path
> that takes the hit.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  include/linux/mmzone.h |  1 -
>  mm/page_alloc.c        | 15 +--------------
>  2 files changed, 1 insertion(+), 15 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 9b61b9b..564b169 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -757,7 +757,6 @@ typedef struct pglist_data {
>  	unsigned long node_spanned_pages; /* total size of physical page
>  					     range, including holes */
>  	int node_id;
> -	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
>  	wait_queue_head_t kswapd_wait;
>  	wait_queue_head_t pfmemalloc_wait;
>  	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a256f85..574928e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1863,16 +1863,7 @@ static bool zone_local(struct zone *local_zone, struct zone *zone)
>  
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  {
> -	return node_isset(local_zone->node, zone->zone_pgdat->reclaim_nodes);
> -}
> -
> -static void __paginginit init_zone_allows_reclaim(int nid)
> -{
> -	int i;
> -
> -	for_each_online_node(i)
> -		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> -			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> +	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) < RECLAIM_DISTANCE;
>  }
>  
>  #else	/* CONFIG_NUMA */
> @@ -1906,9 +1897,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  	return true;
>  }
>  
> -static inline void init_zone_allows_reclaim(int nid)
> -{
> -}
>  #endif	/* CONFIG_NUMA */
>  
>  /*
> @@ -4917,7 +4905,6 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  
>  	pgdat->node_id = nid;
>  	pgdat->node_start_pfn = node_start_pfn;
> -	init_zone_allows_reclaim(nid);
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
>  #endif
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
