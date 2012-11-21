Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A00386B00B8
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:23:08 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 43/46] sched: numa: Rename mempolicy to HOME
Date: Wed, 21 Nov 2012 10:21:49 +0000
Message-Id: <1353493312-8069-44-git-send-email-mgorman@suse.de>
In-Reply-To: <1353493312-8069-1-git-send-email-mgorman@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Rename the policy to reflect that while allocations and migrations are
based on reference that the home node is taken into account for
migration decisions.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/uapi/linux/mempolicy.h |    9 ++++++++-
 mm/mempolicy.c                 |    9 ++++++---
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 0d11c3d..4506772 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -67,7 +67,14 @@ enum mpol_rebind_step {
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
-#define MPOL_F_MORON	(1 << 4) /* Migrate On pte_numa Reference On Node */
+#define MPOL_F_HOME	(1 << 4) /*
+				  * Migrate towards referencing node.
+				  * By building up stats on faults, the
+				  * scheduler will reinforce the choice
+				  * by identifying a home node and
+				  * queueing the task on that node
+				  * where possible.
+				  */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index fd20e28..3da7435 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2316,8 +2316,11 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		BUG();
 	}
 
-	/* Migrate the page towards the node whose CPU is referencing it */
-	if (pol->flags & MPOL_F_MORON) {
+	/*
+	 * Migrate pages towards their referencing node. Based on the fault
+	 * statistics a home node will be chosen by the scheduler
+	 */
+	if (pol->flags & MPOL_F_HOME) {
 		int last_nid;
 
 		polnid = numa_node_id();
@@ -2540,7 +2543,7 @@ void __init numa_policy_init(void)
 		preferred_node_policy[nid] = (struct mempolicy) {
 			.refcnt = ATOMIC_INIT(1),
 			.mode = MPOL_PREFERRED,
-			.flags = MPOL_F_MOF | MPOL_F_MORON,
+			.flags = MPOL_F_MOF | MPOL_F_HOME,
 			.v = { .preferred_node = nid, },
 		};
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
