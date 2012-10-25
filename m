Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 89F7F6B0083
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:18 -0400 (EDT)
Message-Id: <20121025124833.247790041@chello.nl>
Date: Thu, 25 Oct 2012 14:16:27 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/31] mm/mpol: Remove NUMA_INTERLEAVE_HIT
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0010-mm-mpol-Remove-NUMA_INTERLEAVE_HIT.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Ingo Molnar <mingo@kernel.org>

Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
to be compared to either a total of interleave allocations or to a miss
count, remove it.

Fixing it would be possible, but since we've gone years without these
statistics I figure we can continue that way.

Also NUMA_HIT fully includes NUMA_INTERLEAVE_HIT so users might
switch to using that.

This cleans up some of the weird MPOL_INTERLEAVE allocation exceptions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/base/node.c    |    2 -
 include/linux/mmzone.h |    1 
 mm/mempolicy.c         |   68 +++++++++++++++----------------------------------
 mm/vmstat.c            |    1 
 4 files changed, 22 insertions(+), 50 deletions(-)

Index: tip/drivers/base/node.c
===================================================================
--- tip.orig/drivers/base/node.c
+++ tip/drivers/base/node.c
@@ -169,7 +169,7 @@ static ssize_t node_read_numastat(struct
 		       node_page_state(dev->id, NUMA_HIT),
 		       node_page_state(dev->id, NUMA_MISS),
 		       node_page_state(dev->id, NUMA_FOREIGN),
-		       node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       0UL,
 		       node_page_state(dev->id, NUMA_LOCAL),
 		       node_page_state(dev->id, NUMA_OTHER));
 }
Index: tip/include/linux/mmzone.h
===================================================================
--- tip.orig/include/linux/mmzone.h
+++ tip/include/linux/mmzone.h
@@ -137,7 +137,6 @@ enum zone_stat_item {
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
 	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
-	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
@@ -1587,11 +1587,29 @@ static nodemask_t *policy_nodemask(gfp_t
 	return NULL;
 }
 
+/* Do dynamic interleaving for a process */
+static unsigned interleave_nodes(struct mempolicy *policy)
+{
+	unsigned nid, next;
+	struct task_struct *me = current;
+
+	nid = me->il_next;
+	next = next_node(nid, policy->v.nodes);
+	if (next >= MAX_NUMNODES)
+		next = first_node(policy->v.nodes);
+	if (next < MAX_NUMNODES)
+		me->il_next = next;
+	return nid;
+}
+
 /* Return a zonelist indicated by gfp for node representing a mempolicy */
 static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 	int nd)
 {
 	switch (policy->mode) {
+	case MPOL_INTERLEAVE:
+		nd = interleave_nodes(policy);
+		break;
 	case MPOL_PREFERRED:
 		if (!(policy->flags & MPOL_F_LOCAL))
 			nd = policy->v.preferred_node;
@@ -1613,21 +1631,6 @@ static struct zonelist *policy_zonelist(
 	return node_zonelist(nd, gfp);
 }
 
-/* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
-{
-	unsigned nid, next;
-	struct task_struct *me = current;
-
-	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
-	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
-	if (next < MAX_NUMNODES)
-		me->il_next = next;
-	return nid;
-}
-
 /*
  * Depending on the memory policy provide a node from which to allocate the
  * next slab entry.
@@ -1864,21 +1867,6 @@ out:
 	return ret;
 }
 
-/* Allocate a page in interleaved policy.
-   Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
-{
-	struct zonelist *zl;
-	struct page *page;
-
-	zl = node_zonelist(nid, gfp);
-	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
-		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
-	return page;
-}
-
 /**
  * 	alloc_pages_vma	- Allocate a page for a VMA.
  *
@@ -1915,17 +1903,6 @@ retry_cpuset:
 	pol = get_vma_policy(current, vma, addr);
 	cpuset_mems_cookie = get_mems_allowed();
 
-	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
-		unsigned nid;
-
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
-			goto retry_cpuset;
-
-		return page;
-	}
 	zl = policy_zonelist(gfp, pol, node);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
@@ -1983,12 +1960,9 @@ retry_cpuset:
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
 	 */
-	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	else
-		page = __alloc_pages_nodemask(gfp, order,
-				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+	page = __alloc_pages_nodemask(gfp, order,
+			policy_zonelist(gfp, pol, numa_node_id()),
+			policy_nodemask(gfp, pol));
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
Index: tip/mm/vmstat.c
===================================================================
--- tip.orig/mm/vmstat.c
+++ tip/mm/vmstat.c
@@ -729,7 +729,6 @@ const char * const vmstat_text[] = {
 	"numa_hit",
 	"numa_miss",
 	"numa_foreign",
-	"numa_interleave",
 	"numa_local",
 	"numa_other",
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
