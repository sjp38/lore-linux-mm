Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 696C06B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:01:30 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI11RH2001453
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Nov 2009 10:01:28 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 97C8A45DE52
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 10:01:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6067945DE4E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 10:01:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4CC1DB803A
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 10:01:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C41B21DB8042
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 10:01:26 +0900 (JST)
Date: Wed, 18 Nov 2009 09:58:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v4.2
Message-Id: <20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
	<20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 17 Nov 2009 16:11:58 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Fixing node-oriented allocation handling in oom-kill.c
> > I myself think this as bugfix not as ehnancement.
> > 
> > In these days, things are changed as
> >   - alloc_pages() eats nodemask as its arguments, __alloc_pages_nodemask().
> >   - mempolicy don't maintain its own private zonelists.
> >   (And cpuset doesn't use nodemask for __alloc_pages_nodemask())
> > 
> > So, current oom-killer's check function is wrong.
> > 
> > This patch does
> >   - check nodemask, if nodemask && nodemask doesn't cover all
> >     node_states[N_HIGH_MEMORY], this is CONSTRAINT_MEMORY_POLICY.
> >   - Scan all zonelist under nodemask, if it hits cpuset's wall
> >     this faiulre is from cpuset.
> > And
> >   - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
> >     This doesn't change "current" behavior. If callers use __GFP_THISNODE
> >     it should handle "page allocation failure" by itself.
> > 
> >   - handle __GFP_NOFAIL+__GFP_THISNODE path.
> >     This is something like a FIXME but this gfpmask is not used now.
> > 
> 
> Now that we're passing the nodemask into the oom killer, we should be able 
> to do more intelligent CONSTRAINT_MEMORY_POLICY selection.  current is not 
> always the ideal task to kill, so it's better to scan the tasklist and 
> determine the best task depending on our heuristics, similiar to how we 
> penalize candidates if they do not share the same cpuset.
> 
> Something like the following (untested) patch.  Comments?

Hm, yes. I think this direction is good.
I have my own but your version looks nicer.
(I'm busy with troubles in these days, sorry.)


> ---
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -201,7 +201,9 @@ extern void mpol_fix_fork_child_flag(struct task_struct *p);
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
> -extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
> +extern bool init_nodemask_of_task_mempolicy(struct task_struct *tsk,
> +				nodemask_t *mask);
> +extern bool init_nodemask_of_current_mempolicy(nodemask_t *mask);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -329,7 +331,16 @@ static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  	return node_zonelist(0, gfp_flags);
>  }
>  
> -static inline bool init_nodemask_of_mempolicy(nodemask_t *m) { return false; }
> +static inline bool init_nodemask_of_task_mempolicy(struct task_struct *tsk,
> +							nodemask_t *mask)
> +{
> +	return false;
> +}
> +
> +static inline bool init_nodemask_of_current_mempolicy(nodemask_t *mask)
> +{
> +	return false;
> +}
>  
>  static inline int do_migrate_pages(struct mm_struct *mm,
>  			const nodemask_t *from_nodes,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ed3f392..3ab3021 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1373,7 +1373,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  		 * global hstate attribute
>  		 */
>  		if (!(obey_mempolicy &&
> -				init_nodemask_of_mempolicy(nodes_allowed))) {
> +			init_nodemask_of_current_mempolicy(nodes_allowed))) {
>  			NODEMASK_FREE(nodes_allowed);
>  			nodes_allowed = &node_states[N_HIGH_MEMORY];
>  		}
> @@ -1860,7 +1860,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  		NODEMASK_ALLOC(nodemask_t, nodes_allowed,
>  						GFP_KERNEL | __GFP_NORETRY);
>  		if (!(obey_mempolicy &&
> -			       init_nodemask_of_mempolicy(nodes_allowed))) {
> +			init_nodemask_of_current_mempolicy(nodes_allowed))) {
>  			NODEMASK_FREE(nodes_allowed);
>  			nodes_allowed = &node_states[N_HIGH_MEMORY];
>  		}
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f11fdad..23c84bb 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1568,24 +1568,18 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  	}
>  	return zl;
>  }
> +#endif
>  
>  /*
> - * init_nodemask_of_mempolicy
> - *
> - * If the current task's mempolicy is "default" [NULL], return 'false'
> - * to indicate default policy.  Otherwise, extract the policy nodemask
> - * for 'bind' or 'interleave' policy into the argument nodemask, or
> - * initialize the argument nodemask to contain the single node for
> - * 'preferred' or 'local' policy and return 'true' to indicate presence
> - * of non-default mempolicy.
> - *
> - * We don't bother with reference counting the mempolicy [mpol_get/put]
> - * because the current task is examining it's own mempolicy and a task's
> - * mempolicy is only ever changed by the task itself.
> + * If tsk's mempolicy is "default" [NULL], return 'false' to indicate default
> + * policy.  Otherwise, extract the policy nodemask for 'bind' or 'interleave'
> + * policy into the argument nodemask, or initialize the argument nodemask to
> + * contain the single node for 'preferred' or 'local' policy and return 'true'
> + * to indicate presence of non-default mempolicy.
>   *
>   * N.B., it is the caller's responsibility to free a returned nodemask.
>   */
> -bool init_nodemask_of_mempolicy(nodemask_t *mask)
> +bool init_nodemask_of_task_mempolicy(struct task_struct *tsk, nodemask_t *mask)
>  {
>  	struct mempolicy *mempolicy;
>  	int nid;
> @@ -1615,7 +1609,16 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
>  
>  	return true;
>  }
> -#endif
> +
> +/*
> + * We don't bother with reference counting the mempolicy [mpol_get/put]
> + * because the current task is examining it's own mempolicy and a task's
> + * mempolicy is only ever changed by the task itself.
> + */
> +bool init_nodemask_of_current_mempolicy(nodemask_t *mask)
> +{
> +	return init_nodemask_of_task_mempolicy(current, mask);
> +}
>  
>  /* Allocate a page in interleaved policy.
>     Own path because it needs to do special accounting. */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ab04537..4c5c58b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -27,6 +27,7 @@
>  #include <linux/notifier.h>
>  #include <linux/memcontrol.h>
>  #include <linux/security.h>
> +#include <linux/mempolicy.h>
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> @@ -35,18 +36,30 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  
>  /*
> - * Is all threads of the target process nodes overlap ours?
> + * Do the nodes allowed by any of tsk's threads overlap ours?
>   */
> -static int has_intersects_mems_allowed(struct task_struct *tsk)
> +static int has_intersects_mems_allowed(struct task_struct *tsk,
> +						nodemask_t *nodemask)
>  {
> -	struct task_struct *t;
> +	struct task_struct *start = tsk;
> +	NODEMASK_ALLOC(nodemask_t, mpol_nodemask, GFP_KERNEL);
>  
> -	t = tsk;
> +	if (!nodemask)
> +		mpol_nodemask = NULL;
>  	do {
> -		if (cpuset_mems_allowed_intersects(current, t))
> +		if (mpol_nodemask) {
> +			mpol_get(tsk->mempolicy);
> +			if (init_nodemask_of_task_mempolicy(tsk, mpol_nodemask) &&
> +				nodes_intersects(*nodemask, *mpol_nodemask)) {
> +				mpol_put(tsk->mempolicy);
> +				return 1;
> +			}
> +			mpol_put(tsk->mempolicy);
> +		}

Hmm this mpol_get()/mpol_put() are necessary under tasklist_lock held ?
And...I wonder

	if (!init_nodemask_of_task_mempolicy(tsk, mpol_nodemask))
		return 1; /* this task uses default policy */


> +		if (cpuset_mems_allowed_intersects(current, tsk))
>  			return 1;
> -		t = next_thread(t);
> -	} while (t != tsk);
> +		tsk = next_thread(tsk);
> +	} while (tsk != start);
>  

Sigh...we has to scan all threads, again.
Could you have an idea to improve this ?

For example, 
	mm->mask_of_nodes_which_a_page_was_allocated_on
or
        mm->mask_of_nodes_made_by_some_magical_technique
some ?
(maybe per-node rss is over kill.)


>  	return 0;
>  }
> @@ -55,6 +68,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
>   * @uptime: current uptime in seconds
> + * @constraint: type of oom constraint
> + * @nodemask: nodemask passed to page allocator
>   *
>   * The formula used is relatively simple and documented inline in the
>   * function. The main rationale is that we want to select a good task
> @@ -70,7 +85,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>   *    of least surprise ... (be careful when you change it)
>   */
>  
> -unsigned long badness(struct task_struct *p, unsigned long uptime)
> +unsigned long badness(struct task_struct *p, unsigned long uptime,
> +			enum oom_constraint constraint, nodemask_t *nodemask)
>  {
>  	unsigned long points, cpu_time, run_time;
>  	struct mm_struct *mm;
> @@ -171,7 +187,9 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	 * because p may have allocated or otherwise mapped memory on
>  	 * this node before. However it will be less likely.
>  	 */
> -	if (!has_intersects_mems_allowed(p))
> +	if (!has_intersects_mems_allowed(p,
> +			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
> +								 NULL))
>  		points /= 8;
>  
>  	/*
> @@ -244,7 +262,8 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
>  static struct task_struct *select_bad_process(unsigned long *ppoints,
> -						struct mem_cgroup *mem)
> +			struct mem_cgroup *mem, enum oom_constraint constraint,
> +			nodemask_t *nodemask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *chosen = NULL;
> @@ -300,7 +319,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		if (p->signal->oom_adj == OOM_DISABLE)
>  			continue;
>  
> -		points = badness(p, uptime.tv_sec);
> +		points = badness(p, uptime.tv_sec, constraint, nodemask);
>  		if (points > *ppoints || !chosen) {
>  			chosen = p;
>  			*ppoints = points;
> @@ -472,7 +491,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem);
> +	p = select_bad_process(&points, mem, NULL);
>  	if (PTR_ERR(p) == -1UL)
>  		goto out;
>  
> @@ -554,7 +573,8 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  /*
>   * Must be called with tasklist_lock held for read.
>   */
> -static void __out_of_memory(gfp_t gfp_mask, int order)
> +static void __out_of_memory(gfp_t gfp_mask, int order,
> +			enum oom_constraint constraint, nodemask_t *nodemask)
>  {
>  	struct task_struct *p;
>  	unsigned long points;
> @@ -568,7 +588,7 @@ retry:
>  	 * Rambo mode: Shoot down a process and hope it solves whatever
>  	 * issues we may have.
>  	 */
> -	p = select_bad_process(&points, NULL);
> +	p = select_bad_process(&points, NULL, constraint, nodemask);
>  
>  	if (PTR_ERR(p) == -1UL)
>  		return;
> @@ -609,7 +629,8 @@ void pagefault_out_of_memory(void)
>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>  
>  	read_lock(&tasklist_lock);
> -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
> +	/* unknown gfp_mask and order */
> +	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
>  	read_unlock(&tasklist_lock);
>  
>  	/*
> @@ -656,11 +677,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	read_lock(&tasklist_lock);
>  
>  	switch (constraint) {
> -	case CONSTRAINT_MEMORY_POLICY:
> -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> -				"No available memory (MPOL_BIND)");
> -		break;
> -
>  	case CONSTRAINT_NONE:
>  		if (sysctl_panic_on_oom) {
>  			dump_header(gfp_mask, order, NULL);
> @@ -668,7 +684,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		}
>  		/* Fall-through */
>  	case CONSTRAINT_CPUSET:
> -		__out_of_memory(gfp_mask, order);
> +	case CONSTRAINT_MEMORY_POLICY:
> +		__out_of_memory(gfp_mask, order, constraint, nodemask);
>  		break;
>  	}
maybe good. But hmm...does this work well with per-vma mempolicy ?

I wonder
  mm->mask_of_nodes_made_by_some_magical_technique
will be necessary for completeness.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
