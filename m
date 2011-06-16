Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BFEC56B00F1
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 19:37:35 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GNQ7Dp027197
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 19:26:07 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GNbV3J143914
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 19:37:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GNbTA3021325
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 19:37:31 -0400
Date: Thu, 16 Jun 2011 16:37:28 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110616233727.GO2582@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
 <20110616070335.GA7661@elte.hu>
 <20110616171644.GK2582@linux.vnet.ibm.com>
 <20110616202550.GA16214@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616202550.GA16214@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 10:25:50PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > The funny thing about this workload is that context-switches are 
> > > really a fastpath here and we are using anonymous IRQ-triggered 
> > > softirqs embedded in random task contexts as a workaround for 
> > > that.
> > 
> > The other thing that the IRQ-triggered softirqs do is to get the 
> > callbacks invoked in cases where a CPU-bound user thread is never 
> > context switching.
> 
> Yeah - but this workload didnt have that.

Ah, understood -- I was thinking about the general case as well as this
particular workload.

> > Of course, one alternative might be to set_need_resched() to force 
> > entry into the scheduler as needed.
> 
> No need for that: we can just do the callback not in softirq but in 
> regular syscall context in that case, in the return-to-userspace 
> notifier. (see TIF_USER_RETURN_NOTIFY and the USER_RETURN_NOTIFIER 
> facility)

Good point, I should add this -- there was a similar RCU hook into
the trap and syscall paths in DYNIX/ptx.  At first glance, this looks
x86-specific -- or am I missing something?

> Abusing a facility like setting need_resched artificially will 
> generally cause trouble.

Yep, from an RCU viewpoint, it would be best to use it only to force a
quiescent state.

> > > [ I think we'll have to revisit this issue and do it properly:
> > >   quiescent state is mostly defined by context-switches here, so we
> > >   could do the RCU callbacks from the task that turns a CPU
> > >   quiescent, right in the scheduler context-switch path - perhaps
> > >   with an option for SCHED_FIFO tasks to *not* do GC.
> > 
> > I considered this approach for TINY_RCU, but dropped it in favor of 
> > reducing the interlocking between the scheduler and RCU callbacks. 
> > Might be worth revisiting, though.  If SCHED_FIFO task omit RCU 
> > callback invocation, then there will need to be some override for 
> > CPUs with lots of SCHED_FIFO load, probably similar to RCU's 
> > current blimit stuff.
> 
> I wouldnt complicate it much for SCHED_FIFO: SCHED_FIFO tasks are 
> special and should never run long.

Agreed, but if someone creates a badly behaved SCHED_FIFO task, RCU
still needs to make forward progress.  Otherwise, a user task can OOM
the system.

> > >   That could possibly be more cache-efficient than softirq execution,
> > >   as we'll process a still-hot pool of callbacks instead of doing
> > >   them only once per timer tick. It will also make the RCU GC
> > >   behavior HZ independent. ]
> > 
> > Well, the callbacks will normally be cache-cold in any case due to 
> > the grace-period delay, [...]
> 
> The workloads that are the most critical in this regard tend to be 
> context switch intense, so the grace period expiry latency should be 
> pretty short.

And TINY_RCU does in fact do core RCU processing at context-switch
time from within rcu_preempt_note_context_switch(), which is called
from rcu_note_context_switch().  I never tried that in TREE_RCU because
of the heavier weight of the processing.  But it is easy to test --
six-line change, see patch below.  (Untested, probably doesn't compile.)

> Or at least significantly shorter than today's HZ frequency, right? 
> HZ would still provide an upper bound for the latency.

Yes, this should shorten the average grace-period length, at some cost
in overhead.  (Probably a -lot- less than the RT kthread change, but hey!)

> Btw., the current worst-case grace period latency is in reality more 
> like two timer ticks: one for the current CPU to expire and another 
> for the longest "other CPU" expiry, right? Average expiry (for 
> IRQ-poor workloads) would be 1.5 timer ticks. (if i got my stat 
> calculations right!)

Yep, typical best-case grace period latency is indeed less than two ticks,
but it depends on exactly what you are measuring.  It consts another
tick on the average to get the callbacks invoked (assuming no backlog),
but you can save a tick for back-to-back grace periods.

But this assumes CONFIG_NO_HZ=n with current RCU -- it takes about six
scheduler-clock ticks to detect dyntick-idle CPUs.  Certain CPU-hotplug
races can leave RCU confused about whether or not a given CPU is part
of the current grace period, in which case RCU also takes about six
scheduler-clock ticks to get itself unconfused.  If a process spends too
much time in the kernel without scheduling, RCU will send it a resched
IPI after about six scheduler-clock ticks.  And of course a very
long RCU read-side critical section will extend the grace period, as
it absolutely must.

> > [...] but on the other hand, both tick-independence and the ability 
> > to shield a given CPU from RCU callback execution might be quite 
> > useful. [...]
> 
> Yeah.
> 
> > [...] The tick currently does the following for RCU:
> > 
> > 1.	Informs RCU of user-mode execution (rcu_sched and rcu_bh
> > 	quiescent state).
> > 
> > 2.	Informs RCU of non-dyntick idle mode (again, rcu_sched and
> > 	rcu_bh quiescent state).
> > 
> > 3.	Kicks the current CPU's RCU core processing as needed in
> > 	response to actions from other CPUs.
> > 
> > Frederic's work avoiding ticks in long-running user-mode tasks 
> > might take care of #1, and it should be possible to make use of the 
> > current dyntick-idle APIs to deal with #2.  Replacing #3 
> > efficiently will take some thought.
> 
> What is the longest delay the scheduler tick can take typically - 40 
> msecs? That would then be the worst-case grace period latency for 
> workloads that neither do context switches nor trigger IRQs, right?

40 milliseconds would be 25Hz.  I haven't run that myself, though.
The lowest-HZ systems I use regularly are 250HZ, for 4-millisecond
scheduler-tick period.  So that gets you a grace-period latency from
6 to about 20 milliseconds, depending on what is happening and exactly
what you are measuring.

> > > In any case the proxy kthread model clearly sucked, no argument 
> > > about that.
> > 
> > Indeed, I lost track of the global nature of real-time scheduling.
> > :-(
> 
> Btw., i think that test was pretty bad: running exim as SCHED_FIFO??
> 
> But it does not excuse the kthread model.

"It seemed like a good idea at the time."  ;-)

> > Whatever does the boosting will need to have process context and 
> > can be subject to delays, so that pretty much needs to be a 
> > kthread. But it will context-switch quite rarely, so should not be 
> > a problem.
> 
> So user-return notifiers ought to be the ideal platform for that, 
> right? We don't even have to touch the scheduler: anything that 
> schedules will eventually return to user-space, at which point the 
> RCU GC magic can run.

The RCU-bh variant requires some other mechanism, as it must to work
even if some crazy piece of network infrastructure is hit so hard by a
DoS attack that it never executes in user mode at all.

> And user-return-notifiers can be triggered from IRQs as well.
> 
> That allows us to get rid of softirqs altogether and maybe even speed 
> the whole thing up and allow it to be isolated better.

I am a bit concerned about how this would work with extreme workloads.

							Thanx, Paul

------------------------------------------------------------------------

diff --git a/kernel/rcutree.c b/kernel/rcutree.c
index 405a5fd..f58ce53 100644
--- a/kernel/rcutree.c
+++ b/kernel/rcutree.c
@@ -159,8 +159,14 @@ void rcu_bh_qs(int cpu)
  */
 void rcu_note_context_switch(int cpu)
 {
+	unsigned long flags;
+
 	rcu_sched_qs(cpu);
 	rcu_preempt_note_context_switch(cpu);
+	local_irq_save(flags);
+	if (rcu_pending(cpu))
+		invoke_rcu_core();
+	local_irq_restore(flags);
 }
 EXPORT_SYMBOL_GPL(rcu_note_context_switch);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
