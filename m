Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B249D9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:24:57 -0400 (EDT)
Date: Wed, 27 Apr 2011 14:20:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: reclaim memory from nodes in round robin
Message-Id: <20110427142059.a364a8e7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110427115718.ab6c55ae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427115718.ab6c55ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hi,

On Wed, 27 Apr 2011 11:57:18 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Now, memory cgroup's direct reclaim frees memory from the current node.
> But this has some troubles. In usual, when a set of threads works in
> cooperative way, they are tend to on the same node. So, if they hit
> limits under memcg, it will reclaim memory from themselves, it may be
> active working set.
> 
> For example, assume 2 node system which has Node 0 and Node 1
> and a memcg which has 1G limit. After some work, file cacne remains and
> and usages are
>    Node 0:  1M
>    Node 1:  998M.
> 
> and run an application on Node 0, it will eats its foot before freeing
> unnecessary file caches.
> 
> This patch adds round-robin for NUMA and adds equal pressure to each
> node. When using cpuset's spread memory feature, this will work very well.
> 
> But yes, better algorithm is appreciated.
>
At first, I thought the process may be oom-killed easily if we have many NUMA nodes
and we try to reclaim only from nodes where no processes in the memcg allocate memory.
But considering more, node_zonelists contains zones from other NUMA nodes IIUC,
so it doesn't happen. 

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Except for some typos which have already been pointed out.

Thanks,
Daisuke Nishimura.

P.S.
I'm very sorry for my laziness these days. We have a long holidays in Japan
from this weekend, so I hope I can review recent patches about bgreclaim etc
in my home.

> From: Ying Han <yinghan@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/memcontrol.c            |   25 +++++++++++++++++++++++++
>  mm/vmscan.c                |    9 ++++++++-
>  3 files changed, 34 insertions(+), 1 deletion(-)
> 
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -108,6 +108,7 @@ extern void mem_cgroup_end_migration(str
>   */
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>  				       struct zone *zone,
>  				       enum lru_list lru);
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -237,6 +237,7 @@ struct mem_cgroup {
>  	 * reclaimed from.
>  	 */
>  	int last_scanned_child;
> +	int last_scanned_node;
>  	/*
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
> @@ -1472,6 +1473,29 @@ mem_cgroup_select_victim(struct mem_cgro
>  }
>  
>  /*
> + * Selecting a node where we start reclaim from. Because what we need is just
> + * reducing usage counter, start from anywhere is O,K. When considering
> + * memory reclaim from current node, there are pros. and cons.
> + * Freeing memory from current node means freeing memory from a node which
> + * we'll use or we've used. So, it may make LRU bad. And if several threads
> + * hit limits, it will see a contention on a node. But freeing from remote
> + * node mean more costs for memory reclaim because of memory latency.
> + *
> + * Now, we use round-robin. Better algorithm is welcomed.
> + */
> +int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> +{
> +	int node;
> +
> +	node = next_node(mem->last_scanned_node, node_states[N_HIGH_MEMORY]);
> +	if (node == MAX_NUMNODES)
> +		node = first_node(node_states[N_HIGH_MEMORY]);
> +
> +	mem->last_scanned_node = node;
> +	return node;
> +}
> +
> +/*
>   * Scan the hierarchy if needed to reclaim memory. We remember the last child
>   * we reclaimed from, so that we don't end up penalizing one child extensively
>   * based on its position in the children list.
> @@ -4678,6 +4702,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  		res_counter_init(&mem->memsw, NULL);
>  	}
>  	mem->last_scanned_child = 0;
> +	mem->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
>  	if (parent)
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -2198,6 +2198,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  {
>  	struct zonelist *zonelist;
>  	unsigned long nr_reclaimed;
> +	int nid;
>  	struct scan_control sc = {
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
> @@ -2208,10 +2209,16 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.mem_cgroup = mem_cont,
>  		.nodemask = NULL, /* we don't care the placement */
>  	};
> +	/*
> +	 * Unlike direct reclaim via allo_pages(), memcg's reclaim
> +	 * don't take care from where we get free resouce. So, the node where
> +	 * we need to start scan is not need to be current node.
> +	 */
> +	nid = mem_cgroup_select_victim_node(mem_cont);
>  
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> -	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
> +	zonelist = NODE_DATA(nid)->node_zonelists;
>  
>  	trace_mm_vmscan_memcg_reclaim_begin(0,
>  					    sc.may_writepage,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
