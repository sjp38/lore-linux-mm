Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 457116B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:10:12 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D787Jb032236
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:08:07 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D7AFCB422132
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:10:19 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D79v3p020617
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:09:57 +1100
Date: Fri, 13 Mar 2009 12:39:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
Message-ID: <20090313070947.GJ16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <20090312175625.17890.94795.sendpatchset@localhost.localdomain> <cfa8f3be8873274b74d5c5bd0dbcb532.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <cfa8f3be8873274b74d5c5bd0dbcb532.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-13 15:59:49]:

> Balbir Singh wrote:
> > Feature: Organize cgroups over soft limit in a RB-Tree
> >
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> >
> > Changelog v5...v4
> > 1. res_counter_uncharge has an additional parameter to indicate if the
> >    counter was over its soft limit, before uncharge.
> >
> > Changelog v4...v3
> > 1. Optimizations to ensure we don't uncessarily get res_counter values
> > 2. Fixed a bug in usage of time_after()
> >
> > Changelog v3...v2
> > 1. Add only the ancestor to the RB-Tree
> > 2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put
> >
> > Changelog v2...v1
> > 1. Add support for hierarchies
> > 2. The res_counter that is highest in the hierarchy is returned on soft
> >    limit being exceeded. Since we do hierarchical reclaim and add all
> >    groups exceeding their soft limits, this approach seems to work well
> >    in practice.
> >
> > This patch introduces a RB-Tree for storing memory cgroups that are over
> > their
> > soft limit. The overall goal is to
> >
> > 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
> >    We are careful about updates, updates take place only after a
> > particular
> >    time interval has passed
> > 2. We remove the node from the RB-Tree when the usage goes below the soft
> >    limit
> >
> > The next set of patches will exploit the RB-Tree to get the group that is
> > over its soft limit by the largest amount and reclaim from it, when we
> > face memory contention.
> >
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> >
> >  include/linux/res_counter.h |    6 +-
> >  kernel/res_counter.c        |   18 +++++
> >  mm/memcontrol.c             |  141
> > ++++++++++++++++++++++++++++++++++++++-----
> >  3 files changed, 143 insertions(+), 22 deletions(-)
> >
> >
> > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > index 5c821fd..5bbf8b1 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -112,7 +112,8 @@ void res_counter_init(struct res_counter *counter,
> > struct res_counter *parent);
> >  int __must_check res_counter_charge_locked(struct res_counter *counter,
> >  		unsigned long val);
> >  int __must_check res_counter_charge(struct res_counter *counter,
> > -		unsigned long val, struct res_counter **limit_fail_at);
> > +		unsigned long val, struct res_counter **limit_fail_at,
> > +		struct res_counter **soft_limit_at);
> >
> >  /*
> >   * uncharge - tell that some portion of the resource is released
> > @@ -125,7 +126,8 @@ int __must_check res_counter_charge(struct res_counter
> > *counter,
> >   */
> >
> >  void res_counter_uncharge_locked(struct res_counter *counter, unsigned
> > long val);
> > -void res_counter_uncharge(struct res_counter *counter, unsigned long
> > val);
> > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > +				bool *was_soft_limit_excess);
> >
> >  static inline bool res_counter_limit_check_locked(struct res_counter
> > *cnt)
> >  {
> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > index 4e6dafe..51ec438 100644
> > --- a/kernel/res_counter.c
> > +++ b/kernel/res_counter.c
> > @@ -37,17 +37,27 @@ int res_counter_charge_locked(struct res_counter
> > *counter, unsigned long val)
> >  }
> >
> >  int res_counter_charge(struct res_counter *counter, unsigned long val,
> > -			struct res_counter **limit_fail_at)
> > +			struct res_counter **limit_fail_at,
> > +			struct res_counter **soft_limit_fail_at)
> >  {
> >  	int ret;
> >  	unsigned long flags;
> >  	struct res_counter *c, *u;
> >
> >  	*limit_fail_at = NULL;
> > +	if (soft_limit_fail_at)
> > +		*soft_limit_fail_at = NULL;
> >  	local_irq_save(flags);
> >  	for (c = counter; c != NULL; c = c->parent) {
> >  		spin_lock(&c->lock);
> >  		ret = res_counter_charge_locked(c, val);
> > +		/*
> > +		 * With soft limits, we return the highest ancestor
> > +		 * that exceeds its soft limit
> > +		 */
> > +		if (soft_limit_fail_at &&
> > +			!res_counter_soft_limit_check_locked(c))
> > +			*soft_limit_fail_at = c;
> >  		spin_unlock(&c->lock);
> >  		if (ret < 0) {
> >  			*limit_fail_at = c;
> 
> Do we need these all check at every call ?
> If you just check tree update once per HZ/?? , please check
> this onece per HZ/??. And please help people who doesn't use softlimit
> i.e. who doesn't mount cgroup but have to use configured kernel.
> 
> 
> 
> > +static struct rb_root mem_cgroup_soft_limit_tree;
> > +static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
> > +
> Can't we breakd down this lock to per node or per cpu or...?
>

I responded to the same comment by Kosaki.
 
> > +/*
> >   * The memory controller data structure. The memory controller controls
> > both
> >   * page cache and RSS per cgroup. We would eventually like to provide
> >   * statistics based on the statistics developed by Rik Van Riel for
> > clock-pro,
> > @@ -176,12 +185,20 @@ struct mem_cgroup {
> >
> >  	unsigned int	swappiness;
> >
> > +	struct rb_node mem_cgroup_node;		/* RB tree node */
> > +	unsigned long long usage_in_excess;	/* Set to the value by which */
> > +						/* the soft limit is exceeded*/
> > +	unsigned long last_tree_update;		/* Last time the tree was */
> > +						/* updated in jiffies     */
> > +
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> >  	 */
> >  	struct mem_cgroup_stat stat;
> >  };
> >
> > +#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
> > +
> 
> Why HZ/4 again.
> 

Good question. HZ/4 is not too aggressive or not to lax. The value is
empirical.


> >  enum charge_type {
> >  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
> >  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> > @@ -214,6 +231,41 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >
> > +static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> > +{
> > +	struct rb_node **p = &mem_cgroup_soft_limit_tree.rb_node;
> > +	struct rb_node *parent = NULL;
> > +	struct mem_cgroup *mem_node;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	while (*p) {
> > +		parent = *p;
> > +		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
> > +		if (mem->usage_in_excess < mem_node->usage_in_excess)
> > +			p = &(*p)->rb_left;
> > +		/*
> > +		 * We can't avoid mem cgroups that are over their soft
> > +		 * limit by the same amount
> > +		 */
> > +		else if (mem->usage_in_excess >= mem_node->usage_in_excess)
> > +			p = &(*p)->rb_right;
> > +	}
> > +	rb_link_node(&mem->mem_cgroup_node, parent, p);
> > +	rb_insert_color(&mem->mem_cgroup_node,
> > +			&mem_cgroup_soft_limit_tree);
> > +	mem->last_tree_update = jiffies;
> > +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +}
> > +
> > +static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> > +{
> > +	unsigned long flags;
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
> > +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +}
> > +
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >  					 struct page_cgroup *pc,
> >  					 bool charge)
> > @@ -897,6 +949,40 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> >  }
> >
> > +static void mem_cgroup_check_and_update_tree(struct mem_cgroup *mem,
> > +						bool time_check)
> > +{
> > +	unsigned long long prev_usage_in_excess, new_usage_in_excess;
> > +	bool updated_tree = false;
> > +	unsigned long next_update = 0;
> > +	unsigned long flags;
> > +
> > +	prev_usage_in_excess = mem->usage_in_excess;
> > +
> > +	if (time_check)
> > +		next_update = mem->last_tree_update +
> > +				MEM_CGROUP_TREE_UPDATE_INTERVAL;
> > +
> > +	if (!time_check || time_after(jiffies, next_update)) {
> > +		new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > +		if (prev_usage_in_excess) {
> > +			mem_cgroup_remove_exceeded(mem);
> > +			updated_tree = true;
> > +		}
> > +		if (!new_usage_in_excess)
> > +			goto done;
> > +		mem_cgroup_insert_exceeded(mem);
> > +		updated_tree = true;
> > +	}
> > +
> > +done:
> > +	if (updated_tree) {
> > +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +		mem->last_tree_update = jiffies;
> > +		mem->usage_in_excess = new_usage_in_excess;
> > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +	}
> > +}
> Why update key parameter after inserting tree ? Is this bug ?
> Maybe RB-tree will be not sorted.
>

Hmm.. I'll revisit. Thanks!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
