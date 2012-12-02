Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 88DB36B007B
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:44:25 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:44:25 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 13/52] mm/mempolicy: Use _PAGE_NUMA to migrate pages
Date: Sun,  2 Dec 2012 19:43:05 +0100
Message-Id: <1354473824-19229-14-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

From: Mel Gorman <mgorman@suse.de>

Note: Based on "mm/mpol: Use special PROT_NONE to migrate pages"
but 	sufficiently different that the signed-off-bys were dropped

Combine our previous _PAGE_NUMA, mpol_misplaced and
migrate_misplaced_page() pieces into an effective migrate on
fault scheme.

Note that (on x86) we rely on PROT_NONE pages being !present and
avoid the TLB flush from try_to_unmap(TTU_MIGRATION). This
greatly improves the page-migration performance.

Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Shi <lkml.alex@gmail.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/huge_mm.h |  8 ++++----
 mm/huge_memory.c        | 31 ++++++++++++++++++++++++++++---
 mm/memory.c             | 32 +++++++++++++++++++++++++++-----
 3 files changed, 59 insertions(+), 12 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6cd7dcb..dabb510 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -160,8 +160,8 @@ static inline struct page *compound_trans_head(struct page *page)
 	return page;
 }
 
-extern int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
-				  pmd_t pmd, pmd_t *pmdp);
+extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
@@ -200,8 +200,8 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
 	return 0;
 }
 
-static inline int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
-					pmd_t pmd, pmd_t *pmdp)
+static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+					unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 900eb1b..5723b55 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -18,6 +18,7 @@
 #include <linux/freezer.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
+#include <linux/migrate.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -1019,17 +1020,39 @@ out:
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
-				pmd_t pmd, pmd_t *pmdp)
+int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
+	struct page *page = NULL;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	struct page *page;
+	int target_nid;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
 	page = pmd_page(pmd);
+	get_page(page);
+	spin_unlock(&mm->page_table_lock);
+
+	target_nid = mpol_misplaced(page, vma, haddr);
+	if (target_nid == -1)
+		goto clear_pmdnuma;
+
+	/*
+	 * Due to lacking code to migrate thp pages, we'll split
+	 * (which preserves the special PROT_NONE) and re-take the
+	 * fault on the normal pages.
+	 */
+	split_huge_page(page);
+	put_page(page);
+	return 0;
+
+clear_pmdnuma:
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(pmd, *pmdp)))
+		goto out_unlock;
+
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
@@ -1037,6 +1060,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 290b80a..174f006 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/migrate.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3451,8 +3452,9 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
-	struct page *page;
+	struct page *page = NULL;
 	spinlock_t *ptl;
+	int current_nid, target_nid;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3465,8 +3467,11 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	*/
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, pte)))
-		goto out_unlock;
+	if (unlikely(!pte_same(*ptep, pte))) {
+		pte_unmap_unlock(ptep, ptl);
+		goto out;
+	}
+
 	pte = pte_mknonnuma(pte);
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
@@ -3477,8 +3482,25 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
-out_unlock:
+	get_page(page);
+	current_nid = page_to_nid(page);
+	target_nid = mpol_misplaced(page, vma, addr);
 	pte_unmap_unlock(ptep, ptl);
+	if (target_nid == -1) {
+		/*
+		 * Account for the fault against the current node if it not
+		 * being replaced regardless of where the page is located.
+		 */
+		current_nid = numa_node_id();
+		put_page(page);
+		goto out;
+	}
+
+	/* Migrate to the requested node */
+	if (migrate_misplaced_page(page, target_nid))
+		current_nid = target_nid;
+
+out:
 	return 0;
 }
 
@@ -3647,7 +3669,7 @@ retry:
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
 			if (pmd_numa(*pmd))
-				return do_huge_pmd_numa_page(mm, address,
+				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
 
 			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
