Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C31FD900001
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:29:52 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7214186pab.29
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:29:52 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/63] mm: numa: Sanitize task_numa_fault() callsites
Date: Mon,  7 Oct 2013 11:28:45 +0100
Message-Id: <1381141781-10992-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There are three callers of task_numa_fault():

 - do_huge_pmd_numa_page():
     Accounts against the current node, not the node where the
     page resides, unless we migrated, in which case it accounts
     against the node we migrated to.

 - do_numa_page():
     Accounts against the current node, not the node where the
     page resides, unless we migrated, in which case it accounts
     against the node we migrated to.

 - do_pmd_numa_page():
     Accounts not at all when the page isn't migrated, otherwise
     accounts against the node we migrated towards.

This seems wrong to me; all three sites should have the same
sementaics, furthermore we should accounts against where the page
really is, we already know where the task is.

So modify all three sites to always account; we did after all receive
the fault; and always account to where the page is after migration,
regardless of success.

They all still differ on when they clear the PTE/PMD; ideally that
would get sorted too.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 25 +++++++++++++------------
 mm/memory.c      | 53 +++++++++++++++++++++--------------------------------
 2 files changed, 34 insertions(+), 44 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1d6334f..c3bb65f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1281,18 +1281,19 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct anon_vma *anon_vma = NULL;
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
+	int page_nid = -1, this_nid = numa_node_id();
 	int target_nid;
-	int current_nid = -1;
-	bool migrated, page_locked;
+	bool page_locked;
+	bool migrated = false;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
 	page = pmd_page(pmd);
-	current_nid = page_to_nid(page);
+	page_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	/*
@@ -1335,19 +1336,18 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
-	if (!migrated)
+	if (migrated)
+		page_nid = target_nid;
+	else
 		goto check_same;
 
-	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
-	if (anon_vma)
-		page_unlock_anon_vma_read(anon_vma);
-	return 0;
+	goto out;
 
 check_same:
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		/* Someone else took our fault */
-		current_nid = -1;
+		page_nid = -1;
 		goto out_unlock;
 	}
 clear_pmdnuma:
@@ -1362,8 +1362,9 @@ out:
 	if (anon_vma)
 		page_unlock_anon_vma_read(anon_vma);
 
-	if (current_nid != -1)
-		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
+	if (page_nid != -1)
+		task_numa_fault(page_nid, HPAGE_PMD_NR, migrated);
+
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index ca00039..42ae82e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3519,12 +3519,12 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-				unsigned long addr, int current_nid)
+				unsigned long addr, int page_nid)
 {
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	return mpol_misplaced(page, vma, addr);
@@ -3535,7 +3535,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int current_nid = -1;
+	int page_nid = -1;
 	int target_nid;
 	bool migrated = false;
 
@@ -3565,15 +3565,10 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
-	current_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
+	page_nid = page_to_nid(page);
+	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
-		/*
-		 * Account for the fault against the current node if it not
-		 * being replaced regardless of where the page is located.
-		 */
-		current_nid = numa_node_id();
 		put_page(page);
 		goto out;
 	}
@@ -3581,11 +3576,11 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, target_nid);
 	if (migrated)
-		current_nid = target_nid;
+		page_nid = target_nid;
 
 out:
-	if (current_nid != -1)
-		task_numa_fault(current_nid, 1, migrated);
+	if (page_nid != -1)
+		task_numa_fault(page_nid, 1, migrated);
 	return 0;
 }
 
@@ -3600,7 +3595,6 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int local_nid = numa_node_id();
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3623,9 +3617,10 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
-		int curr_nid = local_nid;
+		int page_nid = -1;
 		int target_nid;
-		bool migrated;
+		bool migrated = false;
+
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3647,25 +3642,19 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(page_mapcount(page) != 1))
 			continue;
 
-		/*
-		 * Note that the NUMA fault is later accounted to either
-		 * the node that is currently running or where the page is
-		 * migrated to.
-		 */
-		curr_nid = local_nid;
-		target_nid = numa_migrate_prep(page, vma, addr,
-					       page_to_nid(page));
-		if (target_nid == -1) {
+		page_nid = page_to_nid(page);
+		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
+		pte_unmap_unlock(pte, ptl);
+		if (target_nid != -1) {
+			migrated = migrate_misplaced_page(page, target_nid);
+			if (migrated)
+				page_nid = target_nid;
+		} else {
 			put_page(page);
-			continue;
 		}
 
-		/* Migrate to the requested node */
-		pte_unmap_unlock(pte, ptl);
-		migrated = migrate_misplaced_page(page, target_nid);
-		if (migrated)
-			curr_nid = target_nid;
-		task_numa_fault(curr_nid, 1, migrated);
+		if (page_nid != -1)
+			task_numa_fault(page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
