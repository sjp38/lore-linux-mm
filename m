Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3684A6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 20:12:54 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n081CojM000652
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 10:12:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCBCD45DE55
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 10:12:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A82B45DD79
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 10:12:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E4FC1DB803F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 10:12:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00D661DB8038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 10:12:50 +0900 (JST)
Date: Thu, 8 Jan 2009 10:11:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups
Message-Id: <20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090107184128.18062.96016.sendpatchset@localhost.localdomain>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	<20090107184128.18062.96016.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 08 Jan 2009 00:11:28 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> This patch introduces a RB-Tree for storing memory cgroups that are over their
> soft limit. The overall goal is to
> 
> 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
>    We are careful about updates, updates take place only after a particular
>    time interval has passed
> 2. We remove the node from the RB-Tree when the usage goes below the soft
>    limit
> 
> The next set of patches will exploit the RB-Tree to get the group that is
> over its soft limit by the largest amount and reclaim from it, when we
> face memory contention.
> 

Hmm,  Could you clarify following ?
  
  - Usage of memory at insertsion and usage of memory at reclaim is different.
    So, this *sorted* order by RB-tree isn't the best order in general.
    Why don't you sort this at memory-reclaim dynamically ?
  - Considering above, the look of RB tree can be

                +30M (an amount over soft limit is 30M)
                /  \
             -15M   +60M
     ?

    At least, pleease remove the node at uncharge() when the usage goes down.

Thanks,
-Kame




> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 78 insertions(+)
> 
> diff -puN mm/memcontrol.c~memcg-organize-over-soft-limit-groups mm/memcontrol.c
> --- a/mm/memcontrol.c~memcg-organize-over-soft-limit-groups
> +++ a/mm/memcontrol.c
> @@ -28,6 +28,7 @@
>  #include <linux/bit_spinlock.h>
>  #include <linux/rcupdate.h>
>  #include <linux/mutex.h>
> +#include <linux/rbtree.h>
>  #include <linux/slab.h>
>  #include <linux/swap.h>
>  #include <linux/spinlock.h>
> @@ -119,6 +120,13 @@ struct mem_cgroup_lru_info {
>  };
>  
>  /*
> + * Cgroups above their limits are maintained in a RB-Tree, independent of
> + * their hierarchy representation
> + */
> +static struct rb_root mem_cgroup_soft_limit_exceeded_groups;
> +static DEFINE_MUTEX(memcg_soft_limit_tree_mutex);
> +
> +/*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
>   * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> @@ -166,12 +174,18 @@ struct mem_cgroup {
>  
>  	unsigned int	swappiness;
>  
> +	struct rb_node mem_cgroup_node;
> +	unsigned long long usage_in_excess;
> +	unsigned long last_tree_update;
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
>  	struct mem_cgroup_stat stat;
>  };
>  
> +#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ)
> +
>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
>  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> @@ -203,6 +217,39 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  
> +static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> +{
> +	struct rb_node **p = &mem_cgroup_soft_limit_exceeded_groups.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct mem_cgroup *mem_node;
> +
> +	mutex_lock(&memcg_soft_limit_tree_mutex);
> +	while (*p) {
> +		parent = *p;
> +		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
> +		if (mem->usage_in_excess < mem_node->usage_in_excess)
> +			p = &(*p)->rb_left;
> +		/*
> +		 * We can't avoid mem cgroups that are over their soft
> +		 * limit by the same amount
> +		 */
> +		else if (mem->usage_in_excess >= mem_node->usage_in_excess)
> +			p = &(*p)->rb_right;
> +	}
> +	rb_link_node(&mem->mem_cgroup_node, parent, p);
> +	rb_insert_color(&mem->mem_cgroup_node,
> +			&mem_cgroup_soft_limit_exceeded_groups);
> +	mem->last_tree_update = jiffies;
> +	mutex_unlock(&memcg_soft_limit_tree_mutex);
> +}
> +
> +static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> +{
> +	mutex_lock(&memcg_soft_limit_tree_mutex);
> +	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
> +	mutex_unlock(&memcg_soft_limit_tree_mutex);
> +}
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
>  					 bool charge)
> @@ -917,6 +964,10 @@ static void __mem_cgroup_commit_charge(s
>  				     struct page_cgroup *pc,
>  				     enum charge_type ctype)
>  {
> +	unsigned long long prev_usage_in_excess, new_usage_in_excess;
> +	bool updated_tree = false;
> +	unsigned long next_update;
> +
>  	/* try_charge() can return NULL to *memcg, taking care of it. */
>  	if (!mem)
>  		return;
> @@ -937,6 +988,30 @@ static void __mem_cgroup_commit_charge(s
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
>  	unlock_page_cgroup(pc);
> +
> +	mem_cgroup_get(mem);
> +	prev_usage_in_excess = mem->usage_in_excess;
> +	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> +
> +	next_update = mem->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
> +	if (new_usage_in_excess && time_after(jiffies, next_update)) {
> +		if (prev_usage_in_excess)
> +			mem_cgroup_remove_exceeded(mem);
> +		mem_cgroup_insert_exceeded(mem);
> +		updated_tree = true;
> +	} else if (prev_usage_in_excess && !new_usage_in_excess) {
> +		mem_cgroup_remove_exceeded(mem);
> +		updated_tree = true;
> +	}
> +
> +	if (updated_tree) {
> +		mutex_lock(&memcg_soft_limit_tree_mutex);
> +		mem->last_tree_update = jiffies;
> +		mem->usage_in_excess = new_usage_in_excess;
> +		mutex_unlock(&memcg_soft_limit_tree_mutex);
> +	}
> +	mem_cgroup_put(mem);
> +
>  }
>  
>  /**
> @@ -2218,6 +2293,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> +		mem_cgroup_soft_limit_exceeded_groups = RB_ROOT;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> @@ -2231,6 +2307,8 @@ mem_cgroup_create(struct cgroup_subsys *
>  		res_counter_init(&mem->memsw, NULL);
>  	}
>  	mem->last_scanned_child = NULL;
> +	mem->usage_in_excess = 0;
> +	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
>  	spin_lock_init(&mem->reclaim_param_lock);
>  
>  	if (parent)
> _
> 
> -- 
> 	Balbir
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
