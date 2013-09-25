Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B3B396B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 14:40:24 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so61365pdi.0
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:40:24 -0700 (PDT)
Date: Wed, 25 Sep 2013 20:40:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925184015.GC3657@laptop.programming.kicks-ass.net>
References: <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
 <20130924202423.GW12926@twins.programming.kicks-ass.net>
 <20130925155515.GA17447@redhat.com>
 <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925175055.GA25914@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Wed, Sep 25, 2013 at 07:50:55PM +0200, Oleg Nesterov wrote:
> No. Too tired too ;) damn LSB test failures...


ok; I cobbled this together.. I might think better of it tomorrow, but
for now I think I closed the hole before wait_event(readers_active())
you pointed out -- of course I might have created new holes :/

For easy reading the + only version.

---
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
+++ b/kernel/cpu.c
@@ -49,88 +49,140 @@ static int cpu_hotplug_disabled;
 
 #ifdef CONFIG_HOTPLUG_CPU
 
+enum { readers_fast = 0, readers_slow, readers_block };
+
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
 
+void __get_online_cpus(void)
 {
+again:
+	/* See __srcu_read_lock() */
+	__this_cpu_inc(__cpuhp_refcount);
+	smp_mb(); /* A matches B, E */
+	__this_cpu_inc(cpuhp_seq);
+
+	if (unlikely(__cpuhp_writer == readers_block)) {
+		__put_online_cpus();
+
+		atomic_inc(&cpuhp_waitcount);
+
+		/*
+		 * We either call schedule() in the wait, or we'll fall through
+		 * and reschedule on the preempt_enable() in get_online_cpus().
+		 */
+		preempt_enable_no_resched();
+		__wait_event(cpuhp_readers, __cpuhp_writer != readers_block);
+		preempt_disable();
 
+		if (atomic_dec_and_test(&cpuhp_waitcount))
+			wake_up_all(&cpuhp_writer);
+
+		goto again;
+	}
+}
+EXPORT_SYMBOL_GPL(__get_online_cpus);
+
+void __put_online_cpus(void)
+{
+	/* See __srcu_read_unlock() */
+	smp_mb(); /* C matches D */
+	this_cpu_dec(__cpuhp_refcount);
+
+	/* Prod writer to recheck readers_active */
+	wake_up_all(&cpuhp_writer);
 }
+EXPORT_SYMBOL_GPL(__put_online_cpus);
 
+#define per_cpu_sum(var)						\
+({ 									\
+ 	typeof(var) __sum = 0;						\
+ 	int cpu;							\
+ 	for_each_possible_cpu(cpu)					\
+ 		__sum += per_cpu(var, cpu);				\
+ 	__sum;								\
+)}
+
+/*
+ * See srcu_readers_active_idx_check()
+ */
+static bool cpuhp_readers_active_check(void)
 {
+	unsigned int seq = per_cpu_sum(cpuhp_seq);
+
+	smp_mb(); /* B matches A */
 
+	if (per_cpu_sum(__cpuhp_refcount) != 0)
+		return false;
 
+	smp_mb(); /* D matches C */
 
+	return per_cpu_sum(cpuhp_seq) == seq;
 }
 
 /*
  * This ensures that the hotplug operation can begin only when the
  * refcount goes to zero.
  *
  * Since cpu_hotplug_begin() is always called after invoking
  * cpu_maps_update_begin(), we can be sure that only one writer is active.
  */
 void cpu_hotplug_begin(void)
 {
+	unsigned int count = 0;
+	int cpu;
 
+	lockdep_assert_held(&cpu_add_remove_lock);
+
+	/* allow reader-in-writer recursion */
+	current->cpuhp_ref++;
+
+	/* make readers take the slow path */
+	__cpuhp_writer = readers_slow;
+
+	/* See percpu_down_write() */
+	synchronize_sched();
+
+	/* make readers block */
+	__cpuhp_writer = readers_block;
+
+	smp_mb(); /* E matches A */
+
+	/* Wait for all readers to go away */
+	wait_event(cpuhp_writer, cpuhp_readers_active_check());
 }
 
 void cpu_hotplug_done(void)
 {
+	/* Signal the writer is done, no fast path yet */
+	__cpuhp_writer = readers_slow;
+	wake_up_all(&cpuhp_readers);
+
+	/* See percpu_up_write() */
+	synchronize_sched();
+
+	/* Let 'em rip */
+	__cpuhp_writer = readers_fast;
+	current->cpuhp_ref--;
+
+	/*
+	 * Wait for any pending readers to be running. This ensures readers
+	 * after writer and avoids writers starving readers.
+	 */
+	wait_event(cpuhp_writer, !atomic_read(&cpuhp_waitcount));
 }
 
 /*
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
