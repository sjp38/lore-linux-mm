Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id DAC196B0036
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:39:32 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so4836359pbb.28
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:39:32 -0700 (PDT)
Date: Tue, 24 Sep 2013 12:39:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924123927.32da5c1e@gandalf.local.home>
In-Reply-To: <20130924123821.GT12926@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130917162050.GK22421@suse.de>
	<20130917164505.GG12926@twins.programming.kicks-ass.net>
	<20130918154939.GZ26785@twins.programming.kicks-ass.net>
	<20130919143241.GB26785@twins.programming.kicks-ass.net>
	<20130923175052.GA20991@redhat.com>
	<20130924123821.GT12926@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, 24 Sep 2013 14:38:21 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> +#define cpuhp_writer_wait(cond)						\
> +do {									\
> +	for (;;) {							\
> +		set_current_state(TASK_UNINTERRUPTIBLE);		\
> +		if (cond)						\
> +			break;						\
> +		schedule();						\
> +	}								\
> +	__set_current_state(TASK_RUNNING);				\
> +} while (0)
> +
> +void __get_online_cpus(void)

The above really needs a comment about how it is used. Otherwise, I can
envision someone calling this as "oh I can use this when I'm in a
preempt disable section", and the comment below for the
preempt_enable_no_resched() will no longer be true.

-- Steve


>  {
> -	if (cpu_hotplug.active_writer == current)
> +	if (cpuhp_writer_task == current)
>  		return;
> -	mutex_lock(&cpu_hotplug.lock);
>  
> -	if (WARN_ON(!cpu_hotplug.refcount))
> -		cpu_hotplug.refcount++; /* try to fix things up */
> +	atomic_inc(&cpuhp_waitcount);
> +
> +	/*
> +	 * We either call schedule() in the wait, or we'll fall through
> +	 * and reschedule on the preempt_enable() in get_online_cpus().
> +	 */
> +	preempt_enable_no_resched();
> +	wait_event(cpuhp_wq, !__cpuhp_writer);
> +	preempt_disable();
> +
> +	/*
> +	 * It would be possible for cpu_hotplug_done() to complete before
> +	 * the atomic_inc() above; in which case there is no writer waiting
> +	 * and doing a wakeup would be BAD (tm).
> +	 *
> +	 * If however we still observe cpuhp_writer_task here we know
> +	 * cpu_hotplug_done() is currently stuck waiting for cpuhp_waitcount.
> +	 */
> +	if (atomic_dec_and_test(&cpuhp_waitcount) && cpuhp_writer_task)
> +		cpuhp_writer_wake();
> +}
> +EXPORT_SYMBOL_GPL(__get_online_cpus);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
