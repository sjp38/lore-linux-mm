Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B9E06B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 20:13:16 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H1DDW6011527
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Feb 2010 10:13:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F95C45DE58
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 10:13:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A2B145DE52
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 10:13:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC2AE38008
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 10:13:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B5B9E38002
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 10:13:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/7 -mm] oom: select task from tasklist for mempolicy ooms
In-Reply-To: <alpine.DEB.2.00.1002161647160.31753@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002161343070.23037@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161647160.31753@chino.kir.corp.google.com>
Message-Id: <20100217100316.7321.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Feb 2010 10:13:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 16 Feb 2010, David Rientjes wrote:
> 
> > True, good point.  It looks like we'll need to include mempolicy 
> > detachment in exit_mm() while under task_lock() and then synchronize with 
> > that.  It's a legitimate place to do it since no memory allocation will be 
> > done after its mm is detached, anyway.
> > 
> 
> Here's the updated version of the patch, what do you think?

Looks good. probably we need to discuss about mlocked page issue (as Nick
pointed out) and determine how about care it. but I think this patch
can be treated independently. this is just forward step.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> 
> 
> oom: select task from tasklist for mempolicy ooms
> 
> The oom killer presently kills current whenever there is no more memory
> free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> current is a memory-hogging task or that killing it will free any
> substantial amount of memory, however.
> 
> In such situations, it is better to scan the tasklist for nodes that are
> allowed to allocate on current's set of nodes and kill the task with the
> highest badness() score.  This ensures that the most memory-hogging task,
> or the one configured by the user with /proc/pid/oom_adj, is always
> selected in such scenarios.
> 
> It is necessary to synchronize the detachment of task->mempolicy with
> task_lock(task) to ensure it is not prematurely destroyed while a user is
> operating on it.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/mempolicy.h |   13 +++++++-
>  kernel/exit.c             |    8 ++--
>  mm/mempolicy.c            |   44 +++++++++++++++++++++++++
>  mm/oom_kill.c             |   77 +++++++++++++++++++++++++++-----------------
>  4 files changed, 107 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -202,6 +202,8 @@ extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
>  extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
> +extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> +				const nodemask_t *mask);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -329,7 +331,16 @@ static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  	return node_zonelist(0, gfp_flags);
>  }
>  
> -static inline bool init_nodemask_of_mempolicy(nodemask_t *m) { return false; }
> +static inline bool init_nodemask_of_mempolicy(nodemask_t *m)
> +{
> +	return false;
> +}
> +
> +static inline bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> +			const nodemask_t *mask)
> +{
> +	return false;
> +}
>  
>  static inline int do_migrate_pages(struct mm_struct *mm,
>  			const nodemask_t *from_nodes,
> diff --git a/kernel/exit.c b/kernel/exit.c
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -689,6 +689,10 @@ static void exit_mm(struct task_struct * tsk)
>  	enter_lazy_tlb(mm, current);
>  	/* We don't want this task to be frozen prematurely */
>  	clear_freeze_flag(tsk);
> +#ifdef CONFIG_NUMA
> +	mpol_put(tsk->mempolicy);
> +	tsk->mempolicy = NULL;
> +#endif
>  	task_unlock(tsk);
>  	mm_update_next_owner(mm);
>  	mmput(mm);
> @@ -993,10 +997,6 @@ NORET_TYPE void do_exit(long code)
>  	perf_event_exit_task(tsk);
>  
>  	exit_notify(tsk, group_dead);
> -#ifdef CONFIG_NUMA
> -	mpol_put(tsk->mempolicy);
> -	tsk->mempolicy = NULL;
> -#endif
>  #ifdef CONFIG_FUTEX
>  	if (unlikely(current->pi_state_cache))
>  		kfree(current->pi_state_cache);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1638,6 +1638,50 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
>  }
>  #endif
>  
> +/*
> + * mempolicy_nodemask_intersects
> + *
> + * If tsk's mempolicy is "default" [NULL], return 'true' to indicate default
> + * policy.  Otherwise, check for intersection between mask and the policy
> + * nodemask for 'bind' or 'interleave' policy.  For 'perferred' or 'local'
> + * policy, always return true since it may allocate elsewhere on fallback.
> + *
> + * Takes task_lock(tsk) to prevent freeing of its mempolicy.
> + */
> +bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> +					const nodemask_t *mask)
> +{
> +	struct mempolicy *mempolicy;
> +	bool ret = true;
> +
> +	if (!mask)
> +		return ret;
> +	task_lock(tsk);
> +	mempolicy = tsk->mempolicy;
> +	if (!mempolicy)
> +		goto out;
> +
> +	switch (mempolicy->mode) {
> +	case MPOL_PREFERRED:
> +		/*
> +		 * MPOL_PREFERRED and MPOL_F_LOCAL are only preferred nodes to
> +		 * allocate from, they may fallback to other nodes when oom.
> +		 * Thus, it's possible for tsk to have allocated memory from
> +		 * nodes in mask.
> +		 */
> +		break;
> +	case MPOL_BIND:
> +	case MPOL_INTERLEAVE:
> +		ret = nodes_intersects(mempolicy->v.nodes, *mask);
> +		break;
> +	default:
> +		BUG();
> +	}
> +out:
> +	task_unlock(tsk);
> +	return ret;
> +}
> +
>  /* Allocate a page in interleaved policy.
>     Own path because it needs to do special accounting. */
>  static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -26,6 +26,7 @@
>  #include <linux/module.h>
>  #include <linux/notifier.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mempolicy.h>
>  #include <linux/security.h>
>  
>  int sysctl_panic_on_oom;
> @@ -36,19 +37,35 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>  
>  /*
>   * Do all threads of the target process overlap our allowed nodes?
> + * @tsk: task struct of which task to consider
> + * @mask: nodemask passed to page allocator for mempolicy ooms
>   */
> -static int has_intersects_mems_allowed(struct task_struct *tsk)
> +static bool has_intersects_mems_allowed(struct task_struct *tsk,
> +						const nodemask_t *mask)
>  {
> -	struct task_struct *t;
> +	struct task_struct *start = tsk;
>  
> -	t = tsk;
>  	do {
> -		if (cpuset_mems_allowed_intersects(current, t))
> -			return 1;
> -		t = next_thread(t);
> -	} while (t != tsk);
> -
> -	return 0;
> +		if (mask) {
> +			/*
> +			 * If this is a mempolicy constrained oom, tsk's
> +			 * cpuset is irrelevant.  Only return true if its
> +			 * mempolicy intersects current, otherwise it may be
> +			 * needlessly killed.
> +			 */
> +			if (mempolicy_nodemask_intersects(tsk, mask))
> +				return true;
> +		} else {
> +			/*
> +			 * This is not a mempolicy constrained oom, so only
> +			 * check the mems of tsk's cpuset.
> +			 */
> +			if (cpuset_mems_allowed_intersects(current, tsk))
> +				return true;
> +		}
> +		tsk = next_thread(tsk);
> +	} while (tsk != start);
> +	return false;
>  }
>  
>  /**
> @@ -236,7 +253,8 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
>  static struct task_struct *select_bad_process(unsigned long *ppoints,
> -						struct mem_cgroup *mem)
> +		struct mem_cgroup *mem, enum oom_constraint constraint,
> +		const nodemask_t *mask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *chosen = NULL;
> @@ -258,7 +276,9 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  			continue;
>  		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
> -		if (!has_intersects_mems_allowed(p))
> +		if (!has_intersects_mems_allowed(p,
> +				constraint == CONSTRAINT_MEMORY_POLICY ? mask :
> +									 NULL))
>  			continue;
>  
>  		/*
> @@ -478,7 +498,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem);
> +	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
>  	if (PTR_ERR(p) == -1UL)
>  		goto out;
>  
> @@ -560,7 +580,8 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  /*
>   * Must be called with tasklist_lock held for read.
>   */
> -static void __out_of_memory(gfp_t gfp_mask, int order)
> +static void __out_of_memory(gfp_t gfp_mask, int order,
> +			enum oom_constraint constraint, const nodemask_t *mask)
>  {
>  	struct task_struct *p;
>  	unsigned long points;
> @@ -574,7 +595,7 @@ retry:
>  	 * Rambo mode: Shoot down a process and hope it solves whatever
>  	 * issues we may have.
>  	 */
> -	p = select_bad_process(&points, NULL);
> +	p = select_bad_process(&points, NULL, constraint, mask);
>  
>  	if (PTR_ERR(p) == -1UL)
>  		return;
> @@ -615,7 +636,8 @@ void pagefault_out_of_memory(void)
>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>  
>  	read_lock(&tasklist_lock);
> -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
> +	/* unknown gfp_mask and order */
> +	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
>  	read_unlock(&tasklist_lock);
>  
>  	/*
> @@ -632,6 +654,7 @@ rest_and_return:
>   * @zonelist: zonelist pointer
>   * @gfp_mask: memory allocation flags
>   * @order: amount of memory being requested as a power of 2
> + * @nodemask: nodemask passed to page allocator
>   *
>   * If we run out of memory, we have the choice between either
>   * killing a random task (bad), letting the system crash (worse)
> @@ -660,24 +683,18 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 */
>  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
>  	read_lock(&tasklist_lock);
> -
> -	switch (constraint) {
> -	case CONSTRAINT_MEMORY_POLICY:
> -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> -				"No available memory (MPOL_BIND)");
> -		break;
> -
> -	case CONSTRAINT_NONE:
> -		if (sysctl_panic_on_oom) {
> +	if (unlikely(sysctl_panic_on_oom)) {
> +		/*
> +		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
> +		 * should not panic for cpuset or mempolicy induced memory
> +		 * failures.
> +		 */
> +		if (constraint == CONSTRAINT_NONE) {
>  			dump_header(NULL, gfp_mask, order, NULL);
> -			panic("out of memory. panic_on_oom is selected\n");
> +			panic("Out of memory: panic_on_oom is enabled\n");
>  		}
> -		/* Fall-through */
> -	case CONSTRAINT_CPUSET:
> -		__out_of_memory(gfp_mask, order);
> -		break;
>  	}
> -
> +	__out_of_memory(gfp_mask, order, constraint, nodemask);
>  	read_unlock(&tasklist_lock);
>  
>  	/*



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
