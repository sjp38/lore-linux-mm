Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 1B3716B0072
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:14 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 5/8] Discard volatile page
Date: Thu,  3 Jan 2013 13:28:03 +0900
Message-Id: <1357187286-18759-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

VM don't need to swap out volatile pages. Instead, it just discards
pages and set true to the vma's purge state so if user try to access
purged vma without calling mnovolatile, it will encounter SIGBUS.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/memory.h    |    2 +
 include/linux/mvolatile.h |   20 +++++
 include/linux/rmap.h      |    2 +
 mm/memory.c               |   10 ++-
 mm/mvolatile.c            |  185 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/rmap.c                 |    3 +-
 mm/vmscan.c               |   13 ++++
 7 files changed, 230 insertions(+), 5 deletions(-)

diff --git a/include/linux/memory.h b/include/linux/memory.h
index ff9a9f8..0c50bec 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -150,5 +150,7 @@ struct memory_accessor {
  * can sleep.
  */
 extern struct mutex text_mutex;
+void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
+			  pte_t pte, struct page *page);
 
 #endif /* _LINUX_MEMORY_H_ */
diff --git a/include/linux/mvolatile.h b/include/linux/mvolatile.h
index cfb12b4..eb07761 100644
--- a/include/linux/mvolatile.h
+++ b/include/linux/mvolatile.h
@@ -2,8 +2,15 @@
 #define __LINUX_MVOLATILE_H
 
 #include <linux/syscalls.h>
+#include <linux/rmap.h>
 
 #ifdef CONFIG_VOLATILE_PAGE
+
+static inline bool is_volatile_vma(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_VOLATILE;
+}
+
 static inline bool vma_purged(struct vm_area_struct *vma)
 {
 	return vma->purged;
@@ -14,6 +21,8 @@ static inline void vma_purge_copy(struct vm_area_struct *dst,
 {
 	dst->purged = src->purged;
 }
+
+int discard_volatile_page(struct page *page, enum ttu_flags ttu_flags);
 #else
 static inline bool vma_purged(struct vm_area_struct *vma)
 {
@@ -25,6 +34,17 @@ static inline void vma_purge_copy(struct vm_area_struct *dst,
 {
 
 }
+
+static inline int discard_volatile_page(struct page *page,
+					enum ttu_flags ttu_flags)
+{
+	return 0;
+}
+
+static inline bool is_volatile_vma(struct vm_area_struct *vma)
+{
+	return false;
+}
 #endif
 #endif
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bfe1f47..5429804 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -223,6 +223,7 @@ int try_to_munlock(struct page *);
 struct anon_vma *page_lock_anon_vma(struct page *page);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
+unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
 
 /*
  * Called by migrate.c to remove migration ptes, but might be used more later.
@@ -244,6 +245,7 @@ static inline int page_referenced(struct page *page, int is_locked,
 	return 0;
 }
 
+
 #define try_to_unmap(page, refs) SWAP_FAIL
 
 static inline int page_mkclean(struct page *page)
diff --git a/mm/memory.c b/mm/memory.c
index c475cc1..0646375 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/mvolatile.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -655,7 +656,7 @@ static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
  *
  * The calling function must still handle the error.
  */
-static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
+void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 			  pte_t pte, struct page *page)
 {
 	pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
@@ -3459,6 +3460,8 @@ int handle_pte_fault(struct mm_struct *mm,
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, flags, entry);
 			}
+			if (unlikely(is_volatile_vma(vma)))
+				return VM_FAULT_SIGBUS;
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
@@ -3528,9 +3531,12 @@ retry:
 	if (!pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
-		if (!vma->vm_ops)
+		if (!vma->vm_ops) {
+			if (unlikely(is_volatile_vma(vma)))
+				return VM_FAULT_SIGBUS;
 			return do_huge_pmd_anonymous_page(mm, vma, address,
 							  pmd, flags);
+		}
 	} else {
 		pmd_t orig_pmd = *pmd;
 		int ret;
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
index 8b812d2..6bc9f7e 100644
--- a/mm/mvolatile.c
+++ b/mm/mvolatile.c
@@ -10,8 +10,12 @@
 #include <linux/mvolatile.h>
 #include <linux/mm_types.h>
 #include <linux/mm.h>
-#include <linux/rmap.h>
+#include <linux/memory.h>
 #include <linux/mempolicy.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/hugetlb.h>
+#include <linux/mmu_notifier.h>
 
 #ifndef CONFIG_VOLATILE_PAGE
 SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
@@ -25,6 +29,185 @@ SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
 }
 #else
 
+/*
+ * Check that @page is mapped at @address into @mm
+ * The difference with __page_check_address is this function checks
+ * pte has swap entry of page.
+ *
+ * On success returns with pte mapped and locked.
+ */
+static pte_t *__page_check_volatile_address(struct page *page,
+	struct mm_struct *mm, unsigned long address, spinlock_t **ptlp)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return NULL;
+
+	VM_BUG_ON(pmd_trans_huge(*pmd));
+
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (pte_none(*pte))
+		goto out;
+
+	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
+		*ptlp = ptl;
+		return pte;
+	} else {
+		swp_entry_t entry = { .val = page_private(page) };
+
+		WARN_ON(pte_present(*pte));
+		VM_BUG_ON(non_swap_entry(entry));
+
+		if (entry.val != pte_to_swp_entry(*pte).val)
+			goto out;
+
+		*ptlp = ptl;
+		return pte;
+	}
+out:
+	pte_unmap_unlock(pte, ptl);
+	return NULL;
+}
+
+static inline pte_t *page_check_volatile_address(struct page *page,
+			struct mm_struct *mm, unsigned long address,
+			spinlock_t **ptlp)
+{
+	pte_t *ptep;
+
+	__cond_lock(*ptlp, ptep = __page_check_volatile_address(page,
+				mm, address, ptlp));
+	return ptep;
+}
+
+int try_to_zap_one(struct page *page, struct vm_area_struct *vma,
+		unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *pte;
+	pte_t pteval;
+	spinlock_t *ptl;
+	int ret = 0;
+	bool present;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	pte = page_check_volatile_address(page, mm, address, &ptl);
+	if (!pte)
+		goto out;
+
+	present = pte_present(*pte);
+	flush_cache_page(vma, address, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	update_hiwater_rss(mm);
+	dec_mm_counter(mm, MM_ANONPAGES);
+
+	page_remove_rmap(page);
+	page_cache_release(page);
+
+	if (!present) {
+		swp_entry_t entry = pte_to_swp_entry(*pte);
+		dec_mm_counter(mm, MM_SWAPENTS);
+		if (unlikely(!free_swap_and_cache(entry, true)))
+			print_bad_pte(vma, address, *pte, NULL);
+	}
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, address);
+	ret = 1;
+out:
+	return ret;
+}
+
+static int try_to_volatile_page(struct page *page, enum ttu_flags flags)
+{
+	struct anon_vma *anon_vma;
+	pgoff_t pgoff;
+	struct anon_vma_chain *avc;
+	unsigned long address;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	int ret = 0;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page)))
+			return 0;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return ret;
+
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		pte_t *pte;
+		spinlock_t *ptl;
+
+		vma = avc->vma;
+		mm = vma->vm_mm;
+		/*
+		 * During exec, a temporary VMA is setup and later moved.
+		 * The VMA is moved under the anon_vma lock but not the
+		 * page tables leading to a race where migration cannot
+		 * find the migration ptes. Rather than increasing the
+		 * locking requirements of exec(), migration skips
+		 * temporary VMAs until after exec() completes.
+		 */
+		if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
+				is_vma_temporary_stack(vma))
+			continue;
+
+		address = vma_address(page, vma);
+		pte = page_check_volatile_address(page, mm, address, &ptl);
+		if (!pte)
+			continue;
+		pte_unmap_unlock(pte, ptl);
+
+		if (!(vma->vm_flags & VM_VOLATILE))
+			goto out;
+	}
+
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		struct vm_area_struct *vma = avc->vma;
+
+		address = vma_address(page, vma);
+		if (try_to_zap_one(page, vma, address))
+			vma->purged = true;
+	}
+
+	ret = 1;
+out:
+	page_unlock_anon_vma(anon_vma);
+	return ret;
+}
+
+int discard_volatile_page(struct page *page, enum ttu_flags ttu_flags)
+{
+	if (try_to_volatile_page(page, ttu_flags)) {
+		if (page_freeze_refs(page, 1)) {
+			unlock_page(page);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 #define NO_PURGED	0
 #define PURGED		1
 
diff --git a/mm/rmap.c b/mm/rmap.c
index fea01cd..e305bbf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -525,8 +525,7 @@ __vma_address(struct page *page, struct vm_area_struct *vma)
 	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 }
 
-inline unsigned long
-vma_address(struct page *page, struct vm_area_struct *vma)
+unsigned long vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	unsigned long address = __vma_address(page, vma);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7ed376..449ec95 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -42,6 +42,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/mvolatile.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -609,6 +610,7 @@ redo:
 enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
+	PAGEREF_DISCARD,
 	PAGEREF_KEEP,
 	PAGEREF_ACTIVATE,
 };
@@ -627,9 +629,16 @@ static enum page_references page_check_references(struct page *page,
 	 * Mlock lost the isolation race with us.  Let try_to_unmap()
 	 * move the page to the unevictable list.
 	 */
+
+	VM_BUG_ON((vm_flags & (VM_LOCKED|VM_VOLATILE)) ==
+				(VM_LOCKED|VM_VOLATILE));
+
 	if (vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
+	if (vm_flags & VM_VOLATILE)
+		return PAGEREF_DISCARD;
+
 	if (referenced_ptes) {
 		if (PageSwapBacked(page))
 			return PAGEREF_ACTIVATE;
@@ -768,6 +777,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto activate_locked;
 		case PAGEREF_KEEP:
 			goto keep_locked;
+		case PAGEREF_DISCARD:
+			if (discard_volatile_page(page, ttu_flags))
+				goto free_it;
+			break;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
