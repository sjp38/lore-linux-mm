Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id D39266B0253
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 10:33:26 -0500 (EST)
Received: by obbsd4 with SMTP id sd4so54116322obb.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 07:33:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c63si3926733oib.67.2015.12.12.07.33.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 12 Dec 2015 07:33:25 -0800 (PST)
Subject: [PATCH v4] mm,oom: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp>
Date: Sun, 13 Dec 2015 00:33:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

>From 2804913f4d21a20a154b93d5437c21e52bf761a1 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 13 Dec 2015 00:02:29 +0900
Subject: [PATCH v4] mm/oom: Add memory allocation watchdog kernel thread.

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

Changes from v3:

  (1) Avoid stalls even if there are so many tasks to report.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 Documentation/malloc-watchdog.txt | 139 +++++++++++++++++++++
 include/linux/sched.h             |  25 ++++
 kernel/fork.c                     |   4 +
 mm/Kconfig                        |  10 ++
 mm/page_alloc.c                   | 254 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 432 insertions(+)
 create mode 100644 Documentation/malloc-watchdog.txt

diff --git a/Documentation/malloc-watchdog.txt b/Documentation/malloc-watchdog.txt
new file mode 100644
index 0000000..599d751
--- /dev/null
+++ b/Documentation/malloc-watchdog.txt
@@ -0,0 +1,139 @@
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
+watchdog timers reset the machine. Without this kernel thread, it is
+extremely hard to figure out that the system hung up due to memory
+allocation stalls.
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
+An example of MemAlloc lines (grep of dmesg output) is shown below.
+You can use serial console and/or netconsole to save these messages
+when the system is stalling.
+
+  [   78.402510] MemAlloc-Info: 7 stalling task, 1 dying task, 1 victim task.
+  [   78.404691] MemAlloc: kthreadd(2) seq=6 gfp=0x27000c0 order=2 delay=9931 uninterruptible
+  [   78.451201] MemAlloc: systemd-journal(478) seq=73 gfp=0x24201ca order=0 delay=9842
+  [   78.497058] MemAlloc: irqbalance(747) seq=4 gfp=0x24201ca order=0 delay=7454
+  [   78.542291] MemAlloc: crond(969) seq=18 gfp=0x24201ca order=0 delay=9842
+  [   78.586270] MemAlloc: vmtoolsd(1912) seq=64 gfp=0x24201ca order=0 delay=9847
+  [   78.631516] MemAlloc: oom-write(3786) seq=25322 gfp=0x24280ca order=0 delay=10000 uninterruptible
+  [   78.676193] MemAlloc: write(3787) seq=46308 gfp=0x2400240 order=0 delay=9847 uninterruptible exiting
+  [   78.755351] MemAlloc: write(3788) uninterruptible dying victim
+  [   88.854456] MemAlloc-Info: 8 stalling task, 1 dying task, 1 victim task.
+  [   88.856533] MemAlloc: kthreadd(2) seq=6 gfp=0x27000c0 order=2 delay=20383 uninterruptible
+  [   88.900375] MemAlloc: systemd-journal(478) seq=73 gfp=0x24201ca order=0 delay=20294 uninterruptible
+  [   88.952300] MemAlloc: irqbalance(747) seq=4 gfp=0x24201ca order=0 delay=17906 uninterruptible
+  [   88.997542] MemAlloc: crond(969) seq=18 gfp=0x24201ca order=0 delay=20294
+  [   89.041480] MemAlloc: vmtoolsd(1912) seq=64 gfp=0x24201ca order=0 delay=20299
+  [   89.090096] MemAlloc: nmbd(3709) seq=9 gfp=0x24201ca order=0 delay=13855
+  [   89.142032] MemAlloc: oom-write(3786) seq=25322 gfp=0x24280ca order=0 delay=20452
+  [   89.177999] MemAlloc: write(3787) seq=46308 gfp=0x2400240 order=0 delay=20299 exiting
+  [   89.254554] MemAlloc: write(3788) uninterruptible dying victim
+  [   99.353664] MemAlloc-Info: 11 stalling task, 1 dying task, 1 victim task.
+  [   99.356044] MemAlloc: kthreadd(2) seq=6 gfp=0x27000c0 order=2 delay=30882 uninterruptible
+  [   99.403609] MemAlloc: systemd-journal(478) seq=73 gfp=0x24201ca order=0 delay=30793 uninterruptible
+  [   99.449469] MemAlloc: irqbalance(747) seq=4 gfp=0x24201ca order=0 delay=28405
+  [   99.493474] MemAlloc: crond(969) seq=18 gfp=0x24201ca order=0 delay=30793 uninterruptible
+  [   99.536027] MemAlloc: vmtoolsd(1912) seq=64 gfp=0x24201ca order=0 delay=30798 uninterruptible
+  [   99.582630] MemAlloc: master(3682) seq=2 gfp=0x24201ca order=0 delay=10886
+  [   99.626574] MemAlloc: nmbd(3709) seq=9 gfp=0x24201ca order=0 delay=24354
+  [   99.669191] MemAlloc: smbd(3737) seq=2 gfp=0x24201ca order=0 delay=7130
+  [   99.714555] MemAlloc: smbd(3753) seq=2 gfp=0x24201ca order=0 delay=6616 uninterruptible
+  [   99.758412] MemAlloc: oom-write(3786) seq=25322 gfp=0x24280ca order=0 delay=30951
+  [   99.793156] MemAlloc: write(3787) seq=46308 gfp=0x2400240 order=0 delay=30798 uninterruptible exiting
+  [   99.871842] MemAlloc: write(3788) uninterruptible dying victim
+
+You can check whether memory allocations are making forward progress.
+You can check where memory allocations are stalling using stack trace
+of reported task which follows each MemAlloc line. You can check memory
+information (SysRq-m) which follows end of MemAlloc lines.
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7b76e39..039b04d 100644
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
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 8cb287a..aed1c89 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1414,6 +1414,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index bac8842d..5ff89ae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -62,6 +62,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/console.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3199,6 +3200,257 @@ got_pg:
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
+		preempt_disable();
+		rcu_read_lock();
+		for_each_process_thread(g, p) {
+			if (likely(!p->memalloc.valid))
+				continue;
+			t = min_t(long, t, p->memalloc.start + delta);
+			if (unlikely(t <= 0))
+				goto stalling;
+		}
+		rcu_read_unlock();
+		preempt_enable();
+		schedule_timeout_interruptible(t);
+	}
+ stalling:
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	now = jiffies;
+	/*
+	 * Report tasks that stalled for more than half of timeout duration
+	 * because such tasks might be correlated with tasks that already
+	 * stalled for full timeout duration.
+	 */
+	expire = now - kmallocwd_timeout / 2;
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
+		goto restart;
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	cond_resched();
+	preempt_disable();
+	rcu_read_lock();
+ restart_report:
+	for_each_process_thread(g, p) {
+		bool can_cont;
+		u8 type = p->memalloc.type;
+
+		if (likely(!type))
+			continue;
+		p->memalloc.type = 0;
+		buf[0] = '\0';
+		/*
+		 * Recheck stalling tasks in case they called
+		 * stop_memalloc_timer() meanwhile.
+		 */
+		if (type & 4) {
+			if (is_stalling_task(p, expire)) {
+				snprintf(buf, sizeof(buf),
+					 " seq=%u gfp=0x%x order=%u delay=%lu",
+					 memalloc.sequence >> 1, memalloc.gfp,
+					 memalloc.order, now - memalloc.start);
+			} else {
+				type &= ~4;
+				if (!type)
+					continue;
+			}
+		}
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
+	/* Sleep until next timeout duration. */
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	goto restart;
+	return 0; /* To suppress "no return statement" compiler warning. */
+}
+
+static int __init start_kmallocwd(void)
+{
+	if (kmallocwd_timeout)
+		kthread_run(kmallocwd, NULL, "kmallocwd");
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
@@ -3266,7 +3518,9 @@ retry_cpuset:
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
