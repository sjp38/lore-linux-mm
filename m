Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9A3D16B0044
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/13] sched: Check current->mm before allocating NUMA faults
Date: Wed,  3 Jul 2013 15:21:38 +0100
Message-Id: <1372861300-9973-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

task_numa_placement checks current->mm but after buffers for faults
have already been uselessly allocated. Move the check earlier.

[peterz@infradead.org: Identified the problem]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 336074f..3c796b0 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -870,8 +870,6 @@ static void task_numa_placement(struct task_struct *p)
 	int seq, nid, max_nid = 0;
 	unsigned long max_faults = 0;
 
-	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
-		return;
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
@@ -945,6 +943,12 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 	if (!sched_feat_numa(NUMA))
 		return;
 
+	/* for example, ksmd faulting in a user's mm */
+	if (!p->mm) {
+		p->numa_scan_period = sysctl_numa_balancing_scan_period_max;
+		return;
+	}
+
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
 		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
@@ -1072,16 +1076,18 @@ void task_numa_work(struct callback_head *work)
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
 			end = min(end, vma->vm_end);
 			nr_pte_updates += change_prot_numa(vma, start, end);
-			pages -= (end - start) >> PAGE_SHIFT;
-
-			start = end;
 
 			/*
 			 * Scan sysctl_numa_balancing_scan_size but ensure that
-			 * least one PTE is updated so that unused virtual
-			 * address space is quickly skipped
+			 * at least one PTE is updated so that unused virtual
+			 * address space is quickly skipped.
 			 */
-			if (pages <= 0 && nr_pte_updates)
+			if (nr_pte_updates)
+				pages -= (end - start) >> PAGE_SHIFT;
+
+			start = end;
+
+			if (pages <= 0)
 				goto out;
 		} while (end != vma->vm_end);
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
