Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AE0196B0038
	for <linux-mm@kvack.org>; Wed, 31 Dec 2014 06:22:33 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so21206887pad.27
        for <linux-mm@kvack.org>; Wed, 31 Dec 2014 03:22:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id zc8si50109059pac.134.2014.12.31.03.22.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 31 Dec 2014 03:22:31 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
	<201412302233.HDD82379.FFtOJQVFOOHSML@I-love.SAKURA.ne.jp>
In-Reply-To: <201412302233.HDD82379.FFtOJQVFOOHSML@I-love.SAKURA.ne.jp>
Message-Id: <201412311924.AJB26029.MFOVFFOOQHJtSL@I-love.SAKURA.ne.jp>
Date: Wed, 31 Dec 2014 19:24:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

Tetsuo Handa wrote:
> > > where I think a.out cannot die within reasonable duration due to b.out .
> > 
> > I am not sure you can have any reasonable time expectation with such a
> > huge contention on a single file. Even killing the task manually would
> > take quite some time I suspect. Sure, memory pressure makes it all much
> > worse.
> 
> Not specific to OOM-killer case, but I wish that the stall ends within 10
> seconds, for my customers are using watchdog timeout of 11 seconds with
> watchdog keep-alive interval of 2 seconds.
> 
> I wish that there is a way to record that the process who is supposed to do
> watchdog keep-alive operation was unexpectedly blocked for many seconds at
> memory allocation. My gfp_start patch works for that purpose.
> 
> > > but I think we need to be prepared for cases where sending SIGKILL to
> > > all threads sharing the same memory does not help.
> > 
> > Sure, unkillable tasks are a problem which we have to handle. Having
> > GFP_KERNEL allocations looping without way out contributes to this which
> > is sad but your current data just show that sometimes it might take ages
> > to finish even without that going on.
> 
> Can't we replace mutex_lock() / wait_for_completion() with killable versions
> where it is safe (in order to reduce locations of unkillable waits)?
> I think replacing mutex_lock() in xfs_file_buffered_aio_write() with killable
> version is possible because data written by buffered write is not guaranteed
> to be flushed until sync() / fsync() / fdatasync() returns.
> 
> And can't we detect unkillable TIF_MEMDIE tasks (like checking task's ->state
> after a while after TIF_MEMDIE was set)? My sysctl_memdie_timeout_jiffies
> patch works for that purpose.
> 

I was testing below patch on current linux.git tree. To my surprise, I can no
longer reproduce "stall by a.out + b.out" because setting TIF_MEMDIE to all
threads sharing the same memory (without granting access to memory reserves)
made it possible to solve the stalled state immediately (console log is at
http://I-love.SAKURA.ne.jp/tmp/serial-20141231-ab.txt.xz ). Given that
low-order (<=PAGE_ALLOC_COSTLY_ORDER) allocations are allowed to fail
immediately upon OOM, maybe we can let ongoing memory allocations fail
without granting access to memory reserves?
----------------------------------------
>From 9212fb2bc96579c0dd0e1f121f5c089c683e12c0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 31 Dec 2014 17:50:24 +0900
Subject: [RFC PATCH] oom: Introduce sysctl-tunable MEMDIE timeout.

When there is a thread with TIF_MEMDIE flag set, the OOM killer is
disabled. However, a victim process containing that thread could get
stuck due to dependency which is invisible to the OOM killer. As a
result, the system will stall for unpredictable duration because the
OOM killer is kept disabled when one of threads in the victim process
got stuck. This situation is easily reproduced by multi-threaded
programs where thread1 tries to allocate memory whereas thread2 tries
to perform file I/O operation. The OOM killer sets TIF_MEMDIE flag to
only thread1, but the threads which really needs TIF_MEMDIE flag which
is blocking thread2 via unkillable wait (e.g. mutex_lock() for
"struct inode"->i_mutex) can be thread3 doing memory allocation. And
the thread3 can be outside of the victim process containing thread1.

But in order to avoid depletion of memory reserves via TIF_MEMDIE flag,
we don't want to set TIF_MEMDIE flag to all threads which might be
preventing thread2 to terminate. Moreover, we can't know which threads
are holding the lock which thread2 depends on.

While converting unkillable waits (e.g. mutex_lock()) to killable waits
(e.g. mutex_lock_killable()) helps thread2 to die quickly (not only
SIGKILL by the OOM killer but also SIGKILL by user's operations), we
can't afford converting all unkillable waits. So, we want to be prepared
for unkillable threads anyway.

This patch does the following things.

  (1) Let ongoing memory allocation fail without accessing to memory
      reserves via TIF_MEMDIE flag.
  (2) Let the OOM killer set TIF_MEMDIE flag to all threads sharing
      the same memory.
  (3) Let the OOM killer record current time as of setting TIF_MEMDIE
      flag.
  (4) Let the OOM killer treat threads which did not die within
      sysctl-tunable timeout as unkillable.

We can avoid depletion of memory reserves via TIF_MEMDIE flag by (1).
While (1) might retard termination of thread1 when allowing access to
memory reserves helps the victim process containing thread1 to die
quickly, (4) will prevent thread1 from being unable to die forever by
killing other threads after timeout.

If the OOM killer cannot find threads to kill after timeout, something
is absolutely wrong. Therefore, kernel panic followed by automatic
reboot (with kdump as optional for analyzing the cause) should be OK.

(4) introduces /proc/sys/vm/memdie_task_{skip|panic}_secs interfaces
which control timeout for waiting for the threads with TIF_MEMDIE flag
set. When timeout expired, the former enables the OOM killer again and
the latter triggers kernel panic.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  3 ++
 include/linux/sched.h |  1 +
 kernel/cpuset.c       |  5 ++--
 kernel/exit.c         |  1 +
 kernel/sysctl.c       | 19 +++++++++++++
 mm/oom_kill.c         | 77 ++++++++++++++++++++++++++++++++++++++++++++-------
 mm/page_alloc.c       |  4 +--
 7 files changed, 95 insertions(+), 15 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 853698c..642e4ae 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -68,6 +68,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
 
+extern bool is_killable_memdie_task(struct task_struct *p);
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);
@@ -107,4 +108,6 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_memdie_task_skip_secs;
+extern unsigned long sysctl_memdie_task_panic_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef..58ad56a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1701,6 +1701,7 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+	unsigned long memdie_start;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 64b257f..aea9d712 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -35,6 +35,7 @@
 #include <linux/kmod.h>
 #include <linux/list.h>
 #include <linux/mempolicy.h>
+#include <linux/oom.h>
 #include <linux/mm.h>
 #include <linux/memory.h>
 #include <linux/export.h>
@@ -1008,7 +1009,7 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
+	if (unlikely(is_killable_memdie_task(current)))
 		return;
 	if (current->flags & PF_EXITING) /* Let dying task have memory */
 		return;
@@ -2515,7 +2516,7 @@ int __cpuset_node_allowed(int node, gfp_t gfp_mask)
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
+	if (unlikely(is_killable_memdie_task(current)))
 		return 1;
 	if (gfp_mask & __GFP_HARDWALL)	/* If hardwall request, stop here */
 		return 0;
diff --git a/kernel/exit.c b/kernel/exit.c
index 1ea4369..de5efe5 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -436,6 +436,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	clear_thread_flag(TIF_MEMDIE);
+	current->memdie_start = 0;
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 137c7f6..dab9b31 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -145,6 +145,9 @@ static const int cap_last_cap = CAP_LAST_CAP;
 static unsigned long hung_task_timeout_max = (LONG_MAX/HZ);
 #endif
 
+/* Used by proc_doulongvec_minmax of sysctl_memdie_task_*_secs */
+static unsigned long memdie_task_timeout_max = (LONG_MAX/HZ);
+
 #ifdef CONFIG_INOTIFY_USER
 #include <linux/inotify.h>
 #endif
@@ -1502,6 +1505,22 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname	= "memdie_task_skip_secs",
+		.data		= &sysctl_memdie_task_skip_secs,
+		.maxlen		= sizeof(sysctl_memdie_task_skip_secs),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra2		= &memdie_task_timeout_max,
+	},
+	{
+		.procname	= "memdie_task_panic_secs",
+		.data		= &sysctl_memdie_task_panic_secs,
+		.maxlen		= sizeof(sysctl_memdie_task_panic_secs),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra2		= &memdie_task_timeout_max,
+	},
 	{ }
 };
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..dbff730 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,8 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
+unsigned long sysctl_memdie_task_skip_secs;
+unsigned long sysctl_memdie_task_panic_secs;
 
 #ifdef CONFIG_NUMA
 /**
@@ -117,6 +119,61 @@ found:
 	return t;
 }
 
+/**
+ * set_memdie_flag - set TIF_MEMDIE flag and record current time.
+ * @p: Pointer to "struct task_struct".
+ */
+static void set_memdie_flag(struct task_struct *p)
+{
+	/* For avoiding race condition, current time must not be 0. */
+	if (!p->memdie_start) {
+		const unsigned long start = jiffies;
+
+		p->memdie_start = start ? start : 1;
+	}
+	set_tsk_thread_flag(p, TIF_MEMDIE);
+}
+
+/**
+ * is_killable_memdie_task - check task is not stuck with TIF_MEMDIE flag set.
+ * @p: Pointer to "struct task_struct".
+ *
+ * Setting TIF_MEMDIE flag to @p disables the OOM killer. However, @p could get
+ * stuck due to dependency which is invisible to the OOM killer. When @p got
+ * stuck, the system will stall for unpredictable duration (presumably forever)
+ * because the OOM killer is kept disabled.
+ *
+ * If @p remained stuck for /proc/sys/vm/memdie_task_skip_secs seconds, this
+ * function returns false as if TIF_MEMDIE flag was not set to @p. As a result,
+ * the OOM killer will try to find other killable processes at the risk of
+ * kernel panic when there is no other killable processes.
+ * If @p remained stuck for /proc/sys/vm/memdie_task_panic_secs seconds, this
+ * function triggers kernel panic (for optionally taking vmcore for analysis).
+ * Setting 0 to these interfaces disables this check.
+ */
+bool is_killable_memdie_task(struct task_struct *p)
+{
+	unsigned long start, timeout;
+
+	/* If task does not have TIF_MEMDIE flag, there is nothing to do.*/
+	if (!test_tsk_thread_flag(p, TIF_MEMDIE))
+		return false;
+	/* Handle cases where TIF_MEMDIE was set outside of this file. */
+	start = p->memdie_start;
+	if (!start) {
+		set_memdie_flag(p);
+		return true;
+	}
+	/* Trigger kernel panic after timeout. */
+	timeout = sysctl_memdie_task_panic_secs;
+	if (timeout && time_after(jiffies, start + timeout * HZ))
+		panic("Out of memory: %s (%d) did not die within %lu seconds.\n",
+		      p->comm, p->pid, timeout);
+	/* Return true before timeout. */
+	timeout = sysctl_memdie_task_skip_secs;
+	return !timeout || time_before(jiffies, start + timeout * HZ);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -134,7 +191,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
-	return false;
+	return is_killable_memdie_task(p);
 }
 
 /**
@@ -439,7 +496,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (task_will_free_mem(p)) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
+		set_memdie_flag(p);
 		put_task_struct(p);
 		return;
 	}
@@ -500,12 +557,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * any. This mitigates mm->mmap_sem livelock when an oom killed thread
+	 * cannot exit because it requires the semaphore and its contended by
+	 * another thread trying to allocate memory itself. Note that this does
+	 * not help if the contended process does not share victim->mm. In that
+	 * case, is_killable_memdie_task() will detect it and take actions.
 	 */
 	rcu_read_lock();
 	for_each_process(p)
@@ -518,11 +574,12 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
+			set_memdie_flag(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 		}
 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	set_memdie_flag(victim);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
@@ -645,7 +702,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		set_thread_flag(TIF_MEMDIE);
+		set_memdie_flag(current);
 		return;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..3799139 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2603,9 +2603,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
