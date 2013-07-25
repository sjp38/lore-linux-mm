Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C64536B0033
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 06:38:55 -0400 (EDT)
Date: Thu, 25 Jul 2013 12:38:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] mm, numa: Sanitize task_numa_fault() callsites
Message-ID: <20130725103845.GN27075@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


Subject: mm, numa: Sanitize task_numa_fault() callsites
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon Jul 22 10:42:38 CEST 2013

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

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 mm/huge_memory.c |   24 ++++++++++++++----------
 mm/memory.c      |   52 ++++++++++++++++++++++------------------------------
 2 files changed, 36 insertions(+), 40 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1292,9 +1292,9 @@ int do_huge_pmd_numa_page(struct mm_stru
 {
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
+	int page_nid = -1, this_nid = numa_node_id();
 	int target_nid, last_nidpid;
-	int src_nid = -1;
-	bool migrated;
+	bool migrated = false;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1311,9 +1311,9 @@ int do_huge_pmd_numa_page(struct mm_stru
 	if (is_huge_zero_page(page))
 		goto clear_pmdnuma;
 
-	src_nid = numa_node_id();
+	page_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (src_nid == page_to_nid(page))
+	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	last_nidpid = page_nidpid_last(page);
@@ -1327,7 +1327,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 	spin_unlock(&mm->page_table_lock);
 	lock_page(page);
 
-	/* Confirm the PTE did not while locked */
+	/* Confirm the PMD didn't change while we released the page_table_lock */
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
@@ -1339,11 +1339,12 @@ int do_huge_pmd_numa_page(struct mm_stru
 	/* Migrate the THP to the requested node */
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
-	if (!migrated)
+	if (migrated)
+		page_nid = target_nid;
+	else
 		goto check_same;
 
-	task_numa_fault(last_nidpid, target_nid, HPAGE_PMD_NR, true);
-	return 0;
+	goto out;
 
 check_same:
 	spin_lock(&mm->page_table_lock);
@@ -1356,8 +1357,11 @@ int do_huge_pmd_numa_page(struct mm_stru
 	update_mmu_cache_pmd(vma, addr, pmdp);
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (src_nid != -1)
-		task_numa_fault(last_nidpid, src_nid, HPAGE_PMD_NR, false);
+
+out:
+	if (page_nid != -1)
+		task_numa_fault(last_nidpid, page_nid, HPAGE_PMD_NR, migrated);
+
 	return 0;
 }
 
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3533,8 +3533,8 @@ int do_numa_page(struct mm_struct *mm, s
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int current_nid = -1, last_nidpid;
-	int target_nid;
+	int page_nid = -1;
+	int target_nid, last_nidpid;
 	bool migrated = false;
 
 	/*
@@ -3569,15 +3569,10 @@ int do_numa_page(struct mm_struct *mm, s
 	}
 
 	last_nidpid = page_nidpid_last(page);
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
@@ -3585,11 +3580,12 @@ int do_numa_page(struct mm_struct *mm, s
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated)
-		current_nid = target_nid;
+		page_nid = target_nid;
 
 out:
-	if (current_nid != -1)
-		task_numa_fault(last_nidpid, current_nid, 1, migrated);
+	if (page_nid != -1)
+		task_numa_fault(last_nidpid, page_nid, 1, migrated);
+
 	return 0;
 }
 
@@ -3604,7 +3600,6 @@ static int do_pmd_numa_page(struct mm_st
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int local_nid = numa_node_id();
 	int last_nidpid;
 
 	spin_lock(&mm->page_table_lock);
@@ -3628,9 +3623,10 @@ static int do_pmd_numa_page(struct mm_st
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
@@ -3649,26 +3645,22 @@ static int do_pmd_numa_page(struct mm_st
 		if (unlikely(!page))
 			continue;
 
-		/*
-		 * Note that the NUMA fault is later accounted to either
-		 * the node that is currently running or where the page is
-		 * migrated to.
-		 */
-		curr_nid = local_nid;
 		last_nidpid = page_nidpid_last(page);
+		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr,
-					       page_to_nid(page));
-		if (target_nid == -1) {
+				               page_nid);
+		pte_unmap_unlock(pte, ptl);
+
+		if (target_nid != -1) {
+			migrated = migrate_misplaced_page(page, vma, target_nid);
+			if (migrated)
+				page_nid = target_nid;
+		} else {
 			put_page(page);
-			continue;
 		}
 
-		/* Migrate to the requested node */
-		pte_unmap_unlock(pte, ptl);
-		migrated = migrate_misplaced_page(page, vma, target_nid);
-		if (migrated)
-			curr_nid = target_nid;
-		task_numa_fault(last_nidpid, curr_nid, 1, migrated);
+		if (page_nid != -1)
+			task_numa_fault(last_nidpid, page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
