Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 77CB182998
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:11 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so4135719pad.23
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:11 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id xy8si12104947pab.324.2014.05.06.07.38.09
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/8] mm, x86: kill pte_to_pgoff(), pgoff_to_pte() and pte_file*()
Date: Tue,  6 May 2014 17:37:32 +0300
Message-Id: <1399387052-31660-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Kill heplers which no longer need. For x86 only for now.

It also frees _PAGE_FILE flag in pte.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable-2level.h |  39 -----------
 arch/x86/include/asm/pgtable-3level.h |   4 --
 arch/x86/include/asm/pgtable.h        |  20 ------
 arch/x86/include/asm/pgtable_64.h     |   4 --
 arch/x86/include/asm/pgtable_types.h  |   3 +-
 fs/proc/task_mmu.c                    |   5 --
 include/linux/swapops.h               |   4 +-
 mm/madvise.c                          |   2 +-
 mm/memcontrol.c                       |   7 +-
 mm/memory.c                           | 126 ++++++++++++++--------------------
 mm/mincore.c                          |   5 +-
 mm/mprotect.c                         |   2 +-
 mm/mremap.c                           |   2 -
 mm/rmap.c                             |   1 -
 14 files changed, 57 insertions(+), 167 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 0d193e234647..6731f8c09016 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -86,27 +86,6 @@ static inline unsigned long pte_bitop(unsigned long value, unsigned int rightshi
 #define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
 #define PTE_FILE_LSHIFT4	(PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
 
-static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
-{
-	return (pgoff_t)
-		(pte_bitop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		    +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3,  PTE_FILE_LSHIFT3) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT4,           -1UL,  PTE_FILE_LSHIFT4));
-}
-
-static __always_inline pte_t pgoff_to_pte(pgoff_t off)
-{
-	return (pte_t){
-		.pte_low =
-			pte_bitop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
-			pte_bitop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
-			pte_bitop(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3,  PTE_FILE_SHIFT3) +
-			pte_bitop(off, PTE_FILE_LSHIFT4,           -1UL,  PTE_FILE_SHIFT4) +
-			_PAGE_FILE,
-	};
-}
-
 #else /* CONFIG_MEM_SOFT_DIRTY */
 
 /*
@@ -131,24 +110,6 @@ static __always_inline pte_t pgoff_to_pte(pgoff_t off)
 #define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
 #define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
 
-static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
-{
-	return (pgoff_t)
-		(pte_bitop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		    +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT3,           -1UL,  PTE_FILE_LSHIFT3));
-}
-
-static __always_inline pte_t pgoff_to_pte(pgoff_t off)
-{
-	return (pte_t){
-		.pte_low =
-			pte_bitop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
-			pte_bitop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
-			pte_bitop(off, PTE_FILE_LSHIFT3,           -1UL,  PTE_FILE_SHIFT3) +
-			_PAGE_FILE,
-	};
-}
 
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 81bb91b49a88..9315864c8d45 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -183,10 +183,6 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
  * For soft-dirty tracking 11 bit is taken from
  * the low part of pte as well.
  */
-#define pte_to_pgoff(pte) ((pte).pte_high)
-#define pgoff_to_pte(off)						\
-	((pte_t) { { .pte_low = _PAGE_FILE, .pte_high = (off) } })
-#define PTE_FILE_MAX_BITS       32
 
 /* Encode and de-code a swap entry */
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > 5)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index b459ddf27d64..c2c7633e3e3e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -109,11 +109,6 @@ static inline int pte_write(pte_t pte)
 	return pte_flags(pte) & _PAGE_RW;
 }
 
-static inline int pte_file(pte_t pte)
-{
-	return pte_flags(pte) & _PAGE_FILE;
-}
-
 static inline int pte_huge(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_PSE;
@@ -316,21 +311,6 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
-static inline pte_t pte_file_clear_soft_dirty(pte_t pte)
-{
-	return pte_clear_flags(pte, _PAGE_SOFT_DIRTY);
-}
-
-static inline pte_t pte_file_mksoft_dirty(pte_t pte)
-{
-	return pte_set_flags(pte, _PAGE_SOFT_DIRTY);
-}
-
-static inline int pte_file_soft_dirty(pte_t pte)
-{
-	return pte_flags(pte) & _PAGE_SOFT_DIRTY;
-}
-
 /*
  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
  * can use those bits for other purposes, so leave them be.
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index e22c1dbf7feb..7f83a69825e1 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -131,10 +131,6 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 /* PUD - Level3 access */
 
 /* PMD  - Level 2 access */
-#define pte_to_pgoff(pte) ((pte_val((pte)) & PHYSICAL_PAGE_MASK) >> PAGE_SHIFT)
-#define pgoff_to_pte(off) ((pte_t) { .pte = ((off) << PAGE_SHIFT) |	\
-					    _PAGE_FILE })
-#define PTE_FILE_MAX_BITS __PHYSICAL_MASK_SHIFT
 
 /* PTE - Level 1 access. */
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index eb3d44945133..0ffe96ef7c87 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -91,14 +91,13 @@
 #define _PAGE_NX	(_AT(pteval_t, 0))
 #endif
 
-#define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
 /*
  * _PAGE_NUMA indicates that this page will trigger a numa hinting
  * minor page fault to gather numa placement statistics (see
  * pte_numa()). The bit picked (8) is within the range between
- * _PAGE_FILE (6) and _PAGE_PROTNONE (8) bits. Therefore, it doesn't
+ * bit 6 and bit 8 (_PAGE_PROTNONE). Therefore, it doesn't
  * require changes to the swp entry format because that bit is always
  * zero when the pte is not present.
  *
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 1a2d7d3bea28..031bf1defffe 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -457,9 +457,6 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 			mss->swap += ptent_size;
 		else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
-	} else if (pte_file(ptent)) {
-		if (pte_to_pgoff(ptent) != pgoff)
-			mss->nonlinear += ptent_size;
 	}
 
 	if (!page)
@@ -728,8 +725,6 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
-	} else if (pte_file(ptent)) {
-		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
 	if (vma->vm_flags & VM_SOFTDIRTY)
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index c0f75261a728..cefd26aa1aae 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -54,7 +54,7 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
-	return !pte_none(pte) && !pte_present(pte) && !pte_file(pte);
+	return !pte_none(pte) && !pte_present(pte);
 }
 #endif
 
@@ -66,7 +66,6 @@ static inline swp_entry_t pte_to_swp_entry(pte_t pte)
 {
 	swp_entry_t arch_entry;
 
-	BUG_ON(pte_file(pte));
 	if (pte_swp_soft_dirty(pte))
 		pte = pte_swp_clear_soft_dirty(pte);
 	arch_entry = __pte_to_swp_entry(pte);
@@ -82,7 +81,6 @@ static inline pte_t swp_entry_to_pte(swp_entry_t entry)
 	swp_entry_t arch_entry;
 
 	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
-	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index cfb458c78e09..58cc98df29b1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -155,7 +155,7 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
 		pte_unmap_unlock(orig_pte, ptl);
 
-		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
+		if (pte_present(pte) || pte_none(pte))
 			continue;
 		entry = pte_to_swp_entry(pte);
 		if (unlikely(non_swap_entry(entry)))
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 29501f040568..f8979fa16a5e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6680,10 +6680,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 		return NULL;
 
 	mapping = vma->vm_file->f_mapping;
-	if (pte_none(ptent))
-		pgoff = linear_page_index(vma, addr);
-	else /* pte_file(ptent) is true */
-		pgoff = pte_to_pgoff(ptent);
+	pgoff = linear_page_index(vma, addr);
 
 	/* page is moved even if it's not RSS of this task(page-faulted). */
 	page = find_get_page(mapping, pgoff);
@@ -6712,7 +6709,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		page = mc_handle_present_pte(vma, addr, ptent);
 	else if (is_swap_pte(ptent))
 		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
-	else if (pte_none(ptent) || pte_file(ptent))
+	else if (pte_none(ptent))
 		page = mc_handle_file_pte(vma, addr, ptent, &ent);
 
 	if (!page && !ent.val)
diff --git a/mm/memory.c b/mm/memory.c
index a4f4ed739a60..4e1b6f626f23 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -815,42 +815,40 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
-		if (!pte_file(pte)) {
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			if (swap_duplicate(entry) < 0)
-				return entry.val;
-
-			/* make sure dst_mm is on swapoff's mmlist. */
-			if (unlikely(list_empty(&dst_mm->mmlist))) {
-				spin_lock(&mmlist_lock);
-				if (list_empty(&dst_mm->mmlist))
-					list_add(&dst_mm->mmlist,
-						 &src_mm->mmlist);
-				spin_unlock(&mmlist_lock);
-			}
-			if (likely(!non_swap_entry(entry)))
-				rss[MM_SWAPENTS]++;
-			else if (is_migration_entry(entry)) {
-				page = migration_entry_to_page(entry);
-
-				if (PageAnon(page))
-					rss[MM_ANONPAGES]++;
-				else
-					rss[MM_FILEPAGES]++;
-
-				if (is_write_migration_entry(entry) &&
-				    is_cow_mapping(vm_flags)) {
-					/*
-					 * COW mappings require pages in both
-					 * parent and child to be set to read.
-					 */
-					make_migration_entry_read(&entry);
-					pte = swp_entry_to_pte(entry);
-					if (pte_swp_soft_dirty(*src_pte))
-						pte = pte_swp_mksoft_dirty(pte);
-					set_pte_at(src_mm, addr, src_pte, pte);
-				}
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (swap_duplicate(entry) < 0)
+			return entry.val;
+
+		/* make sure dst_mm is on swapoff's mmlist. */
+		if (unlikely(list_empty(&dst_mm->mmlist))) {
+			spin_lock(&mmlist_lock);
+			if (list_empty(&dst_mm->mmlist))
+				list_add(&dst_mm->mmlist,
+						&src_mm->mmlist);
+			spin_unlock(&mmlist_lock);
+		}
+		if (likely(!non_swap_entry(entry)))
+			rss[MM_SWAPENTS]++;
+		else if (is_migration_entry(entry)) {
+			page = migration_entry_to_page(entry);
+
+			if (PageAnon(page))
+				rss[MM_ANONPAGES]++;
+			else
+				rss[MM_FILEPAGES]++;
+
+			if (is_write_migration_entry(entry) &&
+					is_cow_mapping(vm_flags)) {
+				/*
+				 * COW mappings require pages in both
+				 * parent and child to be set to read.
+				 */
+				make_migration_entry_read(&entry);
+				pte = swp_entry_to_pte(entry);
+				if (pte_swp_soft_dirty(*src_pte))
+					pte = pte_swp_mksoft_dirty(pte);
+				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		}
 		goto out_set_pte;
@@ -1085,6 +1083,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	spinlock_t *ptl;
 	pte_t *start_pte;
 	pte_t *pte;
+	swp_entry_t entry;
 
 again:
 	init_rss_vec(rss);
@@ -1140,26 +1139,21 @@ again:
 		/* If details->check_mapping, we leave swap entries */
 		if (unlikely(details))
 			continue;
-		if (pte_file(ptent)) {
-			print_bad_pte(vma, addr, ptent, NULL);
-		} else {
-			swp_entry_t entry = pte_to_swp_entry(ptent);
-
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
 
@@ -1545,7 +1539,7 @@ split_fallthrough:
 		 */
 		if (likely(!(flags & FOLL_MIGRATION)))
 			goto no_page;
-		if (pte_none(pte) || pte_file(pte))
+		if (pte_none(pte))
 			goto no_page;
 		entry = pte_to_swp_entry(pte);
 		if (!is_migration_entry(entry))
@@ -2561,7 +2555,7 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * handle_pte_fault chooses page fault handler according to an entry
  * which was read non-atomically.  Before making any commitment, on
  * those architectures or configurations (e.g. i386 with PAE) which
- * might give a mix of unmatched parts, do_swap_page and do_nonlinear_fault
+ * might give a mix of unmatched parts, do_swap_page
  * must check under lock before unmapping the pte and proceeding
  * (but do_wp_page is only called after already making such a check;
  * and do_anonymous_page can safely check later on).
@@ -3346,8 +3340,6 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
-		pte_mksoft_dirty(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
@@ -3621,20 +3613,6 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
-{
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		return 0;
-
-	/*
-	 * Page table corrupted: show pte and kill process.
-	 */
-	print_bad_pte(vma, address, orig_pte, NULL);
-	return VM_FAULT_SIGBUS;
-}
-
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 				unsigned long addr, int page_nid,
 				int *flags)
@@ -3756,11 +3734,7 @@ static int handle_pte_fault(struct mm_struct *mm,
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
-		if (pte_file(entry))
-			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, flags, entry);
-		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
+		return do_swap_page(mm, vma, address, pte, pmd, flags, entry);
 	}
 
 	if (pte_numa(entry))
diff --git a/mm/mincore.c b/mm/mincore.c
index 725c80961048..1e7aa8aa54f1 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -131,10 +131,7 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			mincore_unmapped_range(vma, addr, next, vec);
 		else if (pte_present(pte))
 			*vec = 1;
-		else if (pte_file(pte)) {
-			pgoff = pte_to_pgoff(pte);
-			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
-		} else { /* pte is a swap entry */
+		else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (is_migration_entry(entry)) {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557941f8..c61918c60b81 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -110,7 +110,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 			if (updated)
 				pages++;
-		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
+		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
 			if (is_write_migration_entry(entry)) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180e9f21..6d49f62a4863 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -81,8 +81,6 @@ static pte_t move_soft_dirty_pte(pte_t pte)
 		pte = pte_mksoft_dirty(pte);
 	else if (is_swap_pte(pte))
 		pte = pte_swp_mksoft_dirty(pte);
-	else if (pte_file(pte))
-		pte = pte_file_mksoft_dirty(pte);
 #endif
 	return pte;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index c9d964d0a7c4..9ea40f12f6e9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1209,7 +1209,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(mm, address, pte, swp_pte);
-		BUG_ON(pte_file(*pte));
 	} else if (IS_ENABLED(CONFIG_MIGRATION) &&
 		   (TTU_ACTION(flags) == TTU_MIGRATION)) {
 		/* Establish migration entry for a file page */
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
