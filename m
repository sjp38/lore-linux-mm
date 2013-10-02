Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id E42CA6B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 08:21:02 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so797870pbb.19
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 05:21:02 -0700 (PDT)
Date: Wed, 2 Oct 2013 14:13:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131002121356.GA21581@redhat.com>
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com> <7632387.20FXkuCITr@vostro.rjw.lan> <524B0233.8070203@linux.vnet.ibm.com> <20131001173615.GW3657@laptop.programming.kicks-ass.net> <20131001174508.GA17411@redhat.com> <20131001175640.GQ15690@laptop.programming.kicks-ass.net> <20131001180750.GA18261@redhat.com> <20131002090859.GE12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131002090859.GE12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On 10/02, Peter Zijlstra wrote:
>
> On Tue, Oct 01, 2013 at 08:07:50PM +0200, Oleg Nesterov wrote:
> > > > But note that you do not strictly need this change. Just kill cpuhp_waitcount,
> > > > then we can change cpu_hotplug_begin/end to use xxx_enter/exit we discuss in
> > > > another thread, this should likely "join" all synchronize_sched's.
> > >
> > > That would still be 4k * sync_sched() == terribly long.
> >
> > No? the next xxx_enter() avoids sync_sched() if rcu callback is still
> > pending. Unless __cpufreq_remove_dev_finish() is "too slow" of course.
>
> Hmm,. not in the version you posted; there xxx_enter() would only not do
> the sync_sched if there's a concurrent 'writer', in which case it will
> wait for it.

No, please see below.

> You only avoid the sync_sched in xxx_exit() and potentially join in the
> sync_sched() of a next xxx_begin().
>
> So with that scheme:
>
>   for (i= ; i<4096; i++) {
>     xxx_begin();
>     xxx_exit();
>   }
>
> Will get 4096 sync_sched() calls from the xxx_begin() and all but the
> last xxx_exit() will 'drop' the rcu callback.

No, the code above should call sync_sched() only once, no matter what
this code does between _enter and _exit. This was one of the points.

To clarify, of course I mean the "likely" case. Say, a long preemption
after _exit can lead to another sync_sched().

	void xxx_enter(struct xxx_struct *xxx)
	{
		bool need_wait, need_sync;

		spin_lock_irq(&xxx->xxx_lock);
		need_wait = xxx->gp_count++;
		need_sync = xxx->gp_state == GP_IDLE;
		if (need_sync)
			xxx->gp_state = GP_PENDING;
		spin_unlock_irq(&xxx->xxx_lock);

		BUG_ON(need_wait && need_sync);

		if (need_sync) {
			synchronize_sched();
			xxx->gp_state = GP_PASSED;
			wake_up_all(&xxx->gp_waitq);
		} else if (need_wait) {
			wait_event(&xxx->gp_waitq, xxx->gp_state == GP_PASSED);
		} else {
			BUG_ON(xxx->gp_state != GP_PASSED);
		}
	}

The 1st iteration:

	xxx_enter() does synchronize_sched() and sets gp_state = GP_PASSED.

	xxx_exit() starts the rcu callback, but gp_state is still PASSED.

all other iterations in the "likely" case:

	xxx_enter() should likely come before the pending callback fires
	and clears gp_state. In this case we only increment ->gp_count
	(this "disables" the rcu callback) and do nothing more, gp_state
	is still GP_PASSED.

	xxx_exit() does another call_rcu_sched(), or does the
	CP_PENDING -> CB_REPLAY change. The latter is the same as "start
	another callback".

In short: unless a gp elapses between _exit() and _enter(), the next
_enter() does nothing and avoids synchronize_sched().

> And given the construct; I'm not entirely sure you can do away with the
> sync_sched() in between. While its clear to me you can merge the two
> into one; leaving it out entirely doesn't seem right.

Could you explain?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
