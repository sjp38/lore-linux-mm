Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8956B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:24:34 -0500 (EST)
Received: by obbbj7 with SMTP id bj7so15572369obb.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:24:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d10si4608924oif.133.2015.11.24.07.24.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 07:24:32 -0800 (PST)
Subject: Re: [RFC][PATCH v3] Memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp>
	<201511222346.JBH48464.VFFtOLOOQJMFHS@I-love.SAKURA.ne.jp>
In-Reply-To: <201511222346.JBH48464.VFFtOLOOQJMFHS@I-love.SAKURA.ne.jp>
Message-Id: <201511250024.AAE78692.QVOtFFOSFOMLJH@I-love.SAKURA.ne.jp>
Date: Wed, 25 Nov 2015 00:24:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

>From 7cfea996b67a430000e7b0fb9943ebd799cf37e8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 25 Nov 2015 00:16:24 +0900
Subject: [PATCH v3] Memory allocation watchdog kernel thread.

This patch adds a kernel thread which periodically reports number of
memory allocating tasks, dying tasks and OOM victim tasks when some task
is spending too long time inside __alloc_pages_slowpath().

Changes from v1:

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

Changes from v2:

  (1) Print sequence number. This makes it easier to know whether
      memory allocation is succeeding (looks like a livelock but making
      forward progress) or not.

  (2) Replace spinlock with cheaper seqlock_t like sequence number based
      method. The caller no longer contend on lock, and major overhead
      for caller side will be two smp_wmb() instead for
      read_lock()/read_unlock().

  (3) Print "exiting" instead for "dying" if an OOM victim is stalling
      at do_exit(), for SIGKILL is removed before arriving at do_exit().

  (4) Moved explanation to Documentation/malloc-watchdog.txt .

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 Documentation/malloc-watchdog.txt | 141 +++++++++++++++++++++++
 include/linux/sched.h             |  21 ++++
 kernel/fork.c                     |   4 +
 mm/Kconfig                        |  10 ++
 mm/page_alloc.c                   | 230 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 406 insertions(+)
 create mode 100644 Documentation/malloc-watchdog.txt

diff --git a/Documentation/malloc-watchdog.txt b/Documentation/malloc-watchdog.txt
new file mode 100644
index 0000000..6d7b33d
--- /dev/null
+++ b/Documentation/malloc-watchdog.txt
@@ -0,0 +1,141 @@
+=========================================
+Memory allocation watchdog kernel thread.
+=========================================
+
+
+- What is it?
+
+This kernel thread resembles khungtaskd kernel thread, but this kernel
+thread is for warning that memory allocation requests are stalling, in
+order to catch unexplained hangups/reboots caused by memory allocation
+stalls.
+
+
+- Why need to use it?
+
+Currently, when something went wrong inside memory allocation request,
+the system will stall with either 100% CPU usage (if memory allocating
+tasks are doing busy loop) or 0% CPU usage (if memory allocating tasks
+are waiting for file data to be flushed to storage).
+But /proc/sys/kernel/hung_task_warnings is not helpful because memory
+allocating tasks unlikely sleep in uninterruptible state for
+/proc/sys/kernel/hung_task_timeout_secs seconds.
+
+People are reporting hang up problems. But we are forcing people to use
+kernels without means to find out what was happening. The means are
+expected to work without knowledge to use trace points functionality,
+are expected to run without memory allocation, are expected to dump
+output without administrator's operation, are expected to work before
+watchdog timers reset the machine.
+
+Without this kernel thread, it is extremely hard to figure out that
+the system hung up due to memory allocation stalls because the
+"%s invoked oom-killer: gfp_mask=0x%x, order=%d, ""oom_score_adj=%hd\n"
+line is not printed for several corner cases in the former case and is
+never printed in the latter case, resulting in completely silent hangups.
+
+
+- How to configure it?
+
+Build kernels with CONFIG_MEMALLOC_WATCHDOG=y.
+
+Default scan interval is 10 seconds. Scan interval can be changed by passing
+integer value to kmallocwd boot parameter. For example, passing kmallocwd=30
+will emit first stall warnings in 30 seconds, and emit subsequent warnings in
+30 seconds.
+
+Even if you disable this kernel thread by passing kmallocwd=0 boot parameter,
+information about last memory allocation request is kept. That is, you will
+get some hint for understanding last-minute behavior of the kernel when you
+analyze vmcore (or memory snapshot of a virtualized machine).
+
+
+- How memory allocation stalls are reported?
+
+There are two types of memory allocation stalls, one is that we fail to
+solve OOM conditions after the OOM killer is invoked, the other is that
+we fail to solve OOM conditions before the OOM killer is invoked.
+
+The former case is that the OOM killer chose an OOM victim but the chosen
+victim is unable to make forward progress. Although the OOM victim
+receives TIF_MEMDIE by the OOM killer, TIF_MEMDIE helps only if the OOM
+victim was doing memory allocation. That is, if the OOM victim was
+blocked at unkillable locks (e.g. mutex_lock(&inode->i_mutex) or
+down_read(&mm->mmap_sem)), the system will hang up upon global OOM
+condition. This kernel thread will report such situation by printing
+
+  MemAlloc-Info: $X stalling task, $Y dying task, $Z victim task.
+
+line where $X > 0 and $Y > 0 and $Z > 0, followed by at most $X + $Y
+lines of
+
+  MemAlloc: $name($pid) $state_of_allocation $state_of_task
+
+where $name and $pid are comm name and pid of a task.
+
+$state_of_allocation is reported only when that task is stalling inside
+__alloc_pages_slowpath(), in seq=$seq gfp=$gfp order=$order delay=$delay
+format where $seq is the sequence number for allocation request, $gfp is
+the gfp flags used for that allocation request, $order is the order,
+delay is jiffies elapsed since entering into __alloc_pages_slowpath().
+
+$state_of_task is reported only when that task is dying, in combination
+of "uninterruptible" (where that task is in uninterruptible sleep,
+likely due to uninterruptible lock), "exiting" (where that task arrived
+at do_exit() function), "dying" (where that task has pending SIGKILL)
+and "victim" (where that task received TIF_MEMDIE, likely be only 1 task).
+
+The latter case has three possibilities. First possibility is simply
+overloaded (not a livelock but progress is too slow to wait). You can
+check for seq=$seq field for each reported process. If $seq is
+increasing over time, it is not a livelock. Second possibility is that
+at least one task is doing __GFP_FS || __GFP_NOFAIL memory allocation
+request but operation for reclaiming memory is not working as expected
+due to unknown reason (a livelock), which will not invoke the OOM
+killer. Third possibility is that all ongoing memory allocation
+requests are !__GFP_FS && !__GFP_NOFAIL, which does not invoke the OOM
+killer. This kernel thread will report such situation with $X > 0,
+$Y >= 0 and $Z = 0.
+
+
+- How the messages look like?
+
+An example of MemAlloc lines is shown below. Stack trace of stalling tasks and
+dying tasks, and memory information (SysRq-m) will follow the MemAlloc lines.
+You can use serial console and/or netconsole to save these messages when the
+system is stalling.
+
+  [   95.444132] MemAlloc-Info: 1 stalling task, 9 dying task, 1 victim task.
+  [   95.446356] MemAlloc: oom-tester(11043) uninterruptible exiting victim
+  [   95.448535] MemAlloc: oom-tester(11045) dying
+  [   95.450270] MemAlloc: oom-tester(11046) dying
+  [   95.452160] MemAlloc: oom-tester(11047) uninterruptible dying
+  [   95.454220] MemAlloc: oom-tester(11048) dying
+  [   95.455933] MemAlloc: oom-tester(11049) uninterruptible dying
+  [   95.457901] MemAlloc: oom-tester(11050) uninterruptible dying
+  [   95.459849] MemAlloc: oom-tester(11051) uninterruptible dying
+  [   95.461793] MemAlloc: oom-tester(11052) seq=2 gfp=0x242014a order=0 delay=10002 dying
+  [   95.464165] MemAlloc: oom-tester(11053) dying
+
+  [  105.879267] MemAlloc-Info: 16 stalling task, 9 dying task, 1 victim task.
+  [  105.881314] MemAlloc: kworker/1:2(407) seq=1 gfp=0x2400000 order=0 delay=18966
+  [  105.883360] MemAlloc: systemd-journal(477) seq=1227 gfp=0x242014a order=0 delay=19999
+  [  105.885514] MemAlloc: tuned(2081) seq=789 gfp=0x242014a order=0 delay=12001
+  [  105.887515] MemAlloc: irqbalance(743) seq=2 gfp=0x242014a order=0 delay=15882
+  [  105.889554] MemAlloc: rngd(744) seq=61 gfp=0x242014a order=0 delay=20000
+  [  105.891573] MemAlloc: abrt-watch-log(757) seq=4 gfp=0x242014a order=0 delay=20013
+  [  105.893696] MemAlloc: vmtoolsd(1905) seq=1512 gfp=0x242014a order=0 delay=20014
+  [  105.895873] MemAlloc: nmbd(4784) seq=2 gfp=0x242014a order=0 delay=15034
+  [  105.897872] MemAlloc: smbd(4949) seq=2 gfp=0x242014a order=0 delay=16070
+  [  105.899835] MemAlloc: smbd(5020) seq=2 gfp=0x242014a order=0 delay=15632
+  [  105.901782] MemAlloc: oom-tester(11042) seq=4974 gfp=0x24280ca order=0 delay=20015
+  [  105.903887] MemAlloc: oom-tester(11043) uninterruptible exiting victim
+  [  105.905797] MemAlloc: oom-tester(11045) seq=2 gfp=0x242014a order=0 delay=20419 dying
+  [  105.908024] MemAlloc: oom-tester(11046) seq=4 gfp=0x242014a order=0 delay=20011 dying
+  [  105.910161] MemAlloc: oom-tester(11047) uninterruptible dying
+  [  105.911910] MemAlloc: oom-tester(11048) seq=4 gfp=0x242014a order=0 delay=20004 dying
+  [  105.914044] MemAlloc: oom-tester(11049) uninterruptible dying
+  [  105.915780] MemAlloc: oom-tester(11050) uninterruptible dying
+  [  105.917518] MemAlloc: oom-tester(11051) uninterruptible dying
+  [  105.919249] MemAlloc: oom-tester(11052) seq=2 gfp=0x242014a order=0 delay=20437 dying
+  [  105.921362] MemAlloc: oom-tester(11053) seq=2 gfp=0x242014a order=0 delay=20402 dying
diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..6116d70 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1375,6 +1375,24 @@ struct tlbflush_unmap_batch {
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
+	/* For reducing stack traces. */
+	u8 dumped;
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
@@ -1812,6 +1830,9 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index ff39b78..3cf4402 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1416,6 +1416,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+	p->memalloc.sequence = 0;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06..df05f85 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -668,3 +668,13 @@ config ZONE_DEVICE
 
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
+	  See Documentation/malloc-watchdog.txt for more information.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3504925..142cb94 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -62,6 +62,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/nmi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3173,6 +3174,233 @@ got_pg:
 	return page;
 }
 
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+
+static unsigned long kmallocwd_timeout = 10 * HZ; /* Default scan interval. */
+static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
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
+	unsigned int seq;
+
+	if (!m->valid)
+		return false;
+	/*
+	 * If start_memalloc_timer() is updating "struct memalloc_info" now,
+	 * we can ignore it because timeout jiffies cannot be expired as soon
+	 * as updating it completes.
+	 */
+	seq = READ_ONCE(m->sequence);
+	smp_rmb();
+	if (seq & 1)
+		return false;
+	memalloc = *m;
+	/*
+	 * If start_memalloc_timer() started updating it while we read it,
+	 * we can ignore it for the same reason.
+	 */
+	if (!memalloc.valid || (memalloc.sequence & 1))
+		return false;
+	/* This is a valid "struct memalloc_info". Check for timeout. */
+	return time_after_eq(expire, memalloc.start);
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
+		buf[0] = '\0';
+		if (type & 4)
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x order=%u delay=%lu",
+				 memalloc.sequence >> 1, memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
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
+		m->sequence++;
+		smp_wmb(); /* Block is_stalling_task(). */
+		m->start = jiffies;
+		m->gfp = gfp_mask;
+		m->order = order;
+		m->dumped = 0;
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
@@ -3240,7 +3468,9 @@ retry_cpuset:
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
