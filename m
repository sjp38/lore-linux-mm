Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 47A24900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:34:29 -0400 (EDT)
Date: Thu, 18 Aug 2011 15:34:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 5/6]  memg: vmscan select victim node by weight
Message-ID: <20110818133424.GA9206@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809191202.955d9101.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809191202.955d9101.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Tue 09-08-11 19:12:02, KAMEZAWA Hiroyuki wrote:
> 
> This patch implements a node selection logic based on each node's weight.
> 
> This patch adds a new array of nodescan_tickets[]. This array holds
> each node's scan weight in a tuple of 2 values. as
> 
>     for (i = 0, total_weight = 0; i < nodes; i++) {
>         weight = node->weight;
>         nodescan_tickets[i].start = total_weight;
>         nodescan_tickets[i].length = weight;
>     }
> 
> After this, a lottery logic as 'ticket = random32()/total_weight'
> will make a ticket and bserach(ticket, nodescan_tickets[])
> will find a node which holds [start, length] contains ticket.
> (This is a lottery scheduling.)
> 
> By this, node will be selected in fair manner proportinal to
> its weight.

The algorithm sounds interesting, I am just wondering how much gain it
gives over a simple node select with maximum weight (+ add some aging so
that we do not hammer a single node all the time). Have you tried that?

> 
> This patch improve the scan time. Following is a test result
> ot kernel-make on 4-node fake-numa under 500M limit, with 8cpus.
> 2cpus per node.
> 
> [Before patch]
>  772.52user 305.67system 4:11.48elapsed 428%CPU
>  (0avgtext+0avgdata 1457264maxresident)k
>  4797592inputs+5483240outputs (12550major+35707629minor)pagefaults 0swaps

Just to make sure I understand. Before means before this patch not the
entire patch set, right?

> 
> [After patch]
>  773.73user 305.09system 3:51.28elapsed 466%CPU
>  (0avgtext+0avgdata 1458464maxresident)k
>  4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps
> 
> elapsed time and major faults are reduced.
> 
[...]
> Index: mmotm-Aug3/mm/memcontrol.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/memcontrol.c
> +++ mmotm-Aug3/mm/memcontrol.c
[...]
> @@ -1660,6 +1671,46 @@ mem_cgroup_calc_numascan_weight(struct m
>  }
>  
>  /*
> + * For lottery scheduling, this routine disributes "ticket" for
> + * scanning to each node. ticket will be recored into numascan_ticket
> + * array and this array will be used for scheduling, lator.
> + * For make lottery wair, we limit the sum of tickets almost 0xffff.
> + * Later, random() & 0xffff will do proportional fair lottery.
> + */
> +#define NUMA_TICKET_SHIFT	(16)
> +#define NUMA_TICKET_FACTOR	((1 << NUMA_TICKET_SHIFT) - 1)
> +static void mem_cgroup_update_numascan_tickets(struct mem_cgroup *memcg)
> +{
> +	struct numascan_ticket *nt;
> +	unsigned int node_ticket, assigned_tickets;
> +	u64 weight;
> +	int nid, assigned_num, generation;
> +
> +	/* update ticket information by double buffering */
> +	generation = memcg->numascan_generation ^ 0x1;

Double buffering is used due to synchronization with consumers (they
are using the other one than is updated here), right?  Would be good to
mention in the coment...

> +
> +	nt = memcg->numascan_tickets[generation];
> +	assigned_tickets = 0;
> +	assigned_num = 0;
> +	for_each_node_mask(nid, memcg->scan_nodes) {
> +		weight = memcg->info.nodeinfo[nid]->weight;
> +		node_ticket = div64_u64(weight << NUMA_TICKET_SHIFT,
> +					memcg->total_weight + 1);
> +		if (!node_ticket)
> +			node_ticket = 1;
> +		nt->nid = nid;
> +		nt->start = assigned_tickets;
> +		nt->tickets = node_ticket;
> +		assigned_tickets += node_ticket;
> +		nt++;
> +		assigned_num++;
> +	}
> +	memcg->numascan_tickets_num[generation] = assigned_num;
> +	smp_wmb();
> +	memcg->numascan_generation = generation;
> +}
> +
> +/*
>   * Update all node's scan weight in background.
>   */
>  static void mem_cgroup_numainfo_update_work(struct work_struct *work)
> @@ -1672,6 +1723,8 @@ static void mem_cgroup_numainfo_update_w
>  
>  	memcg->total_weight = mem_cgroup_calc_numascan_weight(memcg);
>  
> +	synchronize_rcu();
> +	mem_cgroup_update_numascan_tickets(memcg);

OK, so we have only one updater (this one) which will update generation.
Why do we need rcu here and for search? ACCESS_ONCE should be
sufficient (in mem_cgroup_select_victim_node) or are you afraid that we
could get to update twice during the search?

>  	atomic_set(&memcg->numainfo_updating, 0);
>  	css_put(&memcg->css);
>  }
[...]
> @@ -1707,32 +1772,38 @@ static void mem_cgroup_may_update_nodema
>   * we'll use or we've used. So, it may make LRU bad. And if several threads
>   * hit limits, it will see a contention on a node. But freeing from remote
>   * node means more costs for memory reclaim because of memory latency.
> - *
> - * Now, we use round-robin. Better algorithm is welcomed.
>   */
> -int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask)
> +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, nodemask_t **mask,
> +				struct memcg_scanrecord *rec)
>  {
> -	int node;
> +	int node = MAX_NUMNODES;
> +	struct numascan_ticket *nt;
> +	unsigned long lottery;
> +	int generation;
>  
> +	if (rec->context == SCAN_BY_SHRINK)
> +		goto out;

Why do we care about shrinking here? Due to overhead in node selection?

> +
> +	mem_cgroup_may_update_nodemask(memcg);
>  	*mask = NULL;
> -	mem_cgroup_may_update_nodemask(mem);
> -	node = mem->last_scanned_node;
> +	lottery = random32() & NUMA_TICKET_FACTOR;
>  
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
> +	rcu_read_lock();
> +	generation = memcg->numascan_generation;
> +	nt = bsearch((void *)lottery,
> +		memcg->numascan_tickets[generation],
> +		memcg->numascan_tickets_num[generation],
> +		sizeof(struct numascan_ticket), node_weight_compare);
> +	rcu_read_unlock();
> +	if (nt)
> +		node = nt->nid;
> +out:
> +	if (unlikely(node == MAX_NUMNODES)) {
>  		node = numa_node_id();
> -	else
> -		*mask = &mem->scan_nodes;
> +		*mask = NULL;
> +	} else
> +		*mask = &memcg->scan_nodes;
>  
> -	mem->last_scanned_node = node;
>  	return node;
>  }
>  
[...]
> Index: mmotm-Aug3/mm/vmscan.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/vmscan.c
> +++ mmotm-Aug3/mm/vmscan.c
> @@ -2378,9 +2378,9 @@ unsigned long try_to_free_mem_cgroup_pag
>  	 * take care of from where we get pages. So the node where we start the
>  	 * scan does not need to be the current node.
>  	 */
> -	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask);
> +	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask, rec);
>  
> -	zonelist = NODE_DATA(nid)->node_zonelists;
> +	zonelist = &NODE_DATA(nid)->node_zonelists[0];

Unnecessary change.

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
