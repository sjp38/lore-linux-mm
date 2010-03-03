Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DA8176B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 02:26:39 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o237QaT7004621
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 16:26:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72BF545DE51
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 16:26:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 443C345DE4F
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 16:26:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29DCD1DB803A
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 16:26:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2E21E38002
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 16:26:35 +0900 (JST)
Date: Wed, 3 Mar 2010 16:23:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix oom kill behavior v3
Message-Id: <20100303162304.eaf49099.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303093844.cf768ea4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302135524.afe2f7ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302143738.5cd42026.nishimura@mxp.nes.nec.co.jp>
	<20100302145644.0f8fbcca.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302151544.59c23678.nishimura@mxp.nes.nec.co.jp>
	<20100303092606.2e2152fc.nishimura@mxp.nes.nec.co.jp>
	<20100303093844.cf768ea4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 09:38:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 3 Mar 2010 09:26:06 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > I'll test this patch all through this night, and check whether it doesn't trigger
> > > global oom after memcg's oom.
> > > 
> > O.K. It works well.
> > Feel free to add my signs.
> > 
> > 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> 
> Thank you !
> 
> I'll apply Balbir's comment and post v3.
> 

rebased onto mmotm-Mar2.
tested on x86-64.


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

Changelog 20100303
 - added comments
Changelog 20100302
 - fixed mutex and prepare_to_wait order.
 - fixed per-memcg oom lock.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 --
 mm/memcontrol.c            |  119 ++++++++++++++++++++++++++++++++++-----------
 mm/oom_kill.c              |    8 ---
 3 files changed, 92 insertions(+), 41 deletions(-)

Index: mmotm-2.6.33-Mar2/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.33-Mar2.orig/include/linux/memcontrol.h
+++ mmotm-2.6.33-Mar2/include/linux/memcontrol.h
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
Index: mmotm-2.6.33-Mar2/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Mar2.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Mar2/mm/memcontrol.c
@@ -203,7 +203,7 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long	last_oom_jiffies;
+	atomic_t	oom_lock;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -1246,32 +1246,87 @@ static int mem_cgroup_hierarchical_recla
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
+	*val = max(x, *val);
+	return 0;
 }
+/*
+ * Check OOM-Killer is already running under our hierarchy.
+ * If someone is running, return false.
+ */
+static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
+{
+	int lock_count = 0;
+
+	mem_cgroup_walk_tree(mem, &lock_count, mem_cgroup_oom_lock_cb);
 
-static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
+	if (lock_count == 1)
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
 {
-	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
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
+{
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
+	/*
+ 	 * Here, we use global waitq .....more fine grained waitq ?
+ 	 * Assume following hierarchy.
+ 	 * A/
+ 	 *   01
+ 	 *   02
+ 	 * assume OOM happens both in A and 01 at the same time. Tthey are
+ 	 * mutually exclusive by lock. (kill in 01 helps A.)
+ 	 * When we use per memcg waitq, we have to wake up waiters on A and 02
+ 	 * in addtion to waiters on 01. We use global waitq for avoiding mess.
+ 	 * It will not be a big problem.
+ 	 */
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
@@ -1443,11 +1498,14 @@ static int __mem_cgroup_try_charge(struc
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
@@ -1560,11 +1618,15 @@ static int __mem_cgroup_try_charge(struc
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
@@ -1574,6 +1636,9 @@ done:
 nomem:
 	css_put(&mem->css);
 	return -ENOMEM;
+bypass:
+	*memcg = NULL;
+	return 0;
 }
 
 /*
Index: mmotm-2.6.33-Mar2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Mar2.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Mar2/mm/oom_kill.c
@@ -603,13 +603,6 @@ void pagefault_out_of_memory(void)
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
 
@@ -621,7 +614,6 @@ void pagefault_out_of_memory(void)
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
