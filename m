Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B37746B0099
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:35 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 26/43] mm: numa: Only mark a PMD pmd_numa if the pages are all on the same node
Date: Fri, 16 Nov 2012 11:22:36 +0000
Message-Id: <1353064973-26082-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When a pmd_numa fault is handled, all PTEs are treated as if the current
CPU had referenced them and handles it as one fault. This effectively
batches the ptl but loses precision. This patch will only set the PMD
pmd_numa if the examined pages are all on the same node. If the workload
is converged on a PMD boundary then the batch handling is equivalent.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mempolicy.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bcaa4fe..ca201e9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -604,6 +604,8 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 	int nr_pte_updates = 0;
+	bool all_same_node = true;
+	int last_nid = -1;
 
 	VM_BUG_ON(address & ~PAGE_MASK);
 
@@ -662,6 +664,7 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (_address = address, _pte = pte; _address < end;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
+		int this_nid;
 		if (!pte_present(pteval))
 			continue;
 		if (pte_numa(pteval))
@@ -669,6 +672,18 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			continue;
+
+		/*
+		 * Check if all pages within the PMD are on the same node. This
+		 * is an approximation as existing pte_numa pages are not
+		 * examined.
+		 */
+		this_nid = page_to_nid(page);
+		if (last_nid == -1)
+			last_nid = this_nid;
+		if (last_nid != this_nid)
+			all_same_node = false;
+
 		/* only check non-shared pages */
 		if (page_mapcount(page) != 1)
 			continue;
@@ -681,7 +696,11 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	pte_unmap_unlock(pte, ptl);
 
-	if (ret && !pmd_numa(*pmd)) {
+	/*
+	 * If all the pages within the PMD are on the same node then mark
+	 * the PMD so it is handled in one fault when next referenced.
+	 */
+	if (all_same_node && !pmd_numa(*pmd)) {
 		spin_lock(&mm->page_table_lock);
 		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
 		spin_unlock(&mm->page_table_lock);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
