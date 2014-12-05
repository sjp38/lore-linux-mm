Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B40BF6B0078
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:41:58 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so1983923wiw.3
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:41:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yo4si19235984wjc.118.2014.12.05.08.41.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 08:41:55 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path raceless
Date: Fri,  5 Dec 2014 17:41:47 +0100
Message-Id: <1417797707-31699-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1417797707-31699-1-git-send-email-mhocko@suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

5695be142e20 (OOM, PM: OOM killed task shouldn't escape PM suspend)
has left a race window when OOM killer manages to note_oom_kill after
freeze_processes checks the counter. The race window is quite small and
really unlikely and partial solution deemed sufficient at the time of
submission.

Tejun wasn't happy about this partial solution though and insisted on a
full solution. That requires the full OOM and freezer's task freezing
exclusion, though. This is done by this patch which introduces oom_sem
RW lock and turns oom_killer_disable() into a full OOM barrier.

oom_killer_disabled check is moved from the allocation path to the OOM
level and we take oom_sem for reading for both the check and the whole
OOM invocation.

oom_killer_disable() takes oom_sem for writing so it waits for all
currently running OOM killer invocations. Then it disable all the
further OOMs by setting oom_killer_disabled and checks for any oom
victims. Victims are counted via {un}mark_tsk_oom_victim. The last
victim wakes up all waiters on oom_victims_wait waitqueue enqueued by
oom_killer_disable(). Therefore this function acts as the full OOM
barrier.

The page fault path is covered now as well although it was assumed to be
safe before. As per Tejun, "We used to have freezing points deep in file
system code which may be reacheable from page fault." so it would be
better and more robust to not rely on freezing points here. Same applies
to the memcg OOM killer.

out_of_memory tells the caller whether the OOM was allowed to trigger
and the callers are supposed to handle the situation. The page
allocation path simply fails the allocation same as before. The page
fault path will retry the fault (more on that later) and Sysrq OOM
trigger will simply complain to the log.

As oom_killer_disable() is a full OOM barrier now we can postpone it in
the PM freezer to later after all freezable user tasks are considered
frozen (to freeze_kernel_threads).

Normally there wouldn't be any unfrozen user tasks at this moment so
the function will not block. But if there was an OOM killer racing with
try_to_freeze_tasks and the OOM victim didn't finish yet then we have to
wait for it. This should complete in a finite time, though, because
	- the victim cannot loop in the page fault handler (it would die
	  on the way out from the exception)
	- it cannot loop in the page allocator because all the further
	  allocation would fail and __GFP_NOFAIL allocations are not
	  acceptable at this stage
	- it shouldn't be blocked on any locks held by frozen tasks
	  (try_to_freeze expects lockless context) and kernel threads and
	  work queues are not frozen yet

TODO:
Android lowmemory killer abuses TIF_MEMDIE in lowmem_scan and it has to
learn about oom_disable logic as well.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/tty/sysrq.c    |   5 +-
 include/linux/oom.h    |  14 ++----
 kernel/exit.c          |   3 +-
 kernel/power/process.c |  58 ++++++----------------
 mm/memcontrol.c        |   2 +-
 mm/oom_kill.c          | 131 ++++++++++++++++++++++++++++++++++++++++++-------
 mm/page_alloc.c        |  17 +------
 7 files changed, 137 insertions(+), 93 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 0071469ecbf1..259a4d5a4e8f 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -355,8 +355,9 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL), GFP_KERNEL,
-		      0, NULL, true);
+	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
+			   GFP_KERNEL, 0, NULL, true))
+		pr_info("OOM request ignored because killer is disabled\n");
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 1315fcbb9527..03b5c395e514 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -72,22 +72,14 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
 
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
 extern bool oom_killer_disabled;
-
-static inline void oom_killer_disable(void)
-{
-	oom_killer_disabled = true;
-}
-
-static inline void oom_killer_enable(void)
-{
-	oom_killer_disabled = false;
-}
+extern bool oom_killer_disable(void);
+extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
diff --git a/kernel/exit.c b/kernel/exit.c
index ee5176e2a1ba..272915fc603f 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -459,7 +459,8 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	unmark_tsk_oom_victim();
+	if (test_thread_flag(TIF_MEMDIE))
+		unmark_tsk_oom_victim();
 }
 
 /*
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 3ac45f192e9f..c3da8b297b10 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -108,30 +108,6 @@ static int try_to_freeze_tasks(bool user_only)
 	return todo ? -EBUSY : 0;
 }
 
-static bool __check_frozen_processes(void)
-{
-	struct task_struct *g, *p;
-
-	for_each_process_thread(g, p)
-		if (p != current && !freezer_should_skip(p) && !frozen(p))
-			return false;
-
-	return true;
-}
-
-/*
- * Returns true if all freezable tasks (except for current) are frozen already
- */
-static bool check_frozen_processes(void)
-{
-	bool ret;
-
-	read_lock(&tasklist_lock);
-	ret = __check_frozen_processes();
-	read_unlock(&tasklist_lock);
-	return ret;
-}
-
 /**
  * freeze_processes - Signal user space processes to enter the refrigerator.
  * The current thread will not be frozen.  The same process that calls
@@ -142,7 +118,6 @@ static bool check_frozen_processes(void)
 int freeze_processes(void)
 {
 	int error;
-	int oom_kills_saved;
 
 	error = __usermodehelper_disable(UMH_FREEZING);
 	if (error)
@@ -157,25 +132,10 @@ int freeze_processes(void)
 	pm_wakeup_clear();
 	pr_info("Freezing user space processes ... ");
 	pm_freezing = true;
-	oom_kills_saved = oom_kills_count();
 	error = try_to_freeze_tasks(true);
 	if (!error) {
 		__usermodehelper_set_disable_depth(UMH_DISABLED);
-		oom_killer_disable();
-
-		/*
-		 * There might have been an OOM kill while we were
-		 * freezing tasks and the killed task might be still
-		 * on the way out so we have to double check for race.
-		 */
-		if (oom_kills_count() != oom_kills_saved &&
-		    !check_frozen_processes()) {
-			__usermodehelper_set_disable_depth(UMH_ENABLED);
-			pr_cont("OOM in progress.");
-			error = -EBUSY;
-		} else {
-			pr_cont("done.");
-		}
+		pr_cont("done.");
 	}
 	pr_cont("\n");
 	BUG_ON(in_atomic());
@@ -197,8 +157,17 @@ int freeze_kernel_threads(void)
 {
 	int error;
 
-	pr_info("Freezing remaining freezable tasks ... ");
+	/*
+	 * Now that the whole userspace is frozen we need to disbale
+	 * the OOM killer to disallow any further interference with
+	 * killable tasks.
+	 */
+	if (!oom_killer_disable()) {
+		error = -EBUSY;
+		goto out;
+	}
 
+	pr_info("Freezing remaining freezable tasks ... ");
 	pm_nosig_freezing = true;
 	error = try_to_freeze_tasks(false);
 	if (!error)
@@ -207,6 +176,7 @@ int freeze_kernel_threads(void)
 	pr_cont("\n");
 	BUG_ON(in_atomic());
 
+out:
 	if (error)
 		thaw_kernel_threads();
 	return error;
@@ -223,8 +193,6 @@ void thaw_processes(void)
 	pm_freezing = false;
 	pm_nosig_freezing = false;
 
-	oom_killer_enable();
-
 	pr_info("Restarting tasks ... ");
 
 	__usermodehelper_set_disable_depth(UMH_FREEZING);
@@ -252,6 +220,8 @@ void thaw_kernel_threads(void)
 {
 	struct task_struct *g, *p;
 
+	oom_killer_enable();
+
 	pm_nosig_freezing = false;
 	pr_info("Restarting kernel threads ... ");
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 302e0fc6d121..34a196eb45cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2155,7 +2155,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	if (!memcg)
 		return false;
 
-	if (!handle)
+	if (!handle || oom_killer_disabled)
 		goto cleanup;
 
 	owait.memcg = memcg;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8874058d62db..facc4587daf3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -405,37 +405,91 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 /*
- * Number of OOM killer invocations (including memcg OOM killer).
- * Primarily used by PM freezer to check for potential races with
- * OOM killed frozen task.
+ * Number of OOM victims in flight
  */
-static atomic_t oom_kills = ATOMIC_INIT(0);
+static atomic_t oom_victims = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
-int oom_kills_count(void)
-{
-	return atomic_read(&oom_kills);
-}
-
-void note_oom_kill(void)
-{
-	atomic_inc(&oom_kills);
-}
+bool oom_killer_disabled __read_mostly;
+static DECLARE_RWSEM(oom_sem);
 
 /**
  * Marks the given taks as OOM victim.
  * @tsk: task to mark
+ *
+ * Has to be called with oom_sem taken for read and never after
+ * oom has been disabled already.
  */
 void mark_tsk_oom_victim(struct task_struct *tsk)
 {
-	set_tsk_thread_flag(tsk, TIF_MEMDIE);
+	WARN_ON(oom_killer_disabled);
+	/* OOM killer might race with memcg OOM */
+	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return;
+	atomic_inc(&oom_victims);
 }
 
 /**
  * Unmarks the current task as OOM victim.
+ *
+ * Wakes up all waiters in oom_killer_disable()
  */
 void unmark_tsk_oom_victim(void)
 {
-	clear_thread_flag(TIF_MEMDIE);
+	if (!test_and_clear_thread_flag(TIF_MEMDIE))
+		return;
+
+	down_read(&oom_sem);
+	/*
+	 * There is no need to signal the lasst oom_victim if there
+	 * is nobody who cares.
+	 */
+	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
+		wake_up_all(&oom_victims_wait);
+	up_read(&oom_sem);
+}
+
+/**
+ * oom_killer_disable - disable OOM killer
+ *
+ * Forces all page allocations to fail rather than trigger OOM killer.
+ * Will block and wait until all OOM victims are killed.
+ *
+ * The function cannot be called when there are runnable user tasks because
+ * the userspace would see unexpected allocation failures as a result. Any
+ * new usage of this function should be consulted with MM people.
+ *
+ * Returns true if successful and false if the OOM killer cannot be
+ * disabled.
+ */
+bool oom_killer_disable(void)
+{
+	/*
+	 * Make sure to not race with an ongoing OOM killer
+	 * and that the current is not the victim.
+	 */
+	down_write(&oom_sem);
+	if (test_thread_flag(TIF_MEMDIE)) {
+		up_write(&oom_sem);
+		return false;
+	}
+
+	oom_killer_disabled = true;
+	up_write(&oom_sem);
+
+	wait_event(oom_victims_wait, atomic_read(&oom_victims));
+
+	return true;
+}
+
+/**
+ * oom_killer_enable - enable OOM killer
+ */
+void oom_killer_enable(void)
+{
+	down_write(&oom_sem);
+	oom_killer_disabled = false;
+	up_write(&oom_sem);
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -635,7 +689,7 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
 }
 
 /**
- * out_of_memory - kill the "best" process when we run out of memory
+ * __out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
@@ -647,7 +701,7 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask, bool force_kill)
 {
 	const nodemask_t *mpol_mask;
@@ -712,6 +766,32 @@ out:
 		schedule_timeout_killable(1);
 }
 
+/**
+ * out_of_memory -  tries to invoke OOM killer.
+ * @zonelist: zonelist pointer
+ * @gfp_mask: memory allocation flags
+ * @order: amount of memory being requested as a power of 2
+ * @nodemask: nodemask passed to page allocator
+ * @force_kill: true if a task must be killed, even if others are exiting
+ *
+ * invokes __out_of_memory if the OOM is not disabled by oom_killer_disable()
+ * when it returns false. Otherwise returns true.
+ */
+bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *nodemask, bool force_kill)
+{
+	bool ret = false;
+
+	down_read(&oom_sem);
+	if (!oom_killer_disabled) {
+		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
+		ret = true;
+	}
+	up_read(&oom_sem);
+
+	return ret;
+}
+
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
  * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
@@ -721,12 +801,25 @@ void pagefault_out_of_memory(void)
 {
 	struct zonelist *zonelist;
 
+	down_read(&oom_sem);
 	if (mem_cgroup_oom_synchronize(true))
-		return;
+		goto unlock;
 
 	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
 	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
-		out_of_memory(NULL, 0, 0, NULL, false);
+		if (!oom_killer_disabled)
+			__out_of_memory(NULL, 0, 0, NULL, false);
+		else
+			/*
+			 * There shouldn't be any user tasks runable while the
+			 * OOM killer is disabled so the current task has to
+			 * be a racing OOM victim for which oom_killer_disable()
+			 * is waiting for.
+			 */
+			WARN_ON(test_thread_flag(TIF_MEMDIE));
+
 		oom_zonelist_unlock(zonelist, GFP_KERNEL);
 	}
+unlock:
+	up_read(&oom_sem);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 721780ce1fd3..5b87346837dd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -242,8 +242,6 @@ void set_pageblock_migratetype(struct page *page, int migratetype)
 					PB_migrate, PB_migrate_end);
 }
 
-bool oom_killer_disabled __read_mostly;
-
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -2247,9 +2245,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 
 	*did_some_progress = 0;
 
-	if (oom_killer_disabled)
-		return NULL;
-
 	/*
 	 * Acquire the per-zone oom lock for each zone.  If that
 	 * fails, somebody else is making progress for us.
@@ -2261,14 +2256,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/*
-	 * PM-freezer should be notified that there might be an OOM killer on
-	 * its way to kill and wake somebody up. This is too early and we might
-	 * end up not killing anything but false positives are acceptable.
-	 * See freeze_processes.
-	 */
-	note_oom_kill();
-
-	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
@@ -2304,8 +2291,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
-	*did_some_progress = 1;
+	if (out_of_memory(zonelist, gfp_mask, order, nodemask, false))
+		*did_some_progress = 1;
 out:
 	oom_zonelist_unlock(zonelist, gfp_mask);
 	return page;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
