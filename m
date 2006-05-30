Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:13:14 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:13:14 +1000 (EST)
Subject: [Patch 3/17] PTI: Abstract default page table B
Message-ID: <Pine.LNX.4.61.0605301710560.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove page table tear down implementation from memory.c (it is now part
  of the default page table implementation found in default-pt.c)

  Abstracted free_pgtables in memory.c to be independent of the default
  page table implementation (via a call to coallesce vmas).

  Some of the page table implementation is contained in mm.h. This is
  abstracted to ts own file (default-pt-mm.h).

  include/linux/mm.h |   71 ----------------------
  mm/memory.c        |  170 
+----------------------------------------------------
  2 files changed, 6 insertions(+), 235 deletions(-)
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-29 16:56:36.315678896 +1000
+++ linux-rc5/mm/memory.c	2006-05-29 16:56:37.252536472 +1000
@@ -91,154 +91,6 @@
  }
  __setup("norandmaps", disable_randmaps);

-/*
- * Note: this doesn't free the actual pages themselves. That
- * has been handled earlier when unmapping all the memory regions.
- */
-static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
-{
-	struct page *page = pmd_page(*pmd);
-	pmd_clear(pmd);
-	pte_lock_deinit(page);
-	pte_free_tlb(tlb, page);
-	dec_page_state(nr_page_table_pages);
-	tlb->mm->nr_ptes--;
-}
-
-static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				unsigned long floor, unsigned long 
ceiling)
-{
-	pmd_t *pmd;
-	unsigned long next;
-	unsigned long start;
-
-	start = addr;
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		free_pte_range(tlb, pmd);
-	} while (pmd++, addr = next, addr != end);
-
-	start &= PUD_MASK;
-	if (start < floor)
-		return;
-	if (ceiling) {
-		ceiling &= PUD_MASK;
-		if (!ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		return;
-
-	pmd = pmd_offset(pud, start);
-	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd);
-}
-
-static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				unsigned long floor, unsigned long 
ceiling)
-{
-	pud_t *pud;
-	unsigned long next;
-	unsigned long start;
-
-	start = addr;
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		free_pmd_range(tlb, pud, addr, next, floor, ceiling);
-	} while (pud++, addr = next, addr != end);
-
-	start &= PGDIR_MASK;
-	if (start < floor)
-		return;
-	if (ceiling) {
-		ceiling &= PGDIR_MASK;
-		if (!ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		return;
-
-	pud = pud_offset(pgd, start);
-	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud);
-}
-
-/*
- * This function frees user-level page tables of a process.
- *
- * Must be called with pagetable lock held.
- */
-void free_pgd_range(struct mmu_gather **tlb,
-			unsigned long addr, unsigned long end,
-			unsigned long floor, unsigned long ceiling)
-{
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long start;
-
-	/*
-	 * The next few lines have given us lots of grief...
-	 *
-	 * Why are we testing PMD* at this top level?  Because often
-	 * there will be no work to do at all, and we'd prefer not to
-	 * go all the way down to the bottom just to discover that.
-	 *
-	 * Why all these "- 1"s?  Because 0 represents both the bottom
-	 * of the address space and the top of it (using -1 for the
-	 * top wouldn't help much: the masks would do the wrong thing).
-	 * The rule is that addr 0 and floor 0 refer to the bottom of
-	 * the address space, but end 0 and ceiling 0 refer to the top
-	 * Comparisons need to use "end - 1" and "ceiling - 1" (though
-	 * that end 0 case should be mythical).
-	 *
-	 * Wherever addr is brought up or ceiling brought down, we must
-	 * be careful to reject "the opposite 0" before it confuses the
-	 * subsequent tests.  But what about where end is brought down
-	 * by PMD_SIZE below? no, end can't go down to 0 there.
-	 *
-	 * Whereas we round start (addr) and ceiling down, by different
-	 * masks at different levels, in order to test whether a table
-	 * now has no other vmas using it, so can be freed, we don't
-	 * bother to round floor or end up - the tests don't need that.
-	 */
-
-	addr &= PMD_MASK;
-	if (addr < floor) {
-		addr += PMD_SIZE;
-		if (!addr)
-			return;
-	}
-	if (ceiling) {
-		ceiling &= PMD_MASK;
-		if (!ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		end -= PMD_SIZE;
-	if (addr > end - 1)
-		return;
-
-	start = addr;
-	pgd = pgd_offset((*tlb)->mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
-	} while (pgd++, addr = next, addr != end);
-
-	if (!(*tlb)->fullmm)
-		flush_tlb_pgtables((*tlb)->mm, start, end);
-}
-
  void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
  		unsigned long floor, unsigned long ceiling)
  {
@@ -252,23 +104,11 @@
  		anon_vma_unlink(vma);
  		unlink_file_vma(vma);

-		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		} else {
-			/*
-			 * Optimization: gather nearby vmas into one call 
down
-			 */
-			while (next && next->vm_start <= vma->vm_end + 
PMD_SIZE
-			       && !is_vm_hugetlb_page(next)) {
-				vma = next;
-				next = vma->vm_next;
-				anon_vma_unlink(vma);
-				unlink_file_vma(vma);
-			}
-			free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		}
+		coallesce_vmas(&vma, &next);
+
+		free_pgd_range(tlb, addr, vma->vm_end,
+			floor, next? next->vm_start: ceiling);
+
  		vma = next;
  	}
  }
Index: linux-rc5/include/linux/mm.h
===================================================================
--- linux-rc5.orig/include/linux/mm.h	2006-05-29 14:57:46.793748888 
+1000
+++ linux-rc5/include/linux/mm.h	2006-05-29 16:56:37.708467160 
+1000
@@ -791,76 +791,7 @@

  extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long 
addr, spinlock_t **ptl));

-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
-
-/*
- * The following ifdef needed to get the 4level-fixup.h header to work.
- * Remove it when 4level-fixup.h has been removed.
- */
-#if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned 
long address)
-{
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, 
address))?
-		NULL: pud_offset(pgd, address);
-}
-
-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned 
long address)
-{
-	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, 
address))?
-		NULL: pmd_offset(pud, address);
-}
-#endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
-
-#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
-/*
- * We tuck a spinlock to guard each pagetable page into its struct page,
- * at page->private, with BUILD_BUG_ON to make sure that this will not
- * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
- * When freeing, reset page->mapping so free_pages_check won't complain.
- */
-#define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
-#define pte_lockptr(mm, pmd)	({(void)(mm); 
__pte_lockptr(pmd_page(*(pmd)));})
-#else
-/*
- * We use mm->page_table_lock to guard all pagetable pages of the mm.
- */
-#define pte_lock_init(page)	do {} while (0)
-#define pte_lock_deinit(page)	do {} while (0)
-#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
-#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
-
-#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
-({							\
-	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
-	pte_t *__pte = pte_offset_map(pmd, address);	\
-	*(ptlp) = __ptl;				\
-	spin_lock(__ptl);				\
-	__pte;						\
-})
-
-#define pte_unmap_unlock(pte, ptl)	do {		\
-	spin_unlock(ptl);				\
-	pte_unmap(pte);					\
-} while (0)
-
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, 
address))? \
-		NULL: pte_offset_map(pmd, address))
-
-#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, 
address))? \
-		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
-
-#define pte_alloc_kernel(pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, 
address))? \
-		NULL: pte_offset_kernel(pmd, address))
+#include <linux/default-pt-mm.h>

  extern void free_area_init(unsigned long * zones_size);
  extern void free_area_init_node(int nid, pg_data_t *pgdat,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
