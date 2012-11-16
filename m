Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7F4216B0087
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:17 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/43] mm: mempolicy: Use _PAGE_NUMA to migrate pages
Date: Fri, 16 Nov 2012 11:22:24 +0000
Message-Id: <1353064973-26082-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Note: Based on "mm/mpol: Use special PROT_NONE to migrate pages" but
	sufficiently different that the signed-off-bys were dropped

Combine our previous _PAGE_NUMA, mpol_misplaced and migrate_misplaced_page()
pieces into an effective migrate on fault scheme.

Note that (on x86) we rely on PROT_NONE pages being !present and avoid
the TLB flush from try_to_unmap(TTU_MIGRATION). This greatly improves the
page-migration performance.

Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/huge_mm.h |    8 ++++----
 mm/huge_memory.c        |   32 +++++++++++++++++++++++++++++---
 mm/memory.c             |   44 ++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 73 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a13ebb1..406f81c 100644
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
-					pmd_t pmd, pmd_t *pmdp);
+static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+					unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 {
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 92a64d2..1453c30 100644
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
@@ -1018,16 +1019,39 @@ out:
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
-				pmd_t pmd, pmd_t *pmdp)
+int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
-	struct page *page;
+	struct page *page = NULL;
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
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
 	set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
@@ -1035,6 +1059,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 4291fa3..d5dda73 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/migrate.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3453,8 +3454,9 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
-	struct page *page;
+	struct page *page = NULL;
 	spinlock_t *ptl;
+	int current_nid, target_nid;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3469,14 +3471,48 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*ptep, pte)))
 		goto out_unlock;
-	pte = pte_mknonnuma(pte);
-	set_pte_at(mm, addr, ptep, pte);
+
 	page = vm_normal_page(vma, addr, pte);
 	BUG_ON(!page);
+
+	get_page(page);
+	current_nid = page_to_nid(page);
+	target_nid = mpol_misplaced(page, vma, addr);
+	if (target_nid == -1) {
+		/*
+		 * Account for the fault against the current node if it not
+		 * being replaced regardless of where the page is located.
+		 */
+		current_nid = numa_node_id();
+		goto clear_pmdnuma;
+	}
+	pte_unmap_unlock(ptep, ptl);
+
+	/* Migrate to the requested node */
+	if (migrate_misplaced_page(page, target_nid)) {
+		/*
+		 * If the page was migrated then the pte_same check below is
+		 * guaranteed to fail so just retry the entire fault.
+		 */
+		current_nid = target_nid;
+		goto out;
+	}
+	page = NULL;
+
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	if (!pte_same(*ptep, pte))
+		goto out_unlock;
+
+clear_pmdnuma:
+	pte = pte_mknonnuma(pte);
+	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
+	if (page)
+		put_page(page);
+out:
 	return 0;
 }
 
@@ -3643,7 +3679,7 @@ retry:
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
 			if (pmd_numa(*pmd))
-				return do_huge_pmd_numa_page(mm, address,
+				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
 
 			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
