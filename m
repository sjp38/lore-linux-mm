Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB0DF6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 15:02:59 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2AJ2kq4018639
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 00:32:46 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2AJ2sJs4477126
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 00:32:54 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2AJ2j8S019641
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 00:32:46 +0530
Date: Wed, 11 Mar 2009 00:32:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/4] memcg: softlimit caller via kswapd
Message-ID: <20090310190242.GG26837@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com> <20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:42:18]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch adds hooks for memcg's softlimit to kswapd().
> 
> Softlimit handler is called...
>   - before generic shrink_zone() is called.
>   - # of pages to be scanned depends on priority.
>   - If not enough progress, selected memcg will be moved to UNUSED queue.
>   - at each call for balance_pgdat(), softlimit queue is rebalanced.
> 
> Changelog: v1->v2
>   - check "enough progress" or not.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
> 
> Index: develop/mm/vmscan.c
> ===================================================================
> --- develop.orig/mm/vmscan.c
> +++ develop/mm/vmscan.c
> @@ -1733,6 +1733,43 @@ unsigned long try_to_free_mem_cgroup_pag
>  }
>  #endif
> 
> +static void shrink_zone_softlimit(struct scan_control *sc, struct zone *zone,
> +			   int order, int priority, int target, int end_zone)
> +{
> +	int scan = SWAP_CLUSTER_MAX;
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	int before;
> +	struct mem_cgroup *mem;
> +
> +	scan <<= (DEF_PRIORITY - priority);
> +	if (scan > (target * 2))
> +		scan = target * 2;
> +
> +	while (scan > 0) {
> +		if (zone_watermark_ok(zone, order, target, end_zone, 0))
> +			break;
> +		mem = mem_cgroup_schedule(nid, zid);
> +		if (!mem)
> +			return;
> +		sc->nr_scanned = 0;
> +		sc->mem_cgroup = mem;
> +		before = sc->nr_reclaimed;
> +		sc->isolate_pages = mem_cgroup_isolate_pages;
> +
> +		shrink_zone(priority, zone, sc);
> +
> +		if (sc->nr_reclaimed - before > scan/2)
> +			mem_cgroup_schedule_end(nid, zid, mem, true);
> +		else
> +			mem_cgroup_schedule_end(nid, zid, mem, false);
> +
> +		sc->mem_cgroup = NULL;
> +		sc->isolate_pages = isolate_pages_global;


Looks like a dirty hack, replacing sc-> fields this way. I've
experimented a lot with per zone balancing and soft limits and it does
not work well. The reasons

1. zone watermark balancing has a different goal than soft limit. Soft
limits are more of a mem cgroup feature rather than node/zone feature.
IIRC, you called reclaim as hot-path for soft limit reclaim, my
experimentation is beginning to show changed behaviour

On a system with 4 CPUs and 4 Nodes, I find all CPUs spending time
doing reclaim, putting the hook in the reclaim path, makes the reclaim
dependent on the number of tasks and contention.

What does your test data/experimentation show?

> +		scan -= sc->nr_scanned;
> +	}
> +	return;
> +}
>  /*
>   * For kswapd, balance_pgdat() will work across all this node's zones until
>   * they are all at pages_high.
> @@ -1776,6 +1813,8 @@ static unsigned long balance_pgdat(pg_da
>  	 */
>  	int temp_priority[MAX_NR_ZONES];
> 
> +	/* Refill softlimit queue */
> +	mem_cgroup_reschedule(pgdat->node_id);
>  loop_again:
>  	total_scanned = 0;
>  	sc.nr_reclaimed = 0;
> @@ -1856,6 +1895,9 @@ loop_again:
>  					       end_zone, 0))
>  				all_zones_ok = 0;
>  			temp_priority[i] = priority;
> +			/* Try soft limit at first */
> +			shrink_zone_softlimit(&sc, zone, order, priority,
> +					       8 * zone->pages_high, end_zone);
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
>  			/*
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
