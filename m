Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0B56F6B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 20:05:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3FE3D3EE0BB
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:05:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FA2745DE61
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:05:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0817445DE68
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:05:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E71B81DB803C
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:05:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A0431DB803B
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:05:48 +0900 (JST)
Date: Fri, 10 Jun 2011 08:58:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] A scan node selection logic for memcg rather than
 round-robin.
Message-Id: <20110610085856.310d5484.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110609191031.483daba5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609191031.483daba5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Thu, 9 Jun 2011 19:10:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> A scan node selection logic for memcg rather than round-robin.
> 
> This patch is what I'm testing now but I don't have big NUMA.
> please review if you have time. This is against linux-3.0-rc2.
> 
I'm sorry that I noticed I can remove all "noswap" code then...
the size of patch will be half. I'll post more tested version in the next week.

Thanks,
-Kame


> ==
> From fedf64c8b7e42a8d03974456f01fa3774df94afe Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 9 Jun 2011 18:53:14 +0900
> Subject: [PATCH] weighted node scanning for memory cgroup.
> 
> When I pushed 889976dbcb1218119fdd950fb7819084e37d7d37
>  " memcg: reclaim memory from nodes in round-robin order "
> 
> I mentioned " a better algorithm is needed."
> 
> This patch is a better algorithm. This implements..
> 
>    1. per node reclaim target possibilty (called as weight.)
>    2. select a node from nodes by proportional fair way with the weight
> 
> For 1, this patch simply check the number of pages on LRU with
> some bias of active/inactive ratio and swappiness. A weight for
> node is calculated as
> 
>    weight = (inactive_files + active_files * active_ratio) * (200-swappines)
>             (inactive_anon + active_files * active_ratio) * swappiness
> 
> In general, if node contains more inactive files, the weight goes high.
> This weight can be seen by numa_stat.
> 
> [root@bluextal linux-2.6]# cat /cgroup/memory/A/memory.numa_stat
> total=31863 N0=14235 N1=17628
> file=27912 N0=12814 N1=15098
> anon=3951 N0=1421 N1=2530
> unevictable=0 N0=0 N1=0
> lru_scan_weight=35798 N0=19886 N1=15912
> 
> For 2. this patch uses lottery scheduling using node's weight.
> This is porportionally fair logic.
> 
> For example, assume Node 0,1,2,3 and their weights are 1000,2000,1000,6000.
> The node selection possibility is 1:2:1:6. So, even if a node contains
> small amount of memory, it has possiblity to be reclaimed. In long run,
> there will prevent starvation....where the system ignores small umount of
> file caches in a node.....
> 
> I used bsearch() for finding a victim node..so, you may think the code is
> complicated.
> 
> TO-BE-CHECKED:
>   - of course, calculation of "weight" is the heart of the logic.
>   - what part is hard to read ?
>   - cleverer implemenation ?
>   - need more tests.
>   - choose better variable names and add more comments ;)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    2 +-
>  mm/memcontrol.c            |  226 +++++++++++++++++++++++++++++++++++++------
>  mm/vmscan.c                |    2 +-
>  3 files changed, 196 insertions(+), 34 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 9724a38..95d18b6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -108,7 +108,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>   */
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> -int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, bool noswap);
>  unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  						struct zone *zone,
>  						enum lru_list lru);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 06825be..2ed3749 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -48,6 +48,8 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
> +#include <linux/random.h>
> +#include <linux/bsearch.h>
>  #include "internal.h"
>  
>  #include <asm/uaccess.h>
> @@ -141,10 +143,22 @@ struct mem_cgroup_per_zone {
>  
>  struct mem_cgroup_per_node {
>  	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
> +	unsigned long weight;
> +};
> +
> +struct node_schedinfo {
> +	unsigned long weight_start, weight_end;
> +	unsigned long weight_noswap_start, weight_noswap_end;
> +	int nid;
>  };
>  
>  struct mem_cgroup_lru_info {
>  	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> +	struct node_schedinfo *schedinfo;
> +	struct rw_semaphore	updating;
> +	int nr_nodes;
> +	unsigned long total_weight;
> +	unsigned long total_weight_noswap;
>  };
>  
>  /*
> @@ -1559,36 +1573,157 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>  }
>  
>  #if MAX_NUMNODES > 1
> +/*
> + * Weight for node scanning calculation.
> + * Basically, node includes inactive pages are guilty. But if we never scan
> + * nodes only with active pages, LRU rotation on the node never occurs.
> + * So, we need to take into account active pages to some extent.
> + */
> +static void mem_cgroup_node_sched_weight(struct mem_cgroup *mem,
> +		int nid, unsigned long usage,
> +		int file_active_ratio, int anon_active_ratio,
> +		unsigned long *weight, unsigned long *weight_noswap)
> +{
> +	unsigned long file, anon;
> +
> +
> +	file = mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE);
> +	/* reduce weight of node active pages with regard to the total ratio */
> +	file = file * file_active_ratio / 100;
> +	file += mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE);
> +
> +
> +	anon = mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON);
> +	/* reduce weight of node active pages with regard to the total ratio */
> +	anon = anon * anon_active_ratio / 100;
> +	anon += mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON);
> +
> +	*weight_noswap = file;
> +	*weight = file * (200 - mem->swappiness) + anon * (mem->swappiness + 1);
> +	*weight /= 200;
> +
> +	return;
> +}
> +
> +/*
> + * calculate a ratio for active/inactive ratio with regard to curret
> + * total inactive/active ratio.
> + */
> +static unsigned int
> +mem_cgroup_active_ratio(struct mem_cgroup *mem, enum lru_list l)
> +{
> +	unsigned long active, inactive;
> +
> +	inactive = mem_cgroup_get_local_zonestat(mem, l);
> +	active = mem_cgroup_get_local_zonestat(mem, l + LRU_ACTIVE);
> +
> +	return (active * 100)/(active + inactive);
> +}
>  
>  /*
>   * Always updating the nodemask is not very good - even if we have an empty
>   * list or the wrong list here, we can start from some node and traverse all
>   * nodes based on the zonelist. So update the list loosely once per 10 secs.
> - *
>   */
> -static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
> +static void mem_cgroup_may_update_nodeweight(struct mem_cgroup *mem)
>  {
>  	int nid;
> +	int file_active_ratio, anon_active_ratio;
> +	unsigned long total_weight, total_weight_noswap;
> +	struct node_schedinfo *ns;
> +	unsigned long usage;
>  
>  	if (time_after(mem->next_scan_node_update, jiffies))
>  		return;
> -
> +	down_write(&mem->info.updating);
> +	/* double check for race. */
> +	if (time_after(mem->next_scan_node_update, jiffies)) {
> +		up_write(&mem->info.updating);
> +		return;
> +	}
>  	mem->next_scan_node_update = jiffies + 10*HZ;
> +
>  	/* make a nodemask where this memcg uses memory from */
> -	mem->scan_nodes = node_states[N_HIGH_MEMORY];
> +	total_weight = 0;
> +	total_weight_noswap = 0;
>  
> -	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
>  
> -		if (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE) ||
> -		    mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE))
> -			continue;
> +	file_active_ratio = mem_cgroup_active_ratio(mem, LRU_INACTIVE_FILE);
> +	anon_active_ratio = mem_cgroup_active_ratio(mem, LRU_INACTIVE_ANON);
> +	usage = res_counter_read_u64(&mem->res, RES_USAGE) >> PAGE_SHIFT;
> +
> +	/*
> +	 * Calculate each node's weight and put the score into array of
> +	 * node_scheinfo. Eech node schedinfo contains nid and
> +	 * [start_weight, end_weight). Later, a thread will get a ticket
> +	 * with a number < total_weight and find a node_schedinfo which
> +	 * has start_weight <= ticket number < end_weight.
> +	 *
> +	 * If ticket number is enough random, we can do proportional fair
> +	 * victim selection with regard to "weight" of each nodes.
> +	 *
> +	 * Why do we need to use "schedinfo" rather than adding member to
> +	 * per-node structure ? There are 2 reasons. 1) node array
> +	 * can have holes and not good for bsearch() 2) We can skip nodes
> +	 * which has no memory. Using other structure like prio-tree is a
> +	 * possible idea, of course.
> +	 */
> +	ns = &mem->info.schedinfo[0];
> +
> +	for_each_node_mask (nid, node_states[N_HIGH_MEMORY]) {
> +		unsigned long weight, weight_noswap;
>  
> -		if (total_swap_pages &&
> -		    (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON) ||
> -		     mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON)))
> +		mem_cgroup_node_sched_weight(mem, nid, usage,
> +				file_active_ratio,
> +				anon_active_ratio,
> +				&weight, &weight_noswap);
> +
> +		if (weight == 0)
>  			continue;
> -		node_clear(nid, mem->scan_nodes);
> +		ns->nid = nid;
> +		/* For noswap scan, we take care of file caches */
> +		ns->weight_noswap_start = total_weight_noswap;
> +		ns->weight_noswap_end = ns->weight_noswap_start + weight_noswap;
> +		total_weight_noswap += weight_noswap;
> +
> +		ns->weight_start = total_weight;
> +		ns->weight_end = ns->weight_start + weight;
> +		total_weight += weight;
> +		ns++;
> +		/* for numa stat */
> +		mem->info.nodeinfo[nid]->weight = weight;
>  	}
> +
> +	mem->info.total_weight = total_weight;
> +	mem->info.total_weight_noswap = total_weight_noswap;
> +	mem->info.nr_nodes = ns - mem->info.schedinfo;
> +
> +	up_write(&mem->info.updating);
> +}
> +
> +/* routine for finding lottery winner by bsearch. */
> +static int cmp_node_lottery_weight(const void *key, const void *elt)
> +{
> +	struct node_schedinfo *ns = (struct node_schedinfo *)elt;
> +	unsigned long lottery = (unsigned long)key;
> +
> +	if (lottery < ns->weight_start)
> +		return -1;
> +	if (lottery >= ns->weight_end)
> +		return 1;
> +	return 0;
> +}
> +
> +static int cmp_node_lottery_weight_noswap(const void *key, const void *elt)
> +{
> +	struct node_schedinfo *ns = (struct node_schedinfo *)elt;
> +	unsigned long lottery = (unsigned long)key;
> +
> +	if (lottery < ns->weight_noswap_start)
> +		return -1;
> +	if (lottery >= ns->weight_noswap_end)
> +		return 1;
> +	return 0;
>  }
>  
>  /*
> @@ -1601,29 +1736,42 @@ static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>   * hit limits, it will see a contention on a node. But freeing from remote
>   * node means more costs for memory reclaim because of memory latency.
>   *
> - * Now, we use round-robin. Better algorithm is welcomed.
> + * This selects a node by an lottery scheduling algorithm with regard to
> + * each node's weight under the whole memcg usage. By this we'll scan
> + * nodes in a way proportional fair to the number of reclaim candidate
> + * pages per node.
>   */
> -int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> +int mem_cgroup_select_victim_node(struct mem_cgroup *mem, bool noswap)
>  {
> -	int node;
> -
> -	mem_cgroup_may_update_nodemask(mem);
> -	node = mem->last_scanned_node;
> -
> -	node = next_node(node, mem->scan_nodes);
> -	if (node == MAX_NUMNODES)
> -		node = first_node(mem->scan_nodes);
> -	/*
> -	 * We call this when we hit limit, not when pages are added to LRU.
> -	 * No LRU may hold pages because all pages are UNEVICTABLE or
> -	 * memcg is too small and all pages are not on LRU. In that case,
> -	 * we use curret node.
> -	 */
> -	if (unlikely(node == MAX_NUMNODES))
> -		node = numa_node_id();
> +	struct node_schedinfo *ns;
> +	unsigned long lottery;
> +	int nid;
>  
> -	mem->last_scanned_node = node;
> -	return node;
> +	mem_cgroup_may_update_nodeweight(mem);
> +	/* use pseudo nid while updating schedule information. */
> +	if (!down_read_trylock(&mem->info.updating))
> +		return numa_node_id();
> +
> +	if (!mem->info.nr_nodes) {
> +		/* if all nodes has very small memory for each... */
> +		ns = NULL;
> +	} else if (noswap) {
> +		lottery = random32() % mem->info.total_weight_noswap;
> +		ns = bsearch((void*)lottery, mem->info.schedinfo,
> +			mem->info.nr_nodes,
> +			sizeof(*ns), cmp_node_lottery_weight_noswap);
> +	} else {
> +		lottery = random32() % mem->info.total_weight;
> +		ns = bsearch((void*)lottery, mem->info.schedinfo,
> +			mem->info.nr_nodes,
> +			sizeof(*ns), cmp_node_lottery_weight);
> +	}
> +	if (ns)
> +		nid = ns->nid;
> +	else
> +		nid = numa_node_id();
> +	up_read(&mem->info.updating);
> +	return nid;
>  }
>  
>  #else
> @@ -4135,6 +4283,11 @@ static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
>  		seq_printf(m, " N%d=%lu", nid, node_nr);
>  	}
>  	seq_putc(m, '\n');
> +	seq_printf(m, "lru_scan_weight=%lu", mem_cont->info.total_weight);
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		seq_printf(m, " N%d=%lu", nid,
> +				mem_cont->info.nodeinfo[nid]->weight);
> +	seq_putc(m, '\n');
>  	return 0;
>  }
>  #endif /* CONFIG_NUMA */
> @@ -4789,6 +4942,8 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
>  
> +	kfree(mem->info.schedinfo);
> +
>  	free_percpu(mem->stat);
>  	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
>  		kfree(mem);
> @@ -4878,6 +5033,13 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
>  			goto free_out;
>  
> +	node = nodes_weight(node_states[N_POSSIBLE]);
> +	mem->info.schedinfo =
> +		kzalloc(sizeof(struct node_schedinfo) * node, GFP_KERNEL);
> +	if (!mem->info.schedinfo)
> +		goto free_out;
> +	init_rwsem(&mem->info.updating);
> +
>  	/* root ? */
>  	if (cont->parent == NULL) {
>  		int cpu;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index faa0a08..dd1823b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2254,7 +2254,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  	 * take care of from where we get pages. So the node where we start the
>  	 * scan does not need to be the current node.
>  	 */
> -	nid = mem_cgroup_select_victim_node(mem_cont);
> +	nid = mem_cgroup_select_victim_node(mem_cont, noswap);
>  
>  	zonelist = NODE_DATA(nid)->node_zonelists;
>  
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
