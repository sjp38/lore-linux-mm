Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 85BFB6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:16:54 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GGqdBj023935
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:52:39 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GHGqqo132986
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:16:52 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GHGkJ6011847
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:16:49 -0400
Date: Thu, 16 Jun 2011 10:16:44 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110616171644.GK2582@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
 <20110616070335.GA7661@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616070335.GA7661@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 09:03:35AM +0200, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > 
> > 
> > Ingo Molnar <mingo@elte.hu> wrote:
> > >
> > > I have this fix queued up currently:
> > >
> > >  09223371deac: rcu: Use softirq to address performance regression
> > 
> > I really don't think that is even close to enough.
> 
> Yeah.
> 
> > It still does all the callbacks in the threads, and according to 
> > Peter, about half the rcu time in the threads remained..
> 
> You are right - things that are a few percent on a 24 core machine 
> will definitely go exponentially worse on larger boxen. We'll get rid 
> of the kthreads entirely.

I did indeed at one time have access to larger test systems than I
do now, and I clearly need to fix that.  :-/

> The funny thing about this workload is that context-switches are 
> really a fastpath here and we are using anonymous IRQ-triggered 
> softirqs embedded in random task contexts as a workaround for that.

The other thing that the IRQ-triggered softirqs do is to get the callbacks
invoked in cases where a CPU-bound user thread is never context switching.
Of course, one alternative might be to set_need_resched() to force entry
into the scheduler as needed.

> [ I think we'll have to revisit this issue and do it properly:
>   quiescent state is mostly defined by context-switches here, so we
>   could do the RCU callbacks from the task that turns a CPU
>   quiescent, right in the scheduler context-switch path - perhaps
>   with an option for SCHED_FIFO tasks to *not* do GC.

I considered this approach for TINY_RCU, but dropped it in favor of
reducing the interlocking between the scheduler and RCU callbacks.
Might be worth revisiting, though.  If SCHED_FIFO task omit RCU callback
invocation, then there will need to be some override for CPUs with lots
of SCHED_FIFO load, probably similar to RCU's current blimit stuff.

>   That could possibly be more cache-efficient than softirq execution,
>   as we'll process a still-hot pool of callbacks instead of doing
>   them only once per timer tick. It will also make the RCU GC
>   behavior HZ independent. ]

Well, the callbacks will normally be cache-cold in any case due to the
grace-period delay, but on the other hand, both tick-independence and
the ability to shield a given CPU from RCU callback execution might be
quite useful.  The tick currently does the following for RCU:

1.	Informs RCU of user-mode execution (rcu_sched and rcu_bh
	quiescent state).

2.	Informs RCU of non-dyntick idle mode (again, rcu_sched and
	rcu_bh quiescent state).

3.	Kicks the current CPU's RCU core processing as needed in
	response to actions from other CPUs.

Frederic's work avoiding ticks in long-running user-mode tasks
might take care of #1, and it should be possible to make use of
the current dyntick-idle APIs to deal with #2.  Replacing #3
efficiently will take some thought.

> In any case the proxy kthread model clearly sucked, no argument about 
> that.

Indeed, I lost track of the global nature of real-time scheduling.  :-(

Whatever does the boosting will need to have process context and
can be subject to delays, so that pretty much needs to be a kthread.
But it will context-switch quite rarely, so should not be a problem.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
