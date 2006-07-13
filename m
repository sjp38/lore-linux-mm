From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:10 +1000
Message-Id: <20060713042710.9978.65098.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/18] PTI - Abstract default page table
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

This patch does the following:
1) Continues page table abstraction from memory.c to pt-default.c
 * More allocations functions moved across.
 * Page table deallocation iterator put into pt-default.c
 * Removed free_pgd_range prototype from mm.h
2) Calls coallesce vmas in free_pgtables to remove direct reference 
to PMD_SIZE.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/mm.h |    2 
 mm/memory.c        |   53 ---------------
 mm/pt-default.c    |  182 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 185 insertions(+), 52 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-09 00:06:01.159110960 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-09 00:06:01.707027664 +1000
@@ -252,23 +252,10 @@
 		anon_vma_unlink(vma);
 		unlink_file_vma(vma);
 
-		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		} else {
-			/*
-			 * Optimization: gather nearby vmas into one call down
-			 */
-			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
-			       && !is_vm_hugetlb_page(next)) {
-				vma = next;
-				next = vma->vm_next;
-				anon_vma_unlink(vma);
-				unlink_file_vma(vma);
-			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+		coallesce_vmas(&vma, &next);
+
+		free_page_table_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
-		}
 		vma = next;
 	}
 }
@@ -2216,40 +2203,6 @@
 
 EXPORT_SYMBOL_GPL(__handle_mm_fault);
 
-#ifndef __PAGETABLE_PMD_FOLDED
-/*
- * Allocate page middle directory.
- * We've already handled the fast-path in-line.
- */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	pmd_t *new = pmd_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-#ifndef __ARCH_HAS_4LEVEL_HACK
-	if (pud_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pud_populate(mm, pud, new);
-#else
-	if (pgd_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pgd_populate(mm, pud, new);
-#endif /* __ARCH_HAS_4LEVEL_HACK */
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-#else
-/* Workaround for gcc 2.96 */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	return 0;
-}
-#endif /* __PAGETABLE_PMD_FOLDED */
-
 int make_pages_present(unsigned long addr, unsigned long end)
 {
 	int ret, len, write;
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-09 00:06:01.149112480 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-09 00:06:01.707027664 +1000
@@ -42,6 +42,154 @@
 	pmd_clear(pmd);
 }
 
+/*
+ * Note: this doesn't free the actual pages themselves. That
+ * has been handled earlier when unmapping all the memory regions.
+ */
+static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+	pmd_clear(pmd);
+	pte_lock_deinit(page);
+	pte_free_tlb(tlb, page);
+	dec_page_state(nr_page_table_pages);
+	tlb->mm->nr_ptes--;
+}
+
+static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long ceiling)
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
+				unsigned long floor, unsigned long ceiling)
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
+void free_page_table_range(struct mmu_gather **tlb,
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
+	if (!(*tlb)->fullmm)
+		flush_tlb_pgtables((*tlb)->mm, start, end);
+}
+
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
 	struct page *new = pte_alloc_one(mm, address);
@@ -103,3 +251,37 @@
 	return 0;
 }
 #endif /* __PAGETABLE_PUD_FOLDED */
+
+#ifndef __PAGETABLE_PMD_FOLDED
+/*
+ * Allocate page middle directory.
+ * We've already handled the fast-path in-line.
+ */
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	pmd_t *new = pmd_alloc_one(mm, address);
+	if (!new)
+		return -ENOMEM;
+
+	spin_lock(&mm->page_table_lock);
+#ifndef __ARCH_HAS_4LEVEL_HACK
+	if (pud_present(*pud))		/* Another has populated it */
+		pmd_free(new);
+	else
+		pud_populate(mm, pud, new);
+#else
+	if (pgd_present(*pud))		/* Another has populated it */
+		pmd_free(new);
+	else
+		pgd_populate(mm, pud, new);
+#endif /* __ARCH_HAS_4LEVEL_HACK */
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+#else
+/* Workaround for gcc 2.96 */
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	return 0;
+}
+#endif /* __PAGETABLE_PMD_FOLDED */
Index: linux-2.6.17.2/include/linux/mm.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/mm.h	2006-07-09 00:06:00.654187720 +1000
+++ linux-2.6.17.2/include/linux/mm.h	2006-07-09 00:06:01.714026600 +1000
@@ -702,8 +702,6 @@
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
-		unsigned long end, unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
