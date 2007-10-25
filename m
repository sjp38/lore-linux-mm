Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ3O2277980
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:03 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ3el1876120
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:03 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ2t8016639
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:02 +0200
Message-Id: <20071025181902.293056406@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:25 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/6] s390: Add four level page tables for CONFIG_64BIT=y.
Content-Disposition: inline; filename=005-mm-pud.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/mm/init.c            |    4 +-
 arch/s390/mm/vmem.c            |   16 ++++++++++-
 include/asm-s390/a.out.h       |    9 +++++-
 include/asm-s390/elf.h         |    9 ------
 include/asm-s390/mmu_context.h |    2 -
 include/asm-s390/pgalloc.h     |   29 +++++++++++++++++---
 include/asm-s390/pgtable.h     |   57 ++++++++++++++++++++++++++++++++---------
 include/asm-s390/processor.h   |   11 ++-----
 include/asm-s390/tlb.h         |   33 +++++++++++++++++------
 9 files changed, 122 insertions(+), 48 deletions(-)

Index: quilt-2.6/arch/s390/mm/init.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/init.c
+++ quilt-2.6/arch/s390/mm/init.c
@@ -112,8 +112,8 @@ void __init paging_init(void)
 	init_mm.pgd = swapper_pg_dir;
 	S390_lowcore.kernel_asce = __pa(init_mm.pgd) & PAGE_MASK;
 #ifdef CONFIG_64BIT
-	S390_lowcore.kernel_asce |= _ASCE_TYPE_REGION3 | _ASCE_TABLE_LENGTH;
-	pgd_type = _REGION3_ENTRY_EMPTY;
+	S390_lowcore.kernel_asce |= _ASCE_TYPE_REGION2 | _ASCE_TABLE_LENGTH;
+	pgd_type = _REGION2_ENTRY_EMPTY;
 #else
 	S390_lowcore.kernel_asce |= _ASCE_TABLE_LENGTH;
 	pgd_type = _SEGMENT_ENTRY_EMPTY;
Index: quilt-2.6/arch/s390/mm/vmem.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/vmem.c
+++ quilt-2.6/arch/s390/mm/vmem.c
@@ -73,8 +73,6 @@ static void __init_refok *vmem_alloc_pag
 	return alloc_bootmem_pages((1 << order) * PAGE_SIZE);
 }
 
-#define vmem_pud_alloc()	({ BUG(); ((pud_t *) NULL); })
-
 static inline void *vmem_alloc_slab(size_t size)
 {
 	if (slab_is_available())
@@ -82,6 +80,20 @@ static inline void *vmem_alloc_slab(size
 	return alloc_bootmem(size);
 }
 
+static inline pud_t *vmem_pud_alloc(void)
+{
+	pud_t *pud = NULL;
+
+#ifdef CONFIG_64BIT
+	pud = vmem_alloc_pages(2);
+	if (!pud)
+		return NULL;
+	pud_val(*pud) = _REGION3_ENTRY_EMPTY;
+	memcpy(pud + 1, pud, (PTRS_PER_PUD - 1)*sizeof(pud_t));
+#endif
+	return pud;
+}
+
 static inline pmd_t *vmem_pmd_alloc(void)
 {
 	pmd_t *pmd = NULL;
Index: quilt-2.6/include/asm-s390/a.out.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/a.out.h
+++ quilt-2.6/include/asm-s390/a.out.h
@@ -31,8 +31,13 @@ struct exec
 
 #ifdef __KERNEL__
 
-#define STACK_TOP	TASK_SIZE
-#define STACK_TOP_MAX	DEFAULT_TASK_SIZE
+#ifndef __s390x__
+#define STACK_TOP		(1UL << 31)
+#else /* __s390x__ */
+#define STACK_TOP		(1UL << (test_thread_flag(TIF_31BIT) ? 31:53))
+#endif /* __s390x__ */
+
+#define STACK_TOP_MAX		STACK_TOP
 
 #endif
 
Index: quilt-2.6/include/asm-s390/elf.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/elf.h
+++ quilt-2.6/include/asm-s390/elf.h
@@ -139,14 +139,7 @@ typedef s390_regs elf_gregset_t;
    use of this is to invoke "./ld.so someprog" to test out a new version of
    the loader.  We need to make sure that it is out of the way of the program
    that it will "exec", and that there is sufficient room for the brk.  */
-
-#ifndef __s390x__
-#define ELF_ET_DYN_BASE         ((TASK_SIZE & 0x80000000) \
-                                ? TASK_SIZE / 3 * 2 \
-                                : 2 * TASK_SIZE / 3)
-#else /* __s390x__ */
-#define ELF_ET_DYN_BASE         (TASK_SIZE / 3 * 2)
-#endif /* __s390x__ */
+#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
 
 /* Wow, the "main" arch needs arch dependent functions too.. :) */
 
Index: quilt-2.6/include/asm-s390/mmu_context.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/mmu_context.h
+++ quilt-2.6/include/asm-s390/mmu_context.h
@@ -35,7 +35,7 @@ static inline void update_mm(struct mm_s
 	/* Calculate asce bits from the first pgd table entry. */
 	asce_bits = _ASCE_TABLE_LENGTH | _ASCE_USER_BITS;
 #ifdef CONFIG_64BIT
-	asce_bits |= _ASCE_TYPE_REGION3;
+	asce_bits |= _ASCE_TYPE_REGION2;
 #endif
 	S390_lowcore.user_asce = asce_bits | __pa(pgd);
 	if (switch_amode) {
Index: quilt-2.6/include/asm-s390/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgalloc.h
+++ quilt-2.6/include/asm-s390/pgalloc.h
@@ -73,11 +73,17 @@ static inline unsigned long pgd_entry_ty
 
 static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 {
-	return _REGION3_ENTRY_EMPTY;
+	return _REGION2_ENTRY_EMPTY;
 }
 
-#define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
-#define pud_free(mm, x)				do { } while (0)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+	if (table)
+		crst_table_init(table, _REGION3_ENTRY_EMPTY);
+	return (pud_t *) table;
+}
+#define pud_free(mm, pud) crst_table_free(mm, (unsigned long *) pud)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
 {
@@ -88,8 +94,21 @@ static inline pmd_t *pmd_alloc_one(struc
 }
 #define pmd_free(mm, pmd) crst_table_free(mm, (unsigned long *) pmd)
 
-#define pgd_populate(mm, pgd, pud)		BUG()
-#define pgd_populate_kernel(mm, pgd, pud)	BUG()
+static inline void pgd_populate_kernel(struct mm_struct *mm,
+				       pgd_t *pgd, pud_t *pud)
+{
+	pgd_val(*pgd) = _REGION2_ENTRY | __pa(pud);
+}
+
+static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
+{
+	pgd_t *shadow_pgd = get_shadow_table(pgd);
+	pud_t *shadow_pud = get_shadow_table(pud);
+
+	if (shadow_pgd && shadow_pud)
+		pgd_populate_kernel(mm, shadow_pgd, shadow_pud);
+	pgd_populate_kernel(mm, pgd, pud);
+}
 
 static inline void pud_populate_kernel(struct mm_struct *mm,
 				       pud_t *pud, pmd_t *pmd)
Index: quilt-2.6/include/asm-s390/pgtable.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgtable.h
+++ quilt-2.6/include/asm-s390/pgtable.h
@@ -63,15 +63,15 @@ extern char empty_zero_page[PAGE_SIZE];
 #else /* __s390x__ */
 # define PMD_SHIFT	20
 # define PUD_SHIFT	31
-# define PGDIR_SHIFT	31
+# define PGDIR_SHIFT	42
 #endif /* __s390x__ */
 
 #define PMD_SIZE        (1UL << PMD_SHIFT)
 #define PMD_MASK        (~(PMD_SIZE-1))
 #define PUD_SIZE	(1UL << PUD_SHIFT)
 #define PUD_MASK	(~(PUD_SIZE-1))
-#define PGDIR_SIZE      (1UL << PGDIR_SHIFT)
-#define PGDIR_MASK      (~(PGDIR_SIZE-1))
+#define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
+#define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
 /*
  * entries per page directory level: the S390 is two-level, so
@@ -82,10 +82,11 @@ extern char empty_zero_page[PAGE_SIZE];
 #define PTRS_PER_PTE	256
 #ifndef __s390x__
 #define PTRS_PER_PMD	1
+#define PTRS_PER_PUD	1
 #else /* __s390x__ */
 #define PTRS_PER_PMD	2048
+#define PTRS_PER_PUD	2048
 #endif /* __s390x__ */
-#define PTRS_PER_PUD	1
 #define PTRS_PER_PGD	2048
 
 #define FIRST_USER_ADDRESS  0
@@ -425,9 +426,23 @@ static inline int pud_bad(pud_t pud)	 { 
 
 #else /* __s390x__ */
 
-static inline int pgd_present(pgd_t pgd) { return 1; }
-static inline int pgd_none(pgd_t pgd)	 { return 0; }
-static inline int pgd_bad(pgd_t pgd)	 { return 0; }
+static inline int pgd_present(pgd_t pgd)
+{
+	return pgd_val(pgd) & _REGION_ENTRY_ORIGIN;
+}
+
+static inline int pgd_none(pgd_t pgd)
+{
+	return pgd_val(pgd) & _REGION_ENTRY_INV;
+}
+
+static inline int pgd_bad(pgd_t pgd)
+{
+	unsigned long mask =
+		~_REGION_ENTRY_ORIGIN & ~_REGION_ENTRY_INV &
+		~_REGION_ENTRY_TYPE_MASK & ~_REGION_ENTRY_LENGTH;
+	return (pgd_val(pgd) & mask) != 0;
+}
 
 static inline int pud_present(pud_t pud)
 {
@@ -441,8 +456,10 @@ static inline int pud_none(pud_t pud)
 
 static inline int pud_bad(pud_t pud)
 {
-	unsigned long mask = ~_REGION_ENTRY_ORIGIN & ~_REGION_ENTRY_INV;
-	return (pud_val(pud) & mask) != _REGION3_ENTRY;
+	unsigned long mask =
+		~_REGION_ENTRY_ORIGIN & ~_REGION_ENTRY_INV &
+		~_REGION_ENTRY_TYPE_MASK & ~_REGION_ENTRY_LENGTH;
+	return (pud_val(pud) & mask) != 0;
 }
 
 #endif /* __s390x__ */
@@ -523,7 +540,19 @@ static inline int pte_young(pte_t pte)
 
 #else /* __s390x__ */
 
-#define pgd_clear(pgd)		do { } while (0)
+static inline void pgd_clear_kernel(pgd_t * pgd)
+{
+	pgd_val(*pgd) = _REGION2_ENTRY_EMPTY;
+}
+
+static inline void pgd_clear(pgd_t * pgd)
+{
+	pgd_t *shadow = get_shadow_table(pgd);
+
+	pgd_clear_kernel(pgd);
+	if (shadow)
+		pgd_clear_kernel(shadow);
+}
 
 static inline void pud_clear_kernel(pud_t *pud)
 {
@@ -815,9 +844,13 @@ static inline pte_t mk_pte(struct page *
 
 #define pmd_deref(pmd) (pmd_val(pmd) & _SEGMENT_ENTRY_ORIGIN)
 #define pud_deref(pud) (pud_val(pud) & _REGION_ENTRY_ORIGIN)
-#define pgd_deref(pgd) ({ BUG(); 0UL; })
+#define pgd_deref(pgd) (pgd_val(pgd) & _REGION_ENTRY_ORIGIN)
 
-#define pud_offset(pgd, address) ((pud_t *) pgd)
+static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
+{
+	pud_t *pud = (pud_t *) pgd_deref(*pgd);
+	return pud  + pud_index(address);
+}
 
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 {
Index: quilt-2.6/include/asm-s390/processor.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/processor.h
+++ quilt-2.6/include/asm-s390/processor.h
@@ -67,16 +67,13 @@ extern struct task_struct *last_task_use
  */
 #ifndef __s390x__
 
-# define TASK_SIZE		(0x80000000UL)
-# define TASK_UNMAPPED_BASE	(TASK_SIZE / 2)
-# define DEFAULT_TASK_SIZE	(0x80000000UL)
+#define TASK_SIZE		(1UL << 31)
+#define TASK_UNMAPPED_BASE	(1UL << 30)
 
 #else /* __s390x__ */
 
-# define TASK_SIZE		(test_thread_flag(TIF_31BIT) ? \
-					(0x80000000UL) : (0x40000000000UL))
-# define TASK_UNMAPPED_BASE	(TASK_SIZE / 2)
-# define DEFAULT_TASK_SIZE	(0x40000000000UL)
+#define TASK_SIZE		(1UL << (test_thread_flag(TIF_31BIT) ? 31:53))
+#define TASK_UNMAPPED_BASE	(1UL << (test_thread_flag(TIF_31BIT) ? 30:41))
 
 #endif /* __s390x__ */
 
Index: quilt-2.6/include/asm-s390/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlb.h
+++ quilt-2.6/include/asm-s390/tlb.h
@@ -38,7 +38,7 @@ struct mmu_gather {
 	struct mm_struct *mm;
 	unsigned int fullmm;
 	unsigned int nr_ptes;
-	unsigned int nr_pmds;
+	unsigned int nr_pxds;
 	void *array[TLB_NR_PTRS];
 };
 
@@ -53,7 +53,7 @@ static inline struct mmu_gather *tlb_gat
 	tlb->fullmm = full_mm_flush || (num_online_cpus() == 1) ||
 		(atomic_read(&mm->mm_users) <= 1 && mm == current->active_mm);
 	tlb->nr_ptes = 0;
-	tlb->nr_pmds = TLB_NR_PTRS;
+	tlb->nr_pxds = TLB_NR_PTRS;
 	if (tlb->fullmm)
 		__tlb_flush_mm(mm);
 	return tlb;
@@ -62,12 +62,13 @@ static inline struct mmu_gather *tlb_gat
 static inline void tlb_flush_mmu(struct mmu_gather *tlb,
 				 unsigned long start, unsigned long end)
 {
-	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pmds < TLB_NR_PTRS))
+	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pxds < TLB_NR_PTRS))
 		__tlb_flush_mm(tlb->mm);
 	while (tlb->nr_ptes > 0)
 		pte_free(tlb->mm, tlb->array[--tlb->nr_ptes]);
-	while (tlb->nr_pmds < TLB_NR_PTRS)
-		pmd_free(tlb->mm, (pmd_t *) tlb->array[tlb->nr_pmds++]);
+	while (tlb->nr_pxds < TLB_NR_PTRS)
+		/* pgd_free frees the pointer as region or segment table */
+		pgd_free(tlb->mm, tlb->array[tlb->nr_pxds++]);
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
@@ -99,7 +100,7 @@ static inline void pte_free_tlb(struct m
 {
 	if (!tlb->fullmm) {
 		tlb->array[tlb->nr_ptes++] = pte;
-		if (tlb->nr_ptes >= tlb->nr_pmds)
+		if (tlb->nr_ptes >= tlb->nr_pxds)
 			tlb_flush_mmu(tlb, 0, 0);
 	} else
 		pte_free(tlb->mm, pte);
@@ -113,15 +114,29 @@ static inline void pmd_free_tlb(struct m
 {
 #ifdef __s390x__
 	if (!tlb->fullmm) {
-		tlb->array[--tlb->nr_pmds] = (struct page *) pmd;
-		if (tlb->nr_ptes >= tlb->nr_pmds)
+		tlb->array[--tlb->nr_pxds] = pmd;
+		if (tlb->nr_ptes >= tlb->nr_pxds)
 			tlb_flush_mmu(tlb, 0, 0);
 	} else
 		pmd_free(tlb->mm, pmd);
 #endif
 }
 
-#define pud_free_tlb(tlb, pud)			do { } while (0)
+/*
+ * pud_free_tlb frees a pud table and clears the CRSTE for the
+ * region third table entry from the tlb.
+ */
+static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
+{
+#ifdef __s390x__
+	if (!tlb->fullmm) {
+		tlb->array[--tlb->nr_pxds] = pud;
+		if (tlb->nr_ptes >= tlb->nr_pxds)
+			tlb_flush_mmu(tlb, 0, 0);
+	} else
+		pud_free(tlb->mm, pud);
+#endif
+}
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
