Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D3EA6B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:15:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338FGpI003951
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:15:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5189445DD7E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:15:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29FE845DD78
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:15:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E88DDE08001
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:15:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8292BE08007
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:15:15 +0900 (JST)
Date: Fri, 3 Apr 2009 17:13:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/9] add more hooks and check in lazy manner
Message-Id: <20090403171349.aa598593.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Adds 2 more soft limit update hooks.
 - uncharge
 - write to memory.soft_limit_in_bytes file.
And fixes issues under hierarchy. (This is the most complicated part...)

Because ucharge() can be called under very busy spin_lock, all checks should be 
done in lazy. We can use this lazy work to charge() part and make use of it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 55 insertions(+), 11 deletions(-)

Index: softlimit-test2/mm/memcontrol.c
===================================================================
--- softlimit-test2.orig/mm/memcontrol.c
+++ softlimit-test2/mm/memcontrol.c
@@ -200,6 +200,8 @@ struct mem_cgroup {
 #define SL_ANON (0)
 #define SL_FILE (1)
 	atomic_t soft_limit_update;
+	struct work_struct soft_limit_work;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -989,6 +991,23 @@ static int mem_cgroup_soft_limit_prio(st
 	return __calc_soft_limit_prio(max_excess);
 }
 
+static struct mem_cgroup *
+mem_cgroup_soft_limit_need_check(struct mem_cgroup *mem)
+{
+	struct res_counter *c = &mem->res;
+	unsigned long excess, prio;
+
+	do {
+		excess = res_counter_soft_limit_excess(c) >> PAGE_SHIFT;
+		prio = __calc_soft_limit_prio(excess);
+		mem = container_of(c, struct mem_cgroup, res);
+		if (mem->soft_limit_priority != prio)
+			return mem;
+		c = c->parent;
+	} while (c);
+	return NULL;
+}
+
 static void __mem_cgroup_requeue(struct mem_cgroup *mem, int prio)
 {
 	/* enqueue to softlimit queue */
@@ -1028,18 +1047,36 @@ __mem_cgroup_update_soft_limit_cb(struct
 	return 0;
 }
 
-static void mem_cgroup_update_soft_limit(struct mem_cgroup *mem)
+static void mem_cgroup_update_soft_limit_work(struct work_struct *work)
 {
-	int priority;
+	struct mem_cgroup *mem;
+
+	mem = container_of(work, struct mem_cgroup, soft_limit_work);
+
+	mem_cgroup_walk_tree(mem, NULL, __mem_cgroup_update_soft_limit_cb);
+	atomic_set(&mem->soft_limit_update, 0);
+	css_put(&mem->css);
+}
+
+static void mem_cgroup_update_soft_limit_lazy(struct mem_cgroup *mem)
+{
+	int ret, priority;
+	struct mem_cgroup * root;
+
+	/*
+	 * check status change under hierarchy.
+	 */
+	root = mem_cgroup_soft_limit_need_check(mem);
+	if (!root)
+		return;
+
+	if (atomic_inc_return(&root->soft_limit_update) > 1)
+		return;
+	css_get(&root->css);
+	ret = schedule_work(&root->soft_limit_work);
+	if (!ret)
+		css_put(&root->css);
 
-	/* check status change */
-	priority = mem_cgroup_soft_limit_prio(mem);
-	if (priority != mem->soft_limit_priority &&
-	    atomic_inc_return(&mem->soft_limit_update) > 1) {
-		mem_cgroup_walk_tree(mem, NULL,
-				     __mem_cgroup_update_soft_limit_cb);
-		atomic_set(&mem->soft_limit_update, 0);
-	}
 	return;
 }
 
@@ -1145,7 +1182,7 @@ static int __mem_cgroup_try_charge(struc
 	}
 
 	if (soft_fail && mem_cgroup_soft_limit_check(mem))
-		mem_cgroup_update_soft_limit(mem);
+		mem_cgroup_update_soft_limit_lazy(mem);
 
 	return 0;
 nomem:
@@ -1625,6 +1662,9 @@ __mem_cgroup_uncharge_common(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	if (mem->soft_limit_priority && mem_cgroup_soft_limit_check(mem))
+		mem_cgroup_update_soft_limit_lazy(mem);
+
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -2163,6 +2203,9 @@ static int mem_cgroup_write(struct cgrou
 			ret = res_counter_set_soft_limit(&memcg->res, val);
 		else
 			ret = -EINVAL;
+		if (!ret)
+			mem_cgroup_update_soft_limit_lazy(memcg);
+
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
@@ -2648,6 +2691,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	INIT_LIST_HEAD(&mem->soft_limit_list[SL_ANON]);
 	INIT_LIST_HEAD(&mem->soft_limit_list[SL_FILE]);
 	spin_lock_init(&mem->reclaim_param_lock);
+	INIT_WORK(&mem->soft_limit_work, mem_cgroup_update_soft_limit_work);
 
 	if (parent)
 		mem->swappiness = get_swappiness(parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
