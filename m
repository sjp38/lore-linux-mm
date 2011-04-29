Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53009900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 06:26:59 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3TAQXfi003723
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:26:33 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3TAQqmZ2449476
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:26:52 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3TAQofj024089
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:26:52 +1000
Date: Fri, 29 Apr 2011 15:56:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] Add the soft_limit reclaim in global direct
 reclaim.
Message-ID: <20110429102649.GK6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
 <1304030226-19332-2-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1304030226-19332-2-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-04-28 15:37:05]:

> We recently added the change in global background reclaim which
> counts the return value of soft_limit reclaim. Now this patch adds
> the similar logic on global direct reclaim.
> 
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim
> does enough work. This is the first step where we start with counting
> the nr_scanned and nr_reclaimed from soft_limit reclaim into global
> scan_control.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/vmscan.c |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3a569f..84003cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1959,11 +1959,14 @@ restart:
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> -static void shrink_zones(int priority, struct zonelist *zonelist,
> +static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
>  					struct scan_control *sc)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
> +	unsigned long nr_soft_reclaimed;
> +	unsigned long nr_soft_scanned;
> +	unsigned long total_scanned = 0;
> 
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> @@ -1980,8 +1983,17 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  				continue;	/* Let kswapd poll it */
>  		}
> 
> +		nr_soft_scanned = 0;
> +		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> +							sc->order, sc->gfp_mask,
> +							&nr_soft_scanned);
> +		sc->nr_reclaimed += nr_soft_reclaimed;
> +		total_scanned += nr_soft_scanned;
> +
>  		shrink_zone(priority, zone, sc);
>  	}
> +
> +	return total_scanned;
>  }
> 
>  static bool zone_reclaimable(struct zone *zone)
> @@ -2045,7 +2057,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> -		shrink_zones(priority, zonelist, sc);
> +		total_scanned += shrink_zones(priority, zonelist, sc);
>  		/*
>  		 * Don't shrink slabs when reclaiming memory from
>  		 * over limit cgroups

Seems reasonable to me, are you able to see the benefits of setting
soft limits and then adding back the stats on global LRU scan if
soft limits did a good job?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
