Message-ID: <41C94473.7050804@yahoo.com.au>
Date: Wed, 22 Dec 2004 20:54:59 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 4/11] split copy_page_range
References: <41C94361.6070909@yahoo.com.au> <41C943F0.4090006@yahoo.com.au> <41C94427.9020601@yahoo.com.au> <41C94449.20004@yahoo.com.au>
In-Reply-To: <41C94449.20004@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010201000303010806050200"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010201000303010806050200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/11

--------------010201000303010806050200
Content-Type: text/plain;
 name="3level-split-copy_page_range.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3level-split-copy_page_range.patch"



Split copy_page_range into the usual set of page table walking functions.
Needed to handle the complexity when moving to 4 levels.

Split out from Andi Kleen's 4level patch.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/mm/memory.c |  290 ++++++++++++++++++++++--------------------
 1 files changed, 152 insertions(+), 138 deletions(-)

diff -puN mm/memory.c~3level-split-copy_page_range mm/memory.c
--- linux-2.6/mm/memory.c~3level-split-copy_page_range	2004-12-22 20:31:44.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-12-22 20:35:58.000000000 +1100
@@ -204,165 +204,179 @@ pte_t fastcall * pte_alloc_kernel(struct
 out:
 	return pte_offset_kernel(pmd, address);
 }
-#define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
-#define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
 
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
  * covered by this vma.
  *
- * 08Jan98 Merged into one routine from several inline routines to reduce
- *         variable count and make things faster. -jj
- *
  * dst->page_table_lock is held on entry and exit,
- * but may be dropped within pmd_alloc() and pte_alloc_map().
+ * but may be dropped within p[mg]d_alloc() and pte_alloc_map().
  */
+
+static inline void
+copy_swap_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm, pte_t pte)
+{
+	if (pte_file(pte))
+		return;
+	swap_duplicate(pte_to_swp_entry(pte));
+	if (list_empty(&dst_mm->mmlist)) {
+		spin_lock(&mmlist_lock);
+		list_add(&dst_mm->mmlist, &src_mm->mmlist);
+		spin_unlock(&mmlist_lock);
+	}
+}
+
+static inline void
+copy_one_pte(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pte_t *dst_pte, pte_t *src_pte, unsigned long vm_flags,
+		unsigned long addr)
+{
+	pte_t pte = *src_pte;
+	struct page *page;
+	unsigned long pfn;
+
+	/* pte contains position in swap, so copy. */
+	if (!pte_present(pte)) {
+		copy_swap_pte(dst_mm, src_mm, pte);
+		set_pte(dst_pte, pte);
+		return;
+	}
+	pfn = pte_pfn(pte);
+	/* the pte points outside of valid memory, the
+	 * mapping is assumed to be good, meaningful
+	 * and not mapped via rmap - duplicate the
+	 * mapping as is.
+	 */
+	page = NULL;
+	if (pfn_valid(pfn))
+		page = pfn_to_page(pfn);
+
+	if (!page || PageReserved(page)) {
+		set_pte(dst_pte, pte);
+		return;
+	}
+
+	/*
+	 * If it's a COW mapping, write protect it both
+	 * in the parent and the child
+	 */
+	if ((vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE) {
+		ptep_set_wrprotect(src_pte);
+		pte = *src_pte;
+	}
+
+	/*
+	 * If it's a shared mapping, mark it clean in
+	 * the child
+	 */
+	if (vm_flags & VM_SHARED)
+		pte = pte_mkclean(pte);
+	pte = pte_mkold(pte);
+	get_page(page);
+	dst_mm->rss++;
+	if (PageAnon(page))
+		dst_mm->anon_rss++;
+	set_pte(dst_pte, pte);
+	page_dup_rmap(page);
+}
+
+static int copy_pte_range(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+	pte_t *s, *d;
+	unsigned long vm_flags = vma->vm_flags;
+
+	d = dst_pte = pte_alloc_map(dst_mm, dst_pmd, addr);
+	if (!dst_pte)
+		return -ENOMEM;
+
+	spin_lock(&src_mm->page_table_lock);
+	s = src_pte = pte_offset_map_nested(src_pmd, addr);
+	for (; addr < end; addr += PAGE_SIZE, s++, d++) {
+		if (pte_none(*s))
+			continue;
+		copy_one_pte(dst_mm, src_mm, d, s, vm_flags, addr);
+	}
+	pte_unmap_nested(src_pte);
+	pte_unmap(dst_pte);
+	spin_unlock(&src_mm->page_table_lock);
+	cond_resched_lock(&dst_mm->page_table_lock);
+	return 0;
+}
+
+static int copy_pmd_range(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	int err = 0;
+	unsigned long next;
+
+	src_pmd = pmd_offset(src_pgd, addr);
+	dst_pmd = pmd_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_pmd)
+		return -ENOMEM;
+
+	for (; addr < end; addr = next, src_pmd++, dst_pmd++) {
+		next = (addr + PMD_SIZE) & PMD_MASK;
+		if (next > end)
+			next = end;
+		if (pmd_none(*src_pmd))
+			continue;
+		if (pmd_bad(*src_pmd)) {
+			pmd_ERROR(*src_pmd);
+			pmd_clear(src_pmd);
+			continue;
+		}
+		err = copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+							vma, addr, next);
+		if (err)
+			break;
+	}
+	return err;
+}
+
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma)
+		struct vm_area_struct *vma)
 {
-	pgd_t * src_pgd, * dst_pgd;
-	unsigned long address = vma->vm_start;
-	unsigned long end = vma->vm_end;
-	unsigned long cow;
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long addr, start, end, next;
+	int err = 0;
 
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst, src, vma);
 
-	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
-	src_pgd = pgd_offset(src, address)-1;
-	dst_pgd = pgd_offset(dst, address)-1;
-
-	for (;;) {
-		pmd_t * src_pmd, * dst_pmd;
-
-		src_pgd++; dst_pgd++;
-		
-		/* copy_pmd_range */
-		
+	start = vma->vm_start;
+	src_pgd = pgd_offset(src, start);
+	dst_pgd = pgd_offset(dst, start);
+
+	end = vma->vm_end;
+	addr = start;
+	while (addr && (addr < end-1)) {
+		next = (addr + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end || next <= addr)
+			next = end;
 		if (pgd_none(*src_pgd))
-			goto skip_copy_pmd_range;
-		if (unlikely(pgd_bad(*src_pgd))) {
+			continue;
+		if (pgd_bad(*src_pgd)) {
 			pgd_ERROR(*src_pgd);
 			pgd_clear(src_pgd);
-skip_copy_pmd_range:	address = (address + PGDIR_SIZE) & PGDIR_MASK;
-			if (!address || (address >= end))
-				goto out;
 			continue;
 		}
+		err = copy_pmd_range(dst, src, dst_pgd, src_pgd,
+							vma, addr, next);
+		if (err)
+			break;
 
-		src_pmd = pmd_offset(src_pgd, address);
-		dst_pmd = pmd_alloc(dst, dst_pgd, address);
-		if (!dst_pmd)
-			goto nomem;
-
-		do {
-			pte_t * src_pte, * dst_pte;
-		
-			/* copy_pte_range */
-		
-			if (pmd_none(*src_pmd))
-				goto skip_copy_pte_range;
-			if (unlikely(pmd_bad(*src_pmd))) {
-				pmd_ERROR(*src_pmd);
-				pmd_clear(src_pmd);
-skip_copy_pte_range:
-				address = (address + PMD_SIZE) & PMD_MASK;
-				if (address >= end)
-					goto out;
-				goto cont_copy_pmd_range;
-			}
-
-			dst_pte = pte_alloc_map(dst, dst_pmd, address);
-			if (!dst_pte)
-				goto nomem;
-			spin_lock(&src->page_table_lock);	
-			src_pte = pte_offset_map_nested(src_pmd, address);
-			do {
-				pte_t pte = *src_pte;
-				struct page *page;
-				unsigned long pfn;
-
-				/* copy_one_pte */
-
-				if (pte_none(pte))
-					goto cont_copy_pte_range_noset;
-				/* pte contains position in swap, so copy. */
-				if (!pte_present(pte)) {
-					if (!pte_file(pte)) {
-						swap_duplicate(pte_to_swp_entry(pte));
-						if (list_empty(&dst->mmlist)) {
-							spin_lock(&mmlist_lock);
-							list_add(&dst->mmlist,
-								 &src->mmlist);
-							spin_unlock(&mmlist_lock);
-						}
-					}
-					set_pte(dst_pte, pte);
-					goto cont_copy_pte_range_noset;
-				}
-				pfn = pte_pfn(pte);
-				/* the pte points outside of valid memory, the
-				 * mapping is assumed to be good, meaningful
-				 * and not mapped via rmap - duplicate the
-				 * mapping as is.
-				 */
-				page = NULL;
-				if (pfn_valid(pfn)) 
-					page = pfn_to_page(pfn); 
-
-				if (!page || PageReserved(page)) {
-					set_pte(dst_pte, pte);
-					goto cont_copy_pte_range_noset;
-				}
-
-				/*
-				 * If it's a COW mapping, write protect it both
-				 * in the parent and the child
-				 */
-				if (cow) {
-					ptep_set_wrprotect(src_pte);
-					pte = *src_pte;
-				}
-
-				/*
-				 * If it's a shared mapping, mark it clean in
-				 * the child
-				 */
-				if (vma->vm_flags & VM_SHARED)
-					pte = pte_mkclean(pte);
-				pte = pte_mkold(pte);
-				get_page(page);
-				dst->rss++;
-				if (PageAnon(page))
-					dst->anon_rss++;
-				set_pte(dst_pte, pte);
-				page_dup_rmap(page);
-cont_copy_pte_range_noset:
-				address += PAGE_SIZE;
-				if (address >= end) {
-					pte_unmap_nested(src_pte);
-					pte_unmap(dst_pte);
-					goto out_unlock;
-				}
-				src_pte++;
-				dst_pte++;
-			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
-			pte_unmap_nested(src_pte-1);
-			pte_unmap(dst_pte-1);
-			spin_unlock(&src->page_table_lock);
-			cond_resched_lock(&dst->page_table_lock);
-cont_copy_pmd_range:
-			src_pmd++;
-			dst_pmd++;
-		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
+		src_pgd++;
+		dst_pgd++;
+		addr = next;
 	}
-out_unlock:
-	spin_unlock(&src->page_table_lock);
-out:
-	return 0;
-nomem:
-	return -ENOMEM;
+
+	return err;
 }
 
 static void zap_pte_range(struct mmu_gather *tlb,

_

--------------010201000303010806050200--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
