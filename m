Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D0E3B6B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 20:58:24 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o1H1wCsv015920
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:58:13 GMT
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz33.hot.corp.google.com with ESMTP id o1H1wB2E026841
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:58:11 -0800
Received: by pzk37 with SMTP id 37so6293362pzk.10
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:58:10 -0800 (PST)
Date: Tue, 16 Feb 2010 17:58:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
 <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, David Rientjes wrote:

> Ok, I'll eliminate pagefault_out_of_memory() and get it to use 
> out_of_memory() by only checking for constrained_alloc() when
> gfp_mask != 0.
> 

What do you think about making pagefaults use out_of_memory() directly and 
respecting the sysctl_panic_on_oom settings?

This removes the check for a parallel memcg oom killing since we can 
guarantee that's not going to happen if we take ZONE_OOM_LOCKED for all 
populated zones (nobody is currently executing the oom killer) and no 
tasks have TIF_MEMDIE set.

Signed-off-by: David Rientjes <rientjes@google.com>
---
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
@@ -200,7 +200,6 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long	last_oom_jiffies;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -1234,34 +1233,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -1549,10 +1520,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		}
 
 		if (!nr_retries--) {
-			if (oom) {
+			if (oom)
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
-				record_last_oom(mem_over_limit);
-			}
 			goto nomem;
 		}
 	}
@@ -2408,8 +2377,6 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 
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
@@ -490,29 +490,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	return oom_kill_task(victim);
 }
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
-{
-	unsigned long points = 0;
-	struct task_struct *p;
-
-	read_lock(&tasklist_lock);
-retry:
-	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
-	if (PTR_ERR(p) == -1UL)
-		goto out;
-
-	if (!p)
-		p = current;
-
-	if (oom_kill_process(p, gfp_mask, 0, points, mem,
-				"Memory cgroup out of memory"))
-		goto retry;
-out:
-	read_unlock(&tasklist_lock);
-}
-#endif
-
 static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
 
 int register_oom_notifier(struct notifier_block *nb)
@@ -578,6 +555,70 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
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
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
+{
+	unsigned long points = 0;
+	struct task_struct *p;
+
+	if (!try_set_system_oom())
+		return;
+	read_lock(&tasklist_lock);
+retry:
+	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
+	if (PTR_ERR(p) == -1UL)
+		goto out;
+
+	if (!p)
+		p = current;
+
+	if (oom_kill_process(p, gfp_mask, 0, points, mem,
+				"Memory cgroup out of memory"))
+		goto retry;
+out:
+	read_unlock(&tasklist_lock);
+	clear_system_oom();
+}
+#endif
+
+/*
  * Must be called with tasklist_lock held for read.
  */
 static void __out_of_memory(gfp_t gfp_mask, int order,
@@ -612,46 +653,9 @@ retry:
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
@@ -665,7 +669,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint;
+	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
@@ -681,7 +685,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
+	if (zonelist)
+		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
 	if (unlikely(sysctl_panic_on_oom)) {
 		/*
@@ -691,6 +696,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		 */
 		if (constraint == CONSTRAINT_NONE) {
 			dump_header(NULL, gfp_mask, order, NULL);
+			read_unlock(&tasklist_lock);
 			panic("Out of memory: panic_on_oom is enabled\n");
 		}
 	}
@@ -704,3 +710,17 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
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
