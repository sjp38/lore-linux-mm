Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 569D76B0103
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:32:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 551143EE0AE
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:32:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3109445DE50
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:32:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 138D345DD74
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:32:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 053FE1DB803C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:32:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A185A1DB802C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:32:08 +0900 (JST)
Message-ID: <4F86BCCE.5050802@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:30:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 6/7] memcg: remove pre_destroy()
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Tejun Heo, cgroup maintainer, tries to remove ->pre_destroy() to
prevent rmdir() from failure of EBUSY or some.

This patch removes pre_destroy() in memcg. All remaining charges
will be moved to other cgroup, without any failure,  ->destroy()
just schedule a work and it will destroy the memcg.
Then, rmdir will never fail. The kernel will take care of remaining
resources in the cgroup to be accounted correctly.

After this patch, memcg will be destroyed by workqueue in asynchrnous way.
Then, we can modify 'moving' logic to work asynchrnously, i.e,
we don't force users to wait for the end of rmdir(), now. We don't
need to use heavy synchronous calls. This patch modifies logics as

 - Use mem_cgroup_drain_stock_async rather tan drain_stock_sync.
 - lru_add_drain_all() will be called only when necessary, in a lazy way.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   52 ++++++++++++++++++++++------------------------------
 1 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22c8faa..e466809 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -315,6 +315,8 @@ struct mem_cgroup {
 #ifdef CONFIG_INET
 	struct tcp_memcontrol tcp_mem;
 #endif
+
+	struct work_struct work_destroy;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -2105,7 +2107,6 @@ static void drain_all_stock_async(struct mem_cgroup *root_memcg)
 	mutex_unlock(&percpu_charge_mutex);
 }
 
-/* This is a synchronous drain interface. */
 static void drain_all_stock_sync(struct mem_cgroup *root_memcg)
 {
 	/* called when force_empty is called */
@@ -3661,10 +3662,9 @@ static int mem_cgroup_recharge_lru(struct mem_cgroup *memcg,
 		pc = lookup_page_cgroup(page);
 
 		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
-		if (ret == -EINTR)
-			break;
 
-		if (ret == -EBUSY || ret == -EINVAL) {
+		VM_BUG_ON(ret != 0 && ret != -EBUSY);
+		if (ret) {
 			/* found lock contention or "pc" is obsolete. */
 			busy = page;
 			cond_resched();
@@ -3677,22 +3677,19 @@ static int mem_cgroup_recharge_lru(struct mem_cgroup *memcg,
 	return ret;
 }
 
-
-static int mem_cgroup_recharge(struct mem_cgroup *memcg)
+/*
+ * This function is called after ->destroy(). So, we cannot access cgroup
+ * of this memcg.
+ */
+static void mem_cgroup_recharge(struct work_struct *work)
 {
+	struct mem_cgroup *memcg;
 	int ret, node, zid;
-	struct cgroup *cgrp = memcg->css.cgroup;
 
+	memcg = container_of(work, struct mem_cgroup, work_destroy);
+	/* No task points this memcg. call this only once */
+	drain_all_stock_async(memcg);
 	do {
-		ret = -EBUSY;
-		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
-			goto out;
-		ret = -EINTR;
-		if (signal_pending(current))
-			goto out;
-		/* This is for making all *used* pages to be on LRU. */
-		lru_add_drain_all();
-		drain_all_stock_sync(memcg);
 		ret = 0;
 		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
@@ -3710,13 +3707,14 @@ static int mem_cgroup_recharge(struct mem_cgroup *memcg)
 		}
 		mem_cgroup_end_move(memcg);
 		cond_resched();
-	/* "ret" should also be checked to ensure all lists are empty. */
-	} while (memcg->res.usage > 0 || ret);
-out:
-	return ret;
+		/* drain LRU only when we canoot find pages on LRU */
+		if (res_counter_read_u64(&memcg->res, RES_USAGE) &&
+		    !mem_cgroup_nr_lru_pages(memcg, LRU_ALL))
+			lru_add_drain_all();
+	} while (res_counter_read_u64(&memcg->res, RES_USAGE) || ret);
+	mem_cgroup_put(memcg);
 }
 
-
 /*
  * make mem_cgroup's charge to be 0 if there is no task. This is only called
  * by memory.force_empty file, an user request.
@@ -4803,6 +4801,7 @@ static void vfree_work(struct work_struct *work)
 	memcg = container_of(work, struct mem_cgroup, work_freeing);
 	vfree(memcg);
 }
+
 static void vfree_rcu(struct rcu_head *rcu_head)
 {
 	struct mem_cgroup *memcg;
@@ -4982,20 +4981,14 @@ free_out:
 	return ERR_PTR(error);
 }
 
-static int mem_cgroup_pre_destroy(struct cgroup *cont)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-
-	return mem_cgroup_recharge(memcg);
-}
-
 static void mem_cgroup_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
 	kmem_cgroup_destroy(cont);
 
-	mem_cgroup_put(memcg);
+	INIT_WORK(&memcg->work_destroy, mem_cgroup_recharge);
+	schedule_work(&memcg->work_destroy);
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
@@ -5589,7 +5582,6 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
 	.create = mem_cgroup_create,
-	.pre_destroy = mem_cgroup_pre_destroy,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
 	.can_attach = mem_cgroup_can_attach,
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
