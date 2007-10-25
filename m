Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ1NC065444
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ1P31933392
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ1RJ016576
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Message-Id: <20071025181900.837019250@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:21 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/6] add mm argument to pte/pmd/pud/pgd_free.
Content-Disposition: inline; filename=001-mm-pxdfree.diff
Sender: owner-linux-mm@kvack.org
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

The pgd/pud/pmd/pte page table allocation functions get a mm_struct
pointer as first argument. The free functions do not get the mm_struct
argument. This is 1) asymmetrical and 2) to do mm related page table
allocations the mm argument is needed on the free function as well.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/arm/kernel/smp.c               |    2 +-
 arch/arm/mm/ioremap.c               |    2 +-
 arch/arm/mm/pgd.c                   |    8 ++++----
 arch/frv/mm/pgalloc.c               |    2 +-
 arch/powerpc/mm/pgtable_32.c        |    6 +++---
 arch/ppc/mm/pgtable.c               |    6 +++---
 arch/um/kernel/mem.c                |    2 +-
 arch/um/kernel/skas/mmu.c           |    8 ++++----
 arch/x86/mm/pgtable_32.c            |    2 +-
 include/asm-alpha/pgalloc.h         |    8 ++++----
 include/asm-alpha/tlb.h             |    4 ++--
 include/asm-arm/pgalloc.h           |   10 +++++-----
 include/asm-arm/tlb.h               |    4 ++--
 include/asm-avr32/pgalloc.h         |    6 +++---
 include/asm-cris/pgalloc.h          |    6 +++---
 include/asm-frv/pgalloc.h           |    8 ++++----
 include/asm-frv/pgtable.h           |    2 +-
 include/asm-generic/4level-fixup.h  |    2 +-
 include/asm-generic/pgtable-nopmd.h |    2 +-
 include/asm-generic/pgtable-nopud.h |    2 +-
 include/asm-ia64/pgalloc.h          |   16 ++++++++--------
 include/asm-m32r/pgalloc.h          |   10 +++++-----
 include/asm-m68k/motorola_pgalloc.h |   10 +++++-----
 include/asm-m68k/sun3_pgalloc.h     |    8 ++++----
 include/asm-mips/pgalloc.h          |   12 ++++++------
 include/asm-parisc/pgalloc.h        |   10 +++++-----
 include/asm-parisc/tlb.h            |    4 ++--
 include/asm-powerpc/pgalloc-32.h    |   10 +++++-----
 include/asm-powerpc/pgalloc-64.h    |   10 +++++-----
 include/asm-ppc/pgalloc.h           |   10 +++++-----
 include/asm-s390/pgalloc.h          |   14 +++++++-------
 include/asm-s390/tlb.h              |    8 ++++----
 include/asm-sh/pgalloc.h            |    8 ++++----
 include/asm-sh64/pgalloc.h          |   12 ++++++------
 include/asm-sparc/pgalloc.h         |   12 ++++++------
 include/asm-sparc64/pgalloc.h       |    8 ++++----
 include/asm-sparc64/tlb.h           |    4 ++--
 include/asm-um/pgalloc.h            |    8 ++++----
 include/asm-x86/pgalloc_32.h        |    8 ++++----
 include/asm-x86/pgalloc_64.h        |   10 +++++-----
 include/asm-xtensa/pgalloc.h        |    6 +++---
 include/asm-xtensa/tlb.h            |    2 +-
 kernel/fork.c                       |    2 +-
 mm/memory.c                         |   10 +++++-----
 44 files changed, 152 insertions(+), 152 deletions(-)

Index: quilt-2.6/arch/arm/kernel/smp.c
===================================================================
--- quilt-2.6.orig/arch/arm/kernel/smp.c
+++ quilt-2.6/arch/arm/kernel/smp.c
@@ -150,7 +150,7 @@ int __cpuinit __cpu_up(unsigned int cpu)
 	secondary_data.pgdir = 0;
 
 	*pmd_offset(pgd, PHYS_OFFSET) = __pmd(0);
-	pgd_free(pgd);
+	pgd_free(&init_mm, pgd);
 
 	if (ret) {
 		printk(KERN_CRIT "CPU%u: processor failed to boot\n", cpu);
Index: quilt-2.6/arch/arm/mm/ioremap.c
===================================================================
--- quilt-2.6.orig/arch/arm/mm/ioremap.c
+++ quilt-2.6/arch/arm/mm/ioremap.c
@@ -162,7 +162,7 @@ static void unmap_area_sections(unsigned
 			 * Free the page table, if there was one.
 			 */
 			if ((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_TABLE)
-				pte_free_kernel(pmd_page_vaddr(pmd));
+				pte_free_kernel(&init_mm, pmd_page_vaddr(pmd));
 		}
 
 		addr += PGDIR_SIZE;
Index: quilt-2.6/arch/arm/mm/pgd.c
===================================================================
--- quilt-2.6.orig/arch/arm/mm/pgd.c
+++ quilt-2.6/arch/arm/mm/pgd.c
@@ -65,14 +65,14 @@ pgd_t *get_pgd_slow(struct mm_struct *mm
 	return new_pgd;
 
 no_pte:
-	pmd_free(new_pmd);
+	pmd_free(mm, new_pmd);
 no_pmd:
 	free_pages((unsigned long)new_pgd, 2);
 no_pgd:
 	return NULL;
 }
 
-void free_pgd_slow(pgd_t *pgd)
+void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd)
 {
 	pmd_t *pmd;
 	struct page *pte;
@@ -94,8 +94,8 @@ void free_pgd_slow(pgd_t *pgd)
 	pmd_clear(pmd);
 	dec_zone_page_state(virt_to_page((unsigned long *)pgd), NR_PAGETABLE);
 	pte_lock_deinit(pte);
-	pte_free(pte);
-	pmd_free(pmd);
+	pte_free(mm, pte);
+	pmd_free(mm, pmd);
 free:
 	free_pages((unsigned long) pgd, 2);
 }
Index: quilt-2.6/arch/frv/mm/pgalloc.c
===================================================================
--- quilt-2.6.orig/arch/frv/mm/pgalloc.c
+++ quilt-2.6/arch/frv/mm/pgalloc.c
@@ -140,7 +140,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	/* in the non-PAE case, clear_page_tables() clears user pgd entries */
  	quicklist_free(0, pgd_dtor, pgd);
Index: quilt-2.6/arch/powerpc/mm/pgtable_32.c
===================================================================
--- quilt-2.6.orig/arch/powerpc/mm/pgtable_32.c
+++ quilt-2.6/arch/powerpc/mm/pgtable_32.c
@@ -86,7 +86,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return ret;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGDIR_ORDER);
 }
@@ -123,7 +123,7 @@ struct page *pte_alloc_one(struct mm_str
 	return ptepage;
 }
 
-void pte_free_kernel(pte_t *pte)
+void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
@@ -131,7 +131,7 @@ void pte_free_kernel(pte_t *pte)
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct page *ptepage)
+void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
Index: quilt-2.6/arch/ppc/mm/pgtable.c
===================================================================
--- quilt-2.6.orig/arch/ppc/mm/pgtable.c
+++ quilt-2.6/arch/ppc/mm/pgtable.c
@@ -87,7 +87,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return ret;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGDIR_ORDER);
 }
@@ -124,7 +124,7 @@ struct page *pte_alloc_one(struct mm_str
 	return ptepage;
 }
 
-void pte_free_kernel(pte_t *pte)
+void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
@@ -132,7 +132,7 @@ void pte_free_kernel(pte_t *pte)
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct page *ptepage)
+void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
Index: quilt-2.6/arch/um/kernel/mem.c
===================================================================
--- quilt-2.6.orig/arch/um/kernel/mem.c
+++ quilt-2.6/arch/um/kernel/mem.c
@@ -348,7 +348,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long) pgd);
 }
Index: quilt-2.6/arch/um/kernel/skas/mmu.c
===================================================================
--- quilt-2.6.orig/arch/um/kernel/skas/mmu.c
+++ quilt-2.6/arch/um/kernel/skas/mmu.c
@@ -58,9 +58,9 @@ static int init_stub_pte(struct mm_struc
 	return 0;
 
  out_pmd:
-	pud_free(pud);
+	pud_free(mm, pud);
  out_pte:
-	pmd_free(pmd);
+	pmd_free(mm, pmd);
  out:
 	return -ENOMEM;
 }
@@ -144,10 +144,10 @@ void destroy_context(struct mm_struct *m
 	if (!proc_mm || !ptrace_faultinfo) {
 		free_page(mmu->id.stack);
 		pte_lock_deinit(virt_to_page(mmu->last_page_table));
-		pte_free_kernel((pte_t *) mmu->last_page_table);
+		pte_free_kernel(mm, (pte_t *) mmu->last_page_table);
 		dec_zone_page_state(virt_to_page(mmu->last_page_table), NR_PAGETABLE);
 #ifdef CONFIG_3_LEVEL_PGTABLES
-		pmd_free((pmd_t *) mmu->last_pmd);
+		pmd_free(mm, (pmd_t *) mmu->last_pmd);
 #endif
 	}
 
Index: quilt-2.6/arch/x86/mm/pgtable_32.c
===================================================================
--- quilt-2.6.orig/arch/x86/mm/pgtable_32.c
+++ quilt-2.6/arch/x86/mm/pgtable_32.c
@@ -352,7 +352,7 @@ out_oom:
 	return NULL;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	int i;
 
Index: quilt-2.6/include/asm-alpha/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-alpha/pgalloc.h
+++ quilt-2.6/include/asm-alpha/pgalloc.h
@@ -31,7 +31,7 @@ pgd_populate(struct mm_struct *mm, pgd_t
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 
 static inline void
-pgd_free(pgd_t *pgd)
+pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -44,7 +44,7 @@ pmd_alloc_one(struct mm_struct *mm, unsi
 }
 
 static inline void
-pmd_free(pmd_t *pmd)
+pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
@@ -52,7 +52,7 @@ pmd_free(pmd_t *pmd)
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 
 static inline void
-pte_free_kernel(pte_t *pte)
+pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
@@ -67,7 +67,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 }
 
 static inline void
-pte_free(struct page *page)
+pte_free(struct mm_struct *mm, struct page *page)
 {
 	__free_page(page);
 }
Index: quilt-2.6/include/asm-alpha/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-alpha/tlb.h
+++ quilt-2.6/include/asm-alpha/tlb.h
@@ -9,7 +9,7 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free(pte)
-#define __pmd_free_tlb(tlb,pmd)			pmd_free(pmd)
+#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb,pmd)			pmd_free((tlb)->mm, pmd)
  
 #endif
Index: quilt-2.6/include/asm-arm/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-arm/pgalloc.h
+++ quilt-2.6/include/asm-arm/pgalloc.h
@@ -27,14 +27,14 @@
  * Since we have only two-level page tables, these are trivial
  */
 #define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(pmd)			do { } while (0)
+#define pmd_free(mm,pmd)		do { } while (0)
 #define pgd_populate(mm,pmd,pte)	BUG()
 
 extern pgd_t *get_pgd_slow(struct mm_struct *mm);
-extern void free_pgd_slow(pgd_t *pgd);
+extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
 
 #define pgd_alloc(mm)			get_pgd_slow(mm)
-#define pgd_free(pgd)			free_pgd_slow(pgd)
+#define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
 
 /*
  * Allocate one PTE table.
@@ -83,7 +83,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 /*
  * Free one PTE table.
  */
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	if (pte) {
 		pte -= PTRS_PER_PTE;
@@ -91,7 +91,7 @@ static inline void pte_free_kernel(pte_t
 	}
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: quilt-2.6/include/asm-arm/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-arm/tlb.h
+++ quilt-2.6/include/asm-arm/tlb.h
@@ -85,8 +85,8 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb,ptep)		pte_free(ptep)
-#define pmd_free_tlb(tlb,pmdp)		pmd_free(pmdp)
+#define pte_free_tlb(tlb,ptep)		pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb,pmdp)		pmd_free((tlb)->mm, pmdp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
Index: quilt-2.6/include/asm-avr32/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-avr32/pgalloc.h
+++ quilt-2.6/include/asm-avr32/pgalloc.h
@@ -30,7 +30,7 @@ static __inline__ pgd_t *pgd_alloc(struc
 	return kcalloc(USER_PTRS_PER_PGD, sizeof(pgd_t), GFP_KERNEL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	kfree(pgd);
 }
@@ -55,12 +55,12 @@ static inline struct page *pte_alloc_one
 	return pte;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: quilt-2.6/include/asm-cris/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-cris/pgalloc.h
+++ quilt-2.6/include/asm-cris/pgalloc.h
@@ -16,7 +16,7 @@ static inline pgd_t *pgd_alloc (struct m
 	return (pgd_t *)get_zeroed_page(GFP_KERNEL);
 }
 
-static inline void pgd_free (pgd_t *pgd)
+static inline void pgd_free (struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -34,12 +34,12 @@ static inline struct page *pte_alloc_one
 	return pte;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: quilt-2.6/include/asm-frv/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-frv/pgalloc.h
+++ quilt-2.6/include/asm-frv/pgalloc.h
@@ -31,18 +31,18 @@ do {										\
  */
 
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *);
+extern void pgd_free(struct mm_struct *mm, pgd_t *);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -55,7 +55,7 @@ static inline void pte_free(struct page 
  * (In the PAE case we free the pmds as part of the pgd.)
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 #endif /* CONFIG_MMU */
Index: quilt-2.6/include/asm-frv/pgtable.h
===================================================================
--- quilt-2.6.orig/include/asm-frv/pgtable.h
+++ quilt-2.6/include/asm-frv/pgtable.h
@@ -226,7 +226,7 @@ static inline pud_t *pud_offset(pgd_t *p
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pud_alloc_one(mm, address)		NULL
-#define pud_free(x)				do { } while (0)
+#define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x)			do { } while (0)
 
 /*
Index: quilt-2.6/include/asm-generic/4level-fixup.h
===================================================================
--- quilt-2.6.orig/include/asm-generic/4level-fixup.h
+++ quilt-2.6/include/asm-generic/4level-fixup.h
@@ -28,7 +28,7 @@
 
 #undef pud_free_tlb
 #define pud_free_tlb(tlb, x)            do { } while (0)
-#define pud_free(x)			do { } while (0)
+#define pud_free(mm, x)			do { } while (0)
 #define __pud_free_tlb(tlb, x)		do { } while (0)
 
 #undef  pud_addr_end
Index: quilt-2.6/include/asm-generic/pgtable-nopmd.h
===================================================================
--- quilt-2.6.orig/include/asm-generic/pgtable-nopmd.h
+++ quilt-2.6/include/asm-generic/pgtable-nopmd.h
@@ -54,7 +54,7 @@ static inline pmd_t * pmd_offset(pud_t *
  * inside the pud, so has no extra memory associated with it.
  */
 #define pmd_alloc_one(mm, address)		NULL
-#define pmd_free(x)				do { } while (0)
+#define pmd_free(mm, x)				do { } while (0)
 #define __pmd_free_tlb(tlb, x)			do { } while (0)
 
 #undef  pmd_addr_end
Index: quilt-2.6/include/asm-generic/pgtable-nopud.h
===================================================================
--- quilt-2.6.orig/include/asm-generic/pgtable-nopud.h
+++ quilt-2.6/include/asm-generic/pgtable-nopud.h
@@ -51,7 +51,7 @@ static inline pud_t * pud_offset(pgd_t *
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pud_alloc_one(mm, address)		NULL
-#define pud_free(x)				do { } while (0)
+#define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x)			do { } while (0)
 
 #undef  pud_addr_end
Index: quilt-2.6/include/asm-ia64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-ia64/pgalloc.h
+++ quilt-2.6/include/asm-ia64/pgalloc.h
@@ -27,7 +27,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t * pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t * pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -44,11 +44,11 @@ static inline pud_t *pud_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pud_free(pud_t * pud)
+static inline void pud_free(struct mm_struct *mm, pud_t * pud)
 {
 	quicklist_free(0, NULL, pud);
 }
-#define __pud_free_tlb(tlb, pud)	pud_free(pud)
+#define __pud_free_tlb(tlb, pud)	pud_free((tlb)->mm, pud)
 #endif /* CONFIG_PGTABLE_4 */
 
 static inline void
@@ -62,12 +62,12 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t * pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t * pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
 
 static inline void
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
@@ -94,12 +94,12 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(0, NULL, pte);
 }
 
-static inline void pte_free_kernel(pte_t * pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t * pte)
 {
 	quicklist_free(0, NULL, pte);
 }
@@ -109,6 +109,6 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: quilt-2.6/include/asm-m32r/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m32r/pgalloc.h
+++ quilt-2.6/include/asm-m32r/pgalloc.h
@@ -24,7 +24,7 @@ static __inline__ pgd_t *pgd_alloc(struc
 	return pgd;
 }
 
-static __inline__ void pgd_free(pgd_t *pgd)
+static __inline__ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -46,17 +46,17 @@ static __inline__ struct page *pte_alloc
 	return pte;
 }
 
-static __inline__ void pte_free_kernel(pte_t *pte)
+static __inline__ void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static __inline__ void pte_free(struct page *pte)
+static __inline__ void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -65,7 +65,7 @@ static __inline__ void pte_free(struct p
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
Index: quilt-2.6/include/asm-m68k/motorola_pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m68k/motorola_pgalloc.h
+++ quilt-2.6/include/asm-m68k/motorola_pgalloc.h
@@ -22,7 +22,7 @@ static inline pte_t *pte_alloc_one_kerne
 	return pte;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	cache_page(pte);
 	free_page((unsigned long) pte);
@@ -47,7 +47,7 @@ static inline struct page *pte_alloc_one
 	return page;
 }
 
-static inline void pte_free(struct page *page)
+static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
 	cache_page(kmap(page));
 	kunmap(page);
@@ -67,7 +67,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return get_pointer_table();
 }
 
-static inline int pmd_free(pmd_t *pmd)
+static inline int pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	return free_pointer_table(pmd);
 }
@@ -78,9 +78,9 @@ static inline int __pmd_free_tlb(struct 
 }
 
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
-	pmd_free((pmd_t *)pgd);
+	pmd_free(mm, (pmd_t *)pgd);
 }
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
Index: quilt-2.6/include/asm-m68k/sun3_pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m68k/sun3_pgalloc.h
+++ quilt-2.6/include/asm-m68k/sun3_pgalloc.h
@@ -21,12 +21,12 @@ extern const char bad_pmd_string[];
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 
 
-static inline void pte_free_kernel(pte_t * pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t * pte)
 {
         free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct page *page)
+static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
         __free_page(page);
 }
@@ -72,10 +72,10 @@ static inline void pmd_populate(struct m
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 
-static inline void pgd_free(pgd_t * pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t * pgd)
 {
         free_page((unsigned long) pgd);
 }
Index: quilt-2.6/include/asm-mips/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-mips/pgalloc.h
+++ quilt-2.6/include/asm-mips/pgalloc.h
@@ -58,7 +58,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return ret;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
@@ -85,12 +85,12 @@ static inline struct page *pte_alloc_one
 	return pte;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_pages((unsigned long)pte, PTE_ORDER);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_pages(pte, PTE_ORDER);
 }
@@ -103,7 +103,7 @@ static inline void pte_free(struct page 
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 
 #endif
@@ -120,12 +120,12 @@ static inline pmd_t *pmd_alloc_one(struc
 	return pmd;
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
 
-#define __pmd_free_tlb(tlb, x)	pmd_free(x)
+#define __pmd_free_tlb(tlb, x)	pmd_free((tlb)->mm, x)
 
 #endif
 
Index: quilt-2.6/include/asm-parisc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-parisc/pgalloc.h
+++ quilt-2.6/include/asm-parisc/pgalloc.h
@@ -43,7 +43,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return actual_pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 #ifdef CONFIG_64BIT
 	pgd -= PTRS_PER_PGD;
@@ -70,7 +70,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return pmd;
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 #ifdef CONFIG_64BIT
 	if(pmd_flag(*pmd) & PxD_FLAG_ATTACHED)
@@ -91,7 +91,7 @@ static inline void pmd_free(pmd_t *pmd)
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #endif
@@ -130,12 +130,12 @@ pte_alloc_one_kernel(struct mm_struct *m
 	return pte;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-#define pte_free(page)	pte_free_kernel(page_address(page))
+#define pte_free(mm, page) pte_free_kernel(page_address(page))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: quilt-2.6/include/asm-parisc/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-parisc/tlb.h
+++ quilt-2.6/include/asm-parisc/tlb.h
@@ -21,7 +21,7 @@ do {	if (!(tlb)->fullmm)	\
 
 #include <asm-generic/tlb.h>
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif
Index: quilt-2.6/include/asm-powerpc/pgalloc-32.h
===================================================================
--- quilt-2.6.orig/include/asm-powerpc/pgalloc-32.h
+++ quilt-2.6/include/asm-powerpc/pgalloc-32.h
@@ -6,14 +6,14 @@
 extern void __bad_pte(pmd_t *pmd);
 
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 /*
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
 /* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
-#define pmd_free(x)                     do { } while (0)
+#define pmd_free(mm, x) 		do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 /* #define pgd_populate(mm, pmd, pte)      BUG() */
 
@@ -31,10 +31,10 @@ extern void pgd_free(pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
-extern void pte_free_kernel(pte_t *pte);
-extern void pte_free(struct page *pte);
+extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
+extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: quilt-2.6/include/asm-powerpc/pgalloc-64.h
===================================================================
--- quilt-2.6.orig/include/asm-powerpc/pgalloc-64.h
+++ quilt-2.6/include/asm-powerpc/pgalloc-64.h
@@ -25,7 +25,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return kmem_cache_alloc(pgtable_cache[PGD_CACHE_NUM], GFP_KERNEL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	kmem_cache_free(pgtable_cache[PGD_CACHE_NUM], pgd);
 }
@@ -40,7 +40,7 @@ static inline pud_t *pud_alloc_one(struc
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pud_free(pud_t *pud)
+static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 {
 	kmem_cache_free(pgtable_cache[PUD_CACHE_NUM], pud);
 }
@@ -76,7 +76,7 @@ static inline pmd_t *pmd_alloc_one(struc
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	kmem_cache_free(pgtable_cache[PMD_CACHE_NUM], pmd);
 }
@@ -94,12 +94,12 @@ static inline struct page *pte_alloc_one
 	return pte ? virt_to_page(pte) : NULL;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 	__free_page(ptepage);
 }
Index: quilt-2.6/include/asm-ppc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-ppc/pgalloc.h
+++ quilt-2.6/include/asm-ppc/pgalloc.h
@@ -7,14 +7,14 @@
 extern void __bad_pte(pmd_t *pmd);
 
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 /*
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)                     do { } while (0)
+#define pmd_free(mm, x) 		do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 
@@ -32,10 +32,10 @@ extern void pgd_free(pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
-extern void pte_free_kernel(pte_t *pte);
-extern void pte_free(struct page *pte);
+extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
+extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: quilt-2.6/include/asm-s390/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgalloc.h
+++ quilt-2.6/include/asm-s390/pgalloc.h
@@ -57,10 +57,10 @@ static inline unsigned long pgd_entry_ty
 }
 
 #define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
-#define pud_free(x)				do { } while (0)
+#define pud_free(mm, x)				do { } while (0)
 
 #define pmd_alloc_one(mm,address)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)				do { } while (0)
+#define pmd_free(mm, x)				do { } while (0)
 
 #define pgd_populate(mm, pgd, pud)		BUG()
 #define pgd_populate_kernel(mm, pgd, pud)	BUG()
@@ -76,7 +76,7 @@ static inline unsigned long pgd_entry_ty
 }
 
 #define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
-#define pud_free(x)				do { } while (0)
+#define pud_free(mm, x)				do { } while (0)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
 {
@@ -85,7 +85,7 @@ static inline pmd_t *pmd_alloc_one(struc
 		crst_table_init(crst, _SEGMENT_ENTRY_EMPTY);
 	return (pmd_t *) crst;
 }
-#define pmd_free(pmd) crst_table_free((unsigned long *) pmd)
+#define pmd_free(mm, pmd) crst_table_free((unsigned long *) pmd)
 
 #define pgd_populate(mm, pgd, pud)		BUG()
 #define pgd_populate_kernel(mm, pgd, pud)	BUG()
@@ -115,7 +115,7 @@ static inline pgd_t *pgd_alloc(struct mm
 		crst_table_init(crst, pgd_entry_type(mm));
 	return (pgd_t *) crst;
 }
-#define pgd_free(pgd) crst_table_free((unsigned long *) pgd)
+#define pgd_free(mm, pgd) crst_table_free((unsigned long *) pgd)
 
 static inline void 
 pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
@@ -151,9 +151,9 @@ pmd_populate(struct mm_struct *mm, pmd_t
 #define pte_alloc_one(mm, vmaddr) \
 	virt_to_page(page_table_alloc(s390_noexec))
 
-#define pte_free_kernel(pte) \
+#define pte_free_kernel(mm, pte) \
 	page_table_free((unsigned long *) pte)
-#define pte_free(pte) \
+#define pte_free(mm, pte) \
 	page_table_free((unsigned long *) page_to_phys((struct page *) pte))
 
 #endif /* _S390_PGALLOC_H */
Index: quilt-2.6/include/asm-s390/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlb.h
+++ quilt-2.6/include/asm-s390/tlb.h
@@ -65,9 +65,9 @@ static inline void tlb_flush_mmu(struct 
 	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pmds < TLB_NR_PTRS))
 		__tlb_flush_mm(tlb->mm);
 	while (tlb->nr_ptes > 0)
-		pte_free(tlb->array[--tlb->nr_ptes]);
+		pte_free(tlb->mm, tlb->array[--tlb->nr_ptes]);
 	while (tlb->nr_pmds < TLB_NR_PTRS)
-		pmd_free((pmd_t *) tlb->array[tlb->nr_pmds++]);
+		pmd_free(tlb->mm, (pmd_t *) tlb->array[tlb->nr_pmds++]);
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
@@ -102,7 +102,7 @@ static inline void pte_free_tlb(struct m
 		if (tlb->nr_ptes >= tlb->nr_pmds)
 			tlb_flush_mmu(tlb, 0, 0);
 	} else
-		pte_free(page);
+		pte_free(tlb->mm, page);
 }
 
 /*
@@ -117,7 +117,7 @@ static inline void pmd_free_tlb(struct m
 		if (tlb->nr_ptes >= tlb->nr_pmds)
 			tlb_flush_mmu(tlb, 0, 0);
 	} else
-		pmd_free(pmd);
+		pmd_free(tlb->mm, pmd);
 #endif
 }
 
Index: quilt-2.6/include/asm-sh/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sh/pgalloc.h
+++ quilt-2.6/include/asm-sh/pgalloc.h
@@ -36,7 +36,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(QUICK_PGD, GFP_KERNEL | __GFP_REPEAT, pgd_ctor);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(QUICK_PGD, NULL, pgd);
 }
@@ -54,12 +54,12 @@ static inline struct page *pte_alloc_one
 	return pg ? virt_to_page(pg) : NULL;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	quicklist_free(QUICK_PT, NULL, pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
@@ -71,7 +71,7 @@ static inline void pte_free(struct page 
  * inside the pgd, so has no extra memory associated with it.
  */
 
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 static inline void check_pgt_cache(void)
Index: quilt-2.6/include/asm-sh64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sh64/pgalloc.h
+++ quilt-2.6/include/asm-sh64/pgalloc.h
@@ -46,7 +46,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -58,12 +58,12 @@ static inline struct page *pte_alloc_one
 	return pg ? virt_to_page(pg) : NULL;
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(0, NULL, pte);
 }
@@ -84,7 +84,7 @@ static inline pte_t *pte_alloc_one_kerne
 #if defined(CONFIG_SH64_PGTABLE_2_LEVEL)
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 #define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
 #define __pmd_free_tlb(tlb,pmd)		do { } while (0)
@@ -96,13 +96,13 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
 
 #define pgd_populate(mm, pgd, pmd)	pgd_set(pgd, pmd)
-#define __pmd_free_tlb(tlb,pmd)		pmd_free(pmd)
+#define __pmd_free_tlb(tlb,pmd)		pmd_free((tlb)->mm, pmd)
 
 #else
 #error "No defined page table size"
Index: quilt-2.6/include/asm-sparc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc/pgalloc.h
+++ quilt-2.6/include/asm-sparc/pgalloc.h
@@ -32,7 +32,7 @@ BTFIXUPDEF_CALL(pgd_t *, get_pgd_fast, v
 BTFIXUPDEF_CALL(void, free_pgd_fast, pgd_t *)
 #define free_pgd_fast(pgd)	BTFIXUP_CALL(free_pgd_fast)(pgd)
 
-#define pgd_free(pgd)	free_pgd_fast(pgd)
+#define pgd_free(mm,pgd)	free_pgd_fast(pgd)
 #define pgd_alloc(mm)	get_pgd_fast()
 
 BTFIXUPDEF_CALL(void, pgd_set, pgd_t *, pmd_t *)
@@ -45,8 +45,8 @@ BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, 
 BTFIXUPDEF_CALL(void, free_pmd_fast, pmd_t *)
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
 
-#define pmd_free(pmd)           free_pmd_fast(pmd)
-#define __pmd_free_tlb(tlb, pmd) pmd_free(pmd)
+#define pmd_free(mm, pmd)	free_pmd_fast(pmd)
+#define __pmd_free_tlb(tlb, pmd) pmd_free((tlb)->mm, pmd)
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
@@ -59,10 +59,10 @@ BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_k
 #define pte_alloc_one_kernel(mm, addr)	BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr)
 
 BTFIXUPDEF_CALL(void, free_pte_fast, pte_t *)
-#define pte_free_kernel(pte)	BTFIXUP_CALL(free_pte_fast)(pte)
+#define pte_free_kernel(mm,pte)	BTFIXUP_CALL(free_pte_fast)(pte)
 
 BTFIXUPDEF_CALL(void, pte_free, struct page *)
-#define pte_free(pte)		BTFIXUP_CALL(pte_free)(pte)
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define pte_free(mm,pte)	BTFIXUP_CALL(pte_free)(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif /* _SPARC_PGALLOC_H */
Index: quilt-2.6/include/asm-sparc64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc64/pgalloc.h
+++ quilt-2.6/include/asm-sparc64/pgalloc.h
@@ -20,7 +20,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -32,7 +32,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
@@ -50,12 +50,12 @@ static inline struct page *pte_alloc_one
 	return pg ? virt_to_page(pg) : NULL;
 }
 		
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 	quicklist_free_page(0, NULL, ptepage);
 }
Index: quilt-2.6/include/asm-sparc64/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc64/tlb.h
+++ quilt-2.6/include/asm-sparc64/tlb.h
@@ -100,8 +100,8 @@ static inline void tlb_remove_page(struc
 }
 
 #define tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
-#define pte_free_tlb(mp,ptepage) pte_free(ptepage)
-#define pmd_free_tlb(mp,pmdp) pmd_free(pmdp)
+#define pte_free_tlb(mp,ptepage) pte_free((mp)->mm, ptepage)
+#define pmd_free_tlb(mp,pmdp) pmd_free((mp)->mm, pmdp)
 #define pud_free_tlb(tlb,pudp) __pud_free_tlb(tlb,pudp)
 
 #define tlb_migrate_finish(mm)	do { } while (0)
Index: quilt-2.6/include/asm-um/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-um/pgalloc.h
+++ quilt-2.6/include/asm-um/pgalloc.h
@@ -23,17 +23,17 @@
  * Allocate and free page tables.
  */
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -42,7 +42,7 @@ static inline void pte_free(struct page 
 
 #ifdef CONFIG_3_LEVEL_PGTABLES
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
Index: quilt-2.6/include/asm-x86/pgalloc_32.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/pgalloc_32.h
+++ quilt-2.6/include/asm-x86/pgalloc_32.h
@@ -33,17 +33,17 @@ do {								\
  * Allocate and free page tables.
  */
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -60,7 +60,7 @@ do {									\
  * In the PAE case we free the pmds as part of the pgd.
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
Index: quilt-2.6/include/asm-x86/pgalloc_64.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/pgalloc_64.h
+++ quilt-2.6/include/asm-x86/pgalloc_64.h
@@ -17,7 +17,7 @@ static inline void pmd_populate(struct m
 	set_pmd(pmd, __pmd(_PAGE_TABLE | (page_to_pfn(pte) << PAGE_SHIFT)));
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
 	free_page((unsigned long)pmd);
@@ -33,7 +33,7 @@ static inline pud_t *pud_alloc_one(struc
 	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pud_free (pud_t *pud)
+static inline void pud_free (struct mm_struct *mm, pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
 	free_page((unsigned long)pud);
@@ -77,7 +77,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
 	pgd_list_del(pgd);
@@ -100,13 +100,13 @@ static inline struct page *pte_alloc_one
 /* Should really implement gc for free page table pages. This could be
    done with a reference count in struct page. */
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
 	free_page((unsigned long)pte); 
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 } 
Index: quilt-2.6/include/asm-xtensa/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-xtensa/pgalloc.h
+++ quilt-2.6/include/asm-xtensa/pgalloc.h
@@ -31,7 +31,7 @@ pgd_alloc(struct mm_struct *mm)
 	return (pgd_t*) __get_free_pages(GFP_KERNEL | __GFP_ZERO, PGD_ORDER);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -52,12 +52,12 @@ static inline struct page *pte_alloc_one
 	return virt_to_page(pte_alloc_one_kernel(mm, addr));
 }
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	kmem_cache_free(pgtable_cache, pte);
 }
 
-static inline void pte_free(struct page *page)
+static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
 	kmem_cache_free(pgtable_cache, page_address(page));
 }
Index: quilt-2.6/include/asm-xtensa/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-xtensa/tlb.h
+++ quilt-2.6/include/asm-xtensa/tlb.h
@@ -42,6 +42,6 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free(pte)
+#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
 
 #endif	/* _XTENSA_TLB_H */
Index: quilt-2.6/kernel/fork.c
===================================================================
--- quilt-2.6.orig/kernel/fork.c
+++ quilt-2.6/kernel/fork.c
@@ -324,7 +324,7 @@ static inline int mm_alloc_pgd(struct mm
 
 static inline void mm_free_pgd(struct mm_struct * mm)
 {
-	pgd_free(mm->pgd);
+	pgd_free(mm, mm->pgd);
 }
 #else
 #define dup_mmap(mm, oldmm)	(0)
Index: quilt-2.6/mm/memory.c
===================================================================
--- quilt-2.6.orig/mm/memory.c
+++ quilt-2.6/mm/memory.c
@@ -305,7 +305,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 	spin_lock(&mm->page_table_lock);
 	if (pmd_present(*pmd)) {	/* Another has populated it */
 		pte_lock_deinit(new);
-		pte_free(new);
+		pte_free(mm, new);
 	} else {
 		mm->nr_ptes++;
 		inc_zone_page_state(new, NR_PAGETABLE);
@@ -323,7 +323,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 
 	spin_lock(&init_mm.page_table_lock);
 	if (pmd_present(*pmd))		/* Another has populated it */
-		pte_free_kernel(new);
+		pte_free_kernel(&init_mm, new);
 	else
 		pmd_populate_kernel(&init_mm, pmd, new);
 	spin_unlock(&init_mm.page_table_lock);
@@ -2557,7 +2557,7 @@ int __pud_alloc(struct mm_struct *mm, pg
 
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
-		pud_free(new);
+		pud_free(mm, new);
 	else
 		pgd_populate(mm, pgd, new);
 	spin_unlock(&mm->page_table_lock);
@@ -2579,12 +2579,12 @@ int __pmd_alloc(struct mm_struct *mm, pu
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
-		pmd_free(new);
+		pmd_free(mm, new);
 	else
 		pud_populate(mm, pud, new);
 #else
 	if (pgd_present(*pud))		/* Another has populated it */
-		pmd_free(new);
+		pmd_free(mm, new);
 	else
 		pgd_populate(mm, pud, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
