Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 07ADB6B00EA
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 16:26:39 -0400 (EDT)
Date: Thu, 16 Jun 2011 22:25:50 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110616202550.GA16214@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
 <20110616070335.GA7661@elte.hu>
 <20110616171644.GK2582@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616171644.GK2582@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > The funny thing about this workload is that context-switches are 
> > really a fastpath here and we are using anonymous IRQ-triggered 
> > softirqs embedded in random task contexts as a workaround for 
> > that.
> 
> The other thing that the IRQ-triggered softirqs do is to get the 
> callbacks invoked in cases where a CPU-bound user thread is never 
> context switching.

Yeah - but this workload didnt have that.

> Of course, one alternative might be to set_need_resched() to force 
> entry into the scheduler as needed.

No need for that: we can just do the callback not in softirq but in 
regular syscall context in that case, in the return-to-userspace 
notifier. (see TIF_USER_RETURN_NOTIFY and the USER_RETURN_NOTIFIER 
facility)

Abusing a facility like setting need_resched artificially will 
generally cause trouble.

> > [ I think we'll have to revisit this issue and do it properly:
> >   quiescent state is mostly defined by context-switches here, so we
> >   could do the RCU callbacks from the task that turns a CPU
> >   quiescent, right in the scheduler context-switch path - perhaps
> >   with an option for SCHED_FIFO tasks to *not* do GC.
> 
> I considered this approach for TINY_RCU, but dropped it in favor of 
> reducing the interlocking between the scheduler and RCU callbacks. 
> Might be worth revisiting, though.  If SCHED_FIFO task omit RCU 
> callback invocation, then there will need to be some override for 
> CPUs with lots of SCHED_FIFO load, probably similar to RCU's 
> current blimit stuff.

I wouldnt complicate it much for SCHED_FIFO: SCHED_FIFO tasks are 
special and should never run long.

> >   That could possibly be more cache-efficient than softirq execution,
> >   as we'll process a still-hot pool of callbacks instead of doing
> >   them only once per timer tick. It will also make the RCU GC
> >   behavior HZ independent. ]
> 
> Well, the callbacks will normally be cache-cold in any case due to 
> the grace-period delay, [...]

The workloads that are the most critical in this regard tend to be 
context switch intense, so the grace period expiry latency should be 
pretty short.

Or at least significantly shorter than today's HZ frequency, right? 
HZ would still provide an upper bound for the latency.

Btw., the current worst-case grace period latency is in reality more 
like two timer ticks: one for the current CPU to expire and another 
for the longest "other CPU" expiry, right? Average expiry (for 
IRQ-poor workloads) would be 1.5 timer ticks. (if i got my stat 
calculations right!)

> [...] but on the other hand, both tick-independence and the ability 
> to shield a given CPU from RCU callback execution might be quite 
> useful. [...]

Yeah.

> [...] The tick currently does the following for RCU:
> 
> 1.	Informs RCU of user-mode execution (rcu_sched and rcu_bh
> 	quiescent state).
> 
> 2.	Informs RCU of non-dyntick idle mode (again, rcu_sched and
> 	rcu_bh quiescent state).
> 
> 3.	Kicks the current CPU's RCU core processing as needed in
> 	response to actions from other CPUs.
> 
> Frederic's work avoiding ticks in long-running user-mode tasks 
> might take care of #1, and it should be possible to make use of the 
> current dyntick-idle APIs to deal with #2.  Replacing #3 
> efficiently will take some thought.

What is the longest delay the scheduler tick can take typically - 40 
msecs? That would then be the worst-case grace period latency for 
workloads that neither do context switches nor trigger IRQs, right?

> > In any case the proxy kthread model clearly sucked, no argument 
> > about that.
> 
> Indeed, I lost track of the global nature of real-time scheduling.
> :-(

Btw., i think that test was pretty bad: running exim as SCHED_FIFO??

But it does not excuse the kthread model.

> Whatever does the boosting will need to have process context and 
> can be subject to delays, so that pretty much needs to be a 
> kthread. But it will context-switch quite rarely, so should not be 
> a problem.

So user-return notifiers ought to be the ideal platform for that, 
right? We don't even have to touch the scheduler: anything that 
schedules will eventually return to user-space, at which point the 
RCU GC magic can run.

And user-return-notifiers can be triggered from IRQs as well.

That allows us to get rid of softirqs altogether and maybe even speed 
the whole thing up and allow it to be isolated better.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
