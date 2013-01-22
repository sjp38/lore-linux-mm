Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 65A5E6B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:43:58 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 2/5] Bug-fix: mempolicy: fix is_valid_nodemask()
Date: Tue, 22 Jan 2013 19:43:01 +0800
Message-Id: <1358854984-6073-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>

is_valid_nodemask() is introduced by 19770b32. but it does not match
its comments, because it does not check the zone which > policy_zone.

Also in b377fd, this commits told us, if highest zone is ZONE_MOVABLE,
we should also apply memory policies to it. so ZONE_MOVABLE should be valid zone
for policies. is_valid_nodemask() need to be changed to match it.

Fix: check all zones, even its zoneid > policy_zone.
Use nodes_intersects() instead open code to check it.

Reported-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/mempolicy.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af8a121..6f7979c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -161,19 +161,7 @@ static const struct mempolicy_operations {
 /* Check that the nodemask contains at least one populated zone */
 static int is_valid_nodemask(const nodemask_t *nodemask)
 {
-	int nd, k;
-
-	for_each_node_mask(nd, *nodemask) {
-		struct zone *z;
-
-		for (k = 0; k <= policy_zone; k++) {
-			z = &NODE_DATA(nd)->node_zones[k];
-			if (z->managed_pages > 0)
-				return 1;
-		}
-	}
-
-	return 0;
+	return nodes_intersects(*nodemask, node_states[N_MEMORY]);
 }
 
 static inline int mpol_store_user_nodemask(const struct mempolicy *pol)
@@ -1644,6 +1632,26 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
 	return pol;
 }
 
+static int apply_policy_zone(struct mempolicy *policy, enum zone_type zone)
+{
+	enum zone_type dynamic_policy_zone = policy_zone;
+
+	BUG_ON(dynamic_policy_zone == ZONE_MOVABLE);
+
+	/*
+	 * if policy->v.nodes has movable memory only,
+	 * we apply policy when gfp_zone(gfp) = ZONE_MOVABLE only.
+	 *
+	 * policy->v.nodes is intersect with node_states[N_MEMORY].
+	 * so if the following test faile, it implies
+	 * policy->v.nodes has movable memory only.
+	 */
+	if (!nodes_intersects(policy->v.nodes, node_states[N_HIGH_MEMORY]))
+		dynamic_policy_zone = ZONE_MOVABLE;
+
+	return zone >= dynamic_policy_zone;
+}
+
 /*
  * Return a nodemask representing a mempolicy for filtering nodes for
  * page allocation
@@ -1652,7 +1660,7 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
 {
 	/* Lower zones don't get a nodemask applied for MPOL_BIND */
 	if (unlikely(policy->mode == MPOL_BIND) &&
-			gfp_zone(gfp) >= policy_zone &&
+			apply_policy_zone(policy, gfp_zone(gfp)) &&
 			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes))
 		return &policy->v.nodes;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
