Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CDEB16B0034
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 12:20:58 -0400 (EDT)
Date: Tue, 17 Sep 2013 17:20:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130917162050.GK22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130917143003.GA29354@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 17, 2013 at 04:30:03PM +0200, Peter Zijlstra wrote:
> Subject: hotplug: Optimize {get,put}_online_cpus()
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue Sep 17 16:17:11 CEST 2013
> 
> The cpu hotplug lock is a purely reader biased read-write lock.
> 
> The current implementation uses global state, change it so the reader
> side uses per-cpu state in the uncontended fast-path.
> 
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> ---
>  include/linux/cpu.h |   33 ++++++++++++++-
>  kernel/cpu.c        |  108 ++++++++++++++++++++++++++--------------------------
>  2 files changed, 87 insertions(+), 54 deletions(-)
> 
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
> @@ -175,8 +176,36 @@ extern struct bus_type cpu_subsys;
>  
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
> +	this_cpu_inc(__cpuhp_refcount);
> +	/*
> +	 * Order the refcount inc against the writer read; pairs with the full
> +	 * barrier in cpu_hotplug_begin().
> +	 */
> +	smp_mb();
> +	if (unlikely(__cpuhp_writer))
> +		__get_online_cpus();
> +}
> +

If the problem with get_online_cpus() is the shared global state then a
full barrier in the fast path is still going to hurt. Granted, it will hurt
a lot less and there should be no lock contention.

However, what barrier in cpu_hotplug_begin is the comment referring to? The
other barrier is in the slowpath __get_online_cpus. Did you mean to do
a rmb here and a wmb after __cpuhp_writer is set in cpu_hotplug_begin?
I'm assuming you are currently using a full barrier to guarantee that an
update if cpuhp_writer will be visible so get_online_cpus blocks but I'm
not 100% sure because of the comments.

> +extern void __put_online_cpus(void);
> +
> +static inline void put_online_cpus(void)
> +{
> +	barrier();

Why is this barrier necessary? I could not find anything that stated if an
inline function is an implicit compiler barrier but whether it is or not,
it's not clear why it's necessary at all.

> +	this_cpu_dec(__cpuhp_refcount);
> +	if (unlikely(__cpuhp_writer))
> +		__put_online_cpus();
> +}
> +
>  extern void cpu_hotplug_disable(void);
>  extern void cpu_hotplug_enable(void);
>  #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -49,88 +49,92 @@ static int cpu_hotplug_disabled;
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
> +struct task_struct *__cpuhp_writer = NULL;
> +EXPORT_SYMBOL_GPL(__cpuhp_writer);
> +
> +DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
> +EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
>  
> -void get_online_cpus(void)
> +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_wq);
> +
> +void __get_online_cpus(void)
>  {
> -	might_sleep();
> -	if (cpu_hotplug.active_writer == current)
> +	if (__cpuhp_writer == current)
>  		return;
> -	mutex_lock(&cpu_hotplug.lock);
> -	cpu_hotplug.refcount++;
> -	mutex_unlock(&cpu_hotplug.lock);
>  
> +again:
> +	/*
> +	 * Ensure a pending reading has a 0 refcount.
> +	 *
> +	 * Without this a new reader that comes in before cpu_hotplug_begin()
> +	 * reads the refcount will deadlock.
> +	 */
> +	this_cpu_dec(__cpuhp_refcount);
> +	wait_event(cpuhp_wq, !__cpuhp_writer);
> +
> +	this_cpu_inc(__cpuhp_refcount);
> +	/*
> +	 * See get_online_cpu().
> +	 */
> +	smp_mb();
> +	if (unlikely(__cpuhp_writer))
> +		goto again;
>  }

If CPU hotplug operations are very frequent (or a stupid stress test) then
it's possible for a new hotplug operation to start (updating __cpuhp_writer)
before a caller to __get_online_cpus can update the refcount. Potentially
a caller to __get_online_cpus gets starved although as it only affects a
CPU hotplug stress test it may not be a serious issue.

> -EXPORT_SYMBOL_GPL(get_online_cpus);
> +EXPORT_SYMBOL_GPL(__get_online_cpus);
>  
> -void put_online_cpus(void)
> +void __put_online_cpus(void)
>  {
> -	if (cpu_hotplug.active_writer == current)
> -		return;
> -	mutex_lock(&cpu_hotplug.lock);
> +	unsigned int refcnt = 0;
> +	int cpu;
>  
> -	if (WARN_ON(!cpu_hotplug.refcount))
> -		cpu_hotplug.refcount++; /* try to fix things up */
> +	if (__cpuhp_writer == current)
> +		return;
>  
> -	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
> -		wake_up_process(cpu_hotplug.active_writer);
> -	mutex_unlock(&cpu_hotplug.lock);
> +	for_each_possible_cpu(cpu)
> +		refcnt += per_cpu(__cpuhp_refcount, cpu);
>  

This can result in spurious wakeups if CPU N calls get_online_cpus after
its refcnt has been checked but I could not think of a case where it
matters.

> +	if (!refcnt)
> +		wake_up_process(__cpuhp_writer);
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
> +	__cpuhp_writer = current;
>  
>  	for (;;) {
> -		mutex_lock(&cpu_hotplug.lock);
> -		if (likely(!cpu_hotplug.refcount))
> +		unsigned int refcnt = 0;
> +		int cpu;
> +
> +		/*
> +		 * Order the setting of writer against the reading of refcount;
> +		 * pairs with the full barrier in get_online_cpus().
> +		 */
> +
> +		set_current_state(TASK_UNINTERRUPTIBLE);
> +
> +		for_each_possible_cpu(cpu)
> +			refcnt += per_cpu(__cpuhp_refcount, cpu);
> +

CPU 0					CPU 1
get_online_cpus
refcnt++
					__cpuhp_writer = current
					refcnt > 0
					schedule
__get_online_cpus slowpath
refcnt--
wait_event(!__cpuhp_writer)

What wakes up __cpuhp_writer to recheck the refcnts and see that they're
all 0?

> +		if (!refcnt)
>  			break;
> -		__set_current_state(TASK_UNINTERRUPTIBLE);
> -		mutex_unlock(&cpu_hotplug.lock);
> +
>  		schedule();
>  	}
> +	__set_current_state(TASK_RUNNING);
>  }
>  
>  void cpu_hotplug_done(void)
>  {
> -	cpu_hotplug.active_writer = NULL;
> -	mutex_unlock(&cpu_hotplug.lock);
> +	__cpuhp_writer = NULL;
> +	wake_up_all(&cpuhp_wq);
>  }
>  
>  /*

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
