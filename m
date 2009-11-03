Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A08896B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 15:18:50 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id nA3KIjVG007183
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:18:46 -0800
Received: from pwj12 (pwj12.prod.google.com [10.241.219.76])
	by wpaz24.hot.corp.google.com with ESMTP id nA3KIgLT016723
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:18:43 -0800
Received: by pwj12 with SMTP id 12so3112688pwj.27
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 12:18:42 -0800 (PST)
Date: Tue, 3 Nov 2009 12:18:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][-mm][PATCH 1/6] oom-killer: updates for classification of
 OOM
In-Reply-To: <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031150500.11821@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com> <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Rewrite oom constarint to be up to date.
> 
> (1). Now, at badness calculation, oom_constraint and other information
>    (which is available easily) are ignore. Pass them.
> 
> (2)Adds more classes of oom constraint as _MEMCG and _LOWMEM.
>    This is just a change for interface and doesn't add new logic, at this stage.
> 
> (3) Pass nodemask to oom_kill. Now alloc_pages() are totally rewritten and
>   it uses nodemask as its argument. By this, mempolicy doesn't have its own
>   private zonelist. So, Passing nodemask to out_of_memory() is necessary.
>   But, pagefault_out_of_memory() doesn't have enough information. We should
>   visit this again, later.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  drivers/char/sysrq.c |    2 -
>  fs/proc/base.c       |    4 +-
>  include/linux/oom.h  |    8 +++-
>  mm/oom_kill.c        |  101 +++++++++++++++++++++++++++++++++++++++------------
>  mm/page_alloc.c      |    2 -
>  5 files changed, 88 insertions(+), 29 deletions(-)
> 
> Index: mmotm-2.6.32-Nov2/include/linux/oom.h
> ===================================================================
> --- mmotm-2.6.32-Nov2.orig/include/linux/oom.h
> +++ mmotm-2.6.32-Nov2/include/linux/oom.h
> @@ -10,23 +10,27 @@
>  #ifdef __KERNEL__
>  
>  #include <linux/types.h>
> +#include <linux/nodemask.h>
>  
>  struct zonelist;
>  struct notifier_block;
>  
>  /*
> - * Types of limitations to the nodes from which allocations may occur
> + * Types of limitations to zones from which allocations may occur
>   */
>  enum oom_constraint {
>  	CONSTRAINT_NONE,
> +	CONSTRAINT_LOWMEM,
>  	CONSTRAINT_CPUSET,
>  	CONSTRAINT_MEMORY_POLICY,
> +	CONSTRAINT_MEMCG
>  };
>  
>  extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  
> -extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
> +extern void out_of_memory(struct zonelist *zonelist,
> +		gfp_t gfp_mask, int order, nodemask_t *mask);
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
>  
> Index: mmotm-2.6.32-Nov2/mm/oom_kill.c
> ===================================================================
> --- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
> +++ mmotm-2.6.32-Nov2/mm/oom_kill.c
> @@ -27,6 +27,7 @@
>  #include <linux/notifier.h>
>  #include <linux/memcontrol.h>
>  #include <linux/security.h>
> +#include <linux/mempolicy.h>
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> @@ -55,6 +56,8 @@ static int has_intersects_mems_allowed(s
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
>   * @uptime: current uptime in seconds
> + * @constraint: type of oom_kill region
> + * @mem: set if called by memory cgroup
>   *
>   * The formula used is relatively simple and documented inline in the
>   * function. The main rationale is that we want to select a good task
> @@ -70,7 +73,9 @@ static int has_intersects_mems_allowed(s
>   *    of least surprise ... (be careful when you change it)
>   */
>  
> -unsigned long badness(struct task_struct *p, unsigned long uptime)
> +static unsigned long __badness(struct task_struct *p,
> +		      unsigned long uptime, enum oom_constraint constraint,
> +		      struct mem_cgroup *mem)
>  {
>  	unsigned long points, cpu_time, run_time;
>  	struct mm_struct *mm;
> @@ -193,30 +198,68 @@ unsigned long badness(struct task_struct
>  	return points;
>  }
>  
> +/* for /proc */
> +unsigned long global_badness(struct task_struct *p, unsigned long uptime)
> +{
> +	return __badness(p, uptime, CONSTRAINT_NONE, NULL);
> +}

I don't understand why this is necessary, CONSTRAINT_NONE should be 
available to proc_oom_score() via linux/oom.h.  It would probably be 
better to not rename badness() and use it directly.

> +
> +
>  /*
>   * Determine the type of allocation constraint.
>   */
> -static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -						    gfp_t gfp_mask)
> -{
> +
>  #ifdef CONFIG_NUMA
> +static inline enum oom_constraint guess_oom_context(struct zonelist *zonelist,
> +		gfp_t gfp_mask, nodemask_t *nodemask)

Why is this renamed from constrained_alloc()?  If the new code is really a 
guess, we probably shouldn't be altering the oom killing behavior to kill 
innocent tasks if it's wrong.

> +{
>  	struct zone *zone;
>  	struct zoneref *z;
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> +	enum oom_constraint ret = CONSTRAINT_NONE;
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> -			node_clear(zone_to_nid(zone), nodes);
> -		else
> +	/*
> +	 * In numa environ, almost all allocation will be against NORMAL zone.
> +	 * But some small area, ex)GFP_DMA for ia64 or GFP_DMA32 for x86-64
> +	 * can cause OOM. We can use policy_zone for checking lowmem.
> +	 */
> +	if (high_zoneidx < policy_zone)
> +		return CONSTRAINT_LOWMEM;
> +	/*
> +	 * Now, only mempolicy specifies nodemask. But if nodemask
> +	 * covers all nodes, this oom is global oom.
> +	 */
> +	if (nodemask && !nodes_equal(node_states[N_HIGH_MEMORY], *nodemask))
> +		ret = CONSTRAINT_MEMORY_POLICY;
> +	/*
> + 	 * If not __GFP_THISNODE, zonelist containes all nodes. And if
> + 	 * zonelist contains a zone which isn't allowed under cpuset, we assume
> + 	 * this allocation failure is caused by cpuset's constraint.
> + 	 * Note: all nodes are scanned if nodemask=NULL.
> + 	 */
> +	for_each_zone_zonelist_nodemask(zone,
> +			z, zonelist, high_zoneidx, nodemask) {
> +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  			return CONSTRAINT_CPUSET;
> +	}

This could probably be written as

	int nid;
	if (nodemask)
		for_each_node_mask(nid, *nodemask)
			if (!__cpuset_node_allowed_softwall(nid, gfp_mask))
				return CONSTRAINT_CPUSET;

and then you don't need the struct zoneref or struct zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
