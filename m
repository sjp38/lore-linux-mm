Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C88566B0204
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:53:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G0rTXH025332
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Mar 2010 09:53:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2546845DE50
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:53:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0236B45DE4E
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:53:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1990E38002
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:53:28 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DCC61DB8041
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:53:28 +0900 (JST)
Date: Tue, 16 Mar 2010 09:49:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3] memcg: oom wakeup filter (v5)
Message-Id: <20100316094951.babe938c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Updated comments.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memcg's oom waitqueue is a system-wide wait_queue (for handling hierarchy.)
So, it's better to add custom wake function and do flitering in wake up path.

This patch adds a filtering feature for waking up oom-waiters.
Hierarchy is properly handled.

Changelog 20100316
 - fixed comment.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   63 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 46 insertions(+), 17 deletions(-)

Index: mmotm-2.6.34-Mar11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Mar11.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Mar11/mm/memcontrol.c
@@ -1293,14 +1293,56 @@ static void mem_cgroup_oom_unlock(struct
 static DEFINE_MUTEX(memcg_oom_mutex);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
+struct oom_wait_info {
+	struct mem_cgroup *mem;
+	wait_queue_t	wait;
+};
+
+static int memcg_oom_wake_function(wait_queue_t *wait,
+	unsigned mode, int sync, void *arg)
+{
+	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
+	struct oom_wait_info *oom_wait_info;
+
+	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
+
+	if (oom_wait_info->mem == wake_mem)
+		goto wakeup;
+	/* if no hierarchy, no match */
+	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
+		return 0;
+	/*
+	 * Both of oom_wait_info->mem and wake_mem are stable under us.
+	 * Then we can use css_is_ancestor without taking care of RCU.
+	 */
+	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
+	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
+		return 0;
+
+wakeup:
+	return autoremove_wake_function(wait, mode, sync, arg);
+}
+
+static void memcg_wakeup_oom(struct mem_cgroup *mem)
+{
+	/* for filtering, pass "mem" as argument. */
+	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, mem);
+}
+
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
 bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 {
-	DEFINE_WAIT(wait);
+	struct oom_wait_info owait;
 	bool locked;
 
+	owait.mem = mem;
+	owait.wait.flags = 0;
+	owait.wait.func = memcg_oom_wake_function;
+	owait.wait.private = current;
+	INIT_LIST_HEAD(&owait.wait.task_list);
+
 	/* At first, try to OOM lock hierarchy under mem.*/
 	mutex_lock(&memcg_oom_mutex);
 	locked = mem_cgroup_oom_lock(mem);
@@ -1310,31 +1352,18 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	if (!locked)
-		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_KILLABLE);
+		prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
 	mutex_unlock(&memcg_oom_mutex);
 
 	if (locked)
 		mem_cgroup_out_of_memory(mem, mask);
 	else {
 		schedule();
-		finish_wait(&memcg_oom_waitq, &wait);
+		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 	mutex_lock(&memcg_oom_mutex);
 	mem_cgroup_oom_unlock(mem);
-	/*
-	 * Here, we use global waitq .....more fine grained waitq ?
-	 * Assume following hierarchy.
-	 * A/
-	 *   01
-	 *   02
-	 * assume OOM happens both in A and 01 at the same time. Tthey are
-	 * mutually exclusive by lock. (kill in 01 helps A.)
-	 * When we use per memcg waitq, we have to wake up waiters on A and 02
-	 * in addtion to waiters on 01. We use global waitq for avoiding mess.
-	 * It will not be a big problem.
-	 * (And a task may be moved to other groups while it's waiting for OOM.)
-	 */
-	wake_up_all(&memcg_oom_waitq);
+	memcg_wakeup_oom(mem);
 	mutex_unlock(&memcg_oom_mutex);
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
