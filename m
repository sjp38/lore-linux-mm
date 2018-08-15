Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDB266B000D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:20:49 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id p127-v6so1908353ywg.1
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:20:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13-v6sor3563621ybe.83.2018.08.15.10.20.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 10:20:46 -0700 (PDT)
Date: Wed, 15 Aug 2018 13:20:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Message-ID: <20180815172044.GA29793@cmpxchg.org>
References: <20180815003620.15678-1-guro@fb.com>
 <20180815163923.GA28953@cmpxchg.org>
 <20180815165513.GA26330@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815165513.GA26330@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, Aug 15, 2018 at 09:55:17AM -0700, Roman Gushchin wrote:
> On Wed, Aug 15, 2018 at 12:39:23PM -0400, Johannes Weiner wrote:
> > On Tue, Aug 14, 2018 at 05:36:19PM -0700, Roman Gushchin wrote:
> > > @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> > >  		return s->addr;
> > >  	}
> > >  
> > > +	/*
> > > +	 * Allocated stacks are cached and later reused by new threads,
> > > +	 * so memcg accounting is performed manually on assigning/releasing
> > > +	 * stacks to tasks. Drop __GFP_ACCOUNT.
> > > +	 */
> > >  	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
> > >  				     VMALLOC_START, VMALLOC_END,
> > > -				     THREADINFO_GFP,
> > > +				     THREADINFO_GFP & ~__GFP_ACCOUNT,
> > >  				     PAGE_KERNEL,
> > >  				     0, node, __builtin_return_address(0));
> > >  
> > > @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> > >  #endif
> > >  }
> > >  
> > > +static void memcg_charge_kernel_stack(struct task_struct *tsk)
> > > +{
> > > +#ifdef CONFIG_VMAP_STACK
> > > +	struct vm_struct *vm = task_stack_vm_area(tsk);
> > > +
> > > +	if (vm) {
> > > +		int i;
> > > +
> > > +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
> > > +			memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
> > > +					  compound_order(vm->pages[i]));
> > > +
> > > +		/* All stack pages belong to the same memcg. */
> > > +		mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> > > +				     THREAD_SIZE / 1024);
> > > +	}
> > > +#endif
> > > +}
> > 
> > Before this change, the memory limit can fail the fork, but afterwards
> > fork() can grow memory consumption unimpeded by the cgroup settings.
> > 
> > Can we continue to use try_charge() here and fail the fork?
> 
> We can, but I'm not convinced we should.
> 
> Kernel stack is relatively small, and it's already allocated at this point.
> So IMO exceeding the memcg limit for 1-2 pages isn't worse than
> adding complexity and handle this case (e.g. uncharge partially
> charged stack). Do you have an example, when it does matter?

This is completely backwards.

We respect the limits unless there is a *really* strong reason not
to. The only situations I can think of is during OOM kills to avoid
memory deadlocks and during packet reception for correctness issues
(and because the network stack has its own way to reclaim memory).

Relying on some vague future allocations in the process's lifetime to
fail in order to contain it is crappy and unreliable. And unwinding
the stack allocation isn't too much complexity to warrant breaking the
containment rules here, even if it were several steps. But it looks
like it's nothing more than a 'goto free_stack'.

Please just fix this.
