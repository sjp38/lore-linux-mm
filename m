Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49D166B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 04:35:36 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2G8ZK4f001362
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:05:20 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2G8W2Y23088532
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:02:02 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2G8ZJe1010163
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 19:35:19 +1100
Date: Mon, 16 Mar 2009 14:05:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090316083512.GV16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain> <20090314173111.16591.68465.sendpatchset@localhost.localdomain> <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 09:52:58]:

> On Sat, 14 Mar 2009 23:01:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> >  include/linux/memcontrol.h |    8 ++
> >  include/linux/swap.h       |    1 
> >  mm/memcontrol.c            |  205 ++++++++++++++++++++++++++++++++++++++++----
> >  mm/page_alloc.c            |    9 ++
> >  mm/vmscan.c                |    5 +
> >  5 files changed, 205 insertions(+), 23 deletions(-)
> > 
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 18146c9..b99d9c5 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -116,7 +116,8 @@ static inline bool mem_cgroup_disabled(void)
> >  }
> >  
> >  extern bool mem_cgroup_oom_called(struct task_struct *task);
> > -
> > +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl,
> > +						gfp_t gfp_mask);
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> >  
> > @@ -264,6 +265,11 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  {
> >  }
> >  
> > +static inline
> > +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
> > +{
> > +	return 0;
> > +}
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >  
> >  #endif /* _LINUX_MEMCONTROL_H */
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 989eb53..c128337 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -215,6 +215,7 @@ static inline void lru_cache_add_active_file(struct page *page)
> >  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> >  					gfp_t gfp_mask);
> >  extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> > +						  struct zonelist *zl,
> >  						  gfp_t gfp_mask, bool noswap,
> >  						  unsigned int swappiness);
> >  extern int __isolate_lru_page(struct page *page, int mode, int file);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 200d44a..980bd18 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -191,6 +191,7 @@ struct mem_cgroup {
> >  	unsigned long last_tree_update;		/* Last time the tree was */
> >  						/* updated in jiffies     */
> >  
> > +	bool on_tree;				/* Is the node on tree? */
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> >  	 */
> > @@ -227,18 +228,29 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
> >  #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
> >  #define MEMFILE_ATTR(val)	((val) & 0xffff)
> >  
> > +/*
> > + * Bits used for hierarchical reclaim bits
> > + */
> > +#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
> > +#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
> > +#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
> > +#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
> > +#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
> > +#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
> > +
> Could you divide this clean-up part to other patch ?
>

OK, sure, I'll do that.
 
> 
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >  
> > -static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> > +static void __mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> >  {
> >  	struct rb_node **p = &mem_cgroup_soft_limit_tree.rb_node;
> >  	struct rb_node *parent = NULL;
> >  	struct mem_cgroup *mem_node;
> > -	unsigned long flags;
> >  
> > -	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	if (mem->on_tree)
> > +		return;
> > +
> >  	mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> >  	while (*p) {
> >  		parent = *p;
> > @@ -256,6 +268,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
> >  	rb_insert_color(&mem->mem_cgroup_node,
> >  			&mem_cgroup_soft_limit_tree);
> >  	mem->last_tree_update = jiffies;
> > +	mem->on_tree = true;
> > +}
> > +
> > +static void __mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> > +{
> > +	if (!mem->on_tree)
> > +		return;
> > +	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
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
> > @@ -263,8 +292,53 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
> >  {
> >  	unsigned long flags;
> >  	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > -	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
> > +	__mem_cgroup_remove_exceeded(mem);
> > +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +}
> > +
> > +unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
> > +{
> > +	unsigned long flags;
> > +	unsigned long long excess;
> > +
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	excess = mem->usage_in_excess >> PAGE_SHIFT;
> >  	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +	return (excess > ULONG_MAX) ? ULONG_MAX : excess;
> > +}
> > +
> > +static struct mem_cgroup *__mem_cgroup_largest_soft_limit_node(void)
> > +{
> > +	struct rb_node *rightmost = NULL;
> > +	struct mem_cgroup *mem = NULL;
> > +
> > +retry:
> > +	rightmost = rb_last(&mem_cgroup_soft_limit_tree);
> > +	if (!rightmost)
> > +		goto done;		/* Nothing to reclaim from */
> > +
> > +	mem = rb_entry(rightmost, struct mem_cgroup, mem_cgroup_node);
> > +	/*
> > +	 * Remove the node now but someone else can add it back,
> > +	 * we will to add it back at the end of reclaim to its correct
> > +	 * position in the tree.
> > +	 */
> > +	__mem_cgroup_remove_exceeded(mem);
> > +	if (!css_tryget(&mem->css) || !res_counter_soft_limit_excess(&mem->res))
> > +		goto retry;
> > +done:
> > +	return mem;
> > +}
> > +
> > +static struct mem_cgroup *mem_cgroup_largest_soft_limit_node(void)
> > +{
> > +	struct mem_cgroup *mem;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +	mem = __mem_cgroup_largest_soft_limit_node();
> > +	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +	return mem;
> >  }
> >  
> Can you think of avoiding this global-lock ?(As Kosaki said.)
> IIUC, cpu-scheduler's RB tree/hrtimer's one, you memtioned, is per-cpu.
>

I thought about it, but since the data structure is global, we need a
global lock. I've not yet seen a lot of contention on the lock. I'll
think more along the lines of seeing how to split up the lock, but I
don't see it right now.
 
> 
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> > @@ -889,14 +963,42 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> >   * If shrink==true, for avoiding to free too much, this returns immedieately.
> >   */
> >  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > -				   gfp_t gfp_mask, bool noswap, bool shrink)
> > +						struct zonelist *zl,
> > +						gfp_t gfp_mask,
> > +						unsigned long reclaim_options)
> >  {
> >  	struct mem_cgroup *victim;
> >  	int ret, total = 0;
> >  	int loop = 0;
> > +	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> > +	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> > +	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> > +	unsigned long excess = mem_cgroup_get_excess(root_mem);
> >  
> > -	while (loop < 2) {
> > +	while (1) {
> > +		if (loop >= 2) {
> > +			if (!check_soft)
> > +				break;
> > +			/*
> > +			 * We want to do more targetted reclaim. excess >> 4
> > +			 * >> 4 is not to excessive so as to reclaim too
> > +			 * much, nor too less that we keep coming back
> > +			 * to reclaim from this cgroup
> > +			 */
> > +			if (total >= (excess >> 4))
> > +				break;
> > +		}
> 
> I wonder this means, in very bad case, the thread cannot exit this loop...
> right ?

Potentially. When we do force empty, we actually reclaim all pages in a loop.
Do you want to see additional checks here?

> >  		victim = mem_cgroup_select_victim(root_mem);
> > +		/*
> > +		 * In the first loop, don't reclaim from victims below
> > +		 * their soft limit
> > +		 */
> > +		if (!loop && res_counter_check_under_soft_limit(&victim->res)) {
> > +			if (victim == root_mem)
> > +				loop++;
> > +			css_put(&victim->css);
> > +			continue;
> > +		}
> >  		if (victim == root_mem)
> >  			loop++;
> >  		if (!mem_cgroup_local_usage(&victim->stat)) {
> > @@ -905,8 +1007,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  			continue;
> >  		}
> >  		/* we use swappiness of local cgroup */
> > -		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
> > -						   get_swappiness(victim));
> > +		ret = try_to_free_mem_cgroup_pages(victim, zl, gfp_mask,
> > +							noswap,
> > +							get_swappiness(victim));
> >  		css_put(&victim->css);
> >  		/*
> >  		 * At shrinking usage, we can't check we should stop here or
> > @@ -916,7 +1019,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  		if (shrink)
> >  			return ret;
> >  		total += ret;
> > -		if (mem_cgroup_check_under_limit(root_mem))
> > +		if (check_soft) {
> > +			if (res_counter_check_under_soft_limit(&root_mem->res))
> > +				return total;
> > +		} else if (mem_cgroup_check_under_limit(root_mem))
> >  			return 1 + total;
> >  	}
> >  	return total;
> > @@ -1022,7 +1128,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  
> >  	while (1) {
> >  		int ret;
> > -		bool noswap = false;
> > +		unsigned long flags = 0;
> >  
> >  		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
> >  						&soft_fail_res);
> > @@ -1035,7 +1141,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  				break;
> >  			/* mem+swap counter fails */
> >  			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> > -			noswap = true;
> > +			flags = MEM_CGROUP_RECLAIM_NOSWAP;
> >  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> >  									memsw);
> >  		} else
> > @@ -1046,8 +1152,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto nomem;
> >  
> > -		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> > -							noswap, false);
> > +		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > +							gfp_mask, flags);
> >  		if (ret)
> >  			continue;
> >  
> > @@ -1757,8 +1863,8 @@ int mem_cgroup_shrink_usage(struct page *page,
> >  		return 0;
> >  
> >  	do {
> > -		progress = mem_cgroup_hierarchical_reclaim(mem,
> > -					gfp_mask, true, false);
> > +		progress = mem_cgroup_hierarchical_reclaim(mem, NULL,
> > +					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
> >  		progress += mem_cgroup_check_under_limit(mem);
> >  	} while (!progress && --retry);
> >  
> > @@ -1812,8 +1918,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >  		if (!ret)
> >  			break;
> >  
> > -		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> > -						   false, true);
> > +		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
> > +						GFP_KERNEL,
> > +						MEM_CGROUP_RECLAIM_SHRINK);
> >  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> >  		/* Usage is reduced ? */
> >    		if (curusage >= oldusage)
> > @@ -1861,7 +1968,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  		if (!ret)
> >  			break;
> >  
> > -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
> > +		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> > +						MEM_CGROUP_RECLAIM_NOSWAP |
> > +						MEM_CGROUP_RECLAIM_SHRINK);
> >  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> >  		/* Usage is reduced ? */
> >  		if (curusage >= oldusage)
> > @@ -1872,6 +1981,62 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  	return ret;
> >  }
> >  
> > +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
> > +{
> > +	unsigned long nr_reclaimed = 0;
> > +	struct mem_cgroup *mem, *next_mem = NULL;
> > +	unsigned long flags;
> > +	unsigned long reclaimed;
> > +
> > +	/*
> > +	 * This loop can run a while, specially if mem_cgroup's continuously
> > +	 * keep exceeding their soft limit and putting the system under
> > +	 * pressure
> > +	 */
> > +	do {
> > +		if (next_mem)
> > +			mem = next_mem;
> > +		else
> > +			mem = mem_cgroup_largest_soft_limit_node();
> > +		if (!mem)
> > +			break;
> > +
> > +		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
> > +						gfp_mask,
> > +						MEM_CGROUP_RECLAIM_SOFT);
> > +		nr_reclaimed += reclaimed;
> > +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +
> > +		/*
> > +		 * If we failed to reclaim anything from this memory cgroup
> > +		 * it is time to move on to the next cgroup
> > +		 */
> > +		next_mem = NULL;
> > +		if (!reclaimed) {
> > +			do {
> > +				/*
> > +				 * By the time we get the soft_limit lock
> > +				 * again, someone might have aded the
> > +				 * group back on the RB tree. Iterate to
> > +				 * make sure we get a different mem.
> > +				 * mem_cgroup_largest_soft_limit_node returns
> > +				 * NULL if no other cgroup is present on
> > +				 * the tree
> > +				 */
> Do we have to allow "someone will push back" case ?
> 

Not sure I understand your comment completely? When you say push back,
are you referring to some one else adding back the RB-Tree to the
node? If so, yes, that is quite possible and I've seen it happen.

> > +				next_mem =
> > +					__mem_cgroup_largest_soft_limit_node();
> > +			} while (next_mem == mem);
> > +		}
> > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > +		__mem_cgroup_remove_exceeded(mem);
> > +		if (mem->usage_in_excess)
> > +			__mem_cgroup_insert_exceeded(mem);
> 
> If next_mem == NULL here, (means "mem" is an only mem_cgroup which excess softlimit.)
> mem will be found again even if !reclaimed.
> plz check.

Yes, We need to add a if (!next_mem) break; Thanks!

> 
> > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +		css_put(&mem->css);
> > +	} while (!nr_reclaimed);
> > +	return nr_reclaimed;
> > +}
> > +
> >  /*
> >   * This routine traverse page_cgroup in given list and drop them all.
> >   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> > @@ -1995,7 +2160,7 @@ try_to_free:
> >  			ret = -EINTR;
> >  			goto out;
> >  		}
> > -		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > +		progress = try_to_free_mem_cgroup_pages(mem, NULL, GFP_KERNEL,
> >  						false, get_swappiness(mem));
> >  		if (!progress) {
> >  			nr_retries--;
> > @@ -2600,6 +2765,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	mem->last_scanned_child = 0;
> >  	mem->usage_in_excess = 0;
> >  	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
> > +	mem->on_tree = false;
> > +
> >  	spin_lock_init(&mem->reclaim_param_lock);
> >  
> >  	if (parent)
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f8fd1e2..5e1a6ca 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1598,7 +1598,14 @@ nofail_alloc:
> >  	reclaim_state.reclaimed_slab = 0;
> >  	p->reclaim_state = &reclaim_state;
> >  
> > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > +	/*
> > +	 * Try to free up some pages from the memory controllers soft
> > +	 * limit queue.
> > +	 */
> > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > +	if (order || !did_some_progress)
> > +		did_some_progress += try_to_free_pages(zonelist, order,
> > +							gfp_mask);
> I'm not sure but do we have to call try_to_free()...twice ?

We call it twice, once for the memory controller and once for normal
reclaim (try_to_free_mem_cgroup_pages() and try_to_free_pages()), is
that an issue?

> 
> if (order)
>    did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);       
> if (!order || did_some_progrees)
>    did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
>

I don't understand the code snippet above.
 
> IIRC, why Kosaki said "don't check order" is because this was called by kswapd() case.
> 
> BTW, mem_cgroup_soft_limit_reclaim() can do enough job even under 
> (gfp_mask & (__GFP_IO|__GFP_FS)) == 0 case ?
>

What about clean page cache? Anyway, we pass the gfp_mask, so the reclaimer
knows what pages to reclaim from, so it should return quickly if it
can't reclaim. Am I missing something?
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
