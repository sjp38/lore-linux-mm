Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 265766B00B0
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:14:09 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 26/31] sched: numa: Make mempolicy home-node aware
Date: Tue, 13 Nov 2012 11:12:55 +0000
Message-Id: <1352805180-1607-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add another layer of fallback policy to make the home node concept
useful from a memory allocation PoV.

This changes the mpol order to:

 - vma->vm_ops->get_policy	[if applicable]
 - vma->vm_policy		[if applicable]
 - task->mempolicy
 - tsk_home_node() preferred	[NEW]
 - default_policy

Note that the tsk_home_node() policy has Migrate-on-Fault enabled to
facilitate efficient on-demand memory migration.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/uapi/linux/mempolicy.h |    9 ++++++++-
 mm/mempolicy.c                 |   30 ++++++++++++++++++++----------
 2 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index b25064f..bc7b611 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -69,7 +69,14 @@ enum mpol_rebind_step {
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
index f2111b7..076f8f8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -126,9 +126,10 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
 	int node;
 
 	if (!pol) {
-		node = numa_node_id();
-		if (node != -1)
-			pol = &preferred_node_policy[node];
+		node = tsk_home_node(p);
+		if (node == -1)
+			node = numa_node_id();
+		pol = &preferred_node_policy[node];
 
 		/* preferred_node_policy is not initialised early in boot */
 		if (!pol->mode)
@@ -2422,12 +2423,21 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		BUG();
 	}
 
-	/*
-	 * Moronic node selection policy. Migrate the page to the node that is
-	 * currently referencing it
-	 */
-	if (pol->flags & MPOL_F_MORON)
-		polnid = numa_node_id();
+	/* Migrate pages towards their home node or the referencing node */
+	if (pol->flags & MPOL_F_HOME) {
+		/*
+		 * Make a placement decision based on the home node.
+		 * NOTE: Potentially this can result in a remote->remote
+		 * copy but it's not migrated now the numa_fault will
+		 * be lost or accounted for incorrectly making it a rock
+		 * and a hard place.
+		 */
+		polnid = tsk_home_node(current);
+		if (polnid == -1) {
+			/* No home node, migrate to the referencing node */
+			polnid = numa_node_id();
+		}
+	}
 
 	if (curnid != polnid)
 		ret = polnid;
@@ -2621,7 +2631,7 @@ void __init numa_policy_init(void)
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
