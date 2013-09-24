Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id AB10B6B0034
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:10:54 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so4793935pdi.41
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:10:54 -0700 (PDT)
Date: Tue, 24 Sep 2013 18:03:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924160359.GA2739@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130917162050.GK22421@suse.de> <20130917164505.GG12926@twins.programming.kicks-ass.net> <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net> <20130923175052.GA20991@redhat.com> <20130924123821.GT12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924123821.GT12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/24, Peter Zijlstra wrote:
>
> +static inline void get_online_cpus(void)
> +{
> +	might_sleep();
> +
> +	if (current->cpuhp_ref++) {
> +		barrier();
> +		return;

I don't undestand this barrier()... we are going to return if we already
hold the lock, do we really need it?

The same for put_online_cpus().

> +void __get_online_cpus(void)
>  {
> -	if (cpu_hotplug.active_writer == current)
> +	if (cpuhp_writer_task == current)
>  		return;

Probably it would be better to simply inc/dec ->cpuhp_ref in
cpu_hotplug_begin/end and remove this check here and in
__put_online_cpus().

This also means that the writer doing get/put_online_cpus() will
always use the fast path, and __cpuhp_writer can go away,
cpuhp_writer_task != NULL can be used instead.

> +     atomic_inc(&cpuhp_waitcount);
> +
> +     /*
> +      * We either call schedule() in the wait, or we'll fall through
> +      * and reschedule on the preempt_enable() in get_online_cpus().
> +      */
> +     preempt_enable_no_resched();
> +     wait_event(cpuhp_wq, !__cpuhp_writer);
> +     preempt_disable();
> +
> +     /*
> +      * It would be possible for cpu_hotplug_done() to complete before
> +      * the atomic_inc() above; in which case there is no writer waiting
> +      * and doing a wakeup would be BAD (tm).
> +      *
> +      * If however we still observe cpuhp_writer_task here we know
> +      * cpu_hotplug_done() is currently stuck waiting for cpuhp_waitcount.
> +      */
> +     if (atomic_dec_and_test(&cpuhp_waitcount) && cpuhp_writer_task)
> +             cpuhp_writer_wake();

cpuhp_writer_wake() here and in __put_online_cpus() looks racy...
Not only cpuhp_writer_wake() can hit cpuhp_writer_task == NULL (we need
something like ACCESS_ONCE()), its task_struct can be already freed/reused
if the writer exits.

And I don't really understand the logic... This slow path succeds without
incrementing any counter (except current->cpuhp_ref)? How the next writer
can notice the fact it should wait for this reader?

>  void cpu_hotplug_done(void)
>  {
> -	cpu_hotplug.active_writer = NULL;
> -	mutex_unlock(&cpu_hotplug.lock);
> +	/* Signal the writer is done */
> +	cpuhp_writer = 0;
> +	wake_up_all(&cpuhp_wq);
> +
> +	/* Wait for any pending readers to be running */
> +	cpuhp_writer_wait(!atomic_read(&cpuhp_waitcount));
> +	cpuhp_writer_task = NULL;

We also need to ensure that the next reader should see all changes
done by the writer, iow this lacks "realease" semantics.




But, Peter, the main question is, why this is better than
percpu_rw_semaphore performance-wise? (Assuming we add
task_struct->cpuhp_ref).

If the writer is pending, percpu_down_read() does

	down_read(&brw->rw_sem);
	atomic_inc(&brw->slow_read_ctr);
	__up_read(&brw->rw_sem);

is it really much worse than wait_event + atomic_dec_and_test?

And! please note that with your implementation the new readers will
be likely blocked while the writer sleeps in synchronize_sched().
This doesn't happen with percpu_rw_semaphore.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
