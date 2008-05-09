Subject: [RFC/PATCH 2/2] MM: Make Page Tables Relocatable --relcoation code
Message-Id: <20080509135107.28D11DCA63@localhost>
Date: Fri,  9 May 2008 06:51:07 -0700 (PDT)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: rossb@google.com
List-ID: <linux-mm.kvack.org>

-----

Forgot to mention in the last part, major changes from previous version are
support for copying accessed/dirty bits and it at least compiles and should
work with 2 and 3 level page tables as well as 4 level page tables.

diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/fault.c 2.6.25-rc9/arch/powerpc/mm/fault.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/fault.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/powerpc/mm/fault.c	2008-04-14 09:00:29.000000000 -0700
@@ -299,6 +299,8 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
+
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c 2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c	2008-04-14 09:00:29.000000000 -0700
@@ -73,6 +73,7 @@ static int __hugepte_alloc(struct mm_str
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_hpd(&hpdp, mm, address);
 	if (!hugepd_none(*hpdp))
 		kmem_cache_free(huge_pgtable_cache, new);
 	else
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/fault.c 2.6.25-rc9/arch/ppc/mm/fault.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/fault.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/ppc/mm/fault.c	2008-04-14 09:00:29.000000000 -0700
@@ -219,6 +219,7 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/hugetlbpage.c 2.6.25-rc9/arch/x86/mm/hugetlbpage.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/hugetlbpage.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/x86/mm/hugetlbpage.c	2008-04-14 09:00:29.000000000 -0700
@@ -88,6 +88,7 @@ static void huge_pmd_share(struct mm_str
 		goto out;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, addr);
 	if (pud_none(*pud))
 		pud_populate(mm, pud, (pmd_t *)((unsigned long)spte & PAGE_MASK));
 	else
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/pgtable_32.c 2.6.25-rc9/arch/x86/mm/pgtable_32.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/pgtable_32.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/x86/mm/pgtable_32.c	2008-05-08 07:53:51.000000000 -0700
@@ -178,25 +178,6 @@ void reserve_top_address(unsigned long r
 	__VMALLOC_RESERVE += reserve;
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-}
-
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
-{
-	struct page *pte;
-
-#ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
-#else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-#endif
-	if (pte)
-		pgtable_page_ctor(pte);
-	return pte;
-}
-
 /*
  * List of all pgd's needed for non-PAE so it can invalidate entries
  * in both cached and uncached pgd's; not needed for PAE since the
@@ -218,7 +199,12 @@ static inline void pgd_list_del(pgd_t *p
 {
 	struct page *page = virt_to_page(pgd);
 
-	list_del(&page->lru);
+	list_del_init(&page->lru);
+}
+
+void arch_cleanup_pgd_page(pgd_t *pgd)
+{
+	pgd_list_del(pgd);
 }
 
 #define UNSHARED_PTRS_PER_PGD				\
@@ -340,9 +326,47 @@ static void pgd_mop_up_pmds(struct mm_st
 }
 #endif	/* CONFIG_X86_PAE */
 
-pgd_t *pgd_alloc(struct mm_struct *mm)
+#define PAGE_ALLOC(node) alloc_pages_node(node, GFP_KERNEL |__GFP_REPEAT, 0)
+#define PAGE_ALLOC_ZEROED(node)  alloc_pages_node(node, \
+			GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0)
+#define PAGE_ALLOC_ZEROED_HIGH(node)  alloc_pages_node(node, \
+		__GFP_HIGHMEM | GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0)
+
+pte_t *pte_alloc_one_kernel_node(struct mm_struct *mm,
+				 unsigned long address, int node)
 {
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+	return (pte_t *)page_address(PAGE_ALLOC_ZEROED(node));
+}
+
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return pte_alloc_one_kernel_node(mm, address, -1);
+}
+
+pgtable_t pte_alloc_one_node(struct mm_struct *mm, unsigned long address,
+			     int node)
+{
+	struct page *pte;
+
+#ifdef CONFIG_HIGHPTE
+	pte = page_address(PAGE_ALLOC_ZEROED_HIGHMEM(node));
+#else
+	pte = page_address(PAGE_ALLOC_ZEROED(node));
+#endif
+	if (pte)
+		pgtable_page_ctor(pte);
+	return pte;
+}
+
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+
+{
+	return pte_alloc_one_node(mm, address, -1);
+}
+
+pgd_t *pgd_alloc_node(struct mm_struct *mm, int node)
+{
+	pgd_t *pgd = (pgd_t *)page_address(PAGE_ALLOC(node));
 
 	/* so that alloc_pd can use it */
 	mm->pgd = pgd;
@@ -358,6 +382,11 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 }
 
+pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return pgd_alloc_node(mm, -1);
+}
+
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	pgd_mop_up_pmds(mm, pgd);
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h 2.6.25-rc9/include/asm-generic/pgalloc.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.25-rc9/include/asm-generic/pgalloc.h	2008-05-08 09:19:38.000000000 -0700
@@ -0,0 +1,98 @@
+#ifndef _ASM_GENERIC_PGALLOC_H
+#define _ASM_GENERIC_PGALLOC_H
+
+/* Page Table Levels used for alloc_page_table. */
+enum {
+	PAGE_TABLE_PGD,
+	PAGE_TABLE_PUD,
+	PAGE_TABLE_PMD,
+	PAGE_TABLE_PTE,
+};
+
+static inline struct page *alloc_page_table_node(struct mm_struct *mm,
+						 unsigned long addr,
+						 int node,
+						 int page_table_level)
+{
+	switch (page_table_level) {
+	case PAGE_TABLE_PGD:
+		return virt_to_page(pgd_alloc_node(mm, node));
+
+	case PAGE_TABLE_PUD:
+		return virt_to_page(pud_alloc_one_node(mm, addr, node));
+
+	case PAGE_TABLE_PMD:
+		return virt_to_page(pmd_alloc_one_node(mm, addr, node));
+
+	case PAGE_TABLE_PTE:
+		return pte_alloc_one_node(mm, addr, node);
+
+	default:
+		BUG();
+		return NULL;
+	}
+}
+
+static inline void free_page_table_page(struct mm_struct *mm,
+					struct page *page,
+					int page_table_level)
+{
+	page->migrated_page = NULL;
+	reset_page_mapcount(page);
+	switch (page_table_level) {
+	case PAGE_TABLE_PGD:
+		pgd_free(mm, page_address(page));
+		return;
+
+	case PAGE_TABLE_PUD:
+		pud_free(mm, page_address(page));
+		return;
+
+	case PAGE_TABLE_PMD:
+		pmd_free(mm, page_address(page));
+		return;
+
+	case PAGE_TABLE_PTE:
+		pte_free(mm, (pgtable_t)page);
+		return;
+
+	default:
+		BUG();
+		return;
+	}
+}
+
+
+/* The cleanup functions are called as soon as the page is
+ * no longer being used as a page table, but it could be a while
+ * before the page is freed.  These functions *MUST* clean up
+ * any non-global links to the page table, such as the pgd_list on
+ * x86 systems.
+ */
+#ifndef __HAVE_ARCH_CLEANUP_PGD_PAGE
+static inline void arch_cleanup_pgd_page(pgd_t *pgd)
+{
+}
+#endif
+
+
+#ifndef __HAVE_ARCH_CLEANUP_PUD_PAGE
+static inline void arch_cleanup_pud_page(pud_t *pud)
+{
+}
+#endif
+
+#ifndef __HAVE_ARCH_CLEANUP_PMD_PAGE
+static inline void arch_cleanup_pmd_page(pmd_t *pmd)
+{
+}
+#endif
+
+#ifndef __HAVE_ARCH_CLEANUP_PTE_PAGE
+static inline void arch_cleanup_pte_page(pte_t *pte)
+{
+}
+#endif
+
+
+#endif /* _ASM_GENERIC_PGALLOC_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h 2.6.25-rc9/include/asm-generic/pgtable.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-generic/pgtable.h	2008-05-05 07:36:27.000000000 -0700
@@ -4,6 +4,8 @@
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
+#include <linux/sched.h>
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Largely same as above, but only sets the access flags (dirty,
@@ -195,6 +197,22 @@ static inline int pmd_none_or_clear_bad(
 	}
 	return 0;
 }
+
+
+/* Copy the bits that the cpu could have modified. */
+#ifndef __HAVE_ARCH_COPY_CPU_BITS_PTE
+static inline void arch_copy_cpu_bits_pte(pte_t *old, pte_t *new)
+{
+}
+#endif
+
+/* Clear the bits that the cpu could have modified. */
+#ifndef __HAVE_ARCH_CLEAR_CPU_BITS_PTE
+static inline void arch_clear_cpu_bits_pte(pte_t *old)
+{
+}
+#endif
+
 #endif /* CONFIG_MMU */
 
 /*
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_32.h 2.6.25-rc9/include/asm-x86/pgalloc_32.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_32.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-x86/pgalloc_32.h	2008-05-08 07:52:06.000000000 -0700
@@ -37,11 +37,11 @@ static inline void pmd_populate(struct m
  * Allocate and free page tables.
  */
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
-
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
+
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
@@ -60,6 +60,16 @@ extern void __pte_free_tlb(struct mmu_ga
 /*
  * In the PAE case we free the pmds as part of the pgd.
  */
+
+#ifdef CONFIG_NUMA
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	return (pmd_t *)page_address(alloc_pages_node(node,
+			 GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0));
+}
+#endif
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
@@ -90,6 +100,33 @@ static inline void pud_populate(struct m
 	if (mm == current->active_mm)
 		write_cr3(read_cr3());
 }
+#else 	/* CONFIG_X86_PAE */
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	BUG();
+	return NULL;
+}
+
 #endif	/* CONFIG_X86_PAE */
 
+
+#define __HAVE_ARCH_CLEANUP_PGD_PAGE
+extern void arch_cleanup_pgd_page(pgd_t *pgd);
+
+#ifdef CONFIG_NUMA
+extern pgd_t *pgd_alloc_node(struct mm_struct *, int node);
+extern pte_t *pte_alloc_one_kernel_node(struct mm_struct *, unsigned long,
+					int node);
+extern pgtable_t pte_alloc_one_node(struct mm_struct *, unsigned long,
+				    int node);
+static inline pud_t *pud_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	BUG();
+	return NULL;
+}
+#endif
+
+#include <asm-generic/pgalloc.h>
 #endif /* _I386_PGALLOC_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h 2.6.25-rc9/include/asm-x86/pgalloc_64.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-05-08 08:39:54.000000000 -0700
@@ -4,6 +4,7 @@
 #include <asm/pda.h>
 #include <linux/threads.h>
 #include <linux/mm.h>
+#include <linux/gfp.h>
 
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
@@ -25,16 +26,6 @@ static inline void pmd_free(struct mm_st
 	free_page((unsigned long)pmd);
 }
 
-static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
-{
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-}
-
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-}
-
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
@@ -61,10 +52,50 @@ static inline void pgd_list_del(pgd_t *p
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+{
+	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
+	pgd_list_del(pgd);
+	free_page((unsigned long)pgd);
+}
+
+
+/* Should really implement gc for free page table pages. This could be
+   done with a reference count in struct page. */
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
+{
+	pgtable_page_dtor(pte);
+	__free_page(pte);
+}
+
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor((pte));				\
+	tlb_remove_page((tlb), (pte));			\
+} while (0)
+
+#define __pmd_free_tlb(tlb, x)   tlb_remove_page((tlb), virt_to_page(x))
+#define __pud_free_tlb(tlb, x)   tlb_remove_page((tlb), virt_to_page(x))
+
+#define PAGE_ALLOC(node) alloc_pages_node(node, GFP_KERNEL |__GFP_REPEAT, 0)
+#define PAGE_ALLOC_ZEROED(node)  alloc_pages_node(node, \
+			GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0)
+
+/* The _node versions should effectively go away when config_numa is not
+ * defined.
+ */
+
+static inline pgd_t *pgd_alloc_node(struct mm_struct *mm, int node)
 {
 	unsigned boundary;
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pgd_t *pgd = (pgd_t *)page_address(PAGE_ALLOC(node));
 	if (!pgd)
 		return NULL;
 	pgd_list_add(pgd);
@@ -81,53 +112,74 @@ static inline pgd_t *pgd_alloc(struct mm
 	return pgd;
 }
 
-static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+static inline pte_t *pte_alloc_one_kernel_node(struct mm_struct *mm,
+					       unsigned long address, int node)
 {
-	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
-	pgd_list_del(pgd);
-	free_page((unsigned long)pgd);
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
-{
-	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pte_t *)page_address(PAGE_ALLOC_ZEROED(node));
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pgtable_t pte_alloc_one_node(struct mm_struct *mm,
+					   unsigned long address, int node)
 {
 	struct page *page;
-	void *p;
 
-	p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-	if (!p)
+	page = PAGE_ALLOC_ZEROED(node);
+	if (!page)
 		return NULL;
-	page = virt_to_page(p);
 	pgtable_page_ctor(page);
 	return page;
 }
 
-/* Should really implement gc for free page table pages. This could be
-   done with a reference count in struct page. */
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	return (pmd_t *)page_address(PAGE_ALLOC_ZEROED(node));
+}
 
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+static inline pud_t *pud_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
 {
-	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	return (pud_t *)page_address(PAGE_ALLOC_ZEROED(node));
 }
 
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
+static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	pgtable_page_dtor(pte);
-	__free_page(pte);
+	return pmd_alloc_one_node(mm, addr, -1);
 } 
 
-#define __pte_free_tlb(tlb,pte)				\
-do {							\
-	pgtable_page_dtor((pte));				\
-	tlb_remove_page((tlb), (pte));			\
-} while (0)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pud_alloc_one_node(mm, addr, -1);
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return pte_alloc_one_kernel_node(mm, address, -1);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+				      unsigned long address)
+{
+	return pte_alloc_one_node(mm, address, -1);
+}
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return pgd_alloc_node(mm, -1);
+}
+
+
+#undef PAGE_ALLOC
+#undef PAGE_ALLOC_ZEROED
+
+#define __HAVE_ARCH_CLEANUP_PGD_PAGE
+static inline void arch_cleanup_pgd_page(pgd_t *pgd)
+{
+	pgd_list_del(pgd);
+}
+
+#include <asm-generic/pgalloc.h>
 
-#define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
-#define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 
 #endif /* _X86_64_PGALLOC_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgtable.h 2.6.25-rc9/include/asm-x86/pgtable.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgtable.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-x86/pgtable.h	2008-05-05 07:00:10.000000000 -0700
@@ -364,6 +364,19 @@ static inline void ptep_set_wrprotect(st
 	pte_update(mm, addr, ptep);
 }
 
+#define __HAVE_ARCH_COPY_CPU_BITS_PTE
+static inline void arch_copy_cpu_bits_pte(pte_t *old, pte_t *new)
+{
+	set_pte(new, __pte(pte_val(*new) |
+			   (pte_val(*old) & (_PAGE_DIRTY | _PAGE_ACCESSED))));
+}
+
+#define __HAVE_ARCH_CLEAR_CPU_BITS_PTE
+static inline void arch_clear_cpu_bits_pte(pte_t *old)
+{
+	*old = __pte(pte_val(*old) & ~(_PAGE_DIRTY | _PAGE_ACCESSED));
+}
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/migrate.h 2.6.25-rc9/include/linux/migrate.h
--- /home/rossb/local/linux-2.6.25-rc9/include/linux/migrate.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/linux/migrate.h	2008-04-14 09:00:29.000000000 -0700
@@ -6,6 +6,10 @@
 #include <linux/pagemap.h>
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
+typedef struct page *new_page_table_t(struct mm_struct *,
+				      unsigned long addr,
+				      unsigned long private,
+				      int **, int page_table_level);
 
 #ifdef CONFIG_MIGRATION
 /* Check if a vma is migratable */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/mm.h 2.6.25-rc9/include/linux/mm.h
--- /home/rossb/local/linux-2.6.25-rc9/include/linux/mm.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/linux/mm.h	2008-05-06 06:18:51.000000000 -0700
@@ -921,6 +921,7 @@ static inline void pgtable_page_dtor(str
 	pte_t *__pte = pte_offset_map(pmd, address);	\
 	*(ptlp) = __ptl;				\
 	spin_lock(__ptl);				\
+	delimbo_pte(&__pte, ptlp, &pmd, mm, address);	\
 	__pte;						\
 })
 
@@ -945,6 +946,158 @@ extern void free_area_init(unsigned long
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
 	unsigned long * zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size);
+
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+
+void _delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+		  struct mm_struct *mm,  unsigned long addr);
+void _delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
+			 pmd_t **pmd, struct mm_struct *mm,
+			 unsigned long addr, int subclass, spinlock_t *optl);
+void _delimbo_pud(pud_t **pud, struct mm_struct *mm, unsigned long addr);
+void _delimbo_pmd(pmd_t **pmd, struct mm_struct *mm, unsigned long addr);
+void _delimbo_pgd(pgd_t **pgd, struct mm_struct *mm, unsigned long addr);
+void _delimbo_huge_pte(pte_t **pte, struct mm_struct *mm, unsigned long addr);
+
+
+/* We say a page table is in limbo if it's been copied, but the old copy
+ * could still be in use by a kernel thread or a cpu.  The delimbo
+ * functions make sure the new page table is up to date and that
+ * everyone is looking at it.
+ */
+
+static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+			  struct mm_struct *mm,
+			  unsigned long addr)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* If split page table locks are being used, we don't actually
+	 * have the correct spinlock here, but it's ok since the
+	 * relocation code won't go mucking with the relevant level of
+	 * the page table while holding the relevant spinlock.  This
+	 * means that while all the page tables leading up to this one
+	 * could get mucked with, the one we care about cannot be
+	 * mucked with without us seeing that
+	 * page_table_relocation_count has be set.
+	 * 
+	 * The code path is something like
+	 * grab page table lock
+	 * increment relocation count
+	 * release page_table lock
+	 *
+	 * At this point, we might have missed the increment
+	 * because we have the wrong lock. 
+	 *
+	 * Grab page table lock.
+	 * Grab split page table lock. <-- This lock saves us.
+	 * muck with page table.
+	 *
+	 * But it's ok, because even if we get interrupted for a
+	 * long time, the page table we care about won't be mucked
+	 * with until after we drop the spinlock that we do have.
+	 */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pte(pte, ptl, pmd, mm, addr);
+}
+
+static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
+				      pmd_t **pmd, struct mm_struct *mm,
+				      unsigned long addr, int subclass,
+				      spinlock_t *optl)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* same as comment above about the locking issue with
+	 * this test.
+	 */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pte_nested(pte, ptl, pmd, mm, addr, subclass, optl);
+}
+
+
+static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
+			  unsigned long addr)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* At this point we have the page_table_lock. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pud(pud, mm, addr);
+}
+
+static inline void delimbo_pmd(pmd_t **pmd,  struct mm_struct *mm,
+			       unsigned long addr)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* we hold the page_table_lock, so this is safe to test. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pmd(pmd, mm, addr);
+}
+
+static inline void delimbo_pgd(pgd_t **pgd,  struct mm_struct *mm,
+			       unsigned long addr)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* we hold the page_table_lock. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pgd(pgd, mm, addr);
+}
+
+
+static inline void delimbo_huge_pte(pte_t **pte,  struct mm_struct *mm,
+				    unsigned long addr)
+{
+	/* We don't mess with kernel page tables, so if we are
+	 * looking at init_mm, we don't have to do anything.
+	 */
+	if (__builtin_constant_p(mm) && mm == &init_mm)
+		return;
+
+	/* We hold the page_table_lock. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_huge_pte(pte, mm, addr);
+}
+
+#else /* CONFIG_RELOCATE_PAGE_TABLES */
+static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+			       struct mm_struct *mm,  unsigned long addr) {}
+static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
+				      pmd_t **pmd, struct mm_struct *mm,
+				      unsigned long addr, int subclass,
+				      spinlock_t *optl) {}
+static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
+			       unsigned long addr) {}
+static inline void delimbo_pmd(pmd_t **pmd, struct mm_struct *mm,
+			       unsigned long addr) {}
+static inline void delimbo_pgd(pgd_t **pgd, struct mm_struct *mm,
+			       unsigned long addr) {}
+static inline void delimbo_huge_pte(pte_t **pte, struct mm_struct *mm,
+				    unsigned long addr) {}
+#endif /* CONFIG_RELOCATE_PAGE_TABLES */
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 /*
  * With CONFIG_ARCH_POPULATES_NODE_MAP set, an architecture may initialise its
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/mm_types.h 2.6.25-rc9/include/linux/mm_types.h
--- /home/rossb/local/linux-2.6.25-rc9/include/linux/mm_types.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/linux/mm_types.h	2008-05-07 07:01:01.000000000 -0700
@@ -10,6 +10,8 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
+#include <linux/rcupdate.h>
+#include <linux/workqueue.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -43,6 +45,9 @@ struct page {
 					 * & limit reverse map searches.
 					 */
 		unsigned int inuse;	/* SLUB: Nr of objects */
+		int page_table_type;	/* Used to keep track of the type of
+					 * page table so we can clean it up.
+					 */
 	};
 	union {
 	    struct {
@@ -70,7 +75,12 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		struct page *migrated_page; /* The page this page
+					     * table has been migrated to
+					     * or from.
+					     */
 	};
+
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
@@ -173,7 +183,16 @@ struct mm_struct {
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
+	unsigned long flags; /* Must use atomic bitops to access the bits */
+
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+	/* The number of page table relocations currently happening on
+	 * this mm.  Only updated/checked while holding the page_table_lock,
+	 * so doesn't need to be an atomic_t.
+	 */
+	int page_table_relocation_count;
+#endif /* CONFIG_RELOCATE_PAGE_TABLES */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -213,8 +232,6 @@ struct mm_struct {
 	unsigned int token_priority;
 	unsigned int last_interval;
 
-	unsigned long flags; /* Must use atomic bitops to access the bits */
-
 	/* coredumping support */
 	int core_waiters;
 	struct completion *core_startup_done, core_done;
@@ -225,6 +242,9 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+	struct mutex page_table_relocation_lock;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c 2.6.25-rc9/kernel/fork.c
--- /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/kernel/fork.c	2008-05-07 07:01:45.000000000 -0700
@@ -360,6 +360,11 @@ static struct mm_struct * mm_init(struct
 	mm->cached_hole_size = ~0UL;
 	mm_init_cgroup(mm, p);
 
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+	mm->page_table_relocation_count = 0;
+	mutex_init(&mm->page_table_relocation_lock);
+#endif
+
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig 2.6.25-rc9/mm/Kconfig
--- /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/Kconfig	2008-05-08 07:34:15.000000000 -0700
@@ -143,6 +143,10 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config RELOCATE_PAGE_TABLES 
+	def_bool y
+	depends on X86 && MIGRATION
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/hugetlb.c 2.6.25-rc9/mm/hugetlb.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/hugetlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/hugetlb.c	2008-04-14 09:01:16.000000000 -0700
@@ -762,6 +762,8 @@ int copy_hugetlb_page_range(struct mm_st
 
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
+		delimbo_huge_pte(&src_pte, src, addr);
+		delimbo_huge_pte(&dst_pte, dst, addr);
 		if (!pte_none(*src_pte)) {
 			if (cow)
 				ptep_set_wrprotect(src, addr, src_pte);
@@ -937,6 +939,7 @@ retry:
 	}
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
@@ -994,6 +997,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 	ret = 0;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (likely(pte_same(entry, *ptep)))
 		if (write_access && !pte_write(entry))
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/memory.c 2.6.25-rc9/mm/memory.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/memory.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/memory.c	2008-04-15 08:02:48.000000000 -0700
@@ -312,6 +312,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pmd(&pmd, mm, address);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		mm->nr_ptes++;
 		pmd_populate(mm, pmd, new);
@@ -330,6 +331,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 		return -ENOMEM;
 
 	spin_lock(&init_mm.page_table_lock);
+	delimbo_pmd(&pmd, &init_mm, address);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
@@ -513,6 +515,9 @@ again:
 	src_pte = pte_offset_map_nested(src_pmd, addr);
 	src_ptl = pte_lockptr(src_mm, src_pmd);
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	delimbo_pte_nested(&src_pte, &src_ptl, &src_pmd, src_mm, addr,
+			   SINGLE_DEPTH_NESTING, dst_ptl);
 	arch_enter_lazy_mmu_mode();
 
 	do {
@@ -1488,13 +1493,15 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * and do_anonymous_page and do_no_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+				pte_t *page_table, pte_t orig_pte,
+				unsigned long address)
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	if (sizeof(pte_t) > sizeof(unsigned long)) {
 		spinlock_t *ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
+		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
 		same = pte_same(*page_table, orig_pte);
 		spin_unlock(ptl);
 	}
@@ -2021,7 +2028,7 @@ static int do_swap_page(struct mm_struct
 	pte_t pte;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
@@ -2100,6 +2107,10 @@ static int do_swap_page(struct mm_struct
 	}
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
@@ -2151,6 +2162,10 @@ static int do_anonymous_page(struct mm_s
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
@@ -2312,6 +2327,10 @@ static int __do_fault(struct mm_struct *
 		}
 
 		/* no need to invalidate: a not-present page won't be cached */
+		/* Unless of course the cpu could be looking at an old page
+		   table entry. */
+		maybe_reload_tlb_mm(mm);
+
 		update_mmu_cache(vma, address, entry);
 	} else {
 		mem_cgroup_uncharge_page(page);
@@ -2418,7 +2437,7 @@ static int do_nonlinear_fault(struct mm_
 				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		return 0;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
@@ -2477,6 +2496,7 @@ static inline int handle_pte_fault(struc
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
@@ -2498,6 +2518,12 @@ static inline int handle_pte_fault(struc
 		if (write_access)
 			flush_tlb_page(vma, address);
 	}
+
+	/* if the cpu could be looking at an old page table, we need to
+	   flush out everything. */
+	maybe_reload_tlb_mm(mm);
+
+
 unlock:
 	pte_unmap_unlock(pte, ptl);
 	return 0;
@@ -2547,6 +2573,7 @@ int __pud_alloc(struct mm_struct *mm, pg
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pgd(&pgd, mm, address);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(mm, new);
 	else
@@ -2568,6 +2595,7 @@ int __pmd_alloc(struct mm_struct *mm, pu
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, address);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
 		pmd_free(mm, new);
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/mempolicy.c 2.6.25-rc9/mm/mempolicy.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/mempolicy.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/mempolicy.c	2008-04-14 09:00:29.000000000 -0700
@@ -101,6 +101,12 @@
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+int migrate_page_tables_mm(struct mm_struct *mm,  int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private);
+#endif
+
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
 enum zone_type policy_zone = 0;
@@ -627,6 +633,20 @@ static struct page *new_node_page(struct
 	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+static struct page *new_node_page_page_tables(struct mm_struct *mm,
+					      unsigned long addr,
+					      unsigned long node,
+					      int **x,
+					      int level)
+{
+	struct page *p;
+	p = alloc_page_table_node(mm, addr, node, level);
+	return p;
+}
+
+#endif /* CONFIG_RELOCATE_PAGE_TABLES  */
+
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -647,6 +667,12 @@ static int migrate_to_node(struct mm_str
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest);
 
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+	if (!err)
+		err = migrate_page_tables_mm(mm, source,
+					     new_node_page_page_tables, dest);
+#endif /* CONFIG_RELOCATE_PAGE_TABLES */
+
 	return err;
 }
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/migrate.c 2.6.25-rc9/mm/migrate.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/migrate.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/migrate.c	2008-05-08 09:34:53.000000000 -0700
@@ -30,9 +30,19 @@
 #include <linux/vmalloc.h>
 #include <linux/security.h>
 #include <linux/memcontrol.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 
 #include "internal.h"
 
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private);
+
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -155,6 +165,7 @@ static void remove_migration_pte(struct 
 
  	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
+	delimbo_pte(&ptep, &ptl, &pmd, mm, addr);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -895,9 +906,10 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 	else
-		err = -ENOENT;
+		err = 0;
 
 	up_read(&mm->mmap_sem);
+
 	return err;
 }
 
@@ -1075,3 +1087,793 @@ int migrate_vmas(struct mm_struct *mm, c
  	}
  	return err;
 }
+
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+
+/*
+ * Code to relocate live page tables.  The strategy is simple.  We
+ * allow that either the kernel or the cpus could be looking at or
+ * have cached a stale page table.  We just make sure that the kernel
+ * only updates the latest version of the page tables and that we
+ * flush the page table cache anytime a cpu could be looking at a
+ * stale page table and it might matter.
+ *
+ * Since we have to worry about the kernel and cpu's separately,
+ * it's important to distinguish between what the cpu is doing internally
+ * and what the kernel is doing on a cpu.  We use cpu for the former and
+ * thread for the latter.
+ *
+ * This is easier than it might seems since most of the code is
+ * already there.  The kernel never updates a page table without first
+ * grabbing an appropriate spinlock.  Then it has to double
+ * check to make sure that another thread hasn't already changed things.
+ * So all we have to do is rewalk all the page tables whenever we
+ * grab the spinlock. Then the existing double check code takes care
+ * of the rest (except for kernel page tables which are often updated
+ * without locks.  So we just don't muck with kernel page tables.)
+ *
+ * For the cpus, it's just important to flush the TLB cache whenever it
+ * might be relevant.  To avoid unnecessary TLB cache thrashing, we only
+ * flush the TLB caches when we are done with all the changes, or it could
+ * make a difference.  We already have to flush the TLB caches whenever it
+ * could make a difference, except in the cases where we are updating
+ * something the cpu wouldn't normally cache.  The only place this happens,
+ * is when we have a page was non-present.  The cpu won't cache that
+ * particular entry, but it might be caching stale page tables leading
+ * up to the non-present entry.  So we might need to flush everything
+ * where we didn't have to flush before.
+ *
+ * One last gotcha is that before the only way to change the top-level
+ * page table is to switch tasks.  So we had to add a reload
+ * tlb option.  This is per arch function and is not yet on all arches.
+ * For arches where we cannot reload the tlb, we cannot migrate the
+ * top level page table.
+ */
+
+
+/* Used to rewalk the page tables if after we grab the appropriate lock,
+ * we make sure we are not looking at a page table that's just waiting
+ * to go away.
+ * These are only used in the _delimbo* functions in mm/migrate.c
+ * so it's no big deal having them static inline.  Otherwise, they
+ * would just be in there anyway.
+ * XXXXX Why not just copy this into mm/migrate.c?
+ */
+static inline pgd_t *walk_page_table_pgd(struct mm_struct *mm,
+					  unsigned long addr)
+{
+	return pgd_offset(mm, addr);
+}
+
+static inline pud_t *walk_page_table_pud(struct mm_struct *mm,
+					 unsigned long addr) {
+	pgd_t *pgd;
+	pgd = walk_page_table_pgd(mm, addr);
+	BUG_ON(!pgd);
+#ifdef __PAGETABLE_PUD_FOLDED
+	return (pud_t *)pgd;
+#else
+	return pud_offset(pgd, addr);
+#endif
+}
+
+static inline pmd_t *walk_page_table_pmd(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pud_t *pud;
+	pud = walk_page_table_pud(mm, addr);
+	BUG_ON(!pud);
+#ifdef __PAGETABLE_PMD_FOLDED
+	return (pmd_t *)pud;
+#else
+	return  pmd_offset(pud, addr);
+#endif
+}
+
+static inline pte_t *walk_page_table_pte(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pmd_t *pmd;
+	pmd = walk_page_table_pmd(mm, addr);
+	BUG_ON(!pmd);
+	return pte_offset_map(pmd, addr);
+}
+
+static inline pte_t *walk_page_table_huge_pte(struct mm_struct *mm,
+					      unsigned long addr)
+{
+	return (pte_t *)walk_page_table_pmd(mm, addr);
+}
+
+/* A page table is in limbo if we can't be sure if we are looking
+ * at a current page table, or an old one.  The delimbo functions
+ * make sure we are looking at a current one and it's up to date.
+ */
+
+/* This function rewalks the page tables to make sure that
+ * a thread is not looking at a stale page table entry.
+ */
+void _delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+		  struct mm_struct *mm,  unsigned long addr)
+{
+	pte_t *old_pte, old_pte_val=__pte(0);
+	struct page *old_page, *new_page;
+
+	if (*ptl != &mm->page_table_lock) {
+		spin_unlock(*ptl);
+		spin_lock(&mm->page_table_lock);
+	}
+
+	/* We could check the page_table_relocation_count again
+	 * to make sure that it hasn't changed, but it's not a big win
+	 * and makes the code more complex since we have to make sure
+	 * we get the correct spinlock.
+	 */
+
+	pte_unmap(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+
+	/* if the pte was in limbo, we need to worry about
+	 * any cpu updated bits and copy them over.
+	 */
+	new_page = pmd_page(**pmd);
+	old_page = new_page->migrated_page;
+	if (old_page && old_page != new_page) {
+		/* Make sure the cpu won't be updating the
+		 * pte entry that's in limbo. 
+		 */
+		maybe_reload_tlb_mm(mm);
+		old_pte = pte_offset_map(*pmd, addr);
+		old_pte_val = *old_pte;
+		arch_clear_cpu_bits_pte(old_pte);
+		pte_unmap(old_pte);
+	}
+
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+
+	/* Update the dirty and accessed bits in the new pte.
+	 */
+	if (old_page && old_page != new_page)
+		arch_copy_cpu_bits_pte(&old_pte_val, *pte);
+
+	if (*ptl != &mm->page_table_lock) {
+		spin_lock(*ptl);
+		spin_unlock(&mm->page_table_lock);
+	}
+}
+
+void _delimbo_pte_nested(pte_t **pte, spinlock_t **ptl, pmd_t **pmd,
+			 struct mm_struct *mm, unsigned long addr,
+			 int subclass, spinlock_t *optl)
+{
+	pte_t *old_pte, old_pte_val=__pte(0);
+	struct page *old_page, *new_page;
+
+	if (&mm->page_table_lock != *ptl) {
+		if (optl != *ptl)
+			spin_unlock(*ptl);
+		spin_lock(&mm->page_table_lock);
+	}
+
+	pte_unmap_nested(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+
+	/* if the pte was in limbo, we need to worry about
+	 * any cpu updated bits and copy them over.
+	 */
+	new_page = pmd_page(**pmd);
+	old_page = new_page->migrated_page;
+	if (old_page && old_page != new_page) {
+		/* Make sure the cpu won't be updating the
+		 * pte entry that's in limbo. 
+		 */
+		maybe_reload_tlb_mm(mm);
+		old_pte = pte_offset_map_nested(*pmd, addr);
+		old_pte_val = *old_pte;
+		/* Don't want to update these bits again
+		 * later when we copy the entire page.
+		 */
+		arch_clear_cpu_bits_pte(old_pte);
+		pte_unmap(old_pte);
+	}
+
+
+	*pte = pte_offset_map_nested(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+
+	if (old_page && old_page != new_page) {
+		/* Update the dirty and accessed bits in
+		 * the new pte. 
+		 */
+		arch_copy_cpu_bits_pte(&old_pte_val, *pte);
+	}
+
+	if (&mm->page_table_lock != *ptl) {
+		if (optl != *ptl )
+			spin_lock_nested(*ptl, subclass);
+		spin_unlock(&mm->page_table_lock);
+	}
+}
+
+
+void _delimbo_pud(pud_t **pud, struct mm_struct *mm, unsigned long addr)
+{
+	*pud = walk_page_table_pud(mm, addr);
+}
+
+void _delimbo_pmd(pmd_t **pmd, struct mm_struct *mm, unsigned long addr)
+{
+	*pmd = walk_page_table_pmd(mm, addr);
+}
+
+void _delimbo_pgd(pgd_t **pgd, struct mm_struct *mm, unsigned long addr)
+{
+	*pgd = walk_page_table_pgd(mm, addr);
+}
+
+void _delimbo_huge_pte(pte_t **pte, struct mm_struct *mm, unsigned long addr)
+{
+	*pte = walk_page_table_huge_pte(mm, addr);
+}
+
+/*
+ * Clean up the pages, update any bits the cpu may have updated and
+ * free the page.
+ */
+void update_new_page_and_free(struct mm_struct *mm, struct page *old_page)
+{
+
+	int type;
+
+	/* Currently we only worry about cpu bits in ptes. */
+	if (old_page->page_table_type == PAGE_TABLE_PTE) {
+		struct page *new_page = old_page->migrated_page;
+		spinlock_t *ptl;
+		pte_t *old;
+		pte_t *new;
+		int i;
+#ifdef __pte_lockptr
+		ptl = __pte_lockptr(new_page);
+#else
+		ptl = &mm->page_table_lock;
+#endif
+		spin_lock(ptl);
+		old = (pte_t *)kmap_atomic(old_page, KM_PTE0);
+		new = (pte_t *)kmap_atomic(new_page, KM_PTE1);
+		for (i = 0; i < PTRS_PER_PTE; i++)
+			arch_copy_cpu_bits_pte(old, new);
+
+		kunmap_atomic(new_page, KM_PTE1);
+		kunmap_atomic(old_page, KM_PTE0);
+		new_page->migrated_page = NULL;
+		spin_unlock(ptl);
+	}
+
+	old_page->migrated_page = NULL;
+	type = old_page->page_table_type;
+	reset_page_mapcount(old_page);
+
+	free_page_table_page(mm, old_page, type);
+}
+
+/*
+ * Call this function to migrate a pgd to the page dest.
+ * mm is the mm struct that this pgd is part of and
+ * addr is the address for the pgd inside of the mm.
+ * Technically this only moves one page worth of pgd's
+ * starting with the pgd that represents addr.
+ *
+ * The page that contains the pgd will be added to the
+ * end of old_pages.  It should be freed by an rcu callback
+ * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
+ * to be called before the pages are freed.
+ *
+ * Calling this at interrupt time is bad because of the
+ * spinlocks.
+ *
+ * Returns the number of pages not migrated.
+ */
+static inline int migrate_top_level_page_table_entry(struct mm_struct *mm,
+					     struct page *dest,
+					     struct list_head *old_pages)
+{
+	pgd_t *dest_ptr;
+	int i;
+
+	if (sizeof(pgd_t) * PTRS_PER_PGD != PAGE_SIZE)
+		return 1;
+
+	BUG_ON ((unsigned long)(mm->pgd) & ~PAGE_MASK);
+
+	dest_ptr = (pgd_t *)page_address(dest);
+
+	spin_lock(&mm->page_table_lock);
+	for (i = 0; i < PTRS_PER_PGD; i++)
+		set_pgd(dest_ptr + i, mm->pgd[i]);
+
+	arch_cleanup_pgd_page(mm->pgd);
+
+	virt_to_page(mm->pgd)->page_table_type = PAGE_TABLE_PGD;
+
+	list_add_tail(&virt_to_page(mm->pgd)->lru, old_pages);
+
+	mm->pgd = (pgd_t *)dest_ptr;
+
+	maybe_need_tlb_reload_mm(mm);
+
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
+/*
+ * Call this function to migrate a pgd to the page dest.
+ * mm is the mm struct that this pgd is part of and
+ * addr is the address for the pgd inside of the mm.
+ * Technically this only moves one page worth of pud's
+ * starting with the pud that represents addr.
+ *
+ * The page that contains the pgd will be added to the
+ * end of old_pages.  It should be freed by an rcu callback
+ * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
+ * to be called before the pages are freed.
+ *
+ * Calling this at interrupt time is bad because of the
+ * spinlocks.
+ *
+ * Returns the number of pages not migrated.
+ */
+int migrate_pgd_entry(pgd_t *pgd, struct mm_struct *mm,
+		      unsigned long addr, struct page *dest,
+		      struct list_head *old_pages)
+{
+
+	pud_t *dest_pud;
+	pud_t *src_pud;
+	int i;
+
+	/* We currently only deal with full page puds. */
+	if (sizeof(pud_t) * PTRS_PER_PUD != PAGE_SIZE) {
+		return 1;
+	} 
+
+	spin_lock(&mm->page_table_lock);
+
+	_delimbo_pgd(&pgd, mm, addr);
+
+	src_pud = pud_offset(pgd, addr);
+
+	BUG_ON ((unsigned long)src_pud & ~PAGE_MASK);
+
+	dest_pud = (pud_t *)page_address(dest);
+	for (i = 0; i < PTRS_PER_PUD; i++)
+		set_pud(dest_pud + i, src_pud[i]);
+
+	pgd_page(*pgd)->page_table_type = PAGE_TABLE_PUD;
+
+	arch_cleanup_pud_page(src_pud);
+
+	list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
+	pgd_populate(mm, pgd, dest_pud);
+
+
+	maybe_need_flush_mm(mm);
+
+	spin_unlock(&mm->page_table_lock);
+
+	return 0;
+
+}
+
+
+/*
+ * Call this function to migrate a pud to the page dest.
+ * mm is the mm struct that this pud is part of and
+ * addr is the address for the pud inside of the mm.
+ * Technically this only moves one page worth of pmd's
+ * starting with the pmd that represents addr.
+ *
+ * The page that contains the pud will be added to the
+ * end of old_pages.  It should be freed by an rcu callback
+ * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
+ * to be called before the pages are freed.
+ *
+ * Calling this at interrupt time is bad because of the
+ * spinlocks.
+ *
+ * Returns the number of pages not migrated.
+ */
+int migrate_pud_entry(pud_t *pud, struct mm_struct *mm, unsigned long addr,
+		      struct page *dest, struct list_head *old_pages)
+{
+	pmd_t *dest_pmd;
+	pmd_t *src_pmd;
+	int i;
+
+	/* We currently only deal with full page puds. */
+	if (sizeof(pmd_t) * PTRS_PER_PMD != PAGE_SIZE) {
+		return 1;
+	} 
+
+	spin_lock(&mm->page_table_lock);
+
+	_delimbo_pud(&pud, mm, addr);
+	src_pmd = pmd_offset(pud, addr);
+	
+	BUG_ON((unsigned long)src_pmd & ~PAGE_MASK);
+
+	dest_pmd = (pmd_t *) page_address(dest);
+
+	for (i = 0; i < PTRS_PER_PMD; i++)
+		set_pmd(dest_pmd + i, src_pmd[i]);
+
+	pud_page(*pud)->page_table_type = PAGE_TABLE_PMD;
+
+	arch_cleanup_pmd_page(src_pmd);
+
+	list_add_tail(&(pud_page(*pud)->lru), old_pages);
+
+	pud_populate(mm, pud, dest_pmd);
+	maybe_need_flush_mm(mm);
+
+	spin_unlock(&mm->page_table_lock);
+
+	return 0;
+}
+
+/*
+ * Call this function to migrate a pmd to the page dest.
+ * mm is the mm struct that this pmd is part of and
+ * addr is the address for the pud inside of the mm.
+ * Technically this only moves one page worth of pte's
+ * starting with the pte that represents addr.
+ *
+ * The page that contains the pmd will be added to the
+ * end of old_pages.  It should be freed by an rcu callback
+ * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
+ * to be called before the pages are freed.
+ *
+ * Returns the number of pages not migrated.
+ *
+ * This function uses KM_PTE1.  Since it holds the
+ * page_table_lock, it should be safe.
+ *
+ * Calling this at interrupt time is bad because of the
+ * spinlocks.
+ */
+
+int migrate_pmd_entry(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
+		      struct page *dest, struct list_head *old_pages)
+{
+	pte_t *dest_pte;
+	spinlock_t *ptl;
+	pte_t *src_pte;
+	int i;
+
+	/* We currently only deal with full page ptes. */
+	if (sizeof(pte_t) * PTRS_PER_PTE != PAGE_SIZE) {
+		return 1;
+	} 
+
+	spin_lock(&mm->page_table_lock);
+
+	_delimbo_pmd(&pmd, mm, addr);
+
+	/* this could happen if the page table has been swapped out and we
+	   were looking at the old one. */
+	if (unlikely(!pmd_present(*pmd))) {
+		spin_unlock(&mm->page_table_lock);
+		return 1;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+
+	/* We need the page lock as well. */
+	if (ptl != &mm->page_table_lock)
+		spin_lock(ptl);
+
+	src_pte = pte_offset_map(pmd, addr);
+
+	BUG_ON ((unsigned long)src_pte & ~PAGE_MASK);
+
+	dest_pte = (pte_t *)kmap_atomic(dest, KM_PTE1);
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		set_pte(dest_pte + i, src_pte[i]);
+
+	dest->migrated_page = pmd_page(*pmd);
+	dest->migrated_page->page_table_type = PAGE_TABLE_PTE;
+	dest->migrated_page->migrated_page = dest;
+
+	arch_cleanup_pte_page(src_pte);
+
+	list_add_tail(&(pmd_page(*pmd)->lru), old_pages);
+
+	kunmap_atomic(dest, KM_PTE1);
+	pte_unmap(pte);
+	pte_lock_init(dest);
+	pmd_populate(mm, pmd, dest);
+
+	maybe_need_flush_mm(mm);
+
+	if (ptl != &mm->page_table_lock)
+		spin_unlock(ptl);
+
+	spin_unlock(&mm->page_table_lock);
+
+	return 0;
+}
+
+/*
+ * There is no migrate_pte since that would be moving the page
+ * pointed to by a pte around.  That's a user page and is equivalent
+ * to swapping and doesn't need to be handled here.
+ */
+
+static int migrate_page_tables_pmd_entry(pmd_t *pmd, struct mm_struct *mm,
+					 unsigned long *address, int source,
+					 new_page_table_t get_new_page,
+					 unsigned long private,
+					 struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pmd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pmd_present(*pmd)) {
+		*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address, private, &result,
+					PAGE_TABLE_PTE);
+		if (!new_page)
+			return -ENOMEM;
+		not_migrated = migrate_pmd_entry(pmd, mm, *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			free_page_table_page(mm, new_page, PAGE_TABLE_PTE);
+
+		pages_not_migrated += not_migrated;
+	}
+
+
+	*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pud_entry(pud_t *pud, struct mm_struct *mm,
+					 unsigned long *address, int source,
+					 new_page_table_t get_new_page,
+					 unsigned long private,
+					 struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pud);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pud_present(*pud)) {
+		*address += (unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address, private, &result,
+					PAGE_TABLE_PMD);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pud_entry(pud, mm, *address, new_page,
+						 old_pages);
+
+		if (not_migrated)
+			free_page_table_page(mm, new_page, PAGE_TABLE_PMD);
+
+		pages_not_migrated += not_migrated;
+	}
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		int ret;
+		ret = migrate_page_tables_pmd_entry(pmd_offset(pud, *address),
+						    mm, address, source,
+						    get_new_page, private,
+						    old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pgd_entry(pgd_t *pgd, struct mm_struct *mm,
+					 unsigned long *address, int source,
+					 new_page_table_t get_new_page,
+					 unsigned long private,
+					 struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pgd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pgd_present(*pgd)) {
+		*address +=  (unsigned long)PTRS_PER_PUD *
+				(unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address,  private, &result,
+					PAGE_TABLE_PUD);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pgd_entry(pgd, mm,  *address, new_page,
+						 old_pages);
+		if (not_migrated)
+			free_page_table_page(mm, new_page, PAGE_TABLE_PUD);
+
+		pages_not_migrated += not_migrated;
+
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pud_entry(pud_offset(pgd, *address),
+						    mm, address, source,
+						    get_new_page, private,
+						    old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+/*
+ * Call this before calling any of the page table relocation
+ * functions.  It causes any other threads using this mm
+ * to start checking to see if someone has changed the page
+ * tables out from under it.
+ */
+void enter_page_table_relocation_mode(struct mm_struct *mm)
+{
+	/* Use an int and a spinlock rather than an atomic_t
+	 * beacuse we only check this inside the spinlock,
+	 * so we save a bunch of lock prefixes in a fast_path
+	 * by suffering a little here with a full block spinlock.
+	 * should be a win overall.
+	 *
+	 * One gotcha.  page_table_relocation_count is
+	 * checked with the wrong spinlock held in the case
+	 * of split page table locks.  Since we only muck with
+	 * the lowest level page tables while holding both the
+	 * page_table_lock and the split page table lock,
+	 * we are still ok.
+	 */
+
+	mutex_lock(&mm->page_table_relocation_lock);
+	spin_lock(&mm->page_table_lock);
+	BUG_ON(mm->page_table_relocation_count > INT_MAX/2);
+	mm->page_table_relocation_count++;
+	spin_unlock(&mm->page_table_lock);
+}
+
+void leave_page_table_relocation_mode(struct mm_struct *mm)
+{
+	/* Make sure all the threads are no longer looking at a stale
+	 * copy of a page table before clearing the flag that lets the
+	 * threads know they may be looking at a stale copy of the
+	 * page tables.  synchronize_rcu must be called before this
+	 * function.
+	 */
+	spin_lock(&mm->page_table_lock);
+	mm->page_table_relocation_count--;
+	BUG_ON(mm->page_table_relocation_count < 0);
+	spin_unlock(&mm->page_table_lock);
+	mutex_unlock(&mm->page_table_relocation_lock);
+}
+
+/* Similiar to migrate pages, but migrates the page tables.
+ * This particular version moves all pages tables away from
+ * the source node to whatever get's allocated by get_new_page.
+ * It's easy to modify the code to reloate other page tables,
+ * or call the migrate_pxx functions directly to move only
+ * a few pages around.  This is meant as a start to test the
+ * migration code and to allow migration between nodes.
+ */
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(mm->pgd);
+	struct page *new_page;
+	unsigned long address = 0UL;
+	int not_migrated;
+	int ret = 0;
+	int switched_mm = 0;
+	LIST_HEAD(old_pages);
+
+	if (mm->pgd == NULL)
+		return 0;
+
+	/* We don't need our mm and if it's the one we are
+	 * mucking with, we will do a bunch of unneccessary
+	 * flushes.  So we switch to the kernel one and
+	 * switch back later.
+	 */
+	if (mm == current->active_mm) {
+		switch_mm(mm, &init_mm, current);
+		switched_mm = 1;
+	}
+
+	enter_page_table_relocation_mode(mm);
+
+	for (i = 0; i < PTRS_PER_PGD && address < mm->task_size; i++) {
+		ret = migrate_page_tables_pgd_entry(pgd_offset(mm, address),
+						    mm, &address, source,
+						    get_new_page, private,
+						    &old_pages);
+		if (ret < 0)
+			goto out_exit;
+
+		pages_not_migrated += ret;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, address, private, &result,
+					PAGE_TABLE_PGD);
+		if (!new_page) {
+			ret = -ENOMEM;
+			goto out_exit;
+		}
+
+		not_migrated = migrate_top_level_page_table_entry(mm, new_page,
+								  &old_pages);
+		if (not_migrated) {
+			free_page_table_page(mm, new_page, PAGE_TABLE_PGD);
+		}
+
+		pages_not_migrated += not_migrated;
+	}
+
+	/* reload or flush the tlbs if necessary. */
+	maybe_reload_tlb_mm(mm);
+
+	/* make sure all threads have stopped looking at stale pages. */
+	synchronize_rcu();
+
+	while (!list_empty(&old_pages)) {
+		old_page = list_first_entry(&old_pages, struct page, lru);
+		list_del_init(&old_page->lru);
+		update_new_page_and_free(mm, old_page);
+	}
+
+ out_exit:
+	if (switched_mm)
+		switch_mm(&init_mm, mm, current);
+
+	leave_page_table_relocation_mode(mm);
+
+	if (ret < 0)
+		return ret;
+	return pages_not_migrated;
+}
+
+#endif /* CONFIG_RELOCATE_PAGE_TABLES */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/mremap.c 2.6.25-rc9/mm/mremap.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/mremap.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/mremap.c	2008-04-15 08:03:20.000000000 -0700
@@ -98,6 +98,8 @@ static void move_ptes(struct vm_area_str
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	delimbo_pte_nested(&new_pte, &new_ptl, &new_pmd, mm, new_addr,
+			   SINGLE_DEPTH_NESTING, old_ptl);
 	arch_enter_lazy_mmu_mode();
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/rmap.c 2.6.25-rc9/mm/rmap.c
--- /home/rossb/local/linux-2.6.25-rc9/mm/rmap.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/rmap.c	2008-04-14 09:00:29.000000000 -0700
@@ -255,6 +255,7 @@ pte_t *page_check_address(struct page *p
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
