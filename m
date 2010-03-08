Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 59D676B0047
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 02:30:47 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o287UiSN021131
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 8 Mar 2010 16:30:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9758445DE4D
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:30:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BAAF45DE4E
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:30:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C8CBE38005
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:30:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB2541DB804D
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:30:43 +0900 (JST)
Date: Mon, 8 Mar 2010 16:27:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2]  memcg: oom killer disable and hooks for stop and
 recover
Message-Id: <20100308162710.d0d82c03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This adds a feature to disable oom-killer for memcg, if disabled,
of course, tasks under memcg will stop.

But now, we have oom-notifier for memcg. And the world around
memcg is not under out-of-memory. memcg's out-of-memory just
shows memcg hits limit. Then, administrator or
management daemon can recover the situation by
	- kill some process
	- enlarge limit, add more swap.
	- migrate some tasks
	- remove file cache on tmps (difficult ?)

TODO:
	more brush up and find races.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   19 ++++++
 mm/memcontrol.c                  |  118 ++++++++++++++++++++++++++++++++++-----
 2 files changed, 122 insertions(+), 15 deletions(-)

Index: mmotm-2.6.33-Mar5/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Mar5.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Mar5/mm/memcontrol.c
@@ -229,7 +229,8 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
-
+	/* Disable OOM killer */
+	unsigned long	oom_kill_disable;
 	/*
 	 * percpu counter.
 	 */
@@ -1300,14 +1301,30 @@ static void mem_cgroup_oom_unlock(struct
 static DEFINE_MUTEX(memcg_oom_mutex);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
+void memcg_oom_recover(struct mem_cgroup *mem)
+{
+	/*
+	 * This may wakes up unrelated threads, but handling complex
+	 * hierarchy is painful and there is no big side-efffect for
+	 * wake up.
+	 *
+	 * Note: This function is called by __do_uncharge(). In extreme case,
+	 * we may not able to guarantee *mem is a valid memcg. But we do
+	 * no "write", side-effect is just (false) wake up.
+	 */
+	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
+		wake_up_all(&memcg_oom_waitq);
+}
+
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
 bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 {
 	DEFINE_WAIT(wait);
-	bool locked;
+	bool locked, notify;
 
+	notify = false;
 	/* At first, try to OOM lock hierarchy under mem.*/
 	mutex_lock(&memcg_oom_mutex);
 	locked = mem_cgroup_oom_lock(mem);
@@ -1316,12 +1333,17 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
-	if (!locked)
+	if (!locked || mem->oom_kill_disable) {
+		notify = !waitqueue_active(&memcg_oom_waitq);
 		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_KILLABLE);
+		locked = false;
+	}
 	mutex_unlock(&memcg_oom_mutex);
 
-	if (locked) {
+	if (locked || notify) /* we do lock or we're the 1st waiter */
 		mem_cgroup_oom_notify(mem);
+
+	if (locked) {
 		mem_cgroup_out_of_memory(mem, mask);
 	} else {
 		schedule();
@@ -2128,15 +2150,6 @@ __do_uncharge(struct mem_cgroup *mem, co
 	/* If swapout, usage of swap doesn't decrease */
 	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		uncharge_memsw = false;
-	/*
-	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
-	 * In those cases, all pages freed continously can be expected to be in
-	 * the same cgroup and we have chance to coalesce uncharges.
-	 * But we do uncharge one by one if this is killed by OOM(TIF_MEMDIE)
-	 * because we want to do uncharge as soon as possible.
-	 */
-	if (!current->memcg_batch.do_batch || test_thread_flag(TIF_MEMDIE))
-		goto direct_uncharge;
 
 	batch = &current->memcg_batch;
 	/*
@@ -2147,6 +2160,17 @@ __do_uncharge(struct mem_cgroup *mem, co
 	if (!batch->memcg)
 		batch->memcg = mem;
 	/*
+	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
+	 * In those cases, all pages freed continously can be expected to be in
+	 * the same cgroup and we have chance to coalesce uncharges.
+	 * But we do uncharge one by one if this is killed by OOM(TIF_MEMDIE)
+	 * because we want to do uncharge as soon as possible.
+	 */
+
+	if (!batch->do_batch || test_thread_flag(TIF_MEMDIE))
+		goto direct_uncharge;
+
+	/*
 	 * In typical case, batch->memcg == mem. This means we can
 	 * merge a series of uncharges to an uncharge of res_counter.
 	 * If not, we uncharge res_counter ony by one.
@@ -2162,6 +2186,8 @@ direct_uncharge:
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	if (uncharge_memsw)
 		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	if (unlikely(batch->memcg != mem))
+		memcg_oom_recover(mem);
 	return;
 }
 
@@ -2298,6 +2324,7 @@ void mem_cgroup_uncharge_end(void)
 		res_counter_uncharge(&batch->memcg->res, batch->bytes);
 	if (batch->memsw_bytes)
 		res_counter_uncharge(&batch->memcg->memsw, batch->memsw_bytes);
+	memcg_oom_recover(batch->memcg);
 	/* forget this pointer (for sanity check) */
 	batch->memcg = NULL;
 }
@@ -2534,10 +2561,11 @@ static int mem_cgroup_resize_limit(struc
 				unsigned long long val)
 {
 	int retry_count;
-	u64 memswlimit;
+	u64 memswlimit, memlimit;
 	int ret = 0;
 	int children = mem_cgroup_count_children(memcg);
 	u64 curusage, oldusage;
+	int enlarge;
 
 	/*
 	 * For keeping hierarchical_reclaim simple, how long we should retry
@@ -2548,6 +2576,7 @@ static int mem_cgroup_resize_limit(struc
 
 	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 
+	enlarge = 0;
 	while (retry_count) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
@@ -2565,6 +2594,11 @@ static int mem_cgroup_resize_limit(struc
 			mutex_unlock(&set_limit_mutex);
 			break;
 		}
+
+		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+		if (memlimit < val)
+			enlarge = 1;
+
 		ret = res_counter_set_limit(&memcg->res, val);
 		if (!ret) {
 			if (memswlimit == val)
@@ -2586,6 +2620,8 @@ static int mem_cgroup_resize_limit(struc
 		else
 			oldusage = curusage;
 	}
+	if (!ret && enlarge)
+		memcg_oom_recover(memcg);
 
 	return ret;
 }
@@ -2594,9 +2630,10 @@ static int mem_cgroup_resize_memsw_limit
 					unsigned long long val)
 {
 	int retry_count;
-	u64 memlimit, oldusage, curusage;
+	u64 memlimit, memswlimit, oldusage, curusage;
 	int children = mem_cgroup_count_children(memcg);
 	int ret = -EBUSY;
+	int enlarge = 0;
 
 	/* see mem_cgroup_resize_res_limit */
  	retry_count = children * MEM_CGROUP_RECLAIM_RETRIES;
@@ -2618,6 +2655,9 @@ static int mem_cgroup_resize_memsw_limit
 			mutex_unlock(&set_limit_mutex);
 			break;
 		}
+		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+		if (memswlimit < val)
+			enlarge = 1;
 		ret = res_counter_set_limit(&memcg->memsw, val);
 		if (!ret) {
 			if (memlimit == val)
@@ -2640,6 +2680,8 @@ static int mem_cgroup_resize_memsw_limit
 		else
 			oldusage = curusage;
 	}
+	if (!ret && enlarge)
+		memcg_oom_recover(memcg);
 	return ret;
 }
 
@@ -2831,6 +2873,7 @@ move_account:
 			if (ret)
 				break;
 		}
+		memcg_oom_recover(mem);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
 			goto try_to_free;
@@ -3596,6 +3639,46 @@ unlock:
 	return ret;
 }
 
+static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	cb->fill(cb, "oom_kill_disable", mem->oom_kill_disable);
+
+	if (atomic_read(&mem->oom_lock))
+		cb->fill(cb, "under_oom", 1);
+	else
+		cb->fill(cb, "under_oom", 0);
+	return 0;
+}
+
+/*
+ */
+static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
+	struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *parent;
+
+	/* cannot set to root cgroup and only 0 and 1 are allowed */
+	if (!cgrp->parent || !((val == 0) || (val == 1)))
+		return -EINVAL;
+
+	parent = mem_cgroup_from_cont(cgrp->parent);
+
+	cgroup_lock();
+	/* oom-kill-disable is a flag for subhierarchy. */
+	if ((parent->use_hierarchy) ||
+	    (mem->use_hierarchy && !list_empty(&cgrp->children))) {
+		cgroup_unlock();
+		return -EINVAL;
+	}
+	mem->oom_kill_disable = val;
+	cgroup_unlock();
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -3653,6 +3736,8 @@ static struct cftype mem_cgroup_files[] 
 	},
 	{
 		.name = "oom_control",
+		.read_map = mem_cgroup_oom_control_read,
+		.write_u64 = mem_cgroup_oom_control_write,
 		.register_event = mem_cgroup_register_event,
 		.unregister_event = mem_cgroup_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
@@ -3892,6 +3977,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
+		mem->oom_kill_disable = parent->oom_kill_disable;
 	}
 
 	if (parent && parent->use_hierarchy) {
@@ -4162,6 +4248,7 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.precharge) {
 		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
 		mc.precharge = 0;
+		memcg_oom_recover(mc.to);
 	}
 	/*
 	 * we didn't uncharge from mc.from at mem_cgroup_move_account(), so
@@ -4170,6 +4257,7 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.moved_charge) {
 		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
+		memcg_oom_recover(mc.from);
 	}
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
Index: mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.33-Mar5.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
@@ -491,6 +491,8 @@ It's applicable for root and non-root cg
 
 10. OOM Control
 
+memory.oom_control file is for OOM notification and other controls.
+
 Memory controler implements oom notifier using cgroup notification
 API (See cgroups.txt). It allows to register multiple oom notification
 delivery and gets notification when oom happens.
@@ -503,6 +505,23 @@ To register a notifier, application need
 Application will be notifier through eventfd when oom happens.
 OOM notification doesn't work for root cgroup.
 
+You can disable oom-killer by writing "1" to memory.oom_control file.
+As.
+	#echo 1 > memory.oom_control
+
+This operation is only allowed to the top cgroup of subhierarchy.
+If oom-killer is disabled, tasks under cgroup will hang/sleep
+in memcg's oom-waitq when they request accountable memory.
+For running them, you have to relax the memcg's oom sitaution by
+	* enlarge limit
+	* kill some tasks.
+	* move some tasks to other group with account migration.
+Then, stopped tasks will work again.
+
+At reading, current status of OOM is shown.
+	oom_kill_disable 0 or 1 (if 1, oom-killer is disabled)
+	under_oom	 0 or 1 (if 1, the memcg is under OOM,tasks may
+				 be stopped.)
 
 11. TODO
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
