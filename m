Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D612E6B00BF
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:17 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082454eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:17 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 37/52] sched, numa, mm: Interleave shared tasks
Date: Sun,  2 Dec 2012 19:43:29 +0100
Message-Id: <1354473824-19229-38-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Interleave tasks that are 'shared' - i.e. whose memory access patterns
indicate that they are intensively sharing memory with other tasks.

If such a task ends up converging then it switches back into the lazy
node-local policy.

Build-Bug-Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/mempolicy.c | 55 +++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 41 insertions(+), 14 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ad683b9..a847b10 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -112,12 +112,29 @@ enum zone_type policy_zone = 0;
 /*
  * run-time system-wide default policy => local allocation
  */
-static struct mempolicy default_policy = {
-	.refcnt = ATOMIC_INIT(1), /* never free it */
-	.mode = MPOL_PREFERRED,
-	.flags = MPOL_F_LOCAL,
+static struct mempolicy default_policy_local = {
+	.refcnt		= ATOMIC_INIT(1), /* never free it */
+	.mode		= MPOL_PREFERRED,
+	.flags		= MPOL_F_LOCAL,
 };
 
+/*
+ * .v.nodes is set by numa_policy_init():
+ */
+static struct mempolicy default_policy_shared = {
+	.refcnt			= ATOMIC_INIT(1), /* never free it */
+	.mode			= MPOL_INTERLEAVE,
+	.flags			= 0,
+};
+
+static struct mempolicy *default_policy(void)
+{
+	if (task_numa_shared(current) == 1)
+		return &default_policy_shared;
+
+	return &default_policy_local;
+}
+
 static struct mempolicy preferred_node_policy[MAX_NUMNODES];
 
 static struct mempolicy *get_task_policy(struct task_struct *p)
@@ -855,7 +872,7 @@ out:
 static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	nodes_clear(*nodes);
-	if (p == &default_policy)
+	if (p == default_policy())
 		return;
 
 	switch (p->mode) {
@@ -930,7 +947,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		return -EINVAL;
 
 	if (!pol)
-		pol = &default_policy;	/* indicates default behavior */
+		pol = default_policy();	/* indicates default behavior */
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
@@ -946,7 +963,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			goto out;
 		}
 	} else {
-		*policy = pol == &default_policy ? MPOL_DEFAULT :
+		*policy = pol == default_policy() ? MPOL_DEFAULT :
 						pol->mode;
 		/*
 		 * Internal mempolicy flags must be masked off before exposing
@@ -1640,7 +1657,7 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
 		}
 	}
 	if (!pol)
-		pol = &default_policy;
+		pol = default_policy();
 	return pol;
 }
 
@@ -2046,7 +2063,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	unsigned int cpuset_mems_cookie;
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
-		pol = &default_policy;
+		pol = default_policy();
 
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
@@ -2269,7 +2286,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	struct mempolicy *pol;
 	struct zone *zone;
 	int page_nid = page_to_nid(page);
-	unsigned long pgoff;
 	int target_node = page_nid;
 
 	BUG_ON(!vma);
@@ -2280,13 +2296,22 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
+	{
+		int shift;
+
 		BUG_ON(addr >= vma->vm_end);
 		BUG_ON(addr < vma->vm_start);
 
-		pgoff = vma->vm_pgoff;
-		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
-		target_node = offset_il_node(pol, vma, pgoff);
+#ifdef CONFIG_HUGETLB_PAGE
+		if (transparent_hugepage_enabled(vma) || vma->vm_flags & VM_HUGETLB)
+			shift = HPAGE_SHIFT;
+		else
+#endif
+			shift = PAGE_SHIFT;
+
+		target_node = interleave_nid(pol, vma, addr, shift);
 		break;
+	}
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
@@ -2552,6 +2577,8 @@ void __init numa_policy_init(void)
 		};
 	}
 
+	default_policy_shared.v.nodes = node_online_map;
+
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or
@@ -2771,7 +2798,7 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 	 */
 	VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
 
-	if (!pol || pol == &default_policy)
+	if (!pol || pol == default_policy())
 		mode = MPOL_DEFAULT;
 	else
 		mode = pol->mode;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
