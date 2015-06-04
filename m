Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5E197900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 05:30:34 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so15144152wiw.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 02:30:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li12si6814873wic.91.2015.06.04.02.30.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 02:30:32 -0700 (PDT)
Date: Thu, 4 Jun 2015 11:30:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150604093031.GB4806@dhcp22.suse.cz>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603193639.GH20091@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 04-06-15 04:36:39, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Jun 03, 2015 at 04:44:14PM +0200, Michal Hocko wrote:
> > The race does exist in the global case as well AFAICS.
> > __alloc_pages_may_oom
> >   mutex_trylock
> >   get_page_from_freelist # fails
> >   <preempted>				exit_mm # releases some memory
> >   out_of_memory
> >   					  exit_oom_victim
> >     # No TIF_MEMDIE task so kill a new
> 
> Hmmm?  In -mm, if __alloc_page_may_oom() fails trylock, it never calls
> out_of_memory().

Sure but the oom_lock might be free already. out_of_memory doesn't wait
for the victim to finish. It just does schedule_timeout_killable.

> > The race window might be smaller but it is possible in principle.
> > Why does it make sense to treat those two in a different way?
> 
> The main difference here is that the alloc path does the whole thing
> synchrnously and thus the OOM detection and killing can be put in the
> same critical section which isn't the case for the memcg OOM handling.

This is true but there is still a time window between the last
allocation attempt and out_of_memory when the OOM victim might have
exited and another task would be selected.
 
> > > The only reason memcg OOM killer behaves asynchronously (unwinding
> > > stack and then handling) is memcg userland OOM handling, which may end
> > > up blocking for userland actions while still holding whatever locks
> > > that it was holding at the time it was invoking try_charge() leading
> > > to a deadlock.
> > 
> > This is not the only reason. In-kernel memcg oom handling needs it
> > as well. See 3812c8c8f395 ("mm: memcg: do not trap chargers with
> > full callstack on OOM"). In fact it was the in-kernel case which has
> > triggered this change. We simply cannot wait for oom with the stack and
> > all the state the charge is called from.
> 
> Why should this be any different from OOM handling from page allocator
> tho? 

Yes the global OOM is prone to deadlock. This has been discussed a lot
and we still do not have a good answer for that. The primary problem
is that small allocations do not fail and retry indefinitely so an OOM
victim might be blocked on a lock held by a task which is the allocator.

This is less likely and harder to trigger with standard loads than in
memcg environment though.

> That can end up in the exact same situation and currently it
> won't be able to get out of such situation - the OOM victim would be
> stuck with OOM_SCAN_ABORT and all subsequent OOM invocations wouldn't
> do anything due to OOM_SCAN_ABORT.
> 
> The solution here seems to be timing out on those waits.  ie. pick an
> OOM victim, kill it, wait for it to exit for enough seconds.  If the
> victim doesn't exit, ignore it and repeat the process, which is
> guaranteed to make progress no matter what and appliable for both
> allocator and memcg OOM handling.

There have been suggestions to add an OOM timeout and ignore the
previous OOM victim after the timeout expires and select a new
victim. This sounds attractive but this approach has its own problems
(http://marc.info/?l=linux-mm&m=141686814824684&w=2).
I am convinced that a more appropriate solution for this is to not
pretend that small allocation never fail and start failing them after
OOM killer is not able to make any progress (GFP_NOFS allocations would
be the first candidate and the easiest one to trigger deadlocks via
i_mutex). Johannes was also suggesting an OOM memory reserve which would
be used for OOM contexts.

Also OOM killer can be improved and shrink some of the victims memory
before killing it (e.g. drop private clean pages and their page tables).

> > > IOW, it'd be cleaner to do everything synchronously while holding
> > > oom_lock with timeout to get out of rare deadlocks.
> > 
> > Deadlocks are quite real and we really have to unwind and handle with a
> > clean stack.
> 
> Yeah, they're real but we can deal with them in a more consistent way
> using timeouts.
> 
> > > Memcg OOM killings are done at the end of page fault apart from OOM
> > > detection.  This allows the following race condition.
> > > 
> > > 	Task A				Task B
> > > 
> > > 	OOM detection
> > > 					OOM detection
> > > 	OOM kill
> > > 	victim exits
> > > 					OOM kill
> > > 
> > > Task B has no way of knowing that another task has already killed an
> > > OOM victim which proceeded to exit and release memory and will
> > > unnecessarily pick another victim.  In highly contended cases, this
> > > can lead to multiple unnecessary chained killings.
> > 
> > Yes I can see this might happen. I haven't seen this in the real life
> > but I guess such a load can be constructed. The question is whether this
> > is serious enough to make the code more complicated.
> 
> Yeah, I do have bug report and dmesg where multiple processes are
> being killed (each one pretty large) when one should have been enough.

Could you share the oom reports?

> ...
> > > +void mem_cgroup_exit_oom_victim(void)
> > > +{
> > > +	struct mem_cgroup *memcg;
> > > +
> > > +	lockdep_assert_held(&oom_lock);
> > > +
> > > +	rcu_read_lock();
> > > +	memcg = mem_cgroup_from_task(current);
> > 
> > The OOM might have happened in a parent memcg and the OOM victim might
> > be a sibling or where ever in the hierarchy under oom memcg.
> > So you have to use the OOM memcg to track the counter otherwise the
> > tasks from other memcgs in the hierarchy racing with the oom victim
> > would miss it anyway. You can store the target memcg into the victim
> > when killing it.
> 
> In those cases there actually are more than one domains OOMing, but
> yeah the count prolly should propagate all the way to the root.

Not sure I understand what you mean by more OOM domains. There is only
one in a hierarchy which has reached its limit and it is not able to
reclaim any charges.

> Gees... I dislike this approach even more.  Grabbng the oom lock and
> doing everything synchronously with timeout will be far simpler and
> easier to follow.

It might sound easier but it has its own problems...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
