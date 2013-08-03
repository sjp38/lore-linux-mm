Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 840336B0039
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 13:00:42 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/7] mm: memcg: rework and document OOM waiting and wakeup
Date: Sat,  3 Aug 2013 12:59:59 -0400
Message-Id: <1375549200-19110-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg OOM handler open-codes a sleeping lock for OOM serialization
(trylock, wait, repeat) because the required locking is so specific to
memcg hierarchies.  However, it would be nice if this construct would
be clearly recognizable and not be as obfuscated as it is right now.
Clean up as follows:

1. Remove the return value of mem_cgroup_oom_unlock()

2. Rename mem_cgroup_oom_lock() to mem_cgroup_oom_trylock().

3. Pull the prepare_to_wait() out of the memcg_oom_lock scope.  This
   makes it more obvious that the task has to be on the waitqueue
   before attempting to OOM-trylock the hierarchy, to not miss any
   wakeups before going to sleep.  It just didn't matter until now
   because it was all lumped together into the global memcg_oom_lock
   spinlock section.

4. Pull the mem_cgroup_oom_notify() out of the memcg_oom_lock scope.
   It is proctected by the hierarchical OOM-lock.

5. The memcg_oom_lock spinlock is only required to propagate the OOM
   lock in any given hierarchy atomically.  Restrict its scope to
   mem_cgroup_oom_(trylock|unlock).

6. Do not wake up the waitqueue unconditionally at the end of the
   function.  Only the lockholder has to wake up the next in line
   after releasing the lock.

   Note that the lockholder kicks off the OOM-killer, which in turn
   leads to wakeups from the uncharges of the exiting task.  But a
   contender is not guaranteed to see them if it enters the OOM path
   after the OOM kills but before the lockholder releases the lock.
   Thus there has to be an explicit wakeup after releasing the lock.

7. Put the OOM task on the waitqueue before marking the hierarchy as
   under OOM as that is the point where we start to receive wakeups.
   No point in listening before being on the waitqueue.

8. Likewise, unmark the hierarchy before finishing the sleep, for
   symmetry.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 85 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 47 insertions(+), 38 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 30ae46a..3d0c1d3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2076,15 +2076,18 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 	return total;
 }
 
+static DEFINE_SPINLOCK(memcg_oom_lock);
+
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
- * Has to be called with memcg_oom_lock
  */
-static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
+static bool mem_cgroup_oom_trylock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter, *failed = NULL;
 
+	spin_lock(&memcg_oom_lock);
+
 	for_each_mem_cgroup_tree(iter, memcg) {
 		if (iter->oom_lock) {
 			/*
@@ -2098,33 +2101,33 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
 			iter->oom_lock = true;
 	}
 
-	if (!failed)
-		return true;
-
-	/*
-	 * OK, we failed to lock the whole subtree so we have to clean up
-	 * what we set up to the failing subtree
-	 */
-	for_each_mem_cgroup_tree(iter, memcg) {
-		if (iter == failed) {
-			mem_cgroup_iter_break(memcg, iter);
-			break;
+	if (failed) {
+		/*
+		 * OK, we failed to lock the whole subtree so we have
+		 * to clean up what we set up to the failing subtree
+		 */
+		for_each_mem_cgroup_tree(iter, memcg) {
+			if (iter == failed) {
+				mem_cgroup_iter_break(memcg, iter);
+				break;
+			}
+			iter->oom_lock = false;
 		}
-		iter->oom_lock = false;
-	}
-	return false;
+	}	
+
+	spin_unlock(&memcg_oom_lock);
+
+	return !failed;
 }
 
-/*
- * Has to be called with memcg_oom_lock
- */
-static int mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
+static void mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
+	spin_lock(&memcg_oom_lock);
 	for_each_mem_cgroup_tree(iter, memcg)
 		iter->oom_lock = false;
-	return 0;
+	spin_unlock(&memcg_oom_lock);
 }
 
 static void mem_cgroup_mark_under_oom(struct mem_cgroup *memcg)
@@ -2148,7 +2151,6 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -2195,45 +2197,52 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 				  int order)
 {
 	struct oom_wait_info owait;
-	bool locked, need_to_kill;
+	bool locked;
 
 	owait.memcg = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
 
-	/* At first, try to OOM lock hierarchy under memcg.*/
-	spin_lock(&memcg_oom_lock);
-	locked = mem_cgroup_oom_lock(memcg);
 	/*
+	 * As with any blocking lock, a contender needs to start
+	 * listening for wakeups before attempting the trylock,
+	 * otherwise it can miss the wakeup from the unlock and sleep
+	 * indefinitely.  This is just open-coded because our locking
+	 * is so particular to memcg hierarchies.
+	 *
 	 * Even if signal_pending(), we can't quit charge() loop without
 	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || memcg->oom_kill_disable)
-		need_to_kill = false;
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	if (need_to_kill) {
+	if (locked && !memcg->oom_kill_disable) {
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask, order);
 	} else {
 		schedule();
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
-		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	mem_cgroup_unmark_under_oom(memcg);
+	if (locked) {
+		mem_cgroup_oom_unlock(memcg);
+		/*
+		 * There is no guarantee that an OOM-lock contender
+		 * sees the wakeups triggered by the OOM kill
+		 * uncharges.  Wake any sleepers explicitely.
+		 */
+		memcg_oom_recover(memcg);
+	}
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
