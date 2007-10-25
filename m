Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ39f773660
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:03 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ3eS2101450
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:03 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ2v1016664
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:03 +0200
Message-Id: <20071025181902.637882888@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:26 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 6/6] s390: dynamic page tables.
Content-Disposition: inline; filename=006-mm-dynpgd.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Add support for different number of page table levels dependent
on the highest address used for a process. This will cause a 31 bit
process to use a two level page table instead of the four level page
table that is the default after the pud has been introduced. Likewise
a normal 64 bit process will use three levels instead of four. Only
if a process runs out of the 4 tera bytes which can be addressed with
a three level page table the fourth level is dynamically added. Then
the process can use up to 8 peta byte.

To upgrade a page table to the next level the arch_update_pgd hook
in get_unmapped_area is used.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/kernel/traps.c       |    3 +-
 arch/s390/mm/fault.c           |   40 ++++++++++++++++++++++++++++
 arch/s390/mm/init.c            |    5 ++-
 arch/s390/mm/mmap.c            |    4 ++
 arch/s390/mm/pgtable.c         |   57 +++++++++++++++++++++++++++++++++++++++++
 include/asm-s390/a.out.h       |    2 -
 include/asm-s390/elf.h         |    2 -
 include/asm-s390/mmu.h         |    1 
 include/asm-s390/mmu_context.h |   10 +++++--
 include/asm-s390/pgalloc.h     |   47 +++++++++++++++++++++++++--------
 include/asm-s390/pgtable.h     |   24 +++++++++++++----
 include/asm-s390/tlb.h         |   10 +++++++
 12 files changed, 181 insertions(+), 24 deletions(-)

Index: quilt-2.6/arch/s390/kernel/traps.c
===================================================================
--- quilt-2.6.orig/arch/s390/kernel/traps.c
+++ quilt-2.6/arch/s390/kernel/traps.c
@@ -58,6 +58,7 @@ int sysctl_userprocess_debug = 0;
 extern pgm_check_handler_t do_protection_exception;
 extern pgm_check_handler_t do_dat_exception;
 extern pgm_check_handler_t do_monitor_call;
+extern pgm_check_handler_t do_asce_exception;
 
 #define stack_pointer ({ void **sp; asm("la %0,0(15)" : "=&d" (sp)); sp; })
 
@@ -712,7 +713,7 @@ void __init trap_init(void)
         pgm_check_table[0x12] = &translation_exception;
         pgm_check_table[0x13] = &special_op_exception;
 #ifdef CONFIG_64BIT
-        pgm_check_table[0x38] = &do_dat_exception;
+	pgm_check_table[0x38] = &do_asce_exception;
 	pgm_check_table[0x39] = &do_dat_exception;
 	pgm_check_table[0x3A] = &do_dat_exception;
         pgm_check_table[0x3B] = &do_dat_exception;
Index: quilt-2.6/arch/s390/mm/fault.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/fault.c
+++ quilt-2.6/arch/s390/mm/fault.c
@@ -32,6 +32,7 @@
 #include <asm/system.h>
 #include <asm/pgtable.h>
 #include <asm/s390_ext.h>
+#include <asm/mmu_context.h>
 
 #ifndef CONFIG_64BIT
 #define __FAIL_ADDR_MASK 0x7ffff000
@@ -444,6 +445,45 @@ void __kprobes do_dat_exception(struct p
 	do_exception(regs, error_code & 0xff, 0);
 }
 
+#ifdef CONFIG_64BIT
+void __kprobes do_asce_exception(struct pt_regs *regs, unsigned long error_code)
+{
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	unsigned long address;
+	int space;
+
+	mm = current->mm;
+	address = S390_lowcore.trans_exc_code & __FAIL_ADDR_MASK;
+	space = check_space(current);
+
+	if (unlikely(space == 0 || in_atomic() || !mm))
+		goto no_context;
+
+	local_irq_enable();
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, address);
+	up_read(&mm->mmap_sem);
+
+	if (vma) {
+		update_mm(mm, current);
+		return;
+	}
+
+	/* User mode accesses just cause a SIGSEGV */
+	if (regs->psw.mask & PSW_MASK_PSTATE) {
+		current->thread.prot_addr = address;
+		current->thread.trap_no = error_code;
+		do_sigsegv(regs, error_code, SEGV_MAPERR, address);
+		return;
+	}
+
+no_context:
+	do_no_context(regs, error_code, address);
+}
+#endif
+
 #ifdef CONFIG_PFAULT 
 /*
  * 'pfault' pseudo page faults routines.
Index: quilt-2.6/arch/s390/mm/init.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/init.c
+++ quilt-2.6/arch/s390/mm/init.c
@@ -112,8 +112,9 @@ void __init paging_init(void)
 	init_mm.pgd = swapper_pg_dir;
 	S390_lowcore.kernel_asce = __pa(init_mm.pgd) & PAGE_MASK;
 #ifdef CONFIG_64BIT
-	S390_lowcore.kernel_asce |= _ASCE_TYPE_REGION2 | _ASCE_TABLE_LENGTH;
-	pgd_type = _REGION2_ENTRY_EMPTY;
+	/* A three level page table (4TB) is enough for the kernel space. */
+	S390_lowcore.kernel_asce |= _ASCE_TYPE_REGION3 | _ASCE_TABLE_LENGTH;
+	pgd_type = _REGION3_ENTRY_EMPTY;
 #else
 	S390_lowcore.kernel_asce |= _ASCE_TABLE_LENGTH;
 	pgd_type = _SEGMENT_ENTRY_EMPTY;
Index: quilt-2.6/arch/s390/mm/mmap.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/mmap.c
+++ quilt-2.6/arch/s390/mm/mmap.c
@@ -27,6 +27,7 @@
 #include <linux/personality.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <asm/pgalloc.h>
 
 /*
  * Top of mmap area (just below the process stack).
@@ -81,6 +82,9 @@ void arch_pick_mmap_layout(struct mm_str
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 		mm->unmap_area = arch_unmap_area_topdown;
 	}
+#ifdef CONFIG_64BIT
+	pgd_downgrade(mm);
+#endif
 }
 EXPORT_SYMBOL_GPL(arch_pick_mmap_layout);
 
Index: quilt-2.6/arch/s390/mm/pgtable.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/pgtable.c
+++ quilt-2.6/arch/s390/mm/pgtable.c
@@ -23,6 +23,7 @@
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
+#include <asm/mmu_context.h>
 
 #ifndef CONFIG_64BIT
 #define ALLOC_ORDER	1
@@ -68,6 +69,62 @@ void crst_table_free(struct mm_struct *m
 	free_pages((unsigned long) table, ALLOC_ORDER);
 }
 
+#ifdef CONFIG_64BIT
+int crst_table_upgrade(struct mm_struct *mm, unsigned long limit)
+{
+	unsigned long *table, *pgd;
+	unsigned long entry;
+
+	BUG_ON(limit > (1UL << 53));
+repeat:
+	table = crst_table_alloc(mm, mm->context.noexec);
+	if (!table)
+		return -ENOMEM;
+	spin_lock(&mm->page_table_lock);
+	if (mm->context.asce_limit < limit) {
+		pgd = (unsigned long *) mm->pgd;
+		if (mm->context.asce_limit <= (1UL << 31)) {
+			entry = _REGION3_ENTRY_EMPTY;
+			mm->context.asce_limit = 1UL << 42;
+		} else {
+			entry = _REGION2_ENTRY_EMPTY;
+			mm->context.asce_limit = 1UL << 53;
+		}
+		crst_table_init(table, entry);
+		pgd_populate(mm, (pgd_t *) table, (pud_t *) pgd);
+		mm->pgd = (pgd_t *) table;
+		table = NULL;
+	}
+	spin_unlock(&mm->page_table_lock);
+	if (table)
+		crst_table_free(mm, table);
+	if (mm->context.asce_limit < limit)
+		goto repeat;
+	update_mm(mm, current);
+	return 0;
+}
+
+void crst_table_downgrade(struct mm_struct *mm, unsigned long limit)
+{
+	pgd_t *pgd;
+
+	limit = (limit > (1UL << 42)) ? (1UL << 53) :
+		(limit > (1UL << 31)) ? (1UL << 42) : (1UL << 31);
+	if (mm->context.asce_limit <= limit)
+		return;
+	while (mm->context.asce_limit > limit) {
+		if (mm->context.asce_limit >= (1UL << 53))
+			mm->context.asce_limit = 1UL << 42;
+		else if (mm->context.asce_limit >= (1UL << 42))
+			mm->context.asce_limit = 1UL << 31;
+		pgd = mm->pgd;
+		mm->pgd = (pgd_t *) (pgd_val(*pgd) & _REGION_ENTRY_ORIGIN);
+		crst_table_free(mm, (unsigned long *) pgd);
+	}
+	update_mm(mm, current);
+}
+#endif
+
 /*
  * page table entry allocation/free routines.
  */
Index: quilt-2.6/include/asm-s390/a.out.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/a.out.h
+++ quilt-2.6/include/asm-s390/a.out.h
@@ -34,7 +34,7 @@ struct exec
 #ifndef __s390x__
 #define STACK_TOP		(1UL << 31)
 #else /* __s390x__ */
-#define STACK_TOP		(1UL << (test_thread_flag(TIF_31BIT) ? 31:53))
+#define STACK_TOP		(1UL << (test_thread_flag(TIF_31BIT) ? 31:42))
 #endif /* __s390x__ */
 
 #define STACK_TOP_MAX		STACK_TOP
Index: quilt-2.6/include/asm-s390/elf.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/elf.h
+++ quilt-2.6/include/asm-s390/elf.h
@@ -139,7 +139,7 @@ typedef s390_regs elf_gregset_t;
    use of this is to invoke "./ld.so someprog" to test out a new version of
    the loader.  We need to make sure that it is out of the way of the program
    that it will "exec", and that there is sufficient room for the brk.  */
-#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
+#define ELF_ET_DYN_BASE		(STACK_TOP / 3 * 2)
 
 /* Wow, the "main" arch needs arch dependent functions too.. :) */
 
Index: quilt-2.6/include/asm-s390/mmu_context.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/mmu_context.h
+++ quilt-2.6/include/asm-s390/mmu_context.h
@@ -9,6 +9,7 @@
 #ifndef __S390_MMU_CONTEXT_H
 #define __S390_MMU_CONTEXT_H
 
+#include <asm/a.out.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm-generic/mm_hooks.h>
@@ -17,6 +18,9 @@ static inline int init_new_context(struc
 				   struct mm_struct *mm)
 {
 	mm->context.noexec = s390_noexec;
+	mm->context.asce_limit =
+		current->mm ? current->mm->context.asce_limit : STACK_TOP;
+	crst_table_init((unsigned long *) mm->pgd, pgd_entry_type(mm));
 	return(0);
 }
 #define destroy_context(mm)             do { } while (0)
@@ -35,9 +39,9 @@ static inline void update_mm(struct mm_s
 	/* Calculate asce bits from the first pgd table entry. */
 	asce_bits = _ASCE_TABLE_LENGTH | _ASCE_USER_BITS;
 #ifdef CONFIG_64BIT
-	asce_bits |= _ASCE_TYPE_REGION2;
+	asce_bits |= (pgd_val(*pgd) & _ASCE_TYPE_MASK);
 #endif
-	S390_lowcore.user_asce = asce_bits | __pa(pgd);
+	S390_lowcore.user_asce = asce_bits | __pa(mm->pgd);
 	if (switch_amode) {
 		/* Load primary space page table origin. */
 		pgd = mm->context.noexec ? get_shadow_table(pgd) : pgd;
@@ -48,6 +52,7 @@ static inline void update_mm(struct mm_s
 		/* Load home space page table origin. */
 		asm volatile(LCTL_OPCODE" 13,13,%0"
 			     : : "m" (S390_lowcore.user_asce) );
+	set_fs(current->thread.mm_segment);
 }
 
 static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
@@ -66,7 +71,6 @@ static inline void activate_mm(struct mm
                                struct mm_struct *next)
 {
         switch_mm(prev, next, current);
-	set_fs(current->thread.mm_segment);
 }
 
 #endif /* __S390_MMU_CONTEXT_H */
Index: quilt-2.6/include/asm-s390/mmu.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/mmu.h
+++ quilt-2.6/include/asm-s390/mmu.h
@@ -4,6 +4,7 @@
 typedef struct {
 	struct list_head crst_list;
 	struct list_head pgtable_list;
+	unsigned long asce_limit;
 	int noexec;
 } mm_context_t;
 
Index: quilt-2.6/include/asm-s390/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgalloc.h
+++ quilt-2.6/include/asm-s390/pgalloc.h
@@ -73,9 +73,39 @@ static inline unsigned long pgd_entry_ty
 
 static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 {
+	if (mm->context.asce_limit <= (1UL << 31))
+		return _SEGMENT_ENTRY_EMPTY;
+	if (mm->context.asce_limit <= (1UL << 42))
+		return _REGION3_ENTRY_EMPTY;
 	return _REGION2_ENTRY_EMPTY;
 }
 
+int crst_table_upgrade(struct mm_struct *, unsigned long limit);
+void crst_table_downgrade(struct mm_struct *, unsigned long limit);
+
+static inline unsigned long pgd_upgrade(unsigned long addr, unsigned long len)
+{
+	struct mm_struct *mm = current->mm;
+	int rc;
+
+	if (unlikely(mm->context.asce_limit < addr + len)) {
+		rc = crst_table_upgrade(mm, addr + len);
+		if (rc)
+			return (unsigned long) rc;
+	}
+	return addr;
+}
+#define arch_update_pgd(addr,len) pgd_upgrade(addr,len)
+
+static inline void pgd_downgrade(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma, *prev;
+
+	/* Called before a second process can race on the mm */
+	vma = find_vma_prev(mm, -1UL, &prev);
+	crst_table_downgrade(mm, prev->vm_end);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
@@ -102,12 +132,12 @@ static inline void pgd_populate_kernel(s
 
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 {
-	pgd_t *shadow_pgd = get_shadow_table(pgd);
-	pud_t *shadow_pud = get_shadow_table(pud);
-
-	if (shadow_pgd && shadow_pud)
-		pgd_populate_kernel(mm, shadow_pgd, shadow_pud);
 	pgd_populate_kernel(mm, pgd, pud);
+	if (mm->context.noexec) {
+		pgd = get_shadow_table(pgd);
+		pud = get_shadow_table(pud);
+		pgd_populate_kernel(mm, pgd, pud);
+	}
 }
 
 static inline void pud_populate_kernel(struct mm_struct *mm,
@@ -130,14 +160,9 @@ static inline void pud_populate(struct m
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	unsigned long *crst;
-
 	INIT_LIST_HEAD(&mm->context.crst_list);
 	INIT_LIST_HEAD(&mm->context.pgtable_list);
-	crst = crst_table_alloc(mm, s390_noexec);
-	if (crst)
-		crst_table_init(crst, pgd_entry_type(mm));
-	return (pgd_t *) crst;
+	return (pgd_t *) crst_table_alloc(mm, s390_noexec);
 }
 #define pgd_free(mm, pgd) crst_table_free(mm, (unsigned long *) pgd)
 
Index: quilt-2.6/include/asm-s390/pgtable.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgtable.h
+++ quilt-2.6/include/asm-s390/pgtable.h
@@ -428,11 +428,15 @@ static inline int pud_bad(pud_t pud)	 { 
 
 static inline int pgd_present(pgd_t pgd)
 {
+	if ((pgd_val(pgd) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R2)
+		return 1;
 	return pgd_val(pgd) & _REGION_ENTRY_ORIGIN;
 }
 
 static inline int pgd_none(pgd_t pgd)
 {
+	if ((pgd_val(pgd) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R2)
+		return 0;
 	return pgd_val(pgd) & _REGION_ENTRY_INV;
 }
 
@@ -446,11 +450,15 @@ static inline int pgd_bad(pgd_t pgd)
 
 static inline int pud_present(pud_t pud)
 {
+	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R3)
+		return 1;
 	return pud_val(pud) & _REGION_ENTRY_ORIGIN;
 }
 
 static inline int pud_none(pud_t pud)
 {
+	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R3)
+		return 0;
 	return pud_val(pud) & _REGION_ENTRY_INV;
 }
 
@@ -542,7 +550,8 @@ static inline int pte_young(pte_t pte)
 
 static inline void pgd_clear_kernel(pgd_t * pgd)
 {
-	pgd_val(*pgd) = _REGION2_ENTRY_EMPTY;
+	if ((pgd_val(*pgd) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R2)
+		pgd_val(*pgd) = _REGION2_ENTRY_EMPTY;
 }
 
 static inline void pgd_clear(pgd_t * pgd)
@@ -556,10 +565,11 @@ static inline void pgd_clear(pgd_t * pgd
 
 static inline void pud_clear_kernel(pud_t *pud)
 {
-	pud_val(*pud) = _REGION3_ENTRY_EMPTY;
+	if ((pud_val(*pud) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
+		pud_val(*pud) = _REGION3_ENTRY_EMPTY;
 }
 
-static inline void pud_clear(pud_t * pud)
+static inline void pud_clear(pud_t *pud)
 {
 	pud_t *shadow = get_shadow_table(pud);
 
@@ -848,13 +858,17 @@ static inline pte_t mk_pte(struct page *
 
 static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
 {
-	pud_t *pud = (pud_t *) pgd_deref(*pgd);
+	pud_t *pud = (pud_t *) pgd;
+	if ((pgd_val(*pgd) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R2)
+		pud = (pud_t *) pgd_deref(*pgd);
 	return pud  + pud_index(address);
 }
 
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 {
-	pmd_t *pmd = (pmd_t *) pud_deref(*pud);
+	pmd_t *pmd = (pmd_t *) pud;
+	if ((pud_val(*pud) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
+		pmd = (pmd_t *) pud_deref(*pud);
 	return pmd + pmd_index(address);
 }
 
Index: quilt-2.6/include/asm-s390/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlb.h
+++ quilt-2.6/include/asm-s390/tlb.h
@@ -109,10 +109,15 @@ static inline void pte_free_tlb(struct m
 /*
  * pmd_free_tlb frees a pmd table and clears the CRSTE for the
  * segment table entry from the tlb.
+ * If the mm uses a two level page table the single pmd is freed
+ * as the pgd. pmd_free_tlb checks the asce_limit against 2GB
+ * to avoid the double free of the pmd in this case.
  */
 static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
 #ifdef __s390x__
+	if (tlb->mm->context.asce_limit <= (1UL << 31))
+		return;
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pmd;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
@@ -125,10 +130,15 @@ static inline void pmd_free_tlb(struct m
 /*
  * pud_free_tlb frees a pud table and clears the CRSTE for the
  * region third table entry from the tlb.
+ * If the mm uses a three level page table the single pud is freed
+ * as the pgd. pud_free_tlb checks the asce_limit against 4TB
+ * to avoid the double free of the pud in this case.
  */
 static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 {
 #ifdef __s390x__
+	if (tlb->mm->context.asce_limit <= (1UL << 42))
+		return;
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pud;
 		if (tlb->nr_ptes >= tlb->nr_pxds)

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
