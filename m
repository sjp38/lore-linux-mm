Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCD76B01CC
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:46:54 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o590kpju017376
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:46:51 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe19.cbf.corp.google.com with ESMTP id o590kok0002836
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:46:50 -0700
Received: by pzk1 with SMTP id 1so3769149pzk.8
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:46:50 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:46:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <20100608140818.b413c335.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081741150.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com> <20100608140818.b413c335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > The oom killer presently kills current whenever there is no more memory
> > free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> > current is a memory-hogging task or that killing it will free any
> > substantial amount of memory, however.
> > 
> > In such situations, it is better to scan the tasklist for nodes that are
> > allowed to allocate on current's set of nodes and kill the task with the
> > highest badness() score.  This ensures that the most memory-hogging task,
> > or the one configured by the user with /proc/pid/oom_adj, is always
> > selected in such scenarios.
> > 
> >
> > ...
> >
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/module.h>
> >  #include <linux/notifier.h>
> >  #include <linux/memcontrol.h>
> > +#include <linux/mempolicy.h>
> >  #include <linux/security.h>
> >  
> >  int sysctl_panic_on_oom;
> > @@ -36,20 +37,36 @@ static DEFINE_SPINLOCK(zone_scan_lock);
> >  /* #define DEBUG */
> >  
> >  /*
> > - * Is all threads of the target process nodes overlap ours?
> > + * Do all threads of the target process overlap our allowed nodes?
> > + * @tsk: task struct of which task to consider
> > + * @mask: nodemask passed to page allocator for mempolicy ooms
> 
> The comment uses kerneldoc annotation but isn't a kerneldoc comment.
> 

I'll fix it.

> >   */
> > -static int has_intersects_mems_allowed(struct task_struct *tsk)
> > +static bool has_intersects_mems_allowed(struct task_struct *tsk,
> > +					const nodemask_t *mask)
> >  {
> > -	struct task_struct *t;
> > +	struct task_struct *start = tsk;
> >  
> > -	t = tsk;
> >  	do {
> > -		if (cpuset_mems_allowed_intersects(current, t))
> > -			return 1;
> > -		t = next_thread(t);
> > -	} while (t != tsk);
> > -
> > -	return 0;
> > +		if (mask) {
> > +			/*
> > +			 * If this is a mempolicy constrained oom, tsk's
> > +			 * cpuset is irrelevant.  Only return true if its
> > +			 * mempolicy intersects current, otherwise it may be
> > +			 * needlessly killed.
> > +			 */
> > +			if (mempolicy_nodemask_intersects(tsk, mask))
> > +				return true;
> 
> The comment refers to `current' but the code does not?
> 

mempolicy_nodemask_intersects() compares tsk's mempolicy to current's, we 
don't need to pass current into the function (and we optimize for that 
since we don't need to do task_lock(current): nothing else can change its 
mempolicy).

> > +		} else {
> > +			/*
> > +			 * This is not a mempolicy constrained oom, so only
> > +			 * check the mems of tsk's cpuset.
> > +			 */
> 
> The comment doesn't refer to `current', but the code does.  Confused.
> 

This simply compares the cpuset mems_allowed of both tasks passed into the 
function.

> > +			if (cpuset_mems_allowed_intersects(current, tsk))
> > +				return true;
> > +		}
> > +		tsk = next_thread(tsk);
> 
> hm, next_thread() uses list_entry_rcu().  What are the locking rules
> here?  It's one of both of rcu_read_lock() and read_lock(&tasklist_lock),
> I think?
> 

Oleg addressed this in his response.

> > +	} while (tsk != start);
> > +	return false;
> >  }
> 
> This is all bloat and overhead for non-NUMA builds.  I doubt if gcc is
> able to eliminate the task_struct walk (although I didn't check).
> 
> The function isn't oom-killer-specific at all - give it a better name
> then move it to mempolicy.c or similar?  If so, the text "oom"
> shouldn't appear in the comments.
> 

It's the only place where we want to filter tasks based on whether they 
share mempolicy nodes or cpuset mems, though, so I think it's 
appropriately placed in mm/oom_kill.c.  I agree that we can add a
#ifndef CONFIG_NUMA variant and I'll do so, thanks.

> >
> > ...
> >
> > @@ -676,24 +699,19 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	 */
> >  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
> >  	read_lock(&tasklist_lock);
> > -
> > -	switch (constraint) {
> > -	case CONSTRAINT_MEMORY_POLICY:
> > -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> > -				"No available memory (MPOL_BIND)");
> > -		break;
> > -
> > -	case CONSTRAINT_NONE:
> > -		if (sysctl_panic_on_oom) {
> > +	if (unlikely(sysctl_panic_on_oom)) {
> > +		/*
> > +		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
> > +		 * should not panic for cpuset or mempolicy induced memory
> > +		 * failures.
> > +		 */
> 
> This wasn't changelogged?
> 

It's not a functional change, sysctl_panic_on_oom == 2 is already handled 
earlier in the function.  This was intended to elaborate on why we're only 
concerned about CONSTRAINT_NONE here since the switch statement was 
removed.

> > +		if (constraint == CONSTRAINT_NONE) {
> >  			dump_header(NULL, gfp_mask, order, NULL);
> > -			panic("out of memory. panic_on_oom is selected\n");
> > +			read_unlock(&tasklist_lock);
> > +			panic("Out of memory: panic_on_oom is enabled\n");
> >  		}
> > -		/* Fall-through */
> > -	case CONSTRAINT_CPUSET:
> > -		__out_of_memory(gfp_mask, order);
> > -		break;
> >  	}
> > -
> > +	__out_of_memory(gfp_mask, order, constraint, nodemask);
> >  	read_unlock(&tasklist_lock);
> >  
> >  	/*
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
