Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E32026B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 04:59:10 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z125so127538898itc.12
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 01:59:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i127si7807791ita.72.2017.06.04.01.59.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 01:59:08 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
	<CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
In-Reply-To: <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
Message-Id: <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
Date: Sun, 4 Jun 2017 17:58:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xiyou.wangcong@gmail.com
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Cong Wang wrote:
> Just FYI: it is not us who picks those numbers, they are in the LTP test
> memcg_stress_test.sh.

I see. No problem as long as 0.5GB per a memcg and 150 memcg groups
parts are correct.

> > but it is also possible that
> >
> >   (b) Cong is reporting an unnoticed bug in the MM subsystem
> >
>
> I suppose so when I report the warning, unless commit
> 63f53dea0c9866e93802d50a230c460a024 is a false alarm. ;)

63f53dea0c9866e9 is really a half-baked troublesome alarm. :-(

It has failed to alarm for more than 30+ minutes (won't be fixed),
it is failing to alarm forever (not yet fixed), it has failed to
alarm __GFP_NOWARN allocations (fixed in 4.12-rc1), it is still
failing to print all possibly relevant threads (not yet fixed) etc.

I can't expect that users find more than "something went wrong" from
this alarm. You might have found a memcg related MM problem, but you
are a victim who failed to find more than "the kernel got soft lockup
due to parallel dump_stack() calls by this alarm".

>
> If I understand that commit correctly, it warns that we spend too
> much time on retrying and make no progress on the mm allocator
> slow path, which clearly indicates some problem.

Yes, but it is far from reliable, and it won't become reliable.

>
> But I thought it is obvious we should OOM instead of hanging
> somewhere in this situation? (My mm knowledge is very limited.)

Yes, I think that your system should have invoked the OOM killer,
though my MM knowledge is very limited as well.

>
>
> > as well as
> >
> >   (c) Cong is reporting a bug which does not exist in the latest
> >       linux-next kernel
> >
>
> As I already mentioned in my original report, I know there are at least
> two similar warnings reported before:
>
> https://lkml.org/lkml/2016/12/13/529
> https://bugzilla.kernel.org/show_bug.cgi?id=192981
>
> I don't see any fix, nor I see they are similar to mine.

No means for analyzing, no plan for fixing the problems.

> >>> When memory allocation request is stalling, serialization via waiting
> >>> for a lock does help.
> >>
> >> Which will mean that those unlucky ones which stall will stall even more
> >> because they will wait on a lock with potentially many others. While
> >> this certainly is a throttling mechanism it is also a big hammer.
> >
> > According to my testing, the cause of stalls with flooding of printk() from
> > warn_alloc() is exactly the lack of enough CPU time because the page
> > allocator continues busy looping when memory allocation is stalling.
> >
>
> In the retry loop, warn_alloc() is only called after stall is detected, not
> before, therefore waiting on the mutex does not contribute to at least
> the first stall.

Right, but waiting on the mutex inside warn_alloc() cannot yield enough
CPU time for allowing log_buf readers to write to consoles.

> > Andrew Morton wrote:
> >> I'm thinking we should serialize warn_alloc anyway, to prevent the
> >> output from concurrent calls getting all jumbled together?
> >
> > Yes. According to my testing, serializing warn_alloc() can not yield
> > enough CPU time because warn_alloc() is called only once per 10 seconds.
> > Serializing
> >
> > -       if (!mutex_trylock(&oom_lock)) {
> > +       if (mutex_lock_killable(&oom_lock)) {
> >
> > in __alloc_pages_may_oom() can yield enough CPU time to solve the stalls.
> >
>
> For this point, I am with you, it would be helpful to serialize them in
> case we mix different warnings in dmesg. But you probably need to adjust
> the timestamps in case waiting on the mutex contributes to the stall too?

As long as Michal refuses serialization, we won't get helpful output.
You can retry with my kmallocwd patch shown bottom. An example output is
at http://I-love.SAKURA.ne.jp/tmp/sample-serial.log .

Of course, kmallocwd can gather only basic information. You might need to
gather more information by e.g. enabling tracepoints after analyzing basic
information.

>
> [...]
>
> > This result shows that the OOM killer was not able to send SIGKILL until
> > I gave up waiting and pressed SysRq-i because __alloc_pages_slowpath() continued
> > wasting CPU time after the OOM killer tried to start printing memory information.
> > We can avoid this case if we wait for oom_lock at __alloc_pages_may_oom().
> >
>
> Note, in my case OOM killer was probably not even invoked although
> the log I captured is a complete one...

Since you said

  The log I sent is partial, but that is already all what we captured,
  I can't find more in kern.log due to log rotation.

you meant "the log I captured is an incomplete one", don't you?

Under memory pressure, we can't expect printk() output (as well as tracepoint
output) to be flushed to log files on a storage because writing to a file
involves memory allocation. Therefore, you can try serial console or netconsole
for saving printk() output more reliably than log files.

Some hardware uses horribly slow / unreliable serial device. In that case
netconsole would be better. If you use netconsole, you can use a utility
I wrote for receiving netconsole messages available at
https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/ .
This utility can concatenate pr_cont() output heavily used in MM subsystem
with one timestamp per a line.

Below is kmallocwd patch backpoated for 4.9.30 kernel from
http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
Documentation/malloc-watchdog.txt part is stripped in order to reduce lines.



 include/linux/gfp.h   |    8 +
 include/linux/oom.h   |    4
 include/linux/sched.h |   19 ++++
 kernel/fork.c         |    4
 kernel/hung_task.c    |  216 +++++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sysctl.c       |   10 ++
 lib/Kconfig.debug     |   24 +++++
 mm/mempool.c          |    9 +-
 mm/oom_kill.c         |    3
 mm/page_alloc.c       |   82 ++++++++++++++++++
 10 files changed, 377 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de..cd4253f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -460,6 +460,14 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+extern void start_memalloc_timer(const gfp_t gfp_mask, const int order);
+extern void stop_memalloc_timer(const gfp_t gfp_mask);
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
index b4e36e9..8487d1b 100644
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
+extern unsigned long sysctl_memalloc_task_warning_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f425eb3..5d48ecb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1472,6 +1472,22 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+struct memalloc_info {
+	/* Is current thread doing (nested) memory allocation? */
+	u8 in_flight;
+	/* Watchdog kernel thread is about to report this task? */
+	bool report;
+	/* Index used for memalloc_in_flight[] counter. */
+	u8 idx;
+	/* For progress monitoring. */
+	unsigned int sequence;
+	/* Started time in jiffies as of in_flight == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of in_flight == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/*
@@ -1960,6 +1976,9 @@ struct task_struct {
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
index 59faac4..8c2aef2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1624,6 +1624,10 @@ static __latent_entropy struct task_struct *copy_process(
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
index 2b59c82..b6ce9a3 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,8 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/oom.h>
+#include <linux/console.h>
 #include <trace/events/sched.h>
 
 /*
@@ -141,6 +143,8 @@ static bool rcu_lock_break(struct task_struct *g, struct task_struct *t)
 	get_task_struct(g);
 	get_task_struct(t);
 	rcu_read_unlock();
+	if (console_trylock())
+		console_unlock();
 	cond_resched();
 	rcu_read_lock();
 	can_cont = pid_alive(g) && pid_alive(t);
@@ -193,6 +197,200 @@ static long hung_timeout_jiffies(unsigned long last_checked,
 		MAX_SCHEDULE_TIMEOUT;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+/*
+ * Zero means infinite timeout - no checking done:
+ */
+unsigned long __read_mostly sysctl_memalloc_task_warning_secs =
+	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
+
+/* Filled by is_stalling_task(), used by only khungtaskd kernel thread. */
+static struct memalloc_info memalloc;
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
+	if (likely(!m->in_flight || !time_after_eq(expire, m->start)))
+		return false;
+	/*
+	 * start_memalloc_timer() guarantees that ->in_flight is updated after
+	 * ->start is stored.
+	 */
+	smp_rmb();
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
+	enum {
+		MEMALLOC_TYPE_STALLING,       /* Report as stalling task. */
+		MEMALLOC_TYPE_DYING,          /* Report as dying task. */
+		MEMALLOC_TYPE_EXITING,        /* Report as exiting task.*/
+		MEMALLOC_TYPE_OOM_VICTIM,     /* Report as OOM victim. */
+		MEMALLOC_TYPE_UNCONDITIONAL,  /* Report unconditionally. */
+	};
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
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		bool report = false;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			report = true;
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			report = true;
+			sigkill_pending++;
+		}
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			report = true;
+			exiting_tasks++;
+		}
+		if (is_stalling_task(p, expire)) {
+			report = true;
+			stalling_tasks++;
+		}
+		if (p->flags & PF_KSWAPD)
+			report = true;
+		p->memalloc.report = report;
+	}
+	rcu_read_unlock();
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
+	rcu_read_lock();
+ restart_report:
+	for_each_process_thread(g, p) {
+		u8 type;
+
+		if (likely(!p->memalloc.report))
+			continue;
+		p->memalloc.report = false;
+		/* Recheck in case state changed meanwhile. */
+		type = 0;
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			type |= (1 << MEMALLOC_TYPE_OOM_VICTIM);
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			type |= (1 << MEMALLOC_TYPE_DYING);
+			sigkill_pending++;
+		}
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			type |= (1 << MEMALLOC_TYPE_EXITING);
+			exiting_tasks++;
+		}
+		if (is_stalling_task(p, expire)) {
+			type |= (1 << MEMALLOC_TYPE_STALLING);
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
+			type |= (1 << MEMALLOC_TYPE_UNCONDITIONAL);
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
+			(type & (1 << MEMALLOC_TYPE_EXITING)) ?
+			" exiting" : "",
+			(type & (1 << MEMALLOC_TYPE_DYING)) ? " dying" : "",
+			(type & (1 << MEMALLOC_TYPE_OOM_VICTIM)) ?
+			" victim" : "");
+		sched_show_task(p);
+		/*
+		 * Since there could be thousands of tasks to report, we always
+		 * call cond_resched() after each report, in order to avoid RCU
+		 * stalls.
+		 *
+		 * Since not yet reported tasks are marked as
+		 * p->memalloc.report == T, this loop can restart even if
+		 * "g" or "p" went away.
+		 *
+		 * TODO: Try to wait for a while (e.g. sleep until usage of
+		 * printk() buffer becomes less than 75%) in order to avoid
+		 * dropping messages.
+		 */
+		if (!rcu_lock_break(g, p))
+			goto restart_report;
+	}
+	rcu_read_unlock();
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
 /*
  * Process updating of timeout sysctl
  */
@@ -227,12 +425,28 @@ void reset_hung_task_detector(void)
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
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+		unsigned long timeout2 = sysctl_memalloc_task_warning_secs;
+		long t2 = hung_timeout_jiffies(stall_last_checked, timeout2);
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
@@ -240,7 +454,7 @@ static int watchdog(void *dummy)
 			hung_last_checked = jiffies;
 			continue;
 		}
-		schedule_timeout_interruptible(t);
+		schedule_timeout_interruptible(min(t, t2));
 	}
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c1095cd..d8ee12a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1083,6 +1083,16 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &neg_one,
 	},
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	{
+		.procname	= "memalloc_task_warning_secs",
+		.data		= &sysctl_memalloc_task_warning_secs,
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
index a6c8db1..54e8da0 100644
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
+	  It can be adjusted at runtime via the kernel.memalloc_task_warning_secs
+	  sysctl or by writing a value to
+	  /proc/sys/kernel/memalloc_task_warning_secs.
+
+	  A timeout of 0 disables the check. The default is 60 seconds.
+
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/mempool.c b/mm/mempool.c
index 47a659d..8b449af 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -324,11 +324,14 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
+	start_memalloc_timer(gfp_temp, -1);
 repeat_alloc:
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
-	if (likely(element != NULL))
+	if (likely(element != NULL)) {
+		stop_memalloc_timer(gfp_temp);
 		return element;
+	}
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
@@ -341,6 +344,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(element);
+		stop_memalloc_timer(gfp_temp);
 		return element;
 	}
 
@@ -350,13 +354,16 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	 */
 	if (gfp_temp != gfp_mask) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		gfp_temp = gfp_mask;
+		start_memalloc_timer(gfp_temp, -1);
 		goto repeat_alloc;
 	}
 
 	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		return NULL;
 	}
 
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
index 5b06fb3..de24961 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3507,8 +3507,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries;
 	int no_progress_loops;
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
+#endif
 	unsigned int cpuset_mems_cookie;
 
 	/*
@@ -3682,6 +3684,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask,
@@ -3689,6 +3692,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
 	}
+#endif
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
 				 did_some_progress > 0, &no_progress_loops))
@@ -3741,6 +3745,76 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+
+static DEFINE_PER_CPU_ALIGNED(int, memalloc_in_flight[2]);
+static u8 memalloc_active_index; /* Either 0 or 1. */
+
+/* Called periodically with sysctl_memalloc_task_warning_secs interval. */
+bool memalloc_maybe_stalling(void)
+{
+	int cpu;
+	int sum = 0;
+	const u8 idx = memalloc_active_index ^ 1;
+
+	for_each_online_cpu(cpu)
+		sum += per_cpu(memalloc_in_flight[idx], cpu);
+	if (sum)
+		return true;
+	memalloc_active_index ^= 1;
+	return false;
+}
+
+void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_DIRECT_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return;
+	/* Record the beginning of memory allocation request. */
+	if (!m->in_flight) {
+		m->sequence++;
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+		m->idx = memalloc_active_index;
+		/*
+		 * is_stalling_task() depends on ->in_flight being updated
+		 * after ->start is stored.
+		 */
+		smp_wmb();
+		this_cpu_inc(memalloc_in_flight[m->idx]);
+	}
+	m->in_flight++;
+}
+
+void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !--m->in_flight)
+		this_cpu_dec(memalloc_in_flight[m->idx]);
+}
+
+static void memalloc_counter_fold(int cpu)
+{
+	int counter;
+	u8 idx;
+
+	for (idx = 0; idx < 2; idx++) {
+		counter = per_cpu(memalloc_in_flight[idx], cpu);
+		if (!counter)
+			continue;
+		this_cpu_add(memalloc_in_flight[idx], counter);
+		per_cpu(memalloc_in_flight[idx], cpu) = 0;
+	}
+}
+
+#else
+#define memalloc_counter_fold(cpu) do { } while (0)
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3825,7 +3899,9 @@ struct page *
 	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
 
+	start_memalloc_timer(alloc_mask, order);
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	stop_memalloc_timer(alloc_mask);
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
@@ -6551,6 +6627,12 @@ static int page_alloc_cpu_notify(struct notifier_block *self,
 		 * race with what we are doing.
 		 */
 		cpu_vm_stats_fold(cpu);
+
+		/*
+		 * Zero the in-flight counters of the dead processor so that
+		 * memalloc_maybe_stalling() needs to check only online processors.
+		 */
+		memalloc_counter_fold(cpu);
 	}
 	return NOTIFY_OK;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
