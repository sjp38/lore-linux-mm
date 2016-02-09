Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 469386B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 09:50:02 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id xk3so187125631obc.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 06:50:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rx6si16546983oec.3.2016.02.09.06.49.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 06:49:59 -0800 (PST)
Subject: How to handle infinite too_many_isolated() loop (for OOM detection rework v4) ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp>
Date: Tue, 9 Feb 2016 23:49:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

I did an OOM torture test using a reproducer shown below. This version
is intended for consuming the last free pages (before the OOM killer is
invoked) for buffered writes so that __GFP_FS allocations will be blocked
on waiting for !__GFP_FS to flush the written data to disk.

---------- reproducer program ----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <poll.h>

static char use_delay = 0;

static void sigcld_handler(int unused)
{
	use_delay = 1;
}

int main(int argc, char *argv[])
{
	static char buffer[4096] = { };
	char *buf = NULL;
	unsigned long size;
	int i;
	signal(SIGCLD, sigcld_handler);
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			sleep(1);
			if (!i)
				pause();
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer)) {
				poll(NULL, 0, 10);
				fsync(fd);
			}
			_exit(0);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(2);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096) {
		buf[i] = 0;
		if (use_delay) /* Give children a chance to write(). */
			poll(NULL, 0, 10);
	}
	pause();
	return 0;
}
---------- reproducer program ----------

I used kmallocwd patch shown below for dumping information of stalling
tasks. This version also shows how many times out_of_memory() is called
and number of PF_EXITING (but !TASK_DEAD) tasks for demonstrating that
out_of_memory() is not called.

---------- kmallocwd patch (for linux-next-20160209) ----------
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..3f03787 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -113,6 +113,8 @@ static inline bool task_will_free_mem(struct task_struct *task)
 		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
 }
 
+extern unsigned int out_of_memory_count;
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7138917..0aeff29 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1387,6 +1387,28 @@ struct tlbflush_unmap_batch {
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
@@ -1849,6 +1871,9 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct list_head oom_reaper_list;
 #endif
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
index b617af6..78283c6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1425,6 +1425,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index d234022..745a78c 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,7 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/oom.h> /* out_of_memory_count */
 #include <trace/events/sched.h>
 
 /*
@@ -72,6 +73,214 @@ static struct notifier_block panic_block = {
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
+	unsigned int exiting_tasks;
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
+	exiting_tasks = 0;
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
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			type |= 8;
+			exiting_tasks++;
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
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u exiting task, %u victim task. oom_count=%u\n",
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending, out_of_memory_count);
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
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD)
+			type |= 8;
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
+				 memalloc.sequence >> 1, memalloc.gfp, &memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		}
+		if (unlikely(!type))
+			continue;
+		/*
+		 * Victim tasks get pending SIGKILL removed before arriving at
+		 * do_exit(). Therefore, print " exiting" instead for " dying".
+		 */
+		pr_warn("MemAlloc: %s(%u)%s%s%s%s%s\n", p->comm, p->pid,
+			(type & 4) ? buf : "",
+			(p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "",
+			(type & 8) ? " exiting" : "",
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
+	/* Show workqueue state. */
+	show_workqueue_state();
+}
+#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
+
 static void check_hung_task(struct task_struct *t, unsigned long timeout)
 {
 	unsigned long switch_count = t->nvcsw + t->nivcsw;
@@ -227,20 +436,35 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detector);
 static int watchdog(void *dummy)
 {
 	unsigned long hung_last_checked = jiffies;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	unsigned long stall_last_checked = hung_last_checked;
+#endif
 
 	set_user_nice(current, 0);
 
 	for ( ; ; ) {
 		unsigned long timeout = sysctl_hung_task_timeout_secs;
 		long t = hung_timeout_jiffies(hung_last_checked, timeout);
-
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+		unsigned long timeout2 = sysctl_memalloc_task_timeout_secs;
+		long t2 = memalloc_timeout_jiffies(stall_last_checked,
+						   timeout2);
+
+		if (t2 <= 0) {
+			check_memalloc_stalling_tasks(timeout2);
+			stall_last_checked = jiffies;
+			continue;
+		}
+#else
+		long t2 = t;
+#endif
 		if (t <= 0) {
 			if (!atomic_xchg(&reset_hung_task, 0))
 				check_hung_uninterruptible_tasks(timeout);
 			hung_last_checked = jiffies;
 			continue;
 		}
-		schedule_timeout_interruptible(t);
+		schedule_timeout_interruptible(min(t, t2));
 	}
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d479707..9844091 100644
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
index d6449c4..cb27ef5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -852,6 +852,30 @@ config WQ_WATCHDOG
 	  state.  This can be configured through kernel parameter
 	  "workqueue.watchdog_thresh" and its sysfs counterpart.
 
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
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7653055..1bb1b60 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -44,6 +44,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+unsigned int out_of_memory_count;
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -849,6 +851,7 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	out_of_memory_count++;
 	if (oom_killer_disabled)
 		return false;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4ca4ead..e413cb8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3372,6 +3372,37 @@ got_pg:
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
@@ -3439,7 +3470,9 @@ retry_cpuset:
 		alloc_mask = memalloc_noio_flags(gfp_mask);
 		ac.spread_dirty_pages = false;
 
+		start_memalloc_timer(alloc_mask, order);
 		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+		stop_memalloc_timer(alloc_mask);
 	}
 
 	if (kmemcheck_enabled && page)
---------- kmallocwd patch (for linux-next-20160209) ----------

The result is that, we have no TIF_MEMDIE tasks but nobody is calling
out_of_memory(). That is, OOM livelock without invoking the OOM killer.
They seem to be waiting at congestion_wait() from too_many_isolated()
loop called from shrink_inactive_list() because nobody can make forward
progress. I think we must not wait forever at too_many_isolated() loop.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160209.txt.xz .
---------- console log ----------
[   77.972875] MemAlloc-Info: 336 stalling task, 3 dying task, 0 exiting task, 0 victim task. oom_count=6
[  109.433056] MemAlloc-Info: 343 stalling task, 4 dying task, 0 exiting task, 0 victim task. oom_count=7
[  188.076342] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
[  214.760724] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
[  235.977602] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
[  262.342177] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
[  288.735990] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
[  288.741745] MemAlloc: systemd(1) seq=2312 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110660 uninterruptible
[  288.813413] MemAlloc: vmtoolsd(2045) seq=3884 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110483 uninterruptible
[  288.865450] MemAlloc: tuned(3861) seq=3462 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110428 uninterruptible
[  288.916498] MemAlloc: abrt-dbus(3856) seq=849 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110428 uninterruptible
[  288.967496] MemAlloc: a.out(3931) seq=21391 gfp=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=110606 uninterruptible
[  289.010523] MemAlloc: a.out(4100) uninterruptible exiting
[  289.075164] MemAlloc: a.out(4105) uninterruptible exiting
[  289.139227] MemAlloc: a.out(4113) uninterruptible exiting
[  289.204417] MemAlloc: a.out(4114) uninterruptible exiting
[  289.267492] MemAlloc: a.out(4115) uninterruptible exiting
[  289.331283] MemAlloc: a.out(4118) uninterruptible dying
[  289.401583] MemAlloc: a.out(4126) uninterruptible exiting
[  289.463611] MemAlloc: a.out(4130) uninterruptible exiting
[  289.525134] MemAlloc: a.out(4131) uninterruptible dying
[  289.589972] MemAlloc: a.out(4132) uninterruptible dying
[  289.656122] MemAlloc: a.out(4134) uninterruptible dying
[  289.725382] MemAlloc: a.out(4138) uninterruptible exiting
[  289.768154] MemAlloc: a.out(4139) uninterruptible dying
[  289.837049] MemAlloc: a.out(4140) uninterruptible exiting
[  289.900465] MemAlloc: a.out(4142) uninterruptible exiting
[  289.965786] MemAlloc: a.out(4145) uninterruptible exiting
[  290.029514] MemAlloc: a.out(4146) uninterruptible exiting
[  290.092057] MemAlloc: a.out(4147) uninterruptible exiting
[  290.155917] MemAlloc: a.out(4151) uninterruptible exiting
[  290.220284] MemAlloc: a.out(4153) uninterruptible dying
[  290.285904] MemAlloc: a.out(4154) uninterruptible exiting
[  290.348206] MemAlloc: a.out(4155) uninterruptible dying
[  290.416041] MemAlloc: a.out(4160) uninterruptible dying
[  290.486060] MemAlloc: a.out(4162) uninterruptible exiting
[  290.547328] MemAlloc: a.out(4163) uninterruptible exiting
[  290.610510] MemAlloc: a.out(4164) uninterruptible exiting
[  290.673150] MemAlloc: a.out(4165) uninterruptible exiting
[  290.735334] MemAlloc: a.out(4167) uninterruptible exiting
[  290.798767] MemAlloc: a.out(4170) uninterruptible exiting
[  290.861345] MemAlloc: a.out(4171) uninterruptible dying
[  290.945156] MemAlloc: a.out(4172) uninterruptible exiting
[  291.016476] MemAlloc: a.out(4173) uninterruptible exiting
[  291.082861] MemAlloc: a.out(4175) uninterruptible dying
[  291.153041] MemAlloc: a.out(4176) uninterruptible exiting
[  291.218528] MemAlloc: a.out(4177) uninterruptible dying
[  291.286239] MemAlloc: a.out(4178) uninterruptible exiting
[  291.350194] MemAlloc: a.out(4181) uninterruptible exiting
[  291.412941] MemAlloc: a.out(4183) uninterruptible exiting
[  291.478004] MemAlloc: a.out(4185) uninterruptible exiting
[  291.540680] MemAlloc: a.out(4187) uninterruptible exiting
[  291.604121] MemAlloc: a.out(4188) uninterruptible exiting
[  291.666909] MemAlloc: a.out(4194) uninterruptible exiting
[  291.729987] MemAlloc: a.out(4197) uninterruptible exiting
[  291.774457] MemAlloc: a.out(4199) uninterruptible dying
[  291.843302] MemAlloc: a.out(4200) uninterruptible exiting
[  291.906002] MemAlloc: a.out(4202) uninterruptible exiting
[  291.979994] MemAlloc: a.out(4203) uninterruptible dying
[  292.058440] MemAlloc: a.out(4206) uninterruptible exiting
[  292.126031] MemAlloc: a.out(4209) uninterruptible dying
[  292.201428] MemAlloc: a.out(4212) uninterruptible dying
[  292.279546] MemAlloc: a.out(4215) uninterruptible dying
[  292.353191] MemAlloc: a.out(4219) uninterruptible exiting
[  292.423648] MemAlloc: a.out(4220) uninterruptible exiting
[  292.492172] MemAlloc: a.out(4224) uninterruptible dying
[  292.566053] MemAlloc: a.out(4225) uninterruptible dying
[  292.638368] MemAlloc: a.out(4226) uninterruptible exiting
[  292.686426] MemAlloc: a.out(4227) uninterruptible dying
[  292.758527] MemAlloc: a.out(4230) uninterruptible exiting
[  292.827481] MemAlloc: a.out(4231) uninterruptible exiting
[  292.895002] MemAlloc: a.out(4232) uninterruptible dying
[  292.964999] MemAlloc: a.out(4233) uninterruptible dying
[  293.031709] MemAlloc: a.out(4234) uninterruptible exiting
[  293.095453] MemAlloc: a.out(4235) uninterruptible exiting
[  293.161739] MemAlloc: a.out(4236) uninterruptible dying
[  293.228098] MemAlloc: a.out(4237) uninterruptible dying
[  293.294276] MemAlloc: a.out(4239) uninterruptible dying
[  293.362932] MemAlloc: a.out(4240) uninterruptible dying
[  293.431146] MemAlloc: a.out(4241) uninterruptible dying
[  293.497015] MemAlloc: a.out(4242) uninterruptible exiting
[  293.564474] MemAlloc: a.out(4243) uninterruptible dying
[  293.630170] MemAlloc: a.out(4244) uninterruptible dying
[  293.699318] MemAlloc: a.out(4245) uninterruptible exiting
[  293.746545] MemAlloc: a.out(4246) uninterruptible exiting
[  293.790346] MemAlloc: a.out(4247) uninterruptible dying
[  293.860205] MemAlloc: a.out(4248) uninterruptible dying
[  293.927236] MemAlloc: a.out(4252) seq=109 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110409 uninterruptible
[  293.987358] MemAlloc: a.out(4253) seq=279 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110406 uninterruptible
[  294.049077] MemAlloc: a.out(4262) seq=489 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  294.111124] MemAlloc: a.out(4270) seq=164 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110442 uninterruptible
[  294.172876] MemAlloc: a.out(4278) seq=163 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.235220] MemAlloc: a.out(4280) seq=79 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  294.304311] MemAlloc: a.out(4282) seq=377 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.373025] MemAlloc: a.out(4284) seq=219 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  294.437609] MemAlloc: a.out(4288) seq=163 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.499247] MemAlloc: a.out(4289) seq=128 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.561484] MemAlloc: a.out(4290) seq=239 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.624001] MemAlloc: a.out(4291) seq=260 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110411 uninterruptible
[  294.686560] MemAlloc: a.out(4293) seq=46 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.747170] MemAlloc: a.out(4295) seq=112 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.807957] MemAlloc: a.out(4301) seq=284 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110405 uninterruptible
[  294.870383] MemAlloc: a.out(4304) seq=313 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.932033] MemAlloc: a.out(4307) seq=229 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  294.995414] MemAlloc: a.out(4309) seq=423 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  295.057044] MemAlloc: a.out(4310) seq=203 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  295.118153] MemAlloc: a.out(4312) seq=380 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  295.180457] MemAlloc: a.out(4325) seq=625 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  295.242072] MemAlloc: a.out(4331) seq=424 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  295.305434] MemAlloc: a.out(4336) seq=239 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110425 uninterruptible
[  295.367021] MemAlloc: a.out(4337) seq=145 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110425 uninterruptible
[  295.429522] MemAlloc: a.out(4348) seq=460 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110407 uninterruptible
[  295.490002] MemAlloc: a.out(4350) seq=461 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  295.551469] MemAlloc: a.out(4353) seq=381 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  295.613194] MemAlloc: a.out(4356) seq=404 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110404 uninterruptible
[  295.674882] MemAlloc: a.out(4362) seq=299 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  295.736069] MemAlloc: a.out(4368) seq=249 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110413 uninterruptible
[  295.798640] MemAlloc: a.out(4374) seq=81 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  295.860131] MemAlloc: a.out(4377) seq=428 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  295.923754] MemAlloc: a.out(4382) seq=309 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  295.985296] MemAlloc: a.out(4387) seq=155 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  296.046956] MemAlloc: a.out(4394) seq=506 gfp=0x2400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=110533 uninterruptible
[  296.131126] MemAlloc: a.out(4401) seq=46 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  296.192056] MemAlloc: a.out(4408) seq=372 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  296.255125] MemAlloc: a.out(4409) seq=129 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110460 uninterruptible
[  296.316520] MemAlloc: a.out(4411) seq=200 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110446 uninterruptible
[  296.379106] MemAlloc: a.out(4417) seq=241 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  296.440885] MemAlloc: a.out(4418) seq=459 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110407 uninterruptible
[  296.502042] MemAlloc: a.out(4419) seq=229 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  296.564261] MemAlloc: a.out(4422) seq=524 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  296.624935] MemAlloc: a.out(4424) seq=109 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  296.686239] MemAlloc: a.out(4425) seq=257 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  296.747145] MemAlloc: a.out(4430) seq=292 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  296.810571] MemAlloc: a.out(4431) seq=428 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  296.871294] MemAlloc: a.out(4435) seq=75 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  296.931995] MemAlloc: a.out(4438) seq=122 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110408 uninterruptible
[  296.993223] MemAlloc: a.out(4443) seq=126 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.054425] MemAlloc: a.out(4445) seq=355 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.114872] MemAlloc: a.out(4446) seq=352 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.174954] MemAlloc: a.out(4454) seq=150 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110404 uninterruptible
[  297.235558] MemAlloc: a.out(4455) seq=248 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  297.295382] MemAlloc: a.out(4458) seq=180 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.357177] MemAlloc: a.out(4466) seq=523 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.417235] MemAlloc: a.out(4472) seq=481 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110483 uninterruptible
[  297.476913] MemAlloc: a.out(4480) seq=313 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  297.536924] MemAlloc: a.out(4487) seq=198 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  297.598015] MemAlloc: a.out(4490) seq=269 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  297.658632] MemAlloc: a.out(4494) seq=157 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110424 uninterruptible
[  297.719331] MemAlloc: a.out(4509) seq=105 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  297.780123] MemAlloc: a.out(4514) seq=357 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  297.841232] MemAlloc: a.out(4515) seq=306 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110409 uninterruptible
[  297.902488] MemAlloc: a.out(4518) seq=123 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  297.963070] MemAlloc: a.out(4520) seq=377 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  298.025259] MemAlloc: a.out(4521) seq=169 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  298.085972] MemAlloc: a.out(4524) seq=256 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  298.147449] MemAlloc: a.out(4527) seq=53 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110408 uninterruptible
[  298.210280] MemAlloc: a.out(4532) seq=383 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  298.271354] MemAlloc: a.out(4533) seq=259 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  298.333113] MemAlloc: a.out(4534) seq=368 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  298.394307] MemAlloc: a.out(4539) seq=88 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110410 uninterruptible
[  298.455551] MemAlloc: a.out(4548) seq=18 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  298.517113] MemAlloc: a.out(4558) seq=224 gfp=0x2400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=110533 uninterruptible
[  298.602193] MemAlloc: a.out(4561) seq=49 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110412 uninterruptible
[  298.661078] MemAlloc: a.out(4563) seq=181 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  298.721923] MemAlloc: a.out(4565) seq=269 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  298.781994] MemAlloc: a.out(4570) seq=253 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  298.844759] MemAlloc: a.out(4579) seq=27 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110446 uninterruptible
[  298.907038] MemAlloc: a.out(4581) seq=342 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110424 uninterruptible
[  298.967938] MemAlloc: a.out(4582) seq=276 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.028939] MemAlloc: a.out(4583) seq=243 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.089427] MemAlloc: a.out(4586) seq=253 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.151053] MemAlloc: a.out(4587) seq=199 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.213203] MemAlloc: a.out(4589) seq=106 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.274245] MemAlloc: a.out(4591) seq=88 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.337493] MemAlloc: a.out(4594) seq=84 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  299.399904] MemAlloc: a.out(4602) seq=23 gfp=0x2400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=110402 uninterruptible
[  299.485183] MemAlloc: a.out(4603) seq=516 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.546127] MemAlloc: a.out(4618) seq=353 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  299.607553] MemAlloc: a.out(4621) seq=451 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110446 uninterruptible
[  299.669571] MemAlloc: a.out(4622) seq=34 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.731123] MemAlloc: a.out(4624) seq=74 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.793604] MemAlloc: a.out(4627) seq=269 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  299.855179] MemAlloc: a.out(4628) seq=306 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.916566] MemAlloc: a.out(4634) seq=18 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  299.982394] MemAlloc: a.out(4636) seq=25 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  300.043318] MemAlloc: a.out(4639) seq=27 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110411 uninterruptible
[  300.104383] MemAlloc: a.out(4648) seq=323 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  300.165360] MemAlloc: a.out(4653) seq=51 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  300.226917] MemAlloc: a.out(4654) seq=167 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  300.289325] MemAlloc: a.out(4658) seq=297 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  300.351222] MemAlloc: a.out(4664) seq=400 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  300.412566] MemAlloc: a.out(4672) seq=250 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  300.475080] MemAlloc: a.out(4676) seq=422 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471
[  300.535975] MemAlloc: a.out(4680) seq=285 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110404 uninterruptible
[  300.596286] MemAlloc: a.out(4682) seq=25 gfp=0x2400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=110482 uninterruptible
[  300.681355] MemAlloc: a.out(4683) seq=271 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  300.741873] MemAlloc: a.out(4684) seq=25 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  300.803500] MemAlloc: a.out(4686) seq=57 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110403 uninterruptible
[  300.864948] MemAlloc: a.out(4690) seq=256 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  300.927897] MemAlloc: a.out(4694) seq=319 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110411 uninterruptible
[  300.989497] MemAlloc: a.out(4695) seq=32 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  301.054966] MemAlloc: a.out(4697) seq=34 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.121285] MemAlloc: a.out(4699) seq=219 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.183026] MemAlloc: a.out(4703) seq=89 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  301.244092] MemAlloc: a.out(4704) seq=273 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  301.306223] MemAlloc: a.out(4711) seq=144 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  301.369722] MemAlloc: a.out(4713) seq=186 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.433370] MemAlloc: a.out(4724) seq=269 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110483 uninterruptible
[  301.495114] MemAlloc: a.out(4727) seq=254 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  301.556989] MemAlloc: a.out(4728) seq=407 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  301.618006] MemAlloc: a.out(4729) seq=356 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.681279] MemAlloc: a.out(4731) seq=325 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  301.743394] MemAlloc: a.out(4738) seq=387 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  301.805417] MemAlloc: a.out(4742) seq=244 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.866973] MemAlloc: a.out(4744) seq=314 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.931133] MemAlloc: a.out(4750) seq=124 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  301.991970] MemAlloc: a.out(4759) seq=40 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  302.053070] MemAlloc: a.out(4760) seq=96 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  302.114027] MemAlloc: a.out(4761) seq=199 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  302.173189] MemAlloc: a.out(4768) seq=363 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110410 uninterruptible
[  302.233932] MemAlloc: a.out(4769) seq=289 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110427 uninterruptible
[  302.294374] MemAlloc: a.out(4776) seq=495 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  302.355515] MemAlloc: a.out(4778) seq=192 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110459 uninterruptible
[  302.417056] MemAlloc: a.out(4786) seq=185 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  302.478107] MemAlloc: a.out(4787) seq=136 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110410 uninterruptible
[  302.539285] MemAlloc: a.out(4799) seq=271 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  302.601258] MemAlloc: a.out(4805) seq=26 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  302.662153] MemAlloc: a.out(4807) seq=36 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  302.728439] MemAlloc: a.out(4817) seq=22 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  302.790321] MemAlloc: a.out(4818) seq=141 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  302.852027] MemAlloc: a.out(4827) seq=655 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  302.913128] MemAlloc: a.out(4835) seq=330 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  302.974405] MemAlloc: a.out(4838) seq=33 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.035197] MemAlloc: a.out(4840) seq=74 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.097271] MemAlloc: a.out(4841) seq=304 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.158136] MemAlloc: a.out(4844) seq=30 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.220542] MemAlloc: a.out(4846) seq=400 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.283803] MemAlloc: a.out(4848) seq=74 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.345946] MemAlloc: a.out(4850) seq=115 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.406958] MemAlloc: a.out(4860) seq=331 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.466880] MemAlloc: a.out(4861) seq=416 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.528111] MemAlloc: a.out(4874) seq=296 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.588938] MemAlloc: a.out(4879) seq=246 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.648924] MemAlloc: a.out(4880) seq=604 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.710376] MemAlloc: a.out(4886) seq=30 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.775284] MemAlloc: a.out(4887) seq=193 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.837530] MemAlloc: a.out(4889) seq=31 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  303.903037] MemAlloc: a.out(4897) seq=335 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  303.965102] MemAlloc: a.out(4898) seq=236 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.025980] MemAlloc: a.out(4907) seq=211 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110408 uninterruptible
[  304.088067] MemAlloc: a.out(4908) seq=410 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.150072] MemAlloc: a.out(4910) seq=141 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110406 uninterruptible
[  304.211472] MemAlloc: a.out(4917) seq=139 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  304.273634] MemAlloc: a.out(4918) seq=111 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  304.335226] MemAlloc: a.out(4924) seq=101 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110411 uninterruptible
[  304.397988] MemAlloc: a.out(4928) seq=272 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  304.459028] MemAlloc: a.out(4932) seq=263 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.521187] MemAlloc: a.out(4933) seq=405 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  304.583184] MemAlloc: a.out(4934) seq=173 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110458 uninterruptible
[  304.644320] MemAlloc: a.out(4936) seq=26 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.710213] MemAlloc: a.out(4942) seq=294 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.772068] MemAlloc: a.out(4945) seq=27 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  304.837134] MemAlloc: a.out(4947) seq=16 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110471 uninterruptible
[  304.902075] MemAlloc: a.out(4949) seq=231 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110482 uninterruptible
[  304.963532] MemAlloc: a.out(4951) seq=288 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=110460 uninterruptible
[  305.024528] MemAlloc: abrt-hook-ccpp(5006) seq=2155 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110551 uninterruptible
[  305.078309] MemAlloc: smbd(5007) seq=1081 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=110483 uninterruptible
[  315.206606] MemAlloc-Info: 185 stalling task, 30 dying task, 45 exiting task, 0 victim task. oom_count=1593
---------- console log ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
