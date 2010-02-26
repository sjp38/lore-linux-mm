Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 979536B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 18:53:20 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o1QNrFs2014560
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 23:53:15 GMT
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by spaceape9.eur.corp.google.com with ESMTP id o1QNqgmZ005489
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:14 -0800
Received: by pwi10 with SMTP id 10so474251pwi.29
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:13 -0800 (PST)
Date: Fri, 26 Feb 2010 15:53:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is possible to remove the special pagefault oom handler by simply
oom locking all system zones and then calling directly into
out_of_memory().

All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
parallel oom killing in progress that will lead to eventual memory
freeing so it's not necessary to needlessly kill another task.  The
context in which the pagefault is allocating memory is unknown to the oom
killer, so this is done on a system-wide level.

If a task has already been oom killed and hasn't fully exited yet, this
will be a no-op since select_bad_process() recognizes tasks across the
system with TIF_MEMDIE set.

The special handling to determine whether a parallel memcg is currently
oom is removed since we can detect future memory freeing with TIF_MEMDIE.
The memcg has already reached its memory limit, so it will still need to
kill a task regardless of the pagefault oom.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    6 ---
 mm/memcontrol.c            |   35 +---------------
 mm/oom_kill.c              |   97 ++++++++++++++++++++++++++------------------
 3 files changed, 58 insertions(+), 80 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-extern bool mem_cgroup_oom_called(struct task_struct *task);
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
@@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
-static inline bool mem_cgroup_oom_called(struct task_struct *task)
-{
-	return false;
-}
-
 static inline int
 mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -217,7 +217,6 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long	last_oom_jiffies;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -1205,34 +1204,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	return total;
 }
 
-bool mem_cgroup_oom_called(struct task_struct *task)
-{
-	bool ret = false;
-	struct mem_cgroup *mem;
-	struct mm_struct *mm;
-
-	rcu_read_lock();
-	mm = task->mm;
-	if (!mm)
-		mm = &init_mm;
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
-		ret = true;
-	rcu_read_unlock();
-	return ret;
-}
-
-static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
-{
-	mem->last_oom_jiffies = jiffies;
-	return 0;
-}
-
-static void record_last_oom(struct mem_cgroup *mem)
-{
-	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
-}
-
 /*
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
@@ -1484,10 +1455,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			continue;
 
 		if (!nr_retries--) {
-			if (oom) {
+			if (oom)
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
-				record_last_oom(mem_over_limit);
-			}
 			goto nomem;
 		}
 	}
@@ -2284,8 +2253,6 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 
 /*
  * A call to try to shrink memory usage on charge failure at shmem's swapin.
- * Calling hierarchical_reclaim is not enough because we should update
- * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
  * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
  * not from the memcg which this page would be charged to.
  * try_charge_swapin does all of these works properly.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -580,6 +580,44 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 }
 
 /*
+ * Try to acquire the oom killer lock for all system zones.  Returns zero if a
+ * parallel oom killing is taking place, otherwise locks all zones and returns
+ * non-zero.
+ */
+static int try_set_system_oom(void)
+{
+	struct zone *zone;
+	int ret = 1;
+
+	spin_lock(&zone_scan_lock);
+	for_each_populated_zone(zone)
+		if (zone_is_oom_locked(zone)) {
+			ret = 0;
+			goto out;
+		}
+	for_each_populated_zone(zone)
+		zone_set_flag(zone, ZONE_OOM_LOCKED);
+out:
+	spin_unlock(&zone_scan_lock);
+	return ret;
+}
+
+/*
+ * Clears ZONE_OOM_LOCKED for all system zones so that failed allocation
+ * attempts or page faults may now recall the oom killer, if necessary.
+ */
+static void clear_system_oom(void)
+{
+	struct zone *zone;
+
+	spin_lock(&zone_scan_lock);
+	for_each_populated_zone(zone)
+		zone_clear_flag(zone, ZONE_OOM_LOCKED);
+	spin_unlock(&zone_scan_lock);
+}
+
+
+/*
  * Must be called with tasklist_lock held for read.
  */
 static void __out_of_memory(gfp_t gfp_mask, int order,
@@ -614,46 +652,9 @@ retry:
 		goto retry;
 }
 
-/*
- * pagefault handler calls into here because it is out of memory but
- * doesn't know exactly how or why.
- */
-void pagefault_out_of_memory(void)
-{
-	unsigned long freed = 0;
-
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		return;
-
-	/*
-	 * If this is from memcg, oom-killer is already invoked.
-	 * and not worth to go system-wide-oom.
-	 */
-	if (mem_cgroup_oom_called(current))
-		goto rest_and_return;
-
-	if (sysctl_panic_on_oom)
-		panic("out of memory from page fault. panic_on_oom is selected.\n");
-
-	read_lock(&tasklist_lock);
-	/* unknown gfp_mask and order */
-	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
-	read_unlock(&tasklist_lock);
-
-	/*
-	 * Give "p" a good chance of killing itself before we
-	 * retry to allocate memory.
-	 */
-rest_and_return:
-	if (!test_thread_flag(TIF_MEMDIE))
-		schedule_timeout_uninterruptible(1);
-}
-
 /**
  * out_of_memory - kill the "best" process when we run out of memory
- * @zonelist: zonelist pointer
+ * @zonelist: zonelist pointer passed to page allocator
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
  * @nodemask: nodemask passed to page allocator
@@ -667,7 +668,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint;
+	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
@@ -683,7 +684,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
+	if (zonelist)
+		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
 	if (unlikely(sysctl_panic_on_oom)) {
 		/*
@@ -693,6 +695,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		 */
 		if (constraint == CONSTRAINT_NONE) {
 			dump_header(NULL, gfp_mask, order, NULL);
+			read_unlock(&tasklist_lock);
 			panic("Out of memory: panic_on_oom is enabled\n");
 		}
 	}
@@ -706,3 +709,17 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }
+
+/*
+ * The pagefault handler calls here because it is out of memory, so kill a
+ * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
+ * oom killing is already in progress so do nothing.  If a task is found with
+ * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
+ */
+void pagefault_out_of_memory(void)
+{
+	if (!try_set_system_oom())
+		return;
+	out_of_memory(NULL, 0, 0, NULL);
+	clear_system_oom();
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
