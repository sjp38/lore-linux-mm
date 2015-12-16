Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5F24D6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:11:55 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id iw8so34394817obc.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:11:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fk10si7049607obb.101.2015.12.16.07.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Dec 2015 07:11:52 -0800 (PST)
Subject: Re: [PATCH v4] mm,oom: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp>
	<20151212170032.GB7107@cmpxchg.org>
	<201512132326.AHJ86403.OFFVJOLQHSMFtO@I-love.SAKURA.ne.jp>
In-Reply-To: <201512132326.AHJ86403.OFFVJOLQHSMFtO@I-love.SAKURA.ne.jp>
Message-Id: <201512170011.IAC73451.FLtFMSJHOQFVOO@I-love.SAKURA.ne.jp>
Date: Thu, 17 Dec 2015 00:11:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

Here is a different version.
Is this version better than creating a dedicated kernel thread?
----------
 From c9f61902977b04d24d809d2b853a5682fc3c41e8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 17 Dec 2015 00:02:37 +0900
Subject: [PATCH draft] mm,oom: Add memory allocation watchdog kernel thread.

The oom_reaper kernel thread currently proposed by Michal Hocko tries to
reclaim additional memory by preemptively reaping the anonymous or swapped
out memory owned by the OOM victim under an assumption that such a memory
won't be needed when its owner is killed and kicked from the userspace
anyway, in a good hope that preemptively reaped memory is sufficient for
OOM victim to exit.

However, it has been shown by Tetsuo Handa that it is not that hard to
construct workloads which break this hope and the OOM victim takes
unbounded amount of time to exit because oom_reaper does not choose
subsequent OOM victims.

Since currently we are not going to implement timeout based subsequent
OOM victim selection, this patch implements a watchdog for emitting
warning messages when memory allocation is stalling, in case oom_reaper
did not help. The khungtaskd kernel thread is reused for this purpose,
which saves one kernel thread and avoids printk() collisions between
hang task checking and memory allocation stall checking.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h        |  25 +++++
 include/linux/sched/sysctl.h |   3 +
 kernel/fork.c                |   4 +
 kernel/hung_task.c           | 240 +++++++++++++++++++++++++++++++++++++++++--
 kernel/sysctl.c              |  10 ++
 lib/Kconfig.debug            |  24 +++++
 mm/page_alloc.c              |  33 ++++++
 7 files changed, 330 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7b76e39..f903368 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1379,6 +1379,28 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+struct memalloc_info {
+	/* For locking and progress monitoring. */
+	unsigned int sequence;
+	/*
+	 * 0: not doing __GFP_RECLAIM allocation.
+	 * 1: doing non-recursive __GFP_RECLAIM allocation.
+	 * 2: doing recursive __GFP_RECLAIM allocation.
+	 */
+	u8 valid;
+	/*
+	 * bit 0: Will be reported as OOM victim.
+	 * bit 1: Will be reported as dying task.
+	 * bit 2: Will be reported as stalling task.
+	 */
+	u8 type;
+	/* Started time in jiffies as of valid == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of valid == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1822,6 +1844,9 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index c9e4731..fb3004a 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -9,6 +9,9 @@ extern int sysctl_hung_task_warnings;
 extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
 					 void __user *buffer,
 					 size_t *lenp, loff_t *ppos);
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+extern unsigned long sysctl_memalloc_task_timeout_secs;
+#endif
 #else
 /* Avoid need for ifdefs elsewhere in the code */
 enum { sysctl_hung_task_timeout_secs = 0 };
diff --git a/kernel/fork.c b/kernel/fork.c
index 8cb287a..13a1b76 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1414,6 +1414,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	p->memalloc.sequence = 0;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index e0f90c2..8550cc8 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,7 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/console.h>
 #include <trace/events/sched.h>
 
 /*
@@ -72,6 +73,207 @@ static struct notifier_block panic_block = {
 	.notifier_call = hung_task_panic,
 };
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+/*
+ * Zero means infinite timeout - no checking done:
+ */
+unsigned long __read_mostly sysctl_memalloc_task_timeout_secs =
+	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
+static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
+
+static long memalloc_timeout_jiffies(unsigned long last_checked, long timeout)
+{
+	struct task_struct *g, *p;
+	long t;
+	unsigned long delta;
+
+	/* timeout of 0 will disable the watchdog */
+	if (!timeout)
+		return MAX_SCHEDULE_TIMEOUT;
+	/* At least wait for timeout duration. */
+	t = last_checked - jiffies + timeout * HZ;
+	if (t > 0)
+		return t;
+	/* Calculate how long to wait more. */
+	t = timeout * HZ;
+	delta = t - jiffies;
+
+	/*
+	 * We might see outdated values in "struct memalloc_info" here.
+	 * We will recheck later using is_stalling_task().
+	 */
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (likely(!p->memalloc.valid))
+			continue;
+		t = min_t(long, t, p->memalloc.start + delta);
+		if (unlikely(t <= 0))
+			goto stalling;
+	}
+ stalling:
+	rcu_read_unlock();
+	preempt_enable();
+	return t;
+}
+
+/**
+ * is_stalling_task - Check and copy a task's memalloc variable.
+ *
+ * @task:   A task to check.
+ * @expire: Timeout in jiffies.
+ *
+ * Returns true if a task is stalling, false otherwise.
+ */
+static bool is_stalling_task(const struct task_struct *task,
+			     const unsigned long expire)
+{
+	const struct memalloc_info *m = &task->memalloc;
+
+	/*
+	 * If start_memalloc_timer() is updating "struct memalloc_info" now,
+	 * we can ignore it because timeout jiffies cannot be expired as soon
+	 * as updating it completes.
+	 */
+	if (!m->valid || (m->sequence & 1))
+		return false;
+	smp_rmb(); /* Block start_memalloc_timer(). */
+	memalloc.start = m->start;
+	memalloc.order = m->order;
+	memalloc.gfp = m->gfp;
+	smp_rmb(); /* Unblock start_memalloc_timer(). */
+	memalloc.sequence = m->sequence;
+	/*
+	 * If start_memalloc_timer() started updating it while we read it,
+	 * we can ignore it for the same reason.
+	 */
+	if (!m->valid || (memalloc.sequence & 1))
+		return false;
+	/* This is a valid "struct memalloc_info". Check for timeout. */
+	return time_after_eq(expire, memalloc.start);
+}
+
+/* Check for memory allocation stalls. */
+static void check_memalloc_stalling_tasks(unsigned long timeout)
+{
+	char buf[128];
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long expire;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+
+	cond_resched();
+	now = jiffies;
+	/*
+	 * Report tasks that stalled for more than half of timeout duration
+	 * because such tasks might be correlated with tasks that already
+	 * stalled for full timeout duration.
+	 */
+	expire = now - timeout * (HZ / 2);
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			type |= 1;
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			type |= 2;
+			sigkill_pending++;
+		}
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			stalling_tasks++;
+		}
+		p->memalloc.type = type;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	if (!stalling_tasks)
+		return;
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	cond_resched();
+	preempt_disable();
+	rcu_read_lock();
+ restart_report:
+	for_each_process_thread(g, p) {
+		bool can_cont;
+		u8 type;
+
+		if (likely(!p->memalloc.type))
+			continue;
+		p->memalloc.type = 0;
+		/* Recheck in case state changed meanwhile. */
+		type = 0;
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			type |= 1;
+		if (fatal_signal_pending(p))
+			type |= 2;
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x order=%u delay=%lu",
+				 memalloc.sequence >> 1, memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		} else {
+			buf[0] = '\0';
+		}
+		if (unlikely(!type))
+			continue;
+		/*
+		 * Victim tasks get pending SIGKILL removed before arriving at
+		 * do_exit(). Therefore, print " exiting" instead for " dying".
+		 */
+		pr_warn("MemAlloc: %s(%u)%s%s%s%s%s\n", p->comm, p->pid, buf,
+			(p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "",
+			(p->flags & PF_EXITING) ? " exiting" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		/*
+		 * Since there could be thousands of tasks to report, we always
+		 * sleep and try to flush printk() buffer after each report, in
+		 * order to avoid RCU stalls and reduce possibility of messages
+		 * being dropped by continuous printk() flood.
+		 *
+		 * Since not yet reported tasks have p->memalloc.type > 0, we
+		 * can simply restart this loop in case "g" or "p" went away.
+		 */
+		get_task_struct(g);
+		get_task_struct(p);
+		rcu_read_unlock();
+		preempt_enable();
+		schedule_timeout_interruptible(1);
+		console_lock();
+		console_unlock();
+		preempt_disable();
+		rcu_read_lock();
+		can_cont = pid_alive(g) && pid_alive(p);
+		put_task_struct(p);
+		put_task_struct(g);
+		if (!can_cont)
+			goto restart_report;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	/* Show memory information. (SysRq-m) */
+	show_mem(0);
+}
+#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
+
 static void check_hung_task(struct task_struct *t, unsigned long timeout)
 {
 	unsigned long switch_count = t->nvcsw + t->nivcsw;
@@ -185,10 +387,12 @@ static void check_hung_uninterruptible_tasks(unsigned long timeout)
 	rcu_read_unlock();
 }
 
-static unsigned long timeout_jiffies(unsigned long timeout)
+static unsigned long hung_timeout_jiffies(long last_checked, long timeout)
 {
 	/* timeout of 0 will disable the watchdog */
-	return timeout ? timeout * HZ : MAX_SCHEDULE_TIMEOUT;
+	if (!timeout)
+		return MAX_SCHEDULE_TIMEOUT;
+	return last_checked - jiffies + timeout * HZ;
 }
 
 /*
@@ -224,18 +428,36 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detector);
  */
 static int watchdog(void *dummy)
 {
+	unsigned long hung_last_checked = jiffies;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	unsigned long stall_last_checked = hung_last_checked;
+#endif
+
 	set_user_nice(current, 0);
 
 	for ( ; ; ) {
 		unsigned long timeout = sysctl_hung_task_timeout_secs;
-
-		while (schedule_timeout_interruptible(timeout_jiffies(timeout)))
-			timeout = sysctl_hung_task_timeout_secs;
-
-		if (atomic_xchg(&reset_hung_task, 0))
+		long t = hung_timeout_jiffies(hung_last_checked, timeout);
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+		unsigned long timeout2 = sysctl_memalloc_task_timeout_secs;
+		long t2 = memalloc_timeout_jiffies(stall_last_checked,
+						   timeout2);
+
+		if (t2 <= 0) {
+			check_memalloc_stalling_tasks(timeout2);
+			stall_last_checked = jiffies;
 			continue;
-
-		check_hung_uninterruptible_tasks(timeout);
+		}
+#else
+		long t2 = t;
+#endif
+		if (t <= 0) {
+			if (!atomic_xchg(&reset_hung_task, 0))
+				check_hung_uninterruptible_tasks(timeout);
+			hung_last_checked = jiffies;
+			continue;
+		}
+		schedule_timeout_interruptible(min(t, t2));
 	}
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0d6edb5..aac2a20 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1061,6 +1061,16 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &neg_one,
 	},
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	{
+		.procname	= "memalloc_task_timeout_secs",
+		.data		= &sysctl_memalloc_task_timeout_secs,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= proc_dohung_task_timeout_secs,
+		.extra2		= &hung_task_timeout_max,
+	},
+#endif
 #endif
 #ifdef CONFIG_COMPAT
 	{
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index efa0f5f..3be59f9 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -820,6 +820,30 @@ config BOOTPARAM_HUNG_TASK_PANIC_VALUE
 	default 0 if !BOOTPARAM_HUNG_TASK_PANIC
 	default 1 if BOOTPARAM_HUNG_TASK_PANIC
 
+config DETECT_MEMALLOC_STALL_TASK
+	bool "Detect tasks stalling inside memory allocator"
+	default n
+	depends on DETECT_HUNG_TASK
+	help
+	  This option emits warning messages and traces when memory
+	  allocation requests are stalling, in order to catch unexplained
+	  hangups/reboots caused by memory allocation stalls.
+
+config DEFAULT_MEMALLOC_TASK_TIMEOUT
+	int "Default timeout for stalling task detection (in seconds)"
+	depends on DETECT_MEMALLOC_STALL_TASK
+	default 10
+	help
+	  This option controls the default timeout (in seconds) used
+	  to determine when a task has become non-responsive and should
+	  be considered stalling inside memory allocator.
+
+	  It can be adjusted at runtime via the kernel.memalloc_task_timeout_secs
+	  sysctl or by writing a value to
+	  /proc/sys/kernel/memalloc_task_timeout_secs.
+
+	  A timeout of 0 disables the check. The default is 10 seconds.
+
 config WQ_WATCHDOG
 	bool "Detect Workqueue Stalls"
 	depends on DEBUG_KERNEL
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bac8842d..a0cf4b3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3199,6 +3199,37 @@ got_pg:
 	return page;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_RECLAIM))
+		return;
+	/* We don't check for stalls for nested __GFP_RECLAIM allocations */
+	if (!m->valid) {
+		m->sequence++;
+		smp_wmb(); /* Block is_stalling_task(). */
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+		smp_wmb(); /* Unblock is_stalling_task(). */
+		m->sequence++;
+	}
+	m->valid++;
+}
+
+static void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_RECLAIM)
+		current->memalloc.valid--;
+}
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3266,7 +3297,9 @@ retry_cpuset:
 		alloc_mask = memalloc_noio_flags(gfp_mask);
 		ac.spread_dirty_pages = false;
 
+		start_memalloc_timer(alloc_mask, order);
 		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+		stop_memalloc_timer(alloc_mask);
 	}
 
 	if (kmemcheck_enabled && page)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
