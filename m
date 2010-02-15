Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21DA66B0083
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:11:45 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o1FMBl0k024515
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:11:48 -0800
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe11.cbf.corp.google.com with ESMTP id o1FMBkxa010189
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 16:11:46 -0600
Received: by pzk36 with SMTP id 36so6361250pzk.23
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:11:46 -0800 (PST)
Date: Mon, 15 Feb 2010 14:11:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/7 -mm] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <20100215120924.7281.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002151407000.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228370.8001@chino.kir.corp.google.com> <20100215120924.7281.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, KOSAKI Motohiro wrote:

> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1638,6 +1638,45 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
> >  }
> >  #endif
> >  
> > +/*
> > + * mempolicy_nodemask_intersects
> > + *
> > + * If tsk's mempolicy is "default" [NULL], return 'true' to indicate default
> > + * policy.  Otherwise, check for intersection between mask and the policy
> > + * nodemask for 'bind' or 'interleave' policy, or mask to contain the single
> > + * node for 'preferred' or 'local' policy.
> > + */
> > +bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> > +					const nodemask_t *mask)
> > +{
> > +	struct mempolicy *mempolicy;
> > +	bool ret = true;
> > +
> > +	mempolicy = tsk->mempolicy;
> > +	mpol_get(mempolicy);
> 
> Why is this refcount increment necessary? mempolicy is grabbed by tsk,
> IOW it never be freed in this function.
> 

We need to get a refcount on the mempolicy to ensure it doesn't get freed 
from under us, tsk is not necessarily current.

> 
> > +	if (!mask || !mempolicy)
> > +		goto out;
> > +
> > +	switch (mempolicy->mode) {
> > +	case MPOL_PREFERRED:
> > +		if (mempolicy->flags & MPOL_F_LOCAL)
> > +			ret = node_isset(numa_node_id(), *mask);
> 
> Um? Is this good heuristic?
> The task can migrate various cpus, then "node_isset(numa_node_id(), *mask) == 0"
> doesn't mean the task doesn't consume *mask's memory.
> 

For MPOL_F_LOCAL, we need to check whether the task's cpu is on a node 
that is allowed by the zonelist passed to the page allocator.  In the 
second revision of this patchset, this was changed to

	node_isset(cpu_to_node(task_cpu(tsk)), *mask)

to check.  It would be possible for no memory to have been allocated on 
that node and it just happens that the tsk is running on it momentarily, 
but it's the best indication we have given the mempolicy of whether 
killing a task may lead to future memory freeing.

> > @@ -660,24 +683,18 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
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
> > +		if (constraint == CONSTRAINT_NONE) {
> >  			dump_header(NULL, gfp_mask, order, NULL);
> > -			panic("out of memory. panic_on_oom is selected\n");
> > +			panic("Out of memory: panic_on_oom is enabled\n");
> 
> enabled? Its feature is enabled at boot time. triggered? or fired?
> 

The panic_on_oom sysctl is "enabled" if it is set to non-zero; that's the 
word used throughout Documentation/sysctl/vm.txt to describe when a sysctl 
is being used or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
