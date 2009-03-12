Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9036F6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 23:58:59 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C3unFF026886
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:56:49 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C3x1jq1020024
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:59:01 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C3whGW029908
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:58:43 +1100
Date: Thu, 12 Mar 2009 09:28:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/5] memcg softlimit hooks to kswapd
Message-ID: <20090312035837.GD23583@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312100008.aa8379d7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312100008.aa8379d7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 10:00:08]:

> This patch needs MORE investigation...
> 
> ==
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
> Changelog: v3 -> v4
>  - move "sc" as local variable
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 52 insertions(+)
> 
> Index: mmotm-2.6.29-Mar10/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
> +++ mmotm-2.6.29-Mar10/mm/vmscan.c
> @@ -1733,6 +1733,49 @@ unsigned long try_to_free_mem_cgroup_pag
>  }
>  #endif
> 
> +static void shrink_zone_softlimit(struct zone *zone, int order, int priority,
> +			   int target, int end_zone)
> +{
> +	int scan = SWAP_CLUSTER_MAX;
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	struct mem_cgroup *mem;
> +	struct scan_control sc =  {
> +		.gfp_mask = GFP_KERNEL,
> +		.may_writepage = !laptop_mode,
> +		.swap_cluster_max = SWAP_CLUSTER_MAX,
> +		.may_unmap = 1,
> +		.swappiness = vm_swappiness,
> +		.order = order,
> +		.mem_cgroup = NULL,
> +		.isolate_pages = mem_cgroup_isolate_pages,
> +	};
> +
> +	scan = target * 2;
> +
> +	sc.nr_scanned = 0;
> +	sc.nr_reclaimed = 0;
> +	while (scan > 0) {
> +		if (zone_watermark_ok(zone, order, target, end_zone, 0))
> +			break;
> +		mem = mem_cgroup_schedule(nid, zid);
> +		if (!mem)
> +			return;
> +		sc.mem_cgroup = mem;
> +
> +		sc.nr_reclaimed = 0;
> +		shrink_zone(priority, zone, &sc);
> +
> +		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX/2)
> +			mem_cgroup_schedule_end(nid, zid, mem, true);
> +		else
> +			mem_cgroup_schedule_end(nid, zid, mem, false);
> +
> +		scan -= sc.nr_scanned;
> +	}
> +
> +	return;
> +}

I experimented a *lot* with zone reclaim and found it to be not so
effective. Here is why

1. We have no control over priority or how much to scan, that is
controlled by balance_pgdat(). If we find that we are unable to scan
anything, we continue scanning with the scan > 0 check, but we scan
the same pages and the same number, because shrink_zone does scan >>
priority.
2. If we fail to reclaim pages in shrink_zone_softlimit, shrink_zone()
will reclaim pages independent of the soft limit for us

I spent a couple of days looking at zone based reclaim, but ran into
(1) and (2) above.

>  /*
>   * For kswapd, balance_pgdat() will work across all this node's zones until
>   * they are all at pages_high.
> @@ -1776,6 +1819,8 @@ static unsigned long balance_pgdat(pg_da
>  	 */
>  	int temp_priority[MAX_NR_ZONES];
> 
> +	/* Refill softlimit queue */
> +	mem_cgroup_reschedule_all(pgdat->node_id);
>  loop_again:
>  	total_scanned = 0;
>  	sc.nr_reclaimed = 0;
> @@ -1856,6 +1901,13 @@ loop_again:
>  					       end_zone, 0))
>  				all_zones_ok = 0;
>  			temp_priority[i] = priority;
> +
> +			/*
> +			 * Try soft limit at first.  This reclaims page
> +			 * with regard to user's hint.
> +			 */
> +			shrink_zone_softlimit(zone, order, priority,
> +					       8 * zone->pages_high, end_zone);
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
>  			/*
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
