Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C4D396B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 19:39:11 -0400 (EDT)
Date: Thu, 12 Mar 2009 16:34:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v5)
Message-Id: <20090312163425.5e43a0d4.akpm@linux-foundation.org>
In-Reply-To: <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
	<20090312175631.17890.30427.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 23:26:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Implement reclaim from groups over their soft limit
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
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
> kswapd() path) only if the order is 0.

Why for order-0 only?

What are the implications of not handling higher-order pages?

Why kswapd only?

What are the implications of omitting this from direct reclaim?

> memory cgroup soft limit reclaim finds the group that exceeds its soft limit
> by the largest amount and reclaims pages from it and then reinserts the
> cgroup into its correct place in the rbtree.

Why trim the single worst-case group rather than (say) trimming all
groups by a common proportion?  Or other things.


When you say "by the largest amount", is that the "by largest number of
pages" or "by the largest percentage"?

What are the implications of <whichever you chose>?

>
> ...
>
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> -				   gfp_t gfp_mask, bool noswap, bool shrink)
> +						struct zonelist *zl,
> +						gfp_t gfp_mask,
> +						unsigned long flags)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
>  	int loop = 0;
> +	bool noswap = flags & MEM_CGROUP_RECLAIM_NOSWAP;
> +	bool shrink = flags & MEM_CGROUP_RECLAIM_SHRINK;
> +	bool check_soft = flags & MEM_CGROUP_RECLAIM_SOFT;

`flags' wasn't a great choice of identifier.  It's a bit misleading,
and you'll be in a pickle if you later try to add a
spin_lock_irqsave(lock, flags) to this function.  Maybe choose a more
specific name?

> +	unsigned long excess = mem_cgroup_get_excess(root_mem);
>  
> -	while (loop < 2) {
> +	while (1) {
> +		if (loop >= 2) {
> +			/*
> +			 * With soft limits, do more targetted reclaim
> +			 */
> +			if (check_soft && (total >= (excess >> 4)))
> +				break;
> +			else if (!check_soft)
> +				break;

maybe..

			if (!check_soft)
				break;
			if (total >= (excess >> 4))
				break;

dunno.

The ">> 4" magic number would benefit from an explanatory comment.  Why
not ">> 3"???


> +		}
>  		victim = mem_cgroup_select_victim(root_mem);
> +		/*
> +		 * In the first loop, don't reclaim from victims below
> +		 * their soft limit
> +		 */
>
> ...
>
> +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
> +{
> +	unsigned long nr_reclaimed = 0;
> +	struct mem_cgroup *mem;
> +	unsigned long flags;
> +	unsigned long reclaimed;
> +
> +	/*
> +	 * This loop can run a while, specially if mem_cgroup's continuously
> +	 * keep exceeding their soft limit and putting the system under
> +	 * pressure
> +	 */
> +	do {
> +		mem = mem_cgroup_largest_soft_limit_node();
> +		if (!mem)
> +			break;
> +
> +		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
> +						gfp_mask,
> +						MEM_CGROUP_RECLAIM_SOFT);
> +		nr_reclaimed += reclaimed;
> +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> +		__mem_cgroup_remove_exceeded(mem);
> +		if (mem->usage_in_excess)
> +			__mem_cgroup_insert_exceeded(mem);
> +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> +		css_put(&mem->css);
> +		cond_resched();

spin_lock_irq() would suffice here.  Or the cond_resched() is a bug.

There's a decent argument that spin_lock_irq() is dangerous, and its
saving is so small that it's better to use the more robust
spin_lock_irqsave() all the time.  But was that the intent here?


> +	} while (!nr_reclaimed);
> +	return nr_reclaimed;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
