Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE4B6B010D
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:41:05 -0400 (EDT)
Date: Wed, 29 Jun 2011 15:40:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] memcg: fix reclaimable lru check in memcg.
Message-ID: <20110629134059.GD24262@tiehlicka.suse.cz>
References: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110628173958.4f213b26.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110628173958.4f213b26.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue 28-06-11 17:39:58, KAMEZAWA Hiroyuki wrote:
> From b52bcd09843e903e5f184d0ee499909d072f3c8d Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Tue, 28 Jun 2011 15:45:38 +0900
> Subject: [PATCH 1/3] memcg: fix reclaimable lru check in memcg.
> 
> Now, in mem_cgroup_hierarchical_reclaim(), mem_cgroup_local_usage()
> is used for checking whether the memcg contains reclaimable pages
> or not. If no pages in it, the routine skips it.
> 
> But, mem_cgroup_local_usage() contains Unevictable pages and cannot
> handle "noswap" condition correctly. This doesn't work on a swapless
> system.
> 
> This patch adds test_mem_cgroup_reclaimable() and replaces
> mem_cgroup_local_usage(). test_mem_cgroup_reclaimable() see LRU
> counter and returns correct answer to the caller.
> And this new function has "noswap" argument and can see only
> FILE LRU if necessary.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

except for !CONFIG_NUMA issue - see bellow.

> @@ -1559,6 +1550,27 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>  	return ret;
>  }
>  
> +/** test_mem_cgroup_node_reclaimable
> + * @mem: the target memcg
> + * @nid: the node ID to be checked.
> + * @noswap : specify true here if the user wants flle only information.
> + *
> + * This function returns whether the specified memcg contains any
> + * reclaimable pages on a node. Returns true if there are any reclaimable
> + * pages in the node.
> + */
> +static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *mem,
> +		int nid, bool noswap)
> +{
> +	if (mem_cgroup_node_nr_file_lru_pages(mem, nid))
> +		return true;

I do not see definition of mem_cgroup_node_nr_file_lru_pages for
!MAX_NUMNODES==1 (resp. !CONFIG_NUMA) and you are calling this function
also from that context.

>  #if MAX_NUMNODES > 1
>  
>  /*
> @@ -1580,15 +1592,8 @@ static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  
>  	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
>  
> -		if (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE) ||
> -		    mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE))
> -			continue;
> -
> -		if (total_swap_pages &&
> -		    (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON) ||
> -		     mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON)))
> -			continue;
> -		node_clear(nid, mem->scan_nodes);
> +		if (!test_mem_cgroup_node_reclaimable(mem, nid, false))
> +			node_clear(nid, mem->scan_nodes);

Nice clean up.

> @@ -1627,11 +1632,51 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
>  	return node;
>  }
>  
> +/*
> + * Check all nodes whether it contains reclaimable pages or not.
> + * For quick scan, we make use of scan_nodes. This will allow us to skip
> + * unused nodes. But scan_nodes is lazily updated and may not cotain
> + * enough new information. We need to do double check.
> + */
> +bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> +	int nid;
> +
> +	/*
> +	 * quick check...making use of scan_node.
> +	 * We can skip unused nodes.
> +	 */
> +	if (!nodes_empty(mem->scan_nodes)) {
> +		for (nid = first_node(mem->scan_nodes);
> +		     nid < MAX_NUMNODES;
> +		     nid = next_node(nid, mem->scan_nodes)) {
> +
> +			if (test_mem_cgroup_node_reclaimable(mem, nid, noswap))
> +				return true;
> +		}
> +	}
> +	/*
> + 	 * Check rest of nodes.
> + 	 */
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		if (node_isset(nid, mem->scan_nodes))
> +			continue;
> +		if (test_mem_cgroup_node_reclaimable(mem, nid, noswap))
> +			return true;	
> +	}
> +	return false;
> +}
> +
>  #else

This is #else if MAX_NUMNODES == 1 AFAICS

>  int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
>  {
>  	return 0;
>  }
> +
> +bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> +	return test_mem_cgroup_node_reclaimable(mem, 0, noswap);
> +}
>  #endif

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
