Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 356BF6B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:31:17 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/6] memcg: split mem_cgroup_force_empty into reclaiming and reparenting parts
Date: Wed, 17 Oct 2012 15:30:43 +0200
Message-Id: <1350480648-10905-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

mem_cgroup_force_empty did two separate things depending on free_all
parameter from the very beginning. It either reclaimed as many pages as
possible and moved the rest to the parent or just moved charges to the
parent. The first variant is used as memory.force_empty callback while
the later is used from the mem_cgroup_pre_destroy.

The whole games around gotos are far from being nice and there is no
reason to keep those two functions inside one. Let's split them and
also move the responsibility for css reference counting to their callers
to make to code easier.

This patch doesn't have any functional changes.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   72 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 42 insertions(+), 30 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e4e9b18..f25e9c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3733,27 +3733,21 @@ static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 }
 
 /*
- * make mem_cgroup's charge to be 0 if there is no task.
+ * make mem_cgroup's charge to be 0 if there is no task by moving
+ * all the charges and pages to the parent.
  * This enables deleting this mem_cgroup.
+ *
+ * Caller is responsible for holding css reference on the memcg.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
+static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 {
-	int ret;
-	int node, zid, shrink;
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct cgroup *cgrp = memcg->css.cgroup;
+	int node, zid;
+	int ret;
 
-	css_get(&memcg->css);
-
-	shrink = 0;
-	/* should free all ? */
-	if (free_all)
-		goto try_to_free;
-move_account:
 	do {
-		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
-			goto out;
+			return -EBUSY;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		drain_all_stock_sync(memcg);
@@ -3777,27 +3771,34 @@ move_account:
 		cond_resched();
 	/* "ret" should also be checked to ensure all lists are empty. */
 	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
-out:
-	css_put(&memcg->css);
+
 	return ret;
+}
+
+/*
+ * Reclaims as many pages from the given memcg as possible and moves
+ * the rest to the parent.
+ *
+ * Caller is responsible for holding css reference for memcg.
+ */
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
+{
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct cgroup *cgrp = memcg->css.cgroup;
 
-try_to_free:
 	/* returns EBUSY if there is a task or if we come here twice. */
-	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children) || shrink) {
-		ret = -EBUSY;
-		goto out;
-	}
+	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
+		return -EBUSY;
+
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
-	shrink = 1;
 	while (nr_retries && res_counter_read_u64(&memcg->res, RES_USAGE) > 0) {
 		int progress;
 
-		if (signal_pending(current)) {
-			ret = -EINTR;
-			goto out;
-		}
+		if (signal_pending(current))
+			return -EINTR;
+
 		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
 						false);
 		if (!progress) {
@@ -3808,13 +3809,19 @@ try_to_free:
 
 	}
 	lru_add_drain();
-	/* try move_account...there may be some *locked* pages. */
-	goto move_account;
+	return mem_cgroup_reparent_charges(memcg);
 }
 
 static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	int ret;
+
+	css_get(&memcg->css);
+	ret = mem_cgroup_force_empty(memcg);
+	css_put(&memcg->css);
+
+	return ret;
 }
 
 
@@ -5004,8 +5011,13 @@ free_out:
 static int mem_cgroup_pre_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	int ret;
 
-	return mem_cgroup_force_empty(memcg, false);
+	css_get(&memcg->css);
+	ret = mem_cgroup_reparent_charges(memcg);
+	css_put(&memcg->css);
+
+	return ret;
 }
 
 static void mem_cgroup_destroy(struct cgroup *cont)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
