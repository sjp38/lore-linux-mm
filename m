From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:20 +1000
Message-Id: <20060713042720.9978.18521.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/18] PTI - Abstract default page table
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

t		This patch does the following:
1) Continues page table abstraction from memory.c to pt-default.c
 * page table deallocation iterator removed from memory.c

2) Abstraction of page table implementation in mm.h to pt-mm.h
 * Puts implementation in mm.h into pt-mm.h
Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-mm.h |  118 +++++++++++++++++++++++++++++++++++++++
 mm/memory.c           |  148 --------------------------------------------------
 2 files changed, 118 insertions(+), 148 deletions(-)
Index: linux-2.6.17.2/include/linux/pt-mm.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/linux/pt-mm.h	2006-07-08 23:56:38.660308704 +1000
@@ -0,0 +1,118 @@
+#ifndef _LINUX_PT_MM_H
+#define _LINUX_PT_MM_H 1
+
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+
+/*
+ * The following ifdef needed to get the 4level-fixup.h header to work.
+ * Remove it when 4level-fixup.h has been removed.
+ */
+#if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+{
+	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
+		NULL: pud_offset(pgd, address);
+}
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
+		NULL: pmd_offset(pud, address);
+}
+#endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
+
+static inline pmd_t *lookup_pmd(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_none_or_clear_bad(pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none_or_clear_bad(pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none_or_clear_bad(pmd))
+		return NULL;
+
+	return pmd;
+}
+
+static inline pmd_t *build_pmd(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd=NULL;
+
+	pgd = pgd_offset(mm, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return NULL;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return NULL;
+
+	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
+		return NULL;
+
+	return pmd;
+}
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+/*
+ * We tuck a spinlock to guard each pagetable page into its struct page,
+ * at page->private, with BUILD_BUG_ON to make sure that this will not
+ * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
+ * When freeing, reset page->mapping so free_pages_check won't complain.
+ */
+#define __pte_lockptr(page)	&((page)->ptl)
+#define pte_lock_init(_page)	do {					\
+	spin_lock_init(__pte_lockptr(_page));				\
+} while (0)
+#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
+#else
+/*
+ * We use mm->page_table_lock to guard all pagetable pages of the mm.
+ */
+#define pte_lock_init(page)	do {} while (0)
+#define pte_lock_deinit(page)	do {} while (0)
+#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
+#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
+
+#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
+	pte_t *__pte = pte_offset_map(pmd, address);	\
+	*(ptlp) = __ptl;				\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
+#define pte_unmap_unlock(pte, ptl)	do {		\
+	spin_unlock(ptl);				\
+	pte_unmap(pte);					\
+} while (0)
+
+#define pte_alloc_map(mm, pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map(pmd, address))
+
+#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
+
+#define pte_alloc_kernel(pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+		NULL: pte_offset_kernel(pmd, address))
+
+
+#endif
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 23:56:33.707061712 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 23:56:57.978371912 +1000
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
-				unsigned long floor, unsigned long ceiling)
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
-				unsigned long floor, unsigned long ceiling)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
