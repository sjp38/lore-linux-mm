Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F41C6B02FD
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 16:14:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u21so17460394pgn.5
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 13:14:53 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o3si594147pld.210.2017.06.02.13.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 13:14:52 -0700 (PDT)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH] mm/memcontrol: exclude @root from checks in mem_cgroup_low
Date: Fri,  2 Jun 2017 13:13:32 -0700
Message-Id: <1496434412-21005-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, sean.j.christopherson@intel.com

Make @root exclusive in mem_cgroup_low; it is never considered low
when looked at directly and is not checked when traversing the tree.
In effect, @root is handled identically to how root_mem_cgroup was
previously handled by mem_cgroup_low.

If @root is not excluded from the checks, a cgroup underneath @root
will never be considered low during targeted reclaim of @root, e.g.
due to memory.current > memory.high, unless @root is misconfigured
to have memory.low > memory.high.

Excluding @root enables using memory.low to prioritize memory usage
between cgroups within a subtree of the hierarchy that is limited by
memory.high or memory.max, e.g. when ROOT owns @root's controls but
delegates the @root directory to a USER so that USER can create and
administer children of @root.

For example, given cgroup A with children B and C:

    A
   / \
  B   C

and

  1. A/memory.current > A/memory.high
  2. A/B/memory.current < A/B/memory.low
  3. A/C/memory.current >= A/C/memory.low

As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
should reclaim from 'C' until 'A' is no longer high or until we can
no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
low and we will reclaim indiscriminately from both 'B' and 'C'.

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 mm/memcontrol.c | 50 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13998ab..690b7dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5314,38 +5314,52 @@ struct cgroup_subsys memory_cgrp_subsys = {
 
 /**
  * mem_cgroup_low - check if memory consumption is below the normal range
- * @root: the highest ancestor to consider
+ * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
  * Returns %true if memory consumption of @memcg, and that of all
- * configurable ancestors up to @root, is below the normal range.
+ * ancestors up to (but not including) @root, is below the normal range.
+ *
+ * @root is exclusive; it is never low when looked at directly and isn't
+ * checked when traversing the hierarchy.
+ *
+ * Excluding @root enables using memory.low to prioritize memory usage
+ * between cgroups within a subtree of the hierarchy that is limited by
+ * memory.high or memory.max.
+ *
+ * For example, given cgroup A with children B and C:
+ *
+ *    A
+ *   / \
+ *  B   C
+ *
+ * and
+ *
+ *  1. A/memory.current > A/memory.high
+ *  2. A/B/memory.current < A/B/memory.low
+ *  3. A/C/memory.current >= A/C/memory.low
+ *
+ * As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
+ * should reclaim from 'C' until 'A' is no longer high or until we can
+ * no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
+ * mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
+ * low and we will reclaim indiscriminately from both 'B' and 'C'.
  */
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
 	if (mem_cgroup_disabled())
 		return false;
 
-	/*
-	 * The toplevel group doesn't have a configurable range, so
-	 * it's never low when looked at directly, and it is not
-	 * considered an ancestor when assessing the hierarchy.
-	 */
-
-	if (memcg == root_mem_cgroup)
-		return false;
-
-	if (page_counter_read(&memcg->memory) >= memcg->low)
+	if (!root)
+		root = root_mem_cgroup;
+	if (memcg == root)
 		return false;
 
-	while (memcg != root) {
-		memcg = parent_mem_cgroup(memcg);
-
-		if (memcg == root_mem_cgroup)
-			break;
-
+	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
 		if (page_counter_read(&memcg->memory) >= memcg->low)
 			return false;
 	}
+
 	return true;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
