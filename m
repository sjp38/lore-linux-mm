Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8A26B0257
	for <linux-mm@kvack.org>; Sun, 22 Nov 2015 09:46:34 -0500 (EST)
Received: by oies6 with SMTP id s6so98172802oie.1
        for <linux-mm@kvack.org>; Sun, 22 Nov 2015 06:46:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g5si5798174oed.35.2015.11.22.06.46.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Nov 2015 06:46:33 -0800 (PST)
Subject: [RFC][PATCH v2] Memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp>
Message-Id: <201511222346.JBH48464.VFFtOLOOQJMFHS@I-love.SAKURA.ne.jp>
Date: Sun, 22 Nov 2015 23:46:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

>From ee98a42df32060fd08555dabbc3dd65ce9f1d643 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 22 Nov 2015 22:36:39 +0900
Subject: [PATCH v2] Memory allocation watchdog kernel thread.

This patch adds a kernel thread which periodically reports number of
memory allocating tasks, dying tasks and OOM victim tasks when some task
is spending too long time inside __alloc_pages_slowpath().

This kernel thread resembles khungtaskd kernel thread, but this kernel
thread is for warning that memory allocation requests are stalling, in
order to catch unexplained hangups/reboots caused by memory allocation
stalls.

There are two types of memory allocation stalls, one is that we fail to
solve OOM conditions after the OOM killer is invoked, the other is that
we fail to solve OOM conditions before the OOM killer is invoked.

The former case is that the OOM killer chose an OOM victim but the chosen
victim is unable to make forward progress. Although the OOM victim
receives TIF_MEMDIE by the OOM killer, TIF_MEMDIE helps only if the OOM
victim was doing memory allocation. That is, if the OOM victim was
blocked at unkillable locks (e.g. mutex_lock(&inode->i_mutex) or
down_read(&mm->mmap_sem)), the system will hang up upon global OOM
condition. This kernel thread will report such situation by printing

  MemAlloc-Info: $X stalling task, $Y dying task, $Z victim task.

line where $X > 0 and $Y > 0 and $Z > 0, followed by at most $X + $Y
lines of

  MemAlloc: $name($pid) $state_of_allocation $state_of_task

where $name and $pid are comm name and pid of a task.

$state_of_allocation is reported only when that task is stalling inside
__alloc_pages_slowpath(), in gfp=$gfp order=$order delay=$delay format
where $gfp is the gfp flags used for that allocation request, $order is
the order, delay is jiffies elapsed since entering into
__alloc_pages_slowpath().

$state_of_task is reported only when that task is dying, in combination
of "uninterruptible" (where that task is in uninterruptible sleep,
likely due to uninterruptible lock), "dying" (where that task has pending
SIGKILL) and "victim" (where that task received TIF_MEMDIE, likely be
only 1 task).

Then, stack trace of stalling tasks and dying tasks, and memory
information (SysRq-m) follows.

The latter case has three possibilities. First possibility is simply
overloaded (not a livelock but progress is too slow to wait). Second
possibility is that at least one task is doing __GFP_FS || __GFP_NOFAIL
memory allocation request but operation for reclaiming memory is not
working as expected due to unknown reason (a livelock), which will not
invoke the OOM killer. Third possibility is that all ongoing memory
allocation requests are !__GFP_FS && !__GFP_NOFAIL, which does not
invoke the OOM killer. This kernel thread will report such situation
with $X > 0, $Y >= 0 and $Z = 0.

An example of MemAlloc lines is shown below.

  [   91.195737] MemAlloc-Info: 1 stalling task, 10 dying task, 1 victim task.
  [   91.197936] MemAlloc: oom-tester4(11040) uninterruptible dying victim
  [   91.199957] MemAlloc: oom-tester4(11042) uninterruptible dying
  [   91.201833] MemAlloc: oom-tester4(11043) uninterruptible dying
  [   91.203713] MemAlloc: oom-tester4(11044) uninterruptible dying
  [   91.205569] MemAlloc: oom-tester4(11045) gfp=0x242014a order=0 delay=10000 dying
  [   91.207733] MemAlloc: oom-tester4(11046) uninterruptible dying
  [   91.209600] MemAlloc: oom-tester4(11047) uninterruptible dying
  [   91.211473] MemAlloc: oom-tester4(11048) uninterruptible dying
  [   91.213324] MemAlloc: oom-tester4(11049) uninterruptible dying
  [   91.215186] MemAlloc: oom-tester4(11050) uninterruptible dying

  [  101.567609] MemAlloc-Info: 12 stalling task, 10 dying task, 1 victim task.
  [  101.569551] MemAlloc: kworker/3:1(45) gfp=0x2400000 order=0 delay=19470 uninterruptible
  [  101.571680] MemAlloc: systemd-journal(478) gfp=0x242014a order=0 delay=19538 uninterruptible
  [  101.573871] MemAlloc: tuned(2081) gfp=0x242014a order=0 delay=19541 uninterruptible
  [  101.575925] MemAlloc: irqbalance(1711) gfp=0x242014a order=0 delay=10685
  [  101.577850] MemAlloc: vmtoolsd(1908) gfp=0x242014a order=0 delay=19525 uninterruptible
  [  101.579981] MemAlloc: master(4005) gfp=0x242014a order=0 delay=15090 uninterruptible
  [  101.582113] MemAlloc: nmbd(4813) gfp=0x242014a order=0 delay=19533 uninterruptible
  [  101.584267] MemAlloc: smbd(4967) gfp=0x242014a order=0 delay=11799
  [  101.586077] MemAlloc: smbd(5040) gfp=0x242014a order=0 delay=11441
  [  101.587873] MemAlloc: oom-tester4(11039) gfp=0x24280ca order=0 delay=19542
  [  101.589803] MemAlloc: oom-tester4(11040) uninterruptible dying victim
  [  101.591637] MemAlloc: oom-tester4(11042) uninterruptible dying
  [  101.593429] MemAlloc: oom-tester4(11043) uninterruptible dying
  [  101.595122] MemAlloc: oom-tester4(11044) uninterruptible dying
  [  101.596796] MemAlloc: oom-tester4(11045) gfp=0x242014a order=0 delay=20371 dying
  [  101.598772] MemAlloc: oom-tester4(11046) uninterruptible dying
  [  101.600527] MemAlloc: oom-tester4(11047) uninterruptible dying
  [  101.602196] MemAlloc: oom-tester4(11048) uninterruptible dying
  [  101.603851] MemAlloc: oom-tester4(11049) uninterruptible dying
  [  101.605497] MemAlloc: oom-tester4(11050) uninterruptible dying
  [  101.607139] MemAlloc: oom-tester4(11041) gfp=0x242014a order=0 delay=19541

Without this kernel thread, it is extremely hard to figure out that
the system hung up due to memory allocation stalls because the
"%s invoked oom-killer: gfp_mask=0x%x, order=%d, ""oom_score_adj=%hd\n"
line is not printed for several corner cases in the former case and is
never printed in the latter case, resulting in completely silent hangups.

Changes from V1: ( http://lkml.kernel.org/r/201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp )

  (1) Use per a "struct task_struct" variables. This allows vmcore to
      remember information about last memory allocation request, which
      is useful for understanding last-minute behavior of the kernel.

  (2) Report using accurate timeout. This increases possibility of
      successfully reporting before watchdog timers reset the machine.

  (3) Show memory information (SysRq-m). This makes it easier to know
      the reason of stalling.

  (4) Show both $state_of_allocation and $state_of_task in the same
      line. This makes it easier to grep the output.

  (5) Minimize duration of spinlock held by the kernel thread.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |  11 +++
 mm/Kconfig            |  24 ++++++
 mm/page_alloc.c       | 216 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 251 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..aeda82c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1375,6 +1375,14 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+struct memalloc_info {
+	unsigned long start; /* Initialized to jiffies. */
+	unsigned int order;
+	gfp_t gfp;
+	u8 valid; /* Takes one of 0, 1, 2. */
+	u8 dumped;
+};
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1812,6 +1820,9 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06..8e430bd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -668,3 +668,27 @@ config ZONE_DEVICE
 
 config FRAME_VECTOR
 	bool
+
+config MEMALLOC_WATCHDOG
+	bool "Memory allocation stalling watchdog"
+	default n
+	help
+	  This option emits warning messages and traces when memory
+	  allocation requests are stalling, in order to catch unexplained
+	  hangups/reboots caused by memory allocation stalls.
+
+	  Currently, when something went wrong inside memory allocation
+	  request, the system will stall with either 100% CPU usage (if
+	  memory allocating tasks are doing busy loop) or 0% CPU usage
+	  (if memory allocating tasks are waiting for file data to be
+	  flushed to storage). But /proc/sys/kernel/hung_task_warnings
+	  is not helpful because memory allocating tasks do not sleep in
+	  uninterruptible state for /proc/sys/kernel/hung_task_timeout_secs
+	  seconds.
+
+	  Scan interval can be changed by passing integer value to kmallocwd
+	  boot parameter. For example, passing kmallocwd=30 will emit first
+	  stall warnings in 30 seconds, and emit subsequent warnings in 30
+	  seconds.
+
+	  This option can be disabled by passing kmallocwd=0 boot parameter.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3504925..d922563 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -62,6 +62,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/nmi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3173,6 +3174,219 @@ got_pg:
 	return page;
 }
 
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+
+static unsigned long kmallocwd_timeout = 10 * HZ; /* Default scan interval. */
+static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
+/*
+ * Lock for reading memalloc variable.
+ *
+ * Since start_memalloc_timer() updates current->memalloc and single threaded
+ * kmallocwd() reads other task's memalloc, start_memalloc_timer() takes read
+ * lock and kmallocwd() takes write lock.
+ */
+static DEFINE_RWLOCK(memalloc_lock);
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
+	if (!m->valid)
+		return false;
+	write_lock(&memalloc_lock);
+	memalloc = *m;
+	write_unlock(&memalloc_lock);
+	return memalloc.valid && time_after_eq(expire, memalloc.start);
+}
+
+/*
+ * kmallocwd - A kernel thread for monitoring memory allocation stalls.
+ *
+ * @unused: Not used.
+ *
+ * This kernel thread does not terminate.
+ */
+static int kmallocwd(void *unused)
+{
+	char buf[128];
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long expire;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+
+ restart:
+	/* Sleep until stalled tasks are found. */
+	while (1) {
+		/*
+		 * If memory allocations are not stalling, the value of t after
+		 * this for_each_process_thread() loop should remain close to
+		 * kmallocwd_timeout. Also, we sleep for kmallocwd_timeout
+		 * before retrying if memory allocations are stalling.
+		 * Therefore, this while() loop won't waste too much CPU cycles
+		 * due to sleeping for too short period.
+		 */
+		long t = kmallocwd_timeout;
+		const unsigned long delta = t - jiffies;
+		/*
+		 * We might see outdated values in "struct memalloc_info" here.
+		 * We will recheck later using is_stalling_task().
+		 */
+		rcu_read_lock();
+		for_each_process_thread(g, p) {
+			if (likely(!p->memalloc.valid))
+				continue;
+			t = min_t(long, t, p->memalloc.start + delta);
+			if (unlikely(t <= 0))
+				goto stalling;
+		}
+		rcu_read_unlock();
+		schedule_timeout_interruptible(t);
+	}
+ stalling:
+	rcu_read_unlock();
+	cond_resched();
+	now = jiffies;
+	expire = now - kmallocwd_timeout;
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			memdie_pending++;
+		if (fatal_signal_pending(p))
+			sigkill_pending++;
+		if (is_stalling_task(p, expire))
+			stalling_tasks++;
+	}
+	rcu_read_unlock();
+	/* Do not report if stalling tasks called stop_memalloc_timer(). */
+	if (!stalling_tasks)
+		goto restart;
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			type |= 1;
+		if (fatal_signal_pending(p))
+			type |= 2;
+		if (is_stalling_task(p, expire))
+			type |= 4;
+		if (likely(!type))
+			continue;
+		if (p->state & TASK_UNINTERRUPTIBLE)
+			type |= 8;
+		buf[0] = '\0';
+		if (type & 4)
+			snprintf(buf, sizeof(buf),
+				 " gfp=0x%x order=%u delay=%lu", memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		pr_warn("MemAlloc: %s(%u)%s%s%s%s\n", p->comm, p->pid, buf,
+			(type & 8) ? " uninterruptible" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+		touch_nmi_watchdog();
+	}
+	rcu_read_unlock();
+	cond_resched();
+	/*
+	 * Show traces of dying tasks (including victim tasks) and newly
+	 * reported (or too long) stalling tasks.
+	 *
+	 * Only dying tasks which are in trouble (e.g. blocked at unkillable
+	 * locks held by memory allocating tasks) will be repeatedly shown.
+	 * Therefore, we need to pay attention to tasks repeatedly shown here.
+	 *
+	 * Traces of stalling tasks are shown only twice per 256 timeouts
+	 * because their traces will likely be the same (e.g. cond_sched()
+	 * or congestion_wait()) when they are stalling inside
+	 * __alloc_pages_slowpath(). Though it may not exactly twice here
+	 * because we can theoretically race with start_memalloc_timer().
+	 */
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (fatal_signal_pending(p) ||
+		    (is_stalling_task(p, expire) && p->memalloc.dumped++ < 2)) {
+			sched_show_task(p);
+			debug_show_held_locks(p);
+			touch_nmi_watchdog();
+		}
+	}
+	rcu_read_unlock();
+	cond_resched();
+	/* Show memory information. (SysRq-m) */
+	show_mem(0);
+	/* Sleep until next timeout duration. */
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	goto restart;
+	return 0; /* To suppress "no return statement" compiler warning. */
+}
+
+static int __init start_kmallocwd(void)
+{
+	if (kmallocwd_timeout) {
+		struct task_struct *task = kthread_run(kmallocwd, NULL,
+						       "kmallocwd");
+		BUG_ON(IS_ERR(task));
+	}
+	return 0;
+}
+late_initcall(start_kmallocwd);
+
+static int __init kmallocwd_config(char *str)
+{
+	if (kstrtoul(str, 10, &kmallocwd_timeout) == 0)
+		kmallocwd_timeout = min(kmallocwd_timeout * HZ,
+					(unsigned long) LONG_MAX);
+	return 0;
+}
+__setup("kmallocwd=", kmallocwd_config);
+
+static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_RECLAIM))
+		return;
+	/* We don't check for stalls for nested __GFP_RECLAIM allocations */
+	if (!m->valid) {
+		read_lock(&memalloc_lock);
+		m->start = jiffies;
+		m->gfp = gfp_mask;
+		m->order = order;
+		m->dumped = 0;
+		read_unlock(&memalloc_lock);
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
@@ -3240,7 +3454,9 @@ retry_cpuset:
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
