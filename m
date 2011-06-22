Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A3FA9900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:59:00 -0400 (EDT)
Date: Wed, 22 Jun 2011 17:58:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
Message-ID: <20110622155856.GI14343@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 16-06-11 12:54:43, KAMEZAWA Hiroyuki wrote:
> From fcfc6ee9847b0b2571cd6e9847572d7c70e1e2b2 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 16 Jun 2011 09:23:54 +0900
> Subject: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
> 
> Now, mem_cgroup_local_usage(memcg) is used as hint for scanning memory
> cgroup hierarchy. If it returns true, the memcg has some reclaimable memory.
> 
> But this function doesn't take care of
>   - unevictable pages
>   - anon pages on swapless system.
> 
> This patch fixes the function to use LRU information.
> For NUMA, for avoid scanning, numa scan bitmap is used. If it's
> empty, some more precise check will be done.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   43 +++++++++++++++++++++++++++++++++----------
>  1 files changed, 33 insertions(+), 10 deletions(-)
> 
> Index: mmotm-0615/mm/memcontrol.c
> ===================================================================
> --- mmotm-0615.orig/mm/memcontrol.c
> +++ mmotm-0615/mm/memcontrol.c
> @@ -632,15 +632,6 @@ static long mem_cgroup_read_stat(struct 
>  	return val;
>  }
>  
> -static long mem_cgroup_local_usage(struct mem_cgroup *mem)
> -{
> -	long ret;
> -
> -	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> -	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> -	return ret;
> -}
> -
>  static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
>  					 bool charge)
>  {
> @@ -1713,6 +1704,23 @@ static void mem_cgroup_numascan_init(str
>  	mutex_init(&mem->numascan_mutex);
>  }
>  
> +static bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> +	if (!nodes_empty(mem->scan_nodes))
> +		return true;

How the non empty node mask guarantees that there is some reclaimable memory?

> +	/* slow path */
> +	if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE))
> +		return true;
> +	if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE))
> +		return true;
> +	if (noswap || !total_swap_pages)
> +		return false;
> +	if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON))
> +		return true;
> +	if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON))
> +		return true;
> +	return false;
> +}
>  #else
>  int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
>  {
> @@ -1722,6 +1730,21 @@ static void mem_cgroup_numascan_init(str
>  {
>  	return 0;
>  }
> +
> +static bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> +	if (mem_cgroup_get_zonestat_node(mem, 0, LRU_INACTIVE_FILE))
> +		return true;
> +	if (mem_cgroup_get_zonestat_node(mem, 0, LRU_ACTIVE_FILE))
> +		return true;
> +	if (noswap || !total_swap_pages)
> +		return false;
> +	if (mem_cgroup_get_zonestat_node(mem, 0, LRU_INACTIVE_ANON))
> +		return true;
> +	if (mem_cgroup_get_zonestat_node(mem, 0, LRU_ACTIVE_ANON))
> +		return true;
> +	return false;
> +}
>  #endif

Code duplication doesn't look good. What about a common helper?
>  
>  
> @@ -1811,7 +1834,7 @@ again:
>  
>  	while (visit--) {
>  		victim = mem_cgroup_select_victim(root_mem);
> -		if (!mem_cgroup_local_usage(victim)) {
> +		if (!mem_cgroup_reclaimable(victim, noswap)) {
>  			/* this cgroup's local usage == 0 */
>  			css_put(&victim->css);
>  			continue;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
