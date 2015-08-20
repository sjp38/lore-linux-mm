Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2936B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 17:00:41 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so27594384pac.2
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 14:00:40 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ql4si7512018pac.187.2015.08.20.14.00.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 14:00:39 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so27593720pac.2
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 14:00:38 -0700 (PDT)
Date: Thu, 20 Aug 2015 14:00:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On system oom, a process may fail to exit if its thread depends on a lock
held by another allocating process.

In this case, we can detect an oom kill livelock that requires memory
allocation to be successful to resolve.

This patch introduces an oom expiration, set to 5s, that defines how long
a thread has to exit after being oom killed.

When this period elapses, it is assumed that the thread cannot make
forward progress without help.  The only help the VM may provide is to
allow pending allocations to succeed, so it grants all allocators access
to memory reserves after reclaim and compaction have failed.

This patch does not allow global access to memory reserves on memcg oom
kill, but the functionality is there if extended.

An example livelock is possible with a kernel module (requires
EXPORT_SYMBOL(min_free_kbytes)):

#include <linux/delay.h>
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/oom.h>

/*
 * The contended mutex that the allocating kthread is holding and that the oom
 * killed process is trying to acquire.
 */
static DEFINE_MUTEX(shared_mutex);

static int alloc_thread(void *param)
{
	struct task_struct *locking_thread = param;
	struct page *page, *next;
	unsigned int allocs_left;
	bool oom_killed = false;
	LIST_HEAD(pagelist);

	/* Allocate half of memory reserves after oom */
	allocs_left = (min_free_kbytes >> (PAGE_SHIFT - 10)) / 2;

	mutex_lock(&shared_mutex);

	/* Give locking_thread a chance to wakeup */
	msleep(1000);

	while (!oom_killed || allocs_left) {
		page = alloc_pages(GFP_KERNEL, 0);
		if (likely(page))
			list_add(&page->lru, &pagelist);

		cond_resched();

		if (unlikely(kthread_should_stop()))
			break;
		if (oom_killed) {
			allocs_left--;
			continue;
		}
		if (unlikely(fatal_signal_pending(locking_thread))) {
			/*
			 * The process trying to acquire shared_mutex has been
			 * killed.  Continue to allocate some memory to use
			 * reserves, and then drop the mutex.
			 */
			oom_killed = true;
		}
	}
	mutex_unlock(&shared_mutex);

	/* Release memory back to the system */
	list_for_each_entry_safe(page, next, &pagelist, lru) {
		list_del(&page->lru);
		__free_page(page);
		cond_resched();
	}
	return 0;
}

static int __init oom_livelock_init(void)
{
	struct task_struct *allocating_thread;

	allocating_thread = kthread_run(alloc_thread, current,
					"oom_test_alloc");
	if (unlikely(IS_ERR(allocating_thread))) {
		pr_err("oom_test_alloc: could not create oom_test_alloc\n");
		return PTR_ERR(allocating_thread);
	}

	/* Prefer to be the first process killed on system oom */
	set_current_oom_origin();

	/* Wait until the kthread has acquired the mutex */
	while (!mutex_is_locked(&shared_mutex))
		schedule();

	/* This should livelock without VM intervention */
	mutex_lock(&shared_mutex);
	mutex_unlock(&shared_mutex);

	kthread_stop(allocating_thread);
	return 0;
}

module_init(oom_livelock_init);

This will livelock a system running with this patch.  With an oom
expiration, allocating_thread eventually gets access to allocate memory
so that it can drop shared_mutex and the oom victim, insmod, exits.

Format of the kernel log is of the oom killed victim:

	oom_test_alloc invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0, oom_score_badness=5000 (enabled), memcg_scoring=disabled
	oom_test_alloc cpuset=/ mems_allowed=0-1
	...
	Out of Memory: Kill process 13692 (insmod) score 1142282919 or sacrifice child
	Out of Memory: Killed process 13692 (insmod) total-vm:4356kB, anon-rss:68kB, file-rss:284kB
	GOOGLE: oom-kill constraint=CONSTRAINT_NONE origin_memcg= kill_memcg= task=insmod pid=13692 uid=0

and then access to memory reserves being granted:

	WARNING: CPU: 17 PID: 13046 at mm/oom_kill.c:314 oom_scan_process_thread+0x16b/0x1f0()
	insmod (13692) has failed to exit -- global access to memory reserves started
	...
	Call Trace:
	 [<ffffffffbb5f0e67>] dump_stack+0x46/0x58
	 [<ffffffffbb069394>] warn_slowpath_common+0x94/0xc0
	 [<ffffffffbb069476>] warn_slowpath_fmt+0x46/0x50
	 [<ffffffffbb14ad1b>] oom_scan_process_thread+0x16b/0x1f0
	 [<ffffffffbb14b81b>] out_of_memory+0x39b/0x6f0
	 ...
	---[ end trace a26a290e84699a90 ]---
	Call Trace of insmod/13692:
	 [<ffffffffbb0d620c>] load_module+0x1cdc/0x23c0
	 [<ffffffffbb0d6996>] SyS_init_module+0xa6/0xd0
	 [<ffffffffbb5fb322>] system_call_fastpath+0x16/0x1b
	 [<ffffffffffffffff>] 0xffffffffffffffff

load_module+0x1cdc is a shared mutex in the unit test that insmod is
trying to acquire and that oom_test_alloc is holding while allocating.

And then the eventual exit of insmod:

	insmod (13692) exited -- global access to memory reserves ended

Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/tty/sysrq.c   |  3 +-
 include/linux/oom.h   |  5 +--
 include/linux/sched.h |  1 +
 kernel/exit.c         |  4 +++
 mm/memcontrol.c       |  4 ++-
 mm/oom_kill.c         | 92 +++++++++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c       | 18 ++++++----
 7 files changed, 110 insertions(+), 17 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -360,9 +360,10 @@ static void moom_callback(struct work_struct *ignored)
 		.gfp_mask = gfp_mask,
 		.order = -1,
 	};
+	bool unused;
 
 	mutex_lock(&oom_lock);
-	if (!out_of_memory(&oc))
+	if (!out_of_memory(&oc, &unused))
 		pr_info("OOM request ignored because killer is disabled\n");
 	mutex_unlock(&oom_lock);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -87,9 +87,10 @@ extern void check_panic_on_oom(struct oom_control *oc,
 			       struct mem_cgroup *memcg);
 
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-		struct task_struct *task, unsigned long totalpages);
+		struct task_struct *task, unsigned long totalpages,
+		bool *expire);
 
-extern bool out_of_memory(struct oom_control *oc);
+extern bool out_of_memory(struct oom_control *oc, bool *expired_oom_kill);
 
 extern void exit_oom_victim(void);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -767,6 +767,7 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	unsigned long oom_kill_expire;	/* expiration time */
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -427,6 +427,10 @@ static void exit_mm(struct task_struct *tsk)
 	}
 	atomic_inc(&mm->mm_count);
 	BUG_ON(mm != tsk->active_mm);
+	if (tsk->signal->oom_kill_expire &&
+	    time_after_eq(jiffies, tsk->signal->oom_kill_expire))
+		pr_info("%s (%d) exited -- global access to memory reserves ended\n",
+			tsk->comm, tsk->pid);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1330,10 +1330,12 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
+		bool unused;
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task, totalpages)) {
+			switch (oom_scan_process_thread(&oc, task, totalpages,
+							&unused)) {
 			case OOM_SCAN_SELECT:
 				if (chosen)
 					put_task_struct(chosen);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,6 +35,7 @@
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
+#include <linux/stacktrace.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -45,6 +46,14 @@ int sysctl_oom_dump_tasks = 1;
 
 DEFINE_MUTEX(oom_lock);
 
+/*
+ * If an oom killed thread cannot exit because another thread is holding a lock
+ * that is requires, then the oom killer cannot ensure forward progress.  When
+ * OOM_EXPIRE_MSECS lapses, provide all threads access to memory reserves so the
+ * thread holding the lock may drop it and the oom victim may exit.
+ */
+#define OOM_EXPIRE_MSECS	(5000)
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -254,8 +263,57 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+#ifdef CONFIG_STACKTRACE
+#define MAX_STACK_TRACE_ENTRIES	(64)
+static unsigned long stack_trace_entries[MAX_STACK_TRACE_ENTRIES *
+					 sizeof(unsigned long)];
+static DEFINE_MUTEX(stack_trace_mutex);
+
+static void print_stacks_expired(struct task_struct *task)
+{
+	/* One set of stack traces every OOM_EXPIRE_MS */
+	static DEFINE_RATELIMIT_STATE(expire_rs, OOM_EXPIRE_MSECS / 1000 * HZ,
+				      1);
+	struct stack_trace trace = {
+		.nr_entries = 0,
+		.max_entries = ARRAY_SIZE(stack_trace_entries),
+		.entries = stack_trace_entries,
+		.skip = 2,
+	};
+
+	if (!__ratelimit(&expire_rs))
+		return;
+
+	WARN(true,
+	     "%s (%d) has failed to exit -- global access to memory reserves started\n",
+	     task->comm, task->pid);
+
+	/*
+	 * If cred_guard_mutex can't be acquired, this may be a mutex that is
+	 * being held causing the livelock.  Return without printing the stack.
+	 */
+	if (!mutex_trylock(&task->signal->cred_guard_mutex))
+		return;
+
+	mutex_lock(&stack_trace_mutex);
+	save_stack_trace_tsk(task, &trace);
+
+	pr_info("Call Trace of %s/%d:\n", task->comm, task->pid);
+	print_stack_trace(&trace, 0);
+
+	mutex_unlock(&stack_trace_mutex);
+	mutex_unlock(&task->signal->cred_guard_mutex);
+}
+#else
+static inline void print_stacks_expired(struct task_struct *task)
+{
+}
+#endif /* CONFIG_STACKTRACE */
+
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-			struct task_struct *task, unsigned long totalpages)
+			struct task_struct *task, unsigned long totalpages,
+			bool *expired_oom_kill)
 {
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
@@ -265,8 +323,14 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (oc->order != -1)
+		if (oc->order != -1) {
+			if (task->mm && time_after_eq(jiffies,
+					task->signal->oom_kill_expire)) {
+				get_task_struct(task);
+				*expired_oom_kill = true;
+			}
 			return OOM_SCAN_ABORT;
+		}
 	}
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;
@@ -289,7 +353,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
  * number of 'points'.  Returns -1 on scan abort.
  */
 static struct task_struct *select_bad_process(struct oom_control *oc,
-		unsigned int *ppoints, unsigned long totalpages)
+		unsigned int *ppoints, unsigned long totalpages,
+		bool *expired_oom_kill)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -299,7 +364,8 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 	for_each_process_thread(g, p) {
 		unsigned int points;
 
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
+		switch (oom_scan_process_thread(oc, p, totalpages,
+						expired_oom_kill)) {
 		case OOM_SCAN_SELECT:
 			chosen = p;
 			chosen_points = ULONG_MAX;
@@ -308,6 +374,10 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 			continue;
 		case OOM_SCAN_ABORT:
 			rcu_read_unlock();
+			if (*expired_oom_kill) {
+				print_stacks_expired(p);
+				put_task_struct(p);
+			}
 			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
 			break;
@@ -414,6 +484,10 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+
+	tsk->signal->oom_kill_expire = jiffies +
+				       msecs_to_jiffies(OOM_EXPIRE_MSECS);
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -637,8 +711,11 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * killing a random task (bad), letting the system crash (worse)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
+ *
+ * expired_oom_kill is true if waiting on a process that has exceeded its oom
+ * expiration to exit.
  */
-bool out_of_memory(struct oom_control *oc)
+bool out_of_memory(struct oom_control *oc, bool *expired_oom_kill)
 {
 	struct task_struct *p;
 	unsigned long totalpages;
@@ -686,7 +763,7 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
-	p = select_bad_process(oc, &points, totalpages);
+	p = select_bad_process(oc, &points, totalpages, expired_oom_kill);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && oc->order != -1) {
 		dump_header(oc, NULL, NULL);
@@ -717,6 +794,7 @@ void pagefault_out_of_memory(void)
 		.gfp_mask = 0,
 		.order = 0,
 	};
+	bool unused;
 
 	if (mem_cgroup_oom_synchronize(true))
 		return;
@@ -724,7 +802,7 @@ void pagefault_out_of_memory(void)
 	if (!mutex_trylock(&oom_lock))
 		return;
 
-	if (!out_of_memory(&oc)) {
+	if (!out_of_memory(&oc, &unused)) {
 		/*
 		 * There shouldn't be any user tasks runnable while the
 		 * OOM killer is disabled, so the current task has to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2717,7 +2717,8 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+	const struct alloc_context *ac, unsigned long *did_some_progress,
+	bool *expired_oom_kill)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -2776,7 +2777,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+	if (out_of_memory(&oc, expired_oom_kill) ||
+	    WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
 	mutex_unlock(&oom_lock);
@@ -2947,7 +2949,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 }
 
 static inline int
-gfp_to_alloc_flags(gfp_t gfp_mask)
+gfp_to_alloc_flags(gfp_t gfp_mask, const bool expired_oom_kill)
 {
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 	const bool atomic = !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
@@ -2987,6 +2989,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				((current->flags & PF_MEMALLOC) ||
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (expired_oom_kill)
+			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -2997,7 +3001,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
-	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
+	return !!(gfp_to_alloc_flags(gfp_mask, false) & ALLOC_NO_WATERMARKS);
 }
 
 static inline struct page *
@@ -3012,6 +3016,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	bool expired_oom_kill = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3041,7 +3046,7 @@ retry:
 	 * reclaim. Now things get more complex, so set up alloc_flags according
 	 * to how we want to proceed.
 	 */
-	alloc_flags = gfp_to_alloc_flags(gfp_mask);
+	alloc_flags = gfp_to_alloc_flags(gfp_mask, expired_oom_kill);
 
 	/*
 	 * Find the true preferred zone if the allocation is unconstrained by
@@ -3166,7 +3171,8 @@ retry:
 	}
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress,
+				     &expired_oom_kill);
 	if (page)
 		goto got_pg;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
