Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 070256B0073
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:45 -0400 (EDT)
Received: by wief7 with SMTP id f7so252829wie.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ge8si14153481wib.104.2015.04.27.12.06.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:36 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/9] mm: oom_kill: simplify OOM killer locking
Date: Mon, 27 Apr 2015 15:05:52 -0400
Message-Id: <1430161555-6058-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The zonelist locking and the oom_sem are two overlapping locks that
are used to serialize global OOM killing against different things.

The historical zonelist locking serializes OOM kills from allocations
with overlapping zonelists against each other to prevent killing more
tasks than necessary in the same memory domain.  Only when neither
tasklists nor zonelists from two concurrent OOM kills overlap (tasks
in separate memcgs bound to separate nodes) are OOM kills allowed to
execute in parallel.

The younger oom_sem is a read-write lock to serialize OOM killing
against the PM code trying to disable the OOM killer altogether.

However, the OOM killer is a fairly cold error path, there is really
no reason to optimize for highly performant and concurrent OOM kills.
And the oom_sem is just flat-out redundant.

Replace both locking schemes with a single global mutex serializing
OOM kills regardless of context.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/tty/sysrq.c |   2 +
 include/linux/oom.h |   5 +--
 mm/memcontrol.c     |  18 +++++---
 mm/oom_kill.c       | 127 +++++++++++-----------------------------------------
 mm/page_alloc.c     |   8 ++--
 5 files changed, 46 insertions(+), 114 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 843f2cd..b20d2c0 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -356,9 +356,11 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
+	mutex_lock(&oom_lock);
 	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
 			   GFP_KERNEL, 0, NULL, true))
 		pr_info("OOM request ignored because killer is disabled\n");
+	mutex_unlock(&oom_lock);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index a8e6a49..7deecb7 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -32,6 +32,8 @@ enum oom_scan_t {
 /* Thread is the potential origin of an oom condition; kill first on oom */
 #define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
 
+extern struct mutex oom_lock;
+
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flags |= OOM_FLAG_ORIGIN;
@@ -60,9 +62,6 @@ extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			     struct mem_cgroup *memcg, nodemask_t *nodemask,
 			     const char *message);
 
-extern bool oom_zonelist_trylock(struct zonelist *zonelist, gfp_t gfp_flags);
-extern void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_flags);
-
 extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			       int order, const nodemask_t *nodemask,
 			       struct mem_cgroup *memcg);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 54f8457..5fd273d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1530,6 +1530,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
 
+	mutex_lock(&oom_lock);
+
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
@@ -1537,7 +1539,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		return;
+		goto unlock;
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
@@ -1564,7 +1566,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
-				return;
+				goto unlock;
 			case OOM_SCAN_OK:
 				break;
 			};
@@ -1585,11 +1587,13 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		css_task_iter_end(&it);
 	}
 
-	if (!chosen)
-		return;
-	points = chosen_points * 1000 / totalpages;
-	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
-			 NULL, "Memory cgroup out of memory");
+	if (chosen) {
+		points = chosen_points * 1000 / totalpages;
+		oom_kill_process(chosen, gfp_mask, order, points, totalpages,
+				 memcg, NULL, "Memory cgroup out of memory");
+	}
+unlock:
+	mutex_unlock(&oom_lock);
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d3490b0..5cfda39 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -42,7 +42,8 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
-static DEFINE_SPINLOCK(zone_scan_lock);
+
+DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
 /**
@@ -405,13 +406,12 @@ static atomic_t oom_victims = ATOMIC_INIT(0);
 static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 bool oom_killer_disabled __read_mostly;
-static DECLARE_RWSEM(oom_sem);
 
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
  *
- * Has to be called with oom_sem taken for read and never after
+ * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
 void mark_oom_victim(struct task_struct *tsk)
@@ -460,14 +460,14 @@ bool oom_killer_disable(void)
 	 * Make sure to not race with an ongoing OOM killer
 	 * and that the current is not the victim.
 	 */
-	down_write(&oom_sem);
+	mutex_lock(&oom_lock);
 	if (test_thread_flag(TIF_MEMDIE)) {
-		up_write(&oom_sem);
+		mutex_unlock(&oom_lock);
 		return false;
 	}
 
 	oom_killer_disabled = true;
-	up_write(&oom_sem);
+	mutex_unlock(&oom_lock);
 
 	wait_event(oom_victims_wait, !atomic_read(&oom_victims));
 
@@ -634,52 +634,6 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
-/*
- * Try to acquire the OOM killer lock for the zones in zonelist.  Returns zero
- * if a parallel OOM killing is already taking place that includes a zone in
- * the zonelist.  Otherwise, locks all zones in the zonelist and returns 1.
- */
-bool oom_zonelist_trylock(struct zonelist *zonelist, gfp_t gfp_mask)
-{
-	struct zoneref *z;
-	struct zone *zone;
-	bool ret = true;
-
-	spin_lock(&zone_scan_lock);
-	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		if (test_bit(ZONE_OOM_LOCKED, &zone->flags)) {
-			ret = false;
-			goto out;
-		}
-
-	/*
-	 * Lock each zone in the zonelist under zone_scan_lock so a parallel
-	 * call to oom_zonelist_trylock() doesn't succeed when it shouldn't.
-	 */
-	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		set_bit(ZONE_OOM_LOCKED, &zone->flags);
-
-out:
-	spin_unlock(&zone_scan_lock);
-	return ret;
-}
-
-/*
- * Clears the ZONE_OOM_LOCKED flag for all zones in the zonelist so that failed
- * allocation attempts with zonelists containing them may now recall the OOM
- * killer, if necessary.
- */
-void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
-{
-	struct zoneref *z;
-	struct zone *zone;
-
-	spin_lock(&zone_scan_lock);
-	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		clear_bit(ZONE_OOM_LOCKED, &zone->flags);
-	spin_unlock(&zone_scan_lock);
-}
-
 /**
  * __out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -693,8 +647,8 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *nodemask, bool force_kill)
+bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		   int order, nodemask_t *nodemask, bool force_kill)
 {
 	const nodemask_t *mpol_mask;
 	struct task_struct *p;
@@ -704,10 +658,13 @@ static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 	int killed = 0;
 
+	if (oom_killer_disabled)
+		return false;
+
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */
-		return;
+		goto out;
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -720,7 +677,7 @@ static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		mark_oom_victim(current);
-		return;
+		goto out;
 	}
 
 	/*
@@ -760,32 +717,8 @@ out:
 	 */
 	if (killed)
 		schedule_timeout_killable(1);
-}
-
-/**
- * out_of_memory -  tries to invoke OOM killer.
- * @zonelist: zonelist pointer
- * @gfp_mask: memory allocation flags
- * @order: amount of memory being requested as a power of 2
- * @nodemask: nodemask passed to page allocator
- * @force_kill: true if a task must be killed, even if others are exiting
- *
- * invokes __out_of_memory if the OOM is not disabled by oom_killer_disable()
- * when it returns false. Otherwise returns true.
- */
-bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *nodemask, bool force_kill)
-{
-	bool ret = false;
-
-	down_read(&oom_sem);
-	if (!oom_killer_disabled) {
-		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
-		ret = true;
-	}
-	up_read(&oom_sem);
 
-	return ret;
+	return true;
 }
 
 /*
@@ -795,27 +728,21 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
  */
 void pagefault_out_of_memory(void)
 {
-	struct zonelist *zonelist;
-
-	down_read(&oom_sem);
 	if (mem_cgroup_oom_synchronize(true))
-		goto unlock;
+		return;
 
-	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
-	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
-		if (!oom_killer_disabled)
-			__out_of_memory(NULL, 0, 0, NULL, false);
-		else
-			/*
-			 * There shouldn't be any user tasks runable while the
-			 * OOM killer is disabled so the current task has to
-			 * be a racing OOM victim for which oom_killer_disable()
-			 * is waiting for.
-			 */
-			WARN_ON(test_thread_flag(TIF_MEMDIE));
+	if (!mutex_trylock(&oom_lock))
+		return;
 
-		oom_zonelist_unlock(zonelist, GFP_KERNEL);
+	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
+		/*
+		 * There shouldn't be any user tasks runnable while the
+		 * OOM killer is disabled, so the current task has to
+		 * be a racing OOM victim for which oom_killer_disable()
+		 * is waiting for.
+		 */
+		WARN_ON(test_thread_flag(TIF_MEMDIE));
 	}
-unlock:
-	up_read(&oom_sem);
+
+	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..cdb786b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2373,10 +2373,10 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the per-zone oom lock for each zone.  If that
-	 * fails, somebody else is making progress for us.
+	 * Acquire the oom lock.  If that fails, somebody else is
+	 * making progress for us.
 	 */
-	if (!oom_zonelist_trylock(ac->zonelist, gfp_mask)) {
+	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;
@@ -2421,7 +2421,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
-	oom_zonelist_unlock(ac->zonelist, gfp_mask);
+	mutex_unlock(&oom_lock);
 	return page;
 }
 
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
