Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6C02C6B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:31:19 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/6] memcg: Simplify mem_cgroup_force_empty_list error handling
Date: Wed, 17 Oct 2012 15:30:45 +0200
Message-Id: <1350480648-10905-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

mem_cgroup_force_empty_list currently tries to remove all pages from
the given LRU. To prevent from temoporary failures (EBUSY returned by
mem_cgroup_move_parent) it uses a margin to the current LRU pages and
returns the true if there are still some pages left on the list.

If we consider that mem_cgroup_move_parent fails only when we are racing
with somebody else removing the page (resp. uncharging it) or when the
page is migrated then it is obvious that all those failures are only
temporal and so we can safely retry later.
Let's get rid of the safety margin and make the loop really wait for the
empty LRU. The caller should still make sure that all charges have been
removed from the res_counter because mem_cgroup_replace_page_cache might
add a page to the LRU after the check (it doesn't touch res_counter
though).
This catches most of the cases except for shmem which might call
mem_cgroup_replace_page_cache with a page which is not charged and on
the LRU yet but this was the case also without this patch. In order to
fix this we need a guarantee that try_get_mem_cgroup_from_page falls
back to the current mm's cgroup so it needs css_tryget to fail. This
will be fixed up in a later patch because it nees a help from cgroup
core.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   52 +++++++++++++++++++++++++++-------------------------
 1 file changed, 27 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ce24b7..f57ba4c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2697,9 +2697,13 @@ out:
 }
 
 /*
- * move charges to its parent.
+ * move charges to its parent or the root cgroup if the group
+ * has no parent (aka use_hierarchy==0).
+ * Although this might fail the failure is always temporary and it
+ * signals a race with a page removal/uncharge or migration. In the
+ * first case the page will vanish from the LRU on the next attempt
+ * and the call should be retried later.
  */
-
 static int mem_cgroup_move_parent(struct page *page,
 				  struct page_cgroup *pc,
 				  struct mem_cgroup *child)
@@ -2726,8 +2730,10 @@ static int mem_cgroup_move_parent(struct page *page,
 	if (!parent)
 		parent = root_mem_cgroup;
 
-	if (nr_pages > 1)
+	if (nr_pages > 1) {
+		VM_BUG_ON(!PageTransHuge(page));
 		flags = compound_lock_irqsave(page);
+	}
 
 	ret = mem_cgroup_move_account(page, nr_pages,
 				pc, child, parent);
@@ -3679,15 +3685,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 
 /*
  * Traverse a specified page_cgroup list and try to drop them all.  This doesn't
- * reclaim the pages page themselves - it just removes the page_cgroups.
- * Returns true if some page_cgroups were not freed, indicating that the caller
- * must retry this operation.
+ * reclaim the pages page themselves - pages are moved to the parent (or root)
+ * group.
  */
-static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
+static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
-	unsigned long flags, loop;
+	unsigned long flags;
 	struct list_head *list;
 	struct page *busy;
 	struct zone *zone;
@@ -3696,11 +3701,8 @@ static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->lruvec.lists[lru];
 
-	loop = mz->lru_size[lru];
-	/* give some margin against EBUSY etc...*/
-	loop += 256;
 	busy = NULL;
-	while (loop--) {
+	do {
 		struct page_cgroup *pc;
 		struct page *page;
 
@@ -3726,8 +3728,7 @@ static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 			cond_resched();
 		} else
 			busy = NULL;
-	}
-	return !list_empty(list);
+	} while (!list_empty(list));
 }
 
 /*
@@ -3741,7 +3742,6 @@ static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
 	int node, zid;
-	int ret;
 
 	do {
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
@@ -3749,28 +3749,30 @@ static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		drain_all_stock_sync(memcg);
-		ret = 0;
 		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
-			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
+			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				enum lru_list lru;
 				for_each_lru(lru) {
-					ret = mem_cgroup_force_empty_list(memcg,
+					mem_cgroup_force_empty_list(memcg,
 							node, zid, lru);
-					if (ret)
-						break;
 				}
 			}
-			if (ret)
-				break;
 		}
 		mem_cgroup_end_move(memcg);
 		memcg_oom_recover(memcg);
 		cond_resched();
-	/* "ret" should also be checked to ensure all lists are empty. */
-	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
 
-	return ret;
+		/*
+		 * This is a safety check because mem_cgroup_force_empty_list
+		 * could have raced with mem_cgroup_replace_page_cache callers
+		 * so the lru seemed empty but the page could have been added
+		 * right after the check. RES_USAGE should be safe as we always
+		 * charge before adding to the LRU.
+		 */
+	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0);
+
+	return 0;
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
