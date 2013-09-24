Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id AA2E26B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:24:45 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so5081649pbc.1
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 13:24:45 -0700 (PDT)
Date: Tue, 24 Sep 2013 22:24:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924202423.GW12926@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923173203.GA20392@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Mon, Sep 23, 2013 at 07:32:03PM +0200, Oleg Nesterov wrote:
> > static void cpuhp_wait_refcount(void)
> > {
> > 	for (;;) {
> > 		unsigned int rc1, rc2;
> >
> > 		rc1 = cpuhp_refcount();
> > 		set_current_state(TASK_UNINTERRUPTIBLE); /* MB */
> > 		rc2 = cpuhp_refcount();
> >
> > 		if (rc1 == rc2 && !rc1)
> 
> But this only makes the race above "theoretical ** 2". Both
> cpuhp_refcount()'s can be equally fooled.
> 
> Looks like, cpuhp_refcount() should take all per-cpu cpuhp_lock's
> before it reads __cpuhp_refcount.

Ah, so SRCU has a solution for this using a sequence count.

So now we drop from a no memory barriers fast path, into a memory
barrier 'slow' path into blocking.

Only once we block do we hit global state..

--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -16,6 +16,7 @@
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
+#include <linux/percpu.h>
 
 struct device;
 
@@ -173,10 +174,50 @@ extern struct bus_type cpu_subsys;
 #ifdef CONFIG_HOTPLUG_CPU
 /* Stop CPUs going up and down. */
 
+extern void cpu_hotplug_init_task(struct task_struct *p);
+
 extern void cpu_hotplug_begin(void);
 extern void cpu_hotplug_done(void);
-extern void get_online_cpus(void);
-extern void put_online_cpus(void);
+
+extern int __cpuhp_writer;
+DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
+
+extern void __get_online_cpus(void);
+
+static inline void get_online_cpus(void)
+{
+	might_sleep();
+
+	/* Support reader-in-reader recursion */
+	if (current->cpuhp_ref++) {
+		barrier();
+		return;
+	}
+
+	preempt_disable();
+	if (likely(!__cpuhp_writer))
+		__this_cpu_inc(__cpuhp_refcount);
+	else
+		__get_online_cpus();
+	preempt_enable();
+}
+
+extern void __put_online_cpus(void);
+
+static inline void put_online_cpus(void)
+{
+	barrier();
+	if (--current->cpuhp_ref)
+		return;
+
+	preempt_disable();
+	if (likely(!__cpuhp_writer))
+		__this_cpu_dec(__cpuhp_refcount);
+	else
+		__put_online_cpus();
+	preempt_enable();
+}
+
 extern void cpu_hotplug_disable(void);
 extern void cpu_hotplug_enable(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
@@ -200,6 +241,8 @@ static inline void cpu_hotplug_driver_un
 
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
@@ -49,88 +49,148 @@ static int cpu_hotplug_disabled;
 
 #ifdef CONFIG_HOTPLUG_CPU
 
-static struct {
-	struct task_struct *active_writer;
-	struct mutex lock; /* Synchronizes accesses to refcount, */
+int __cpuhp_writer;
+EXPORT_SYMBOL_GPL(__cpuhp_writer);
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
+	if (__cpuhp_writer == 1) {
+		/* See __srcu_read_lock() */
+		__this_cpu_inc(__cpuhp_refcount);
+		smp_mb();
+		__this_cpu_inc(cpuhp_seq);
+		return;
+	}
+
+	atomic_inc(&cpuhp_waitcount);
+
 	/*
-	 * Also blocks the new readers during
-	 * an ongoing cpu hotplug operation.
+	 * We either call schedule() in the wait, or we'll fall through
+	 * and reschedule on the preempt_enable() in get_online_cpus().
 	 */
-	int refcount;
-} cpu_hotplug = {
-	.active_writer = NULL,
-	.lock = __MUTEX_INITIALIZER(cpu_hotplug.lock),
-	.refcount = 0,
-};
+	preempt_enable_no_resched();
+	wait_event(cpuhp_readers, !__cpuhp_writer);
+	preempt_disable();
 
-void get_online_cpus(void)
+	/*
+	 * XXX list_empty_careful(&cpuhp_readers.task_list) ?
+	 */
+	if (atomic_dec_and_test(&cpuhp_waitcount))
+		wake_up_all(&cpuhp_writer);
+}
+EXPORT_SYMBOL_GPL(__get_online_cpus);
+
+void __put_online_cpus(void)
 {
-	might_sleep();
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
-	cpu_hotplug.refcount++;
-	mutex_unlock(&cpu_hotplug.lock);
+	/* See __srcu_read_unlock() */
+	smp_mb();
+	this_cpu_dec(__cpuhp_refcount);
 
+	/* Prod writer to recheck readers_active */
+	wake_up_all(&cpuhp_writer);
 }
-EXPORT_SYMBOL_GPL(get_online_cpus);
+EXPORT_SYMBOL_GPL(__put_online_cpus);
 
-void put_online_cpus(void)
+static unsigned int cpuhp_seq(void)
 {
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
+	unsigned int seq = 0;
+	int cpu;
 
-	if (WARN_ON(!cpu_hotplug.refcount))
-		cpu_hotplug.refcount++; /* try to fix things up */
+	for_each_possible_cpu(cpu)
+		seq += per_cpu(cpuhp_seq, cpu);
 
-	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
-		wake_up_process(cpu_hotplug.active_writer);
-	mutex_unlock(&cpu_hotplug.lock);
+	return seq;
+}
+
+static unsigned int cpuhp_refcount(void)
+{
+	unsigned int refcount = 0;
+	int cpu;
 
+	for_each_possible_cpu(cpu)
+		refcount += per_cpu(__cpuhp_refcount, cpu);
+
+	return refcount;
+}
+
+/*
+ * See srcu_readers_active_idx_check()
+ */
+static bool cpuhp_readers_active_check(void)
+{
+	unsigned int seq = cpuhp_seq();
+
+	smp_mb();
+
+	if (cpuhp_refcount() != 0)
+		return false;
+
+	smp_mb();
+
+	return cpuhp_seq() == seq;
 }
-EXPORT_SYMBOL_GPL(put_online_cpus);
 
 /*
  * This ensures that the hotplug operation can begin only when the
  * refcount goes to zero.
  *
- * Note that during a cpu-hotplug operation, the new readers, if any,
- * will be blocked by the cpu_hotplug.lock
- *
  * Since cpu_hotplug_begin() is always called after invoking
  * cpu_maps_update_begin(), we can be sure that only one writer is active.
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
  */
 void cpu_hotplug_begin(void)
 {
-	cpu_hotplug.active_writer = current;
+	unsigned int count = 0;
+	int cpu;
 
-	for (;;) {
-		mutex_lock(&cpu_hotplug.lock);
-		if (likely(!cpu_hotplug.refcount))
-			break;
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&cpu_hotplug.lock);
-		schedule();
-	}
+	lockdep_assert_held(&cpu_add_remove_lock);
+
+	/* allow reader-in-writer recursion */
+	current->cpuhp_ref++;
+
+	/* make readers take the slow path */
+	__cpuhp_writer = 1;
+
+	/* See percpu_down_write() */
+	synchronize_sched();
+
+	/* make readers block */
+	__cpuhp_writer = 2;
+
+	/* Wait for all readers to go away */
+	wait_event(cpuhp_writer, cpuhp_readers_active_check());
 }
 
 void cpu_hotplug_done(void)
 {
-	cpu_hotplug.active_writer = NULL;
-	mutex_unlock(&cpu_hotplug.lock);
+	/* Signal the writer is done, no fast path yet */
+	__cpuhp_writer = 1;
+	wake_up_all(&cpuhp_readers);
+
+	/* See percpu_up_write() */
+	synchronize_sched();
+
+	/* Let em rip */
+	__cpuhp_writer = 0
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
