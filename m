Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 7BB366B0089
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:24 -0400 (EDT)
Message-Id: <20121025124834.383666518@chello.nl>
Date: Thu, 25 Oct 2012 14:16:42 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/31] sched, numa, mm/mpol: Add_MPOL_F_HOME
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0025-sched-numa-mm-Add_MPOL_F_HOME.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

Add MPOL_F_HOME, to implement multi-stage home node binding.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Turner <pjt@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/uapi/linux/mempolicy.h |    1 +
 mm/mempolicy.c                 |   34 +++++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

Index: tip/include/uapi/linux/mempolicy.h
===================================================================
--- tip.orig/include/uapi/linux/mempolicy.h
+++ tip/include/uapi/linux/mempolicy.h
@@ -69,6 +69,7 @@ enum mpol_rebind_step {
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
+#define MPOL_F_HOME	(1 << 4) /* this is the home-node policy */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
@@ -2190,6 +2190,7 @@ static void sp_free(struct sp_node *n)
  * @page   - page to be checked
  * @vma    - vm area where page mapped
  * @addr   - virtual address where page mapped
+ * @multi  - use multi-stage node binding
  *
  * Lookup current policy node id for vma,addr and "compare to" page's
  * node id.
@@ -2252,6 +2253,37 @@ int mpol_misplaced(struct page *page, st
 	default:
 		BUG();
 	}
+
+	/*
+	 * Multi-stage node selection is used in conjunction with a periodic
+	 * migration fault to build a temporal task<->page relation. By
+	 * using a two-stage filter we remove short/unlikely relations.
+	 *
+	 * Using P(p) ~ n_p / n_t as per frequentist probability, we can
+	 * equate a task's usage of a particular page (n_p) per total usage
+	 * of this page (n_t) (in a given time-span) to a probability.
+	 *
+	 * Our periodic faults will then sample this probability and getting
+	 * the same result twice in a row, given these samples are fully
+	 * independent, is then given by P(n)^2, provided our sample period
+	 * is sufficiently short compared to the usage pattern.
+	 *
+	 * This quadric squishes small probabilities, making it less likely
+	 * we act on an unlikely task<->page relation.
+	 */
+	if (pol->flags & MPOL_F_HOME) {
+		int last_nid;
+
+		/*
+		 * Migrate towards the current node, depends on
+		 * task_numa_placement() details.
+		 */
+		polnid = numa_node_id();
+		last_nid = page_xchg_last_nid(page, polnid);
+		if (last_nid != polnid)
+			goto out;
+	}
+
 	if (curnid != polnid)
 		ret = polnid;
 out:
@@ -2444,7 +2476,7 @@ void __init numa_policy_init(void)
 		preferred_node_policy[nid] = (struct mempolicy) {
 			.refcnt = ATOMIC_INIT(1),
 			.mode = MPOL_PREFERRED,
-			.flags = MPOL_F_MOF,
+			.flags = MPOL_F_MOF | MPOL_F_HOME,
 			.v = { .preferred_node = nid, },
 		};
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
