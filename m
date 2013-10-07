Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 059F49C0017
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:13 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7123062pad.33
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:13 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 31/63] mm: numa: only unmap migrate-on-fault VMAs
Date: Mon,  7 Oct 2013 11:29:09 +0100
Message-Id: <1381141781-10992-32-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There is a 90% regression observed with a large Oracle performance test
on a 4 node system. Profiles indicated that the overhead was due to
contention on sp_lock when looking up shared memory policies. These
policies do not have the appropriate flags to allow them to be
automatically balanced so trapping faults on them is pointless. This
patch skips VMAs that do not have MPOL_F_MOF set.

[riel@redhat.com: Initial patch]
Reviewed-by: Rik van Riel <riel@redhat.com>
Reported-and-tested-by: Joe Mario <jmario@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mempolicy.h |  1 +
 kernel/sched/fair.c       |  2 +-
 mm/mempolicy.c            | 24 ++++++++++++++++++++++++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index da6716b..ea4d249 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -136,6 +136,7 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 
 struct mempolicy *get_vma_policy(struct task_struct *tsk,
 		struct vm_area_struct *vma, unsigned long addr);
+bool vma_policy_mof(struct task_struct *task, struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b7052ed..1789e3c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1130,7 +1130,7 @@ void task_numa_work(struct callback_head *work)
 		vma = mm->mmap;
 	}
 	for (; vma; vma = vma->vm_next) {
-		if (!vma_migratable(vma))
+		if (!vma_migratable(vma) || !vma_policy_mof(p, vma))
 			continue;
 
 		do {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 196d8da..0e895a2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1679,6 +1679,30 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
 	return pol;
 }
 
+bool vma_policy_mof(struct task_struct *task, struct vm_area_struct *vma)
+{
+	struct mempolicy *pol = get_task_policy(task);
+	if (vma) {
+		if (vma->vm_ops && vma->vm_ops->get_policy) {
+			bool ret = false;
+
+			pol = vma->vm_ops->get_policy(vma, vma->vm_start);
+			if (pol && (pol->flags & MPOL_F_MOF))
+				ret = true;
+			mpol_cond_put(pol);
+
+			return ret;
+		} else if (vma->vm_policy) {
+			pol = vma->vm_policy;
+		}
+	}
+
+	if (!pol)
+		return default_policy.flags & MPOL_F_MOF;
+
+	return pol->flags & MPOL_F_MOF;
+}
+
 static int apply_policy_zone(struct mempolicy *policy, enum zone_type zone)
 {
 	enum zone_type dynamic_policy_zone = policy_zone;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
