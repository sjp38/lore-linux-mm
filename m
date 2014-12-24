Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F0FFC6B006E
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:05 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so9951710pac.36
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t6si34277540pdi.126.2014.12.24.04.23.00
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/38] mm: drop support of non-linear mapping from unmap/zap codepath
Date: Wed, 24 Dec 2014 14:22:09 +0200
Message-Id: <1419423766-114457-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't create non-linear mappings anymore. Let's drop code which
handles them on unmap/zap.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  1 -
 mm/madvise.c       |  9 +-----
 mm/memory.c        | 82 ++++++++++++++----------------------------------------
 3 files changed, 22 insertions(+), 70 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f80d0194c9bc..07574d8072f4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1119,7 +1119,6 @@ extern void user_shm_unlock(size_t, struct user_struct *);
  * Parameter block passed down to zap_pte_range in exceptional cases.
  */
 struct zap_details {
-	struct vm_area_struct *nonlinear_vma;	/* Check page->index if set */
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
diff --git a/mm/madvise.c b/mm/madvise.c
index 6fc9b8298da1..8d74d7617598 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -419,14 +419,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
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
index 33f7370cc092..5216b91a714a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1082,6 +1082,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	spinlock_t *ptl;
 	pte_t *start_pte;
 	pte_t *pte;
+	swp_entry_t entry;
 
 again:
 	init_rss_vec(rss);
@@ -1107,28 +1108,12 @@ again:
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
-					ptfile = pte_file_mksoft_dirty(ptfile);
-				set_pte_at(mm, addr, pte, ptfile);
-			}
 			if (PageAnon(page))
 				rss[MM_ANONPAGES]--;
 			else {
@@ -1151,33 +1136,25 @@ again:
 			}
 			continue;
 		}
-		/*
-		 * If details->check_mapping, we leave swap entries;
-		 * if details->nonlinear_vma, we leave file entries.
-		 */
+		/* If details->check_mapping, we leave swap entries. */
 		if (unlikely(details))
 			continue;
-		if (pte_file(ptent)) {
-			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
-				print_bad_pte(vma, addr, ptent, NULL);
-		} else {
-			swp_entry_t entry = pte_to_swp_entry(ptent);
 
-			if (!non_swap_entry(entry))
-				rss[MM_SWAPENTS]--;
-			else if (is_migration_entry(entry)) {
-				struct page *page;
+		entry = pte_to_swp_entry(ptent);
+		if (!non_swap_entry(entry))
+			rss[MM_SWAPENTS]--;
+		else if (is_migration_entry(entry)) {
+			struct page *page;
 
-				page = migration_entry_to_page(entry);
+			page = migration_entry_to_page(entry);
 
-				if (PageAnon(page))
-					rss[MM_ANONPAGES]--;
-				else
-					rss[MM_FILEPAGES]--;
-			}
-			if (unlikely(!free_swap_and_cache(entry)))
-				print_bad_pte(vma, addr, ptent, NULL);
+			if (PageAnon(page))
+				rss[MM_ANONPAGES]--;
+			else
+				rss[MM_FILEPAGES]--;
 		}
+		if (unlikely(!free_swap_and_cache(entry)))
+			print_bad_pte(vma, addr, ptent, NULL);
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
@@ -1277,7 +1254,7 @@ static void unmap_page_range(struct mmu_gather *tlb,
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping)
 		details = NULL;
 
 	BUG_ON(addr >= end);
@@ -1371,7 +1348,7 @@ void unmap_vmas(struct mmu_gather *tlb,
  * @vma: vm_area_struct holding the applicable pages
  * @start: starting address of pages to zap
  * @size: number of bytes to zap
- * @details: details of nonlinear truncation or shared cache invalidation
+ * @details: details of shared cache invalidation
  *
  * Caller must protect the VMA list
  */
@@ -1397,7 +1374,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
  * @vma: vm_area_struct holding the applicable pages
  * @address: starting address of pages to zap
  * @size: number of bytes to zap
- * @details: details of nonlinear truncation or shared cache invalidation
+ * @details: details of shared cache invalidation
  *
  * The range must fit into one VMA.
  */
@@ -2324,25 +2301,11 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
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
- * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
+ * unmap_mapping_range - unmap the portion of all mmaps in the specified
+ * address_space corresponding to the specified page range in the underlying
+ * file.
+ *
  * @mapping: the address space containing mmaps to be unmapped.
  * @holebegin: byte in first page to unmap, relative to the start of
  * the underlying file.  This will be rounded down to a PAGE_SIZE
@@ -2371,7 +2334,6 @@ void unmap_mapping_range(struct address_space *mapping,
 	}
 
 	details.check_mapping = even_cows? NULL: mapping;
-	details.nonlinear_vma = NULL;
 	details.first_index = hba;
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
@@ -2381,8 +2343,6 @@ void unmap_mapping_range(struct address_space *mapping,
 	i_mmap_lock_read(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
-		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	i_mmap_unlock_read(mapping);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
