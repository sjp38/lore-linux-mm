Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 56CB66B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 16:40:28 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so7678141pbc.17
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 13:40:28 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 1 Oct 2013 14:40:12 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C393819D803E
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 14:40:07 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91Ke92o322608
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 14:40:09 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91KhEHD032131
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 14:43:14 -0600
Date: Tue, 1 Oct 2013 13:40:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001204007.GA13320@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
 <20130924202423.GW12926@twins.programming.kicks-ass.net>
 <20130925155515.GA17447@redhat.com>
 <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926111042.GS3081@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Thu, Sep 26, 2013 at 01:10:42PM +0200, Peter Zijlstra wrote:
> On Wed, Sep 25, 2013 at 02:22:00PM -0700, Paul E. McKenney wrote:
> > A couple of nits and some commentary, but if there are races, they are
> > quite subtle.  ;-)
> 
> *whee*..
> 
> I made one little change in the logic; I moved the waitcount increment
> to before the __put_online_cpus() call, such that the writer will have
> to wait for us to wake up before trying again -- not for us to actually
> have acquired the read lock, for that we'd need to mess up
> __get_online_cpus() a bit more.
> 
> Complete patch below.

OK, looks like Oleg is correct, the cpuhp_seq can be dispensed with.

I still don't see anything wrong with it, so time for a serious stress
test on a large system.  ;-)

Additional commentary interspersed.

							Thanx, Paul

> ---
> Subject: hotplug: Optimize {get,put}_online_cpus()
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue Sep 17 16:17:11 CEST 2013
> 
> The current implementation of get_online_cpus() is global of nature
> and thus not suited for any kind of common usage.
> 
> Re-implement the current recursive r/w cpu hotplug lock such that the
> read side locks are as light as possible.
> 
> The current cpu hotplug lock is entirely reader biased; but since
> readers are expensive there aren't a lot of them about and writer
> starvation isn't a particular problem.
> 
> However by making the reader side more usable there is a fair chance
> it will get used more and thus the starvation issue becomes a real
> possibility.
> 
> Therefore this new implementation is fair, alternating readers and
> writers; this however requires per-task state to allow the reader
> recursion.
> 
> Many comments are contributed by Paul McKenney, and many previous
> attempts were shown to be inadequate by both Paul and Oleg; many
> thanks to them for persisting to poke holes in my attempts.
> 
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> ---
>  include/linux/cpu.h   |   58 +++++++++++++
>  include/linux/sched.h |    3 
>  kernel/cpu.c          |  209 +++++++++++++++++++++++++++++++++++---------------
>  kernel/sched/core.c   |    2 
>  4 files changed, 208 insertions(+), 64 deletions(-)

I stripped the removed lines to keep my eyes from going buggy.

> --- a/include/linux/cpu.h
> +++ b/include/linux/cpu.h
> @@ -16,6 +16,7 @@
>  #include <linux/node.h>
>  #include <linux/compiler.h>
>  #include <linux/cpumask.h>
> +#include <linux/percpu.h>
> 
>  struct device;
> 
> @@ -173,10 +174,61 @@ extern struct bus_type cpu_subsys;
>  #ifdef CONFIG_HOTPLUG_CPU
>  /* Stop CPUs going up and down. */
> 
> +extern void cpu_hotplug_init_task(struct task_struct *p);
> +
>  extern void cpu_hotplug_begin(void);
>  extern void cpu_hotplug_done(void);
> +
> +extern int __cpuhp_state;
> +DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
> +
> +extern void __get_online_cpus(void);
> +
> +static inline void get_online_cpus(void)
> +{
> +	might_sleep();
> +
> +	/* Support reader recursion */
> +	/* The value was >= 1 and remains so, reordering causes no harm. */
> +	if (current->cpuhp_ref++)
> +		return;
> +
> +	preempt_disable();
> +	if (likely(!__cpuhp_state)) {
> +		/* The barrier here is supplied by synchronize_sched(). */

I guess I shouldn't complain about the comment given where it came
from, but...

A more accurate comment would say that we are in an RCU-sched read-side
critical section, so the writer cannot both change __cpuhp_state from
readers_fast and start checking counters while we are here.  So if we see
!__cpuhp_state, we know that the writer won't be checking until we past
the preempt_enable() and that once the synchronize_sched() is done,
the writer will see anything we did within this RCU-sched read-side
critical section.

(The writer -can- change __cpuhp_state from readers_slow to readers_block
while we are in this read-side critical section and then start summing
counters, but that corresponds to a different "if" statement.)

> +		__this_cpu_inc(__cpuhp_refcount);
> +	} else {
> +		__get_online_cpus(); /* Unconditional memory barrier. */
> +	}
> +	preempt_enable();
> +	/*
> +	 * The barrier() from preempt_enable() prevents the compiler from
> +	 * bleeding the critical section out.
> +	 */
> +}
> +
> +extern void __put_online_cpus(void);
> +
> +static inline void put_online_cpus(void)
> +{
> +	/* The value was >= 1 and remains so, reordering causes no harm. */
> +	if (--current->cpuhp_ref)
> +		return;
> +
> +	/*
> +	 * The barrier() in preempt_disable() prevents the compiler from
> +	 * bleeding the critical section out.
> +	 */
> +	preempt_disable();
> +	if (likely(!__cpuhp_state)) {
> +		/* The barrier here is supplied by synchronize_sched().  */

Same here, both for the implied self-criticism and the more complete story.

Due to the basic RCU guarantee, the writer cannot both change __cpuhp_state
and start checking counters while we are in this RCU-sched read-side
critical section.  And again, if the synchronize_sched() had to wait on
us (or if we were early enough that no waiting was needed), then once
the synchronize_sched() completes, the writer will see anything that we
did within this RCU-sched read-side critical section.

> +		__this_cpu_dec(__cpuhp_refcount);
> +	} else {
> +		__put_online_cpus(); /* Unconditional memory barrier. */
> +	}
> +	preempt_enable();
> +}
> +
>  extern void cpu_hotplug_disable(void);
>  extern void cpu_hotplug_enable(void);
>  #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
> @@ -200,6 +252,8 @@ static inline void cpu_hotplug_driver_un
> 
>  #else		/* CONFIG_HOTPLUG_CPU */
> 
> +static inline void cpu_hotplug_init_task(struct task_struct *p) {}
> +
>  static inline void cpu_hotplug_begin(void) {}
>  static inline void cpu_hotplug_done(void) {}
>  #define get_online_cpus()	do { } while (0)
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1454,6 +1454,9 @@ struct task_struct {
>  	unsigned int	sequential_io;
>  	unsigned int	sequential_io_avg;
>  #endif
> +#ifdef CONFIG_HOTPLUG_CPU
> +	int		cpuhp_ref;
> +#endif
>  };
> 
>  /* Future-safe accessor for struct task_struct's cpus_allowed. */
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -49,88 +49,173 @@ static int cpu_hotplug_disabled;
> 
>  #ifdef CONFIG_HOTPLUG_CPU
> 
> +enum { readers_fast = 0, readers_slow, readers_block };
> +
> +int __cpuhp_state;
> +EXPORT_SYMBOL_GPL(__cpuhp_state);
> +
> +DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
> +EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
> +
> +static DEFINE_PER_CPU(unsigned int, cpuhp_seq);
> +static atomic_t cpuhp_waitcount;
> +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_readers);
> +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_writer);
> +
> +void cpu_hotplug_init_task(struct task_struct *p)
> +{
> +	p->cpuhp_ref = 0;
> +}
> +
> +void __get_online_cpus(void)
> +{
> +again:
> +	/* See __srcu_read_lock() */
> +	__this_cpu_inc(__cpuhp_refcount);
> +	smp_mb(); /* A matches B, E */
> +	// __this_cpu_inc(cpuhp_seq);

Deleting the above per Oleg's suggestion.  We still need the preceding
memory barrier.

> +
> +	if (unlikely(__cpuhp_state == readers_block)) {
> +		/*
> +		 * Make sure an outgoing writer sees the waitcount to ensure
> +		 * we make progress.
> +		 */
> +		atomic_inc(&cpuhp_waitcount);
> +		__put_online_cpus();

The decrement happens on the same CPU as the increment, avoiding the
increment-on-one-CPU-and-decrement-on-another problem.

And yes, if the reader misses the writer's assignment of readers_block
to __cpuhp_state, then the writer is guaranteed to see the reader's
increment.  Conversely, any readers that increment their __cpuhp_refcount
after the writer looks are guaranteed to see the readers_block value,
which in turn means that they are guaranteed to immediately decrement
their __cpuhp_refcount, so that it doesn't matter that the writer
missed them.

Unfortunately, this trick does not apply back to SRCU, at least not
without adding a second memory barrier to the srcu_read_lock() path
(one to separate reading the index from incrementing the counter and
another to separate incrementing the counter from the critical section.
Can't have everything, I guess!

> +
> +		/*
> +		 * We either call schedule() in the wait, or we'll fall through
> +		 * and reschedule on the preempt_enable() in get_online_cpus().
> +		 */
> +		preempt_enable_no_resched();
> +		__wait_event(cpuhp_readers, __cpuhp_state != readers_block);
> +		preempt_disable();
> +
> +		if (atomic_dec_and_test(&cpuhp_waitcount))
> +			wake_up_all(&cpuhp_writer);

I still don't see why this is a wake_up_all() given that there can be
only one writer.  Not that it makes much difference, but...

> +
> +		goto again;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(__get_online_cpus);
> 
> +void __put_online_cpus(void)
>  {
> +	/* See __srcu_read_unlock() */
> +	smp_mb(); /* C matches D */
> +	/*
> +	 * In other words, if they see our decrement (presumably to aggregate
> +	 * zero, as that is the only time it matters) they will also see our
> +	 * critical section.
> +	 */
> +	this_cpu_dec(__cpuhp_refcount);
> 
> +	/* Prod writer to recheck readers_active */
> +	wake_up_all(&cpuhp_writer);
>  }
> +EXPORT_SYMBOL_GPL(__put_online_cpus);
> +
> +#define per_cpu_sum(var)						\
> +({ 									\
> + 	typeof(var) __sum = 0;						\
> + 	int cpu;							\
> + 	for_each_possible_cpu(cpu)					\
> + 		__sum += per_cpu(var, cpu);				\
> + 	__sum;								\
> +)}
> 
> +/*
> + * See srcu_readers_active_idx_check() for a rather more detailed explanation.
> + */
> +static bool cpuhp_readers_active_check(void)
>  {
> +	// unsigned int seq = per_cpu_sum(cpuhp_seq);

Delete the above per Oleg's suggestion.

> +
> +	smp_mb(); /* B matches A */
> +
> +	/*
> +	 * In other words, if we see __get_online_cpus() cpuhp_seq increment,
> +	 * we are guaranteed to also see its __cpuhp_refcount increment.
> +	 */
> 
> +	if (per_cpu_sum(__cpuhp_refcount) != 0)
> +		return false;
> 
> +	smp_mb(); /* D matches C */
> 
> +	/*
> +	 * On equality, we know that there could not be any "sneak path" pairs
> +	 * where we see a decrement but not the corresponding increment for a
> +	 * given reader. If we saw its decrement, the memory barriers guarantee
> +	 * that we now see its cpuhp_seq increment.
> +	 */
> +
> +	// return per_cpu_sum(cpuhp_seq) == seq;

Delete the above per Oleg's suggestion, but actually need to replace with
"return true;".  We should be able to get rid of the first memory barrier
(B matches A) because the smp_mb() in cpu_hotplug_begin() covers it, but we
cannot git rid of the second memory barrier (D matches C).

>  }
> 
>  /*
> + * This will notify new readers to block and wait for all active readers to
> + * complete.
>   */
>  void cpu_hotplug_begin(void)
>  {
> +	/*
> +	 * Since cpu_hotplug_begin() is always called after invoking
> +	 * cpu_maps_update_begin(), we can be sure that only one writer is
> +	 * active.
> +	 */
> +	lockdep_assert_held(&cpu_add_remove_lock);
> 
> +	/* Allow reader-in-writer recursion. */
> +	current->cpuhp_ref++;
> +
> +	/* Notify readers to take the slow path. */
> +	__cpuhp_state = readers_slow;
> +
> +	/* See percpu_down_write(); guarantees all readers take the slow path */
> +	synchronize_sched();
> +
> +	/*
> +	 * Notify new readers to block; up until now, and thus throughout the
> +	 * longish synchronize_sched() above, new readers could still come in.
> +	 */
> +	__cpuhp_state = readers_block;
> +
> +	smp_mb(); /* E matches A */
> +
> +	/*
> +	 * If they don't see our writer of readers_block to __cpuhp_state,
> +	 * then we are guaranteed to see their __cpuhp_refcount increment, and
> +	 * therefore will wait for them.
> +	 */
> +
> +	/* Wait for all now active readers to complete. */
> +	wait_event(cpuhp_writer, cpuhp_readers_active_check());
>  }
> 
>  void cpu_hotplug_done(void)
>  {
> +	/* Signal the writer is done, no fast path yet. */
> +	__cpuhp_state = readers_slow;
> +	wake_up_all(&cpuhp_readers);

And one reason that we cannot just immediately flip to readers_fast
is that new readers might fail to see the results of this writer's
critical section.

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
> 
>  /*
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1736,6 +1736,8 @@ static void __sched_fork(unsigned long c
>  	INIT_LIST_HEAD(&p->numa_entry);
>  	p->numa_group = NULL;
>  #endif /* CONFIG_NUMA_BALANCING */
> +
> +	cpu_hotplug_init_task(p);
>  }
> 
>  #ifdef CONFIG_NUMA_BALANCING
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
