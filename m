Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6296B0032
	for <linux-mm@kvack.org>; Sat, 21 Sep 2013 12:41:00 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so1577956pbb.28
        for <linux-mm@kvack.org>; Sat, 21 Sep 2013 09:41:00 -0700 (PDT)
Date: Sat, 21 Sep 2013 18:34:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130921163404.GA8545@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130917162050.GK22421@suse.de> <20130917164505.GG12926@twins.programming.kicks-ass.net> <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130919143241.GB26785@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

Sorry for delay, I was sick...

On 09/19, Peter Zijlstra wrote:
>
> I used a per-cpu spinlock to keep the state check and refcount inc
> atomic vs the setting of state.

I think this could be simpler, see below.

> So the slow path is still per-cpu and mostly uncontended even in the
> pending writer case.

Is it really important? I mean, per-cpu/uncontended even if the writer
is pending?

Otherwise we could do

	static DEFINE_PER_CPU(long, cpuhp_fast_ctr);
	static struct task_struct *cpuhp_writer;
	static DEFINE_MUTEX(cpuhp_slow_lock)
	static long cpuhp_slow_ctr;

	static bool update_fast_ctr(int inc)
	{
		bool success = true;

		preempt_disable();
		if (likely(!cpuhp_writer))
			__get_cpu_var(cpuhp_fast_ctr) += inc;
		else if (cpuhp_writer != current)
			success = false;
		preempt_enable();

		return success;
	}

	void get_online_cpus(void)
	{
		if (likely(update_fast_ctr(+1));
			return;

		mutex_lock(&cpuhp_slow_lock);
		cpuhp_slow_ctr++;
		mutex_unlock(&cpuhp_slow_lock);
	}

	void put_online_cpus(void)
	{
		if (likely(update_fast_ctr(-1));
			return;

		mutex_lock(&cpuhp_slow_lock);
		if (!--cpuhp_slow_ctr && cpuhp_writer)
			wake_up_process(cpuhp_writer);
		mutex_unlock(&cpuhp_slow_lock);
	}

	static void clear_fast_ctr(void)
	{
		long total = 0;
		int cpu;

		for_each_possible_cpu(cpu) {
			total += per_cpu(cpuhp_fast_ctr, cpu);
			per_cpu(cpuhp_fast_ctr, cpu) = 0;
		}

		return total;
	}

	static void cpu_hotplug_begin(void)
	{
		cpuhp_writer = current;
		synchronize_sched();

		/* Nobody except us can use can use cpuhp_fast_ctr */

		mutex_lock(&cpuhp_slow_lock);
		cpuhp_slow_ctr += clear_fast_ctr();

		while (cpuhp_slow_ctr) {
			__set_current_state(TASK_UNINTERRUPTIBLE);
			mutex_unlock(&&cpuhp_slow_lock);
			schedule();
			mutex_lock(&cpuhp_slow_lock);
		}
	}

	static void cpu_hotplug_done(void)
	{
		cpuhp_writer = NULL;
		mutex_unlock(&cpuhp_slow_lock);
	}

I already sent this code in 2010, it needs some trivial updates.

But. We already have percpu_rw_semaphore, can't we reuse it? In fact
I thought about this from the very beginning. Just we need
percpu_down_write_recursive_readers() which does

	bool xxx(brw)
	{
		if (down_trylock(&brw->rw_sem))
			return false;
		if (!atomic_read(&brw->slow_read_ctr))
			return true;
		up_write(&brw->rw_sem);
			return false;
	}

	ait_event(brw->write_waitq, xxx(brw));

instead of down_write() + wait_event(!atomic_read(&brw->slow_read_ctr)).

The only problem is the lockdep annotations in percpu_down_read(), but
this looks simple, just we need down_read_no_lockdep() (like __up_read).

Note also that percpu_down_write/percpu_up_write can be improved wrt
synchronize_sched(). We can turn the 2nd one into call_rcu(), and the
1nd one can be avoided if another percpu_down_write() comes "soon after"
percpu_down_up().


As for the patch itself, I am not sure.

> +static void cpuph_wait_refcount(void)
> +{
> +	for (;;) {
> +		unsigned int refcnt = 0;
> +		int cpu;
> +
> +		set_current_state(TASK_UNINTERRUPTIBLE);
> +
> +		for_each_possible_cpu(cpu)
> +			refcnt += per_cpu(__cpuhp_refcount, cpu);
> +
> +		if (!refcnt)
> +			break;
> +
> +		schedule();
> +	}
> +	__set_current_state(TASK_RUNNING);
> +}

It seems, this can succeed while it should not, see below.

>  void cpu_hotplug_begin(void)
>  {
> -	cpu_hotplug.active_writer = current;
> +	lockdep_assert_held(&cpu_add_remove_lock);
>
> -	for (;;) {
> -		mutex_lock(&cpu_hotplug.lock);
> -		if (likely(!cpu_hotplug.refcount))
> -			break;
> -		__set_current_state(TASK_UNINTERRUPTIBLE);
> -		mutex_unlock(&cpu_hotplug.lock);
> -		schedule();
> -	}
> +	__cpuhp_writer = current;
> +
> +	/* After this everybody will observe _writer and take the slow path. */
> +	synchronize_sched();

Yes, the reader should see _writer, but:

> +	/* Wait for no readers -- reader preference */
> +	cpuhp_wait_refcount();

but how we can ensure the writer sees the results of the reader's updates?

Suppose that we have 2 CPU's, __cpuhp_refcount[0] = 0, __cpuhp_refcount[1] = 1.
IOW, we have a single R reader which takes this lock on CPU_1 and sleeps.

Now,

	- The writer calls cpuph_wait_refcount()

	- cpuph_wait_refcount() does refcnt += __cpuhp_refcount[0].
	  refcnt == 0.

	- another reader comes on CPU_0, increments __cpuhp_refcount[0].

	- this reader migrates to CPU_1 and does put_online_cpus(),
	  this decrements __cpuhp_refcount[1] which becomes zero.

	- cpuph_wait_refcount() continues and reads __cpuhp_refcount[1]
	  which is zero. refcnt == 0, return.

	- The writer does cpuhp_set_state(1).

	- The reader R (original reader) wakes up, calls get_online_cpus()
	  recursively, and sleeps in wait_event(!__cpuhp_writer).

Btw, I think that  __sb_start_write/etc is equally wrong. Perhaps it is
another potential user of percpu_rw_sem.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
