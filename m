Date: Thu, 13 Sep 2007 20:33:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Christoph Lameter wrote:

> > A new spinlock, oom_lock, is introduced for the global case.  It
> > serializes the OOM killer for systems that are not using cpusets.  Only
> > one system task may enter the OOM killer at a time to prevent
> > unnecessarily killing others.
> 
> That oom_lock seems to be handled strangely. There is already a global 
> cpuset with the per cpuset locks. If those locks would be available in a 
> static structure in the !CPUSET case then I think that we could avoid the
> oom_lock weirdness.
> 

Sure, but such a static structure doesn't exist when CONFIG_CPUSETS isn't 
defined and there's no reason to create one just for the OOM killer.  That 
would require declaring the cpuset pointer in each task_struct even when 
we haven't enabled cpusets.  The OOM killer should be aware of cpuset-
constrained allocations, but not be dependant upon the subsystem.

> > > A per-cpuset flag, CS_OOM, is introduced in the flags field of struct
> > cpuset.  It serializes the OOM killer for only for hardwall allocations
> > targeted for that cpuset.  Only one task for each cpuset may enter the
> > OOM killer at a time to prevent unnecessarily killing others.  When a
> > per-cpuset OOM killing is taking place, the global spinlock is also
> > locked since we'll be alleviating that condition at the same time.
> 
> Hummm... If the global lock is taken then we can only run one OOM killer 
> at the time right?
> 

Yes, and that would happen if we didn't compile with CONFIG_CPUSETS or 
constrained_alloc() returns CONSTRAINT_NONE before we call out_of_memory() 
because the entire system is OOM.

> > + * If using cpusets, try to lock task's per-cpuset OOM lock; otherwise, try to
> > + * lock the global OOM spinlock.  Returns non-zero if the lock is contended or
> > + * zero if acquired.
> > + */
> > +int oom_test_and_set_lock(struct zonelist *zonelist, gfp_t gfp_mask,
> > +			  enum oom_constraint *constraint)
> > +{
> > +	int ret;
> > +
> > +	*constraint = constrained_alloc(zonelist, gfp_mask);
> > +	switch (*constraint) {
> > +	case CONSTRAINT_CPUSET:
> > +		ret = cpuset_oom_test_and_set_lock();
> > +		if (!ret)
> > +			spin_trylock(&oom_lock);
> 
> Ummm... If we cannot take the cpuset lock then we just casually try the 
> oom_lock and do not care about the result?
> 

We did take the cpuset lock.

We're testing and setting the CS_OOM bit in current->cpuset->flags.  If it 
is 0, meaning we have acquired the lock, we also lock the global lock 
since, by definition, any cpuset-constrained OOM killing will also help 
alleviate a system-wide OOM condition.  If the cpuset lock was contended, 
we don't lock the global lock, the function above returns 1, and we sleep 
when we return to __alloc_pages() before retrying.

> > +		break;
> > +	default:
> > +		ret = spin_trylock(&oom_lock);
> > +		break;
> > +	}
> 
> So we take the global lock if we run out of memory in an allocation 
> restriction using MPOL_BIND?
> 

Hmm, looks like we have another opportunity for an improvement here.

We have no way of locking only the nodes in the MPOL_BIND memory policy 
like we do on a cpuset granularity.  That would require an spinlock in 
each node which would work fine if we alter the CONSTRAINT_CPUSET case to 
lock each node in current->cpuset->mems_allowed.  We could do that if add 
a task_lock(current) before trying oom_test_and_set_lock() in 
__alloc_pages().

There's also no OOM locking at the zone level for GFP_DMA constrained 
allocations, so perhaps locking should be on the zone level.

> > +/*
> > + * If using cpusets, unlock task's per-cpuset OOM lock; otherwise, unlock the
> > + * global OOM spinlock.
> > + */
> > +void oom_unlock(enum oom_constraint constraint)
> > +{
> > +	switch (constraint) {
> > +	case CONSTRAINT_CPUSET:
> > +		if (likely(spin_is_locked(&oom_lock)))
> > +			spin_unlock(&oom_lock);
> 
> That looks a bit strange too.
> 

It looks strange and is open to a race, but it does what we want.  We 
take both the per-cpuset lock and the global lock whenever we are in a 
CONSTRAINT_CPUSET scenario so we need to unlock it here too.  The race 
isn't in this snippet of code because we're protected by the per-cpuset 
lock, but it's in oom_test_and_set_lock() where we lock both:

	CPU #1				CPU #2
	constrained_alloc() ==		constrained_alloc() ==
		CONSTRAINT_CPUSET		CONSTRAINT_NONE
	test_and_set_bit(CS_OOM, ...);	...
	...				spin_trylock(&oom_lock);
	...				out_of_memory();
	spin_trylock(&oom_lock);	...
	out_of_memory();		...
	spin_unlock(&oom_lock);		...

In that case, CPU #2 would not unlock &oom_lock because of the conditional 
you quoted above.

This scenario doesn't look much like serialization but that's completely 
intended.  We went OOM in a cpuset and then we went OOM in the system so 
something exclusive from the tasks bound to that cpuset caused the second 
OOM.  So killing current for the CONSTRAINT_CPUSET case probably won't 
help that condition since they occurred independently of each other.  What 
if they didn't?  Then the tasklist scanning in out_of_memory() will find 
the PF_EXITING task because it's a candidate for killing as well and the 
entire OOM killer will become a no-op for CPU #2.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
