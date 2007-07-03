Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l63CAFli089348
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 12:10:15 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l63CAFN42109666
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l63CADC0019655
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:14 +0200
Message-Id: <20070703121229.180281096@de.ibm.com>
References: <20070703111822.418649776@de.ibm.com>
Date: Tue, 03 Jul 2007 13:18:27 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/5] s390 tlb flush fix.
Content-Disposition: inline; filename=005-s390-tlbflush.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, hugh@veritas.com, peterz@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

The current tlb flushing code for page table entries violates the
s390 architecture in a small detail. The relevant section from the
principles of operation (SA22-7832-02 page 3-47):

   "A valid table entry must not be changed while it is attached
   to any CPU and may be used for translation by that CPU except to
   (1) invalidate the entry by using INVALIDATE PAGE TABLE ENTRY or
   INVALIDATE DAT TABLE ENTRY, (2) alter bits 56-63 of a page-table
   entry, or (3) make a change by means of a COMPARE AND SWAP AND
   PURGE instruction that purges the TLB."

That means if one thread of a multithreaded applciation uses a vma
while another thread does an unmap on it, the page table entries of
that vma needs to get removed with IPTE, IDTE or CSP. In some strange
and rare situations a cpu could check-stop (die) because a entry has
been pushed out of the TLB that is still needed to complete a
(milli-coded) instruction. I've never seen it happen with the current
code on any of the supported machines, so right now this is a
theoretical problem. But I want to fix it nevertheless, to avoid
headaches in the futures.

To get this implemented correctly without changing common code the
primitives ptep_get_and_clear, ptep_get_and_clear_full and
ptep_set_wrprotect need to use the IPTE instruction to invalidate the
pte before the new pte value gets stored. If IPTE is always used for
the three primitives three important operations will have a performace
hit: fork, mprotect and exit_mmap. Time for some workarounds:

* 1: ptep_get_and_clear_full is used in unmap_vmas to remove page
tables entries in a batched tlb gather operation. If the mmu_gather
context passed to unmap_vmas has been started with full_mm_flush==1
or if only one cpu is online or if the mm_struct doesn't has more
than one user the fullmm indication in the mmu_gather context is
set to one. All TLBs for mm_struct are flushed by the tlb_gather_mmu
call. No new TLBs can be created while the unmap is in progress. In
this case ptep_get_and_clear_full clears the ptes with a simple store.

* 2: ptep_get_and_clear is used in change_protection to clear the
ptes from the page tables before they are reentered with the new
access flags. At the end of the update flush_tlb_range clears the
remaining TLBs. In general the ptep_get_and_clear has to issue IPTE
for each pte and flush_tlb_range is a nop. But if there is only one
user of the mm_struct then ptep_get_and_clear uses simple stores
to do the update and flush_tlb_range will flush the TLBs.

* 3: Similar to 2, ptep_set_wrprotect is used in copy_page_range
for a fork to make all ptes of a cow mapping read-only. At the end of
of copy_page_range dup_mmap will flush the TLBs with a call to
flush_tlb_mm.  Check for mm->mm_users and if there is only one user
avoid using IPTE in ptep_set_wrprotect and let flush_tlb_mm clear the
TLBs.

Overall for single threaded programs the tlb flush code now performs
better, for multi threaded programs it is slightly worse. In particular
exit_mmap() now does a single IDTE for the mm and then just frees every
page cache reference and every page table page directly without a delay
over the mmu_gather structure.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/kernel/smp.c      |    2 
 include/asm-s390/pgalloc.h  |   17 ----
 include/asm-s390/pgtable.h  |   90 +++++++++++++++++++-----
 include/asm-s390/tlb.h      |  127 ++++++++++++++++++++++++++++++++---
 include/asm-s390/tlbflush.h |  159 +++++++++++++++-----------------------------
 5 files changed, 245 insertions(+), 150 deletions(-)

diff -urpN linux-2.6/arch/s390/kernel/smp.c linux-2.6-patched/arch/s390/kernel/smp.c
--- linux-2.6/arch/s390/kernel/smp.c	2007-06-01 10:06:01.000000000 +0200
+++ linux-2.6-patched/arch/s390/kernel/smp.c	2007-07-03 12:56:51.000000000 +0200
@@ -328,7 +328,7 @@ static void smp_ext_bitcall(int cpu, ec_
  */
 void smp_ptlb_callback(void *info)
 {
-	local_flush_tlb();
+	__tlb_flush_local();
 }
 
 void smp_ptlb_all(void)
diff -urpN linux-2.6/include/asm-s390/pgalloc.h linux-2.6-patched/include/asm-s390/pgalloc.h
--- linux-2.6/include/asm-s390/pgalloc.h	2007-02-07 15:42:46.000000000 +0100
+++ linux-2.6-patched/include/asm-s390/pgalloc.h	2007-07-03 12:56:51.000000000 +0200
@@ -84,7 +84,6 @@ static inline void pgd_free(pgd_t *pgd)
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)                     do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 #define pgd_populate_kernel(mm, pmd, pte)	BUG()
 #else /* __s390x__ */
@@ -120,12 +119,6 @@ static inline void pmd_free (pmd_t *pmd)
 	free_pages((unsigned long) pmd, PMD_ALLOC_ORDER);
 }
 
-#define __pmd_free_tlb(tlb,pmd)			\
-	do {					\
-		tlb_flush_mmu(tlb, 0, 0);	\
-		pmd_free(pmd);			\
-	 } while (0)
-
 static inline void
 pgd_populate_kernel(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
 {
@@ -226,14 +219,4 @@ static inline void pte_free(struct page 
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)					\
-({									\
-	struct mmu_gather *__tlb = (tlb);				\
-	struct page *__pte = (pte);					\
-	struct page *shadow_page = get_shadow_page(__pte);		\
-	if (shadow_page)						\
-		tlb_remove_page(__tlb, shadow_page);			\
-	tlb_remove_page(__tlb, __pte);					\
-})
-
 #endif /* _S390_PGALLOC_H */
diff -urpN linux-2.6/include/asm-s390/pgtable.h linux-2.6-patched/include/asm-s390/pgtable.h
--- linux-2.6/include/asm-s390/pgtable.h	2007-07-03 12:56:50.000000000 +0200
+++ linux-2.6-patched/include/asm-s390/pgtable.h	2007-07-03 12:56:51.000000000 +0200
@@ -417,7 +417,8 @@ static inline pgd_t *get_shadow_pgd(pgd_
  * within a page table are directly modified.  Thus, the following
  * hook is made available.
  */
-static inline void set_pte(pte_t *pteptr, pte_t pteval)
+static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
+			      pte_t *pteptr, pte_t pteval)
 {
 	pte_t *shadow_pte = get_shadow_pte(pteptr);
 
@@ -430,7 +431,6 @@ static inline void set_pte(pte_t *pteptr
 			pte_val(*shadow_pte) = _PAGE_TYPE_EMPTY;
 	}
 }
-#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 /*
  * pgd/pmd/pte query functions
@@ -501,7 +501,8 @@ static inline int pte_file(pte_t pte)
 	return (pte_val(pte) & mask) == _PAGE_TYPE_FILE;
 }
 
-#define pte_same(a,b)	(pte_val(a) == pte_val(b))
+#define __HAVE_ARCH_PTE_SAME
+#define pte_same(a,b)  (pte_val(a) == pte_val(b))
 
 /*
  * query functions pte_write/pte_dirty/pte_young only work if
@@ -664,17 +665,19 @@ static inline pte_t pte_mkyoung(pte_t pt
 	return pte;
 }
 
-static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma,
+					    unsigned long addr, pte_t *ptep)
 {
 	return 0;
 }
 
-static inline int
-ptep_clear_flush_young(struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep)
+#define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
+static inline int ptep_clear_flush_young(struct vm_area_struct *vma,
+					 unsigned long address, pte_t *ptep)
 {
 	/* No need to flush TLB; bits are in storage key */
-	return ptep_test_and_clear_young(vma, address, ptep);
+	return 0;
 }
 
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
@@ -710,6 +713,31 @@ static inline void ptep_invalidate(unsig
 		__ptep_ipte(address, ptep);
 }
 
+/*
+ * This is hard to understand. ptep_get_and_clear and ptep_clear_flush
+ * both clear the TLB for the unmapped pte. The reason is that
+ * ptep_get_and_clear is used in common code (e.g. change_pte_range)
+ * to modify an active pte. The sequence is
+ *   1) ptep_get_and_clear
+ *   2) set_pte_at
+ *   3) flush_tlb_range
+ * On s390 the tlb needs to get flushed with the modification of the pte
+ * if the pte is active. The only way how this can be implemented is to
+ * have ptep_get_and_clear do the tlb flush. In exchange flush_tlb_range
+ * is a nop.
+ */
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define ptep_get_and_clear(__mm, __address, __ptep)			\
+({									\
+	pte_t __pte = *(__ptep);					\
+	if (atomic_read(&(__mm)->mm_users) > 1)				\
+		ptep_invalidate(__address, __ptep);			\
+	else								\
+		pte_clear((__mm), (__address), (__ptep));		\
+	__pte;								\
+})
+
+#define __HAVE_ARCH_PTEP_CLEAR_FLUSH
 static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
 				     unsigned long address, pte_t *ptep)
 {
@@ -718,12 +746,39 @@ static inline pte_t ptep_clear_flush(str
 	return pte;
 }
 
-static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+/*
+ * The batched pte unmap code uses ptep_get_and_clear_full to clear the
+ * ptes. Here an optimization is possible. tlb_gather_mmu flushes all
+ * tlbs of an mm if it can guarantee that the ptes of the mm_struct
+ * cannot be accessed while the batched unmap is running. In this case
+ * full==1 and a simple pte_clear is enough. See tlb.h.
+ */
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
+static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
+					    unsigned long addr,
+					    pte_t *ptep, int full)
 {
-	pte_t old_pte = *ptep;
-	set_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
+	pte_t pte = *ptep;
+
+	if (full)
+		pte_clear(mm, addr, ptep);
+	else
+		ptep_invalidate(addr, ptep);
+	return pte;
 }
 
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define ptep_set_wrprotect(__mm, __addr, __ptep)			\
+({									\
+	pte_t __pte = *(__ptep);					\
+	if (pte_write(__pte)) {						\
+		if (atomic_read(&(__mm)->mm_users) > 1)			\
+			ptep_invalidate(__addr, __ptep);		\
+		set_pte_at(__mm, __addr, __ptep, pte_wrprotect(__pte));	\
+	}								\
+})
+
+#define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 #define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __dirty)	\
 ({									\
 	int __changed = !pte_same(*(__ptep), __entry);			\
@@ -741,11 +796,13 @@ static inline void ptep_set_wrprotect(st
  * should therefore only be called if it is not mapped in any
  * address space.
  */
+#define __HAVE_ARCH_PAGE_TEST_DIRTY
 static inline int page_test_dirty(struct page *page)
 {
 	return (page_get_storage_key(page_to_phys(page)) & _PAGE_CHANGED) != 0;
 }
 
+#define __HAVE_ARCH_PAGE_CLEAR_DIRTY
 static inline void page_clear_dirty(struct page *page)
 {
 	page_set_storage_key(page_to_phys(page), PAGE_DEFAULT_KEY);
@@ -754,6 +811,7 @@ static inline void page_clear_dirty(stru
 /*
  * Test and clear referenced bit in storage key.
  */
+#define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
 static inline int page_test_and_clear_young(struct page *page)
 {
 	unsigned long physpage = page_to_phys(page);
@@ -931,16 +989,6 @@ extern int remove_shared_memory(unsigned
 #define __HAVE_ARCH_MEMMAP_INIT
 extern void memmap_init(unsigned long, int, unsigned long, unsigned long);
 
-#define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
-#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-#define __HAVE_ARCH_PTEP_CLEAR_FLUSH
-#define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTE_SAME
-#define __HAVE_ARCH_PAGE_TEST_DIRTY
-#define __HAVE_ARCH_PAGE_CLEAR_DIRTY
-#define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
 #include <asm-generic/pgtable.h>
 
 #endif /* _S390_PAGE_H */
diff -urpN linux-2.6/include/asm-s390/tlbflush.h linux-2.6-patched/include/asm-s390/tlbflush.h
--- linux-2.6/include/asm-s390/tlbflush.h	2007-02-07 15:42:46.000000000 +0100
+++ linux-2.6-patched/include/asm-s390/tlbflush.h	2007-07-03 12:56:51.000000000 +0200
@@ -6,69 +6,19 @@
 #include <asm/pgalloc.h>
 
 /*
- * TLB flushing:
- *
- *  - flush_tlb() flushes the current mm struct TLBs
- *  - flush_tlb_all() flushes all processes TLBs 
- *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
- *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
- *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
- */
-
-/*
- * S/390 has three ways of flushing TLBs
- * 'ptlb' does a flush of the local processor
- * 'csp' flushes the TLBs on all PUs of a SMP
- * 'ipte' invalidates a pte in a page table and flushes that out of
- * the TLBs of all PUs of a SMP
+ * Flush all tlb entries on the local cpu.
  */
-
-#define local_flush_tlb() \
-do {  asm volatile("ptlb": : :"memory"); } while (0)
-
-#ifndef CONFIG_SMP
-
-/*
- * We always need to flush, since s390 does not flush tlb
- * on each context switch
- */
-
-static inline void flush_tlb(void)
-{
-	local_flush_tlb();
-}
-static inline void flush_tlb_all(void)
-{
-	local_flush_tlb();
-}
-static inline void flush_tlb_mm(struct mm_struct *mm) 
+static inline void __tlb_flush_local(void)
 {
-	local_flush_tlb();
+	asm volatile("ptlb" : : : "memory");
 }
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-				  unsigned long addr)
-{
-	local_flush_tlb();
-}
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end)
-{
-	local_flush_tlb();
-}
-
-#define flush_tlb_kernel_range(start, end) \
-	local_flush_tlb();
-
-#else
-
-#include <asm/smp.h>
-
-extern void smp_ptlb_all(void);
 
-static inline void global_flush_tlb(void)
+/*
+ * Flush all tlb entries on all cpus.
+ */
+static inline void __tlb_flush_global(void)
 {
+	extern void smp_ptlb_all(void);
 	register unsigned long reg2 asm("2");
 	register unsigned long reg3 asm("3");
 	register unsigned long reg4 asm("4");
@@ -90,72 +40,77 @@ static inline void global_flush_tlb(void
 }
 
 /*
- * We only have to do global flush of tlb if process run since last
- * flush on any other pu than current. 
- * If we have threads (mm->count > 1) we always do a global flush, 
- * since the process runs on more than one processor at the same time.
+ * Flush all tlb entries of a page table on all cpus.
  */
+static inline void __tlb_flush_idte(pgd_t *pgd)
+{
+	asm volatile(
+		"	.insn	rrf,0xb98e0000,0,%0,%1,0"
+		: : "a" (2048), "a" (__pa(pgd) & PAGE_MASK) : "cc" );
+}
 
-static inline void __flush_tlb_mm(struct mm_struct * mm)
+static inline void __tlb_flush_mm(struct mm_struct * mm)
 {
 	cpumask_t local_cpumask;
 
 	if (unlikely(cpus_empty(mm->cpu_vm_mask)))
 		return;
+	/*
+	 * If the machine has IDTE we prefer to do a per mm flush
+	 * on all cpus instead of doing a local flush if the mm
+	 * only ran on the local cpu.
+	 */
 	if (MACHINE_HAS_IDTE) {
 		pgd_t *shadow_pgd = get_shadow_pgd(mm->pgd);
 
-		if (shadow_pgd) {
-			asm volatile(
-				"	.insn	rrf,0xb98e0000,0,%0,%1,0"
-				: : "a" (2048),
-				"a" (__pa(shadow_pgd) & PAGE_MASK) : "cc" );
-		}
-		asm volatile(
-			"	.insn	rrf,0xb98e0000,0,%0,%1,0"
-			: : "a" (2048), "a" (__pa(mm->pgd)&PAGE_MASK) : "cc");
+		if (shadow_pgd)
+			__tlb_flush_idte(shadow_pgd);
+		__tlb_flush_idte(mm->pgd);
 		return;
 	}
 	preempt_disable();
+	/*
+	 * If the process only ran on the local cpu, do a local flush.
+	 */
 	local_cpumask = cpumask_of_cpu(smp_processor_id());
 	if (cpus_equal(mm->cpu_vm_mask, local_cpumask))
-		local_flush_tlb();
+		__tlb_flush_local();
 	else
-		global_flush_tlb();
+		__tlb_flush_global();
 	preempt_enable();
 }
 
-static inline void flush_tlb(void)
-{
-	__flush_tlb_mm(current->mm);
-}
-static inline void flush_tlb_all(void)
-{
-	global_flush_tlb();
-}
-static inline void flush_tlb_mm(struct mm_struct *mm) 
-{
-	__flush_tlb_mm(mm); 
-}
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-				  unsigned long addr)
+static inline void __tlb_flush_mm_cond(struct mm_struct * mm)
 {
-	__flush_tlb_mm(vma->vm_mm);
+	if (atomic_read(&mm->mm_users) <= 1)
+		__tlb_flush_mm(mm);
 }
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end)
-{
-	__flush_tlb_mm(vma->vm_mm); 
-}
-
-#define flush_tlb_kernel_range(start, end) global_flush_tlb()
 
-#endif
+/*
+ * TLB flushing:
+ *  flush_tlb() - flushes the current mm struct TLBs
+ *  flush_tlb_all() - flushes all processes TLBs
+ *  flush_tlb_mm(mm) - flushes the specified mm context TLB's
+ *  flush_tlb_page(vma, vmaddr) - flushes one page
+ *  flush_tlb_range(vma, start, end) - flushes a range of pages
+ *  flush_tlb_kernel_range(start, end) - flushes a range of kernel pages
+ *  flush_tlb_pgtables(mm, start, end) - flushes a range of page tables
+ */
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-                                      unsigned long start, unsigned long end)
-{
-        /* S/390 does not keep any page table caches in TLB */
-}
+/*
+ * flush_tlb_mm goes together with ptep_set_wrprotect for the
+ * copy_page_range operation and flush_tlb_range is related to
+ * ptep_get_and_clear for change_protection. ptep_set_wrprotect and
+ * ptep_get_and_clear do not flush the TLBs directly if the mm has
+ * only one user. At the end of the update the flush_tlb_mm and
+ * flush_tlb_range functions need to do the flush.
+ */
+#define flush_tlb()				do { } while (0)
+#define flush_tlb_all()				do { } while (0)
+#define flush_tlb_mm(mm)			__tlb_flush_mm_cond(mm)
+#define flush_tlb_page(vma, addr)		do { } while (0)
+#define flush_tlb_range(vma, start, end)	__tlb_flush_mm_cond(mm)
+#define flush_tlb_kernel_range(start, end)	__tlb_flush_mm(&init_mm)
+#define flush_tlb_pgtables(mm, start, end)	do { } while (0)
 
 #endif /* _S390_TLBFLUSH_H */
diff -urpN linux-2.6/include/asm-s390/tlb.h linux-2.6-patched/include/asm-s390/tlb.h
--- linux-2.6/include/asm-s390/tlb.h	2006-11-08 10:45:47.000000000 +0100
+++ linux-2.6-patched/include/asm-s390/tlb.h	2007-07-03 12:56:51.000000000 +0200
@@ -2,19 +2,128 @@
 #define _S390_TLB_H
 
 /*
- * s390 doesn't need any special per-pte or
- * per-vma handling..
+ * TLB flushing on s390 is complicated. The following requirement
+ * from the principles of operation is the most arduous:
+ *
+ * "A valid table entry must not be changed while it is attached
+ * to any CPU and may be used for translation by that CPU except to
+ * (1) invalidate the entry by using INVALIDATE PAGE TABLE ENTRY,
+ * or INVALIDATE DAT TABLE ENTRY, (2) alter bits 56-63 of a page
+ * table entry, or (3) make a change by means of a COMPARE AND SWAP
+ * AND PURGE instruction that purges the TLB."
+ *
+ * The modification of a pte of an active mm struct therefore is
+ * a two step process: i) invalidate the pte, ii) store the new pte.
+ * This is true for the page protection bit as well.
+ * The only possible optimization is to flush at the beginning of
+ * a tlb_gather_mmu cycle if the mm_struct is currently not in use.
+ *
+ * Pages used for the page tables is a different story. FIXME: more
  */
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <asm/processor.h>
+#include <asm/pgalloc.h>
+#include <asm/smp.h>
+#include <asm/tlbflush.h>
+
+#ifndef CONFIG_SMP
+#define TLB_NR_PTRS	1
+#else
+#define TLB_NR_PTRS	508
+#endif
+
+struct mmu_gather {
+	struct mm_struct *mm;
+	unsigned int fullmm;
+	unsigned int nr_ptes;
+	unsigned int nr_pmds;
+	void *array[TLB_NR_PTRS];
+};
+
+DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
+
+static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm,
+						unsigned int full_mm_flush)
+{
+	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
+
+	tlb->mm = mm;
+	tlb->fullmm = full_mm_flush || (num_online_cpus() == 1) ||
+		(atomic_read(&mm->mm_users) <= 1);
+	tlb->nr_ptes = 0;
+	tlb->nr_pmds = TLB_NR_PTRS;
+	if (tlb->fullmm)
+		__tlb_flush_mm(mm);
+	return tlb;
+}
+
+static inline void tlb_flush_mmu(struct mmu_gather *tlb,
+				 unsigned long start, unsigned long end)
+{
+	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pmds < TLB_NR_PTRS))
+		__tlb_flush_mm(tlb->mm);
+	while (tlb->nr_ptes > 0)
+		pte_free(tlb->array[--tlb->nr_ptes]);
+	while (tlb->nr_pmds < TLB_NR_PTRS)
+		pmd_free((pmd_t *) tlb->array[tlb->nr_pmds++]);
+}
+
+static inline void tlb_finish_mmu(struct mmu_gather *tlb,
+				  unsigned long start, unsigned long end)
+{
+	tlb_flush_mmu(tlb, start, end);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+
+	put_cpu_var(mmu_gathers);
+}
 
 /*
- * .. because we flush the whole mm when it
- * fills up.
+ * Release the page cache reference for a pte removed by
+ * tlb_ptep_clear_flush. In both flush modes the tlb fo a page cache page
+ * has already been freed, so just do free_page_and_swap_cache.
  */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	free_page_and_swap_cache(page);
+}
 
-#include <asm-generic/tlb.h>
+/*
+ * pte_free_tlb frees a pte table and clears the CRSTE for the
+ * page table from the tlb.
+ */
+static inline void pte_free_tlb(struct mmu_gather *tlb, struct page *page)
+{
+	if (!tlb->fullmm) {
+		tlb->array[tlb->nr_ptes++] = page;
+		if (tlb->nr_ptes >= tlb->nr_pmds)
+			tlb_flush_mmu(tlb, 0, 0);
+	} else
+		pte_free(page);
+}
 
+/*
+ * pmd_free_tlb frees a pmd table and clears the CRSTE for the
+ * segment table entry from the tlb.
+ */
+static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+{
+#ifdef __s390x__
+	if (!tlb->fullmm) {
+		tlb->array[--tlb->nr_pmds] = (struct page *) pmd;
+		if (tlb->nr_ptes >= tlb->nr_pmds)
+			tlb_flush_mmu(tlb, 0, 0);
+	} else
+		pmd_free(pmd);
 #endif
+}
+
+#define tlb_start_vma(tlb, vma)			do { } while (0)
+#define tlb_end_vma(tlb, vma)			do { } while (0)
+#define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
+#define tlb_migrate_finish(mm)			do { } while (0)
+
+#endif /* _S390_TLB_H */

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
