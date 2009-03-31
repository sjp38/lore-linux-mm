Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 71F806B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 04:19:55 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V8KBgD021578
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 17:20:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D59145DE53
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:20:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D5D545DE4F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:20:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10ACB1DB803E
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:20:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4FA1DB8041
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:20:09 +0900 (JST)
Date: Tue, 31 Mar 2009 17:18:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/8] memcg soft limit (yet another new design) v1
Message-Id: <20090331171840.83fb7dab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327140923.7dbbf677.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090327140923.7dbbf677.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 2009 14:09:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> memcg's reclaim routine is designed to ignore locality andplacements and
> then, inactive_anon_is_low() function doesn't take "zone" as its argument.
> 
> In later soft limit patch, we use "zone" as an arguments.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Mar23/mm/memcontrol.c
> @@ -561,15 +561,28 @@ void mem_cgroup_record_reclaim_priority(
>  	spin_unlock(&mem->reclaim_param_lock);
>  }
>  
> -static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
> +static int calc_inactive_ratio(struct mem_cgroup *memcg,
> +			       unsigned long *present_pages,
> +			       struct zone *z)
>  {
>  	unsigned long active;
>  	unsigned long inactive;
>  	unsigned long gb;
>  	unsigned long inactive_ratio;
>  
> -	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
> -	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
> +	if (!z) {
> +		inactive = mem_cgroup_get_local_zonestat(memcg,
> +							 LRU_INACTIVE_ANON);
> +		active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
> +	} else {
> +		int nid = z->zone_pgdat->node_id;
> +		int zid = zone_idx(z);
> +		struct mem_cgroup_per_zone *mz;
> +
> +		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +		inactive = MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
> +		active = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
> +	}
>  
>  	gb = (inactive + active) >> (30 - PAGE_SHIFT);
>  	if (gb)
> @@ -585,14 +598,14 @@ static int calc_inactive_ratio(struct me
>  	return inactive_ratio;
>  }
>  
> -int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> +int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *z)
>  {
>  	unsigned long active;
>  	unsigned long inactive;
>  	unsigned long present_pages[2];
>  	unsigned long inactive_ratio;
>  
> -	inactive_ratio = calc_inactive_ratio(memcg, present_pages);
> +	inactive_ratio = calc_inactive_ratio(memcg, present_pages, NULL);

The last arguments should be "z" not NULL...

seems posted version is a bit old...OMG, sorry.

I'm now adding bugfix etc..

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
