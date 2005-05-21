From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 13:08:47 +1000 (EST)
Subject: [PATCH 3/15] PTI: move mlpt behind interface
In-Reply-To: <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 3 of 15.

This patch starts to rearrange the code, to separate
page-table-specific code into a new file.

 	*The patch moves free_pgtables() away and makes free_pgd_range()
 	 a static.  This breaks hugeTLBfs, but that is to be fixed up in a
 	 later patch set.
 	*The prototype for free_pgtables() is removed out of mm.h as it
 	 now resides in mlpt-generic.h
 	*free_pgtables() is now being called through mlpt-generic.h via
 	 page_table.h.
 	*abstracts mlpt dependent code from mm.h to mm-mlpt.h

  include/linux/mm.h        |   40 +--------
  include/mm/mlpt-generic.h |    3
  include/mm/mm-mlpt.h      |   32 +++++++
  mm/fixed-mlpt/mlpt.c      |  193 
++++++++++++++++++++++++++++++++++++++++++++++
  mm/memory.c               |  177 
------------------------------------------
  mm/mmap.c                 |    1
  6 files changed, 233 insertions(+), 213 deletions(-)

Index: linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/fixed-mlpt/mlpt.c	2005-05-19 
17:24:29.000000000 +1000
+++ linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c	2005-05-19 
17:24:49.000000000 +1000
@@ -1 +1,194 @@
+#include <linux/kernel_stat.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/init.h>
  #include <linux/page_table.h>
+
+#include <asm/uaccess.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+
+#include <linux/swapops.h>
+#include <linux/elf.h>
+
+
+/*
+ * Note: this doesn't free the actual pages themselves. That
+ * has been handled earlier when unmapping all the memory regions.
+ */
+static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+	pmd_clear(pmd);
+	pte_free_tlb(tlb, page);
+	dec_page_state(nr_page_table_pages);
+	tlb->mm->nr_ptes--;
+}
+
+static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long 
ceiling)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		free_pte_range(tlb, pmd);
+	} while (pmd++, addr = next, addr != end);
+
+	start &= PUD_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PUD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pmd = pmd_offset(pud, start);
+	pud_clear(pud);
+	pmd_free_tlb(tlb, pmd);
+}
+
+static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long 
ceiling)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+	} while (pud++, addr = next, addr != end);
+
+	start &= PGDIR_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PGDIR_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pud = pud_offset(pgd, start);
+	pgd_clear(pgd);
+	pud_free_tlb(tlb, pud);
+}
+
+/*
+ * This function frees user-level page tables of a process.
+ *
+ * Must be called with pagetable lock held.
+ */
+static void free_pgd_range(struct mmu_gather **tlb,
+			unsigned long addr, unsigned long end,
+			unsigned long floor, unsigned long ceiling)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	unsigned long start;
+
+	/*
+	 * The next few lines have given us lots of grief...
+	 *
+	 * Why are we testing PMD* at this top level?  Because often
+	 * there will be no work to do at all, and we'd prefer not to
+	 * go all the way down to the bottom just to discover that.
+	 *
+	 * Why all these "- 1"s?  Because 0 represents both the bottom
+	 * of the address space and the top of it (using -1 for the
+	 * top wouldn't help much: the masks would do the wrong thing).
+	 * The rule is that addr 0 and floor 0 refer to the bottom of
+	 * the address space, but end 0 and ceiling 0 refer to the top
+	 * Comparisons need to use "end - 1" and "ceiling - 1" (though
+	 * that end 0 case should be mythical).
+	 *
+	 * Wherever addr is brought up or ceiling brought down, we must
+	 * be careful to reject "the opposite 0" before it confuses the
+	 * subsequent tests.  But what about where end is brought down
+	 * by PMD_SIZE below? no, end can't go down to 0 there.
+	 *
+	 * Whereas we round start (addr) and ceiling down, by different
+	 * masks at different levels, in order to test whether a table
+	 * now has no other vmas using it, so can be freed, we don't
+	 * bother to round floor or end up - the tests don't need that.
+	 */
+
+	addr &= PMD_MASK;
+	if (addr < floor) {
+		addr += PMD_SIZE;
+		if (!addr)
+			return;
+	}
+	if (ceiling) {
+		ceiling &= PMD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		end -= PMD_SIZE;
+	if (addr > end - 1)
+		return;
+
+	start = addr;
+	pgd = pgd_offset((*tlb)->mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
+	} while (pgd++, addr = next, addr != end);
+
+	if (!tlb_is_full_mm(*tlb))
+		flush_tlb_pgtables((*tlb)->mm, start, end);
+}
+
+void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+		unsigned long floor, unsigned long ceiling)
+{
+	while (vma) {
+		struct vm_area_struct *next = vma->vm_next;
+		unsigned long addr = vma->vm_start;
+
+		if (is_hugepage_only_range(vma->vm_mm, addr, HPAGE_SIZE)) 
{
+			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+				floor, next? next->vm_start: ceiling);
+		} else {
+			/*
+			 * Optimization: gather nearby vmas into one call 
down
+			 */
+			while (next && next->vm_start <= vma->vm_end + 
PMD_SIZE
+			  && !is_hugepage_only_range(vma->vm_mm, 
next->vm_start,
+							HPAGE_SIZE)) {
+				vma = next;
+				next = vma->vm_next;
+			}
+			free_pgd_range(tlb, addr, vma->vm_end,
+				floor, next? next->vm_start: ceiling);
+		}
+		vma = next;
+	}
+}
+
Index: linux-2.6.12-rc4/include/mm/mlpt-generic.h
===================================================================
--- linux-2.6.12-rc4.orig/include/mm/mlpt-generic.h	2005-05-19 
17:24:29.000000000 +1000
+++ linux-2.6.12-rc4/include/mm/mlpt-generic.h	2005-05-19 
17:24:49.000000000 +1000
@@ -6,8 +6,7 @@

  /**
   * init_page_table - initialise a user process page table
- *
- * Returns the address of the page table
+ * the address of the page table
   *
   * Creates a new page table.  This consists of a zeroed out pgd.
   */
Index: linux-2.6.12-rc4/mm/mmap.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/mmap.c	2005-05-19 17:24:29.000000000 
+1000
+++ linux-2.6.12-rc4/mm/mmap.c	2005-05-19 17:24:49.000000000 +1000
@@ -24,6 +24,7 @@
  #include <linux/mount.h>
  #include <linux/mempolicy.h>
  #include <linux/rmap.h>
+#include <linux/page_table.h>

  #include <asm/uaccess.h>
  #include <asm/cacheflush.h>
Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-19 17:24:29.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-19 17:24:49.000000000 
+1000
@@ -48,12 +48,11 @@
  #include <linux/rmap.h>
  #include <linux/module.h>
  #include <linux/init.h>
+#include <linux/page_table.h>

-#include <asm/pgalloc.h>
  #include <asm/uaccess.h>
  #include <asm/tlb.h>
  #include <asm/tlbflush.h>
-#include <asm/pgtable.h>

  #include <linux/swapops.h>
  #include <linux/elf.h>
@@ -106,180 +105,6 @@
  	pmd_clear(pmd);
  }

-/*
- * Note: this doesn't free the actual pages themselves. That
- * has been handled earlier when unmapping all the memory regions.
- */
-static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
-{
-	struct page *page = pmd_page(*pmd);
-	pmd_clear(pmd);
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
-	if (!tlb_is_full_mm(*tlb))
-		flush_tlb_pgtables((*tlb)->mm, start, end);
-}
-
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
-		unsigned long floor, unsigned long ceiling)
-{
-	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
-		unsigned long addr = vma->vm_start;
-
-		if (is_hugepage_only_range(vma->vm_mm, addr, HPAGE_SIZE)) 
{
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		} else {
-			/*
-			 * Optimization: gather nearby vmas into one call 
down
-			 */
-			while (next && next->vm_start <= vma->vm_end + 
PMD_SIZE
-			  && !is_hugepage_only_range(vma->vm_mm, 
next->vm_start,
-							HPAGE_SIZE)) {
-				vma = next;
-				next = vma->vm_next;
-			}
-			free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		}
-		vma = next;
-	}
-}
-
  pte_t fastcall *pte_alloc_map(struct mm_struct *mm, pmd_t *pmd,
  				unsigned long address)
  {
Index: linux-2.6.12-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.12-rc4.orig/include/linux/mm.h	2005-05-19 
17:24:29.000000000 +1000
+++ linux-2.6.12-rc4/include/linux/mm.h	2005-05-19 17:24:49.000000000 
+1000
@@ -587,10 +587,6 @@
  		struct vm_area_struct *start_vma, unsigned long 
start_addr,
  		unsigned long end_addr, unsigned long *nr_accounted,
  		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
-		unsigned long end, unsigned long floor, unsigned long 
ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct 
*start_vma,
-		unsigned long floor, unsigned long ceiling);
  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
  			struct vm_area_struct *vma);
  int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
@@ -605,10 +601,11 @@
  }

  extern int vmtruncate(struct inode * inode, loff_t offset);
-extern pud_t *FASTCALL(__pud_alloc(struct mm_struct *mm, pgd_t *pgd, 
unsigned long address));
-extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pud_t *pud, 
unsigned long address));
-extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address));
-extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address));
+
+#ifdef CONFIG_MLPT
+#include <mm/mm-mlpt.h>
+#endif
+
  extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, 
unsigned long addr, struct page *page, pgprot_t prot);
  extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct 
*vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
  extern int handle_mm_fault(struct mm_struct *mm,struct vm_area_struct 
*vma, unsigned long address, int write_access);
@@ -654,33 +651,6 @@
  extern struct shrinker *set_shrinker(int, shrinker_t);
  extern void remove_shrinker(struct shrinker *shrinker);

-/*
- * On a two-level or three-level page table, this ends up being trivial. 
Thus
- * the inlining and the symmetry break with pte_alloc_map() that does all
- * of this out-of-line.
- */
-/*
- * The following ifdef needed to get the 4level-fixup.h header to work.
- * Remove it when 4level-fixup.h has been removed.
- */
-#ifdef CONFIG_MMU
-#ifndef __ARCH_HAS_4LEVEL_HACK
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned 
long address)
-{
-	if (pgd_none(*pgd))
-		return __pud_alloc(mm, pgd, address);
-	return pud_offset(pgd, address);
-}
-
-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned 
long address)
-{
-	if (pud_none(*pud))
-		return __pmd_alloc(mm, pud, address);
-	return pmd_offset(pud, address);
-}
-#endif
-#endif /* CONFIG_MMU */
-
  extern void free_area_init(unsigned long * zones_size);
  extern void free_area_init_node(int nid, pg_data_t *pgdat,
  	unsigned long * zones_size, unsigned long zone_start_pfn,
Index: linux-2.6.12-rc4/include/mm/mm-mlpt.h
===================================================================
--- linux-2.6.12-rc4.orig/include/mm/mm-mlpt.h	2005-05-19 
17:24:27.000000000 +1000
+++ linux-2.6.12-rc4/include/mm/mm-mlpt.h	2005-05-19 
17:29:17.000000000 +1000
@@ -1,4 +1,36 @@
  #ifndef _MM_MM_MLPT_H
  #define _MM_MM_MLPT_H 1

+extern pud_t *FASTCALL(__pud_alloc(struct mm_struct *mm, pgd_t *pgd, 
unsigned long address));
+extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pud_t *pud, 
unsigned long address));
+extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address));
+extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address));
+
+/*
+ * On a two-level or three-level page table, this ends up being trivial. 
Thus
+ * the inlining and the symmetry break with pte_alloc_map() that does all
+ * of this out-of-line.
+ */
+/*
+ * The following ifdef needed to get the 4level-fixup.h header to work.
+ * Remove it when 4level-fixup.h has been removed.
+ */
+#ifdef CONFIG_MMU
+#ifndef __ARCH_HAS_4LEVEL_HACK
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned 
long address)
+{
+	if (pgd_none(*pgd))
+		return __pud_alloc(mm, pgd, address);
+	return pud_offset(pgd, address);
+}
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned 
long address)
+{
+	if (pud_none(*pud))
+		return __pmd_alloc(mm, pud, address);
+	return pmd_offset(pud, address);
+}
+#endif
+#endif /* CONFIG_MMU */
+
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
