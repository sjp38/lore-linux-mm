Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67DE66B0253
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 05:59:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so320428279pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 02:59:27 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id dr13si2704322pac.245.2016.04.18.02.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 02:59:26 -0700 (PDT)
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <kvaneesh@skywalker.in.ibm.com>;
	Mon, 18 Apr 2016 19:59:22 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3E02C2BB0059
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:59:14 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3I9wod629819004
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:59:14 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3I9wQdP004239
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:58:26 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH] mm/mmu_gather: Track page size with mmu gather and force flush if page size change
Date: Mon, 18 Apr 2016 15:28:03 +0530
Message-Id: <1460973483-9234-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This allows arch which need to do special handing with respect to
different page size when flushing tlb to implement the same in mmu gather

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/asm-generic/tlb.h | 11 +++++++---
 mm/huge_memory.c          |  2 +-
 mm/hugetlb.c              | 54 ++++++++++++++++++-----------------------------
 mm/memory.c               | 38 +++++++++++++++++++++++++++------
 4 files changed, 61 insertions(+), 44 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9dbb739cafa0..876ceb44a3bb 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -107,6 +107,7 @@ struct mmu_gather {
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
 	unsigned int		batch_count;
+	int page_size;
 };
 
 #define HAVE_GENERIC_MMU_GATHER
@@ -115,16 +116,20 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
-int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
+bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page, int page_size);
 
 /* tlb_remove_page
  *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
  *	required.
  */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page,
+				   int page_size)
 {
-	if (!__tlb_remove_page(tlb, page))
+	if (__tlb_remove_page(tlb, page, page_size)) {
 		tlb_flush_mmu(tlb);
+		tlb->page_size = page_size;
+		__tlb_remove_page(tlb, page, page_size);
+	}
 }
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36c22a89df61..c1c067e94479 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1669,7 +1669,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, page);
+		tlb_remove_page(tlb, page, HPAGE_PMD_SIZE);
 	}
 	return 1;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d1b07387c5db..d158ceb89ead 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3121,7 +3121,6 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			    unsigned long start, unsigned long end,
 			    struct page *ref_page)
 {
-	int force_flush = 0;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *ptep;
@@ -3140,19 +3139,22 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
-again:
 	for (; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
 
 		ptl = huge_pte_lock(h, mm, ptep);
-		if (huge_pmd_unshare(mm, &address, ptep))
-			goto unlock;
+		if (huge_pmd_unshare(mm, &address, ptep)) {
+			spin_unlock(ptl);
+			continue;
+		}
 
 		pte = huge_ptep_get(ptep);
-		if (huge_pte_none(pte))
-			goto unlock;
+		if (huge_pte_none(pte)) {
+			spin_unlock(ptl);
+			continue;
+		}
 
 		/*
 		 * Migrating hugepage or HWPoisoned hugepage is already
@@ -3160,7 +3162,8 @@ again:
 		 */
 		if (unlikely(!pte_present(pte))) {
 			huge_pte_clear(mm, address, ptep);
-			goto unlock;
+			spin_unlock(ptl);
+			continue;
 		}
 
 		page = pte_page(pte);
@@ -3170,9 +3173,10 @@ again:
 		 * are about to unmap is the actual page of interest.
 		 */
 		if (ref_page) {
-			if (page != ref_page)
-				goto unlock;
-
+			if (page != ref_page) {
+				spin_unlock(ptl);
+				continue;
+			}
 			/*
 			 * Mark the VMA as having unmapped its page so that
 			 * future faults in this VMA will fail rather than
@@ -3188,30 +3192,14 @@ again:
 
 		hugetlb_count_sub(pages_per_huge_page(h), mm);
 		page_remove_rmap(page, true);
-		force_flush = !__tlb_remove_page(tlb, page);
-		if (force_flush) {
-			address += sz;
-			spin_unlock(ptl);
-			break;
-		}
-		/* Bail out after unmapping reference page if supplied */
-		if (ref_page) {
-			spin_unlock(ptl);
-			break;
-		}
-unlock:
+
 		spin_unlock(ptl);
-	}
-	/*
-	 * mmu_gather ran out of room to batch pages, we break out of
-	 * the PTE lock to avoid doing the potential expensive TLB invalidate
-	 * and page-free while holding it.
-	 */
-	if (force_flush) {
-		force_flush = 0;
-		tlb_flush_mmu(tlb);
-		if (address < end && !ref_page)
-			goto again;
+		tlb_remove_page(tlb, page, huge_page_size(h));
+		/*
+		 * Bail out after unmapping reference page if supplied
+		 */
+		if (ref_page)
+			break;
 	}
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	tlb_end_vma(tlb, vma);
diff --git a/mm/memory.c b/mm/memory.c
index 635451abc8f7..7700edf9e243 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -231,6 +231,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+	tlb->page_size = 0 ;
 
 	__tlb_reset_range(tlb);
 }
@@ -290,23 +291,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
  *	handling the additional races in SMP caused by other CPUs caching valid
  *	mappings in their TLBs. Returns the number of free page slots left.
  *	When out of page slots we must call tlb_flush_mmu().
+ *returns true if the caller should flush.
  */
-int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page, int page_size)
 {
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
 
+	if (!tlb->page_size)
+		tlb->page_size = page_size;
+	else {
+		if (page_size != tlb->page_size)
+			return true;
+	}
+
 	batch = tlb->active;
-	batch->pages[batch->nr++] = page;
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
-			return 0;
+			return true;
 		batch = tlb->active;
 	}
 	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
 
-	return batch->max - batch->nr;
+	batch->pages[batch->nr++] = page;
+	return false;
+}
+
+int __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *page)
+{
+	/* active->nr should be zero when we call this */
+	VM_BUG_ON_PAGE(tlb->active->nr, page);
+	tlb->page_size = PAGE_SIZE;
+	return __tlb_remove_page(tlb, page, PAGE_SIZE);
 }
 
 #endif /* HAVE_GENERIC_MMU_GATHER */
@@ -1071,6 +1088,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	pte_t *start_pte;
 	pte_t *pte;
 	swp_entry_t entry;
+	struct page *delayed_page = NULL;
 
 again:
 	init_rss_vec(rss);
@@ -1116,8 +1134,9 @@ again:
 			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			if (unlikely(!__tlb_remove_page(tlb, page))) {
+			if (unlikely(__tlb_remove_page(tlb, page, PAGE_SIZE))) {
 				force_flush = 1;
+				delayed_page = page;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1158,9 +1177,14 @@ again:
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu_free(tlb);
-
-		if (addr != end)
+		if (delayed_page) {
+			/* remove the page with new size */
+			__tlb_remove_pte_page(tlb, delayed_page);
+			delayed_page = NULL;
+		}
+		if (addr != end) {
 			goto again;
+		}
 	}
 
 	return addr;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
