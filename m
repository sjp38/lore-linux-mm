Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A95B6B00B2
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 20:08:13 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6U08EVw023279
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Jul 2009 09:08:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 056BB45DE51
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 09:08:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE37E45DE4F
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 09:08:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BF51C1DB803E
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 09:08:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 64DEE1DB8037
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 09:08:13 +0900 (JST)
Date: Thu, 30 Jul 2009 09:06:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX] set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware
Message-Id: <20090730090621.6511bafc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090729131600.647ff10a.akpm@linux-foundation.org>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
	<20090729131600.647ff10a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, rientjes@google.com, lee.schermerhorn@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Jul 2009 13:16:00 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 28 Jul 2009 16:18:13 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > tested on x86-64/fake NUMA and ia64/NUMA.
> > (That ia64 is a host which orignal bug report used.)
> 
> There's no description here of this bug.
> 
> Does this patch actually fix a bug?  Seems not.  Confusing.
> 
yes. fix a bug. maybe my description is not good.

The bug itself is orignally reporeted here:
http://marc.info/?l=linux-kernel&m=124765131625716&w=2

Ok, let me explain what happened.



At first, init_task's mems_allowed is initialized as this.
 init_task->mems_allowed == node_state[N_POSSIBLE]

And cpuset's top_cpuset mask is initialized as this
 top_cpuset->mems_allowed = node_state[N_HIGH_MEMORY]

Before 2.6.29:
policy's mems_allowed is initialized as this.

  1. update tasks->mems_allowed by its cpuset->mems_allowed.
  2. policy->mems_allowed = nodes_and(tasks->mems_allowed, user's mask)

Updating task's mems_allowed in reference to top_cpuset's one.
cpuset's mems_allowed is aware of N_HIGH_MEMORY, always.


In 2.6.30: After commit=58568d2a8215cb6f55caf2332017d7bdff954e1c

policy's mems_allowed is initialized as this.
  1. policy->mems_allowd = nodes_and(task->mems_allowed, user's mask)

Here, if task is in top_cpuset, task->mems_allowed is not updated from init's
one. Assume user excutes command as
#numactrl --interleave=all ,....

  policy->mems_allowd = nodes_and(N_POSSIBLE, ALL_SET_MASK)

Then, policy's mems_allowd can includes a possible node, which has no pgdat.

MPOL's INTERLEAVE just scans nodemask of task->mems_allowd and access this
directly.
  NODE_DATA(nid)->zonelist even if NODE_DATA(nid)==NULL


Then, what's we need is making policy->mems_allowed be aware of N_HIGH_MEMORY.
This patch does that. But to do so, extra nodemask will be on statck.
Because I know cpumask has a new interface of CPUMASK_ALLOC(), I added it to node.

This patch stands on old behavior. But I feel this fix itself is just a Band-Aid. 
But to do fundametal fix, we have to take care of memory hotplug and it takes time.
 (task->mems_allowd should be N_HIGH_MEMORY, I think.)



> > Maybe this is bigger patch than expected, but NODEMASK_ALLOC() will be a way
> > to go, anyway. (even if CPUMASK_ALLOC is not used anyware yet..)
> > Kosaki tested this on ia64 NUMA. thanks.
> > 
> > I'll wonder more fundamental fix to tsk->mems_allowed but this patch
> > is enough as a fix for now, I think.
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > mpol_set_nodemask() should be aware of N_HIGH_MEMORY and policy's nodemask
> > should be includes only online nodes.
> > In old behavior, this is guaranteed by frequent reference to cpuset's code.
> > Now, most of them are removed and mempolicy has to check it by itself.
> > 
> > To do check, a few nodemask_t will be used for calculating nodemask. But,
> > size of nodemask_t can be big and it's not good to allocate them on stack.
> > 
> > Now, cpumask_t has CPUMASK_ALLOC/FREE an easy code for get scratch area.
> > NODEMASK_ALLOC/FREE shoudl be there.
> > 
> > Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/nodemask.h |   31 +++++++++++++++++
> >  mm/mempolicy.c           |   82 ++++++++++++++++++++++++++++++++---------------
> >  2 files changed, 87 insertions(+), 26 deletions(-)
> > 
> > Index: task-mems-allowed-fix/include/linux/nodemask.h
> > ===================================================================
> > --- task-mems-allowed-fix.orig/include/linux/nodemask.h
> > +++ task-mems-allowed-fix/include/linux/nodemask.h
> > @@ -82,6 +82,13 @@
> >   *    to generate slightly worse code.  So use a simple one-line #define
> >   *    for node_isset(), instead of wrapping an inline inside a macro, the
> >   *    way we do the other calls.
> > + *
> > + * NODEMASK_SCRATCH
> > + * For doing above logical AND, OR, XOR, Remap, etc...the caller tend to be
> > + * necessary to use temporal nodemask_t on stack. But if NODES_SHIFT is large,
> > + * size of nodemask_t can be very big and not suitable for allocating in stack.
> > + * NODEMASK_SCRATCH is a helper for such situaions. See below and CPUMASK_ALLOC
> > + * also.
> >   */
> >  
> >  #include <linux/kernel.h>
> > @@ -473,4 +480,28 @@ static inline int num_node_state(enum no
> >  #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
> >  #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
> >  
> > +/*
> > + * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
> > + */
> > +
> > +#if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
> > +#define NODEMASK_ALLOC(x, m) struct x *m = kmalloc(sizeof(*m), GFP_KERNEL)
> > +#define NODEMASK_FREE(m) kfree(m)
> > +#else
> > +#define NODEMASK_ALLOC(x, m) struct x _m, *m = &_m
> > +#define NODEMASK_FREE(m)
> > +#endif
> > +
> > +#define NODEMASK_POINTER(v, m) nodemask_t *v = &(m->v)
> > +
> > +/* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
> > +struct nodemask_scratch {
> > +	nodemask_t	mask1;
> > +	nodemask_t	mask2;
> > +};
> > +
> > +#define NODEMASK_SCRATCH(x) NODEMASK_ALLOC(nodemask_scratch, x)
> > +#define NODEMASK_SCRATCH_FREE(x)  NODEMASK_FREE(x)
> 
> Ick.  Ho hum.  OK.  Such is life.
> 
> NODEMASK_POINTER() has no callers and is undocumented and unobvious. 
> Can I delete it?
> 
Yes. I added it just because CPUMASK_ALLOC() provides that.
(And I don't think it's necessary, either ;)


> >  void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
> >  {
> >  	int ret;
> > +	NODEMASK_SCRATCH(scratch);
> >  
> >  	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
> >  	spin_lock_init(&sp->lock);
> > @@ -1902,19 +1923,22 @@ void mpol_shared_policy_init(struct shar
> >  	if (mpol) {
> >  		struct vm_area_struct pvma;
> >  		struct mempolicy *new;
> > -
> > +		if (!scratch)
> > +			return;
> >  		/* contextualize the tmpfs mount point mempolicy */
> >  		new = mpol_new(mpol->mode, mpol->flags, &mpol->w.user_nodemask);
> >  		if (IS_ERR(new)) {
> >  			mpol_put(mpol);	/* drop our ref on sb mpol */
> > +			NODEMASK_SCRATCH_FREE(scratch);
> >  			return;		/* no valid nodemask intersection */
> >  		}
> >  
> >  		task_lock(current);
> > -		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask);
> > +		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
> >  		task_unlock(current);
> >  		mpol_put(mpol);	/* drop our ref on sb mpol */
> >  		if (ret) {
> > +			NODEMASK_SCRATCH_FREE(scratch);
> >  			mpol_put(new);
> >  			return;
> >  		}
> > @@ -1925,6 +1949,7 @@ void mpol_shared_policy_init(struct shar
> >  		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
> >  		mpol_put(new);			/* drop initial ref */
> >  	}
> > +	NODEMASK_SCRATCH_FREE(scratch);
> >  }
> 
> This function does an unneeded kmalloc/kfree if mpol==NULL.
> 

Ah yes, the range is not good.


> 
> How's this look?
> 
> diff -puN include/linux/nodemask.h~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix include/linux/nodemask.h
> --- a/include/linux/nodemask.h~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix
> +++ a/include/linux/nodemask.h
> @@ -84,11 +84,10 @@
>   *    way we do the other calls.
>   *
>   * NODEMASK_SCRATCH
> - * For doing above logical AND, OR, XOR, Remap, etc...the caller tend to be
> - * necessary to use temporal nodemask_t on stack. But if NODES_SHIFT is large,
> - * size of nodemask_t can be very big and not suitable for allocating in stack.
> - * NODEMASK_SCRATCH is a helper for such situaions. See below and CPUMASK_ALLOC
> - * also.
> + * When doing above logical AND, OR, XOR, Remap operations the callers tend to
> + * need temporary nodemask_t's on the stack. But if NODES_SHIFT is large,
> + * nodemask_t's consume too much stack space.  NODEMASK_SCRATCH is a helper
> + * for such situations. See below and CPUMASK_ALLOC also.
>   */
>  
>  #include <linux/kernel.h>
> @@ -492,8 +491,6 @@ static inline int num_node_state(enum no
>  #define NODEMASK_FREE(m)
>  #endif
>  
> -#define NODEMASK_POINTER(v, m) nodemask_t *v = &(m->v)
> -
>  /* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
>  struct nodemask_scratch {
>  	nodemask_t	mask1;
> diff -puN mm/mempolicy.c~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix mm/mempolicy.c
> --- a/mm/mempolicy.c~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix
> +++ a/mm/mempolicy.c
> @@ -1915,7 +1915,6 @@ restart:
>  void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
>  {
>  	int ret;
> -	NODEMASK_SCRATCH(scratch);
>  
>  	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
>  	spin_lock_init(&sp->lock);
> @@ -1923,6 +1922,8 @@ void mpol_shared_policy_init(struct shar
>  	if (mpol) {
>  		struct vm_area_struct pvma;
>  		struct mempolicy *new;
> +		NODEMASK_SCRATCH(scratch);
> +
>  		if (!scratch)
>  			return;
>  		/* contextualize the tmpfs mount point mempolicy */
> @@ -1948,8 +1949,8 @@ void mpol_shared_policy_init(struct shar
>  		pvma.vm_end = TASK_SIZE;	/* policy covers entire file */
>  		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
>  		mpol_put(new);			/* drop initial ref */
> +		NODEMASK_SCRATCH_FREE(scratch);
>  	}
> -	NODEMASK_SCRATCH_FREE(scratch);
>  }
>  
>  int mpol_set_shared_policy(struct shared_policy *info,
> _
> 

Seems nice

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
