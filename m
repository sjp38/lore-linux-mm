Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3764B6B0083
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:15 -0400 (EDT)
Message-Id: <66e5483e886eafbb8bddf44ab7b0cbd37ab3cd9b.1311338634.git.mhocko@suse.cz>
In-Reply-To: <cover.1311338634.git.mhocko@suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 22 Jul 2011 12:27:32 +0200
Subject: [PATCH 3/4] memcg: add mem_cgroup_same_or_subtree helper
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

We are checking whether a given two groups are same or at least in the
same subtree of a hierarchy at several places. Let's make a helper for
it to make code easier to read.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   51 ++++++++++++++++++++++++++-------------------------
 1 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8852bed..3685107 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1046,6 +1046,21 @@ void mem_cgroup_move_lists(struct page *page,
 	mem_cgroup_add_lru_list(page, to);
 }
 
+/*
+ * Checks whether given mem is same or in the root_mem's
+ * hierarchy subtree
+ */
+static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_mem,
+		struct mem_cgroup *mem)
+{
+	if (root_mem != mem) {
+		return (root_mem->use_hierarchy &&
+			css_is_ancestor(&mem->css, &root_mem->css));
+	}
+
+	return true;
+}
+
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 {
 	int ret;
@@ -1065,10 +1080,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	 * enabled in "curr" and "curr" is a child of "mem" in *cgroup*
 	 * hierarchy(even if use_hierarchy is disabled in "mem").
 	 */
-	if (mem->use_hierarchy)
-		ret = css_is_ancestor(&curr->css, &mem->css);
-	else
-		ret = (curr == mem);
+	ret = mem_cgroup_same_or_subtree(mem, curr);
 	css_put(&curr->css);
 	return ret;
 }
@@ -1404,10 +1416,9 @@ static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 	to = mc.to;
 	if (!from)
 		goto unlock;
-	if (from == mem || to == mem
-	    || (mem->use_hierarchy && css_is_ancestor(&from->css, &mem->css))
-	    || (mem->use_hierarchy && css_is_ancestor(&to->css,	&mem->css)))
-		ret = true;
+
+	ret = mem_cgroup_same_or_subtree(mem, from)
+		|| mem_cgroup_same_or_subtree(mem, to);
 unlock:
 	spin_unlock(&mc.lock);
 	return ret;
@@ -1894,25 +1905,20 @@ struct oom_wait_info {
 static int memcg_oom_wake_function(wait_queue_t *wait,
 	unsigned mode, int sync, void *arg)
 {
-	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
+	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg,
+			  *oom_wait_mem;
 	struct oom_wait_info *oom_wait_info;
 
 	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
+	oom_wait_mem = oom_wait_info->mem;
 
-	if (oom_wait_info->mem == wake_mem)
-		goto wakeup;
-	/* if no hierarchy, no match */
-	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
-		return 0;
 	/*
 	 * Both of oom_wait_info->mem and wake_mem are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
-	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
-	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
+	if (!mem_cgroup_same_or_subtree(oom_wait_mem, wake_mem)
+			&& !mem_cgroup_same_or_subtree(wake_mem, oom_wait_mem))
 		return 0;
-
-wakeup:
 	return autoremove_wake_function(wait, mode, sync, arg);
 }
 
@@ -2157,13 +2163,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 		mem = stock->cached;
 		if (!mem || !stock->nr_pages)
 			continue;
-		if (mem != root_mem) {
-			if (!root_mem->use_hierarchy)
-				continue;
-			/* check whether "mem" is under tree of "root_mem" */
-			if (!css_is_ancestor(&mem->css, &root_mem->css))
-				continue;
-		}
+		if (!mem_cgroup_same_or_subtree(root_mem, mem))
+			continue;
 		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
 			if (cpu == curcpu)
 				drain_local_stock(&stock->work);
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
