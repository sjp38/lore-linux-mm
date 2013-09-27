Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id ABA616B003B
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 14:22:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so3151410pad.28
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 11:22:33 -0700 (PDT)
Date: Fri, 27 Sep 2013 20:15:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130927181532.GA8401@redhat.com>
References: <20130923173203.GA20392@redhat.com> <20130924202423.GW12926@twins.programming.kicks-ass.net> <20130925155515.GA17447@redhat.com> <20130925174307.GA3220@laptop.programming.kicks-ass.net> <20130925175055.GA25914@redhat.com> <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926165840.GA863@redhat.com> <20130926175016.GI3657@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926175016.GI3657@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/26, Peter Zijlstra wrote:
>
> But if the readers does see BLOCK it will not be an active reader no
> more; and thus the writer doesn't need to observe and wait for it.

I meant they both can block, but please ignore. Today I simply can't
understand what I was thinking about yesterday.


I tried hard to find any hole in this version but failed, I believe it
is correct.

But, could you help me to understand some details?

> +void __get_online_cpus(void)
> +{
> +again:
> +	/* See __srcu_read_lock() */
> +	__this_cpu_inc(__cpuhp_refcount);
> +	smp_mb(); /* A matches B, E */
> +	__this_cpu_inc(cpuhp_seq);
> +
> +	if (unlikely(__cpuhp_state == readers_block)) {

Note that there is no barrier() after inc(seq) and __cpuhp_state
check, this inc() can be "postponed" till ...

> +void __put_online_cpus(void)
>  {
> -	might_sleep();
> -	if (cpu_hotplug.active_writer == current)
> -		return;
> -	mutex_lock(&cpu_hotplug.lock);
> -	cpu_hotplug.refcount++;
> -	mutex_unlock(&cpu_hotplug.lock);
> +	/* See __srcu_read_unlock() */
> +	smp_mb(); /* C matches D */

... this mb() in __put_online_cpus().

And this is fine! The qustion is, perhaps it would be more "natural"
and understandable to shift this_cpu_inc(cpuhp_seq) into
__put_online_cpus().

We need to ensure 2 things:

1. The reader should notic state = BLOCK or the writer should see
   inc(__cpuhp_refcount). This is guaranteed by 2 mb's in
   __get_online_cpus() and in cpu_hotplug_begin().

   We do not care if the writer misses some inc(__cpuhp_refcount)
   in per_cpu_sum(__cpuhp_refcount), that reader(s) should notice
   state = readers_block (and inc(cpuhp_seq) can't help anyway).

2. If the writer sees the result of this_cpu_dec(__cpuhp_refcount)
   from __put_online_cpus() (note that the writer can miss the
   corresponding inc() if it was done on another CPU, so this dec()
   can lead to sum() == 0), it should also notice the change in cpuhp_seq.

   Fortunately, this can only happen if the reader migrates, in
   this case schedule() provides a barrier, the writer can't miss
   the change in cpuhp_seq.

IOW. Unless I missed something, cpuhp_seq is actually needed to
serialize __put_online_cpus()->this_cpu_dec(__cpuhp_refcount) and
and /* D matches C */ in cpuhp_readers_active_check(), and this
is not immediately clear if you look at __get_online_cpus().

I do not suggest to change this code, but please tell me if my
understanding is not correct.

> +static bool cpuhp_readers_active_check(void)
>  {
> -	if (cpu_hotplug.active_writer == current)
> -		return;
> -	mutex_lock(&cpu_hotplug.lock);
> +	unsigned int seq = per_cpu_sum(cpuhp_seq);
> +
> +	smp_mb(); /* B matches A */
> +
> +	/*
> +	 * In other words, if we see __get_online_cpus() cpuhp_seq increment,
> +	 * we are guaranteed to also see its __cpuhp_refcount increment.
> +	 */
>  
> -	if (WARN_ON(!cpu_hotplug.refcount))
> -		cpu_hotplug.refcount++; /* try to fix things up */
> +	if (per_cpu_sum(__cpuhp_refcount) != 0)
> +		return false;
>  
> -	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
> -		wake_up_process(cpu_hotplug.active_writer);
> -	mutex_unlock(&cpu_hotplug.lock);
> +	smp_mb(); /* D matches C */

It seems that both barries could be smp_rmb() ? I am not sure the comments
from srcu_readers_active_idx_check() can explain mb(), note that
__srcu_read_lock() always succeeds unlike get_cpus_online().

>  void cpu_hotplug_done(void)
>  {
> -	cpu_hotplug.active_writer = NULL;
> -	mutex_unlock(&cpu_hotplug.lock);
> +	/* Signal the writer is done, no fast path yet. */
> +	__cpuhp_state = readers_slow;
> +	wake_up_all(&cpuhp_readers);
> +
> +	/*
> +	 * The wait_event()/wake_up_all() prevents the race where the readers
> +	 * are delayed between fetching __cpuhp_state and blocking.
> +	 */
> +
> +	/* See percpu_up_write(); readers will no longer attempt to block. */
> +	synchronize_sched();
> +
> +	/* Let 'em rip */
> +	__cpuhp_state = readers_fast;
> +	current->cpuhp_ref--;
> +
> +	/*
> +	 * Wait for any pending readers to be running. This ensures readers
> +	 * after writer and avoids writers starving readers.
> +	 */
> +	wait_event(cpuhp_writer, !atomic_read(&cpuhp_waitcount));
>  }

OK, to some degree I can understand "avoids writers starving readers"
part (although the next writer should do synchronize_sched() first),
but could you explain "ensures readers after writer" ?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
