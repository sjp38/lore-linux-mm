Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9267D82F64
	for <linux-mm@kvack.org>; Sun, 18 Oct 2015 08:05:52 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so38888288igb.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 05:05:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 84si11544882ioh.110.2015.10.18.05.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 05:05:51 -0700 (PDT)
Subject: [RFC][PATCH] Memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp>
Date: Sun, 18 Oct 2015 21:05:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, mhocko@kernel.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

>From e07c200277cdb8e46aa754d3b980b02ab727cb80 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 18 Oct 2015 20:28:45 +0900
Subject: [PATCH] Memory allocation watchdog kernel thread.

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

line where $X > 0 and $Y > 0 and $Z > 0, followed by $X lines of

  MemAlloc: $name($pid) gfp=$gfp order=$order delay=$delay

where $name and $pid are comm name and pid of a task which is stalling
inside __alloc_pages_slowpath(), $gfp is the gfp flags used for that
allocation request, $order is the order, delay is jiffies elapsed since
entering into __alloc_pages_slowpath(), and $Y lines of

  MemAlloc: $name($pid) $state_of_task

where $state_of_task is combination of "uninterruptible" (where that task
is in uninterruptible sleep, likely due to uninterruptible lock), "dying"
(where that task has pending SIGKILL, should be always included) and
"victim" (where that task received TIF_MEMDIE, likely be only 1 task).
In addition, stack trace of stalling tasks and dying tasks follows
as with khungtaskd.

The latter case has two possibilities. One possibility is that all ongoing
memory allocation requests are !__GFP_FS && !__GFP_NOFAIL, which does not
invoke the OOM killer. The other possibility is that at least one task is
doing __GFP_FS || __GFP_NOFAIL memory allocation request but operation for
reclaiming memory is not working as expected due to unknown reason, which
will not invoke the OOM killer. This kernel thread will report such
situation by printing

  MemAlloc-Info: $X stalling task, $Y dying task, 0 victim task.

line where $X > 0 and $Y >= 0, followed by $X lines of

  MemAlloc: $name($pid) gfp=$gfp order=$order delay=$delay

and $Y lines of

  MemAlloc: $name($pid) $state_of_task

followed by their stack traces.


An example of MemAlloc lines is shown below.

  [  212.372846] MemAlloc-Info: 4 stalling task, 9 dying task, 1 victim task.
  [  212.374782] MemAlloc: oom-tester4(11516) gfp=0x242014a order=0 delay=10364
  [  212.376626] MemAlloc: systemd-journal(466) gfp=0x242014a order=0 delay=10359
  [  212.378505] MemAlloc: oom-tester4(11511) gfp=0x24280ca order=0 delay=10318
  [  212.380337] MemAlloc: vmtoolsd(1899) gfp=0x242014a order=0 delay=10317
  [  212.382182] MemAlloc: oom-tester4(11512) uninterruptible dying victim
  [  212.383928] MemAlloc: oom-tester4(11514) uninterruptible dying
  [  212.385551] MemAlloc: oom-tester4(11515) uninterruptible dying
  [  212.387170] MemAlloc: oom-tester4(11516) dying
  [  212.388516] MemAlloc: oom-tester4(11517) uninterruptible dying
  [  212.390117] MemAlloc: oom-tester4(11519) uninterruptible dying
  [  212.391817] MemAlloc: oom-tester4(11520) uninterruptible dying
  [  212.393411] MemAlloc: oom-tester4(11521) uninterruptible dying
  [  212.394997] MemAlloc: oom-tester4(11522) uninterruptible dying

Without this kernel thread, it is extremely hard to figure out that
the system hung up due to memory allocation stalls because the
"%s invoked oom-killer: gfp_mask=0x%x, order=%d, ""oom_score_adj=%hd\n"
line is not printed for several corner cases in the former case and is
never printed in the latter case, resulting in completely silent hangups.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/Kconfig      |  25 +++++++
 mm/page_alloc.c | 209 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 234 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06..9642670 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -668,3 +668,28 @@ config ZONE_DEVICE
 
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
+	  stall warnings in between 30 and 60 seconds, and emit subsequent
+	  warnings in 30 seconds.
+
+	  While performance penalty carried by using this option is small,
+	  this option can be disabled by passing kmallocwd=0 boot parameter.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9c1341..a4ac1ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -62,6 +62,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/nmi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2999,6 +3000,210 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
  */
 #define MAX_STALL_BACKOFF 16
 
+#ifdef CONFIG_MEMALLOC_WATCHDOG
+
+static unsigned long kmallocwd_timeout = 10 * HZ; /* Scan interval. */
+static u8 memalloc_counter_active_index; /* Either 0 or 1. */
+static int memalloc_counter[2]; /* Number of tasks doing memory allocation. */
+
+struct memalloc {
+	struct list_head list; /* Connected to memalloc_list. */
+	struct task_struct *task; /* Iniatilized to current. */
+	unsigned long start; /* Initialized to jiffies. */
+	unsigned int order;
+	gfp_t gfp;
+	u8 index; /* Initialized to memalloc_counter_active_index. */
+	u8 dumped;
+};
+
+static LIST_HEAD(memalloc_list); /* List of "struct memalloc".*/
+static DEFINE_SPINLOCK(memalloc_list_lock); /* Lock for memalloc_list. */
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
+	struct memalloc *m;
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+	u8 index;
+
+ not_stalling: /* Healty case. */
+	/* Switch active counter and wait for timeout duration. */
+	index = memalloc_counter_active_index;
+	spin_lock(&memalloc_list_lock);
+	memalloc_counter_active_index ^= 1;
+	spin_unlock(&memalloc_list_lock);
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	/*
+	 * If memory allocations are working, the counter should remain 0
+	 * because tasks will be able to call both start_memalloc_timer()
+	 * and stop_memalloc_timer() within timeout duration.
+	 */
+	if (likely(!memalloc_counter[index]))
+		goto not_stalling;
+ maybe_stalling: /* Maybe something is wrong. Let's check. */
+	now = jiffies;
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_after(now - m->start, kmallocwd_timeout))
+			stalling_tasks++;
+	}
+	spin_unlock(&memalloc_list_lock);
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			memdie_pending++;
+		if (fatal_signal_pending(p))
+			sigkill_pending++;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	/* Report stalling tasks, dying and victim tasks. */
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_before(now - m->start, kmallocwd_timeout))
+			continue;
+		p = m->task;
+		pr_warn("MemAlloc: %s(%u) gfp=0x%x order=%u delay=%lu\n",
+			p->comm, p->pid, m->gfp, m->order, now - m->start);
+	}
+	spin_unlock(&memalloc_list_lock);
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			type |= 1;
+		if (fatal_signal_pending(p))
+			type |= 2;
+		if (likely(!type))
+			continue;
+		if (p->state & TASK_UNINTERRUPTIBLE)
+			type |= 4;
+		pr_warn("MemAlloc: %s(%u)%s%s%s\n", p->comm, p->pid,
+			(type & 4) ? " uninterruptible" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	/*
+	 * Show traces of newly reported (or too long) stalling tasks.
+	 *
+	 * Show traces only once per 256 timeouts because their traces
+	 * will likely be the same (e.g. cond_sched() or congestion_wait())
+	 * when they are stalling inside __alloc_pages_slowpath().
+	 */
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_before(now - m->start, kmallocwd_timeout) ||
+		    m->dumped++)
+			continue;
+		p = m->task;
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		touch_nmi_watchdog();
+	}
+	spin_unlock(&memalloc_list_lock);
+	/*
+	 * Show traces of dying tasks (including victim tasks).
+	 *
+	 * Only dying tasks which are in trouble (e.g. blocked at unkillable
+	 * locks held by memory allocating tasks) will be repeatedly shown.
+	 * Therefore, we need to pay attention to tasks repeatedly shown here.
+	 */
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (likely(!fatal_signal_pending(p)))
+			continue;
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		touch_nmi_watchdog();
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	/* Wait until next timeout duration. */
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	if (memalloc_counter[index])
+		goto maybe_stalling;
+	goto not_stalling;
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
+#define DEFINE_MEMALLOC_TIMER(m) struct memalloc m = { .task = NULL }
+
+static void start_memalloc_timer(struct memalloc *m, const gfp_t gfp_mask,
+				 const int order)
+{
+	if (!kmallocwd_timeout || m->task)
+		return;
+	m->task = current;
+	m->start = jiffies;
+	m->gfp = gfp_mask;
+	m->order = order;
+	m->dumped = 0;
+	spin_lock(&memalloc_list_lock);
+	m->index = memalloc_counter_active_index;
+	memalloc_counter[m->index]++;
+	list_add_tail(&m->list, &memalloc_list);
+	spin_unlock(&memalloc_list_lock);
+}
+
+static void stop_memalloc_timer(struct memalloc *m)
+{
+	if (!m->task)
+		return;
+	spin_lock(&memalloc_list_lock);
+	memalloc_counter[m->index]--;
+	list_del(&m->list);
+	spin_unlock(&memalloc_list_lock);
+}
+#else
+#define DEFINE_MEMALLOC_TIMER(m)
+#define start_memalloc_timer(m, gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(m) do { } while (0)
+#endif
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -3013,6 +3218,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zone *zone;
 	struct zoneref *z;
 	int stall_backoff = 0;
+	DEFINE_MEMALLOC_TIMER(m);
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3104,6 +3310,8 @@ retry:
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
+	start_memalloc_timer(&m, gfp_mask, order);
+
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
@@ -3236,6 +3444,7 @@ noretry:
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
+	stop_memalloc_timer(&m);
 	return page;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
