Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id B23736B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:09:55 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5067573pbb.13
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 14:09:55 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 24 Sep 2013 15:09:51 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 82C781FF001C
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 15:09:43 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8OL9n91320592
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 15:09:49 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8OLCmPw024462
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 15:12:48 -0600
Date: Tue, 24 Sep 2013 14:09:43 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924210943.GI9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924144236.GB9093@linux.vnet.ibm.com>
 <20130924160959.GO9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924160959.GO9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 24, 2013 at 06:09:59PM +0200, Peter Zijlstra wrote:
> On Tue, Sep 24, 2013 at 07:42:36AM -0700, Paul E. McKenney wrote:
> > > +#define cpuhp_writer_wake()						\
> > > +	wake_up_process(cpuhp_writer_task)
> > > +
> > > +#define cpuhp_writer_wait(cond)						\
> > > +do {									\
> > > +	for (;;) {							\
> > > +		set_current_state(TASK_UNINTERRUPTIBLE);		\
> > > +		if (cond)						\
> > > +			break;						\
> > > +		schedule();						\
> > > +	}								\
> > > +	__set_current_state(TASK_RUNNING);				\
> > > +} while (0)
> > 
> > Why not wait_event()?  Presumably the above is a bit lighter weight,
> > but is that even something that can be measured?
> 
> I didn't want to mix readers and writers on cpuhp_wq, and I suppose I
> could create a second waitqueue; that might also be a better solution
> for the NULL thing below.

That would have the advantage of being a bit less racy.

> > > +	atomic_inc(&cpuhp_waitcount);
> > > +
> > > +	/*
> > > +	 * We either call schedule() in the wait, or we'll fall through
> > > +	 * and reschedule on the preempt_enable() in get_online_cpus().
> > > +	 */
> > > +	preempt_enable_no_resched();
> > > +	wait_event(cpuhp_wq, !__cpuhp_writer);
> > 
> > Finally!  A good use for preempt_enable_no_resched().  ;-)
> 
> Hehe, there were a few others, but tglx removed most with the
> schedule_preempt_disabled() primitive.

;-)

> In fact, I considered a wait_event_preempt_disabled() but was too lazy.
> That whole wait_event macro fest looks like it could use an iteration or
> two of collapse anyhow.

There are some serious layers there, aren't there?

> > > +	preempt_disable();
> > > +
> > > +	/*
> > > +	 * It would be possible for cpu_hotplug_done() to complete before
> > > +	 * the atomic_inc() above; in which case there is no writer waiting
> > > +	 * and doing a wakeup would be BAD (tm).
> > > +	 *
> > > +	 * If however we still observe cpuhp_writer_task here we know
> > > +	 * cpu_hotplug_done() is currently stuck waiting for cpuhp_waitcount.
> > > +	 */
> > > +	if (atomic_dec_and_test(&cpuhp_waitcount) && cpuhp_writer_task)
> > 
> > OK, I'll bite...  What sequence of events results in the
> > atomic_dec_and_test() returning true but there being no
> > cpuhp_writer_task?
> > 
> > Ah, I see it...
> 
> <snip>
> 
> Indeed, and
> 
> > But what prevents the following sequence of events?
> 
> <snip>
> 
> > o	Task B's call to cpuhp_writer_wake() sees a NULL pointer.
> 
> Quite so.. nothing. See there was a reason I kept being confused about
> it.
> 
> > >  void cpu_hotplug_begin(void)
> > >  {
> > > +	unsigned int count = 0;
> > > +	int cpu;
> > > +
> > > +	lockdep_assert_held(&cpu_add_remove_lock);
> > > 
> > > +	__cpuhp_writer = 1;
> > > +	cpuhp_writer_task = current;
> > 
> > At this point, the value of cpuhp_slowcount can go negative.  Can't see
> > that this causes a problem, given the atomic_add() below.
> 
> Agreed.
> 
> > > +
> > > +	/* After this everybody will observe writer and take the slow path. */
> > > +	synchronize_sched();
> > > +
> > > +	/* Collapse the per-cpu refcount into slowcount */
> > > +	for_each_possible_cpu(cpu) {
> > > +		count += per_cpu(__cpuhp_refcount, cpu);
> > > +		per_cpu(__cpuhp_refcount, cpu) = 0;
> > >  	}
> > 
> > The above is safe because the readers are no longer changing their
> > __cpuhp_refcount values.
> 
> Yes, I'll expand the comment.
> 
> So how about something like this?

A few memory barriers required, if I am reading the code correctly.
Some of them, perhaps all of them, called out by Oleg.

							Thanx, Paul

> ---
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
> @@ -173,10 +174,50 @@ extern struct bus_type cpu_subsys;
>  #ifdef CONFIG_HOTPLUG_CPU
>  /* Stop CPUs going up and down. */
> 
> +extern void cpu_hotplug_init_task(struct task_struct *p);
> +
>  extern void cpu_hotplug_begin(void);
>  extern void cpu_hotplug_done(void);
> -extern void get_online_cpus(void);
> -extern void put_online_cpus(void);
> +
> +extern struct task_struct *__cpuhp_writer;
> +DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
> +
> +extern void __get_online_cpus(void);
> +
> +static inline void get_online_cpus(void)
> +{
> +	might_sleep();
> +
> +	/* Support reader-in-reader recursion */
> +	if (current->cpuhp_ref++) {
> +		barrier();
> +		return;
> +	}
> +
> +	preempt_disable();
> +	if (likely(!__cpuhp_writer))
> +		__this_cpu_inc(__cpuhp_refcount);

As Oleg noted, need a barrier here for when a new reader runs concurrently
with a completing writer.

> +	else
> +		__get_online_cpus();
> +	preempt_enable();
> +}
> +
> +extern void __put_online_cpus(void);
> +
> +static inline void put_online_cpus(void)
> +{
> +	barrier();
> +	if (--current->cpuhp_ref)
> +		return;
> +
> +	preempt_disable();
> +	if (likely(!__cpuhp_writer))
> +		__this_cpu_dec(__cpuhp_refcount);

No barrier needed here because synchronize_sched() covers it.

> +	else
> +		__put_online_cpus();
> +	preempt_enable();
> +}
> +
>  extern void cpu_hotplug_disable(void);
>  extern void cpu_hotplug_enable(void);
>  #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
> @@ -200,6 +241,8 @@ static inline void cpu_hotplug_driver_un
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
> @@ -49,88 +49,100 @@ static int cpu_hotplug_disabled;
> 
>  #ifdef CONFIG_HOTPLUG_CPU
> 
> -static struct {
> -	struct task_struct *active_writer;
> -	struct mutex lock; /* Synchronizes accesses to refcount, */
> -	/*
> -	 * Also blocks the new readers during
> -	 * an ongoing cpu hotplug operation.
> -	 */
> -	int refcount;
> -} cpu_hotplug = {
> -	.active_writer = NULL,
> -	.lock = __MUTEX_INITIALIZER(cpu_hotplug.lock),
> -	.refcount = 0,
> -};
> +struct task_struct *__cpuhp_writer;
> +EXPORT_SYMBOL_GPL(__cpuhp_writer);
> 
> -void get_online_cpus(void)
> -{
> -	might_sleep();
> -	if (cpu_hotplug.active_writer == current)
> -		return;
> -	mutex_lock(&cpu_hotplug.lock);
> -	cpu_hotplug.refcount++;
> -	mutex_unlock(&cpu_hotplug.lock);
> +DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
> +EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
> +
> +static atomic_t cpuhp_waitcount;
> +static atomic_t cpuhp_slowcount;
> +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_readers);
> +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_writer);
> 
> +void cpu_hotplug_init_task(struct task_struct *p)
> +{
> +	p->cpuhp_ref = 0;
>  }
> -EXPORT_SYMBOL_GPL(get_online_cpus);
> 
> -void put_online_cpus(void)
> +void __get_online_cpus(void)
>  {
> -	if (cpu_hotplug.active_writer == current)
> +	/* Support reader-in-writer recursion */
> +	if (__cpuhp_writer == current)
>  		return;
> -	mutex_lock(&cpu_hotplug.lock);
> 
> -	if (WARN_ON(!cpu_hotplug.refcount))
> -		cpu_hotplug.refcount++; /* try to fix things up */
> +	atomic_inc(&cpuhp_waitcount);
> 
> -	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
> -		wake_up_process(cpu_hotplug.active_writer);
> -	mutex_unlock(&cpu_hotplug.lock);
> +	/*
> +	 * We either call schedule() in the wait, or we'll fall through
> +	 * and reschedule on the preempt_enable() in get_online_cpus().
> +	 */
> +	preempt_enable_no_resched();
> +	wait_event(cpuhp_readers, !__cpuhp_writer);
> +	preempt_disable();
> +
> +	if (atomic_dec_and_test(&cpuhp_waitcount))

This provides the needed memory barrier for concurrent write releases.

> +		wake_up_all(&cpuhp_writer);
> +}
> +EXPORT_SYMBOL_GPL(__get_online_cpus);
> +
> +void __put_online_cpus(void)
> +{
> +	if (__cpuhp_writer == current)
> +		return;
> 
> +	if (atomic_dec_and_test(&cpuhp_slowcount))

This provides the needed memory barrier for concurrent write acquisitions.

> +		wake_up_all(&cpuhp_writer);
>  }
> -EXPORT_SYMBOL_GPL(put_online_cpus);
> +EXPORT_SYMBOL_GPL(__put_online_cpus);
> 
>  /*
>   * This ensures that the hotplug operation can begin only when the
>   * refcount goes to zero.
>   *
> - * Note that during a cpu-hotplug operation, the new readers, if any,
> - * will be blocked by the cpu_hotplug.lock
> - *
>   * Since cpu_hotplug_begin() is always called after invoking
>   * cpu_maps_update_begin(), we can be sure that only one writer is active.
> - *
> - * Note that theoretically, there is a possibility of a livelock:
> - * - Refcount goes to zero, last reader wakes up the sleeping
> - *   writer.
> - * - Last reader unlocks the cpu_hotplug.lock.
> - * - A new reader arrives at this moment, bumps up the refcount.
> - * - The writer acquires the cpu_hotplug.lock finds the refcount
> - *   non zero and goes to sleep again.
> - *
> - * However, this is very difficult to achieve in practice since
> - * get_online_cpus() not an api which is called all that often.
> - *
>   */
>  void cpu_hotplug_begin(void)
>  {
> -	cpu_hotplug.active_writer = current;
> +	unsigned int count = 0;
> +	int cpu;
> +
> +	lockdep_assert_held(&cpu_add_remove_lock);
> 
> -	for (;;) {
> -		mutex_lock(&cpu_hotplug.lock);
> -		if (likely(!cpu_hotplug.refcount))
> -			break;
> -		__set_current_state(TASK_UNINTERRUPTIBLE);
> -		mutex_unlock(&cpu_hotplug.lock);
> -		schedule();
> +	__cpuhp_writer = current;
> +
> +	/* 
> +	 * After this everybody will observe writer and take the slow path.
> +	 */
> +	synchronize_sched();
> +
> +	/* 
> +	 * Collapse the per-cpu refcount into slowcount. This is safe because
> +	 * readers are now taking the slow path (per the above) which doesn't
> +	 * touch __cpuhp_refcount.
> +	 */
> +	for_each_possible_cpu(cpu) {
> +		count += per_cpu(__cpuhp_refcount, cpu);
> +		per_cpu(__cpuhp_refcount, cpu) = 0;
>  	}
> +	atomic_add(count, &cpuhp_slowcount);
> +
> +	/* Wait for all readers to go away */
> +	wait_event(cpuhp_writer, !atomic_read(&cpuhp_slowcount));

Oddly enough, there appear to be cases where you need a memory barrier
here.  Suppose that all the readers finish after the atomic_add() above,
but before the wait_event().  Then wait_event() just checks the condition
without any memory barriers.  So smp_mb() needed here.

/me runs off to check RCU's use of wait_event()...

Found one missing.  And some places in need of comments.  And a few
places that could use an ACCESS_ONCE().

Back to the review...

>  }
> 
>  void cpu_hotplug_done(void)
>  {
> -	cpu_hotplug.active_writer = NULL;
> -	mutex_unlock(&cpu_hotplug.lock);
> +	/* Signal the writer is done */

And I believe we need a memory barrier here to keep the write-side
critical section confined from the viewpoint of a reader that starts
just after the NULLing of cpuhp_writer.

Of course, being who I am, I cannot resist pointing out that you have
the same number of memory barriers as would use of SRCU, and that
synchronize_srcu() can be quite a bit faster than synchronize_sched()
in the case where there are no readers.  ;-)

> +	cpuhp_writer = NULL;
> +	wake_up_all(&cpuhp_readers);
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
