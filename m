Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EA9446B007D
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 23:59:17 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o224xEdo003491
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Mar 2010 13:59:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B0945DE4F
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:59:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D4DF45DE53
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:59:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 72DA61DB8040
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:59:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1081EE18003
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:59:14 +0900 (JST)
Date: Tue, 2 Mar 2010 13:55:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix oom kill behavior v2
Message-Id: <20100302135524.afe2f7ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Very sorry, mutex_lock is called after prepare_to_wait.
This is a fixed one.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In current page-fault code,

	handle_mm_fault()
		-> ...
		-> mem_cgroup_charge()
		-> map page or handle error.
	-> check return code.

If page fault's return code is VM_FAULT_OOM, page_fault_out_of_memory()
is called. But if it's caused by memcg, OOM should have been already
invoked.
Then, I added a patch: a636b327f731143ccc544b966cfd8de6cb6d72c6

That patch records last_oom_jiffies for memcg's sub-hierarchy and
prevents page_fault_out_of_memory from being invoked in near future.

But Nishimura-san reported that check by jiffies is not enough
when the system is terribly heavy. 

This patch changes memcg's oom logic as.
 * If memcg causes OOM-kill, continue to retry.
 * remove jiffies check which is used now.
 * add memcg-oom-lock which works like perzone oom lock.
 * If current is killed(as a process), bypass charge.

Something more sophisticated can be added but this pactch does
fundamental things.
TODO:
 - add oom notifier
 - add permemcg disable-oom-kill flag and freezer at oom.
 - more chances for wake up oom waiter (when changing memory limit etc..)

Changelog;
 - fixed mutex and prepare_to_wait order.
 - fixed per-memcg oom lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 --
 mm/memcontrol.c            |  109 +++++++++++++++++++++++++++++++++------------
 mm/oom_kill.c              |    8 ---
 3 files changed, 82 insertions(+), 41 deletions(-)

Index: mmotm-2.6.33-Feb11/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.33-Feb11.orig/include/linux/memcontrol.h
+++ mmotm-2.6.33-Feb11/include/linux/memcontrol.h
@@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
-extern bool mem_cgroup_oom_called(struct task_struct *task);
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
@@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(v
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
Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb11/mm/memcontrol.c
@@ -200,7 +200,7 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long	last_oom_jiffies;
+	atomic_t	oom_lock;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -1234,32 +1234,77 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
-bool mem_cgroup_oom_called(struct task_struct *task)
+static int mem_cgroup_oom_lock_cb(struct mem_cgroup *mem, void *data)
 {
-	bool ret = false;
-	struct mem_cgroup *mem;
-	struct mm_struct *mm;
+	int *val = (int *)data;
+	int x;
 
-	rcu_read_lock();
-	mm = task->mm;
-	if (!mm)
-		mm = &init_mm;
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
-		ret = true;
-	rcu_read_unlock();
-	return ret;
+	x = atomic_inc_return(&mem->oom_lock);
+	if (x > *val)
+		*val = x;
+	return 0;
 }
+/*
+ * Check OOM-Killer is already running under our hierarchy.
+ * If someone is running, return false.
+ */
+static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
+{
+	int check = 0;
+
+	mem_cgroup_walk_tree(mem, &check, mem_cgroup_oom_lock_cb);
 
-static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
+	if (check == 1)
+		return true;
+	return false;
+}
+
+static int mem_cgroup_oom_unlock_cb(struct mem_cgroup *mem, void *data)
 {
-	mem->last_oom_jiffies = jiffies;
+	atomic_dec(&mem->oom_lock);
 	return 0;
 }
 
-static void record_last_oom(struct mem_cgroup *mem)
+static void mem_cgroup_oom_unlock(struct mem_cgroup *mem)
+{
+	mem_cgroup_walk_tree(mem, NULL,	mem_cgroup_oom_unlock_cb);
+}
+
+static DEFINE_MUTEX(memcg_oom_mutex);
+static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
+
+/*
+ * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+ */
+bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 {
-	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
+	DEFINE_WAIT(wait);
+	bool locked;
+
+	/* At first, try to OOM lock hierarchy under mem.*/
+	mutex_lock(&memcg_oom_mutex);
+	locked = mem_cgroup_oom_lock(mem);
+	if (!locked)
+		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
+	mutex_unlock(&memcg_oom_mutex);
+
+	if (locked)
+		mem_cgroup_out_of_memory(mem, mask);
+	else {
+		schedule();
+		finish_wait(&memcg_oom_waitq, &wait);
+	}
+	mutex_lock(&memcg_oom_mutex);
+	mem_cgroup_oom_unlock(mem);
+	/* TODO: more fine grained waitq ? */
+	wake_up_all(&memcg_oom_waitq);
+	mutex_unlock(&memcg_oom_mutex);
+
+	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+		return false;
+	/* Give chance to dying process */
+	schedule_timeout(1);
+	return true;
 }
 
 /*
@@ -1432,11 +1477,14 @@ static int __mem_cgroup_try_charge(struc
 	struct res_counter *fail_res;
 	int csize = CHARGE_SIZE;
 
-	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
-		/* Don't account this! */
-		*memcg = NULL;
-		return 0;
-	}
+	/*
+	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
+	 * in system level. So, allow to go ahead dying process in addition to
+	 * MEMDIE process.
+	 */
+	if (unlikely(test_thread_flag(TIF_MEMDIE)
+		     || fatal_signal_pending(current)))
+		goto bypass;
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -1549,11 +1597,15 @@ static int __mem_cgroup_try_charge(struc
 		}
 
 		if (!nr_retries--) {
-			if (oom) {
-				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
-				record_last_oom(mem_over_limit);
+			if (!oom)
+				goto nomem;
+			if (mem_cgroup_handle_oom(mem_over_limit, gfp_mask)) {
+				nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+				continue;
 			}
-			goto nomem;
+			/* When we reach here, current task is dying .*/
+			css_put(&mem->css);
+			goto bypass;
 		}
 	}
 	if (csize > PAGE_SIZE)
@@ -1572,6 +1624,9 @@ done:
 nomem:
 	css_put(&mem->css);
 	return -ENOMEM;
+bypass:
+	*memcg = NULL;
+	return 0;
 }
 
 /*
Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb11/mm/oom_kill.c
@@ -599,13 +599,6 @@ void pagefault_out_of_memory(void)
 		/* Got some memory back in the last second. */
 		return;
 
-	/*
-	 * If this is from memcg, oom-killer is already invoked.
-	 * and not worth to go system-wide-oom.
-	 */
-	if (mem_cgroup_oom_called(current))
-		goto rest_and_return;
-
 	if (sysctl_panic_on_oom)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
@@ -617,7 +610,6 @@ void pagefault_out_of_memory(void)
 	 * Give "p" a good chance of killing itself before we
 	 * retry to allocate memory.
 	 */
-rest_and_return:
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
