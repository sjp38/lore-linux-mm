Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id C9E7A6B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:11:06 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so993991pbc.31
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:11:06 -0700 (PDT)
Date: Thu, 26 Sep 2013 13:10:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130926111042.GS3081@twins.programming.kicks-ass.net>
References: <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
 <20130924202423.GW12926@twins.programming.kicks-ass.net>
 <20130925155515.GA17447@redhat.com>
 <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925212200.GA7959@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Wed, Sep 25, 2013 at 02:22:00PM -0700, Paul E. McKenney wrote:
> A couple of nits and some commentary, but if there are races, they are
> quite subtle.  ;-)

*whee*..

I made one little change in the logic; I moved the waitcount increment
to before the __put_online_cpus() call, such that the writer will have
to wait for us to wake up before trying again -- not for us to actually
have acquired the read lock, for that we'd need to mess up
__get_online_cpus() a bit more.

Complete patch below.

---
Subject: hotplug: Optimize {get,put}_online_cpus()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Sep 17 16:17:11 CEST 2013

The current implementation of get_online_cpus() is global of nature
and thus not suited for any kind of common usage.

Re-implement the current recursive r/w cpu hotplug lock such that the
read side locks are as light as possible.

The current cpu hotplug lock is entirely reader biased; but since
readers are expensive there aren't a lot of them about and writer
starvation isn't a particular problem.

However by making the reader side more usable there is a fair chance
it will get used more and thus the starvation issue becomes a real
possibility.

Therefore this new implementation is fair, alternating readers and
writers; this however requires per-task state to allow the reader
recursion.

Many comments are contributed by Paul McKenney, and many previous
attempts were shown to be inadequate by both Paul and Oleg; many
thanks to them for persisting to poke holes in my attempts.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/cpu.h   |   58 +++++++++++++
 include/linux/sched.h |    3 
 kernel/cpu.c          |  209 +++++++++++++++++++++++++++++++++++---------------
 kernel/sched/core.c   |    2 
 4 files changed, 208 insertions(+), 64 deletions(-)

--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -16,6 +16,7 @@
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
+#include <linux/percpu.h>
 
 struct device;
 
@@ -173,10 +174,61 @@ extern struct bus_type cpu_subsys;
 #ifdef CONFIG_HOTPLUG_CPU
 /* Stop CPUs going up and down. */
 
+extern void cpu_hotplug_init_task(struct task_struct *p);
+
 extern void cpu_hotplug_begin(void);
 extern void cpu_hotplug_done(void);
-extern void get_online_cpus(void);
-extern void put_online_cpus(void);
+
+extern int __cpuhp_state;
+DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
+
+extern void __get_online_cpus(void);
+
+static inline void get_online_cpus(void)
+{
+	might_sleep();
+
+	/* Support reader recursion */
+	/* The value was >= 1 and remains so, reordering causes no harm. */
+	if (current->cpuhp_ref++)
+		return;
+
+	preempt_disable();
+	if (likely(!__cpuhp_state)) {
+		/* The barrier here is supplied by synchronize_sched(). */
+		__this_cpu_inc(__cpuhp_refcount);
+	} else {
+		__get_online_cpus(); /* Unconditional memory barrier. */
+	}
+	preempt_enable();
+	/*
+	 * The barrier() from preempt_enable() prevents the compiler from
+	 * bleeding the critical section out.
+	 */
+}
+
+extern void __put_online_cpus(void);
+
+static inline void put_online_cpus(void)
+{
+	/* The value was >= 1 and remains so, reordering causes no harm. */
+	if (--current->cpuhp_ref)
+		return;
+
+	/*
+	 * The barrier() in preempt_disable() prevents the compiler from
+	 * bleeding the critical section out.
+	 */
+	preempt_disable();
+	if (likely(!__cpuhp_state)) {
+		/* The barrier here is supplied by synchronize_sched().  */
+		__this_cpu_dec(__cpuhp_refcount);
+	} else {
+		__put_online_cpus(); /* Unconditional memory barrier. */
+	}
+	preempt_enable();
+}
+
 extern void cpu_hotplug_disable(void);
 extern void cpu_hotplug_enable(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
@@ -200,6 +252,8 @@ static inline void cpu_hotplug_driver_un
 
 #else		/* CONFIG_HOTPLUG_CPU */
 
+static inline void cpu_hotplug_init_task(struct task_struct *p) {}
+
 static inline void cpu_hotplug_begin(void) {}
 static inline void cpu_hotplug_done(void) {}
 #define get_online_cpus()	do { } while (0)
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1454,6 +1454,9 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+#ifdef CONFIG_HOTPLUG_CPU
+	int		cpuhp_ref;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -49,88 +49,173 @@ static int cpu_hotplug_disabled;
 
 #ifdef CONFIG_HOTPLUG_CPU
 
-static struct {
-	struct task_struct *active_writer;
-	struct mutex lock; /* Synchronizes accesses to refcount, */
-	/*
-	 * Also blocks the new readers during
-	 * an ongoing cpu hotplug operation.
-	 */
-	int refcount;
-} cpu_hotplug = {
-	.active_writer = NULL,
-	.lock = __MUTEX_INITIALIZER(cpu_hotplug.lock),
-	.refcount = 0,
-};
+enum { readers_fast = 0, readers_slow, readers_block };
+
+int __cpuhp_state;
+EXPORT_SYMBOL_GPL(__cpuhp_state);
+
+DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
+EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
+
+static DEFINE_PER_CPU(unsigned int, cpuhp_seq);
+static atomic_t cpuhp_waitcount;
+static DECLARE_WAIT_QUEUE_HEAD(cpuhp_readers);
+static DECLARE_WAIT_QUEUE_HEAD(cpuhp_writer);
+
+void cpu_hotplug_init_task(struct task_struct *p)
+{
+	p->cpuhp_ref = 0;
+}
+
+void __get_online_cpus(void)
+{
+again:
+	/* See __srcu_read_lock() */
+	__this_cpu_inc(__cpuhp_refcount);
+	smp_mb(); /* A matches B, E */
+	__this_cpu_inc(cpuhp_seq);
+
+	if (unlikely(__cpuhp_state == readers_block)) {
+		/*
+		 * Make sure an outgoing writer sees the waitcount to ensure
+		 * we make progress.
+		 */
+		atomic_inc(&cpuhp_waitcount);
+		__put_online_cpus();
+
+		/*
+		 * We either call schedule() in the wait, or we'll fall through
+		 * and reschedule on the preempt_enable() in get_online_cpus().
+		 */
+		preempt_enable_no_resched();
+		__wait_event(cpuhp_readers, __cpuhp_state != readers_block);
+		preempt_disable();
+
+		if (atomic_dec_and_test(&cpuhp_waitcount))
+			wake_up_all(&cpuhp_writer);
+
+		goto again;
+	}
+}
+EXPORT_SYMBOL_GPL(__get_online_cpus);
 
-void get_online_cpus(void)
+void __put_online_cpus(void)
 {
-	might_sleep();
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
-	cpu_hotplug.refcount++;
-	mutex_unlock(&cpu_hotplug.lock);
+	/* See __srcu_read_unlock() */
+	smp_mb(); /* C matches D */
+	/*
+	 * In other words, if they see our decrement (presumably to aggregate
+	 * zero, as that is the only time it matters) they will also see our
+	 * critical section.
+	 */
+	this_cpu_dec(__cpuhp_refcount);
 
+	/* Prod writer to recheck readers_active */
+	wake_up_all(&cpuhp_writer);
 }
-EXPORT_SYMBOL_GPL(get_online_cpus);
+EXPORT_SYMBOL_GPL(__put_online_cpus);
+
+#define per_cpu_sum(var)						\
+({ 									\
+ 	typeof(var) __sum = 0;						\
+ 	int cpu;							\
+ 	for_each_possible_cpu(cpu)					\
+ 		__sum += per_cpu(var, cpu);				\
+ 	__sum;								\
+)}
 
-void put_online_cpus(void)
+/*
+ * See srcu_readers_active_idx_check() for a rather more detailed explanation.
+ */
+static bool cpuhp_readers_active_check(void)
 {
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
+	unsigned int seq = per_cpu_sum(cpuhp_seq);
+
+	smp_mb(); /* B matches A */
+
+	/*
+	 * In other words, if we see __get_online_cpus() cpuhp_seq increment,
+	 * we are guaranteed to also see its __cpuhp_refcount increment.
+	 */
 
-	if (WARN_ON(!cpu_hotplug.refcount))
-		cpu_hotplug.refcount++; /* try to fix things up */
+	if (per_cpu_sum(__cpuhp_refcount) != 0)
+		return false;
 
-	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
-		wake_up_process(cpu_hotplug.active_writer);
-	mutex_unlock(&cpu_hotplug.lock);
+	smp_mb(); /* D matches C */
 
+	/*
+	 * On equality, we know that there could not be any "sneak path" pairs
+	 * where we see a decrement but not the corresponding increment for a
+	 * given reader. If we saw its decrement, the memory barriers guarantee
+	 * that we now see its cpuhp_seq increment.
+	 */
+
+	return per_cpu_sum(cpuhp_seq) == seq;
 }
-EXPORT_SYMBOL_GPL(put_online_cpus);
 
 /*
- * This ensures that the hotplug operation can begin only when the
- * refcount goes to zero.
- *
- * Note that during a cpu-hotplug operation, the new readers, if any,
- * will be blocked by the cpu_hotplug.lock
- *
- * Since cpu_hotplug_begin() is always called after invoking
- * cpu_maps_update_begin(), we can be sure that only one writer is active.
- *
- * Note that theoretically, there is a possibility of a livelock:
- * - Refcount goes to zero, last reader wakes up the sleeping
- *   writer.
- * - Last reader unlocks the cpu_hotplug.lock.
- * - A new reader arrives at this moment, bumps up the refcount.
- * - The writer acquires the cpu_hotplug.lock finds the refcount
- *   non zero and goes to sleep again.
- *
- * However, this is very difficult to achieve in practice since
- * get_online_cpus() not an api which is called all that often.
- *
+ * This will notify new readers to block and wait for all active readers to
+ * complete.
  */
 void cpu_hotplug_begin(void)
 {
-	cpu_hotplug.active_writer = current;
+	/*
+	 * Since cpu_hotplug_begin() is always called after invoking
+	 * cpu_maps_update_begin(), we can be sure that only one writer is
+	 * active.
+	 */
+	lockdep_assert_held(&cpu_add_remove_lock);
 
-	for (;;) {
-		mutex_lock(&cpu_hotplug.lock);
-		if (likely(!cpu_hotplug.refcount))
-			break;
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&cpu_hotplug.lock);
-		schedule();
-	}
+	/* Allow reader-in-writer recursion. */
+	current->cpuhp_ref++;
+
+	/* Notify readers to take the slow path. */
+	__cpuhp_state = readers_slow;
+
+	/* See percpu_down_write(); guarantees all readers take the slow path */
+	synchronize_sched();
+
+	/*
+	 * Notify new readers to block; up until now, and thus throughout the
+	 * longish synchronize_sched() above, new readers could still come in.
+	 */
+	__cpuhp_state = readers_block;
+
+	smp_mb(); /* E matches A */
+
+	/*
+	 * If they don't see our writer of readers_block to __cpuhp_state,
+	 * then we are guaranteed to see their __cpuhp_refcount increment, and
+	 * therefore will wait for them.
+	 */
+
+	/* Wait for all now active readers to complete. */
+	wait_event(cpuhp_writer, cpuhp_readers_active_check());
 }
 
 void cpu_hotplug_done(void)
 {
-	cpu_hotplug.active_writer = NULL;
-	mutex_unlock(&cpu_hotplug.lock);
+	/* Signal the writer is done, no fast path yet. */
+	__cpuhp_state = readers_slow;
+	wake_up_all(&cpuhp_readers);
+
+	/*
+	 * The wait_event()/wake_up_all() prevents the race where the readers
+	 * are delayed between fetching __cpuhp_state and blocking.
+	 */
+
+	/* See percpu_up_write(); readers will no longer attempt to block. */
+	synchronize_sched();
+
+	/* Let 'em rip */
+	__cpuhp_state = readers_fast;
+	current->cpuhp_ref--;
+
+	/*
+	 * Wait for any pending readers to be running. This ensures readers
+	 * after writer and avoids writers starving readers.
+	 */
+	wait_event(cpuhp_writer, !atomic_read(&cpuhp_waitcount));
 }
 
 /*
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1736,6 +1736,8 @@ static void __sched_fork(unsigned long c
 	INIT_LIST_HEAD(&p->numa_entry);
 	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
+
+	cpu_hotplug_init_task(p);
 }
 
 #ifdef CONFIG_NUMA_BALANCING

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
