Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B38406B009D
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:10:35 -0400 (EDT)
Message-Id: <20121025124834.012980641@chello.nl>
Date: Thu, 25 Oct 2012 14:16:37 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/31] sched, numa, mm/mpol: Make mempolicy home-node aware
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0020-sched-numa-mm-mpol-Make-mempolicy-home-node-aware.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>

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
---
 mm/mempolicy.c |   29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
@@ -117,6 +117,22 @@ static struct mempolicy default_policy =
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
+		node = tsk_home_node(p);
+		if (node != -1)
+			pol = &preferred_node_policy[node];
+	}
+
+	return pol;
+}
+
 static const struct mempolicy_operations {
 	int (*create)(struct mempolicy *pol, const nodemask_t *nodes);
 	/*
@@ -1565,7 +1581,7 @@ asmlinkage long compat_sys_mbind(compat_
 struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
-	struct mempolicy *pol = task->mempolicy;
+	struct mempolicy *pol = get_task_policy(task);
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
@@ -1965,7 +1981,7 @@ retry_cpuset:
  */
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
-	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy *pol = get_task_policy(current);
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 
@@ -2424,6 +2440,15 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL);
 
+	for_each_node(nid) {
+		preferred_node_policy[nid] = (struct mempolicy) {
+			.refcnt = ATOMIC_INIT(1),
+			.mode = MPOL_PREFERRED,
+			.flags = MPOL_F_MOF,
+			.v = { .preferred_node = nid, },
+		};
+	}
+
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
