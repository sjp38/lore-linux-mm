Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A82196B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 10:33:00 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so8558305pdj.1
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 07:33:00 -0700 (PDT)
Date: Thu, 19 Sep 2013 16:32:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130919143241.GB26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130918154939.GZ26785@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>




Meh, I should stop poking at this..

This one lost all the comments again :/

It uses preempt_disable/preempt_enable vs synchronize_sched() to remove
the barriers from the fast path.

After that it waits for !refcount before setting state, which stops new
readers.

I used a per-cpu spinlock to keep the state check and refcount inc
atomic vs the setting of state.

So the slow path is still per-cpu and mostly uncontended even in the
pending writer case.

After setting state it again waits for !refcount -- someone could have
sneaked in between the last !refcount and setting state. But this time
we know refcount will stay 0.

The only thing I don't really like is the unconditional writer wake in
the read-unlock slowpath, but I couldn't come up with anything better.
Here at least we guarantee that there is a wakeup after the last dec --
although there might be far too many wakes.

---
Subject: hotplug: Optimize {get,put}_online_cpus()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Sep 17 16:17:11 CEST 2013

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/cpu.h |   32 ++++++++++-
 kernel/cpu.c        |  151 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 116 insertions(+), 67 deletions(-)

--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -16,6 +16,7 @@
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
+#include <linux/percpu.h>
 
 struct device;
 
@@ -175,8 +176,35 @@ extern struct bus_type cpu_subsys;
 
 extern void cpu_hotplug_begin(void);
 extern void cpu_hotplug_done(void);
-extern void get_online_cpus(void);
-extern void put_online_cpus(void);
+
+extern struct task_struct *__cpuhp_writer;
+DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
+
+extern void __get_online_cpus(void);
+
+static inline void get_online_cpus(void)
+{
+	might_sleep();
+
+	preempt_disable();
+	if (likely(!__cpuhp_writer || __cpuhp_writer == current))
+		this_cpu_inc(__cpuhp_refcount);
+	else
+		__get_online_cpus();
+	preempt_enable();
+}
+
+extern void __put_online_cpus(void);
+
+static inline void put_online_cpus(void)
+{
+	preempt_disable();
+	this_cpu_dec(__cpuhp_refcount);
+	if (unlikely(__cpuhp_writer && __cpuhp_writer != current))
+		__put_online_cpus();
+	preempt_enable();
+}
+
 extern void cpu_hotplug_disable(void);
 extern void cpu_hotplug_enable(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -49,88 +49,109 @@ static int cpu_hotplug_disabled;
 
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
-
-void get_online_cpus(void)
-{
-	might_sleep();
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
-	cpu_hotplug.refcount++;
-	mutex_unlock(&cpu_hotplug.lock);
-
-}
-EXPORT_SYMBOL_GPL(get_online_cpus);
-
-void put_online_cpus(void)
-{
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
-
-	if (WARN_ON(!cpu_hotplug.refcount))
-		cpu_hotplug.refcount++; /* try to fix things up */
-
-	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
-		wake_up_process(cpu_hotplug.active_writer);
-	mutex_unlock(&cpu_hotplug.lock);
+struct task_struct *__cpuhp_writer = NULL;
+EXPORT_SYMBOL_GPL(__cpuhp_writer);
 
+DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
+EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
+
+static DEFINE_PER_CPU(int, cpuhp_state);
+static DEFINE_PER_CPU(spinlock_t, cpuhp_lock);
+static DECLARE_WAIT_QUEUE_HEAD(cpuhp_wq);
+
+void __get_online_cpus(void)
+{
+	spin_lock(__this_cpu_ptr(&cpuhp_lock));
+	for (;;) {
+		if (!__this_cpu_read(cpuhp_state)) {
+			__this_cpu_inc(__cpuhp_refcount);
+			break;
+		}
+
+		spin_unlock(__this_cpu_ptr(&cpuhp_lock));
+		preempt_enable();
+
+		wait_event(cpuhp_wq, !__cpuhp_writer);
+
+		preempt_disable();
+		spin_lock(__this_cpu_ptr(&cpuhp_lock));
+	}
+	spin_unlock(__this_cpu_ptr(&cpuhp_lock));
+}
+EXPORT_SYMBOL_GPL(__get_online_cpus);
+
+void __put_online_cpus(void)
+{
+	wake_up_process(__cpuhp_writer);
+}
+EXPORT_SYMBOL_GPL(__put_online_cpus);
+
+static void cpuph_wait_refcount(void)
+{
+	for (;;) {
+		unsigned int refcnt = 0;
+		int cpu;
+
+		set_current_state(TASK_UNINTERRUPTIBLE);
+
+		for_each_possible_cpu(cpu)
+			refcnt += per_cpu(__cpuhp_refcount, cpu);
+
+		if (!refcnt)
+			break;
+
+		schedule();
+	}
+	__set_current_state(TASK_RUNNING);
+}
+
+static void cpuhp_set_state(int state)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		spinlock_t *lock = &per_cpu(cpuhp_lock, cpu);
+
+		spin_lock(lock);
+		per_cpu(cpuhp_state, cpu) = state;
+		spin_unlock(lock);
+	}
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
+	lockdep_assert_held(&cpu_add_remove_lock);
 
-	for (;;) {
-		mutex_lock(&cpu_hotplug.lock);
-		if (likely(!cpu_hotplug.refcount))
-			break;
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&cpu_hotplug.lock);
-		schedule();
-	}
+	__cpuhp_writer = current;
+
+	/* After this everybody will observe _writer and take the slow path. */
+	synchronize_sched();
+
+	/* Wait for no readers -- reader preference */
+	cpuhp_wait_refcount();
+
+	/* Stop new readers. */
+	cpuhp_set_state(1);
+
+	/* Wait for no readers */
+	cpuhp_wait_refcount();
 }
 
 void cpu_hotplug_done(void)
 {
-	cpu_hotplug.active_writer = NULL;
-	mutex_unlock(&cpu_hotplug.lock);
+	__cpuhp_writer = NULL;
+
+	/* Allow new readers */
+	cpuhp_set_state(0);
+
+	wake_up_all(&cpuhp_wq);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
