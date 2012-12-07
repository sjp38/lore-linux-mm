Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 8FC796B0070
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:46 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277755eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:46 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 5/9] numa, mm, sched: Fix NUMA affinity tracking logic
Date: Fri,  7 Dec 2012 01:19:22 +0100
Message-Id: <1354839566-15697-6-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Support for the p->numa_policy affinity tracking by the scheduler
went missing during the mm/ unification: revive and integrate it
properly.

( This in particular fixes NUMA_POLICY_MANYBUDDIES, which
  bug caused a few regressions in various workloads such as
  numa01 and regressed !THP workloads in particular. )

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/mempolicy.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2f2095c..6bb9fd0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -121,8 +121,10 @@ static struct mempolicy default_policy_local = {
 static struct mempolicy *default_policy(void)
 {
 #ifdef CONFIG_NUMA_BALANCING
-	if (task_numa_shared(current) == 1)
-		return &current->numa_policy;
+	struct mempolicy *pol = &current->numa_policy;
+
+	if (task_numa_shared(current) == 1 && nodes_weight(pol->v.nodes) >= 2)
+		return pol;
 #endif
 	return &default_policy_local;
 }
@@ -135,6 +137,11 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
 	int node;
 
 	if (!pol) {
+#ifdef CONFIG_NUMA_BALANCING
+		pol = default_policy();
+		if (pol != &default_policy_local)
+			return pol;
+#endif
 		node = numa_node_id();
 		if (node != -1)
 			pol = &preferred_node_policy[node];
@@ -2367,7 +2374,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 			shift = PAGE_SHIFT;
 
 		target_node = interleave_nid(pol, vma, addr, shift);
-		break;
+
+		goto out_keep_page;
 	}
 
 	case MPOL_PREFERRED:
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
