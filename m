Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1CD0E6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 02:59:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D6xsmP030767
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 15:59:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2737D45DD7B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:59:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 079B045DD78
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:59:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E30C71DB8042
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:59:53 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92F63E08005
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:59:50 +0900 (JST)
Message-ID: <cfa8f3be8873274b74d5c5bd0dbcb532.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090312175625.17890.94795.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
    <20090312175625.17890.94795.sendpatchset@localhost.localdomain>
Date: Fri, 13 Mar 2009 15:59:49 +0900 (JST)
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Feature: Organize cgroups over soft limit in a RB-Tree
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> Changelog v5...v4
> 1. res_counter_uncharge has an additional parameter to indicate if the
>    counter was over its soft limit, before uncharge.
>
> Changelog v4...v3
> 1. Optimizations to ensure we don't uncessarily get res_counter values
> 2. Fixed a bug in usage of time_after()
>
> Changelog v3...v2
> 1. Add only the ancestor to the RB-Tree
> 2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put
>
> Changelog v2...v1
> 1. Add support for hierarchies
> 2. The res_counter that is highest in the hierarchy is returned on soft
>    limit being exceeded. Since we do hierarchical reclaim and add all
>    groups exceeding their soft limits, this approach seems to work well
>    in practice.
>
> This patch introduces a RB-Tree for storing memory cgroups that are over
> their
> soft limit. The overall goal is to
>
> 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
>    We are careful about updates, updates take place only after a
> particular
>    time interval has passed
> 2. We remove the node from the RB-Tree when the usage goes below the soft
>    limit
>
> The next set of patches will exploit the RB-Tree to get the group that is
> over its soft limit by the largest amount and reclaim from it, when we
> face memory contention.
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>
>  include/linux/res_counter.h |    6 +-
>  kernel/res_counter.c        |   18 +++++
>  mm/memcontrol.c             |  141
> ++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 143 insertions(+), 22 deletions(-)
>
>
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 5c821fd..5bbf8b1 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -112,7 +112,8 @@ void res_counter_init(struct res_counter *counter,
> struct res_counter *parent);
>  int __must_check res_counter_charge_locked(struct res_counter *counter,
>  		unsigned long val);
>  int __must_check res_counter_charge(struct res_counter *counter,
> -		unsigned long val, struct res_counter **limit_fail_at);
> +		unsigned long val, struct res_counter **limit_fail_at,
> +		struct res_counter **soft_limit_at);
>
>  /*
>   * uncharge - tell that some portion of the resource is released
> @@ -125,7 +126,8 @@ int __must_check res_counter_charge(struct res_counter
> *counter,
>   */
>
>  void res_counter_uncharge_locked(struct res_counter *counter, unsigned
> long val);
> -void res_counter_uncharge(struct res_counter *counter, unsigned long
> val);
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> +				bool *was_soft_limit_excess);
>
>  static inline bool res_counter_limit_check_locked(struct res_counter
> *cnt)
>  {
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 4e6dafe..51ec438 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -37,17 +37,27 @@ int res_counter_charge_locked(struct res_counter
> *counter, unsigned long val)
>  }
>
>  int res_counter_charge(struct res_counter *counter, unsigned long val,
> -			struct res_counter **limit_fail_at)
> +			struct res_counter **limit_fail_at,
> +			struct res_counter **soft_limit_fail_at)
>  {
>  	int ret;
>  	unsigned long flags;
>  	struct res_counter *c, *u;
>
>  	*limit_fail_at = NULL;
> +	if (soft_limit_fail_at)
> +		*soft_limit_fail_at = NULL;
>  	local_irq_save(flags);
>  	for (c = counter; c != NULL; c = c->parent) {
>  		spin_lock(&c->lock);
>  		ret = res_counter_charge_locked(c, val);
> +		/*
> +		 * With soft limits, we return the highest ancestor
> +		 * that exceeds its soft limit
> +		 */
> +		if (soft_limit_fail_at &&
> +			!res_counter_soft_limit_check_locked(c))
> +			*soft_limit_fail_at = c;
>  		spin_unlock(&c->lock);
>  		if (ret < 0) {
>  			*limit_fail_at = c;

Do we need these all check at every call ?
If you just check tree update once per HZ/?? , please check
this onece per HZ/??. And please help people who doesn't use softlimit
i.e. who doesn't mount cgroup but have to use configured kernel.



> +static struct rb_root mem_cgroup_soft_limit_tree;
> +static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
> +
Can't we breakd down this lock to per node or per cpu or...?

> +/*
>   * The memory controller data structure. The memory controller controls
> both
>   * page cache and RSS per cgroup. We would eventually like to provide
>   * statistics based on the statistics developed by Rik Van Riel for
> clock-pro,
> @@ -176,12 +185,20 @@ struct mem_cgroup {
>
>  	unsigned int	swappiness;
>
> +	struct rb_node mem_cgroup_node;		/* RB tree node */
> +	unsigned long long usage_in_excess;	/* Set to the value by which */
> +						/* the soft limit is exceeded*/
> +	unsigned long last_tree_update;		/* Last time the tree was */
> +						/* updated in jiffies     */
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
>  	struct mem_cgroup_stat stat;
>  };
>
> +#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
> +

Why HZ/4 again.

>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
>  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> @@ -214,6 +231,41 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>
> +static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> +{
> +	struct rb_node **p = &mem_cgroup_soft_limit_tree.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct mem_cgroup *mem_node;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
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
> +			&mem_cgroup_soft_limit_tree);
> +	mem->last_tree_update = jiffies;
> +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> +}
> +
> +static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> +{
> +	unsigned long flags;
> +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> +	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
> +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> +}
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
>  					 bool charge)
> @@ -897,6 +949,40 @@ static void record_last_oom(struct mem_cgroup *mem)
>  	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
>  }
>
> +static void mem_cgroup_check_and_update_tree(struct mem_cgroup *mem,
> +						bool time_check)
> +{
> +	unsigned long long prev_usage_in_excess, new_usage_in_excess;
> +	bool updated_tree = false;
> +	unsigned long next_update = 0;
> +	unsigned long flags;
> +
> +	prev_usage_in_excess = mem->usage_in_excess;
> +
> +	if (time_check)
> +		next_update = mem->last_tree_update +
> +				MEM_CGROUP_TREE_UPDATE_INTERVAL;
> +
> +	if (!time_check || time_after(jiffies, next_update)) {
> +		new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> +		if (prev_usage_in_excess) {
> +			mem_cgroup_remove_exceeded(mem);
> +			updated_tree = true;
> +		}
> +		if (!new_usage_in_excess)
> +			goto done;
> +		mem_cgroup_insert_exceeded(mem);
> +		updated_tree = true;
> +	}
> +
> +done:
> +	if (updated_tree) {
> +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> +		mem->last_tree_update = jiffies;
> +		mem->usage_in_excess = new_usage_in_excess;
> +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> +	}
> +}
Why update key parameter after inserting tree ? Is this bug ?
Maybe RB-tree will be not sorted.

Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
