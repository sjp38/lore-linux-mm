Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D69956B007E
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:50:05 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id nAB2nv3P017366
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 02:49:58 GMT
Received: from pxi26 (pxi26.prod.google.com [10.243.27.26])
	by wpaz33.hot.corp.google.com with ESMTP id nAB2nKao021957
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:49:55 -0800
Received: by pxi26 with SMTP id 26so468131pxi.21
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:49:53 -0800 (PST)
Date: Tue, 10 Nov 2009 18:49:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v3
In-Reply-To: <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911101841480.11083@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
 <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Index: mm-test-kernel/drivers/char/sysrq.c
> ===================================================================
> --- mm-test-kernel.orig/drivers/char/sysrq.c
> +++ mm-test-kernel/drivers/char/sysrq.c
> @@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
>  
>  static void moom_callback(struct work_struct *ignored)
>  {
> -	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
> +	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
>  }
>  
>  static DECLARE_WORK(moom_work, moom_callback);
> Index: mm-test-kernel/mm/oom_kill.c
> ===================================================================
> --- mm-test-kernel.orig/mm/oom_kill.c
> +++ mm-test-kernel/mm/oom_kill.c
> @@ -196,27 +196,45 @@ unsigned long badness(struct task_struct
>  /*
>   * Determine the type of allocation constraint.
>   */
> +#ifdef CONFIG_NUMA
>  static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -						    gfp_t gfp_mask)
> +				    gfp_t gfp_mask, nodemask_t *nodemask)

We should probably remove the inline specifier, there's only one caller 
currently and if additional ones were added in the future this function 
should probably not be replicated.

>  {
> -#ifdef CONFIG_NUMA
>  	struct zone *zone;
>  	struct zoneref *z;
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> +	int ret = CONSTRAINT_NONE;
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> -			node_clear(zone_to_nid(zone), nodes);
> -		else
> +	/*
> + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> + 	 * feature. mempolicy is an only user of nodemask here.
> + 	 */
> +	if (nodemask) {
> +		nodemask_t mask;
> +		/* check mempolicy's nodemask contains all N_HIGH_MEMORY */
> +		nodes_and(mask, *nodemask, node_states[N_HIGH_MEMORY]);
> +		if (!nodes_equal(mask, node_states[N_HIGH_MEMORY]))
> +			return CONSTRAINT_MEMORY_POLICY;
> +	}

Although a nodemask_t was previously allocated on the stack, we should 
probably change this to use NODEMASK_ALLOC() for kernels with higher 
CONFIG_NODES_SHIFT since allocations can happen very deep into the stack.

There should be a way around that, however.  Shouldn't

	if (nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
		return CONSTRAINT_MEMORY_POLICY;

be sufficient?

> +
> +	/* Check this allocation failure is caused by cpuset's wall function */
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> +			high_zoneidx, nodemask)
> +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  			return CONSTRAINT_CPUSET;
>  
> -	if (!nodes_empty(nodes))
> -		return CONSTRAINT_MEMORY_POLICY;
> -#endif
> +	/* __GFP_THISNODE never calls OOM.*/
>  
>  	return CONSTRAINT_NONE;
>  }
> +#else
> +static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> +				gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> +	return CONSTRAINT_NONE;
> +}
> +#endif
>  
>  /*
>   * Simple selection loop. We chose the process with the highest
> @@ -603,7 +621,8 @@ rest_and_return:
>   * OR try to be smart about which process to kill. Note that we
>   * don't have to be perfect here, we just have to be good.
>   */
> -void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
> +void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> +		int order, nodemask_t *nodemask)
>  {
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint;
> @@ -622,11 +641,12 @@ void out_of_memory(struct zonelist *zone
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA) that may require different handling.
>  	 */
> -	constraint = constrained_alloc(zonelist, gfp_mask);
> +	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
>  	read_lock(&tasklist_lock);
>  
>  	switch (constraint) {
>  	case CONSTRAINT_MEMORY_POLICY:
> +		/* kill by process's its own memory alloc limitation */

I don't understand this comment.

>  		oom_kill_process(current, gfp_mask, order, 0, NULL,
>  				"No available memory (MPOL_BIND)");
>  		break;
> Index: mm-test-kernel/mm/page_alloc.c
> ===================================================================
> --- mm-test-kernel.orig/mm/page_alloc.c
> +++ mm-test-kernel/mm/page_alloc.c
> @@ -1667,9 +1667,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
>  	/* The OOM killer will not help higher order allocs */
>  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_NOFAIL))
>  		goto out;
> -
> +	/*
> +	 * In usual, GFP_THISNODE contains __GFP_NORETRY and we never hit this.
> +	 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> +	 * Note: Hugepage uses it but will hit PAGE_ALLOC_COSTLY_ORDER.
> +	 */
> +	if (gfp_mask & __GFP_THISNODE)
> +		goto out;
>  	/* Exhausted what can be done so it's blamo time */
> -	out_of_memory(zonelist, gfp_mask, order);
> +	out_of_memory(zonelist, gfp_mask, order, nodemask);
>  
>  out:
>  	clear_zonelist_oom(zonelist, gfp_mask);

This doesn't seem like the right place for this check; should we even try 
direct reclaim for bare users of __GFP_THISNODE?  If we're adding it for 
sanity even though no callers would currently hit it, it also is a 
potential escape route for __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
