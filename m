Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6A06B0034
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 11:50:03 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so8389232pad.5
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 08:50:02 -0700 (PDT)
Date: Wed, 18 Sep 2013 17:49:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130918154939.GZ26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130917164505.GG12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

New version, now with excessive comments.

I found a deadlock (where both reader and writer would go to sleep);
identified below as case 1b.

The implementation without patch is reader biased, this implementation,
as Mel pointed out, is writer biased. I should try and fix this but I'm
stepping away from the computer now as I have the feeling I'll only
wreck stuff from now on.

---
Subject: hotplug: Optimize {get,put}_online_cpus()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Sep 17 16:17:11 CEST 2013

The current implementation uses global state, change it so the reader
side uses per-cpu state in the contended fast path.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/cpu.h |   29 ++++++++-
 kernel/cpu.c        |  159 ++++++++++++++++++++++++++++++++++------------------
 2 files changed, 134 insertions(+), 54 deletions(-)

--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -16,6 +16,7 @@
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
+#include <linux/percpu.h>
 
 struct device;
 
@@ -175,8 +176,32 @@ extern struct bus_type cpu_subsys;
 
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
+	this_cpu_inc(__cpuhp_refcount);
+	smp_mb(); /* see comment near __get_online_cpus() */
+	if (unlikely(__cpuhp_writer))
+		__get_online_cpus();
+}
+
+extern void __put_online_cpus(void);
+
+static inline void put_online_cpus(void)
+{
+	this_cpu_dec(__cpuhp_refcount);
+	smp_mb(); /* see comment near __get_online_cpus() */
+	if (unlikely(__cpuhp_writer))
+		__put_online_cpus();
+}
+
 extern void cpu_hotplug_disable(void);
 extern void cpu_hotplug_enable(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -49,88 +49,143 @@ static int cpu_hotplug_disabled;
 
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
+struct task_struct *__cpuhp_writer = NULL;
+EXPORT_SYMBOL_GPL(__cpuhp_writer);
+
+DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
+EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
+
+static DECLARE_WAIT_QUEUE_HEAD(cpuhp_wq);
+
+/*
+ * We must order things like:
+ *
+ *  CPU0 -- read-lock		CPU1 -- write-lock
+ *
+ *  STORE __cpuhp_refcount	STORE __cpuhp_writer
+ *  MB				MB
+ *  LOAD __cpuhp_writer		LOAD __cpuhp_refcount
+ *
+ *
+ * This gives rise to the following permutations:
+ *
+ * a) all of R happend before W
+ * b) R starts but sees the W store -- therefore W must see the R store
+ *    W starts but sees the R store -- therefore R must see the W store
+ * c) all of W happens before R
+ *
+ * 1) RL vs WL:
+ *
+ * 1a) RL proceeds; WL observes refcount and goes wait for !refcount.
+ * 1b) RL drops into the slow path; WL waits for !refcount.
+ * 1c) WL proceeds; RL drops into the slow path.
+ *
+ * 2) RL vs WU:
+ *
+ * 2a) RL drops into the slow path; WU clears writer and wakes RL
+ * 2b) RL proceeds; WU continues to wake others
+ * 2d) RL proceeds.
+ *
+ * 3) RU vs WL:
+ *
+ * 3a) RU proceeds; WL proceeds.
+ * 3b) RU drops to slow path; WL proceeds
+ * 3c) WL waits for !refcount; RL drops to slow path
+ *
+ * 4) RU vs WU:
+ *
+ * Impossible since R and W state are mutually exclusive.
+ *
+ * This leaves us to consider the R slow paths:
+ *
+ * RL
+ *
+ * 1b) we must wake W
+ * 2a) nothing of importance
+ *
+ * RU
+ *
+ * 3b) nothing of importance
+ * 3c) we must wake W
+ *
+ */
 
-void get_online_cpus(void)
+void __get_online_cpus(void)
 {
-	might_sleep();
-	if (cpu_hotplug.active_writer == current)
+	if (__cpuhp_writer == current)
 		return;
-	mutex_lock(&cpu_hotplug.lock);
-	cpu_hotplug.refcount++;
-	mutex_unlock(&cpu_hotplug.lock);
 
+again:
+	/*
+	 * Case 1b; we must decrement our refcount again otherwise WL will
+	 * never observe !refcount and stay blocked forever. Not good since
+	 * we're going to sleep too. Someone must be awake and do something.
+	 *
+	 * Skip recomputing the refcount, just wake the pending writer and
+	 * have him check it -- writers are rare.
+	 */
+	this_cpu_dec(__cpuhp_refcount);
+	wake_up_process(__cpuhp_writer); /* implies MB */
+
+	wait_event(cpuhp_wq, !__cpuhp_writer);
+
+	/* Basically re-do the fast-path. Excep we can never be the writer. */
+	this_cpu_inc(__cpuhp_refcount);
+	smp_mb();
+	if (unlikely(__cpuhp_writer))
+		goto again;
 }
-EXPORT_SYMBOL_GPL(get_online_cpus);
+EXPORT_SYMBOL_GPL(__get_online_cpus);
 
-void put_online_cpus(void)
+void __put_online_cpus(void)
 {
-	if (cpu_hotplug.active_writer == current)
-		return;
-	mutex_lock(&cpu_hotplug.lock);
+	unsigned int refcnt = 0;
+	int cpu;
 
-	if (WARN_ON(!cpu_hotplug.refcount))
-		cpu_hotplug.refcount++; /* try to fix things up */
+	if (__cpuhp_writer == current)
+		return;
 
-	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
-		wake_up_process(cpu_hotplug.active_writer);
-	mutex_unlock(&cpu_hotplug.lock);
+	/* 3c */
+	for_each_possible_cpu(cpu)
+		refcnt += per_cpu(__cpuhp_refcount, cpu);
 
+	if (!refcnt)
+		wake_up_process(__cpuhp_writer);
 }
-EXPORT_SYMBOL_GPL(put_online_cpus);
+EXPORT_SYMBOL_GPL(__put_online_cpus);
 
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
+	__cpuhp_writer = current;
 
 	for (;;) {
-		mutex_lock(&cpu_hotplug.lock);
-		if (likely(!cpu_hotplug.refcount))
+		unsigned int refcnt = 0;
+		int cpu;
+
+		set_current_state(TASK_UNINTERRUPTIBLE); /* implies MB */
+
+		for_each_possible_cpu(cpu)
+			refcnt += per_cpu(__cpuhp_refcount, cpu);
+
+		if (!refcnt)
 			break;
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&cpu_hotplug.lock);
+
 		schedule();
 	}
+	__set_current_state(TASK_RUNNING);
 }
 
 void cpu_hotplug_done(void)
 {
-	cpu_hotplug.active_writer = NULL;
-	mutex_unlock(&cpu_hotplug.lock);
+	__cpuhp_writer = NULL;
+	wake_up_all(&cpuhp_wq); /* implies MB */
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
