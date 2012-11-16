Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 176056B009B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:34 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 25/43] mm: numa: Migrate pages handled during a pmd_numa hinting fault
Date: Fri, 16 Nov 2012 11:22:35 +0000
Message-Id: <1353064973-26082-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

To say that the PMD handling code was incorrectly transferred from autonuma
is an understatement. The intention was to handle a PMDs worth of pages
in the same fault and effectively batch the taking of the PTL and page
migration. The copied version instead has the impact of clearing a number
of pte_numa PTE entries and whether any page migration takes place depends
on racing. This just happens to work in some cases.

This patch handles pte_numa faults in batch when a pmd_numa fault is
handled. The pages are migrated if they are currently misplaced.
Essentially this is making an assumption that NUMA locality is
on a PMD boundary but that could be addressed by only setting
pmd_numa if all the pages within that PMD are on the same node
if necessary.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c |   54 +++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 19 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8795a0a..a498e8d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3451,6 +3451,18 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+				unsigned long addr, int current_nid)
+{
+	get_page(page);
+
+	count_vm_numa_event(NUMA_HINT_FAULTS);
+	if (current_nid == numa_node_id())
+		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
+
+	return mpol_misplaced(page, vma, addr);
+}
+
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
@@ -3473,15 +3485,11 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*ptep, pte)))
 		goto out_unlock;
 
-	count_vm_numa_event(NUMA_HINT_FAULTS);
 	page = vm_normal_page(vma, addr, pte);
 	BUG_ON(!page);
 
-	get_page(page);
 	current_nid = page_to_nid(page);
-	if (current_nid == numa_node_id())
-		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
-	target_nid = mpol_misplaced(page, vma, addr);
+	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
 	if (target_nid == -1) {
 		/*
 		 * Account for the fault against the current node if it not
@@ -3491,9 +3499,8 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto clear_pmdnuma;
 	}
 
-	pte_unmap_unlock(ptep, ptl);
-
 	/* Migrate to the requested node */
+	pte_unmap_unlock(ptep, ptl);
 	newpage = migrate_misplaced_page(page, target_nid);
 	if (newpage)
 		current_nid = target_nid;
@@ -3524,7 +3531,8 @@ out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 	if (page)
 		put_page(page);
-	task_numa_fault(current_nid, 1);
+	if (current_nid != -1)
+		task_numa_fault(current_nid, 1);
 	return 0;
 }
 
@@ -3539,8 +3547,6 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	bool numa = false;
 	int local_nid = numa_node_id();
-	unsigned long nr_faults = 0;
-	unsigned long nr_faults_local = 0;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3563,7 +3569,8 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
-		int curr_nid;
+		int curr_nid = local_nid;
+		int target_nid;
 		if (!pte_present(pteval))
 			continue;
 		if (addr >= vma->vm_end) {
@@ -3582,21 +3589,30 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* only check non-shared pages */
 		if (unlikely(page_mapcount(page) != 1))
 			continue;
-		pte_unmap_unlock(pte, ptl);
 
-		curr_nid = page_to_nid(page);
-		task_numa_fault(curr_nid, 1);
+		/*
+		 * Note that the NUMA fault is later accounted to either
+		 * the node that is currently running or where the page is
+		 * migrated to.
+		 */
+		curr_nid = local_nid;
+		target_nid = numa_migrate_prep(page, vma, addr,
+					       page_to_nid(page));
+		if (target_nid == -1) {
+			put_page(page);
+			continue;
+		}
 
-		nr_faults++;
-		if (curr_nid == local_nid)
-			nr_faults_local++;
+		/* Migrate to the requested node */
+		pte_unmap_unlock(pte, ptl);
+		if (migrate_misplaced_page(page, target_nid))
+			curr_nid = target_nid;
+		task_numa_fault(curr_nid, 1);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
 	pte_unmap_unlock(orig_pte, ptl);
 
-	count_vm_numa_events(NUMA_HINT_FAULTS, nr_faults);
-	count_vm_numa_events(NUMA_HINT_FAULTS_LOCAL, nr_faults_local);
 	return 0;
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
