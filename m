Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C301582963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:10 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so8013606pde.26
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id xy8si12104947pab.324.2014.05.06.07.38.08
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/8] mm: kill zap_details->nonlinear_vma
Date: Tue,  6 May 2014 17:37:27 +0300
Message-Id: <1399387052-31660-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody creates nonlinear VMAs. No need to kill them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  1 -
 mm/madvise.c       |  9 +--------
 mm/memory.c        | 47 ++++-------------------------------------------
 3 files changed, 5 insertions(+), 52 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3e7b88ff15d6..156ca8025cec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1066,7 +1066,6 @@ extern void user_shm_unlock(size_t, struct user_struct *);
  * Parameter block passed down to zap_pte_range in exceptional cases.
  */
 struct zap_details {
-	struct vm_area_struct *nonlinear_vma;	/* Check page->index if set */
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb96b323..1932a1f0feda 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -278,14 +278,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
-	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
-		struct zap_details details = {
-			.nonlinear_vma = vma,
-			.last_index = ULONG_MAX,
-		};
-		zap_page_range(vma, start, end - start, &details);
-	} else
-		zap_page_range(vma, start, end - start, NULL);
+	zap_page_range(vma, start, end - start, NULL);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 037b812a9531..cc741a7ce71e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1111,28 +1111,12 @@ again:
 				if (details->check_mapping &&
 				    details->check_mapping != page->mapping)
 					continue;
-				/*
-				 * Each page->index must be checked when
-				 * invalidating or truncating nonlinear.
-				 */
-				if (details->nonlinear_vma &&
-				    (page->index < details->first_index ||
-				     page->index > details->last_index))
-					continue;
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
-			if (unlikely(details) && details->nonlinear_vma
-			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index) {
-				pte_t ptfile = pgoff_to_pte(page->index);
-				if (pte_soft_dirty(ptent))
-					pte_file_mksoft_dirty(ptfile);
-				set_pte_at(mm, addr, pte, ptfile);
-			}
 			if (PageAnon(page))
 				rss[MM_ANONPAGES]--;
 			else {
@@ -1154,10 +1138,7 @@ again:
 			}
 			continue;
 		}
-		/*
-		 * If details->check_mapping, we leave swap entries;
-		 * if details->nonlinear_vma, we leave file entries.
-		 */
+		/* If details->check_mapping, we leave swap entries */
 		if (unlikely(details))
 			continue;
 		if (pte_file(ptent)) {
@@ -1292,7 +1273,7 @@ static void unmap_page_range(struct mmu_gather *tlb,
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping)
 		details = NULL;
 
 	BUG_ON(addr >= end);
@@ -1388,7 +1369,7 @@ void unmap_vmas(struct mmu_gather *tlb,
  * @vma: vm_area_struct holding the applicable pages
  * @start: starting address of pages to zap
  * @size: number of bytes to zap
- * @details: details of nonlinear truncation or shared cache invalidation
+ * @details: details of shared cache invalidation
  *
  * Caller must protect the VMA list
  */
@@ -1414,7 +1395,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
  * @vma: vm_area_struct holding the applicable pages
  * @address: starting address of pages to zap
  * @size: number of bytes to zap
- * @details: details of nonlinear truncation or shared cache invalidation
+ * @details: details of shared cache invalidation
  *
  * The range must fit into one VMA.
  */
@@ -2977,23 +2958,6 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
 	}
 }
 
-static inline void unmap_mapping_range_list(struct list_head *head,
-					    struct zap_details *details)
-{
-	struct vm_area_struct *vma;
-
-	/*
-	 * In nonlinear VMAs there is no correspondence between virtual address
-	 * offset and file offset.  So we must perform an exhaustive search
-	 * across *all* the pages in each nonlinear VMA, not just the pages
-	 * whose virtual address lies outside the file truncation point.
-	 */
-	list_for_each_entry(vma, head, shared.nonlinear) {
-		details->nonlinear_vma = vma;
-		unmap_mapping_range_vma(vma, vma->vm_start, vma->vm_end, details);
-	}
-}
-
 /**
  * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
  * @mapping: the address space containing mmaps to be unmapped.
@@ -3024,7 +2988,6 @@ void unmap_mapping_range(struct address_space *mapping,
 	}
 
 	details.check_mapping = even_cows? NULL: mapping;
-	details.nonlinear_vma = NULL;
 	details.first_index = hba;
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
@@ -3034,8 +2997,6 @@ void unmap_mapping_range(struct address_space *mapping,
 	mutex_lock(&mapping->i_mmap_mutex);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
-		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	mutex_unlock(&mapping->i_mmap_mutex);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
