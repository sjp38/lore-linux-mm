Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDC45F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 00:06:35 -0400 (EDT)
Date: Tue, 7 Apr 2009 14:04:04 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: + mm-align-vmstat_works-timer.patch added to -mm tree
Message-ID: <20090407040404.GB9584@kryten>
References: <200904011945.n31JjWqG028114@imap1.linux-foundation.org> <20090406120533.450B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090406120533.450B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


Hi,

> Do you have any mesurement data?

I was using a simple set of kprobes to look at when timers and
workqueues fire.

> The fact is, schedule_delayed_work(work, round_jiffies_relative()) is
> a bit ill.
> 
> it mean
>   - round_jiffies_relative() calculate rounded-time - jiffies
>   - schedule_delayed_work() calculate argument + jiffies
> 
> it assume no jiffies change at above two place. IOW it assume
> non preempt kernel.

I'm not sure we are any worse off here. Before the patch we could end up
with all threads converging on the same jiffy, and once that happens
they will continue to fire over the top of each other (at least until a
difference in the time it takes vmstat_work to complete causes them to
diverge again).

With the patch we always apply a per cpu offset, so should keep them
separated even if jiffies sometimes changes between
round_jiffies_relative() and schedule_delayed_work().

> 2)
> > -	schedule_delayed_work_on(cpu, vmstat_work, HZ + cpu);
> > +	schedule_delayed_work_on(cpu, vmstat_work,
> > +				 __round_jiffies_relative(HZ, cpu));
> 
> isn't same meaning.
> 
> vmstat_work mean to move per-cpu stastics to global stastics.
> Then, (HZ + cpu) mean to avoid to touch the same global variable at the same time.

round_jiffies_common still provides per cpu skew doesn't it?

        /*
         * We don't want all cpus firing their timers at once hitting the
         * same lock or cachelines, so we skew each extra cpu with an extra
         * 3 jiffies. This 3 jiffies came originally from the mm/ code which
         * already did this.
         * The skew is done by adding 3*cpunr, then round, then subtract this
         * extra offset again.
         */

In fact we are also skewing timer interrupts across half a timer tick in
tick_setup_sched_timer:

	/* Get the next period (per cpu) */
	hrtimer_set_expires(&ts->sched_timer, tick_init_jiffy_update());
	offset = ktime_to_ns(tick_period) >> 1;
	do_div(offset, num_possible_cpus());
	offset *= smp_processor_id();
	hrtimer_add_expires_ns(&ts->sched_timer, offset);

I still need to see if I can measure a reduction in jitter by removing
this half jiffy skew and aligning all timer interrupts. Assuming we skew
per cpu work and timers, it seems like we shouldn't need to skew timer
interrupts too.

> but I agree vmstat_work is one of most work queue heavy user.
> For power consumption view, it isn't proper behavior.
> 
> I still think improving another way.

I definitely agree it would be nice to fix vmstat_work :)

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
