Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA898eqk028490
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:08:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA89B9h9123316
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:11:09 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA89B84l028640
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:11:09 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sat, 08 Nov 2008 14:41:00 +0530
Message-Id: <20081108091100.32236.89666.sendpatchset@localhost.localdomain>
In-Reply-To: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
Subject: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch introduces hierarchical reclaim. When an ancestor goes over its
limit, the charging routine points to the parent that is above its limit.
The reclaim process then starts from the last scanned child of the ancestor
and reclaims until the ancestor goes below its limit.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |  152 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 128 insertions(+), 24 deletions(-)

diff -puN mm/memcontrol.c~memcg-hierarchical-reclaim mm/memcontrol.c
--- linux-2.6.28-rc2/mm/memcontrol.c~memcg-hierarchical-reclaim	2008-11-08 14:09:32.000000000 +0530
+++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-08 14:09:32.000000000 +0530
@@ -132,6 +132,11 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+	/*
+	 * While reclaiming in a hiearchy, we cache the last child we
+	 * reclaimed from.
+	 */
+	struct mem_cgroup *last_scanned_child;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -467,6 +472,124 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+static struct mem_cgroup *
+mem_cgroup_from_res_counter(struct res_counter *counter)
+{
+	return container_of(counter, struct mem_cgroup, res);
+}
+
+/*
+ * Dance down the hierarchy if needed to reclaim memory. We remember the
+ * last child we reclaimed from, so that we don't end up penalizing
+ * one child extensively based on its position in the children list.
+ *
+ * root_mem is the original ancestor that we've been reclaim from.
+ */
+static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *mem,
+						struct mem_cgroup *root_mem,
+						gfp_t gfp_mask)
+{
+	struct cgroup *cg_current, *cgroup;
+	struct mem_cgroup *mem_child;
+	int ret = 0;
+
+	/*
+	 * Reclaim unconditionally and don't check for return value.
+	 * We need to reclaim in the current group and down the tree.
+	 * One might think about checking for children before reclaiming,
+	 * but there might be left over accounting, even after children
+	 * have left.
+	 */
+	try_to_free_mem_cgroup_pages(mem, gfp_mask);
+
+	if (res_counter_check_under_limit(&root_mem->res))
+		return 0;
+
+	if (list_empty(&mem->css.cgroup->children))
+		return 0;
+
+	/*
+	 * Scan all children under the mem_cgroup mem
+	 */
+	if (!mem->last_scanned_child)
+		cgroup = list_first_entry(&mem->css.cgroup->children,
+				struct cgroup, sibling);
+	else
+		cgroup = mem->last_scanned_child->css.cgroup;
+
+	cg_current = cgroup;
+	cgroup_lock();
+
+	do {
+		struct list_head *next;
+
+		mem_child = mem_cgroup_from_cont(cgroup);
+		cgroup_unlock();
+
+		ret = mem_cgroup_hierarchical_reclaim(mem_child, root_mem,
+							gfp_mask);
+		mem->last_scanned_child = mem_child;
+
+		cgroup_lock();
+		if (res_counter_check_under_limit(&root_mem->res)) {
+			ret = 0;
+			goto done;
+		}
+
+		/*
+		 * Since we gave up the lock, it is time to
+		 * start from last cgroup
+		 */
+		cgroup = mem->last_scanned_child->css.cgroup;
+		next = cgroup->sibling.next;
+
+		if (next == &cg_current->parent->children)
+			cgroup = list_first_entry(&mem->css.cgroup->children,
+							struct cgroup, sibling);
+		else
+			cgroup = container_of(next, struct cgroup, sibling);
+	} while (cgroup != cg_current);
+
+done:
+	cgroup_unlock();
+	return ret;
+}
+
+/*
+ * Charge memory cgroup mem and check if it is over its limit. If so, reclaim
+ * from mem.
+ */
+static int mem_cgroup_charge_and_reclaim(struct mem_cgroup *mem, gfp_t gfp_mask)
+{
+	int ret = 0;
+	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *fail_res;
+	struct mem_cgroup *mem_over_limit;
+
+	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
+		if (!(gfp_mask & __GFP_WAIT))
+			goto out;
+
+		/*
+		 * Is one of our ancestors over their limit?
+		 */
+		if (fail_res)
+			mem_over_limit = mem_cgroup_from_res_counter(fail_res);
+		else
+			mem_over_limit = mem;
+
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit,
+							mem_over_limit,
+							gfp_mask);
+
+		if (!nr_retries--) {
+			mem_cgroup_out_of_memory(mem, gfp_mask);
+			goto out;
+		}
+	}
+out:
+	return ret;
+}
 
 /**
  * mem_cgroup_try_charge - get charge of PAGE_SIZE.
@@ -484,8 +607,7 @@ int mem_cgroup_try_charge(struct mm_stru
 			gfp_t gfp_mask, struct mem_cgroup **memcg)
 {
 	struct mem_cgroup *mem;
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res;
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -510,29 +632,9 @@ int mem_cgroup_try_charge(struct mm_stru
 		css_get(&mem->css);
 	}
 
+	if (mem_cgroup_charge_and_reclaim(mem, gfp_mask))
+		goto nomem;
 
-	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
-		if (!(gfp_mask & __GFP_WAIT))
-			goto nomem;
-
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
-			continue;
-
-		/*
-		 * try_to_free_mem_cgroup_pages() might not give us a full
-		 * picture of reclaim. Some pages are reclaimed and might be
-		 * moved to swap cache or just unmapped from the cgroup.
-		 * Check the limit again to see if the reclaim reduced the
-		 * current usage of the cgroup before giving up
-		 */
-		if (res_counter_check_under_limit(&mem->res))
-			continue;
-
-		if (!nr_retries--) {
-			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto nomem;
-		}
-	}
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -1195,6 +1297,8 @@ mem_cgroup_create(struct cgroup_subsys *
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
+	mem->last_scanned_child = NULL;
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
