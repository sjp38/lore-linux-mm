Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28A4E6B00E2
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:12:20 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n1H3CAOK027435
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:12:10 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1H3CElM381348
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:12:14 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1H3CD2k027782
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:12:14 +1100
Date: Tue, 17 Feb 2009 08:42:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/4] Memory controller soft limit reclaim on
	contention (v2)
Message-ID: <20090217031204.GB20958@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain> <20090216110916.29795.41945.sendpatchset@localhost.localdomain> <20090217100001.8BCC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090217100001.8BCC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-17 10:20:44]:

> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v2...v1
> > 1. Added support for hierarchical soft limits
> > 
> > This patch allows reclaim from memory cgroups on contention (via the
> > __alloc_pages_internal() path). If a order greater than 0 is specified, we
> > anyway fall back on try_to_free_pages().
> > 
> > memory cgroup soft limit reclaim finds the group that exceeds its soft limit
> > by the largest amount and reclaims pages from it and then reinserts the
> > cgroup into its correct place in the rbtree.
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> > 
> >  include/linux/memcontrol.h |    1 
> >  mm/memcontrol.c            |  105 +++++++++++++++++++++++++++++++++++++++-----
> >  mm/page_alloc.c            |   10 ++++
> >  3 files changed, 104 insertions(+), 12 deletions(-)
> > 
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 18146c9..a50f73e 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -116,6 +116,7 @@ static inline bool mem_cgroup_disabled(void)
> >  }
> >  
> >  extern bool mem_cgroup_oom_called(struct task_struct *task);
> > +extern unsigned long mem_cgroup_soft_limit_reclaim(gfp_t gfp_mask);
> >  
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a2617ac..dd835d3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -188,6 +188,7 @@ struct mem_cgroup {
> >  	struct rb_node mem_cgroup_node;
> >  	unsigned long long usage_in_excess;
> >  	unsigned long last_tree_update;
> > +	bool on_tree;
> >  
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> > @@ -195,7 +196,7 @@ struct mem_cgroup {
> >  	struct mem_cgroup_stat stat;
> >  };
> >  
> > -#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ)
> > +#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
> 
> ??
> moving [3/4] is proper more?
>

Yes, I can move it there. Thanks!
 
> 
> >  
> >  enum charge_type {
> >  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
> > @@ -229,14 +230,15 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >  
> > -static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> > +static void __mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> >  {
> >  	struct rb_node **p = &mem_cgroup_soft_limit_exceeded_groups.rb_node;
> >  	struct rb_node *parent = NULL;
> >  	struct mem_cgroup *mem_node;
> > -	unsigned long flags;
> >  
> > -	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	if (mem->on_tree)
> > +		return;
> > +
> >  	while (*p) {
> >  		parent = *p;
> >  		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
> > @@ -253,6 +255,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> >  	rb_insert_color(&mem->mem_cgroup_node,
> >  			&mem_cgroup_soft_limit_exceeded_groups);
> >  	mem->last_tree_update = jiffies;
> > +	mem->on_tree = true;
> > +}
> > +
> > +static void __mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> > +{
> > +	if (!mem->on_tree)
> > +		return;
> > +	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
> > +	mem->on_tree = false;
> > +}
> > +
> > +static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	__mem_cgroup_insert_exceeded(mem);
> >  	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> >  }
> >  
> > @@ -260,10 +279,34 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> >  {
> >  	unsigned long flags;
> >  	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > -	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
> > +	__mem_cgroup_remove_exceeded(mem);
> >  	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> >  }
> >  
> > +static struct mem_cgroup *mem_cgroup_get_largest_soft_limit_exceeding_node(void)
> > +{
> > +	struct rb_node *rightmost = NULL;
> > +	struct mem_cgroup *mem = NULL;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	rightmost = rb_last(&mem_cgroup_soft_limit_exceeded_groups);
> > +	if (!rightmost)
> > +		goto done;		/* Nothing to reclaim from */
> > +
> > +	mem = rb_entry(rightmost, struct mem_cgroup, mem_cgroup_node);
> > +	mem_cgroup_get(mem);
> > +	/*
> > +	 * Remove the node now but someone else can add it back,
> > +	 * we will to add it back at the end of reclaim to its correct
> > +	 * position in the tree.
> > +	 */
> > +	__mem_cgroup_remove_exceeded(mem);
> > +done:
> > +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +	return mem;
> > +}
> > +
> 
> Do you remember we discuss about zone reclaim balancing thing 
> in "reclaim bail out"thread at about 2 month ago?
>
> The "largest exceeding" policy seems to have similar problems.
> if largest exceeding group is most active, 
> 
>   1. do the largest group activity and charge memory over softlimit.
>   2. reclaim memory from the largest group.
>   3. goto 1.
> 
> then, system can become livelock.
>

What other alternative do you recommend? Reclaiming memory from an
over active group that is over its assigned usage is not a livelock
scenario, do you see it that way?
 
> I think per-group priority is not good idea.
>

Not sure I understand this part.
 
> 
> 
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >  					 struct page_cgroup *pc,
> >  					 bool charge)
> > @@ -886,7 +929,8 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> >   * If shrink==true, for avoiding to free too much, this returns immedieately.
> >   */
> >  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > -				   gfp_t gfp_mask, bool noswap, bool shrink)
> > +				   gfp_t gfp_mask, bool noswap, bool shrink,
> > +				   bool check_soft)
> 
> Now, we get three boolean argument.
> So, can we convert "int flags" argument?
> 
> I don't think mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, false, true, false) is
> self-described good look.
> 
> 
> >  {
> >  	struct mem_cgroup *victim;
> >  	int ret, total = 0;
> > @@ -913,7 +957,11 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  		if (shrink)
> >  			return ret;
> >  		total += ret;
> > -		if (mem_cgroup_check_under_limit(root_mem))
> > +
> > +		if (check_soft) {
> > +			if (res_counter_soft_limit_excess(&root_mem->res))
> > +				return 1 + total;
> > +		} else if (mem_cgroup_check_under_limit(root_mem))
> >  			return 1 + total;
> 
> I don't understand what's mean "1 +".
> 
> 
> >  	}
> >  	return total;
> > @@ -1044,7 +1092,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  			goto nomem;
> >  
> >  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> > -							noswap, false);
> > +							noswap, false, false);
> >  		if (ret)
> >  			continue;
> >  
> > @@ -1686,7 +1734,7 @@ int mem_cgroup_shrink_usage(struct page *page,
> >  
> >  	do {
> >  		progress = mem_cgroup_hierarchical_reclaim(mem,
> > -					gfp_mask, true, false);
> > +					gfp_mask, true, false, false);
> >  		progress += mem_cgroup_check_under_limit(mem);
> >  	} while (!progress && --retry);
> >  
> > @@ -1741,7 +1789,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >  			break;
> >  
> >  		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> > -						   false, true);
> > +						   false, true, false);
> >  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> >  		/* Usage is reduced ? */
> >    		if (curusage >= oldusage)
> > @@ -1789,7 +1837,8 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  		if (!ret)
> >  			break;
> >  
> > -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
> > +		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true,
> > +						false);
> >  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> >  		/* Usage is reduced ? */
> >  		if (curusage >= oldusage)
> > @@ -1940,6 +1989,38 @@ try_to_free:
> >  	goto out;
> >  }
> >  
> > +unsigned long mem_cgroup_soft_limit_reclaim(gfp_t gfp_mask)
> > +{
> > +	unsigned long nr_reclaimed = 0;
> > +	struct mem_cgroup *mem;
> > +	unsigned long flags;
> > +
> > +	do {
> > +		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
> > +		if (!mem)
> > +			break;
> > +		if (mem_cgroup_is_obsolete(mem)) {
> > +			mem_cgroup_put(mem);
> > +			continue;
> > +		}
> > +		nr_reclaimed +=
> > +			mem_cgroup_hierarchical_reclaim(mem, gfp_mask, false,
> > +							false, true);
> > +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > +		/*
> > +		 * We need to remove and reinsert the node in its correct
> > +		 * position
> > +		 */
> > +		__mem_cgroup_remove_exceeded(mem);
> > +		if (mem->usage_in_excess)
> > +			__mem_cgroup_insert_exceeded(mem);
> > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +		mem_cgroup_put(mem);
> > +	} while (!nr_reclaimed);
> > +	return nr_reclaimed;
> > +}
> 
> this function is called from reclaim hotpath. but it grab glocal spin lock..
> I don't like this.
> 
> 
> > +
> >  int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> >  {
> >  	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
> > @@ -2528,6 +2609,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	mem->last_scanned_child = 0;
> >  	mem->usage_in_excess = 0;
> >  	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
> > +	mem->on_tree = false;
> > +
> >  	spin_lock_init(&mem->reclaim_param_lock);
> >  
> >  	if (parent)
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 7be9386..c50e29b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1579,7 +1579,15 @@ nofail_alloc:
> >  	reclaim_state.reclaimed_slab = 0;
> >  	p->reclaim_state = &reclaim_state;
> >  
> > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > +	did_some_progress = mem_cgroup_soft_limit_reclaim(gfp_mask);
> > +	/*
> > +	 * If we made no progress or need higher order allocations
> > +	 * try_to_free_pages() is still our best bet, since mem_cgroup
> > +	 * reclaim does not handle freeing pages greater than order 0
> > +	 */
> > +	if (!did_some_progress || order)
> > +		did_some_progress = try_to_free_pages(zonelist, order,
> > +							gfp_mask);
> >  
> >  	p->reclaim_state = NULL;
> >  	p->flags &= ~PF_MEMALLOC;
> 
> this is very freqently called place. then we want to
>   - if no memcgroup using, no performance regression.
>   - if no softlimit but using memcg, performance degression is smaller than 1%.
> 
> Do you have any performance number?
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
