Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BD6A96B011C
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 00:41:33 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C5fTY6017664
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 14:41:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D630245DE6F
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 14:41:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82B1445DE70
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 14:41:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E8441DB8040
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 14:41:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D620E18003
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 14:41:27 +0900 (JST)
Date: Fri, 12 Mar 2010 14:37:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3] memcg: oom kill disable and oom status
Message-Id: <20100312143753.420e7ae7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100312143435.e648e361.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143435.e648e361.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


I haven't get enough comment to this patch itself. But works well.
Feel free to request me if you want me to change some details.

==
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

Unlike OOM-Kill by the kernel, the users can take snapshot or coredump
of guilty process, cgroups.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   19 ++++++
 mm/memcontrol.c                  |  113 ++++++++++++++++++++++++++++++++-------
 2 files changed, 113 insertions(+), 19 deletions(-)

Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Mar9/mm/memcontrol.c
@@ -235,7 +235,8 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
-
+	/* Disable OOM killer */
+	unsigned long	oom_kill_disable;
 	/*
 	 * percpu counter.
 	 */
@@ -1340,20 +1341,26 @@ static void memcg_wakeup_oom(struct mem_
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, mem);
 }
 
+static void memcg_oom_recover(struct mem_cgroup *mem)
+{
+	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
+		memcg_wakeup_oom(mem);
+}
+
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
 bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 {
 	struct oom_wait_info owait;
-	bool locked;
+	bool locked, need_to_kill;
 
 	owait.mem = mem;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
-
+	need_to_kill = true;
 	/* At first, try to OOM lock hierarchy under mem.*/
 	mutex_lock(&memcg_oom_mutex);
 	locked = mem_cgroup_oom_lock(mem);
@@ -1362,15 +1369,17 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
-	if (!locked)
-		prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	else
+	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
+	if (!locked || mem->oom_kill_disable)
+		need_to_kill = false;
+	if (locked)
 		mem_cgroup_oom_notify(mem);
 	mutex_unlock(&memcg_oom_mutex);
 
-	if (locked)
+	if (need_to_kill) {
+		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(mem, mask);
-	else {
+	} else {
 		schedule();
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
@@ -2162,15 +2171,6 @@ __do_uncharge(struct mem_cgroup *mem, co
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
@@ -2181,6 +2181,17 @@ __do_uncharge(struct mem_cgroup *mem, co
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
@@ -2196,6 +2207,8 @@ direct_uncharge:
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	if (uncharge_memsw)
 		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	if (unlikely(batch->memcg != mem))
+		memcg_oom_recover(mem);
 	return;
 }
 
@@ -2332,6 +2345,7 @@ void mem_cgroup_uncharge_end(void)
 		res_counter_uncharge(&batch->memcg->res, batch->bytes);
 	if (batch->memsw_bytes)
 		res_counter_uncharge(&batch->memcg->memsw, batch->memsw_bytes);
+	memcg_oom_recover(batch->memcg);
 	/* forget this pointer (for sanity check) */
 	batch->memcg = NULL;
 }
@@ -2568,10 +2582,11 @@ static int mem_cgroup_resize_limit(struc
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
@@ -2582,6 +2597,7 @@ static int mem_cgroup_resize_limit(struc
 
 	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 
+	enlarge = 0;
 	while (retry_count) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
@@ -2599,6 +2615,11 @@ static int mem_cgroup_resize_limit(struc
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
@@ -2620,6 +2641,8 @@ static int mem_cgroup_resize_limit(struc
 		else
 			oldusage = curusage;
 	}
+	if (!ret && enlarge)
+		memcg_oom_recover(memcg);
 
 	return ret;
 }
@@ -2628,9 +2651,10 @@ static int mem_cgroup_resize_memsw_limit
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
@@ -2652,6 +2676,9 @@ static int mem_cgroup_resize_memsw_limit
 			mutex_unlock(&set_limit_mutex);
 			break;
 		}
+		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+		if (memswlimit < val)
+			enlarge = 1;
 		ret = res_counter_set_limit(&memcg->memsw, val);
 		if (!ret) {
 			if (memlimit == val)
@@ -2674,6 +2701,8 @@ static int mem_cgroup_resize_memsw_limit
 		else
 			oldusage = curusage;
 	}
+	if (!ret && enlarge)
+		memcg_oom_recover(memcg);
 	return ret;
 }
 
@@ -2865,6 +2894,7 @@ move_account:
 			if (ret)
 				break;
 		}
+		memcg_oom_recover(mem);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
 			goto try_to_free;
@@ -3649,6 +3679,46 @@ static int mem_cgroup_oom_unregister_eve
 	return 0;
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
@@ -3706,6 +3776,8 @@ static struct cftype mem_cgroup_files[] 
 	},
 	{
 		.name = "oom_control",
+		.read_map = mem_cgroup_oom_control_read,
+		.write_u64 = mem_cgroup_oom_control_write,
 		.register_event = mem_cgroup_oom_register_event,
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
@@ -3945,6 +4017,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
+		mem->oom_kill_disable = parent->oom_kill_disable;
 	}
 
 	if (parent && parent->use_hierarchy) {
@@ -4239,6 +4312,7 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.precharge) {
 		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
 		mc.precharge = 0;
+		memcg_oom_recover(mc.to);
 	}
 	/*
 	 * we didn't uncharge from mc.from at mem_cgroup_move_account(), so
@@ -4247,6 +4321,7 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.moved_charge) {
 		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
+		memcg_oom_recover(mc.from);
 	}
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
Index: mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.34-Mar9.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
@@ -493,6 +493,8 @@ It's applicable for root and non-root cg
 
 10. OOM Control
 
+memory.oom_control file is for OOM notification and other controls.
+
 Memory controler implements oom notifier using cgroup notification
 API (See cgroups.txt). It allows to register multiple oom notification
 delivery and gets notification when oom happens.
@@ -505,6 +507,23 @@ To register a notifier, application need
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
