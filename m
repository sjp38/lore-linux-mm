Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30B492806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:53:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j11so9583802pgn.9
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:20 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id b10si1615693plk.334.2017.04.19.00.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:53:19 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id g2so2896052pge.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:19 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC 3/4] mm: Integrate N_COHERENT_MEMORY with mempolicy and the rest of the system
Date: Wed, 19 Apr 2017 17:52:41 +1000
Message-Id: <20170419075242.29929-4-bsingharora@gmail.com>
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com, Balbir Singh <bsingharora@gmail.com>

This patch integrates N_COHERENT_MEMORY and makes the integration
deeper. It does the following

1. Modifies mempolicy so as to
	a. Allow policy_zonelist() and policy_nodemask() to
	   understand N_COHERENT_MEMORY nodes and allow the
	   right mask/list to be built when the policy contains
	   those nodes
	b. Checks for N_COHERENT_MEMORY in mpol_new_nodemask()
	   and other places with hard-coded checks for N_MEMORY
2. Modifies mm/page_alloc.c, so that nodes marked as N_COHERENT_MEMORY
   are not marked as N_MEMORY
3. Changes node zonelist creation, so that coherent memory is
   present in the fallback in case multiple such nodes are
   present.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/memory_hotplug.c |  3 ++-
 mm/mempolicy.c      | 31 ++++++++++++++++++++++++++++---
 mm/page_alloc.c     | 21 +++++++++++++++++----
 3 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ebeb3af..12d5431 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1037,7 +1037,8 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
-	node_set_state(node, N_MEMORY);
+	if (!node_state(node, N_COHERENT_MEMORY))
+		node_set_state(node, N_MEMORY);
 }
 
 bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 37d0b33..141398e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -217,6 +217,8 @@ static int mpol_set_nodemask(struct mempolicy *pol,
 		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
 {
 	int ret;
+	int n;
+	nodemask_t tmp;
 
 	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
 	if (pol == NULL)
@@ -226,6 +228,14 @@ static int mpol_set_nodemask(struct mempolicy *pol,
 		  cpuset_current_mems_allowed, node_states[N_MEMORY]);
 
 	VM_BUG_ON(!nodes);
+
+	for_each_node_mask(n, *nodes) {
+		if (node_state(n, N_COHERENT_MEMORY)) {
+			tmp = nodemask_of_node(n);
+			nodes_or(nsc->mask1, nsc->mask1, tmp);
+		}
+	}
+
 	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
 		nodes = NULL;	/* explicit local allocation */
 	else {
@@ -1435,7 +1445,8 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 		goto out_put;
 	}
 
-	if (!nodes_subset(*new, node_states[N_MEMORY])) {
+	if (!nodes_subset(*new, node_states[N_MEMORY]) &&
+		!nodes_subset(*new, node_states[N_COHERENT_MEMORY])) {
 		err = -EINVAL;
 		goto out_put;
 	}
@@ -1670,7 +1681,9 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
 	/* Lower zones don't get a nodemask applied for MPOL_BIND */
 	if (unlikely(policy->mode == MPOL_BIND) &&
 			apply_policy_zone(policy, gfp_zone(gfp)) &&
-			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes))
+			(cpuset_nodemask_valid_mems_allowed(&policy->v.nodes) ||
+			nodes_intersects(policy->v.nodes,
+				node_states[N_COHERENT_MEMORY])))
 		return &policy->v.nodes;
 
 	return NULL;
@@ -1691,6 +1704,17 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
 	}
 
+	/*
+	 * It is not sufficient to have the right nodemask, we need the
+	 * correct zonelist for N_COHERENT_MEMORY
+	 */
+	if (node_state(nd, N_COHERENT_MEMORY))
+		/*
+		 * Ideally we should pick the best node, but for now use
+		 * any one
+		 */
+		nd = first_node(node_states[N_COHERENT_MEMORY]);
+
 	return node_zonelist(nd, gfp);
 }
 
@@ -2689,7 +2713,8 @@ int mpol_parse_str(char *str, struct mempolicy **mpol)
 		*nodelist++ = '\0';
 		if (nodelist_parse(nodelist, nodes))
 			goto out;
-		if (!nodes_subset(nodes, node_states[N_MEMORY]))
+		if (!nodes_subset(nodes, node_states[N_MEMORY]) &&
+			!nodes_subset(nodes, node_states[N_COHERENT_MEMORY]))
 			goto out;
 	} else
 		nodes_clear(nodes);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2c687d..59e4d30 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4856,6 +4856,7 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	int min_val = INT_MAX;
 	int best_node = NUMA_NO_NODE;
 	const struct cpumask *tmp = cpumask_of_node(0);
+	nodemask_t tmp_mask, tmp_mask2;
 
 	/* Use the local node if we haven't already */
 	if (!node_isset(node, *used_node_mask)) {
@@ -4863,7 +4864,17 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 		return node;
 	}
 
-	for_each_node_state(n, N_MEMORY) {
+	tmp_mask = node_states[N_MEMORY];
+	tmp_mask2 = node_states[N_COHERENT_MEMORY];
+
+	/*
+	 * If the nodemask has one coherent node, add others
+	 * as well
+	 */
+	if (node_state(node, N_COHERENT_MEMORY))
+		nodes_or(tmp_mask, tmp_mask2, tmp_mask);
+
+	for_each_node_mask(n, tmp_mask) {
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
@@ -6288,7 +6299,7 @@ static unsigned long __init early_calculate_totalpages(void)
 		unsigned long pages = end_pfn - start_pfn;
 
 		totalpages += pages;
-		if (pages)
+		if (pages && !node_state(nid, N_COHERENT_MEMORY))
 			node_set_state(nid, N_MEMORY);
 	}
 	return totalpages;
@@ -6598,9 +6609,11 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 				find_min_pfn_for_node(nid), NULL);
 
 		/* Any memory on that node */
-		if (pgdat->node_present_pages)
+		if (pgdat->node_present_pages &&
+			!node_state(nid, N_COHERENT_MEMORY)) {
 			node_set_state(nid, N_MEMORY);
-		check_for_memory(pgdat, nid);
+			check_for_memory(pgdat, nid);
+		}
 	}
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
