Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8872A6B025E
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 02:15:30 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id hc3so56802582pac.4
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 00:15:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z4si25761868pgb.66.2016.11.06.00.15.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Nov 2016 00:15:28 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Date: Sun,  6 Nov 2016 16:15:01 +0900
Message-Id: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
too long") was a great step for reducing possibility of silent hang up
problem caused by memory allocation stalls [1]. But it became clear
that Michal Hocko is not going to make warn_alloc() bullet proof [2].
Therefore, I again propose this patch in order to allow a bullet proof
reporting.

Michal Hocko agrees that reporting is important part of debugging of
problems but is thinking that state tracking is in general too complex
for something that doesn't happen in most properly configured systems.
But I assert that there _are_ systems which are bothered by low memory
situations. It is pointless to refer to "properly configured systems"
as a reason not to introduce a state tracking.

This patch adds a watchdog which periodically reports number of memory
allocating tasks, dying tasks and OOM victim tasks when some task is
spending too long time inside __alloc_pages_slowpath(). This patch also
serves as a hook for obtaining additional information using SystemTap
(e.g. examine other variables using printk(), capture a crash dump by
calling panic()) by triggering a callback only when an stall is detected.
Ability to take administrator-controlled actions based on some threshold
is a big advantage gained by introducing a state tracking.

It is administrators who decide whether to utilize debugging capability
with state tracking. Let's give administrators a choice and a chance.

Changes from v1: ( http://lkml.kernel.org/r/201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp )

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

Changes from v2: ( http://lkml.kernel.org/r/201511222346.JBH48464.VFFtOLOOQJMFHS@I-love.SAKURA.ne.jp )

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

Changes from v3: ( http://lkml.kernel.org/r/201511250024.AAE78692.QVOtFFOSFOMLJH@I-love.SAKURA.ne.jp )

  (1) Avoid stalls even if there are so many tasks to report.

Changes from v4: ( http://lkml.kernel.org/r/201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp )

  (1) Use per CPU in-flight counter by reverting "Report using accurate
      timeout." in v2, in order to avoid walking the process list which
      is costly when there are extremely so many tasks in the system.

  (2) Updated Documentation/malloc-watchdog.txt to add explanation for
      serving as a hook for dynamic probes.

Changes from v5: ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp )

  (1) Disable commit 63f53dea0c9866e9 ("mm: warn about allocations which
      stall for too long") when CONFIG_DETECT_MEMALLOC_STALL_TASK is
      enabled.

  (2) Updated Documentation/malloc-watchdog.txt to reflect OOM related
      improvements up to Linux 4.9.

[1] http://lkml.kernel.org/r/201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/20161019115525.GH7517@dhcp22.suse.cz

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 Documentation/malloc-watchdog.txt | 155 ++++++++++++++++++++++++++
 include/linux/oom.h               |   4 +
 include/linux/sched.h             |  29 +++++
 kernel/fork.c                     |   4 +
 kernel/hung_task.c                | 221 +++++++++++++++++++++++++++++++++++++-
 kernel/sysctl.c                   |  10 ++
 lib/Kconfig.debug                 |  24 +++++
 mm/oom_kill.c                     |   3 +
 mm/page_alloc.c                   |  57 ++++++++++
 9 files changed, 505 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/malloc-watchdog.txt

diff --git a/Documentation/malloc-watchdog.txt b/Documentation/malloc-watchdog.txt
new file mode 100644
index 0000000..e4b24d77
--- /dev/null
+++ b/Documentation/malloc-watchdog.txt
@@ -0,0 +1,155 @@
+=================================
+Memory allocation stall watchdog.
+=================================
+
+
+- What is it?
+
+This is an extension to khungtaskd kernel thread, which is for warning
+that memory allocation requests are stalling, in order to catch unexplained
+hangups/reboots caused by memory allocation stalls.
+
+
+- Why need to use it?
+
+Currently, when something went wrong inside memory allocation request,
+the system might stall without any kernel messages.
+
+Although there is khungtaskd kernel thread as an asynchronous monitoring
+approach, khungtaskd kernel thread is not always helpful because memory
+allocating tasks unlikely sleep in uninterruptible state for
+/proc/sys/kernel/hung_task_timeout_secs seconds.
+
+Although there is warn_alloc() as a synchronous monitoring approach
+which emits
+
+  "%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg)\n"
+
+line, warn_alloc() is not bullet proof because allocating tasks can get
+stuck before calling warn_alloc() and/or allocating tasks are using
+__GFP_NOWARN flag and/or such lines are suppressed by ratelimiting and/or
+such lines are corrupted due to collisions.
+
+Unless we use asynchronous monitoring approach, we can fail to figure out
+that something went wrong inside memory allocation requests.
+
+People are reporting hang up problems and/or slowdown problem inside memory
+allocation request. But we are forcing people to use kernels without means
+to find out what was happening. The means are expected to work without
+knowledge to use trace points functionality, are expected to run without
+memory allocation, are expected to dump output without administrator's
+operation, are expected to work before watchdog timers reset the machine.
+
+This extension adds a state tracking mechanism for memory allocation requests
+to khungtaskd kernel thread, allowing administrators to figure out that the
+system hung up due to memory allocation stalls and/or to take administrator-
+controlled actions when memory allocation requests are stalling.
+
+
+- How to configure it?
+
+Build kernels with CONFIG_DETECT_HUNG_TASK=y and
+CONFIG_DETECT_MEMALLOC_STALL_TASK=y.
+
+Default scan interval is configured by CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT.
+Scan interval can be changed at run time by writing timeout in seconds to
+/proc/sys/kernel/memalloc_task_timeout_secs. Writing 0 disables this scan.
+
+Even if you disable this scan, information about last memory allocation
+request is kept. That is, you will get some hint for understanding
+last-minute behavior of the kernel when you analyze vmcore (or memory
+snapshot of a virtualized machine).
+
+
+- How memory allocation stalls are reported?
+
+This extension will report allocation stalls by printing
+
+  MemAlloc-Info: stalling=$X dying=$Y1 exiting=$Y2 victim=$Z oom_count=$O
+
+line where $X > 0, followed by
+
+  MemAlloc: $name($pid) flags=$flags switches=$switches $state_of_allocation $state_of_task
+
+lines and corresponding stack traces.
+
+$O is number of times the OOM killer is invoked. If $O does not increase
+over time, allocation requests got stuck before calling the OOM killer.
+
+$name is that task's comm name string ("struct task_struct"->comm).
+
+$pid is that task's pid value ("struct task_struct"->pid).
+
+$flags is that task's flags value ("struct task_struct"->flags).
+
+$switches is that task's context switch counter ("struct task_struct"->nvcsw +
+"struct task_struct"->nivcsw) which is also checked by
+/proc/sys/kernel/hung_task_warnings for finding hung tasks.
+
+$state_of_allocation is reported only when that task is stalling inside
+__alloc_pages_slowpath(), in seq=$seq gfp=$gfp order=$order delay=$delay
+format where $seq is the sequence number for allocation request, $gfp is
+the gfp flags used for that allocation request, $order is the order,
+delay is jiffies elapsed since entering into __alloc_pages_slowpath().
+
+You can check for seq=$seq field for each reported process. If $seq is
+increasing over time, it will be simply overloaded (not a livelock but
+progress is too slow to wait) unless the caller is doing open-coded
+__GFP_NOFAIL allocation requests (effectively a livelock).
+
+$state_of_task is reported only when that task is dying, in combination
+of "uninterruptible" (where that task is in uninterruptible sleep,
+likely due to uninterruptible lock), "exiting" (where that task arrived
+at do_exit() function), "dying" (where that task has pending SIGKILL)
+and "victim" (where that task received TIF_MEMDIE, likely be only 1 task).
+
+
+- How the messages look like?
+
+An example of MemAlloc lines (grep of dmesg output) is shown below.
+You can use serial console and/or netconsole to save these messages
+when the system is stalling.
+
+  [  100.503284] MemAlloc-Info: stalling=8 dying=1 exiting=0 victim=1 oom_count=101421
+  [  100.505674] MemAlloc: kswapd0(54) flags=0xa40840 switches=84685
+  [  100.546645] MemAlloc: kworker/3:1(70) flags=0x4208060 switches=9462 seq=5 gfp=0x2400000(GFP_NOIO) order=0 delay=8207 uninterruptible
+  [  100.606034] MemAlloc: systemd-journal(469) flags=0x400100 switches=8380 seq=212 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.651766] MemAlloc: irqbalance(998) flags=0x400100 switches=4366 seq=5 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=5819
+  [  100.697590] MemAlloc: vmtoolsd(1928) flags=0x400100 switches=8542 seq=82 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.743312] MemAlloc: tuned(3737) flags=0x400040 switches=8220 seq=44 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.792038] MemAlloc: nmbd(3759) flags=0x400140 switches=8079 seq=198 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.839428] MemAlloc: oom-write(3814) flags=0x400000 switches=8126 seq=223446 gfp=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=10620 uninterruptible
+  [  100.878846] MemAlloc: write(3816) flags=0x400000 switches=7440 uninterruptible dying victim
+  [  100.917971] MemAlloc: write(3820) flags=0x400000 switches=16130 seq=8714 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=10620 uninterruptible
+  [  101.190979] MemAlloc-Info: stalling=8 dying=1 exiting=0 victim=1 oom_count=107514
+  [  111.194055] MemAlloc-Info: stalling=9 dying=1 exiting=0 victim=1 oom_count=199825
+  [  111.196624] MemAlloc: kswapd0(54) flags=0xa40840 switches=168410
+  [  111.238096] MemAlloc: kworker/3:1(70) flags=0x4208060 switches=18592 seq=5 gfp=0x2400000(GFP_NOIO) order=0 delay=18898
+  [  111.296920] MemAlloc: systemd-journal(469) flags=0x400100 switches=15918 seq=212 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311
+  [  111.343129] MemAlloc: systemd-logind(973) flags=0x400100 switches=7786 seq=3 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10476
+  [  111.390142] MemAlloc: irqbalance(998) flags=0x400100 switches=11965 seq=5 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=16510
+  [  111.435170] MemAlloc: vmtoolsd(1928) flags=0x400100 switches=16230 seq=82 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311 uninterruptible
+  [  111.479089] MemAlloc: tuned(3737) flags=0x400040 switches=15850 seq=44 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311 uninterruptible
+  [  111.528294] MemAlloc: nmbd(3759) flags=0x400140 switches=15682 seq=198 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311
+  [  111.576371] MemAlloc: oom-write(3814) flags=0x400000 switches=15378 seq=223446 gfp=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=21311 uninterruptible
+  [  111.617562] MemAlloc: write(3816) flags=0x400000 switches=7440 uninterruptible dying victim
+  [  111.661662] MemAlloc: write(3820) flags=0x400000 switches=24334 seq=8714 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=21311 uninterruptible
+  [  111.956964] MemAlloc-Info: stalling=9 dying=1 exiting=0 victim=1 oom_count=206663
+
+You can check whether memory allocations are making forward progress.
+You can check where memory allocations are stalling using stack trace
+of reported task which follows each MemAlloc: line. You can check memory
+information (SysRq-m) and stuck workqueues information which follow the
+end of MemAlloc: lines. You can also check locks held (SysRq-d) if built
+with CONFIG_PROVE_LOCKING=y and lockdep is still active.
+
+This extension also serves as a hook for triggering actions when timeout
+expired. If you want to obtain more information, you can utilize dynamic
+probes using e.g. SystemTap. For example,
+
+  # stap -F -g -e 'probe kernel.function("check_memalloc_stalling_tasks").return { if ($return > 0) panic("MemAlloc stall detected."); }'
+
+will allow you to obtain vmcore by triggering the kernel panic. Since
+variables used by this extension is associated with "struct task_struct",
+you can obtain accurate snapshot using "foreach task" command from crash
+utility.
diff --git a/include/linux/oom.h b/include/linux/oom.h
index b4e36e9..69556f3 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -79,8 +79,12 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern unsigned int out_of_memory_count;
+extern bool memalloc_maybe_stalling(void);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_memalloc_task_timeout_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6aa5d8c..6e56317 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1496,6 +1496,32 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+struct memalloc_info {
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
+	 * bit 3: Will be reported as exiting task.
+	 * bit 7: Will be reported unconditionally.
+	 */
+	u8 type;
+	/* Index used for memalloc_in_flight[] counter. */
+	u8 idx;
+	/* For progress monitoring. */
+	unsigned int sequence;
+	/* Started time in jiffies as of valid == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of valid == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/*
@@ -1979,6 +2005,9 @@ struct task_struct {
 	/* A live task holds one reference. */
 	atomic_t stack_refcount;
 #endif
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index fd85c68..9d5ebd1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1621,6 +1621,10 @@ static __latent_entropy struct task_struct *copy_process(
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
index 40c07e4..df95a20 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,7 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/oom.h>
 #include <trace/events/sched.h>
 
 /*
@@ -72,6 +73,206 @@ static int __init hung_task_panic_setup(char *str)
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
+	/* timeout of 0 will disable the watchdog */
+	return timeout ? last_checked - jiffies + timeout * HZ :
+		MAX_SCHEDULE_TIMEOUT;
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
+	if (!m->valid)
+		return false;
+	memalloc.sequence = m->sequence;
+	memalloc.start = m->start;
+	memalloc.order = m->order;
+	memalloc.gfp = m->gfp;
+	return time_after_eq(expire, memalloc.start);
+}
+
+/*
+ * check_memalloc_stalling_tasks - Check for memory allocation stalls.
+ *
+ * @timeout: Timeout in jiffies.
+ *
+ * Returns number of stalling tasks.
+ *
+ * This function is marked as "noinline" in order to allow inserting dynamic
+ * probes (e.g. printing more information as needed using SystemTap, calling
+ * panic() if this function returned non 0 value).
+ */
+static noinline int check_memalloc_stalling_tasks(unsigned long timeout)
+{
+	char buf[256];
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long expire;
+	unsigned int sigkill_pending = 0;
+	unsigned int exiting_tasks = 0;
+	unsigned int memdie_pending = 0;
+	unsigned int stalling_tasks = 0;
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
+		if (p->flags & PF_KSWAPD)
+			type |= 128;
+		p->memalloc.type = type;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	if (!stalling_tasks)
+		return 0;
+	cond_resched();
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
+		out_of_memory_count);
+	cond_resched();
+	sigkill_pending = 0;
+	exiting_tasks = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
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
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
+				 memalloc.sequence, memalloc.gfp,
+				 &memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		} else {
+			buf[0] = '\0';
+		}
+		if (p->flags & PF_KSWAPD)
+			type |= 128;
+		if (unlikely(!type))
+			continue;
+		/*
+		 * Victim tasks get pending SIGKILL removed before arriving at
+		 * do_exit(). Therefore, print " exiting" instead for " dying".
+		 */
+		pr_warn("MemAlloc: %s(%u) flags=0x%x switches=%lu%s%s%s%s%s\n",
+			p->comm, p->pid, p->flags, p->nvcsw + p->nivcsw, buf,
+			(p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "",
+			(type & 8) ? " exiting" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+		sched_show_task(p);
+		/*
+		 * Since there could be thousands of tasks to report, we always
+		 * call cond_resched() after each report, in order to avoid RCU
+		 * stalls.
+		 *
+		 * Since not yet reported tasks have p->memalloc.type > 0, we
+		 * can simply restart this loop in case "g" or "p" went away.
+		 */
+		get_task_struct(g);
+		get_task_struct(p);
+		rcu_read_unlock();
+		preempt_enable_no_resched();
+		/*
+		 * TODO: Try to wait for a while (e.g. sleep until usage of
+		 * printk() buffer becomes less than 75%) in order to avoid
+		 * dropping messages.
+		 */
+		cond_resched();
+		preempt_disable();
+		rcu_read_lock();
+		can_cont = pid_alive(g) && pid_alive(p);
+		put_task_struct(p);
+		put_task_struct(g);
+		if (!can_cont)
+			goto restart_report;
+	}
+	rcu_read_unlock();
+	preempt_enable_no_resched();
+	cond_resched();
+	/* Show memory information. (SysRq-m) */
+	show_mem(0);
+	/* Show workqueue state. */
+	show_workqueue_state();
+	/* Show lock information. (SysRq-d) */
+	debug_show_all_locks();
+	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
+		out_of_memory_count);
+	return stalling_tasks;
+}
+#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
+
 static void check_hung_task(struct task_struct *t, unsigned long timeout)
 {
 	unsigned long switch_count = t->nvcsw + t->nivcsw;
@@ -228,20 +429,36 @@ void reset_hung_task_detector(void)
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
+			if (memalloc_maybe_stalling())
+				check_memalloc_stalling_tasks(timeout2);
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
index 39b3368..d96952d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1069,6 +1069,16 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
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
 #ifdef CONFIG_RT_MUTEXES
 	{
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index fd60ace..bcd2494 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -880,6 +880,30 @@ config WQ_WATCHDOG
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
+	default 60
+	help
+	  This option controls the default timeout (in seconds) used
+	  to determine when a task has become non-responsive and should
+	  be considered stalling inside memory allocator.
+
+	  It can be adjusted at runtime via the kernel.memalloc_task_timeout_secs
+	  sysctl or by writing a value to
+	  /proc/sys/kernel/memalloc_task_timeout_secs.
+
+	  A timeout of 0 disables the check. The default is 60 seconds.
+
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d..ab46d06 100644
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
@@ -986,6 +988,7 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	out_of_memory_count++;
 	if (oom_killer_disabled)
 		return false;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 806ada3..ae76920 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3548,8 +3548,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
+#endif
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3705,6 +3707,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask,
@@ -3712,6 +3715,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
 	}
+#endif
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
 				 did_some_progress > 0, &no_progress_loops))
@@ -3747,6 +3751,57 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+
+static DEFINE_PER_CPU_ALIGNED(int, memalloc_in_flight[2]);
+static u8 memalloc_active_index; /* Either 0 or 1. */
+
+/* Called periodically with sysctl_memalloc_task_timeout_secs interval. */
+bool memalloc_maybe_stalling(void)
+{
+	int cpu;
+	int sum = 0;
+	const u8 idx = memalloc_active_index ^ 1;
+
+	for_each_possible_cpu(cpu)
+		sum += per_cpu(memalloc_in_flight[idx], cpu);
+	if (sum)
+		return true;
+	memalloc_active_index ^= 1;
+	return false;
+}
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
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+		m->idx = memalloc_active_index;
+		this_cpu_inc(memalloc_in_flight[m->idx]);
+	}
+	m->valid++;
+}
+
+static void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	if ((gfp_mask & __GFP_RECLAIM) && !--m->valid)
+		this_cpu_dec(memalloc_in_flight[m->idx]);
+}
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3828,7 +3883,9 @@ struct page *
 	 */
 	if (cpusets_enabled())
 		ac.nodemask = nodemask;
+	start_memalloc_timer(alloc_mask, order);
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	stop_memalloc_timer(alloc_mask);
 
 no_zone:
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
