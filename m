Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6902F6B0081
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:13:22 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/31] mm: numa: Only call task_numa_placement for misplaced pages
Date: Tue, 13 Nov 2012 11:12:45 +0000
Message-Id: <1352805180-1607-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

task_numa_placement is potentially very expensive so limit it to being
called when a page is misplaced. How necessary this is depends on
the placement policy.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |    4 ++--
 kernel/sched/fair.c   |    9 +++++++--
 mm/huge_memory.c      |    2 +-
 mm/memory.c           |    6 ++++--
 4 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ac71181..241e4f7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1562,9 +1562,9 @@ struct task_struct {
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
 #ifdef CONFIG_BALANCE_NUMA
-extern void task_numa_fault(int node, int pages);
+extern void task_numa_fault(int node, int pages, bool was_misplaced);
 #else
-static inline void task_numa_fault(int node, int pages)
+static inline void task_numa_fault(int node, int pages, bool was_misplaced)
 {
 }
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e8bdaef..9ea13e9 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -799,13 +799,18 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int pages)
+void task_numa_fault(int node, int pages, bool misplaced)
 {
 	struct task_struct *p = current;
 
 	/* FIXME: Allocate task-specific structure for placement policy here */
 
-	task_numa_placement(p);
+	/*
+	 * task_numa_placement can be expensive so only call it if pages were
+	 * misplaced
+	 */
+	if (misplaced)
+		task_numa_placement(p);
 }
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ccff412..833a601 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1062,7 +1062,7 @@ out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	if (page) {
 		put_page(page);
-		task_numa_fault(numa_node_id(), HPAGE_PMD_NR);
+		task_numa_fault(numa_node_id(), HPAGE_PMD_NR, false);
 	}
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index cd348fd..ab9fbcf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3441,6 +3441,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int current_nid = -1;
 	int target_nid;
+	bool misplaced = false;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3470,6 +3471,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		current_nid = numa_node_id();
 		goto clear_pmdnuma;
 	}
+	misplaced = true;
 
 	pte_unmap_unlock(ptep, ptl);
 
@@ -3498,7 +3500,7 @@ out_unlock:
 	if (page)
 		put_page(page);
 out:
-	task_numa_fault(current_nid, 1);
+	task_numa_fault(current_nid, 1, misplaced);
 	return 0;
 }
 
@@ -3556,7 +3558,7 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 
 		curr_nid = page_to_nid(page);
-		task_numa_fault(curr_nid, 1);
+		task_numa_fault(curr_nid, 1, false);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
