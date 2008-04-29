Subject: [RFC/PATH 2/2] MM: Make Page Tables Relocatable -- relocation code.
Message-Id: <20080429134340.61C42DC683@localhost>
Date: Tue, 29 Apr 2008 06:43:40 -0700 (PDT)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: rossb@google.com
List-ID: <linux-mm.kvack.org>

-----
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
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h 2.6.25-rc9/include/asm-generic/pgalloc.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.25-rc9/include/asm-generic/pgalloc.h	2008-04-14 09:00:29.000000000 -0700
@@ -0,0 +1,37 @@
+#ifndef _ASM_GENERIC_PGALLOC_H
+#define _ASM_GENERIC_PGALLOC_H
+
+
+
+/* Page Table Levels used for alloc_page_table. */
+#define PAGE_TABLE_PGD 0
+#define PAGE_TABLE_PUD 1
+#define PAGE_TABLE_PMD 2
+#define PAGE_TABLE_PTE 3
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
+
+#endif /* _ASM_GENERIC_PGALLOC_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h 2.6.25-rc9/include/asm-generic/pgtable.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-generic/pgtable.h	2008-04-15 07:27:10.000000000 -0700
@@ -4,6 +4,8 @@
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
+#include <linux/sched.h>
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Largely same as above, but only sets the access flags (dirty,
@@ -195,6 +197,54 @@ static inline int pmd_none_or_clear_bad(
 	}
 	return 0;
 }
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
+	return pud_offset(pgd, addr);
+}
+
+static inline pmd_t *walk_page_table_pmd(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pud_t *pud;
+	pud = walk_page_table_pud(mm, addr);
+	BUG_ON(!pud);
+	return  pmd_offset(pud, addr);
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
 #endif /* CONFIG_MMU */
 
 /*
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h 2.6.25-rc9/include/asm-x86/pgalloc_64.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-04-14 09:00:29.000000000 -0700
@@ -25,16 +25,6 @@ static inline void pmd_free(struct mm_st
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
@@ -61,12 +51,75 @@ static inline void pgd_list_del(pgd_t *p
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
+#ifdef CONFIG_NUMA
+static inline pud_t *pud_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr,
+					int node)
+{
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pud_t *)page_address(page);
+	return NULL;
+}
+
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr,
+					int node)
+{
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pmd_t *)page_address(page);
+	return NULL;
+}
+
+static inline pgd_t *pgd_alloc_node(struct mm_struct *mm, int node)
 {
 	unsigned boundary;
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
-	if (!pgd)
+	struct page *page;
+	pgd_t *pgd;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT, 0);
+	if (!page)
 		return NULL;
+
+	pgd = (pgd_t *)page_address(page);
+
 	pgd_list_add(pgd);
 	/*
 	 * Copy kernel pointers in from init.
@@ -81,11 +134,72 @@ static inline pgd_t *pgd_alloc(struct mm
 	return pgd;
 }
 
-static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+static inline pte_t *pte_alloc_one_kernel_node(struct mm_struct *mm,
+					       unsigned long address,
+					       int node)
 {
-	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
-	pgd_list_del(pgd);
-	free_page((unsigned long)pgd);
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pte_t *)page_address(page);
+	return NULL;
+}
+
+static inline struct page *pte_alloc_one_node(struct mm_struct *mm,
+					      unsigned long address,
+					      int node)
+{
+	struct page *page;
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	return page;
+}
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return pgd_alloc_node(mm, -1);
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pte_alloc_one_node(mm, addr, -1);
+}
+
+static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
+{
+	return pmd_alloc_one_node(mm, addr, -1);
+}
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pud_alloc_one_node(mm, addr, -1);
+}
+
+#else /* !CONFIG_NUMA */
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	unsigned boundary;
+	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (!pgd)
+		return NULL;
+	pgd_list_add(pgd);
+	/*
+	 * Copy kernel pointers in from init.
+	 * Could keep a freelist or slab cache of those because the kernel
+	 * part never changes.
+	 */
+	boundary = pgd_index(__PAGE_OFFSET);
+	memset(pgd, 0, boundary * sizeof(pgd_t));
+	memcpy(pgd + boundary,
+	       init_level4_pgt + boundary,
+	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+	return pgd;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
@@ -106,28 +220,19 @@ static inline pgtable_t pte_alloc_one(st
 	return page;
 }
 
-/* Should really implement gc for free page table pages. This could be
-   done with a reference count in struct page. */
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	pgtable_page_dtor(pte);
-	__free_page(pte);
+	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 } 
 
-#define __pte_free_tlb(tlb,pte)				\
-do {							\
-	pgtable_page_dtor((pte));				\
-	tlb_remove_page((tlb), (pte));			\
-} while (0)
+#endif
+
+#include <asm-generic/pgalloc.h>
 
-#define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
-#define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 
 #endif /* _X86_64_PGALLOC_H */
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
+++ 2.6.25-rc9/include/linux/mm.h	2008-04-15 11:35:05.000000000 -0700
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <asm/pgtable.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -921,6 +922,7 @@ static inline void pgtable_page_dtor(str
 	pte_t *__pte = pte_offset_map(pmd, address);	\
 	*(ptlp) = __ptl;				\
 	spin_lock(__ptl);				\
+	delimbo_pte(&__pte, ptlp, &pmd, mm, address);	\
 	__pte;						\
 })
 
@@ -945,6 +947,116 @@ extern void free_area_init(unsigned long
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
+static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+			  struct mm_struct *mm,
+			  unsigned long addr)
+{
+	/* We don't actually have the correct spinlock here, but it's
+	 * ok since the relocation code won't go mucking with the
+	 * relevant level of the page table while holding the relevant
+	 * spinlock.  This means that while all the page tables
+	 * leading up to this one could get mucked with, the one we
+	 * care about cannot be mucked with without us seeing that
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
+	 * But it's ok, because even if we get interrupted after for a
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
+	/* At this point we have the page_table_lock. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pud(pud, mm, addr);
+}
+
+static inline void delimbo_pmd(pmd_t **pmd,  struct mm_struct *mm,
+			       unsigned long addr)
+{
+
+	/* we hold the page_table_lock, so this is safe to test. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pmd(pmd, mm, addr);
+}
+
+static inline void delimbo_pgd(pgd_t **pgd,  struct mm_struct *mm,
+			       unsigned long addr)
+{
+	/* we hold the page_table_lock. */
+	if (unlikely(mm->page_table_relocation_count))
+		_delimbo_pgd(pgd, mm, addr);
+}
+
+
+static inline void delimbo_huge_pte(pte_t **pte,  struct mm_struct *mm,
+				    unsigned long addr)
+{
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
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c 2.6.25-rc9/kernel/fork.c
--- /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/kernel/fork.c	2008-04-15 05:51:53.000000000 -0700
@@ -360,6 +360,10 @@ static struct mm_struct * mm_init(struct
 	mm->cached_hole_size = ~0UL;
 	mm_init_cgroup(mm, p);
 
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+	mm->page_table_relocation_count = 0;
+#endif
+
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig 2.6.25-rc9/mm/Kconfig
--- /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/mm/Kconfig	2008-04-14 09:00:29.000000000 -0700
@@ -143,6 +143,10 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config RELOCATE_PAGE_TABLES 
+	def_bool y
+	depends on X86_64 && MIGRATION
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
+++ 2.6.25-rc9/mm/migrate.c	2008-04-15 08:12:50.000000000 -0700
@@ -30,9 +30,18 @@
 #include <linux/vmalloc.h>
 #include <linux/security.h>
 #include <linux/memcontrol.h>
+#include <linux/mm.h>
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
@@ -155,6 +164,7 @@ static void remove_migration_pte(struct 
 
  	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
+	delimbo_pte(&ptep, &ptl, &pmd, mm, addr);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -895,9 +905,10 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 	else
-		err = -ENOENT;
+		err = 0;
 
 	up_read(&mm->mmap_sem);
+
 	return err;
 }
 
@@ -1075,3 +1086,514 @@ int migrate_vmas(struct mm_struct *mm, c
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
+ * thread for the later.
+ *
+ * This is easier than it might seems since most of the code is
+ * already there.  The kernel never updates a page table without first
+ * grabbing an appropriate spinlock.  Then it has to double
+ * check to make sure that another thread hasn't already changed things.
+ * So all we have to do is rewalk all the page tables whenever we
+ * grab the spinlock. Then the existing double check code takes care
+ * of the rest.
+ *
+ * For the cpus, it's just important to fluch the TLB cache whenever it
+ * might be relevant.  To avoid unnecessary TLB cache tharshing, we only
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
+/* This function rewalks the page tables to make sure that
+ * a thread is not looking at a stale page table entry.
+ */
+void _delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+		  struct mm_struct *mm,  unsigned long addr)
+{
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_unlock(*ptl);
+	spin_lock(&mm->page_table_lock);
+#endif
+	/* We could check the page_table_relocation_count again
+	 * to make sure that it hasn't changed, but it's not a big win
+	 * and makes the code more complex since we have to make sure
+	 * we get the correct spinlock.
+	 */
+	pte_unmap(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_lock(*ptl);
+	spin_unlock(&mm->page_table_lock);
+#endif
+}
+
+void _delimbo_pte_nested(pte_t **pte, spinlock_t **ptl, pmd_t **pmd,
+			 struct mm_struct *mm, unsigned long addr,
+			 int subclass, spinlock_t *optl)
+{
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	if (optl != *ptl)
+		spin_unlock(*ptl);
+	spin_lock(&mm->page_table_lock);
+#endif
+	pte_unmap_nested(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map_nested(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	if (optl != *ptl )
+		spin_lock_nested(*ptl, subclass);
+	spin_unlock(&mm->page_table_lock);
+#endif
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
+ * Returns the number of pages not migrated.
+ */
+int migrate_pgd(pgd_t *pgd, struct mm_struct *mm,
+		unsigned long addr, struct page *dest,
+		struct list_head *old_pages)
+{
+	void *dest_ptr;
+	pud_t *pud;
+
+	spin_lock(&mm->page_table_lock);
+
+	_delimbo_pgd(&pgd, mm, addr);
+
+	pud = pud_offset(pgd, addr);
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pud, PAGE_SIZE);
+
+	list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
+	pgd_populate(mm, pgd, dest_ptr);
+
+	maybe_need_flush_mm(mm);
+
+	spin_unlock(&mm->page_table_lock);
+
+	return 0;
+
+}
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
+ * Returns the number of pages not migrated.
+ */
+int migrate_pud(pud_t *pud, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	void *dest_ptr;
+	pmd_t *pmd;
+
+	spin_lock(&mm->page_table_lock);
+
+	_delimbo_pud(&pud, mm, addr);
+	pmd = pmd_offset(pud, addr);
+
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pmd, PAGE_SIZE);
+
+	list_add_tail(&(pud_page(*pud)->lru), old_pages);
+
+	pud_populate(mm, pud, dest_ptr);
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
+ * This function cannot be called at interrupt time since
+ * it uses KM_USER0.  To modify it to be usable at interrupt
+ * time requires a change of the KM_.  It may require a
+ * KM_ of its own.  It would be safe to always use the
+ * same KM_, since it's all done inside a spinlock, so there
+ * is no chance of the KM_ getting used twice on the same cpu.
+ */
+
+int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	void *dest_ptr;
+	spinlock_t *ptl;
+	pte_t *pte;
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
+	pte = pte_offset_map(pmd, addr);
+
+	dest_ptr = kmap_atomic(dest, KM_USER0);
+	memcpy(dest_ptr, pte, PAGE_SIZE);
+	list_add_tail(&(pmd_page(*pmd)->lru), old_pages);
+
+	kunmap_atomic(dest, KM_USER0);
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
+static int migrate_page_tables_pmd(pmd_t *pmd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
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
+		not_migrated = migrate_pmd(pmd, mm, *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
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
+static int migrate_page_tables_pud(pud_t *pud, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
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
+		not_migrated = migrate_pud(pud, mm, *address, new_page,
+					   old_pages);
+
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pmd(pmd_offset(pud, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pgd(pgd_t *pgd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
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
+		not_migrated = migrate_pgd(pgd, mm,  *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pud(pud_offset(pgd, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
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
+	LIST_HEAD(old_pages);
+
+	if (mm->pgd == NULL)
+		return 0;
+
+	enter_page_table_relocation_mode(mm);
+
+	for (i = 0; i < PTRS_PER_PGD && address < mm->task_size; i++) {
+		ret = migrate_page_tables_pgd(pgd_offset(mm, address), mm,
+					      &address, source,
+					      get_new_page, private,
+					      &old_pages);
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
+		not_migrated = migrate_top_level_page_table(mm, new_page,
+							&old_pages);
+		if (not_migrated) {
+			pgd_list_del(page_address(new_page));
+			__free_page(new_page);
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
+		__free_page(old_page);
+	}
+
+ out_exit:
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
