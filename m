Message-ID: <4181EF96.2030602@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:21:58 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 4/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au> <4181EF69.4070201@yahoo.com.au> <4181EF80.3030709@yahoo.com.au>
In-Reply-To: <4181EF80.3030709@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030408060902090908080607"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030408060902090908080607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/7

--------------030408060902090908080607
Content-Type: text/x-patch;
 name="vm-abstract-pgtable-locking.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-abstract-pgtable-locking.patch"



Abstract out page table locking and pte updating. Move over to a
transactional type API for doing pte updates. See asm-generic/pgtable.h
for more details.

* VMAs pin pagetables. You must hold the mmap_sem or anon vma lock
  in order to pin the vmas before doing any page table operations.
  
* mm_lock_page_table(mm); must also be taken when doing page table
  operations.

* In order to modify a pte, one must do the following:
{
  struct pte_modify pmod; /* This can store the old pteval for cmpxchg */
  pte_t pte;
  pte = ptep_begin_modify(&pmod, mm, ptep);

  /* confirm pte is what we want */
  if (wrong_pte(pte)) {
    ptep_abort(&pmod, mm, ptep);
    goto out;
  }
  
  ... /* modify pte (not *ptep) */

  if (ptep_commit(&pmod, mm, ptep, pte)) {
      /* commit failed - usually cleanup & retry or cleanup & fail */
  } else {
      /*
       * *ptep was updated.
       * The old *ptep value is guaranteed not to have changed between
       * ptep_begin_modify and ptep_commit _except_ some implementations
       * may allow hardware bits to have changed, so we need a range of
       * ptep_commit_xxx functions to cope with those situations.
       */
  }
}




---

 linux-2.6-npiggin/arch/i386/kernel/vm86.c       |   19 
 linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c    |   11 
 linux-2.6-npiggin/arch/i386/mm/ioremap.c        |   23 
 linux-2.6-npiggin/fs/exec.c                     |   22 
 linux-2.6-npiggin/include/asm-generic/pgtable.h |  298 +++++++++
 linux-2.6-npiggin/include/asm-generic/tlb.h     |    9 
 linux-2.6-npiggin/include/linux/mm.h            |    1 
 linux-2.6-npiggin/kernel/fork.c                 |   10 
 linux-2.6-npiggin/kernel/futex.c                |    7 
 linux-2.6-npiggin/mm/fremap.c                   |   44 -
 linux-2.6-npiggin/mm/hugetlb.c                  |    4 
 linux-2.6-npiggin/mm/memory.c                   |  780 ++++++++++++++----------
 linux-2.6-npiggin/mm/mmap.c                     |    4 
 linux-2.6-npiggin/mm/mprotect.c                 |   30 
 linux-2.6-npiggin/mm/mremap.c                   |   25 
 linux-2.6-npiggin/mm/msync.c                    |   52 +
 linux-2.6-npiggin/mm/rmap.c                     |  175 +++--
 linux-2.6-npiggin/mm/swap_state.c               |    2 
 linux-2.6-npiggin/mm/swapfile.c                 |   63 -
 linux-2.6-npiggin/mm/vmalloc.c                  |   24 
 20 files changed, 1104 insertions(+), 499 deletions(-)

diff -puN mm/memory.c~vm-abstract-pgtable-locking mm/memory.c
--- linux-2.6/mm/memory.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/memory.c	2004-10-29 16:28:08.000000000 +1000
@@ -145,11 +145,14 @@ static inline void free_one_pgd(struct m
  */
 void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr)
 {
-	pgd_t * page_dir = tlb->mm->pgd;
+	struct mm_struct *mm = tlb->mm;
+	pgd_t * page_dir = mm->pgd;
 
 	page_dir += first;
 	do {
+		mm_lock_page_table(mm);
 		free_one_pgd(tlb, page_dir);
+		mm_unlock_page_table(mm);
 		page_dir++;
 	} while (--nr);
 }
@@ -159,35 +162,50 @@ pte_t fastcall * pte_alloc_map(struct mm
 	if (!pmd_present(*pmd)) {
 		struct page *new;
 
-		spin_unlock(&mm->page_table_lock);
+		mm_unlock_page_table(mm);
 		new = pte_alloc_one(mm, address);
-		spin_lock(&mm->page_table_lock);
+		mm_lock_page_table(mm);
 		if (!new)
 			return NULL;
 		/*
 		 * Because we dropped the lock, we should re-check the
 		 * entry, as somebody else could have populated it..
 		 */
-		if (pmd_present(*pmd)) {
+		if (pmd_test_and_populate(mm, pmd, new)) {
 			pte_free(new);
 			goto out;
 		}
 		mm->nr_ptes++;
 		inc_page_state(nr_page_table_pages);
-		pmd_populate(mm, pmd, new);
 	}
 out:
 	return pte_offset_map(pmd, address);
 }
 
+static inline pte_t * __pte_alloc_map_unlocked(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+{
+	if (!pmd_present(*pmd)) {
+		struct page *new;
+
+		new = pte_alloc_one(mm, address);
+		if (!new)
+			return NULL;
+
+		pmd_populate(mm, pmd, new);
+		mm->nr_ptes++;
+		inc_page_state(nr_page_table_pages);
+	}
+	return pte_offset_map(pmd, address);
+}
+
 pte_t fastcall * pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
 	if (!pmd_present(*pmd)) {
 		pte_t *new;
 
-		spin_unlock(&mm->page_table_lock);
+		mm_unlock_page_table(mm);
 		new = pte_alloc_one_kernel(mm, address);
-		spin_lock(&mm->page_table_lock);
+		mm_lock_page_table(mm);
 		if (!new)
 			return NULL;
 
@@ -195,13 +213,9 @@ pte_t fastcall * pte_alloc_kernel(struct
 		 * Because we dropped the lock, we should re-check the
 		 * entry, as somebody else could have populated it..
 		 */
-		if (pmd_present(*pmd)) {
+		if (pmd_test_and_populate_kernel(mm, pmd, new))
 			pte_free_kernel(new);
-			goto out;
-		}
-		pmd_populate_kernel(mm, pmd, new);
 	}
-out:
 	return pte_offset_kernel(pmd, address);
 }
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
@@ -214,9 +228,6 @@ out:
  *
  * 08Jan98 Merged into one routine from several inline routines to reduce
  *         variable count and make things faster. -jj
- *
- * dst->page_table_lock is held on entry and exit,
- * but may be dropped within pmd_alloc() and pte_alloc_map().
  */
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
@@ -237,9 +248,9 @@ int copy_page_range(struct mm_struct *ds
 		pmd_t * src_pmd, * dst_pmd;
 
 		src_pgd++; dst_pgd++;
-		
+
 		/* copy_pmd_range */
-		
+
 		if (pgd_none(*src_pgd))
 			goto skip_copy_pmd_range;
 		if (unlikely(pgd_bad(*src_pgd))) {
@@ -251,6 +262,7 @@ skip_copy_pmd_range:	address = (address 
 			continue;
 		}
 
+		/* XXX: Don't we worry about the lock for pgd? */
 		src_pmd = pmd_offset(src_pgd, address);
 		dst_pmd = pmd_alloc(dst, dst_pgd, address);
 		if (!dst_pmd)
@@ -258,9 +270,9 @@ skip_copy_pmd_range:	address = (address 
 
 		do {
 			pte_t * src_pte, * dst_pte;
-		
+
 			/* copy_pte_range */
-		
+
 			if (pmd_none(*src_pmd))
 				goto skip_copy_pte_range;
 			if (unlikely(pmd_bad(*src_pmd))) {
@@ -273,24 +285,43 @@ skip_copy_pte_range:
 				goto cont_copy_pmd_range;
 			}
 
-			dst_pte = pte_alloc_map(dst, dst_pmd, address);
+			dst_pte = __pte_alloc_map_unlocked(dst, dst_pmd, address);
 			if (!dst_pte)
 				goto nomem;
-			spin_lock(&src->page_table_lock);	
+			mm_lock_page_table(src);
+			mm_pin_pages(src);
 			src_pte = pte_offset_map_nested(src_pmd, address);
 			do {
-				pte_t pte = *src_pte;
+				struct pte_modify pmod;
+				pte_t new;
 				struct page *page;
 				unsigned long pfn;
 
+again:
 				/* copy_one_pte */
 
-				if (pte_none(pte))
+				/*
+				 * We use this transaction to check that the
+				 * src hasn't changed from under us. Even if
+				 * we don't actually change it.
+				 */
+				new = ptep_begin_modify(&pmod, src, src_pte);
+				if (pte_none(new)) {
+					ptep_abort(&pmod, src, src_pte);
 					goto cont_copy_pte_range_noset;
+				}
 				/* pte contains position in swap, so copy. */
-				if (!pte_present(pte)) {
-					if (!pte_file(pte)) {
-						swap_duplicate(pte_to_swp_entry(pte));
+				if (!pte_present(new)) {
+					if (!pte_file(new))
+						swap_duplicate(pte_to_swp_entry(new));
+					set_pte(dst_pte, new);
+					if (ptep_verify_finish(&pmod, src, src_pte)) {
+						pte_clear(dst_pte);
+						if (!pte_file(new))
+							free_swap_and_cache(pte_to_swp_entry(new));
+						goto again;
+					}
+					if (!pte_file(new)) {
 						if (list_empty(&dst->mmlist)) {
 							spin_lock(&mmlist_lock);
 							list_add(&dst->mmlist,
@@ -298,10 +329,9 @@ skip_copy_pte_range:
 							spin_unlock(&mmlist_lock);
 						}
 					}
-					set_pte(dst_pte, pte);
 					goto cont_copy_pte_range_noset;
 				}
-				pfn = pte_pfn(pte);
+				pfn = pte_pfn(new);
 				/* the pte points outside of valid memory, the
 				 * mapping is assumed to be good, meaningful
 				 * and not mapped via rmap - duplicate the
@@ -312,7 +342,11 @@ skip_copy_pte_range:
 					page = pfn_to_page(pfn); 
 
 				if (!page || PageReserved(page)) {
-					set_pte(dst_pte, pte);
+					set_pte(dst_pte, new);
+					if (ptep_verify_finish(&pmod, src, src_pte)) {
+						pte_clear(dst_pte);
+						goto again;
+					}
 					goto cont_copy_pte_range_noset;
 				}
 
@@ -320,22 +354,26 @@ skip_copy_pte_range:
 				 * If it's a COW mapping, write protect it both
 				 * in the parent and the child
 				 */
-				if (cow) {
-					ptep_set_wrprotect(src_pte);
-					pte = *src_pte;
-				}
+				if (cow)
+					new = pte_wrprotect(new);
 
 				/*
 				 * If it's a shared mapping, mark it clean in
 				 * the child
 				 */
 				if (vma->vm_flags & VM_SHARED)
-					pte = pte_mkclean(pte);
-				pte = pte_mkold(pte);
+					new = pte_mkclean(new);
+				new = pte_mkold(new);
 				get_page(page);
-				dst->rss++;
-				set_pte(dst_pte, pte);
 				page_dup_rmap(page);
+				set_pte(dst_pte, new);
+				if (ptep_commit(&pmod, src, src_pte, new)) {
+					pte_clear(dst_pte);
+					page_remove_rmap(page);
+					put_page(page);
+					goto again;
+				}
+				dst->rss++;
 cont_copy_pte_range_noset:
 				address += PAGE_SIZE;
 				if (address >= end) {
@@ -348,22 +386,23 @@ cont_copy_pte_range_noset:
 			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
 			pte_unmap_nested(src_pte-1);
 			pte_unmap(dst_pte-1);
-			spin_unlock(&src->page_table_lock);
-			cond_resched_lock(&dst->page_table_lock);
+			mm_unpin_pages(src);
+			mm_unlock_page_table(src);
 cont_copy_pmd_range:
 			src_pmd++;
 			dst_pmd++;
 		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
 	}
 out_unlock:
-	spin_unlock(&src->page_table_lock);
+	mm_unpin_pages(src);
+	mm_unlock_page_table(src);
 out:
 	return 0;
 nomem:
 	return -ENOMEM;
 }
 
-static void zap_pte_range(struct mmu_gather *tlb,
+static void zap_pte_range(struct mmu_gather *tlb, struct mm_struct *mm,
 		pmd_t *pmd, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
@@ -384,13 +423,17 @@ static void zap_pte_range(struct mmu_gat
 	size &= PAGE_MASK;
 	if (details && !details->check_mapping && !details->nonlinear_vma)
 		details = NULL;
+	mm_pin_pages(mm);
 	for (offset=0; offset < size; ptep++, offset += PAGE_SIZE) {
-		pte_t pte = *ptep;
-		if (pte_none(pte))
-			continue;
-		if (pte_present(pte)) {
+		struct pte_modify pmod;
+		pte_t old, new;
+again:
+		new = ptep_begin_modify(&pmod, mm, ptep);
+		if (pte_none(new))
+			goto trns_abort;
+		if (pte_present(new)) {
 			struct page *page = NULL;
-			unsigned long pfn = pte_pfn(pte);
+			unsigned long pfn = pte_pfn(new);
 			if (pfn_valid(pfn)) {
 				page = pfn_to_page(pfn);
 				if (PageReserved(page))
@@ -404,7 +447,7 @@ static void zap_pte_range(struct mmu_gat
 				 */
 				if (details->check_mapping &&
 				    details->check_mapping != page->mapping)
-					continue;
+					goto trns_abort;
 				/*
 				 * Each page->index must be checked when
 				 * invalidating or truncating nonlinear.
@@ -412,23 +455,27 @@ static void zap_pte_range(struct mmu_gat
 				if (details->nonlinear_vma &&
 				    (page->index < details->first_index ||
 				     page->index > details->last_index))
-					continue;
+					goto trns_abort;
 			}
-			pte = ptep_get_and_clear(ptep);
+			pte_clear(&new);
+			if (likely(page)) {
+				if (unlikely(details) && details->nonlinear_vma
+				    && linear_page_index(details->nonlinear_vma,
+						address+offset) != page->index)
+					new = pgoff_to_pte(page->index);
+			}
+			if (ptep_commit_clear(&pmod, mm, ptep, new, old))
+				goto again;
 			tlb_remove_tlb_entry(tlb, ptep, address+offset);
-			if (unlikely(!page))
-				continue;
-			if (unlikely(details) && details->nonlinear_vma
-			    && linear_page_index(details->nonlinear_vma,
-					address+offset) != page->index)
-				set_pte(ptep, pgoff_to_pte(page->index));
-			if (pte_dirty(pte))
-				set_page_dirty(page);
-			if (pte_young(pte) && !PageAnon(page))
-				mark_page_accessed(page);
-			tlb->freed++;
-			page_remove_rmap(page);
-			tlb_remove_page(tlb, page);
+			if (likely(page)) {
+				if (pte_dirty(old))
+					set_page_dirty(page);
+				if (pte_young(old) && !PageAnon(page))
+					mark_page_accessed(page);
+				tlb->freed++;
+				page_remove_rmap(page);
+				tlb_remove_page(tlb, page);
+			}
 			continue;
 		}
 		/*
@@ -436,15 +483,22 @@ static void zap_pte_range(struct mmu_gat
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
 		if (unlikely(details))
-			continue;
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear(ptep);
+			goto trns_abort;
+		pte_clear(&new);
+		if (ptep_commit_clear(&pmod, mm, ptep, new, old))
+			goto again;
+		if (!pte_file(old))
+			free_swap_and_cache(pte_to_swp_entry(old));
+
+		continue;
+trns_abort:
+		ptep_abort(&pmod, mm, ptep);
 	}
+	mm_unpin_pages(mm);
 	pte_unmap(ptep-1);
 }
 
-static void zap_pmd_range(struct mmu_gather *tlb,
+static void zap_pmd_range(struct mmu_gather *tlb, struct mm_struct *mm,
 		pgd_t * dir, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
@@ -463,27 +517,29 @@ static void zap_pmd_range(struct mmu_gat
 	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
 		end = ((address + PGDIR_SIZE) & PGDIR_MASK);
 	do {
-		zap_pte_range(tlb, pmd, address, end - address, details);
+		zap_pte_range(tlb, mm, pmd, address, end - address, details);
 		address = (address + PMD_SIZE) & PMD_MASK; 
 		pmd++;
 	} while (address && (address < end));
 }
 
-static void unmap_page_range(struct mmu_gather *tlb,
+static void unmap_page_range(struct mmu_gather *tlb, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
 		unsigned long end, struct zap_details *details)
 {
 	pgd_t * dir;
 
 	BUG_ON(address >= end);
-	dir = pgd_offset(vma->vm_mm, address);
+	mm_lock_page_table(mm);
+	dir = pgd_offset(mm, address);
 	tlb_start_vma(tlb, vma);
 	do {
-		zap_pmd_range(tlb, dir, address, end - address, details);
+		zap_pmd_range(tlb, mm, dir, address, end - address, details);
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
 	tlb_end_vma(tlb, vma);
+	mm_unlock_page_table(mm);
 }
 
 /* Dispose of an entire struct mmu_gather per rescheduling point */
@@ -513,11 +569,7 @@ static void unmap_page_range(struct mmu_
  *
  * Returns the number of vma's which were covered by the unmapping.
  *
- * Unmap all pages in the vma list.  Called under page_table_lock.
- *
- * We aim to not hold page_table_lock for too long (for scheduling latency
- * reasons).  So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
- * return the ending mmu_gather to the caller.
+ * Unmap all pages in the vma list.
  *
  * Only addresses between `start' and `end' will be unmapped.
  *
@@ -533,7 +585,7 @@ static int __unmap_vmas(struct mmu_gathe
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
-	unsigned long zap_bytes = ZAP_BLOCK_SIZE;
+	unsigned long zap_bytes;
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	int ret = 0;
@@ -556,6 +608,7 @@ static int __unmap_vmas(struct mmu_gathe
 		ret++;
 		while (start != end) {
 			unsigned long block;
+			zap_bytes = ZAP_BLOCK_SIZE;
 
 			if (!tlb_start_valid) {
 				tlb_start = start;
@@ -567,7 +620,7 @@ static int __unmap_vmas(struct mmu_gathe
 				unmap_hugepage_range(vma, start, end);
 			} else {
 				block = min(zap_bytes, end - start);
-				unmap_page_range(*tlbp, vma, start,
+				unmap_page_range(*tlbp, mm, vma, start,
 						start + block, details);
 			}
 
@@ -578,7 +631,7 @@ static int __unmap_vmas(struct mmu_gathe
 			if (!atomic && need_resched()) {
 				int fullmm = tlb_is_full_mm(*tlbp);
 				tlb_finish_mmu(*tlbp, tlb_start, start);
-				cond_resched_lock(&mm->page_table_lock);
+				cond_resched();
 				*tlbp = tlb_gather_mmu(mm, fullmm);
 				tlb_start_valid = 0;
 			}
@@ -594,12 +647,10 @@ void unmap_vmas(struct mm_struct *mm, st
 {
 	struct mmu_gather *tlb;
 	lru_add_drain();
-	spin_lock(&mm->page_table_lock);
 	tlb = tlb_gather_mmu(mm, 0);
 	__unmap_vmas(&tlb, mm, vma,
 			start_addr, end_addr, nr_accounted, details);
 	tlb_finish_mmu(tlb, start_addr, end_addr);
-	spin_unlock(&mm->page_table_lock);
 }
 
 int unmap_all_vmas(struct mm_struct *mm, unsigned long *nr_accounted)
@@ -607,13 +658,11 @@ int unmap_all_vmas(struct mm_struct *mm,
 	struct mmu_gather *tlb;
 	int ret;
 	lru_add_drain();
-	spin_lock(&mm->page_table_lock);
 	tlb = tlb_gather_mmu(mm, 1);
 	flush_cache_mm(mm);
 	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
 	ret = __unmap_vmas(&tlb, mm, mm->mmap, 0, ~0UL, nr_accounted, NULL);
 	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
-	spin_unlock(&mm->page_table_lock);
 
 	return ret;
 }
@@ -640,9 +689,14 @@ void zap_page_range(struct vm_area_struc
 	unmap_vmas(mm, vma, address, end, &nr_accounted, details);
 }
 
+void follow_page_finish(struct mm_struct *mm, unsigned long address)
+{
+	mm_unpin_pages(mm);
+	mm_unlock_page_table(mm);
+}
+
 /*
  * Do a quick page-table lookup for a single page.
- * mm->page_table_lock must be held.
  */
 struct page *
 follow_page(struct mm_struct *mm, unsigned long address, int write) 
@@ -653,7 +707,8 @@ follow_page(struct mm_struct *mm, unsign
 	unsigned long pfn;
 	struct page *page;
 
-	page = follow_huge_addr(mm, address, write);
+	mm_lock_page_table(mm);
+	page = follow_huge_addr(mm, address, write); /* XXX: hugepages are broken */
 	if (! IS_ERR(page))
 		return page;
 
@@ -673,11 +728,16 @@ follow_page(struct mm_struct *mm, unsign
 	if (!ptep)
 		goto out;
 
-	pte = *ptep;
+	/* XXX: should be able to drop the mm_pin_pages lock after pinning the
+	 * page with get_page? 
+	 */
+	mm_pin_pages(mm);
+	pte = ptep_atomic_read(ptep);
 	pte_unmap(ptep);
+
 	if (pte_present(pte)) {
 		if (write && !pte_write(pte))
-			goto out;
+			goto out_unpin;
 		pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
@@ -688,7 +748,10 @@ follow_page(struct mm_struct *mm, unsign
 		}
 	}
 
+out_unpin:
+	mm_unpin_pages(mm);
 out:
+	mm_unlock_page_table(mm);
 	return NULL;
 }
 
@@ -698,23 +761,29 @@ untouched_anonymous_page(struct mm_struc
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
+	int ret = 1;
 
 	/* Check if the vma is for an anonymous mapping. */
 	if (vma->vm_ops && vma->vm_ops->nopage)
 		return 0;
 
+	mm_lock_page_table(mm);
+
 	/* Check if page directory entry exists. */
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		return 1;
+		goto out;
 
 	/* Check if page middle directory entry exists. */
 	pmd = pmd_offset(pgd, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		return 1;
+		goto out;
 
 	/* There is a pte slot for 'address' in 'mm'. */
-	return 0;
+	ret = 0;
+out:
+	mm_unlock_page_table(mm);
+	return ret;
 }
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
@@ -753,6 +822,7 @@ int get_user_pages(struct task_struct *t
 			pte = pte_offset_map(pmd, pg);
 			if (!pte)
 				return i ? : -EFAULT;
+			/* XXX: don't need atomic read for *pte? (guess not) */
 			if (!pte_present(*pte)) {
 				pte_unmap(pte);
 				return i ? : -EFAULT;
@@ -779,7 +849,6 @@ int get_user_pages(struct task_struct *t
 						&start, &len, i);
 			continue;
 		}
-		spin_lock(&mm->page_table_lock);
 		do {
 			struct page *page;
 			int lookup_write = write;
@@ -793,10 +862,10 @@ int get_user_pages(struct task_struct *t
 				 */
 				if (!lookup_write &&
 				    untouched_anonymous_page(mm,vma,start)) {
-					page = ZERO_PAGE(start);
-					break;
+					if (pages)
+						pages[i] = ZERO_PAGE(start);
+					goto set_vmas;
 				}
-				spin_unlock(&mm->page_table_lock);
 				switch (handle_mm_fault(mm,vma,start,write)) {
 				case VM_FAULT_MINOR:
 					tsk->min_flt++;
@@ -819,7 +888,6 @@ int get_user_pages(struct task_struct *t
 				 * we are forcing write access.
 				 */
 				lookup_write = write && !force;
-				spin_lock(&mm->page_table_lock);
 			}
 			if (pages) {
 				pages[i] = page;
@@ -827,21 +895,23 @@ int get_user_pages(struct task_struct *t
 				if (!PageReserved(page))
 					page_cache_get(page);
 			}
+			if (page)
+				follow_page_finish(mm, start);
+set_vmas:
 			if (vmas)
 				vmas[i] = vma;
 			i++;
 			start += PAGE_SIZE;
 			len--;
 		} while(len && start < vma->vm_end);
-		spin_unlock(&mm->page_table_lock);
 	} while(len);
 	return i;
 }
 
 EXPORT_SYMBOL(get_user_pages);
 
-static void zeromap_pte_range(pte_t * pte, unsigned long address,
-                                     unsigned long size, pgprot_t prot)
+static void zeromap_pte_range(struct mm_struct *mm, pte_t * pte,
+		unsigned long address, unsigned long size, pgprot_t prot)
 {
 	unsigned long end;
 
@@ -850,9 +920,14 @@ static void zeromap_pte_range(pte_t * pt
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(address), prot));
-		BUG_ON(!pte_none(*pte));
-		set_pte(pte, zero_pte);
+		struct pte_modify pmod;
+		pte_t new;
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+		BUG_ON(!pte_none(new));
+		new = pte_wrprotect(mk_pte(ZERO_PAGE(address), prot));
+		if (ptep_commit(&pmod, mm, pte, new))
+			goto again;
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
@@ -872,7 +947,7 @@ static inline int zeromap_pmd_range(stru
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		zeromap_pte_range(pte, base + address, end - address, prot);
+		zeromap_pte_range(mm, pte, base + address, end - address, prot);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
@@ -893,7 +968,7 @@ int zeromap_page_range(struct vm_area_st
 	if (address >= end)
 		BUG();
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	do {
 		pmd_t *pmd = pmd_alloc(mm, dir, address);
 		error = -ENOMEM;
@@ -909,7 +984,7 @@ int zeromap_page_range(struct vm_area_st
 	 * Why flush? zeromap_pte_range has a BUG_ON for !pte_none()
 	 */
 	flush_tlb_range(vma, beg, end);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return error;
 }
 
@@ -918,8 +993,9 @@ int zeromap_page_range(struct vm_area_st
  * mappings are removed. any references to nonexistent pages results
  * in null mappings (currently treated as "copy-on-access")
  */
-static inline void remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long pfn, pgprot_t prot)
+static inline void remap_pte_range(struct mm_struct *mm, pte_t * pte,
+		unsigned long address, unsigned long size,
+		unsigned long pfn, pgprot_t prot)
 {
 	unsigned long end;
 
@@ -927,14 +1003,26 @@ static inline void remap_pte_range(pte_t
 	end = address + size;
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
+	mm_pin_pages(mm);
 	do {
-		BUG_ON(!pte_none(*pte));
-		if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn)))
- 			set_pte(pte, pfn_pte(pfn, prot));
+		struct pte_modify pmod;
+		pte_t new;
+
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+		BUG_ON(!pte_none(new));
+		if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn))) {
+			new = pfn_pte(pfn, prot);
+			if (ptep_commit(&pmod, mm, pte, new))
+				goto again;
+		} else
+			ptep_abort(&pmod, mm, pte);
+
 		address += PAGE_SIZE;
 		pfn++;
 		pte++;
 	} while (address && (address < end));
+	mm_unpin_pages(mm);
 }
 
 static inline int remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
@@ -952,7 +1040,7 @@ static inline int remap_pmd_range(struct
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		remap_pte_range(pte, base + address, end - address, pfn + (address >> PAGE_SHIFT), prot);
+		remap_pte_range(mm, pte, base + address, end - address, pfn + (address >> PAGE_SHIFT), prot);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
@@ -984,7 +1072,7 @@ int remap_pfn_range(struct vm_area_struc
 	 *	this region.
 	 */
 	vma->vm_flags |= VM_IO | VM_RESERVED;
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	do {
 		pmd_t *pmd = pmd_alloc(mm, dir, from);
 		error = -ENOMEM;
@@ -1000,7 +1088,7 @@ int remap_pfn_range(struct vm_area_struc
 	 * Why flush? remap_pte_range has a BUG_ON for !pte_none()
 	 */
 	flush_tlb_range(vma, beg, end);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return error;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1019,21 +1107,6 @@ static inline pte_t maybe_mkwrite(pte_t 
 }
 
 /*
- * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
- */
-static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address, 
-		pte_t *page_table)
-{
-	pte_t entry;
-
-	flush_cache_page(vma, address);
-	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
-			      vma);
-	ptep_establish(vma, address, page_table, entry);
-	update_mmu_cache(vma, address, entry);
-}
-
-/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -1050,15 +1123,30 @@ static inline void break_cow(struct vm_a
  * change only once the write actually happens. This avoids a few races,
  * and potentially makes it more efficient.
  *
- * We hold the mm semaphore and the page_table_lock on entry and exit
- * with the page_table_lock released.
+ * We hold the mm semaphore and have the page table locked on entry, and exit
+ * with the page table unlocked.
  */
-static int do_wp_page(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, pte_t *page_table, pmd_t *pmd, pte_t pte)
+static int do_wp_page(struct pte_modify *pmod, struct mm_struct *mm,
+	struct vm_area_struct * vma, unsigned long address,
+	pte_t *page_table, pmd_t *pmd, pte_t pte)
 {
+	pte_t new;
 	struct page *old_page, *new_page;
-	unsigned long pfn = pte_pfn(pte);
-	pte_t entry;
+	unsigned long pfn;
+	int ret = VM_FAULT_OOM;
+
+	/* Audit use of mm_pin_pages nesting with ptep_begin_modify, maybe
+	 * deadlockable if we do pte locks.
+	 */
+	mm_pin_pages(mm);
+
+	/* Make sure the pte hasn't changed under us after pinning */
+	if (ptep_verify(pmod, mm, page_table)) {
+		ret = VM_FAULT_MINOR;
+		goto out_error;
+	}
+
+	pfn = pte_pfn(pte);
 
 	if (unlikely(!pfn_valid(pfn))) {
 		/*
@@ -1066,25 +1154,25 @@ static int do_wp_page(struct mm_struct *
 		 * at least the kernel stops what it's doing before it corrupts
 		 * data, but for the moment just pretend this is OOM.
 		 */
-		pte_unmap(page_table);
 		printk(KERN_ERR "do_wp_page: bogus page at address %08lx\n",
 				address);
-		spin_unlock(&mm->page_table_lock);
-		return VM_FAULT_OOM;
+		goto out_error;
 	}
+
 	old_page = pfn_to_page(pfn);
 
 	if (!TestSetPageLocked(old_page)) {
 		int reuse = can_share_swap_page(old_page);
 		unlock_page(old_page);
 		if (reuse) {
+			mm_unpin_pages(mm);
 			flush_cache_page(vma, address);
-			entry = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)),
-					      vma);
-			ptep_set_access_flags(vma, address, page_table, entry, 1);
-			update_mmu_cache(vma, address, entry);
+			new = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)), vma);
+			if (!ptep_commit_access_flush(pmod, mm, vma, address,
+							page_table, new, 1))
+				update_mmu_cache(vma, address, new);
 			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
+			mm_unlock_page_table(mm);
 			return VM_FAULT_MINOR;
 		}
 	}
@@ -1095,41 +1183,70 @@ static int do_wp_page(struct mm_struct *
 	 */
 	if (!PageReserved(old_page))
 		page_cache_get(old_page);
-	spin_unlock(&mm->page_table_lock);
+	ptep_abort(pmod, mm, page_table);
+	mm_unpin_pages(mm);
+	mm_unlock_page_table(mm);
 
-	if (unlikely(anon_vma_prepare(vma)))
+	if (unlikely(anon_vma_prepare(vma))) {
+		ptep_abort(pmod, mm, page_table);
 		goto no_new_page;
+	}
 	new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
-	if (!new_page)
+	if (!new_page) {
+		ptep_abort(pmod, mm, page_table);
 		goto no_new_page;
-	copy_cow_page(old_page,new_page,address);
+	}
+	copy_cow_page(old_page, new_page, address);
 
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	page_table = pte_offset_map(pmd, address);
-	if (likely(pte_same(*page_table, pte))) {
-		if (PageReserved(old_page))
-			++mm->rss;
-		else
-			page_remove_rmap(old_page);
-		break_cow(vma, new_page, address, page_table);
-		lru_cache_add_active(new_page);
-		page_add_anon_rmap(new_page, vma, address);
+	new = ptep_begin_modify(pmod, mm, page_table);
 
-		/* Free the old page.. */
-		new_page = old_page;
+	if (unlikely(!pte_same(new, pte))) {
+		ptep_abort(pmod, mm, page_table);
+		goto out;
+	}
+
+	/* break COW */
+	flush_cache_page(vma, address);
+	new = maybe_mkwrite(pte_mkdirty(
+				mk_pte(new_page, vma->vm_page_prot)), vma);
+	page_add_anon_rmap(new_page, vma, address);
+	if (ptep_commit_establish_flush(pmod, mm, vma, address,
+				page_table, new)) {
+		page_remove_rmap(new_page);
+		goto out;
 	}
+	update_mmu_cache(vma, address, new);
+	if (PageReserved(old_page))
+		++mm->rss;
+	else
+		page_remove_rmap(old_page);
+
+	/* After lru_cache_add_active new_page may disappear, so don't touch! */
+	lru_cache_add_active(new_page);
+
+	/* Free the old page.. */
+	new_page = old_page;
+
+out:
+	ret = VM_FAULT_MINOR;
 	pte_unmap(page_table);
+	mm_unlock_page_table(mm);
 	page_cache_release(new_page);
-	page_cache_release(old_page);
-	spin_unlock(&mm->page_table_lock);
-	return VM_FAULT_MINOR;
-
 no_new_page:
 	page_cache_release(old_page);
-	return VM_FAULT_OOM;
+	return ret;
+
+out_error:
+	ptep_abort(pmod, mm, page_table);
+	pte_unmap(page_table);
+	mm_unpin_pages(mm);
+	mm_unlock_page_table(mm);
+	return ret;
 }
 
 /*
@@ -1201,6 +1318,7 @@ void unmap_mapping_range(struct address_
 	spin_lock(&mapping->i_mmap_lock);
 	/* Protect against page fault */
 	atomic_inc(&mapping->truncate_count);
+	smp_wmb(); /* For truncate_count */
 
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		unmap_mapping_range_list(&mapping->i_mmap, &details);
@@ -1329,37 +1447,39 @@ void swapin_readahead(swp_entry_t entry,
 }
 
 /*
- * We hold the mm semaphore and the page_table_lock on entry and
- * should release the pagetable lock on exit..
+ * We hold the mm semaphore and the page table locked on entry.
+ * We release the pagetable lock on exit.
  */
-static int do_swap_page(struct mm_struct * mm,
-	struct vm_area_struct * vma, unsigned long address,
-	pte_t *page_table, pmd_t *pmd, pte_t orig_pte, int write_access)
+static int do_swap_page(struct pte_modify *pmod, struct mm_struct * mm,
+	struct vm_area_struct * vma, unsigned long address, int write_access,
+	pte_t *page_table, pmd_t *pmd, pte_t orig_pte)
 {
+	int used_swap_page = 0;
+	pte_t new, old;
 	struct page *page;
 	swp_entry_t entry = pte_to_swp_entry(orig_pte);
-	pte_t pte;
 	int ret = VM_FAULT_MINOR;
 
+	ptep_abort(pmod, mm, page_table);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
  		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
 			/*
-			 * Back out if somebody else faulted in this pte while
-			 * we released the page table lock.
+			 * Back out if somebody else faulted in this pte.
 			 */
-			spin_lock(&mm->page_table_lock);
+			mm_lock_page_table(mm);
 			page_table = pte_offset_map(pmd, address);
-			if (likely(pte_same(*page_table, orig_pte)))
+			if (likely(pte_same(ptep_atomic_read(page_table),
+							orig_pte)))
 				ret = VM_FAULT_OOM;
 			else
 				ret = VM_FAULT_MINOR;
 			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
+			mm_unlock_page_table(mm);
 			goto out;
 		}
 
@@ -1376,71 +1496,83 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else faulted in this pte while we
 	 * released the page table lock.
 	 */
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	page_table = pte_offset_map(pmd, address);
-	if (unlikely(!pte_same(*page_table, orig_pte))) {
-		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
+	new = ptep_begin_modify(pmod, mm, page_table);
+	if (unlikely(!pte_same(new, orig_pte))) {
+		ptep_abort(pmod, mm, page_table);
 		unlock_page(page);
-		page_cache_release(page);
-		ret = VM_FAULT_MINOR;
-		goto out;
+		goto out_failed;
 	}
 
 	/* The page isn't present yet, go ahead with the fault. */
-		
+
 	swap_free(entry);
-	if (vm_swap_full())
-		remove_exclusive_swap_page(page);
 
-	mm->rss++;
-	pte = mk_pte(page, vma->vm_page_prot);
+	new = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		new = maybe_mkwrite(pte_mkdirty(new), vma);
 		write_access = 0;
+		used_swap_page = 1;
 	}
-	unlock_page(page);
 
 	flush_icache_page(vma, page);
-	set_pte(page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	if (ptep_commit(pmod, mm, page_table, new)) {
+		page_remove_rmap(page);
+		swap_duplicate(entry);
+		unlock_page(page);
+		goto out_failed;
+	}
+	if (!used_swap_page && vm_swap_full())
+		remove_exclusive_swap_page(page);
+	unlock_page(page);
+	mm->rss++;
 
 	if (write_access) {
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, pte) == VM_FAULT_OOM)
-			ret = VM_FAULT_OOM;
-		goto out;
+		old = new;
+		new = ptep_begin_modify(pmod, mm, page_table);
+		if (likely(pte_same(old, new))) {
+			if (do_wp_page(pmod, mm, vma, address,
+					page_table, pmd, new) == VM_FAULT_OOM)
+				ret = VM_FAULT_OOM;
+			goto out;
+		}
+		ptep_abort(pmod, mm, page_table);
 	}
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, pte);
+	update_mmu_cache(vma, address, new);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 out:
 	return ret;
+
+out_failed:
+	pte_unmap(page_table);
+	mm_unlock_page_table(mm);
+	page_cache_release(page);
+	return ret;
 }
 
 /*
- * We are called with the MM semaphore and page_table_lock
- * spinlock held to protect against concurrent faults in
- * multithreaded programs. 
+ * We are called with the MM semaphore and page table locked
+ * to protect against concurrent faults in multithreaded programs.
  */
 static int
-do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		pte_t *page_table, pmd_t *pmd, int write_access,
-		unsigned long addr)
+do_anonymous_page(struct pte_modify *pmod, struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long addr,
+		int write_access, pte_t *page_table, pmd_t *pmd)
 {
-	pte_t entry;
-	struct page * page = ZERO_PAGE(addr);
-
-	/* Read-only mapping of ZERO_PAGE. */
-	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
+	pte_t new;
+	struct page *page;
 
-	/* ..except if it's a write access */
+	/* XXX: is this really unlikely? The code previously suggested so */
 	if (write_access) {
 		/* Allocate our own private page. */
+		ptep_abort(ptep, mm, page_table);
 		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
+		mm_unlock_page_table(mm);
 
 		if (unlikely(anon_vma_prepare(vma)))
 			goto no_mem;
@@ -1449,31 +1581,40 @@ do_anonymous_page(struct mm_struct *mm, 
 			goto no_mem;
 		clear_user_highpage(page, addr);
 
-		spin_lock(&mm->page_table_lock);
+		mm_lock_page_table(mm);
 		page_table = pte_offset_map(pmd, addr);
+		new = ptep_begin_modify(pmod, mm, page_table);
 
-		if (!pte_none(*page_table)) {
-			pte_unmap(page_table);
+		if (unlikely(!pte_none(new))) {
+			ptep_abort(ptep, mm, page_table);
+			page_cache_release(page);
+			goto out;
+		}
+		new = maybe_mkwrite(pte_mkdirty(mk_pte(page,
+						vma->vm_page_prot)), vma);
+		page_add_anon_rmap(page, vma, addr);
+		if (ptep_commit(pmod, mm, page_table, new)) {
+			page_remove_rmap(page);
 			page_cache_release(page);
-			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
+
 		mm->rss++;
-		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
-							 vma->vm_page_prot)),
-				      vma);
-		lru_cache_add_active(page);
 		mark_page_accessed(page);
-		page_add_anon_rmap(page, vma, addr);
+		lru_cache_add_active(page);
+	} else {
+		/* Read-only mapping of ZERO_PAGE. */
+		page = ZERO_PAGE(addr);
+		new = pte_wrprotect(mk_pte(page, vma->vm_page_prot));
+		if (ptep_commit(pmod, mm, page_table, new))
+			goto out;
 	}
 
-	set_pte(page_table, entry);
-	pte_unmap(page_table);
-
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, addr, entry);
-	spin_unlock(&mm->page_table_lock);
+	update_mmu_cache(vma, addr, new);
 out:
+	pte_unmap(page_table);
+	mm_unlock_page_table(mm);
 	return VM_FAULT_MINOR;
 no_mem:
 	return VM_FAULT_OOM;
@@ -1492,27 +1633,29 @@ no_mem:
  * spinlock held. Exit with the spinlock released.
  */
 static int
-do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
+do_no_page(struct pte_modify *pmod, struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long address,
+		int write_access, pte_t *page_table, pmd_t *pmd, pte_t pte)
 {
+	pte_t new;
 	struct page * new_page;
 	struct address_space *mapping = NULL;
-	pte_t entry;
 	int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
 
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
-		return do_anonymous_page(mm, vma, page_table,
-					pmd, write_access, address);
+		return do_anonymous_page(pmod, mm, vma, address,
+				write_access, page_table, pmd);
+
+	ptep_abort(ptep, mm, page_table);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
 		sequence = atomic_read(&mapping->truncate_count);
 	}
-	smp_rmb();  /* Prevent CPU from reordering lock-free ->nopage() */
 retry:
 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
 
@@ -1539,20 +1682,32 @@ retry:
 		anon = 1;
 	}
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
+	/* XXX: investigate this further WRT lockless page table issues. */
 	/*
 	 * For a file-backed vma, someone could have truncated or otherwise
 	 * invalidated this page.  If unmap_mapping_range got called,
 	 * retry getting the page.
 	 */
-	if (mapping &&
-	      (unlikely(sequence != atomic_read(&mapping->truncate_count)))) {
-		sequence = atomic_read(&mapping->truncate_count);
-		spin_unlock(&mm->page_table_lock);
-		page_cache_release(new_page);
-		goto retry;
+	if (mapping) {
+		smp_rmb(); /* For truncate_count */
+		if (unlikely(sequence !=
+				atomic_read(&mapping->truncate_count))) {
+			sequence = atomic_read(&mapping->truncate_count);
+			mm_unlock_page_table(mm);
+			page_cache_release(new_page);
+			goto retry;
+		}
 	}
 	page_table = pte_offset_map(pmd, address);
+	new = ptep_begin_modify(pmod, mm, page_table);
+
+	/* Only go through if we didn't race with anybody else... */
+	if (unlikely(!pte_none(new))) {
+		/* One of our sibling threads was faster, back out. */
+		ptep_abort(ptep, mm, page_table);
+		goto out_failed;
+	}
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -1564,34 +1719,39 @@ retry:
 	 * so we can make it writable and dirty to avoid having to
 	 * handle that later.
 	 */
-	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
-		if (!PageReserved(new_page))
-			++mm->rss;
-		flush_icache_page(vma, new_page);
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		if (write_access)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		set_pte(page_table, entry);
-		if (anon) {
-			lru_cache_add_active(new_page);
-			page_add_anon_rmap(new_page, vma, address);
-		} else
-			page_add_file_rmap(new_page);
-		pte_unmap(page_table);
-	} else {
-		/* One of our sibling threads was faster, back out. */
-		pte_unmap(page_table);
-		page_cache_release(new_page);
-		spin_unlock(&mm->page_table_lock);
-		goto out;
-	}
+
+	flush_icache_page(vma, new_page);
+	new = mk_pte(new_page, vma->vm_page_prot);
+	if (write_access)
+		new = maybe_mkwrite(pte_mkdirty(new), vma);
+
+	if (anon) {
+		page_add_anon_rmap(new_page, vma, address);
+	} else
+		page_add_file_rmap(new_page);
+
+	if (ptep_commit(pmod, mm, page_table, new)) {
+		page_remove_rmap(new_page);
+		goto out_failed;
+	}
+	if (!PageReserved(new_page))
+		++mm->rss;
+	if (anon)
+		lru_cache_add_active(new_page);
+
+	pte_unmap(page_table);
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
-	update_mmu_cache(vma, address, entry);
-	spin_unlock(&mm->page_table_lock);
+	update_mmu_cache(vma, address, new);
 out:
+	mm_unlock_page_table(mm);
 	return ret;
+
+out_failed:
+	pte_unmap(page_table);
+	mm_unlock_page_table(mm);
+	page_cache_release(new_page);
+	return VM_FAULT_MINOR;
 oom:
 	page_cache_release(new_page);
 	ret = VM_FAULT_OOM;
@@ -1603,8 +1763,9 @@ oom:
  * from the encoded file_pte if possible. This enables swappable
  * nonlinear vmas.
  */
-static int do_file_page(struct mm_struct * mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd)
+static int do_file_page(struct pte_modify *pmod, struct mm_struct * mm,
+		struct vm_area_struct * vma, unsigned long address,
+		int write_access, pte_t *ptep, pmd_t *pmd, pte_t pte)
 {
 	unsigned long pgoff;
 	int err;
@@ -1616,14 +1777,27 @@ static int do_file_page(struct mm_struct
 	 */
 	if (!vma->vm_ops || !vma->vm_ops->populate || 
 			(write_access && !(vma->vm_flags & VM_SHARED))) {
-		pte_clear(pte);
-		return do_no_page(mm, vma, address, write_access, pte, pmd);
+		pte_clear(&pte);
+		if (ptep_commit(pmod, mm, ptep, pte)) {
+			pte_unmap(ptep);
+			mm_unlock_page_table(mm);
+			return VM_FAULT_MINOR;
+		}
+		pte = ptep_begin_modify(pmod, mm, ptep);
+		return do_no_page(pmod, mm, vma, address,
+				write_access, ptep, pmd, pte);
 	}
 
-	pgoff = pte_to_pgoff(*pte);
+	pgoff = pte_to_pgoff(ptep_atomic_read(ptep));
+	/* XXX: is this right? */
+	if (ptep_verify_finish(pmod, mm, ptep)) {
+		pte_unmap(ptep);
+		mm_unlock_page_table(mm);
+		return VM_FAULT_MINOR;
+	}
 
-	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap(ptep);
+	mm_unlock_page_table(mm);
 
 	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE, vma->vm_page_prot, pgoff, 0);
 	if (err == -ENOMEM)
@@ -1642,25 +1816,16 @@ static int do_file_page(struct mm_struct
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * Note the "page_table_lock". It is to protect against kswapd removing
- * pages from under us. Note that kswapd only ever _removes_ pages, never
- * adds them. As such, once we have noticed that the page is not present,
- * we can drop the lock early.
- *
- * The adding of pages is protected by the MM semaphore (which we hold),
- * so we don't need to worry about a page being suddenly been added into
- * our VM.
- *
- * We enter with the pagetable spinlock held, we are supposed to
- * release it when done.
+ * We enter with the page table locked, and exit with it unlocked.
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
 	int write_access, pte_t *pte, pmd_t *pmd)
 {
+	struct pte_modify pmod;
 	pte_t entry;
 
-	entry = *pte;
+	entry = ptep_begin_modify(&pmod, mm, pte);
 	if (!pte_present(entry)) {
 		/*
 		 * If it truly wasn't present, we know that kswapd
@@ -1668,28 +1833,37 @@ static inline int handle_pte_fault(struc
 		 * drop the lock.
 		 */
 		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write_access, pte, pmd);
+			return do_no_page(&pmod, mm, vma, address,
+					write_access, pte, pmd, entry);
 		if (pte_file(entry))
-			return do_file_page(mm, vma, address, write_access, pte, pmd);
-		return do_swap_page(mm, vma, address, pte, pmd, entry, write_access);
+			return do_file_page(&pmod, mm, vma, address,
+					write_access, pte, pmd, entry);
+
+		return do_swap_page(&pmod, mm, vma, address,
+				write_access, pte, pmd, entry);
 	}
 
 	if (write_access) {
 		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address, pte, pmd, entry);
+			return do_wp_page(&pmod, mm, vma, address,
+							pte, pmd, entry);
 
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	ptep_set_access_flags(vma, address, pte, entry, write_access);
-	update_mmu_cache(vma, address, entry);
+	if (!ptep_commit_access_flush(&pmod, mm, vma, address,
+					pte, entry, write_access)) {
+		/* Success */
+		update_mmu_cache(vma, address, entry);
+	}
+
 	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return VM_FAULT_MINOR;
 }
 
 /*
- * By the time we get here, we already hold the mm semaphore
+ * This must be called with mmap_sem held for reading.
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
 	unsigned long address, int write_access)
@@ -1698,26 +1872,22 @@ int handle_mm_fault(struct mm_struct *mm
 	pmd_t *pmd;
 
 	__set_current_state(TASK_RUNNING);
-	pgd = pgd_offset(mm, address);
-
 	inc_page_state(pgfault);
 
 	if (is_vm_hugetlb_page(vma))
 		return VM_FAULT_SIGBUS;	/* mapping truncation does this. */
 
-	/*
-	 * We need the page table lock to synchronize with kswapd
-	 * and the SMP-safe atomic PTE updates.
-	 */
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
+	pgd = pgd_offset(mm, address);
 	pmd = pmd_alloc(mm, pgd, address);
-
 	if (pmd) {
 		pte_t * pte = pte_alloc_map(mm, pmd, address);
 		if (pte)
-			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+			return handle_pte_fault(mm, vma, address,
+						write_access, pte, pmd);
 	}
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
+
 	return VM_FAULT_OOM;
 }
 
@@ -1734,22 +1904,15 @@ pmd_t fastcall *__pmd_alloc(struct mm_st
 {
 	pmd_t *new;
 
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	new = pmd_alloc_one(mm, address);
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	if (!new)
 		return NULL;
 
-	/*
-	 * Because we dropped the lock, we should re-check the
-	 * entry, as somebody else could have populated it..
-	 */
-	if (pgd_present(*pgd)) {
+	if (pgd_test_and_populate(mm, pgd, new))
 		pmd_free(new);
-		goto out;
-	}
-	pgd_populate(mm, pgd, new);
-out:
+
 	return pmd_offset(pgd, address);
 }
 
@@ -1784,7 +1947,8 @@ struct page * vmalloc_to_page(void * vma
 	pgd_t *pgd = pgd_offset_k(addr);
 	pmd_t *pmd;
 	pte_t *ptep, pte;
-  
+
+	/* XXX: investigate */
 	if (!pgd_none(*pgd)) {
 		pmd = pmd_offset(pgd, addr);
 		if (!pmd_none(*pmd)) {
diff -puN include/asm-generic/pgtable.h~vm-abstract-pgtable-locking include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable.h	2004-10-29 16:40:39.000000000 +1000
@@ -134,4 +134,302 @@ static inline void ptep_mkdirty(pte_t *p
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
 
+#ifndef __ASSEMBLY__
+#ifdef __HAVE_ARCH_PTEP_CMPXCHG
+#define mm_lock_page_table(__mm)					\
+do {									\
+} while (0);
+
+#define mm_unlock_page_table(__mm)					\
+do {									\
+} while (0);
+
+#define mm_pin_pages(__mm)						\
+do {									\
+	spin_lock(&__mm->page_table_lock);				\
+} while (0)
+
+#define mm_unpin_pages(__mm)						\
+do {									\
+	spin_unlock(&__mm->page_table_lock);				\
+} while (0)
+
+/* mm_lock_page_table doesn't actually take a lock, so this can be 0 */
+#define MM_RELOCK_CHECK 0
+
+struct pte_modify {
+	pte_t oldval;
+};
+
+#ifndef __HAVE_ARCH_PTEP_ATOMIC_READ
+#define ptep_atomic_read(__ptep)					\
+({									\
+	*__ptep;							\
+})
+#endif
+
+#define ptep_begin_modify(__pmod, __mm, __ptep)				\
+({									\
+ 	(void)__mm;							\
+ 	(__pmod)->oldval = ptep_atomic_read(__ptep);			\
+ 	(__pmod)->oldval;						\
+})
+
+#define ptep_abort(__pmod, __mm, __ptep)				\
+do {} while (0)
+
+#define ptep_commit(__pmod, __mm, __ptep, __newval)			\
+({									\
+	unlikely(ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval));	\
+})
+
+#define ptep_commit_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+ 	int ret = ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval);	\
+ 	/* XXX:								\		 * worthwhile to see if cmpxchg has succeeded before flushing?	\
+ 	 * worthwhile to see if pte_val has changed before flushing?	\
+	 * like so?:							\
+	 *  if (!ret && pte_val((__pmod)->oldval) != pte_val(__newval)) \
+	 */								\
+	flush_tlb_page(__vma, __address);				\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_access_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __dirty) \
+({									\
+ 	int ret = ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval);	\
+	flush_tlb_page(__vma, __address);				\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_establish_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+	int ret = ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval);	\
+	flush_tlb_page(__vma, __address);				\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_clear(__pmod, __mm, __ptep, __newval, __oldval) 	\
+({									\
+	int ret = ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval);	\
+	__oldval = (__pmod)->oldval;					\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_clear_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __oldval) \
+({									\
+	int ret = ptep_cmpxchg(__ptep, (__pmod)->oldval, __newval);	\
+	flush_tlb_page(__vma, __address);				\
+	__oldval = (__pmod)->oldval;					\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_clear_flush_young(__pmod, __mm, __vma, __address, __ptep, __young) \
+({									\
+ 	pte_t oldval = (__pmod)->oldval;				\
+	int ret = ptep_cmpxchg(__ptep, oldval, pte_mkold(oldval)); 	\
+	*__young = pte_young(oldval);					\
+	if (likely(!ret) && *__young)					\
+ 		flush_tlb_page(__vma, __address);			\
+	unlikely(ret);							\
+})
+
+#define ptep_commit_clear_flush_dirty(__pmod, __mm, __vma, __address, __ptep, __dirty) \
+({									\
+ 	pte_t oldval = (__pmod)->oldval;				\
+	int ret = ptep_cmpxchg(__ptep, oldval, pte_mkclean(oldval)); 	\
+	*__dirty = pte_dirty(oldval);					\
+	if (likely(!ret) && *__dirty)					\
+ 		flush_tlb_page(__vma, __address);			\
+	unlikely(ret);							\
+})
+
+#define ptep_verify(__pmod, __mm, __ptep)				\
+({									\
+ 	/* Prevent writes leaking forward and reads leaking back */	\
+ 	smp_mb();							\
+	unlikely(pte_val((__pmod)->oldval) != pte_val(ptep_atomic_read(__ptep))); \
+})
+
+#define ptep_verify_finish(__pmod, __mm, __ptep)			\
+	ptep_verify(__pmod, __mm, __ptep)
+
+#else /* __HAVE_ARCH_PTEP_CMPXCHG */ /* GENERIC_PTEP_LOCKING follows */
+/* Use the generic mm->page_table_lock serialised scheme */
+/*
+ * XXX: can we make use of this?
+ * At the moment, yes because some code is holding a ptep_begin_modify
+ * transaction across dropping and retaking the mm_lock_page_table (see
+ * mm/memory.c do_??? pagefault routines). A pte cmpxchg system can take
+ * advantage of this (holding the transaction open), but it possibly isn't
+ * exactly clean, and will blow up if ptep_begin_modify takes a lock itself.
+ *
+ * And ptep_begin_modify would probably like to take a lock if an architecture
+ * wants to do per-pte locking (ppc64, maybe).
+ */
+#define MM_RELOCK_CHECK 1
+
+/*
+ * Lock and unlock the pagetable for walking. This guarantees we can safely
+ * walk pgd->pmd->pte, and only that.
+ */
+#define mm_lock_page_table(__mm)					\
+do {									\
+	spin_lock(&(__mm)->page_table_lock);				\
+} while (0)
+
+#define mm_unlock_page_table(__mm)					\
+do {									\
+	spin_unlock(&(__mm)->page_table_lock);				\
+} while (0)
+
+/*
+ * XXX: pin and unpin may be tricky without a page_table_lock.
+ * Use vma locks maybe? Pte page locks? Pte bit?
+ */
+/*
+ * Prevent pages mapped into __mm, __vma from being freed.
+ * Taken inside mm_lock_page_table
+ */
+#define mm_pin_pages(__mm)						\
+do {									\
+	(void)__mm;							\
+} while (0)
+
+#define mm_unpin_pages(__mm)						\
+do {									\
+	(void)__mm;							\
+} while (0)
+
+#define ptep_atomic_read(__ptep)					\
+({									\
+	*__ptep;							\
+})
+
+/* XXX: will we want pmd/pgd_atomic_read? Yes. (big job) */
+
+/*
+ * A pte modification sequence goes something like this:
+ * struct pte_modify pmod;
+ * pte_t pte;
+ *
+ * mm_lock_page_table(mm);
+ * // walk page table to find ptep
+ * pte = ptep_begin_modify(&pmod, mm, ptep)
+ * if (!pte is valid) {
+ *	ptep_abort(&pmod, mm, ptep); // XXX: isn't yet part of the API.
+ *	goto out;
+ * }
+ * // modify pte, or make one that we want to install
+ *
+ * if (ptep_commit(&pmod, mm, ptep, pte)) {
+ * 	// commit failed
+ * 	goto out;
+ * }
+ *
+ * // At this point, the pte replaced by the commit is guaranteed to be the
+ * // same as the one returned by ptep_begin_modify, although hardware bits
+ * // may have changed. The other ptep_commit_* functions can provide
+ * // protection against hardware bits changing.
+ */
+struct pte_modify {
+};
+
+#define ptep_begin_modify(__pmod, __mm, __ptep)				\
+({									\
+ 	(void)__pmod;							\
+ 	(void)__mm;							\
+ 	ptep_atomic_read(__ptep);					\
+})
+
+#define ptep_abort(__pmod, __mm, __ptep)				\
+do {} while (0)
+
+#define ptep_commit(__pmod, __mm, __ptep, __newval)			\
+({									\
+	set_pte_atomic(__ptep, __newval);				\
+	0;								\
+})
+
+#define ptep_commit_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+	set_pte_atomic(__ptep, __newval);				\
+	flush_tlb_page(__vma, __address);				\
+	0;								\
+})
+
+#define ptep_commit_access_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __dirty) \
+({									\
+ 	ptep_set_access_flags(__vma, __address, __ptep, __newval, __dirty); \
+	0;								\
+})
+
+#define ptep_commit_establish_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+ 	ptep_establish(__vma, __address, __ptep, __newval);		\
+	0;								\
+})
+
+#define ptep_commit_clear(__pmod, __mm, __ptep, __newval, __oldval) \
+({									\
+ 	__oldval = ptep_get_and_clear(__ptep);				\
+ 	set_pte(__ptep, __newval);					\
+	0;								\
+})
+
+#define ptep_commit_clear_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __oldval) \
+({									\
+ 	__oldval = ptep_clear_flush(__vma, __address, __ptep);		\
+ 	set_pte(__ptep, __newval);					\
+	0;								\
+})
+
+#define ptep_commit_clear_flush_young(__pmod, __mm, __vma, __address, __ptep, __young) \
+({									\
+ 	*__young = ptep_clear_flush_young(__vma, __address, __ptep);	\
+ 	0;								\
+})
+
+#define ptep_commit_clear_flush_dirty(__pmod, __mm, __vma, __address, __ptep, __dirty) \
+({									\
+ 	*__dirty = ptep_clear_flush_dirty(__vma, __address, __ptep);	\
+	0;								\
+})
+
+#define ptep_verify(__pmod, __mm, __ptep)				\
+({									\
+ 	(void)__pmod;							\
+	0;								\
+})
+
+#define ptep_verify_finish(__pmod, __mm, __ptep)			\
+	ptep_verify(__pmod, __mm, __ptep)
+
+#define pgd_test_and_populate(__mm, ___pgd, ___pmd)			\
+({									\
+	int ret = pgd_present(*(___pgd));				\
+ 	if (likely(!ret))						\
+ 		pgd_populate(__mm, ___pgd, ___pmd);			\
+ 	unlikely(ret);							\
+})
+
+#define pmd_test_and_populate(__mm, ___pmd, ___page)			\
+({									\
+	int ret = pmd_present(*(___pmd));				\
+ 	if (likely(!ret))						\
+ 		pmd_populate(__mm, ___pmd, ___page);			\
+ 	unlikely(ret);							\
+})
+
+#define pmd_test_and_populate_kernel(__mm, ___pmd, ___page)		\
+({									\
+	int ret = pmd_present(*(___pmd));				\
+ 	if (likely(!ret))						\
+ 		pmd_populate_kernel(__mm, ___pmd, ___page);		\
+ 	unlikely(ret);							\
+})
+
+#endif /* GENERIC_PTEP_LOCKING */
+#endif /* ASSEMBLY */
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff -puN kernel/fork.c~vm-abstract-pgtable-locking kernel/fork.c
--- linux-2.6/kernel/fork.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/kernel/fork.c	2004-10-29 16:28:08.000000000 +1000
@@ -227,7 +227,6 @@ static inline int dup_mmap(struct mm_str
 		 * link in first so that swapoff can see swap entries,
 		 * and try_to_unmap_one's find_vma find the new vma.
 		 */
-		spin_lock(&mm->page_table_lock);
 		*pprev = tmp;
 		pprev = &tmp->vm_next;
 
@@ -237,7 +236,6 @@ static inline int dup_mmap(struct mm_str
 
 		mm->map_count++;
 		retval = copy_page_range(mm, current->mm, tmp);
-		spin_unlock(&mm->page_table_lock);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
@@ -446,7 +444,15 @@ static int copy_mm(unsigned long clone_f
 		 * allows optimizing out ipis; the tlb_gather_mmu code
 		 * is an example.
 		 */
+		/*
+		 * XXX: I think this is only needed for sparc64's tlb and
+		 * context switching code - but sparc64 is in big trouble
+		 * now anyway because tlb_gather_mmu can be done without
+		 * holding the page table lock now anyway.
+		 */
+#if 0
 		spin_unlock_wait(&oldmm->page_table_lock);
+#endif
 		goto good_mm;
 	}
 
diff -puN kernel/futex.c~vm-abstract-pgtable-locking kernel/futex.c
--- linux-2.6/kernel/futex.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/kernel/futex.c	2004-10-29 16:28:08.000000000 +1000
@@ -204,15 +204,13 @@ static int get_futex_key(unsigned long u
 	/*
 	 * Do a quick atomic lookup first - this is the fastpath.
 	 */
-	spin_lock(&current->mm->page_table_lock);
 	page = follow_page(mm, uaddr, 0);
 	if (likely(page != NULL)) {
 		key->shared.pgoff =
 			page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-		spin_unlock(&current->mm->page_table_lock);
+		follow_page_finish(mm, uaddr);
 		return 0;
 	}
-	spin_unlock(&current->mm->page_table_lock);
 
 	/*
 	 * Do it the general way.
@@ -505,7 +503,7 @@ static int futex_wait(unsigned long uadd
 	/*
 	 * Now the futex is queued and we have checked the data, we
 	 * don't want to hold mmap_sem while we sleep.
-	 */	
+	 */
 	up_read(&current->mm->mmap_sem);
 
 	/*
@@ -520,6 +518,7 @@ static int futex_wait(unsigned long uadd
 	/* add_wait_queue is the barrier after __set_current_state. */
 	__set_current_state(TASK_INTERRUPTIBLE);
 	add_wait_queue(&q.waiters, &wait);
+
 	/*
 	 * !list_empty() is safe here without any lock.
 	 * q.lock_ptr != 0 is not safe, because of ordering against wakeup.
diff -puN include/linux/mm.h~vm-abstract-pgtable-locking include/linux/mm.h
--- linux-2.6/include/linux/mm.h~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mm.h	2004-10-29 16:28:08.000000000 +1000
@@ -758,6 +758,7 @@ extern struct vm_area_struct *find_exten
 extern struct page * vmalloc_to_page(void *addr);
 extern struct page * follow_page(struct mm_struct *mm, unsigned long address,
 		int write);
+extern void follow_page_finish(struct mm_struct *mm, unsigned long address);
 int remap_pfn_range(struct vm_area_struct *, unsigned long,
 		unsigned long, unsigned long, pgprot_t);
 
diff -puN include/asm-generic/tlb.h~vm-abstract-pgtable-locking include/asm-generic/tlb.h
--- linux-2.6/include/asm-generic/tlb.h~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/tlb.h	2004-10-29 16:28:08.000000000 +1000
@@ -53,7 +53,13 @@ DECLARE_PER_CPU(struct mmu_gather, mmu_g
 static inline struct mmu_gather *
 tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *tlb = &per_cpu(mmu_gathers, smp_processor_id());
+	/*
+	 * XXX: Now calling this without the page_table_lock!
+	 * This will blow up at least sparc64 (see sparc64's switch_mm
+	 * and kernel/fork.c:copy_mm for more details.
+	 */
+	int cpu = get_cpu();
+	struct mmu_gather *tlb = &per_cpu(mmu_gathers, cpu);
 
 	tlb->mm = mm;
 
@@ -97,6 +103,7 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
+	put_cpu();
 }
 
 static inline unsigned int
diff -puN mm/mmap.c~vm-abstract-pgtable-locking mm/mmap.c
--- linux-2.6/mm/mmap.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/mmap.c	2004-10-29 16:28:08.000000000 +1000
@@ -1575,14 +1575,12 @@ static void free_dangling_pgtables_regio
 {
 	struct mmu_gather *tlb;
 
-	spin_lock(&mm->page_table_lock);
 	tlb = tlb_gather_mmu(mm, 0);
 	if (is_hugepage_only_range(start, end - start))
 		hugetlb_free_pgtables(tlb, prev, start, end);
 	else
 		free_pgtables(tlb, prev, start, end);
 	tlb_finish_mmu(tlb, start, end);
-	spin_unlock(&mm->page_table_lock);
 }
 
 /*
@@ -1866,11 +1864,9 @@ void exit_mmap(struct mm_struct *mm)
 	 * Finally, free the pagetables. By this point, nothing should
 	 * refer to them.
 	 */
-	spin_lock(&mm->page_table_lock);
 	tlb = tlb_gather_mmu(mm, 1);
 	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
 	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
-	spin_unlock(&mm->page_table_lock);
 }
 
 /* Insert vm structure into process list sorted by address
diff -puN mm/rmap.c~vm-abstract-pgtable-locking mm/rmap.c
--- linux-2.6/mm/rmap.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/rmap.c	2004-10-29 16:28:08.000000000 +1000
@@ -32,7 +32,7 @@
  *   page->flags PG_locked (lock_page)
  *     mapping->i_mmap_lock
  *       anon_vma->lock
- *         mm->page_table_lock
+ *         mm_lock_page_table(mm)
  *           zone->lru_lock (in mark_page_accessed)
  *           swap_list_lock (in swap_free etc's swap_info_get)
  *             mmlist_lock (in mmput, drain_mmlist and others)
@@ -101,7 +101,11 @@ int anon_vma_prepare(struct vm_area_stru
 			locked = NULL;
 		}
 
-		/* page_table_lock to protect against threads */
+		/* protect against threads */
+		/*
+		 * XXX: this only needs to serialise against itself.
+		 * Perhaps we should rename the page table lock at some point.
+		 */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
@@ -256,6 +260,8 @@ unsigned long page_address_in_vma(struct
 static int page_referenced_one(struct page *page,
 	struct vm_area_struct *vma, unsigned int *mapcount)
 {
+	struct pte_modify pmod;
+	pte_t new;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pgd_t *pgd;
@@ -269,7 +275,7 @@ static int page_referenced_one(struct pa
 	if (address == -EFAULT)
 		goto out;
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -280,14 +286,19 @@ static int page_referenced_one(struct pa
 		goto out_unlock;
 
 	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte))
-		goto out_unmap;
-
-	if (page_to_pfn(page) != pte_pfn(*pte))
-		goto out_unmap;
+	new = ptep_begin_modify(&pmod, mm, pte);
+	if (!pte_present(new))
+		goto out_abort;
+
+	/* 
+	 * This doesn't need mm_pin_pages, because the anonvma locks
+	 * serialise against try_to_unmap.
+	 */
+	if (page_to_pfn(page) != pte_pfn(new))
+		goto out_abort;
 
-	if (ptep_clear_flush_young(vma, address, pte))
-		referenced++;
+	/* Doesn't matter much if this fails */
+	ptep_commit_clear_flush_young(&pmod, mm, vma, address, pte, &referenced);
 
 	if (mm != current->mm && has_swap_token(mm))
 		referenced++;
@@ -297,9 +308,13 @@ static int page_referenced_one(struct pa
 out_unmap:
 	pte_unmap(pte);
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 out:
 	return referenced;
+
+out_abort:
+	ptep_abort(&pmod, mm, pte);
+	goto out_unmap;
 }
 
 static int page_referenced_anon(struct page *page)
@@ -420,8 +435,6 @@ int page_referenced(struct page *page, i
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
- *
- * The caller needs to hold the mm->page_table_lock.
  */
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
@@ -448,8 +461,6 @@ void page_add_anon_rmap(struct page *pag
 /**
  * page_add_file_rmap - add pte mapping to a file page
  * @page: the page to add the mapping to
- *
- * The caller needs to hold the mm->page_table_lock.
  */
 void page_add_file_rmap(struct page *page)
 {
@@ -464,8 +475,6 @@ void page_add_file_rmap(struct page *pag
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
- *
- * Caller needs to hold the mm->page_table_lock.
  */
 void page_remove_rmap(struct page *page)
 {
@@ -494,12 +503,14 @@ void page_remove_rmap(struct page *page)
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma)
 {
+	struct pte_modify pmod;
+	swp_entry_t entry;
+	pte_t new, old;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
-	pte_t pteval;
 	int ret = SWAP_AGAIN;
 
 	if (!mm->rss)
@@ -509,10 +520,10 @@ static int try_to_unmap_one(struct page 
 		goto out;
 
 	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
+	 * We need to lock the page table to protect from page faults,
+	 * munmap, fork, exit, etc...
 	 */
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -523,27 +534,37 @@ static int try_to_unmap_one(struct page 
 		goto out_unlock;
 
 	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte))
-		goto out_unmap;
+	new = ptep_begin_modify(&pmod, mm, pte);
+	if (!pte_present(new))
+		goto out_abort;
 
-	if (page_to_pfn(page) != pte_pfn(*pte))
-		goto out_unmap;
+	/*
+	 * XXX: don't need to pin pages here because anonvma locking means
+	 * this page can't come out from underneath us (ie. we serialise
+	 * with other try_to_unmap's
+	 */
+	if (page_to_pfn(page) != pte_pfn(new))
+		goto out_abort;
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if ((vma->vm_flags & (VM_LOCKED|VM_RESERVED)) ||
-			ptep_clear_flush_young(vma, address, pte)) {
+	if (vma->vm_flags & (VM_LOCKED|VM_RESERVED)) {
 		ret = SWAP_FAIL;
-		goto out_unmap;
+		goto out_abort;
+	}
+
+	if (pte_young(new)) {
+		ret = SWAP_AGAIN;
+		goto out_abort;
 	}
 
 	/*
 	 * Don't pull an anonymous page out from under get_user_pages.
-	 * GUP carefully breaks COW and raises page count (while holding
-	 * page_table_lock, as we have here) to make sure that the page
+	 * GUP carefully breaks COW and raises page count (while the page
+	 * table is locked, as we have here) to make sure that the page
 	 * cannot be freed.  If we unmap that page here, a user write
 	 * access to the virtual address will bring back the page, but
 	 * its raised count will (ironically) be taken to mean it's not
@@ -555,22 +576,27 @@ static int try_to_unmap_one(struct page 
 	 * to drop page lock: its reference to the page stops existing
 	 * ptes from being unmapped, so swapoff can make progress.
 	 */
+	/*
+	 * XXX: this should be ok, as GUP is doing atomic checking...?
+	 * Well maybe not because neither are serialised. But hmm, GUP
+	 * and friends need to pin pages anyway, so it may be that these
+	 * paths will actually get serialised even without the page table
+	 * lock.
+	 */
+	/* XXX: Should this be enough? (Obviously a finer lock would be nice) */
+	mm_pin_pages(mm);
 	if (PageSwapCache(page) &&
 	    page_count(page) != page_mapcount(page) + 2) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+		mm_unpin_pages(mm);
+		ret = SWAP_AGAIN;
+		goto out_abort;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address);
-	pteval = ptep_clear_flush(vma, address, pte);
-
-	/* Move the dirty bit to the physical page now the pte is gone. */
-	if (pte_dirty(pteval))
-		set_page_dirty(page);
-
+	pte_clear(&new);
 	if (PageAnon(page)) {
-		swp_entry_t entry = { .val = page->private };
+		entry.val = page->private;
 		/*
 		 * Store the swap location in the pte.
 		 * See handle_pte_fault() ...
@@ -582,9 +608,22 @@ static int try_to_unmap_one(struct page 
 			list_add(&mm->mmlist, &init_mm.mmlist);
 			spin_unlock(&mmlist_lock);
 		}
-		set_pte(pte, swp_entry_to_pte(entry));
-		BUG_ON(pte_file(*pte));
+		new = swp_entry_to_pte(entry);
+		BUG_ON(pte_file(new));
+	}
+
+	if (ptep_commit_clear_flush(&pmod, mm, vma, address, pte, new, old)) {
+		ret = SWAP_AGAIN;
+		mm_unpin_pages(mm);
+		if (PageAnon(page))
+			free_swap_and_cache(entry);
+		goto out_unmap;
 	}
+	mm_unpin_pages(mm);
+
+	/* Move the dirty bit to the physical page now the pte is gone. */
+	if (pte_dirty(old))
+		set_page_dirty(page);
 
 	mm->rss--;
 	page_remove_rmap(page);
@@ -593,9 +632,13 @@ static int try_to_unmap_one(struct page 
 out_unmap:
 	pte_unmap(pte);
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 out:
 	return ret;
+
+out_abort:
+	ptep_abort(&pmod, mm, pte);
+	goto out_unmap;
 }
 
 /*
@@ -627,18 +670,11 @@ static void try_to_unmap_cluster(unsigne
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
-	pte_t pteval;
 	struct page *page;
 	unsigned long address;
 	unsigned long end;
 	unsigned long pfn;
 
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	spin_lock(&mm->page_table_lock);
-
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
 	if (address < vma->vm_start)
@@ -646,6 +682,12 @@ static void try_to_unmap_cluster(unsigne
 	if (end > vma->vm_end)
 		end = vma->vm_end;
 
+	/*
+	 * We need to lock the page table to protect from page faults,
+	 * munmap, fork, exit, etc...
+	 */
+	mm_lock_page_table(mm);
+
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
 		goto out_unlock;
@@ -656,44 +698,57 @@ static void try_to_unmap_cluster(unsigne
 
 	for (pte = pte_offset_map(pmd, address);
 			address < end; pte++, address += PAGE_SIZE) {
+		struct pte_modify pmod;
+		pte_t new, old;
 
-		if (!pte_present(*pte))
-			continue;
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+
+		if (!pte_present(new))
+			goto out_abort;
 
-		pfn = pte_pfn(*pte);
+		pfn = pte_pfn(new);
 		if (!pfn_valid(pfn))
-			continue;
+			goto out_abort;
 
 		page = pfn_to_page(pfn);
 		BUG_ON(PageAnon(page));
 		if (PageReserved(page))
-			continue;
+			goto out_abort;
 
-		if (ptep_clear_flush_young(vma, address, pte))
-			continue;
+		if (pte_young(new))
+			goto out_abort;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address);
-		pteval = ptep_clear_flush(vma, address, pte);
+		pte_clear(&new);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
-			set_pte(pte, pgoff_to_pte(page->index));
+			new = pgoff_to_pte(page->index);
+
+		if (ptep_commit_clear_flush(&pmod, mm, vma, address, pte, new, old))
+			goto again;
+		flush_tlb_page(vma, address);
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
-		if (pte_dirty(pteval))
+		if (pte_dirty(old))
 			set_page_dirty(page);
 
 		page_remove_rmap(page);
 		page_cache_release(page);
 		mm->rss--;
 		(*mapcount)--;
+
+		continue;
+out_abort:
+		ptep_abort(&pmod, mm, pte);
 	}
 
 	pte_unmap(pte);
 
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 }
 
 static int try_to_unmap_anon(struct page *page)
diff -puN mm/mremap.c~vm-abstract-pgtable-locking mm/mremap.c
--- linux-2.6/mm/mremap.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/mremap.c	2004-10-29 16:28:08.000000000 +1000
@@ -99,7 +99,7 @@ move_one_page(struct vm_area_struct *vma
 		mapping = vma->vm_file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
 	}
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 
 	src = get_one_pte_map_nested(mm, old_addr);
 	if (src) {
@@ -115,21 +115,28 @@ move_one_page(struct vm_area_struct *vma
 				spin_unlock(&mapping->i_mmap_lock);
 			dst = alloc_one_pte_map(mm, new_addr);
 			if (mapping && !spin_trylock(&mapping->i_mmap_lock)) {
-				spin_unlock(&mm->page_table_lock);
+				mm_unlock_page_table(mm);
 				spin_lock(&mapping->i_mmap_lock);
-				spin_lock(&mm->page_table_lock);
+				mm_lock_page_table(mm);
 			}
 			src = get_one_pte_map_nested(mm, old_addr);
 		}
+
 		/*
-		 * Since alloc_one_pte_map can drop and re-acquire
-		 * page_table_lock, we should re-check the src entry...
+		 * Since alloc_one_pte_map can drop and re-lock the
+		 * page table, we should re-check the src entry...
 		 */
 		if (src) {
 			if (dst) {
-				pte_t pte;
-				pte = ptep_clear_flush(vma, old_addr, src);
-				set_pte(dst, pte);
+				struct pte_modify pmod;
+				pte_t new, old;
+again:
+				new = ptep_begin_modify(&pmod, mm, src);
+				pte_clear(&new);
+				if (ptep_commit_clear_flush(&pmod, mm, vma,
+						old_addr, src, new, old))
+					goto again;
+				set_pte(dst, old);
 			} else
 				error = -ENOMEM;
 			pte_unmap_nested(src);
@@ -137,7 +144,7 @@ move_one_page(struct vm_area_struct *vma
 		if (dst)
 			pte_unmap(dst);
 	}
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 	return error;
diff -puN mm/msync.c~vm-abstract-pgtable-locking mm/msync.c
--- linux-2.6/mm/msync.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/msync.c	2004-10-29 16:28:08.000000000 +1000
@@ -18,27 +18,40 @@
 #include <asm/tlbflush.h>
 
 /*
- * Called with mm->page_table_lock held to protect against other
+ * Called with the page table locked to protect against other
  * threads/the swapper from ripping pte's out from under us.
  */
-static int filemap_sync_pte(pte_t *ptep, struct vm_area_struct *vma,
-	unsigned long address, unsigned int flags)
-{
-	pte_t pte = *ptep;
-	unsigned long pfn = pte_pfn(pte);
+static int filemap_sync_pte(struct mm_struct *mm, pte_t *ptep,
+		struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags)
+{
+	struct pte_modify pmod;
+	pte_t new;
+	unsigned long pfn;
 	struct page *page;
+	int dirty;
+
+again:
+	new = ptep_begin_modify(&pmod, mm, ptep);
 
-	if (pte_present(pte) && pfn_valid(pfn)) {
+	pfn = pte_pfn(new);
+	if (pte_present(new) && pfn_valid(pfn)) {
 		page = pfn_to_page(pfn);
-		if (!PageReserved(page) &&
-		    (ptep_clear_flush_dirty(vma, address, ptep) ||
-		     page_test_and_clear_dirty(page)))
-			set_page_dirty(page);
+		if (!PageReserved(page)) {
+			new = pte_mkclean(new);
+			if (ptep_commit_clear_flush_dirty(&pmod, mm, vma, address, ptep, &dirty))
+					goto again;
+			if (dirty || page_test_and_clear_dirty(page))
+				set_page_dirty(page);
+			goto out;
+		}
 	}
+	ptep_abort(&pmod, mm, ptep);
+out:
 	return 0;
 }
 
-static int filemap_sync_pte_range(pmd_t * pmd,
+static int filemap_sync_pte_range(struct mm_struct *mm, pmd_t * pmd,
 	unsigned long address, unsigned long end, 
 	struct vm_area_struct *vma, unsigned int flags)
 {
@@ -52,22 +65,25 @@ static int filemap_sync_pte_range(pmd_t 
 		pmd_clear(pmd);
 		return 0;
 	}
+
+	mm_pin_pages(mm); /* Required for filemap_sync_pte */
 	pte = pte_offset_map(pmd, address);
 	if ((address & PMD_MASK) != (end & PMD_MASK))
 		end = (address & PMD_MASK) + PMD_SIZE;
 	error = 0;
 	do {
-		error |= filemap_sync_pte(pte, vma, address, flags);
+		error |= filemap_sync_pte(mm, pte, vma, address, flags);
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
 
 	pte_unmap(pte - 1);
+	mm_unpin_pages(mm);
 
 	return error;
 }
 
-static inline int filemap_sync_pmd_range(pgd_t * pgd,
+static inline int filemap_sync_pmd_range(struct mm_struct *mm, pgd_t * pgd,
 	unsigned long address, unsigned long end, 
 	struct vm_area_struct *vma, unsigned int flags)
 {
@@ -86,7 +102,7 @@ static inline int filemap_sync_pmd_range
 		end = (address & PGDIR_MASK) + PGDIR_SIZE;
 	error = 0;
 	do {
-		error |= filemap_sync_pte_range(pmd, address, end, vma, flags);
+		error |= filemap_sync_pte_range(mm, pmd, address, end, vma, flags);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -103,7 +119,7 @@ static int filemap_sync(struct vm_area_s
 	/* Aquire the lock early; it may be possible to avoid dropping
 	 * and reaquiring it repeatedly.
 	 */
-	spin_lock(&vma->vm_mm->page_table_lock);
+	mm_lock_page_table(vma->vm_mm);
 
 	dir = pgd_offset(vma->vm_mm, address);
 	flush_cache_range(vma, address, end);
@@ -117,7 +133,7 @@ static int filemap_sync(struct vm_area_s
 	if (address >= end)
 		BUG();
 	do {
-		error |= filemap_sync_pmd_range(dir, address, end, vma, flags);
+		error |= filemap_sync_pmd_range(vma->vm_mm, dir, address, end, vma, flags);
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
@@ -127,7 +143,7 @@ static int filemap_sync(struct vm_area_s
 	 */
 	flush_tlb_range(vma, end - size, end);
  out:
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	mm_unlock_page_table(vma->vm_mm);
 
 	return error;
 }
diff -puN mm/mprotect.c~vm-abstract-pgtable-locking mm/mprotect.c
--- linux-2.6/mm/mprotect.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/mprotect.c	2004-10-29 16:28:08.000000000 +1000
@@ -26,7 +26,7 @@
 #include <asm/tlbflush.h>
 
 static inline void
-change_pte_range(pmd_t *pmd, unsigned long address,
+change_pte_range(struct mm_struct *mm, pmd_t *pmd, unsigned long address,
 		unsigned long size, pgprot_t newprot)
 {
 	pte_t * pte;
@@ -45,16 +45,21 @@ change_pte_range(pmd_t *pmd, unsigned lo
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		if (pte_present(*pte)) {
-			pte_t entry;
-
+		struct pte_modify pmod;
+		pte_t new, old;
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+		if (pte_present(new)) {
 			/* Avoid an SMP race with hardware updated dirty/clean
 			 * bits by wiping the pte and then setting the new pte
 			 * into place.
 			 */
-			entry = ptep_get_and_clear(pte);
-			set_pte(pte, pte_modify(entry, newprot));
-		}
+			new = pte_modify(new, newprot);
+			if (ptep_commit_clear(&pmod, mm, pte, new, old))
+				goto again;
+		} else
+			ptep_abort(&pmod, mm, pte);
+
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
@@ -62,7 +67,7 @@ change_pte_range(pmd_t *pmd, unsigned lo
 }
 
 static inline void
-change_pmd_range(pgd_t *pgd, unsigned long address,
+change_pmd_range(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
 		unsigned long size, pgprot_t newprot)
 {
 	pmd_t * pmd;
@@ -81,7 +86,7 @@ change_pmd_range(pgd_t *pgd, unsigned lo
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		change_pte_range(pmd, address, end - address, newprot);
+		change_pte_range(mm, pmd, address, end - address, newprot);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -93,19 +98,20 @@ change_protection(struct vm_area_struct 
 {
 	pgd_t *dir;
 	unsigned long beg = start;
+	struct mm_struct *mm = current->mm;
 
 	dir = pgd_offset(current->mm, start);
 	flush_cache_range(vma, beg, end);
 	if (start >= end)
 		BUG();
-	spin_lock(&current->mm->page_table_lock);
+	mm_lock_page_table(mm);
 	do {
-		change_pmd_range(dir, start, end - start, newprot);
+		change_pmd_range(mm, dir, start, end - start, newprot);
 		start = (start + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (start && (start < end));
 	flush_tlb_range(vma, beg, end);
-	spin_unlock(&current->mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return;
 }
 
diff -puN mm/swap_state.c~vm-abstract-pgtable-locking mm/swap_state.c
--- linux-2.6/mm/swap_state.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/swap_state.c	2004-10-29 16:28:08.000000000 +1000
@@ -273,7 +273,7 @@ static inline void free_swap_cache(struc
 /* 
  * Perform a free_page(), also freeing any swap cache associated with
  * this page if it is the last user of the page. Can not do a lock_page,
- * as we are holding the page_table_lock spinlock.
+ * as the page table is locked.
  */
 void free_page_and_swap_cache(struct page *page)
 {
diff -puN fs/exec.c~vm-abstract-pgtable-locking fs/exec.c
--- linux-2.6/fs/exec.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/fs/exec.c	2004-10-29 16:28:08.000000000 +1000
@@ -298,10 +298,12 @@ EXPORT_SYMBOL(copy_strings_kernel);
 void install_arg_page(struct vm_area_struct *vma,
 			struct page *page, unsigned long address)
 {
+	struct pte_modify pmod;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t * pgd;
 	pmd_t * pmd;
 	pte_t * pte;
+	pte_t new;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto out_sig;
@@ -309,29 +311,35 @@ void install_arg_page(struct vm_area_str
 	flush_dcache_page(page);
 	pgd = pgd_offset(mm, address);
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	pmd = pmd_alloc(mm, pgd, address);
 	if (!pmd)
 		goto out;
 	pte = pte_alloc_map(mm, pmd, address);
 	if (!pte)
 		goto out;
-	if (!pte_none(*pte)) {
+again:
+	new = ptep_begin_modify(&pmod, mm, pte);
+	if (!pte_none(new)) {
+		ptep_abort(&pmod, mm, pte);
 		pte_unmap(pte);
 		goto out;
 	}
+	new = pte_mkdirty(pte_mkwrite(mk_pte(page, vma->vm_page_prot)));
+	page_add_anon_rmap(page, vma, address);
+	if (ptep_commit(&pmod, mm, pte, new)) {
+		page_remove_rmap(page);
+		goto again;
+	}
 	mm->rss++;
 	lru_cache_add_active(page);
-	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
-	page_add_anon_rmap(page, vma, address);
 	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 
 	/* no need for flush_tlb */
 	return;
 out:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 out_sig:
 	__free_page(page);
 	force_sig(SIGKILL, current);
diff -puN arch/i386/kernel/vm86.c~vm-abstract-pgtable-locking arch/i386/kernel/vm86.c
--- linux-2.6/arch/i386/kernel/vm86.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/arch/i386/kernel/vm86.c	2004-10-29 16:28:08.000000000 +1000
@@ -136,13 +136,13 @@ struct pt_regs * fastcall save_v86_state
 
 static void mark_screen_rdonly(struct task_struct * tsk)
 {
+	struct mm_struct *mm = tsk->mm;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte, *mapped;
 	int i;
 
-	preempt_disable();
-	spin_lock(&tsk->mm->page_table_lock);
+	mm_lock_page_table(mm);
 	pgd = pgd_offset(tsk->mm, 0xA0000);
 	if (pgd_none(*pgd))
 		goto out;
@@ -161,14 +161,21 @@ static void mark_screen_rdonly(struct ta
 	}
 	pte = mapped = pte_offset_map(pmd, 0xA0000);
 	for (i = 0; i < 32; i++) {
-		if (pte_present(*pte))
-			set_pte(pte, pte_wrprotect(*pte));
+		struct pte_modify pmod;
+		pte_t new;
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+		if (pte_present(new)) {
+			new = pte_wrprotect(new);
+			if (ptep_commit(&pmod, mm, pte, new))
+				goto again;
+		} else
+			ptep_abort(&pmod, mm, pte);
 		pte++;
 	}
 	pte_unmap(mapped);
 out:
-	spin_unlock(&tsk->mm->page_table_lock);
-	preempt_enable();
+	mm_unlock_page_table(mm);
 	flush_tlb();
 }
 
diff -puN arch/i386/mm/hugetlbpage.c~vm-abstract-pgtable-locking arch/i386/mm/hugetlbpage.c
--- linux-2.6/arch/i386/mm/hugetlbpage.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c	2004-10-29 16:28:08.000000000 +1000
@@ -40,6 +40,7 @@ static pte_t *huge_pte_offset(struct mm_
 
 static void set_huge_pte(struct mm_struct *mm, struct vm_area_struct *vma, struct page *page, pte_t * page_table, int write_access)
 {
+	struct pte_modify pmod;
 	pte_t entry;
 
 	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
@@ -50,7 +51,11 @@ static void set_huge_pte(struct mm_struc
 		entry = pte_wrprotect(mk_pte(page, vma->vm_page_prot));
 	entry = pte_mkyoung(entry);
 	mk_pte_huge(entry);
-	set_pte(page_table, entry);
+	
+	/* XXX: ... */
+	do {
+		ptep_begin_modify(&pmod, mm, page_table);
+	} while (ptep_commit(&pmod, mm, page_table, entry));
 }
 
 /*
@@ -231,7 +236,7 @@ int hugetlb_prefault(struct address_spac
 	BUG_ON(vma->vm_start & ~HPAGE_MASK);
 	BUG_ON(vma->vm_end & ~HPAGE_MASK);
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
 		unsigned long idx;
 		pte_t *pte = huge_pte_alloc(mm, addr);
@@ -279,7 +284,7 @@ int hugetlb_prefault(struct address_spac
 		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
 	}
 out:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return ret;
 }
 
diff -puN mm/swapfile.c~vm-abstract-pgtable-locking mm/swapfile.c
--- linux-2.6/mm/swapfile.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/swapfile.c	2004-10-29 16:28:08.000000000 +1000
@@ -426,22 +426,9 @@ void free_swap_and_cache(swp_entry_t ent
  * share this swap entry, so be cautious and let do_wp_page work out
  * what to do if a write is requested later.
  */
-/* vma->vm_mm->page_table_lock is held */
-static void
-unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
-	swp_entry_t entry, struct page *page)
-{
-	vma->vm_mm->rss++;
-	get_page(page);
-	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_anon_rmap(page, vma, address);
-	swap_free(entry);
-}
-
-/* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
-	unsigned long address, unsigned long size, unsigned long offset,
-	swp_entry_t entry, struct page *page)
+static unsigned long unuse_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+	pmd_t *dir, unsigned long address, unsigned long size,
+	unsigned long offset, swp_entry_t entry, struct page *page)
 {
 	pte_t * pte;
 	unsigned long end;
@@ -461,12 +448,26 @@ static unsigned long unuse_pmd(struct vm
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
+		struct pte_modify pmod;
+		pte_t new;
 		/*
 		 * swapoff spends a _lot_ of time in this loop!
 		 * Test inline before going to call unuse_pte.
 		 */
-		if (unlikely(pte_same(*pte, swp_pte))) {
-			unuse_pte(vma, offset + address, pte, entry, page);
+again:
+		new = ptep_begin_modify(&pmod, mm, pte);
+		if (unlikely(pte_same(new, swp_pte))) {
+			get_page(page);
+			new = pte_mkold(mk_pte(page, vma->vm_page_prot));
+			if (ptep_commit(&pmod, mm, pte, new)) {
+				put_page(page);
+				goto again;
+			}
+
+			vma->vm_mm->rss++;
+			page_add_anon_rmap(page, vma, address);
+			swap_free(entry);
+
 			pte_unmap(pte);
 
 			/*
@@ -477,7 +478,9 @@ static unsigned long unuse_pmd(struct vm
 
 			/* add 1 since address may be 0 */
 			return 1 + offset + address;
-		}
+		} else
+			ptep_abort(&pmod, mm, pte);
+
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
@@ -485,9 +488,8 @@ static unsigned long unuse_pmd(struct vm
 	return 0;
 }
 
-/* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
-	unsigned long address, unsigned long size,
+static unsigned long unuse_pgd(struct mm_struct *mm, struct vm_area_struct *vma,
+	pgd_t *dir, unsigned long address, unsigned long size,
 	swp_entry_t entry, struct page *page)
 {
 	pmd_t * pmd;
@@ -510,7 +512,7 @@ static unsigned long unuse_pgd(struct vm
 	if (address >= end)
 		BUG();
 	do {
-		foundaddr = unuse_pmd(vma, pmd, address, end - address,
+		foundaddr = unuse_pmd(mm, vma, pmd, address, end - address,
 						offset, entry, page);
 		if (foundaddr)
 			return foundaddr;
@@ -520,9 +522,8 @@ static unsigned long unuse_pgd(struct vm
 	return 0;
 }
 
-/* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_vma(struct vm_area_struct * vma,
-	swp_entry_t entry, struct page *page)
+static unsigned long unuse_vma(struct mm_struct *mm, struct vm_area_struct *vma,
+		swp_entry_t entry, struct page *page)
 {
 	pgd_t *pgdir;
 	unsigned long start, end;
@@ -538,15 +539,17 @@ static unsigned long unuse_vma(struct vm
 		start = vma->vm_start;
 		end = vma->vm_end;
 	}
+	mm_lock_page_table(vma->vm_mm);
 	pgdir = pgd_offset(vma->vm_mm, start);
 	do {
-		foundaddr = unuse_pgd(vma, pgdir, start, end - start,
-						entry, page);
+		foundaddr = unuse_pgd(mm, vma, pgdir, start,
+						end - start, entry, page);
 		if (foundaddr)
 			return foundaddr;
 		start = (start + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (start && (start < end));
+	mm_unlock_page_table(vma->vm_mm);
 	return 0;
 }
 
@@ -568,15 +571,13 @@ static int unuse_process(struct mm_struc
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	spin_lock(&mm->page_table_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma) {
-			foundaddr = unuse_vma(vma, entry, page);
+			foundaddr = unuse_vma(mm, vma, entry, page);
 			if (foundaddr)
 				break;
 		}
 	}
-	spin_unlock(&mm->page_table_lock);
 	up_read(&mm->mmap_sem);
 	/*
 	 * Currently unuse_process cannot fail, but leave error handling
diff -puN mm/vmalloc.c~vm-abstract-pgtable-locking mm/vmalloc.c
--- linux-2.6/mm/vmalloc.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/vmalloc.c	2004-10-29 16:28:08.000000000 +1000
@@ -45,6 +45,7 @@ static void unmap_area_pte(pmd_t *pmd, u
 
 	do {
 		pte_t page;
+		/* XXX: make this use ptep_begin_modify */
 		page = ptep_get_and_clear(pte);
 		address += PAGE_SIZE;
 		pte++;
@@ -57,7 +58,7 @@ static void unmap_area_pte(pmd_t *pmd, u
 }
 
 static void unmap_area_pmd(pgd_t *dir, unsigned long address,
-				  unsigned long size)
+				unsigned long size)
 {
 	unsigned long end;
 	pmd_t *pmd;
@@ -84,8 +85,7 @@ static void unmap_area_pmd(pgd_t *dir, u
 }
 
 static int map_area_pte(pte_t *pte, unsigned long address,
-			       unsigned long size, pgprot_t prot,
-			       struct page ***pages)
+		unsigned long size, pgprot_t prot, struct page ***pages)
 {
 	unsigned long end;
 
@@ -95,13 +95,18 @@ static int map_area_pte(pte_t *pte, unsi
 		end = PMD_SIZE;
 
 	do {
+		struct pte_modify pmod;
+		pte_t new;
 		struct page *page = **pages;
-
-		WARN_ON(!pte_none(*pte));
 		if (!page)
 			return -ENOMEM;
 
-		set_pte(pte, mk_pte(page, prot));
+again:
+		new = ptep_begin_modify(&pmod, &init_mm, pte);
+		WARN_ON(!pte_none(new));
+		new = mk_pte(page, prot);
+		if (ptep_commit(&pmod, &init_mm, pte, new))
+			goto again;
 		address += PAGE_SIZE;
 		pte++;
 		(*pages)++;
@@ -110,8 +115,7 @@ static int map_area_pte(pte_t *pte, unsi
 }
 
 static int map_area_pmd(pmd_t *pmd, unsigned long address,
-			       unsigned long size, pgprot_t prot,
-			       struct page ***pages)
+		unsigned long size, pgprot_t prot, struct page ***pages)
 {
 	unsigned long base, end;
 
@@ -158,7 +162,7 @@ int map_vm_area(struct vm_struct *area, 
 	int err = 0;
 
 	dir = pgd_offset_k(address);
-	spin_lock(&init_mm.page_table_lock);
+	mm_lock_page_table(&init_mm);
 	do {
 		pmd_t *pmd = pmd_alloc(&init_mm, dir, address);
 		if (!pmd) {
@@ -174,7 +178,7 @@ int map_vm_area(struct vm_struct *area, 
 		dir++;
 	} while (address && (address < end));
 
-	spin_unlock(&init_mm.page_table_lock);
+	mm_unlock_page_table(&init_mm);
 	flush_cache_vmap((unsigned long) area->addr, end);
 	return err;
 }
diff -puN mm/hugetlb.c~vm-abstract-pgtable-locking mm/hugetlb.c
--- linux-2.6/mm/hugetlb.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/hugetlb.c	2004-10-29 16:28:08.000000000 +1000
@@ -253,7 +253,7 @@ void zap_hugepage_range(struct vm_area_s
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 	unmap_hugepage_range(vma, start, start + length);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 }
diff -puN mm/fremap.c~vm-abstract-pgtable-locking mm/fremap.c
--- linux-2.6/mm/fremap.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/mm/fremap.c	2004-10-29 16:28:08.000000000 +1000
@@ -23,19 +23,28 @@
 static inline void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, pte_t *ptep)
 {
-	pte_t pte = *ptep;
+	struct pte_modify pmod;
+	pte_t new, old;
 
-	if (pte_none(pte))
+again:
+	new = ptep_begin_modify(&pmod, mm, ptep);
+	if (pte_none(new)) {
+		ptep_abort(&pmod, mm, ptep);
 		return;
-	if (pte_present(pte)) {
-		unsigned long pfn = pte_pfn(pte);
+	}
+	if (pte_present(new)) {
+		/* XXX: needs mm_pin_pages */
+		unsigned long pfn = pte_pfn(new);
 
 		flush_cache_page(vma, addr);
-		pte = ptep_clear_flush(vma, addr, ptep);
+		pte_clear(&new);
+		if (ptep_commit_clear_flush(&pmod, mm, vma, addr,
+							ptep, new, old))
+			goto again;
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
 			if (!PageReserved(page)) {
-				if (pte_dirty(pte))
+				if (pte_dirty(old))
 					set_page_dirty(page);
 				page_remove_rmap(page);
 				page_cache_release(page);
@@ -43,9 +52,12 @@ static inline void zap_pte(struct mm_str
 			}
 		}
 	} else {
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear(ptep);
+		/* XXX: this will need to be done under a lock. Or maybe
+		 * we should clear the pte first?
+		 */
+		if (!pte_file(new))
+			free_swap_and_cache(pte_to_swp_entry(new));
+		ptep_abort(&pmod, mm, ptep);
 	}
 }
 
@@ -65,7 +77,7 @@ int install_page(struct mm_struct *mm, s
 	pte_t pte_val;
 
 	pgd = pgd_offset(mm, addr);
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 
 	pmd = pmd_alloc(mm, pgd, addr);
 	if (!pmd)
@@ -85,6 +97,10 @@ int install_page(struct mm_struct *mm, s
 	if (!page->mapping || page->index >= size)
 		goto err_unlock;
 
+	/*
+	 * XXX: locking becomes probably very broken - all this will now
+	 * be non atomic with lockless pagetables. Investigate.
+	 */
 	zap_pte(mm, vma, addr, pte);
 
 	mm->rss++;
@@ -97,7 +113,7 @@ int install_page(struct mm_struct *mm, s
 
 	err = 0;
 err_unlock:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return err;
 }
 EXPORT_SYMBOL(install_page);
@@ -117,7 +133,7 @@ int install_file_pte(struct mm_struct *m
 	pte_t pte_val;
 
 	pgd = pgd_offset(mm, addr);
-	spin_lock(&mm->page_table_lock);
+	mm_lock_page_table(mm);
 
 	pmd = pmd_alloc(mm, pgd, addr);
 	if (!pmd)
@@ -133,11 +149,11 @@ int install_file_pte(struct mm_struct *m
 	pte_val = *pte;
 	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return 0;
 
 err_unlock:
-	spin_unlock(&mm->page_table_lock);
+	mm_unlock_page_table(mm);
 	return err;
 }
 
diff -puN arch/i386/mm/ioremap.c~vm-abstract-pgtable-locking arch/i386/mm/ioremap.c
--- linux-2.6/arch/i386/mm/ioremap.c~vm-abstract-pgtable-locking	2004-10-29 16:28:08.000000000 +1000
+++ linux-2.6-npiggin/arch/i386/mm/ioremap.c	2004-10-29 16:28:08.000000000 +1000
@@ -17,8 +17,9 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
+static inline void remap_area_pte(pte_t * pte, unsigned long address,
+		unsigned long size, unsigned long phys_addr,
+		unsigned long flags)
 {
 	unsigned long end;
 	unsigned long pfn;
@@ -31,12 +32,20 @@ static inline void remap_area_pte(pte_t 
 		BUG();
 	pfn = phys_addr >> PAGE_SHIFT;
 	do {
-		if (!pte_none(*pte)) {
+		struct pte_modify pmod;
+		pte_t new;
+again:
+		new = ptep_begin_modify(&pmod, &init_mm, pte);
+		if (!pte_none(new)) {
 			printk("remap_area_pte: page already exists\n");
 			BUG();
 		}
-		set_pte(pte, pfn_pte(pfn, __pgprot(_PAGE_PRESENT | _PAGE_RW | 
-					_PAGE_DIRTY | _PAGE_ACCESSED | flags)));
+		new = pfn_pte(pfn, __pgprot(_PAGE_PRESENT | _PAGE_RW |
+					_PAGE_DIRTY | _PAGE_ACCESSED | flags));
+		if (ptep_commit(&pmod, &init_mm, pte, new)) {
+			printk("remap_area_pte: ptep_commit raced\n");
+			goto again;
+		}
 		address += PAGE_SIZE;
 		pfn++;
 		pte++;
@@ -78,7 +87,7 @@ static int remap_area_pages(unsigned lon
 	flush_cache_all();
 	if (address >= end)
 		BUG();
-	spin_lock(&init_mm.page_table_lock);
+	mm_lock_page_table(&init_mm);
 	do {
 		pmd_t *pmd;
 		pmd = pmd_alloc(&init_mm, dir, address);
@@ -92,7 +101,7 @@ static int remap_area_pages(unsigned lon
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
+	mm_unlock_page_table(&init_mm);
 	flush_tlb_all();
 	return error;
 }

_

--------------030408060902090908080607--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
