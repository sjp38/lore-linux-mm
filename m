Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 243E06B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:15:22 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G5FICv000506
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 14:15:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 91A1045DE57
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:15:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 49F4145DE54
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:15:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 02189E18004
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:15:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 86F661DB803F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:15:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/7 -mm] oom: select task from tasklist for mempolicy ooms
In-Reply-To: <alpine.DEB.2.00.1002151407000.26927@chino.kir.corp.google.com>
References: <20100215120924.7281.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151407000.26927@chino.kir.corp.google.com>
Message-Id: <20100216135240.72EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 14:15:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Feb 2010, KOSAKI Motohiro wrote:
> 
> > > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > > --- a/mm/mempolicy.c
> > > +++ b/mm/mempolicy.c
> > > @@ -1638,6 +1638,45 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
> > >  }
> > >  #endif
> > >  
> > > +/*
> > > + * mempolicy_nodemask_intersects
> > > + *
> > > + * If tsk's mempolicy is "default" [NULL], return 'true' to indicate default
> > > + * policy.  Otherwise, check for intersection between mask and the policy
> > > + * nodemask for 'bind' or 'interleave' policy, or mask to contain the single
> > > + * node for 'preferred' or 'local' policy.
> > > + */
> > > +bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> > > +					const nodemask_t *mask)
> > > +{
> > > +	struct mempolicy *mempolicy;
> > > +	bool ret = true;
> > > +
> > > +	mempolicy = tsk->mempolicy;
> > > +	mpol_get(mempolicy);
> > 
> > Why is this refcount increment necessary? mempolicy is grabbed by tsk,
> > IOW it never be freed in this function.
> 
> We need to get a refcount on the mempolicy to ensure it doesn't get freed 
> from under us, tsk is not necessarily current.

Hm.
if you explanation is correct, I think your patch have following race.


 CPU0                            CPU1
----------------------------------------------
mempolicy_nodemask_intersects()
mempolicy = tsk->mempolicy;
                                 do_exit()
                                 mpol_put(tsk_mempolicy)
mpol_get(mempolicy);




> > > +	if (!mask || !mempolicy)
> > > +		goto out;
> > > +
> > > +	switch (mempolicy->mode) {
> > > +	case MPOL_PREFERRED:
> > > +		if (mempolicy->flags & MPOL_F_LOCAL)
> > > +			ret = node_isset(numa_node_id(), *mask);
> > 
> > Um? Is this good heuristic?
> > The task can migrate various cpus, then "node_isset(numa_node_id(), *mask) == 0"
> > doesn't mean the task doesn't consume *mask's memory.
> > 
> 
> For MPOL_F_LOCAL, we need to check whether the task's cpu is on a node 
> that is allowed by the zonelist passed to the page allocator.  In the 
> second revision of this patchset, this was changed to
> 
> 	node_isset(cpu_to_node(task_cpu(tsk)), *mask)
> 
> to check.  It would be possible for no memory to have been allocated on 
> that node and it just happens that the tsk is running on it momentarily, 
> but it's the best indication we have given the mempolicy of whether 
> killing a task may lead to future memory freeing.

This calculation is still broken. In general, running cpu and allocation node
is not bound.
We can't know such task use which node memory because MPOL_PREFERRED doesn't
bind allocation node. it only provide allocation hint.

	case MPOL_PREFERRED:
		ret = true;
		break;

is better. (probably we can make some bonus to oom_badness, but it's irrelevant thing).


> 
> > > @@ -660,24 +683,18 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > >  	 */
> > >  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
> > >  	read_lock(&tasklist_lock);
> > > -
> > > -	switch (constraint) {
> > > -	case CONSTRAINT_MEMORY_POLICY:
> > > -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> > > -				"No available memory (MPOL_BIND)");
> > > -		break;
> > > -
> > > -	case CONSTRAINT_NONE:
> > > -		if (sysctl_panic_on_oom) {
> > > +	if (unlikely(sysctl_panic_on_oom)) {
> > > +		/*
> > > +		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
> > > +		 * should not panic for cpuset or mempolicy induced memory
> > > +		 * failures.
> > > +		 */
> > > +		if (constraint == CONSTRAINT_NONE) {
> > >  			dump_header(NULL, gfp_mask, order, NULL);
> > > -			panic("out of memory. panic_on_oom is selected\n");
> > > +			panic("Out of memory: panic_on_oom is enabled\n");
> > 
> > enabled? Its feature is enabled at boot time. triggered? or fired?
> 
> The panic_on_oom sysctl is "enabled" if it is set to non-zero; that's the 
> word used throughout Documentation/sysctl/vm.txt to describe when a sysctl 
> is being used or not.

Probably, you changed message meanings. I think the original one doesn't
intend to describe enable or disable. but it isn't big matter. I can accept it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
