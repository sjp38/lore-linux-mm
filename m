Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E7C996B01EC
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg2uX008051
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8926E45DE56
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 518AE45DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 142281DB8015
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 497A21DB8017
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy ooms
In-Reply-To: <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
Message-Id: <20100608203529.7669.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/mempolicy.h |   13 +++++++-
>  mm/mempolicy.c            |   44 ++++++++++++++++++++++++
>  mm/oom_kill.c             |   80 +++++++++++++++++++++++++++-----------------
>  3 files changed, 105 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -210,6 +210,8 @@ extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
>  extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
> +extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> +				const nodemask_t *mask);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -338,7 +340,16 @@ static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
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
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1712,6 +1712,50 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
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
> @@ -27,6 +27,7 @@
>  #include <linux/module.h>
>  #include <linux/notifier.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mempolicy.h>
>  #include <linux/security.h>
>  
>  int sysctl_panic_on_oom;
> @@ -36,20 +37,36 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  
>  /*
> - * Is all threads of the target process nodes overlap ours?
> + * Do all threads of the target process overlap our allowed nodes?
> + * @tsk: task struct of which task to consider
> + * @mask: nodemask passed to page allocator for mempolicy ooms
>   */
> -static int has_intersects_mems_allowed(struct task_struct *tsk)
> +static bool has_intersects_mems_allowed(struct task_struct *tsk,
> +					const nodemask_t *mask)
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
>  static struct task_struct *find_lock_task_mm(struct task_struct *p)
> @@ -253,7 +270,8 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
>  static struct task_struct *select_bad_process(unsigned long *ppoints,
> -						struct mem_cgroup *mem)
> +		struct mem_cgroup *mem, enum oom_constraint constraint,
> +		const nodemask_t *mask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *chosen = NULL;
> @@ -269,7 +287,9 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
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
> @@ -495,7 +515,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  		panic("out of memory(memcg). panic_on_oom is selected.\n");
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem);
> +	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
>  	if (!p || PTR_ERR(p) == -1UL)
>  		goto out;
>  
> @@ -574,7 +594,8 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  /*
>   * Must be called with tasklist_lock held for read.
>   */
> -static void __out_of_memory(gfp_t gfp_mask, int order)
> +static void __out_of_memory(gfp_t gfp_mask, int order,
> +			enum oom_constraint constraint, const nodemask_t *mask)
>  {
>  	struct task_struct *p;
>  	unsigned long points;
> @@ -588,7 +609,7 @@ retry:
>  	 * Rambo mode: Shoot down a process and hope it solves whatever
>  	 * issues we may have.
>  	 */
> -	p = select_bad_process(&points, NULL);
> +	p = select_bad_process(&points, NULL, constraint, mask);
>  
>  	if (PTR_ERR(p) == -1UL)
>  		return;
> @@ -622,7 +643,8 @@ void pagefault_out_of_memory(void)
>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>  
>  	read_lock(&tasklist_lock);
> -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
> +	/* unknown gfp_mask and order */
> +	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
>  	read_unlock(&tasklist_lock);
>  
>  	/*
> @@ -638,6 +660,7 @@ void pagefault_out_of_memory(void)
>   * @zonelist: zonelist pointer
>   * @gfp_mask: memory allocation flags
>   * @order: amount of memory being requested as a power of 2
> + * @nodemask: nodemask passed to page allocator
>   *
>   * If we run out of memory, we have the choice between either
>   * killing a random task (bad), letting the system crash (worse)
> @@ -676,24 +699,19 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
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
> +			read_unlock(&tasklist_lock);
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

pulled.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
