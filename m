Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFC46B02A4
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 00:49:22 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6M4jmwh016181
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:45:48 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6M4nHpc109760
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:49:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6M4nG3n018145
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:49:17 -0600
Date: Thu, 22 Jul 2010 10:19:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/7] memcg: mem_cgroup_shrink_node_zone() doesn't need
 sc.nodemask
Message-ID: <20100722044911.GK14369@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
 <20100716191334.736F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100716191334.736F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-07-16 19:14:15]:

> Currently mem_cgroup_shrink_node_zone() call shrink_zone() directly.
> thus it doesn't need to initialize sc.nodemask. shrink_zone() doesn't
> use it at all.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/linux/swap.h |    3 +--
>  mm/memcontrol.c      |    3 +--
>  mm/vmscan.c          |    8 ++------
>  3 files changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ff4acea..bf4eb62 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -244,8 +244,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
>  extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
>  						unsigned int swappiness,
> -						struct zone *zone,
> -						int nid);
> +						struct zone *zone);
>  extern int __isolate_lru_page(struct page *page, int mode, int file);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index aba4310..01f38ff 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1307,8 +1307,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  		/* we use swappiness of local cgroup */
>  		if (check_soft)
>  			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -				noswap, get_swappiness(victim), zone,
> -				zone->zone_pgdat->node_id);
> +				noswap, get_swappiness(victim), zone);
>  		else
>  			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
>  						noswap, get_swappiness(victim));
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bd1d035..be860a0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1929,7 +1929,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
>  						unsigned int swappiness,
> -						struct zone *zone, int nid)
> +						struct zone *zone)
>  {
>  	struct scan_control sc = {
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> @@ -1940,13 +1940,9 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  		.order = 0,
>  		.mem_cgroup = mem,
>  	};
> -	nodemask_t nm  = nodemask_of_node(nid);
> -
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> -	sc.nodemask = &nm;
> -	sc.nr_reclaimed = 0;
> -	sc.nr_scanned = 0;

We need the initialization to 0, is there a reason why it was removed?
What happens when we compare or increment sc.nr_*?

Can we keep this indepedent of the tracing patches?

> +
>  	/*
>  	 * NOTE: Although we can get the priority field, using it
>  	 * here is not a good idea, since it limits the pages we can scan.
> -- 
> 1.6.5.2
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
