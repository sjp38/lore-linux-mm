Date: Tue, 11 Nov 2008 00:14:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH]Per-cgroup OOM handler
In-Reply-To: <20081111162812.492218fc.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0811102356350.27365@chino.kir.corp.google.com>
References: <604427e00811031340k56634773g6e260d79e6cb51e7@mail.gmail.com> <604427e00811031419k2e990061kdb03f4b715b51fb9@mail.gmail.com> <20081106143438.5557b87c.kamezawa.hiroyu@jp.fujitsu.com> <604427e00811102042x202906ecq2a10eb5e404e2ec9@mail.gmail.com>
 <20081111162812.492218fc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, Rohit Seth <rohitseth@google.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Sorry, there's been some confusion in this proposal.

On Tue, 11 Nov 2008, KAMEZAWA Hiroyuki wrote:

> >     Here is how we do the one-tick-wait in cgroup_should_oom() in oom_kill.c
> >     >-------if (!ret) {
> >     >------->-------/* If we're not going to OOM, we should sleep for a
> >     >------->------- * bit to give userspace a chance to respond before we
> >     >------->------- * go back and try to reclaim again */
> >     >------->-------schedule_timeout_uninterruptible(1);
> >     >-------}
> >    and it works well in-house so far as i mentioned earlier. what's
> > important here is not "sleeping for one tick", the idea here is to
> > reschedule the ooming thread so the oom handler can make action ( like
> > adding memory node to the cpuset) and the subsequent page allocator in
> > get_page_from_freelist() can use it.
> > 
> Can't we avoid this kind of magical one-tick wait ?
> 

cgroup_should_oom() determines whether the oom killer should be invoked or 
whether userspace should be given the opportunity to act first; it returns 
zero only when the kernel has deferred to userspace.

In these situations, the kernel will return to the page allocator to 
attempt the allocation again.  If current were not rescheduled like this 
(the schedule_timeout is simply more powerful than a cond_resched), there 
is a very high liklihood that this subsequent allocation attempt would 
fail just as it did before the oom killer was triggered and then we'd 
enter reclaim unnecessarily when userspace could have reclaimed on its 
own, killed a task by overriding the kernels' heuristics, added a node to 
the cpuset, increased its memcg allocation, etc.

So this reschedule simply prevents needlessly entering reclaim, just as 
its comment indicates.

> > > (Before OOM, the system tend to wait in congestion_wait() or some.)
> > 

Yes, we wait on block congestion as part of direct reclaim but at this 
point we've yet to notify the userspace oom handler so that it may act to 
avoid invoking the oom kiler.

> Hmm, from discussion of mem_notify handler in Feb/March of this year,
> oom-hanlder cannot works well if memory is near to OOM, in general.
> Then, mlockall was recomemded to handler.
> (and it must not do file access.)
> 

This would be a legitimate point if we were talking about a system-wide 
oom notifier like /dev/mem_notify was and we were addressing unconstrained 
ooms.  This patch was specific to cgroups and the only likely usecases are 
for either cpusets or memcg.

> I wonder creating small cpuset (and isolated node) for oom-handler may be
> another help.
> 

This is obviously a pure userspace issue; any sane oom handler that is 
itself subjected to the same memory constraints would be written to avoid 
memory allocations when woken up.

> > > I'm wondering
> > >  - freeeze-all-threads-in-group-at-oom
> > >  - free emergency memory to page allocator which was pooled at cgroup
> > > creation
> > >    rather than 1-tick wait
> > >
> > > BTW, it seems this patch allows task detach/attach always. it's safe(and
> > > sane) ?
> > 
> >    yes, we allows task detach/attach. So far we don't see any race condition
> > except the livelock
> > i mentioned above. Any particular scenario can think of now? thanks
> > 
> I don't find it ;)
> BTW, shouldn't we disable preempt(or irq) before taking spinlocks ?
> 

I don't know which spinlock you're specifically referring to here, but the 
oom killer (and thus the handling of the oom handler) is invoked in 
process context with irqs enabled.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
