Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B218B6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 01:10:07 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A5WCiN009433
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 14:32:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C0A5545DE50
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:32:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A683145DE4F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:32:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A6441DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:32:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 09C6A1DB803F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:32:09 +0900 (JST)
Date: Fri, 10 Jul 2009 14:30:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
 contention (v8)
Message-Id: <20090710143026.4de7d4b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709171512.8080.8138.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	<20090709171512.8080.8138.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 09 Jul 2009 22:45:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Implement reclaim from groups over their soft limit
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v8 ..v7
> 1. Soft limit reclaim takes an order parameter and does no reclaim for
>    order > 0. This ensures that we don't do double reclaim for order > 0
> 2. Make the data structures more scalable, move the reclaim logic
>    to a new function mem_cgroup_shrink_node_zone that does per node
>    per zone reclaim.
> 3. Reclaim has moved back to kswapd (balance_pgdat)
> 
> Changelog v7...v6
> 1. Refactored out reclaim_options patch into a separate patch
> 2. Added additional checks for all swap off condition in
>    mem_cgroup_hierarchical_reclaim()
> 
> Changelog v6...v5
> 1. Reclaim arguments to hierarchical reclaim have been merged into one
>    parameter called reclaim_options.
> 2. Check if we failed to reclaim from one cgroup during soft reclaim, if
>    so move on to the next one. This can be very useful if the zonelist
>    passed to soft limit reclaim has no allocations from the selected
>    memory cgroup
> 3. Coding style cleanups
> 
> Changelog v5...v4
> 
> 1. Throttling is removed, earlier we throttled tasks over their soft limit
> 2. Reclaim has been moved back to __alloc_pages_internal, several experiments
>    and tests showed that it was the best place to reclaim memory. kswapd has
>    a different goal, that does not work with a single soft limit for the memory
>    cgroup.
> 3. Soft limit reclaim is more targetted and the pages reclaim depend on the
>    amount by which the soft limit is exceeded.
> 
> Changelog v4...v3
> 1. soft_reclaim is now called from balance_pgdat
> 2. soft_reclaim is aware of nodes and zones
> 3. A mem_cgroup will be throttled if it is undergoing soft limit reclaim
>    and at the same time trying to allocate pages and exceed its soft limit.
> 4. A new mem_cgroup_shrink_zone() routine has been added to shrink zones
>    particular to a mem cgroup.
> 
> Changelog v3...v2
> 1. Convert several arguments to hierarchical reclaim to flags, thereby
>    consolidating them
> 2. The reclaim for soft limits is now triggered from kswapd
> 3. try_to_free_mem_cgroup_pages() now accepts an optional zonelist argument
> 
> 
> Changelog v2...v1
> 1. Added support for hierarchical soft limits
> 
> This patch allows reclaim from memory cgroups on contention (via the
> direct reclaim path).
> 
> memory cgroup soft limit reclaim finds the group that exceeds its soft limit
> by the largest number of pages and reclaims pages from it and then reinserts the
> cgroup into its correct place in the rbtree.
> 
> Added additional checks to mem_cgroup_hierarchical_reclaim() to detect
> long loops in case all swap is turned off. The code has been refactored
> and the loop check (loop < 2) has been enhanced for soft limits. For soft
> limits, we try to do more targetted reclaim. Instead of bailing out after
> two loops, the routine now reclaims memory proportional to the size by
> which the soft limit is exceeded. The proportion has been empirically
> determined.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/memcontrol.h |   11 ++
>  include/linux/swap.h       |    5 +
>  mm/memcontrol.c            |  224 +++++++++++++++++++++++++++++++++++++++++---
>  mm/vmscan.c                |   39 +++++++-
>  4 files changed, 262 insertions(+), 17 deletions(-)
> 
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index e46a073..cf20acc 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -118,6 +118,9 @@ static inline bool mem_cgroup_disabled(void)
>  
>  extern bool mem_cgroup_oom_called(struct task_struct *task);
>  void mem_cgroup_update_mapped_file_stat(struct page *page, int val);
> +unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> +						gfp_t gfp_mask, int nid,
> +						int zid, int priority);
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> @@ -276,6 +279,14 @@ static inline void mem_cgroup_update_mapped_file_stat(struct page *page,
>  {
>  }
>  
> +static inline
> +unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> +						gfp_t gfp_mask, int nid,
> +						int zid, int priority)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 6c990e6..afc0721 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -217,6 +217,11 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
>  						  gfp_t gfp_mask, bool noswap,
>  						  unsigned int swappiness);
> +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> +						gfp_t gfp_mask, bool noswap,
> +						unsigned int swappiness,
> +						struct zone *zone,
> +						int nid, int priority);
>  extern int __isolate_lru_page(struct page *page, int mode, int file);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ca9c257..e7a1cf4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -124,6 +124,9 @@ struct mem_cgroup_per_zone {
>  						/* updated in jiffies     */
>  	unsigned long long	usage_in_excess;/* Set to the value by which */
>  						/* the soft limit is exceeded*/
> +	bool on_tree;				/* Is the node on tree? */
> +	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
> +						/* use container_of	   */
>  };
>  /* Macro for accessing counter */
>  #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
> @@ -216,6 +219,13 @@ struct mem_cgroup {
>  
>  #define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
>  
> +/*
> + * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> + * limit reclaim to prevent infinite loops, if they ever occur.
> + */
> +#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(10000)
> +#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
> +
>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
>  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> @@ -247,6 +257,8 @@ enum charge_type {
>  #define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>  #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
> +#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
> +#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
>  
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
> @@ -287,16 +299,17 @@ page_cgroup_soft_limit_tree(struct page_cgroup *pc)
>  }
>  
>  static void
> -mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
> +__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
>  				struct mem_cgroup_per_zone *mz,
>  				struct mem_cgroup_soft_limit_tree_per_zone *stz)
>  {
>  	struct rb_node **p = &stz->rb_root.rb_node;
>  	struct rb_node *parent = NULL;
>  	struct mem_cgroup_per_zone *mz_node;
> -	unsigned long flags;
>  
> -	spin_lock_irqsave(&stz->lock, flags);
> +	if (mz->on_tree)
> +		return;
> +
>  	mz->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
>  	while (*p) {
>  		parent = *p;
> @@ -314,6 +327,29 @@ mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
>  	rb_link_node(&mz->tree_node, parent, p);
>  	rb_insert_color(&mz->tree_node, &stz->rb_root);
>  	mz->last_tree_update = jiffies;
> +	mz->on_tree = true;
> +}
> +
> +static void
> +__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
> +				struct mem_cgroup_per_zone *mz,
> +				struct mem_cgroup_soft_limit_tree_per_zone *stz)
> +{
> +	if (!mz->on_tree)
> +		return;
> +	rb_erase(&mz->tree_node, &stz->rb_root);
> +	mz->on_tree = false;
> +}
> +
> +static void
> +mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
> +				struct mem_cgroup_per_zone *mz,
> +				struct mem_cgroup_soft_limit_tree_per_zone *stz)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&stz->lock, flags);
> +	__mem_cgroup_insert_exceeded(mem, mz, stz);
>  	spin_unlock_irqrestore(&stz->lock, flags);
>  }
>  
> @@ -324,7 +360,7 @@ mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
>  {
>  	unsigned long flags;
>  	spin_lock_irqsave(&stz->lock, flags);
> -	rb_erase(&mz->tree_node, &stz->rb_root);
> +	__mem_cgroup_remove_exceeded(mem, mz, stz);
>  	spin_unlock_irqrestore(&stz->lock, flags);
>  }
>  
> @@ -410,6 +446,52 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
>  	}
>  }
>  
> +unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
> +{
> +	unsigned long excess;
> +	excess = res_counter_soft_limit_excess(&mem->res) >> PAGE_SHIFT;
> +	return (excess > ULONG_MAX) ? ULONG_MAX : excess;
> +}
> +
What this means ? excess can be bigger than ULONG_MAX even after >> PAGE_SHIFT ?



> +static struct mem_cgroup_per_zone *
> +__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_soft_limit_tree_per_zone
> +					*stz)
> +{
> +	struct rb_node *rightmost = NULL;
> +	struct mem_cgroup_per_zone *mz = NULL;
> +
> +retry:
> +	rightmost = rb_last(&stz->rb_root);
> +	if (!rightmost)
> +		goto done;		/* Nothing to reclaim from */
> +
> +	mz = rb_entry(rightmost, struct mem_cgroup_per_zone, tree_node);
> +	/*
> +	 * Remove the node now but someone else can add it back,
> +	 * we will to add it back at the end of reclaim to its correct
> +	 * position in the tree.
> +	 */
> +	__mem_cgroup_remove_exceeded(mz->mem, mz, stz);
> +	if (!css_tryget(&mz->mem->css) ||
> +		!res_counter_soft_limit_excess(&mz->mem->res))
> +		goto retry;
This leaks css's refcnt. plz invert order as

	if (!res_counter_xxxxx() || !css_tryget())



> +done:
> +	return mz;
> +}
> +
> +static struct mem_cgroup_per_zone *
> +mem_cgroup_largest_soft_limit_node(struct mem_cgroup_soft_limit_tree_per_zone
> +					*stz)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&stz->lock, flags);
> +	mz = __mem_cgroup_largest_soft_limit_node(stz);
> +	spin_unlock_irqrestore(&stz->lock, flags);
> +	return mz;
> +}
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
>  					 bool charge)
> @@ -1038,31 +1120,59 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>   * If shrink==true, for avoiding to free too much, this returns immedieately.
>   */
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> +						struct zone *zone,
>  						gfp_t gfp_mask,
> -						unsigned long reclaim_options)
> +						unsigned long reclaim_options,
> +						int priority)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
>  	int loop = 0;
>  	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
>  	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> +	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> +	unsigned long excess = mem_cgroup_get_excess(root_mem);
>  
>  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
>  	if (root_mem->memsw_is_minimum)
>  		noswap = true;
>  
> -	while (loop < 2) {
> +	while (1) {
>  		victim = mem_cgroup_select_victim(root_mem);
> -		if (victim == root_mem)
> +		if (victim == root_mem) {
>  			loop++;
> +			if (loop >= 2) {
> +				/*
> +				 * If we have not been able to reclaim
> +				 * anything, it might because there are
> +				 * no reclaimable pages under this hierarchy
> +				 */
> +				if (!check_soft || !total)
> +					break;
> +				/*
> +				 * We want to do more targetted reclaim.
> +				 * excess >> 2 is not to excessive so as to
> +				 * reclaim too much, nor too less that we keep
> +				 * coming back to reclaim from this cgroup
> +				 */
> +				if (total >= (excess >> 2) ||
> +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> +					break;
> +			}
> +		}

Hmm..this logic is very unclear for me. Why just exit back as usual reclaim ?



>  		if (!mem_cgroup_local_usage(&victim->stat)) {
>  			/* this cgroup's local usage == 0 */
>  			css_put(&victim->css);
>  			continue;
>  		}
>  		/* we use swappiness of local cgroup */
> -		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
> -						   get_swappiness(victim));
> +		if (check_soft)
> +			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> +				noswap, get_swappiness(victim), zone,
> +				zone->zone_pgdat->node_id, priority);
> +		else
> +			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> +						noswap, get_swappiness(victim));

Do we need 2 functions ?

>  		css_put(&victim->css);
>  		/*
>  		 * At shrinking usage, we can't check we should stop here or
> @@ -1072,7 +1182,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  		if (shrink)
>  			return ret;
>  		total += ret;
> -		if (mem_cgroup_check_under_limit(root_mem))
> +		if (check_soft) {
> +			if (res_counter_check_under_soft_limit(&root_mem->res))
> +				return total;
> +		} else if (mem_cgroup_check_under_limit(root_mem))
>  			return 1 + total;
>  	}
>  	return total;
> @@ -1207,8 +1320,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> -		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> -							flags);
> +		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> +							gfp_mask, flags, -1);
>  		if (ret)
>  			continue;
>  
> @@ -2002,8 +2115,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> -						   MEM_CGROUP_RECLAIM_SHRINK);
> +		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
> +						GFP_KERNEL,
> +						MEM_CGROUP_RECLAIM_SHRINK, -1);

What this -1 means ?

>  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>  		/* Usage is reduced ? */
>    		if (curusage >= oldusage)
> @@ -2055,9 +2169,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> +		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
>  						MEM_CGROUP_RECLAIM_NOSWAP |
> -						MEM_CGROUP_RECLAIM_SHRINK);
> +						MEM_CGROUP_RECLAIM_SHRINK, -1);
again.

>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
> @@ -2068,6 +2182,82 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  	return ret;
>  }
>  
> +unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> +						gfp_t gfp_mask, int nid,
> +						int zid, int priority)
> +{
> +	unsigned long nr_reclaimed = 0;
> +	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
> +	unsigned long flags;
> +	unsigned long reclaimed;
> +	int loop = 0;
> +	struct mem_cgroup_soft_limit_tree_per_zone *stz;
> +
> +	if (order > 0)
> +		return 0;
> +
> +	stz = soft_limit_tree_node_zone(nid, zid);
> +	/*
> +	 * This loop can run a while, specially if mem_cgroup's continuously
> +	 * keep exceeding their soft limit and putting the system under
> +	 * pressure
> +	 */
> +	do {
> +		if (next_mz)
> +			mz = next_mz;
> +		else
> +			mz = mem_cgroup_largest_soft_limit_node(stz);
> +		if (!mz)
> +			break;
> +
> +		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
> +						gfp_mask,
> +						MEM_CGROUP_RECLAIM_SOFT,
> +						priority);
> +		nr_reclaimed += reclaimed;
> +		spin_lock_irqsave(&stz->lock, flags);
> +
> +		/*
> +		 * If we failed to reclaim anything from this memory cgroup
> +		 * it is time to move on to the next cgroup
> +		 */
> +		next_mz = NULL;
> +		if (!reclaimed) {
> +			do {
> +				/*
> +				 * By the time we get the soft_limit lock
> +				 * again, someone might have aded the
> +				 * group back on the RB tree. Iterate to
> +				 * make sure we get a different mem.
> +				 * mem_cgroup_largest_soft_limit_node returns
> +				 * NULL if no other cgroup is present on
> +				 * the tree
> +				 */
> +				next_mz =
> +				__mem_cgroup_largest_soft_limit_node(stz);
> +			} while (next_mz == mz);
> +		}
> +		mz->usage_in_excess =
> +			res_counter_soft_limit_excess(&mz->mem->res);
> +		__mem_cgroup_remove_exceeded(mz->mem, mz, stz);
> +		if (mz->usage_in_excess)
> +			__mem_cgroup_insert_exceeded(mz->mem, mz, stz);

plz don't push back "mz" if !reclaimd.



> +		spin_unlock_irqrestore(&stz->lock, flags);
> +		css_put(&mz->mem->css);
> +		loop++;
> +		/*
> +		 * Could not reclaim anything and there are no more
> +		 * mem cgroups to try or we seem to be looping without
> +		 * reclaiming anything.
> +		 */
> +		if (!nr_reclaimed &&
> +			(next_mz == NULL ||
> +			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
> +			break;
> +	} while (!nr_reclaimed);
> +	return nr_reclaimed;
> +}
> +
>  /*
>   * This routine traverse page_cgroup in given list and drop them all.
>   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> @@ -2671,6 +2861,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  			INIT_LIST_HEAD(&mz->lists[l]);
>  		mz->last_tree_update = 0;
>  		mz->usage_in_excess = 0;
> +		mz->on_tree = false;
> +		mz->mem = mem;
>  	}
>  	return 0;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 86dc0c3..d0f5c4d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1780,11 +1780,39 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  
> +unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> +						gfp_t gfp_mask, bool noswap,
> +						unsigned int swappiness,
> +						struct zone *zone, int nid,
> +						int priority)
> +{
> +	struct scan_control sc = {
> +		.may_writepage = !laptop_mode,
> +		.may_unmap = 1,
> +		.may_swap = !noswap,
> +		.swap_cluster_max = SWAP_CLUSTER_MAX,
> +		.swappiness = swappiness,
> +		.order = 0,
> +		.mem_cgroup = mem,
> +		.isolate_pages = mem_cgroup_isolate_pages,
> +	};
> +	nodemask_t nm  = nodemask_of_node(nid);
> +
> +	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> +			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> +	sc.nodemask = &nm;
> +	sc.nr_reclaimed = 0;
> +	sc.nr_scanned = 0;
> +	shrink_zone(priority, zone, &sc);
> +	return sc.nr_reclaimed;
> +}
> +
>  unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  					   gfp_t gfp_mask,
>  					   bool noswap,
>  					   unsigned int swappiness)
>  {
> +	struct zonelist *zonelist;
>  	struct scan_control sc = {
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
> @@ -1796,7 +1824,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  		.isolate_pages = mem_cgroup_isolate_pages,
>  		.nodemask = NULL, /* we don't care the placement */
>  	};
> -	struct zonelist *zonelist;
>  
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> @@ -1918,6 +1945,7 @@ loop_again:
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  			int nr_slab;
> +			int nid, zid;
>  
>  			if (!populated_zone(zone))
>  				continue;
> @@ -1932,6 +1960,15 @@ loop_again:
>  			temp_priority[i] = priority;
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
> +
> +			nid = pgdat->node_id;
> +			zid = zone_idx(zone);
> +			/*
> +			 * Call soft limit reclaim before calling shrink_zone.
> +			 * For now we ignore the return value
> +			 */
> +			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask,
> +							nid, zid, priority);
>  			/*
>  			 * We put equal pressure on every zone, unless one
>  			 * zone has way too many pages free already.
> 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
