Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6EA986B009D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:13:28 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 21/31] mm: numa: Migrate on reference policy
Date: Tue, 13 Nov 2012 11:12:50 +0000
Message-Id: <1352805180-1607-22-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is the dumbest possible policy that still does something of note.
When a pte_numa is faulted, it is moved immediately. Any replacement
policy must at least do better than this and in all likelihood this
policy regresses normal workloads.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/uapi/linux/mempolicy.h |    1 +
 mm/mempolicy.c                 |   41 ++++++++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 6a1baae..b25064f 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -69,6 +69,7 @@ enum mpol_rebind_step {
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
+#define MPOL_F_MORON	(1 << 4) /* Migrate On pte_numa Reference On Node */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 860341e..f2111b7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -118,6 +118,26 @@ static struct mempolicy default_policy = {
 	.flags = MPOL_F_LOCAL,
 };
 
+static struct mempolicy preferred_node_policy[MAX_NUMNODES];
+
+static struct mempolicy *get_task_policy(struct task_struct *p)
+{
+	struct mempolicy *pol = p->mempolicy;
+	int node;
+
+	if (!pol) {
+		node = numa_node_id();
+		if (node != -1)
+			pol = &preferred_node_policy[node];
+
+		/* preferred_node_policy is not initialised early in boot */
+		if (!pol->mode)
+			pol = NULL;
+	}
+
+	return pol;
+}
+
 static const struct mempolicy_operations {
 	int (*create)(struct mempolicy *pol, const nodemask_t *nodes);
 	/*
@@ -1704,7 +1724,7 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
 struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
-	struct mempolicy *pol = task->mempolicy;
+	struct mempolicy *pol = get_task_policy(task);
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
@@ -2127,7 +2147,7 @@ retry_cpuset:
  */
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
-	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy *pol = get_task_policy(current);
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 
@@ -2401,6 +2421,14 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	default:
 		BUG();
 	}
+
+	/*
+	 * Moronic node selection policy. Migrate the page to the node that is
+	 * currently referencing it
+	 */
+	if (pol->flags & MPOL_F_MORON)
+		polnid = numa_node_id();
+
 	if (curnid != polnid)
 		ret = polnid;
 out:
@@ -2589,6 +2617,15 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL);
 
+	for_each_node(nid) {
+		preferred_node_policy[nid] = (struct mempolicy) {
+			.refcnt = ATOMIC_INIT(1),
+			.mode = MPOL_PREFERRED,
+			.flags = MPOL_F_MOF | MPOL_F_MORON,
+			.v = { .preferred_node = nid, },
+		};
+	}
+
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
