Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id CDF908D0010
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:30 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:30 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 23/33] sched, numa, mm: Interleave shared tasks
Date: Thu, 22 Nov 2012 23:49:44 +0100
Message-Id: <1353624594-1118-24-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
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
 mm/mempolicy.c | 56 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 14 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 318043a..02890f2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -111,12 +111,30 @@ enum zone_type policy_zone = 0;
 /*
  * run-time system-wide default policy => local allocation
  */
-static struct mempolicy default_policy = {
-	.refcnt = ATOMIC_INIT(1), /* never free it */
-	.mode = MPOL_PREFERRED,
-	.flags = MPOL_F_LOCAL,
+
+static struct mempolicy default_policy_local = {
+	.refcnt		= ATOMIC_INIT(1), /* never free it */
+	.mode		= MPOL_PREFERRED,
+	.flags		= MPOL_F_LOCAL,
+};
+
+/*
+ * .v.nodes is set by numa_policy_init():
+ */
+static struct mempolicy default_policy_shared = {
+	.refcnt			= ATOMIC_INIT(1), /* never free it */
+	.mode			= MPOL_INTERLEAVE,
+	.flags			= 0,
 };
 
+static struct mempolicy *default_policy(void)
+{
+	if (task_numa_shared(current) == 1)
+		return &default_policy_shared;
+
+	return &default_policy_local;
+}
+
 static const struct mempolicy_operations {
 	int (*create)(struct mempolicy *pol, const nodemask_t *nodes);
 	/*
@@ -789,7 +807,7 @@ out:
 static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	nodes_clear(*nodes);
-	if (p == &default_policy)
+	if (p == default_policy())
 		return;
 
 	switch (p->mode) {
@@ -864,7 +882,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		return -EINVAL;
 
 	if (!pol)
-		pol = &default_policy;	/* indicates default behavior */
+		pol = default_policy();	/* indicates default behavior */
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
@@ -880,7 +898,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			goto out;
 		}
 	} else {
-		*policy = pol == &default_policy ? MPOL_DEFAULT :
+		*policy = pol == default_policy() ? MPOL_DEFAULT :
 						pol->mode;
 		/*
 		 * Internal mempolicy flags must be masked off before exposing
@@ -1568,7 +1586,7 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
 		}
 	}
 	if (!pol)
-		pol = &default_policy;
+		pol = default_policy();
 	return pol;
 }
 
@@ -1974,7 +1992,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	unsigned int cpuset_mems_cookie;
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
-		pol = &default_policy;
+		pol = default_policy();
 
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
@@ -2255,7 +2273,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	int best_nid = -1, page_nid;
 	int cpu_last_access, this_cpu;
 	struct mempolicy *pol;
-	unsigned long pgoff;
 	struct zone *zone;
 
 	BUG_ON(!vma);
@@ -2271,13 +2288,22 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
+	{
+		int shift;
+
 		BUG_ON(addr >= vma->vm_end);
 		BUG_ON(addr < vma->vm_start);
 
-		pgoff = vma->vm_pgoff;
-		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
-		best_nid = offset_il_node(pol, vma, pgoff);
+#ifdef CONFIG_HUGETLB_PAGE
+		if (transparent_hugepage_enabled(vma) || vma->vm_flags & VM_HUGETLB)
+			shift = HPAGE_SHIFT;
+		else
+#endif
+			shift = PAGE_SHIFT;
+
+		best_nid = interleave_nid(pol, vma, addr, shift);
 		break;
+	}
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
@@ -2492,6 +2518,8 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL);
 
+	default_policy_shared.v.nodes = node_online_map;
+
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or
@@ -2712,7 +2740,7 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
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
