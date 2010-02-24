Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6EFB86B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 03:05:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O85Ekl022253
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 17:05:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5340045DE51
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:05:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 30A7745DE57
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:05:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6281DB8042
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:05:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB8E21DB8041
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:05:13 +0900 (JST)
Date: Wed, 24 Feb 2010 17:01:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: oom kill nofify and disable oom kill for
 memcg.
Message-Id: <20100224170146.57364e1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is just a toy for considering problem.

memcg's OOM means "the usage hits limit" and doesn't mean "there is no
resource.". So, user-land daemon may be able to do better jobs than
default oom-killer.

This patch adds 
  - oom notifier for memcg.
    Implementation is baed on threshold notifier.
  - dislable_oom flag.
    If set, avoid to call oom-killer and wait for event (uncharge etc..)

Assume a user land daemon which works on root cgroup.
  - the daemon registers event fd to wait for memcg's OOM
    % ./cgroup_event_listener /cgroup/A/memory.usage_in_bytes OOM
  - set memcg's oom-killing disabled.
    % echo 1 > /cgroup/A/memory.disable_oom_kill
After wakeup, the daemon can...
  - enlarge limit. (adding swap etc.)
  - kill some processes.
  - move processes to other group.
  - send signal to _important_ processes to safe terminate and
    send SIGSTOP to others. ennlarge limit for a while.

TODO:
  - many...?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  144 +++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 117 insertions(+), 27 deletions(-)

Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb11/mm/memcontrol.c
@@ -216,6 +216,10 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *memsw_thresholds;
 
+	/* Notifiers for OOM situation */
+	struct mem_cgroup_threshold_ary *oom_notify;
+	int oom_kill_disabled;
+
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -1143,6 +1147,7 @@ static void memcg_oom_wake(void)
  * Check there are ongoing oom-kill in this hierarchy or not.
  * If now under oom-kill, wait for some event to restart job.
  */
+static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 static bool memcg_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 {
 	int oom_count = 0;
@@ -1161,8 +1166,14 @@ static bool memcg_handle_oom(struct mem_
 	mem_cgroup_walk_tree(mem, &oom_count, set_memcg_oom_cb);
 	/* Am I the 1st oom killer in this sub hierarchy ? */
 	if (oom_count == 1) {
-		finish_wait(&memcg_oom_waitq, &wait);
-		mem_cgroup_out_of_memory(mem, mask);
+		mem_cgroup_oom_notify(mem);
+		if (!mem->oom_kill_disabled) {
+			finish_wait(&memcg_oom_waitq, &wait);
+			mem_cgroup_out_of_memory(mem, mask);
+		} else { /* give chance admin daemon to run */
+			schedule();
+			finish_wait(&memcg_oom_waitq, &wait);
+		}
 		mem_cgroup_walk_tree(mem, NULL, unset_memcg_oom_cb);
 	} else {
 		/*
@@ -3141,6 +3152,35 @@ static int mem_cgroup_move_charge_write(
 	return 0;
 }
 
+static u64 mem_cgroup_oom_kill_disable_read(struct cgroup *cgrp,
+				struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cgrp)->oom_kill_disabled;
+}
+
+static int mem_cgroup_oom_kill_disable_write(struct cgroup *cgrp,
+				struct cftype *cft, u64 val)
+{
+	struct cgroup *parent = cgrp->parent;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *parent_mem = NULL;
+	int retval = 0;
+
+	if (val > 1)
+		return -EINVAL;
+	/*
+	 * can be set only to root cgroup.
+	 */
+	if (parent)
+		parent_mem = mem_cgroup_from_cont(parent);
+	cgroup_lock();
+	if (!parent_mem || !parent_mem->use_hierarchy)
+		mem->oom_kill_disabled = val;
+	else
+		retval = -EINVAL;
+	cgroup_unlock();
+	return retval;
+}
 
 /* For read statistics */
 enum {
@@ -3405,6 +3445,25 @@ static int compare_thresholds(const void
 	return _a->threshold - _b->threshold;
 }
 
+static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
+{
+	struct mem_cgroup_threshold_ary *t;
+	int i;
+
+	rcu_read_lock();
+	t = rcu_dereference(mem->oom_notify);
+
+	for (i = 0; i < t->size; i++)
+		eventfd_signal(t->entries[i].eventfd, 1);
+	rcu_read_unlock();
+	return 0;
+}
+
+static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
+{
+	mem_cgroup_walk_tree(memcg, NULL, mem_cgroup_oom_notify_cb);
+}
+
 static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
 		struct eventfd_ctx *eventfd, const char *args)
 {
@@ -3414,23 +3473,30 @@ static int mem_cgroup_register_event(str
 	u64 threshold, usage;
 	int size;
 	int i, ret;
+	int oom = 0;
 
 	ret = res_counter_memparse_write_strategy(args, &threshold);
-	if (ret)
+	if (ret) {
+		if (!strcmp(args, "oom") || !strcmp(args, "OOM"))
+			oom = 1;
 		return ret;
-
+	}
 	mutex_lock(&memcg->thresholds_lock);
-	if (type == _MEM)
-		thresholds = memcg->thresholds;
-	else if (type == _MEMSWAP)
-		thresholds = memcg->memsw_thresholds;
-	else
-		BUG();
+	if (!oom) {
+		if (type == _MEM)
+			thresholds = memcg->thresholds;
+		else if (type == _MEMSWAP)
+			thresholds = memcg->memsw_thresholds;
+		else
+			BUG();
+	} else {
+		thresholds = memcg->oom_notify;
+	}
 
 	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
 	/* Check if a threshold crossed before adding a new one */
-	if (thresholds)
+	if (!oom && thresholds)
 		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
 
 	if (thresholds)
@@ -3458,20 +3524,22 @@ static int mem_cgroup_register_event(str
 	thresholds_new->entries[size - 1].threshold = threshold;
 
 	/* Sort thresholds. Registering of new threshold isn't time-critical */
-	sort(thresholds_new->entries, size,
+	if (!oom) {
+		sort(thresholds_new->entries, size,
 			sizeof(struct mem_cgroup_threshold),
 			compare_thresholds, NULL);
 
-	/* Find current threshold */
-	atomic_set(&thresholds_new->current_threshold, -1);
-	for (i = 0; i < size; i++) {
-		if (thresholds_new->entries[i].threshold < usage) {
+		/* Find current threshold */
+		atomic_set(&thresholds_new->current_threshold, -1);
+		for (i = 0; i < size; i++) {
+			if (thresholds_new->entries[i].threshold < usage) {
 			/*
 			 * thresholds_new->current_threshold will not be used
 			 * until rcu_assign_pointer(), so it's safe to increment
 			 * it here.
 			 */
-			atomic_inc(&thresholds_new->current_threshold);
+				atomic_inc(&thresholds_new->current_threshold);
+			}
 		}
 	}
 
@@ -3480,11 +3548,12 @@ static int mem_cgroup_register_event(str
 	 * will be unregistered before calling __mem_cgroup_free()
 	 */
 	mem_cgroup_get(memcg);
-
-	if (type == _MEM)
+	if (oom)
+		rcu_assign_pointer(memcg->oom_notify, thresholds_new);
+	else if (type == _MEM)
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
 	else
-		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+		rcu_assign_pointer(memcg->memsw_thresholds,thresholds_new);
 
 	/* To be sure that nobody uses thresholds before freeing it */
 	synchronize_rcu();
@@ -3502,8 +3571,9 @@ static int mem_cgroup_unregister_event(s
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
 	int type = MEMFILE_TYPE(cft->private);
-	u64 usage;
+	u64 usage = 0;
 	int size = 0;
+	int oom = 0;
 	int i, j, ret;
 
 	mutex_lock(&memcg->thresholds_lock);
@@ -3513,17 +3583,29 @@ static int mem_cgroup_unregister_event(s
 		thresholds = memcg->memsw_thresholds;
 	else
 		BUG();
-
+	/* check it's oom notify or not */
+	if (memcg->oom_notify) {
+		for (i = 0; i < memcg->oom_notify->size; i++) {
+			if (memcg->oom_notify->entries[i].eventfd ==
+				eventfd) {
+				thresholds = memcg->oom_notify;
+				oom = 1;
+				break;
+			}
+		}
+	}
 	/*
 	 * Something went wrong if we trying to unregister a threshold
 	 * if we don't have thresholds
 	 */
 	BUG_ON(!thresholds);
 
-	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
+	if (!oom) {
+		usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
-	/* Check if a threshold crossed before removing */
-	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+		/* Check if a threshold crossed before removing */
+		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+	}
 
 	/* Calculate new number of threshold */
 	for (i = 0; i < thresholds->size; i++) {
@@ -3554,7 +3636,7 @@ static int mem_cgroup_unregister_event(s
 			continue;
 
 		thresholds_new->entries[j] = thresholds->entries[i];
-		if (thresholds_new->entries[j].threshold < usage) {
+		if (!oom && thresholds_new->entries[j].threshold < usage) {
 			/*
 			 * thresholds_new->current_threshold will not be used
 			 * until rcu_assign_pointer(), so it's safe to increment
@@ -3566,7 +3648,9 @@ static int mem_cgroup_unregister_event(s
 	}
 
 assign:
-	if (type == _MEM)
+	if (oom)
+		rcu_assign_pointer(memcg->oom_notify, thresholds_new);
+	else if (type == _MEM)
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
 	else
 		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
@@ -3639,6 +3723,11 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
 	},
+	{
+		.name = "disable_oom_kill",
+		.read_u64 = mem_cgroup_oom_kill_disable_read,
+		.write_u64 = mem_cgroup_oom_kill_disable_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -3886,6 +3975,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		 * mem_cgroup(see mem_cgroup_put).
 		 */
 		mem_cgroup_get(parent);
+		mem->oom_kill_disabled = parent->oom_kill_disabled;
 	} else {
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
