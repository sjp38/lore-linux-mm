Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4486B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 21:13:59 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id nAI2DsmK027614
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 02:13:54 GMT
Received: from pxi29 (pxi29.prod.google.com [10.243.27.29])
	by spaceape9.eur.corp.google.com with ESMTP id nAI2DRaG018015
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 18:13:51 -0800
Received: by pxi29 with SMTP id 29so444892pxi.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 18:13:51 -0800 (PST)
Date: Tue, 17 Nov 2009 18:13:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
 <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com> <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com> <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com> <20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Nov 2009, KAMEZAWA Hiroyuki wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index ab04537..4c5c58b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/notifier.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/security.h>
> > +#include <linux/mempolicy.h>
> >  
> >  int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> > @@ -35,18 +36,30 @@ static DEFINE_SPINLOCK(zone_scan_lock);
> >  /* #define DEBUG */
> >  
> >  /*
> > - * Is all threads of the target process nodes overlap ours?
> > + * Do the nodes allowed by any of tsk's threads overlap ours?
> >   */
> > -static int has_intersects_mems_allowed(struct task_struct *tsk)
> > +static int has_intersects_mems_allowed(struct task_struct *tsk,
> > +						nodemask_t *nodemask)
> >  {
> > -	struct task_struct *t;
> > +	struct task_struct *start = tsk;
> > +	NODEMASK_ALLOC(nodemask_t, mpol_nodemask, GFP_KERNEL);
> >  
> > -	t = tsk;
> > +	if (!nodemask)
> > +		mpol_nodemask = NULL;
> >  	do {
> > -		if (cpuset_mems_allowed_intersects(current, t))
> > +		if (mpol_nodemask) {
> > +			mpol_get(tsk->mempolicy);
> > +			if (init_nodemask_of_task_mempolicy(tsk, mpol_nodemask) &&
> > +				nodes_intersects(*nodemask, *mpol_nodemask)) {
> > +				mpol_put(tsk->mempolicy);
> > +				return 1;
> > +			}
> > +			mpol_put(tsk->mempolicy);
> > +		}
> 
> Hmm this mpol_get()/mpol_put() are necessary under tasklist_lock held ?

They are, we don't hold tasklist_lock while dropping the reference count 
in do_exit().

> And...I wonder
> 
> 	if (!init_nodemask_of_task_mempolicy(tsk, mpol_nodemask))
> 		return 1; /* this task uses default policy */
> 
> 
> > +		if (cpuset_mems_allowed_intersects(current, tsk))
> >  			return 1;
> > -		t = next_thread(t);
> > -	} while (t != tsk);
> > +		tsk = next_thread(tsk);
> > +	} while (tsk != start);
> >  
> 
> Sigh...we has to scan all threads, again.
> Could you have an idea to improve this ?
> 
> For example, 
> 	mm->mask_of_nodes_which_a_page_was_allocated_on
> or
>         mm->mask_of_nodes_made_by_some_magical_technique
> some ?
> (maybe per-node rss is over kill.)
> 

The same criticism could be said for the CONSTRAINT_CPUSET.  We don't 
actually know in either case, mempolicy or cpusets, if memory was ever 
allocated on a particular node in tsk->mempolicy->v.nodes or 
tsk->mems_allowed, respectively.  We assume, however, that if a node is 
included in a mempolicy nodemask or cpuset mems that it is an allowed 
node to allocate from for all attached tasks (and those tasks aren't 
solely allocating on a subset) so that killing tasks based on their 
potential for allocating on oom nodes is actually helpful.

> 
> >  	return 0;
> >  }
> > @@ -55,6 +68,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
> >   * badness - calculate a numeric value for how bad this task has been
> >   * @p: task struct of which task we should calculate
> >   * @uptime: current uptime in seconds
> > + * @constraint: type of oom constraint
> > + * @nodemask: nodemask passed to page allocator
> >   *
> >   * The formula used is relatively simple and documented inline in the
> >   * function. The main rationale is that we want to select a good task
> > @@ -70,7 +85,8 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
> >   *    of least surprise ... (be careful when you change it)
> >   */
> >  
> > -unsigned long badness(struct task_struct *p, unsigned long uptime)
> > +unsigned long badness(struct task_struct *p, unsigned long uptime,
> > +			enum oom_constraint constraint, nodemask_t *nodemask)
> >  {
> >  	unsigned long points, cpu_time, run_time;
> >  	struct mm_struct *mm;
> > @@ -171,7 +187,9 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  	 * because p may have allocated or otherwise mapped memory on
> >  	 * this node before. However it will be less likely.
> >  	 */
> > -	if (!has_intersects_mems_allowed(p))
> > +	if (!has_intersects_mems_allowed(p,
> > +			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
> > +								 NULL))
> >  		points /= 8;
> >  
> >  	/*
> > @@ -244,7 +262,8 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> >   * (not docbooked, we don't want this one cluttering up the manual)
> >   */
> >  static struct task_struct *select_bad_process(unsigned long *ppoints,
> > -						struct mem_cgroup *mem)
> > +			struct mem_cgroup *mem, enum oom_constraint constraint,
> > +			nodemask_t *nodemask)
> >  {
> >  	struct task_struct *p;
> >  	struct task_struct *chosen = NULL;
> > @@ -300,7 +319,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  		if (p->signal->oom_adj == OOM_DISABLE)
> >  			continue;
> >  
> > -		points = badness(p, uptime.tv_sec);
> > +		points = badness(p, uptime.tv_sec, constraint, nodemask);
> >  		if (points > *ppoints || !chosen) {
> >  			chosen = p;
> >  			*ppoints = points;
> > @@ -472,7 +491,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
> >  
> >  	read_lock(&tasklist_lock);
> >  retry:
> > -	p = select_bad_process(&points, mem);
> > +	p = select_bad_process(&points, mem, NULL);
> >  	if (PTR_ERR(p) == -1UL)
> >  		goto out;
> >  
> > @@ -554,7 +573,8 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
> >  /*
> >   * Must be called with tasklist_lock held for read.
> >   */
> > -static void __out_of_memory(gfp_t gfp_mask, int order)
> > +static void __out_of_memory(gfp_t gfp_mask, int order,
> > +			enum oom_constraint constraint, nodemask_t *nodemask)
> >  {
> >  	struct task_struct *p;
> >  	unsigned long points;
> > @@ -568,7 +588,7 @@ retry:
> >  	 * Rambo mode: Shoot down a process and hope it solves whatever
> >  	 * issues we may have.
> >  	 */
> > -	p = select_bad_process(&points, NULL);
> > +	p = select_bad_process(&points, NULL, constraint, nodemask);
> >  
> >  	if (PTR_ERR(p) == -1UL)
> >  		return;
> > @@ -609,7 +629,8 @@ void pagefault_out_of_memory(void)
> >  		panic("out of memory from page fault. panic_on_oom is selected.\n");
> >  
> >  	read_lock(&tasklist_lock);
> > -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
> > +	/* unknown gfp_mask and order */
> > +	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
> >  	read_unlock(&tasklist_lock);
> >  
> >  	/*
> > @@ -656,11 +677,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	read_lock(&tasklist_lock);
> >  
> >  	switch (constraint) {
> > -	case CONSTRAINT_MEMORY_POLICY:
> > -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> > -				"No available memory (MPOL_BIND)");
> > -		break;
> > -
> >  	case CONSTRAINT_NONE:
> >  		if (sysctl_panic_on_oom) {
> >  			dump_header(gfp_mask, order, NULL);
> > @@ -668,7 +684,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  		}
> >  		/* Fall-through */
> >  	case CONSTRAINT_CPUSET:
> > -		__out_of_memory(gfp_mask, order);
> > +	case CONSTRAINT_MEMORY_POLICY:
> > +		__out_of_memory(gfp_mask, order, constraint, nodemask);
> >  		break;
> >  	}
> maybe good. But hmm...does this work well with per-vma mempolicy ?
> 
> I wonder
>   mm->mask_of_nodes_made_by_some_magical_technique
> will be necessary for completeness.
> 

I think that would probably be rejected because of its implications on the 
allocation fastpath.  The change here isn't causing the oom killing to be 
any less ideal; current may never have allocated any memory on its 
mempolicy nodes prior to the oom and so killing it may be entirely 
useless.  It's better to use our heuristics for determining the ideal task 
to kill in that case and restricting our subset of eligible tasks by the 
same criteria that we use for cpusets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
