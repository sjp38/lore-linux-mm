Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ2ep923840
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:02 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ2rg1843224
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:02 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ2pL016624
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:02 +0200
Message-Id: <20071025181901.988317307@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:24 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 4/6] s390: 1K/2K page table pages.
Content-Disposition: inline; filename=004-mm-1k2k.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch implements 1K/2K page table pages for s390.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/mm/pgtable.c         |  100 ++++++++++++++++++++++++++++++---------
 arch/s390/mm/vmem.c            |   10 +++
 include/asm-s390/elf.h         |   12 ++++
 include/asm-s390/mmu.h         |    7 +-
 include/asm-s390/mmu_context.h |   16 +++---
 include/asm-s390/page.h        |   37 +-------------
 include/asm-s390/pgalloc.h     |   79 ++++++++++++++----------------
 include/asm-s390/pgtable.h     |  105 ++++++++++++++---------------------------
 include/asm-s390/tlb.h         |    6 +-
 include/asm-s390/tlbflush.h    |    6 --
 10 files changed, 197 insertions(+), 181 deletions(-)

Index: quilt-2.6/arch/s390/mm/pgtable.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/pgtable.c
+++ quilt-2.6/arch/s390/mm/pgtable.c
@@ -26,8 +26,12 @@
 
 #ifndef CONFIG_64BIT
 #define ALLOC_ORDER	1
+#define TABLES_PER_PAGE	4
+#define SECOND_HALVES	10
 #else
 #define ALLOC_ORDER	2
+#define TABLES_PER_PAGE	2
+#define SECOND_HALVES	2
 #endif
 
 unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec)
@@ -45,13 +49,20 @@ unsigned long *crst_table_alloc(struct m
 		}
 		page->index = page_to_phys(shadow);
 	}
+	spin_lock(&mm->page_table_lock);
+	list_add(&page->lru, &mm->context.crst_list);
+	spin_unlock(&mm->page_table_lock);
 	return (unsigned long *) page_to_phys(page);
 }
 
-void crst_table_free(unsigned long *table)
+void crst_table_free(struct mm_struct *mm, unsigned long *table)
 {
 	unsigned long *shadow = get_shadow_table(table);
+	struct page *page = virt_to_page(table);
 
+	spin_lock(&mm->page_table_lock);
+	list_del(&page->lru);
+	spin_unlock(&mm->page_table_lock);
 	if (shadow)
 		free_pages((unsigned long) shadow, ALLOC_ORDER);
 	free_pages((unsigned long) table, ALLOC_ORDER);
@@ -60,37 +71,84 @@ void crst_table_free(unsigned long *tabl
 /*
  * page table entry allocation/free routines.
  */
-unsigned long *page_table_alloc(int noexec)
+unsigned long *page_table_alloc(struct mm_struct *mm)
 {
-	struct page *page = alloc_page(GFP_KERNEL);
+	struct page *page;
 	unsigned long *table;
+	unsigned long bits;
 
-	if (!page)
-		return NULL;
-	page->index = 0;
-	if (noexec) {
-		struct page *shadow = alloc_page(GFP_KERNEL);
-		if (!shadow) {
-			__free_page(page);
+	bits = mm->context.noexec ? 3UL : 1UL;
+	spin_lock(&mm->page_table_lock);
+	page = NULL;
+	if (!list_empty(&mm->context.pgtable_list)) {
+		page = list_first_entry(&mm->context.pgtable_list,
+					struct page, lru);
+		if (page->flags == ((1UL << TABLES_PER_PAGE) - 1))
+			page = NULL;
+	}
+	if (!page) {
+		spin_unlock(&mm->page_table_lock);
+		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+		if (!page)
 			return NULL;
-		}
-		table = (unsigned long *) page_to_phys(shadow);
+		pgtable_page_ctor(page);
+		page->flags = 0;
+		table = (unsigned long *) page_to_phys(page);
 		clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
-		page->index = (addr_t) table;
+		spin_lock(&mm->page_table_lock);
+		list_add(&page->lru, &mm->context.pgtable_list);
 	}
-	pgtable_page_ctor(page);
 	table = (unsigned long *) page_to_phys(page);
-	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
+	while (page->flags & bits) {
+		table += 256;
+		bits <<= 1;
+	}
+	page->flags |= bits;
+	if (page->flags == ((1UL << TABLES_PER_PAGE) - 1))
+		list_move_tail(&page->lru, &mm->context.pgtable_list);
+	spin_unlock(&mm->page_table_lock);
 	return table;
 }
 
-void page_table_free(unsigned long *table)
+void page_table_free(struct mm_struct *mm, unsigned long *table)
 {
-	unsigned long *shadow = get_shadow_pte(table);
+	struct page *page;
+	unsigned long bits;
 
-	pgtable_page_dtor(virt_to_page(table));
-	if (shadow)
-		free_page((unsigned long) shadow);
-	free_page((unsigned long) table);
+	bits = mm->context.noexec ? 3UL : 1UL;
+	bits <<= (__pa(table) & (PAGE_SIZE - 1)) / 256 / sizeof(unsigned long);
+	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
+	spin_lock(&mm->page_table_lock);
+	page->flags ^= bits;
+	if (page->flags) {
+		/* Page now has some free pgtable fragments. */
+		list_move(&page->lru, &mm->context.pgtable_list);
+		page = NULL;
+	} else
+		/* All fragments of the 4K page have been freed. */
+		list_del(&page->lru);
+	spin_unlock(&mm->page_table_lock);
+	if (page) {
+		pgtable_page_dtor(page);
+		__free_page(page);
+	}
+}
 
+void disable_noexec(struct mm_struct *mm, struct task_struct *tsk)
+{
+	struct page *page;
+
+	spin_lock(&mm->page_table_lock);
+	/* Free shadow region and segment tables. */
+	list_for_each_entry(page, &mm->context.crst_list, lru)
+		if (page->index) {
+			free_pages((unsigned long) page->index, ALLOC_ORDER);
+			page->index = 0;
+		}
+	/* "Free" second halves of page tables. */
+	list_for_each_entry(page, &mm->context.pgtable_list, lru)
+		page->flags &= ~SECOND_HALVES;
+	spin_unlock(&mm->page_table_lock);
+	mm->context.noexec = 0;
+	update_mm(mm, tsk);
 }
Index: quilt-2.6/arch/s390/mm/vmem.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/vmem.c
+++ quilt-2.6/arch/s390/mm/vmem.c
@@ -75,6 +75,13 @@ static void __init_refok *vmem_alloc_pag
 
 #define vmem_pud_alloc()	({ BUG(); ((pud_t *) NULL); })
 
+static inline void *vmem_alloc_slab(size_t size)
+{
+	if (slab_is_available())
+		return (void *) kmalloc(size, GFP_KERNEL);
+	return alloc_bootmem(size);
+}
+
 static inline pmd_t *vmem_pmd_alloc(void)
 {
 	pmd_t *pmd = NULL;
@@ -363,6 +370,9 @@ void __init vmem_map_init(void)
 	unsigned long map_size;
 	int i;
 
+	INIT_LIST_HEAD(&init_mm.context.crst_list);
+	INIT_LIST_HEAD(&init_mm.context.pgtable_list);
+	init_mm.context.noexec = 0;
 	map_size = ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) * sizeof(struct page);
 	vmalloc_end = PFN_ALIGN(VMALLOC_END_INIT) - PFN_ALIGN(map_size);
 	vmem_map = (struct page *) vmalloc_end;
Index: quilt-2.6/include/asm-s390/elf.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/elf.h
+++ quilt-2.6/include/asm-s390/elf.h
@@ -116,6 +116,7 @@ typedef s390_regs elf_gregset_t;
 #ifdef __KERNEL__
 #include <linux/sched.h>	/* for task_struct */
 #include <asm/system.h>		/* for save_access_regs */
+#include <asm/mmu_context.h>
 
 /*
  * This is used to ensure we don't load something for the wrong architecture.
@@ -214,6 +215,17 @@ do {							\
 	clear_thread_flag(TIF_31BIT);			\
 } while (0)
 #endif /* __s390x__ */
+/*
+ * An executable for which elf_read_implies_exec() returns TRUE will
+ * have the READ_IMPLIES_EXEC personality flag set automatically.
+ */
+#define elf_read_implies_exec(ex, executable_stack)	\
+({							\
+	if (current->mm->context.noexec &&		\
+	    executable_stack != EXSTACK_DISABLE_X)	\
+		disable_noexec(current->mm, current);	\
+	current->mm->context.noexec == 0;		\
+})
 #endif
 
 #endif
Index: quilt-2.6/include/asm-s390/mmu_context.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/mmu_context.h
+++ quilt-2.6/include/asm-s390/mmu_context.h
@@ -10,13 +10,15 @@
 #define __S390_MMU_CONTEXT_H
 
 #include <asm/pgalloc.h>
+#include <asm/uaccess.h>
 #include <asm-generic/mm_hooks.h>
 
-/*
- * get a new mmu context.. S390 don't know about contexts.
- */
-#define init_new_context(tsk,mm)        0
-
+static inline int init_new_context(struct task_struct *tsk,
+				   struct mm_struct *mm)
+{
+	mm->context.noexec = s390_noexec;
+	return(0);
+}
 #define destroy_context(mm)             do { } while (0)
 
 #ifndef __s390x__
@@ -38,8 +40,8 @@ static inline void update_mm(struct mm_s
 	S390_lowcore.user_asce = asce_bits | __pa(pgd);
 	if (switch_amode) {
 		/* Load primary space page table origin. */
-		pgd_t *shadow_pgd = get_shadow_table(pgd) ? : pgd;
-		S390_lowcore.user_exec_asce = asce_bits | __pa(shadow_pgd);
+		pgd = mm->context.noexec ? get_shadow_table(pgd) : pgd;
+		S390_lowcore.user_exec_asce = asce_bits | __pa(pgd);
 		asm volatile(LCTL_OPCODE" 1,1,%0\n"
 			     : : "m" (S390_lowcore.user_exec_asce) );
 	} else
Index: quilt-2.6/include/asm-s390/mmu.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/mmu.h
+++ quilt-2.6/include/asm-s390/mmu.h
@@ -1,7 +1,10 @@
 #ifndef __MMU_H
 #define __MMU_H
 
-/* Default "unsigned long" context */
-typedef unsigned long mm_context_t;
+typedef struct {
+	struct list_head crst_list;
+	struct list_head pgtable_list;
+	int noexec;
+} mm_context_t;
 
 #endif
Index: quilt-2.6/include/asm-s390/page.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/page.h
+++ quilt-2.6/include/asm-s390/page.h
@@ -75,43 +75,17 @@ static inline void copy_page(void *to, v
 
 typedef struct { unsigned long pgprot; } pgprot_t;
 typedef struct { unsigned long pte; } pte_t;
-
-#define pte_val(x)      ((x).pte)
-#define pgprot_val(x)   ((x).pgprot)
-
-#ifndef __s390x__
-
 typedef struct { unsigned long pmd; } pmd_t;
 typedef struct { unsigned long pud; } pud_t;
-typedef struct {
-        unsigned long pgd0;
-        unsigned long pgd1;
-        unsigned long pgd2;
-        unsigned long pgd3;
-        } pgd_t;
-
-#define pmd_val(x)      ((x).pmd)
-#define pud_val(x)	((x).pud)
-#define pgd_val(x)      ((x).pgd0)
-
-#else /* __s390x__ */
-
-typedef struct { 
-        unsigned long pmd0;
-        unsigned long pmd1; 
-        } pmd_t;
-typedef struct { unsigned long pud; } pud_t;
 typedef struct { unsigned long pgd; } pgd_t;
+typedef pte_t *pgtable_t;
 
-#define pmd_val(x)      ((x).pmd0)
-#define pmd_val1(x)     ((x).pmd1)
+#define pgprot_val(x)	((x).pgprot)
+#define pte_val(x)	((x).pte)
+#define pmd_val(x)	((x).pmd)
 #define pud_val(x)	((x).pud)
 #define pgd_val(x)      ((x).pgd)
 
-#endif /* __s390x__ */
-
-typedef struct page *pgtable_t;
-
 #define __pte(x)        ((pte_t) { (x) } )
 #define __pmd(x)        ((pmd_t) { (x) } )
 #define __pgd(x)        ((pgd_t) { (x) } )
@@ -168,8 +142,7 @@ static inline int pfn_valid(unsigned lon
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
-				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
+#define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE )
 
 #include <asm-generic/memory_model.h>
 #include <asm-generic/page.h>
Index: quilt-2.6/include/asm-s390/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgalloc.h
+++ quilt-2.6/include/asm-s390/pgalloc.h
@@ -20,10 +20,11 @@
 #define check_pgt_cache()	do {} while (0)
 
 unsigned long *crst_table_alloc(struct mm_struct *, int);
-void crst_table_free(unsigned long *);
+void crst_table_free(struct mm_struct *, unsigned long *);
 
-unsigned long *page_table_alloc(int);
-void page_table_free(unsigned long *);
+unsigned long *page_table_alloc(struct mm_struct *);
+void page_table_free(struct mm_struct *, unsigned long *);
+void disable_noexec(struct mm_struct *, struct task_struct *);
 
 static inline void clear_table(unsigned long *s, unsigned long val, size_t n)
 {
@@ -80,12 +81,12 @@ static inline unsigned long pgd_entry_ty
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
 {
-	unsigned long *crst = crst_table_alloc(mm, s390_noexec);
-	if (crst)
-		crst_table_init(crst, _SEGMENT_ENTRY_EMPTY);
-	return (pmd_t *) crst;
+	unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+	if (table)
+		crst_table_init(table, _SEGMENT_ENTRY_EMPTY);
+	return (pmd_t *) table;
 }
-#define pmd_free(mm, pmd) crst_table_free((unsigned long *) pmd)
+#define pmd_free(mm, pmd) crst_table_free(mm, (unsigned long *) pmd)
 
 #define pgd_populate(mm, pgd, pud)		BUG()
 #define pgd_populate_kernel(mm, pgd, pud)	BUG()
@@ -98,63 +99,55 @@ static inline void pud_populate_kernel(s
 
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
-	pud_t *shadow_pud = get_shadow_table(pud);
-	pmd_t *shadow_pmd = get_shadow_table(pmd);
-
-	if (shadow_pud && shadow_pmd)
-		pud_populate_kernel(mm, shadow_pud, shadow_pmd);
 	pud_populate_kernel(mm, pud, pmd);
+	if (mm->context.noexec) {
+		pud = get_shadow_table(pud);
+		pmd = get_shadow_table(pmd);
+		pud_populate_kernel(mm, pud, pmd);
+	}
 }
 
 #endif /* __s390x__ */
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	unsigned long *crst = crst_table_alloc(mm, s390_noexec);
+	unsigned long *crst;
+
+	INIT_LIST_HEAD(&mm->context.crst_list);
+	INIT_LIST_HEAD(&mm->context.pgtable_list);
+	crst = crst_table_alloc(mm, s390_noexec);
 	if (crst)
 		crst_table_init(crst, pgd_entry_type(mm));
 	return (pgd_t *) crst;
 }
-#define pgd_free(mm, pgd) crst_table_free((unsigned long *) pgd)
+#define pgd_free(mm, pgd) crst_table_free(mm, (unsigned long *) pgd)
 
-static inline void 
-pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
+static inline void pmd_populate_kernel(struct mm_struct *mm,
+				       pmd_t *pmd, pte_t *pte)
 {
-#ifndef __s390x__
-	pmd_val(pmd[0]) = _SEGMENT_ENTRY + __pa(pte);
-	pmd_val(pmd[1]) = _SEGMENT_ENTRY + __pa(pte+256);
-	pmd_val(pmd[2]) = _SEGMENT_ENTRY + __pa(pte+512);
-	pmd_val(pmd[3]) = _SEGMENT_ENTRY + __pa(pte+768);
-#else /* __s390x__ */
 	pmd_val(*pmd) = _SEGMENT_ENTRY + __pa(pte);
-	pmd_val1(*pmd) = _SEGMENT_ENTRY + __pa(pte+256);
-#endif /* __s390x__ */
 }
 
-static inline void
-pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page)
+static inline void pmd_populate(struct mm_struct *mm,
+				pmd_t *pmd, pgtable_t pte)
 {
-	pte_t *pte = (pte_t *)page_to_phys(page);
-	pmd_t *shadow_pmd = get_shadow_table(pmd);
-	pte_t *shadow_pte = get_shadow_pte(pte);
-
 	pmd_populate_kernel(mm, pmd, pte);
-	if (shadow_pmd && shadow_pte)
-		pmd_populate_kernel(mm, shadow_pmd, shadow_pte);
+	if (mm->context.noexec) {
+		pmd = get_shadow_table(pmd);
+		pmd_populate_kernel(mm, pmd, pte + PTRS_PER_PTE);
+	}
 }
-#define pmd_pgtable(pmd) pmd_page(pmd)
+
+#define pmd_pgtable(pmd) \
+	(pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE)
 
 /*
  * page table entry allocation/free routines.
  */
-#define pte_alloc_one_kernel(mm, vmaddr) \
-	((pte_t *) page_table_alloc(s390_noexec))
-#define pte_alloc_one(mm, vmaddr) \
-	virt_to_page(page_table_alloc(s390_noexec))
-
-#define pte_free_kernel(mm, pte) \
-	page_table_free((unsigned long *) pte)
-#define pte_free(mm, pte) \
-	page_table_free((unsigned long *) page_to_phys((struct page *) pte))
+#define pte_alloc_one_kernel(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
+#define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
+
+#define pte_free_kernel(mm, pte) page_table_free(mm, (unsigned long *) pte)
+#define pte_free(mm, pte) page_table_free(mm, (unsigned long *) pte)
 
 #endif /* _S390_PGALLOC_H */
Index: quilt-2.6/include/asm-s390/pgtable.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgtable.h
+++ quilt-2.6/include/asm-s390/pgtable.h
@@ -57,11 +57,11 @@ extern char empty_zero_page[PAGE_SIZE];
  * PGDIR_SHIFT determines what a third-level page table entry can map
  */
 #ifndef __s390x__
-# define PMD_SHIFT	22
-# define PUD_SHIFT	22
-# define PGDIR_SHIFT	22
+# define PMD_SHIFT	20
+# define PUD_SHIFT	20
+# define PGDIR_SHIFT	20
 #else /* __s390x__ */
-# define PMD_SHIFT	21
+# define PMD_SHIFT	20
 # define PUD_SHIFT	31
 # define PGDIR_SHIFT	31
 #endif /* __s390x__ */
@@ -79,17 +79,14 @@ extern char empty_zero_page[PAGE_SIZE];
  * for S390 segment-table entries are combined to one PGD
  * that leads to 1024 pte per pgd
  */
+#define PTRS_PER_PTE	256
 #ifndef __s390x__
-# define PTRS_PER_PTE    1024
-# define PTRS_PER_PMD    1
-# define PTRS_PER_PUD	1
-# define PTRS_PER_PGD    512
+#define PTRS_PER_PMD	1
 #else /* __s390x__ */
-# define PTRS_PER_PTE    512
-# define PTRS_PER_PMD    1024
-# define PTRS_PER_PUD	1
-# define PTRS_PER_PGD    2048
+#define PTRS_PER_PMD	2048
 #endif /* __s390x__ */
+#define PTRS_PER_PUD	1
+#define PTRS_PER_PGD	2048
 
 #define FIRST_USER_ADDRESS  0
 
@@ -383,24 +380,6 @@ extern unsigned long vmalloc_end;
 # define PxD_SHADOW_SHIFT	2
 #endif /* __s390x__ */
 
-static inline struct page *get_shadow_page(struct page *page)
-{
-	if (s390_noexec && page->index)
-		return virt_to_page((void *)(addr_t) page->index);
-	return NULL;
-}
-
-static inline void *get_shadow_pte(void *table)
-{
-	unsigned long addr, offset;
-	struct page *page;
-
-	addr = (unsigned long) table;
-	offset = addr & (PAGE_SIZE - 1);
-	page = virt_to_page((void *)(addr ^ offset));
-	return (void *)(addr_t)(page->index ? (page->index | offset) : 0UL);
-}
-
 static inline void *get_shadow_table(void *table)
 {
 	unsigned long addr, offset;
@@ -418,17 +397,16 @@ static inline void *get_shadow_table(voi
  * hook is made available.
  */
 static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
-			      pte_t *pteptr, pte_t pteval)
+			      pte_t *ptep, pte_t entry)
 {
-	pte_t *shadow_pte = get_shadow_pte(pteptr);
-
-	*pteptr = pteval;
-	if (shadow_pte) {
-		if (!(pte_val(pteval) & _PAGE_INVALID) &&
-		    (pte_val(pteval) & _PAGE_SWX))
-			pte_val(*shadow_pte) = pte_val(pteval) | _PAGE_RO;
+	*ptep = entry;
+	if (mm->context.noexec) {
+		if (!(pte_val(entry) & _PAGE_INVALID) &&
+		    (pte_val(entry) & _PAGE_SWX))
+			pte_val(entry) |= _PAGE_RO;
 		else
-			pte_val(*shadow_pte) = _PAGE_TYPE_EMPTY;
+			pte_val(entry) = _PAGE_TYPE_EMPTY;
+		ptep[PTRS_PER_PTE] = entry;
 	}
 }
 
@@ -543,14 +521,6 @@ static inline int pte_young(pte_t pte)
 #define pgd_clear(pgd)		do { } while (0)
 #define pud_clear(pud)		do { } while (0)
 
-static inline void pmd_clear_kernel(pmd_t * pmdp)
-{
-	pmd_val(pmdp[0]) = _SEGMENT_ENTRY_EMPTY;
-	pmd_val(pmdp[1]) = _SEGMENT_ENTRY_EMPTY;
-	pmd_val(pmdp[2]) = _SEGMENT_ENTRY_EMPTY;
-	pmd_val(pmdp[3]) = _SEGMENT_ENTRY_EMPTY;
-}
-
 #else /* __s390x__ */
 
 #define pgd_clear(pgd)		do { } while (0)
@@ -569,30 +539,27 @@ static inline void pud_clear(pud_t * pud
 		pud_clear_kernel(shadow);
 }
 
+#endif /* __s390x__ */
+
 static inline void pmd_clear_kernel(pmd_t * pmdp)
 {
 	pmd_val(*pmdp) = _SEGMENT_ENTRY_EMPTY;
-	pmd_val1(*pmdp) = _SEGMENT_ENTRY_EMPTY;
 }
 
-#endif /* __s390x__ */
-
-static inline void pmd_clear(pmd_t * pmdp)
+static inline void pmd_clear(pmd_t *pmd)
 {
-	pmd_t *shadow_pmd = get_shadow_table(pmdp);
+	pmd_t *shadow = get_shadow_table(pmd);
 
-	pmd_clear_kernel(pmdp);
-	if (shadow_pmd)
-		pmd_clear_kernel(shadow_pmd);
+	pmd_clear_kernel(pmd);
+	if (shadow)
+		pmd_clear_kernel(shadow);
 }
 
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
-	pte_t *shadow_pte = get_shadow_pte(ptep);
-
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
-	if (shadow_pte)
-		pte_val(*shadow_pte) = _PAGE_TYPE_EMPTY;
+	if (mm->context.noexec)
+		pte_val(ptep[PTRS_PER_PTE]) = _PAGE_TYPE_EMPTY;
 }
 
 /*
@@ -673,7 +640,7 @@ static inline void __ptep_ipte(unsigned 
 {
 	if (!(pte_val(*ptep) & _PAGE_INVALID)) {
 #ifndef __s390x__
-		/* S390 has 1mb segments, we are emulating 4MB segments */
+		/* pto must point to the start of the segment table */
 		pte_t *pto = (pte_t *) (((unsigned long) ptep) & 0x7ffffc00);
 #else
 		/* ipte in zarch mode can do the math */
@@ -687,12 +654,12 @@ static inline void __ptep_ipte(unsigned 
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 }
 
-static inline void ptep_invalidate(unsigned long address, pte_t *ptep)
+static inline void ptep_invalidate(struct mm_struct *mm,
+				   unsigned long address, pte_t *ptep)
 {
 	__ptep_ipte(address, ptep);
-	ptep = get_shadow_pte(ptep);
-	if (ptep)
-		__ptep_ipte(address, ptep);
+	if (mm->context.noexec)
+		__ptep_ipte(address, ptep + PTRS_PER_PTE);
 }
 
 /*
@@ -714,7 +681,7 @@ static inline void ptep_invalidate(unsig
 	pte_t __pte = *(__ptep);					\
 	if (atomic_read(&(__mm)->mm_users) > 1 ||			\
 	    (__mm) != current->active_mm)				\
-		ptep_invalidate(__address, __ptep);			\
+		ptep_invalidate(__mm, __address, __ptep);		\
 	else								\
 		pte_clear((__mm), (__address), (__ptep));		\
 	__pte;								\
@@ -725,7 +692,7 @@ static inline pte_t ptep_clear_flush(str
 				     unsigned long address, pte_t *ptep)
 {
 	pte_t pte = *ptep;
-	ptep_invalidate(address, ptep);
+	ptep_invalidate(vma->vm_mm, address, ptep);
 	return pte;
 }
 
@@ -746,7 +713,7 @@ static inline pte_t ptep_get_and_clear_f
 	if (full)
 		pte_clear(mm, addr, ptep);
 	else
-		ptep_invalidate(addr, ptep);
+		ptep_invalidate(mm, addr, ptep);
 	return pte;
 }
 
@@ -757,7 +724,7 @@ static inline pte_t ptep_get_and_clear_f
 	if (pte_write(__pte)) {						\
 		if (atomic_read(&(__mm)->mm_users) > 1 ||		\
 		    (__mm) != current->active_mm)			\
-			ptep_invalidate(__addr, __ptep);		\
+			ptep_invalidate(__mm, __addr, __ptep);		\
 		set_pte_at(__mm, __addr, __ptep, pte_wrprotect(__pte));	\
 	}								\
 })
@@ -767,7 +734,7 @@ static inline pte_t ptep_get_and_clear_f
 ({									\
 	int __changed = !pte_same(*(__ptep), __entry);			\
 	if (__changed) {						\
-		ptep_invalidate(__addr, __ptep);			\
+		ptep_invalidate((__vma)->vm_mm, __addr, __ptep);	\
 		set_pte_at((__vma)->vm_mm, __addr, __ptep, __entry);	\
 	}								\
 	__changed;							\
Index: quilt-2.6/include/asm-s390/tlbflush.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlbflush.h
+++ quilt-2.6/include/asm-s390/tlbflush.h
@@ -61,10 +61,8 @@ static inline void __tlb_flush_mm(struct
 	 * only ran on the local cpu.
 	 */
 	if (MACHINE_HAS_IDTE) {
-		pgd_t *shadow_pgd = get_shadow_table(mm->pgd);
-
-		if (shadow_pgd)
-			__tlb_flush_idte(shadow_pgd);
+		if (mm->context.noexec)
+			__tlb_flush_idte(get_shadow_table(mm->pgd));
 		__tlb_flush_idte(mm->pgd);
 		return;
 	}
Index: quilt-2.6/include/asm-s390/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlb.h
+++ quilt-2.6/include/asm-s390/tlb.h
@@ -95,14 +95,14 @@ static inline void tlb_remove_page(struc
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
  */
-static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t page)
+static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte)
 {
 	if (!tlb->fullmm) {
-		tlb->array[tlb->nr_ptes++] = page;
+		tlb->array[tlb->nr_ptes++] = pte;
 		if (tlb->nr_ptes >= tlb->nr_pmds)
 			tlb_flush_mmu(tlb, 0, 0);
 	} else
-		pte_free(tlb->mm, page);
+		pte_free(tlb->mm, pte);
 }
 
 /*

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
