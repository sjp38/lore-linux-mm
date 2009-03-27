Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 134DC6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 00:58:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R55EJq007289
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:05:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1237745DD72
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:05:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC0F845DE4F
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:05:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D4C1DB803E
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:05:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F8A5E18001
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:05:13 +0900 (JST)
Date: Fri, 27 Mar 2009 14:03:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/8] soft limit framework in memcg.
Message-Id: <20090327140346.8d27b69a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add minimal modification for soft limit to res_counter_charge() and memcontol.c
Based on Balbir Singh <balbir@linux.vnet.ibm.com> 's work but most of
features are removed. (dropped or moved to later patch.)

This is for building a frame to implement soft limit handler in memcg.
 - Checks soft limit status at every charge.
 - Adds mem_cgroup_soft_limit_check() as a function to detect we need
   check now or not.
 - mem_cgroup_update_soft_limit() is a function for updates internal status
   of soft limit controller of memcg.
 - This has no hooks in uncharge path. (see later patch.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.29-Mar23/include/linux/res_counter.h
===================================================================
--- mmotm-2.6.29-Mar23.orig/include/linux/res_counter.h
+++ mmotm-2.6.29-Mar23/include/linux/res_counter.h
@@ -112,7 +112,8 @@ void res_counter_init(struct res_counter
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
+		unsigned long val, struct res_counter **limit_fail_at,
+		bool *soft_limit_failure);
 
 /*
  * uncharge - tell that some portion of the resource is released
Index: mmotm-2.6.29-Mar23/kernel/res_counter.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/kernel/res_counter.c
+++ mmotm-2.6.29-Mar23/kernel/res_counter.c
@@ -37,9 +37,11 @@ int res_counter_charge_locked(struct res
 }
 
 int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at)
+			struct res_counter **limit_fail_at,
+			bool *soft_limit_failure)
 {
 	int ret;
+	int soft_cnt = 0;
 	unsigned long flags;
 	struct res_counter *c, *u;
 
@@ -48,6 +50,8 @@ int res_counter_charge(struct res_counte
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
 		ret = res_counter_charge_locked(c, val);
+		if (!res_counter_soft_limit_check_locked(c))
+			soft_cnt += 1;
 		spin_unlock(&c->lock);
 		if (ret < 0) {
 			*limit_fail_at = c;
@@ -55,6 +59,12 @@ int res_counter_charge(struct res_counte
 		}
 	}
 	ret = 0;
+	if (soft_limit_failure) {
+		if (!soft_cnt)
+			*soft_limit_failure = false;
+		else
+			*soft_limit_failure = true;
+	}
 	goto done;
 undo:
 	for (u = counter; u != c; u = u->parent) {
Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar23/mm/memcontrol.c
@@ -897,6 +897,15 @@ static void record_last_oom(struct mem_c
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
+static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
+{
+	return false;
+}
+
+static void mem_cgroup_update_soft_limit(struct mem_cgroup *mem)
+{
+	return;
+}
 
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
@@ -909,6 +918,7 @@ static int __mem_cgroup_try_charge(struc
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
+	bool soft_fail;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -938,12 +948,13 @@ static int __mem_cgroup_try_charge(struc
 		int ret;
 		bool noswap = false;
 
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
+		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
+						&soft_fail);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
 			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
-							&fail_res);
+							&fail_res, NULL);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
@@ -985,6 +996,10 @@ static int __mem_cgroup_try_charge(struc
 			goto nomem;
 		}
 	}
+
+	if (soft_fail && mem_cgroup_soft_limit_check(mem))
+		mem_cgroup_update_soft_limit(mem);
+
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -2409,6 +2424,7 @@ static void __mem_cgroup_free(struct mem
 {
 	int node;
 
+	mem_cgroup_update_soft_limit(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
