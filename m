Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 795646B009E
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:10:25 -0400 (EDT)
Message-Id: <20121025124833.861587584@chello.nl>
Date: Thu, 25 Oct 2012 14:16:35 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/31] mm/mpol: Use special PROT_NONE to migrate pages
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0018-mm-mpol-Use-special-PROT_NONE-to-migrate-pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

Combine our previous PROT_NONE, mpol_misplaced and
migrate_misplaced_page() pieces into an effective migrate on fault
scheme.

Note that (on x86) we rely on PROT_NONE pages being !present and avoid
the TLB flush from try_to_unmap(TTU_MIGRATION). This greatly improves
the page-migration performance.

Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Paul Turner <pjt@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c |   41 ++++++++++++++++++++++++++++++++++-
 mm/memory.c      |   63 +++++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 85 insertions(+), 19 deletions(-)

Index: tip/mm/huge_memory.c
===================================================================
--- tip.orig/mm/huge_memory.c
+++ tip/mm/huge_memory.c
@@ -18,6 +18,7 @@
 #include <linux/freezer.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
+#include <linux/migrate.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -741,12 +742,48 @@ void do_huge_pmd_numa_page(struct mm_str
 			   unsigned int flags, pmd_t entry)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct page *page = NULL;
+	int node;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry)))
 		goto out_unlock;
 
-	/* do fancy stuff */
+	if (unlikely(pmd_trans_splitting(entry))) {
+		spin_unlock(&mm->page_table_lock);
+		wait_split_huge_page(vma->anon_vma, pmd);
+		return;
+	}
+
+#ifdef CONFIG_NUMA
+	page = pmd_page(entry);
+	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+
+	get_page(page);
+	spin_unlock(&mm->page_table_lock);
+
+	/*
+	 * XXX should we serialize against split_huge_page ?
+	 */
+
+	node = mpol_misplaced(page, vma, haddr);
+	if (node == -1)
+		goto do_fixup;
+
+	/*
+	 * Due to lacking code to migrate thp pages, we'll split
+	 * (which preserves the special PROT_NONE) and re-take the
+	 * fault on the normal pages.
+	 */
+	split_huge_page(page);
+	put_page(page);
+	return;
+
+do_fixup:
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry)))
+		goto out_unlock;
+#endif
 
 	/* change back to regular protection */
 	entry = pmd_modify(entry, vma->vm_page_prot);
@@ -755,6 +792,8 @@ void do_huge_pmd_numa_page(struct mm_str
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
Index: tip/mm/memory.c
===================================================================
--- tip.orig/mm/memory.c
+++ tip/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/migrate.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -1467,8 +1468,10 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
 static bool pte_numa(struct vm_area_struct *vma, pte_t pte)
 {
 	/*
-	 * If we have the normal vma->vm_page_prot protections we're not a
-	 * 'special' PROT_NONE page.
+	 * For NUMA page faults, we use PROT_NONE ptes in VMAs with
+	 * "normal" vma->vm_page_prot protections.  Genuine PROT_NONE
+	 * VMAs should never get here, because the fault handling code
+	 * will notice that the VMA has no read or write permissions.
 	 *
 	 * This means we cannot get 'special' PROT_NONE faults from genuine
 	 * PROT_NONE maps, nor from PROT_WRITE file maps that do dirty
@@ -3473,35 +3476,59 @@ static int do_numa_page(struct mm_struct
 			unsigned long address, pte_t *ptep, pmd_t *pmd,
 			unsigned int flags, pte_t entry)
 {
+	struct page *page = NULL;
+	int node, page_nid = -1;
 	spinlock_t *ptl;
-	int ret = 0;
-
-	if (!pte_unmap_same(mm, pmd, ptep, entry))
-		goto out;
 
-	/*
-	 * Do fancy stuff...
-	 */
-
-	/*
-	 * OK, nothing to do,.. change the protection back to what it
-	 * ought to be.
-	 */
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pte_same(*ptep, entry)))
-		goto unlock;
+		goto out_unlock;
+
+	page = vm_normal_page(vma, address, entry);
+	if (page) {
+		get_page(page);
+		page_nid = page_to_nid(page);
+		node = mpol_misplaced(page, vma, address);
+		if (node != -1)
+			goto migrate;
+	}
 
+out_pte_upgrade_unlock:
 	flush_cache_page(vma, address, pte_pfn(entry));
 
 	ptep_modify_prot_start(mm, address, ptep);
 	entry = pte_modify(entry, vma->vm_page_prot);
 	ptep_modify_prot_commit(mm, address, ptep, entry);
 
+	/* No TLB flush needed because we upgraded the PTE */
+
 	update_mmu_cache(vma, address, ptep);
-unlock:
+
+out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
-	return ret;
+	if (page)
+		put_page(page);
+
+	return 0;
+
+migrate:
+	pte_unmap_unlock(ptep, ptl);
+
+	if (!migrate_misplaced_page(page, node)) {
+		page_nid = node;
+		goto out;
+	}
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_same(*ptep, entry)) {
+		put_page(page);
+		page = NULL;
+		goto out_unlock;
+	}
+
+	goto out_pte_upgrade_unlock;
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
