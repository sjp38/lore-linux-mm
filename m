Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF906B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:25:05 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4361556eei.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:25:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si59115513een.74.2014.04.22.03.25.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:25:03 -0700 (PDT)
Date: Tue, 22 Apr 2014 12:25:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-page_alloc-do-not-cache-reclaim-distances.patch added to
 -mm tree
Message-ID: <20140422102500.GG29311@dhcp22.suse.cz>
References: <535185ce.+shpjTaPUTpb3Ija%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535185ce.+shpjTaPUTpb3Ija%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, zhangyanfei@cn.fujitsu.com, hannes@cmpxchg.org, mgorman@suse.de, linux-mm@kvack.org

On Fri 18-04-14 13:06:38, Andrew Morton wrote:
> From: Mel Gorman <mgorman@suse.de>
> Subject: mm: page_alloc: do not cache reclaim distances
> 
> pgdat->reclaim_nodes tracks if a remote node is allowed to be reclaimed by
> zone_reclaim due to its distance. As it is expected that zone_reclaim_mode
> will be rarely enabled it is unreasonable for all machines to take a penalty.
> Fortunately, the zone_reclaim_mode() path is already slow and it is the path
> that takes the hit.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/mmzone.h |    1 -
>  mm/page_alloc.c        |   15 ++-------------
>  2 files changed, 2 insertions(+), 14 deletions(-)
> 
> diff -puN include/linux/mmzone.h~mm-page_alloc-do-not-cache-reclaim-distances include/linux/mmzone.h
> --- a/include/linux/mmzone.h~mm-page_alloc-do-not-cache-reclaim-distances
> +++ a/include/linux/mmzone.h
> @@ -763,7 +763,6 @@ typedef struct pglist_data {
>  	unsigned long node_spanned_pages; /* total size of physical page
>  					     range, including holes */
>  	int node_id;
> -	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
>  	wait_queue_head_t kswapd_wait;
>  	wait_queue_head_t pfmemalloc_wait;
>  	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
> diff -puN mm/page_alloc.c~mm-page_alloc-do-not-cache-reclaim-distances mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-page_alloc-do-not-cache-reclaim-distances
> +++ a/mm/page_alloc.c
> @@ -1850,16 +1850,8 @@ static bool zone_local(struct zone *loca
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
> -	for_each_node_state(i, N_MEMORY)
> -		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> -			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> +	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
> +				RECLAIM_DISTANCE;

It is not clear to me why we do not have to care about memory less
nodes in zone_allows_reclaim anymore. Those were excluded during the
initialization previously but we can consider them now if they are in
the zonelist. I have seen such memoryless nodes only on ppc and the
distance was > RECLAIM_DISTANCE so it is probably not a problem, but who
knows what will come later and a comment wouldn't hurt.

>  }
>  
>  #else	/* CONFIG_NUMA */
> @@ -1893,9 +1885,6 @@ static bool zone_allows_reclaim(struct z
>  	return true;
>  }
>  
> -static inline void init_zone_allows_reclaim(int nid)
> -{
> -}
>  #endif	/* CONFIG_NUMA */
>  
>  /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
