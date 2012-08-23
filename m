Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BC5EE6B006E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:19:00 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHIocx28246154
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:50 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHIt6A018791
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:56 -0600
Message-Id: <20120823171855.006932817@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:40 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 7/7] thp, s390: architecture backend for thp on System z
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-s390.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

This implements the architecture backend for transparent hugepages
on System z.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/s390/include/asm/hugetlb.h |   18 ----
 arch/s390/include/asm/pgtable.h |  176 ++++++++++++++++++++++++++++++++++++++++
 arch/s390/include/asm/tlb.h     |    1 
 arch/s390/mm/pgtable.c          |   22 +++++
 mm/Kconfig                      |    2 
 5 files changed, 201 insertions(+), 18 deletions(-)

--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -87,23 +87,6 @@ static inline void __pmd_csp(pmd_t *pmdp
 		"	csp %1,%3"
 		: "=m" (*pmdp)
 		: "d" (reg2), "d" (reg3), "d" (reg4), "m" (*pmdp) : "cc");
-	pmd_val(*pmdp) = _SEGMENT_ENTRY_INV | _SEGMENT_ENTRY;
-}
-
-static inline void __pmd_idte(unsigned long address, pmd_t *pmdp)
-{
-	unsigned long sto = (unsigned long) pmdp -
-				pmd_index(address) * sizeof(pmd_t);
-
-	if (!(pmd_val(*pmdp) & _SEGMENT_ENTRY_INV)) {
-		asm volatile(
-			"	.insn	rrf,0xb98e0000,%2,%3,0,0"
-			: "=m" (*pmdp)
-			: "m" (*pmdp), "a" (sto),
-			  "a" ((address & HPAGE_MASK))
-		);
-	}
-	pmd_val(*pmdp) = _SEGMENT_ENTRY_INV | _SEGMENT_ENTRY;
 }
 
 static inline void huge_ptep_invalidate(struct mm_struct *mm,
@@ -115,6 +98,7 @@ static inline void huge_ptep_invalidate(
 		__pmd_idte(address, pmdp);
 	else
 		__pmd_csp(pmdp);
+	pmd_val(*pmdp) = _SEGMENT_ENTRY_INV | _SEGMENT_ENTRY;
 }
 
 #define huge_ptep_set_access_flags(__vma, __addr, __ptep, __entry, __dirty) \
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -350,6 +350,10 @@ extern struct page *vmemmap;
 #define _SEGMENT_ENTRY_SPLIT_BIT 0	/* THP splitting bit number */
 #define _SEGMENT_ENTRY_SPLIT	(1UL << _SEGMENT_ENTRY_SPLIT_BIT)
 
+/* Set of bits not changed in pmd_modify */
+#define _SEGMENT_CHG_MASK	(_SEGMENT_ENTRY_ORIGIN | _SEGMENT_ENTRY_LARGE \
+				 | _SEGMENT_ENTRY_SPLIT | _SEGMENT_ENTRY_CO)
+
 /* Page status table bits for virtualization */
 #define RCP_ACC_BITS	0xf000000000000000UL
 #define RCP_FP_BIT	0x0800000000000000UL
@@ -512,6 +516,26 @@ static inline int pmd_bad(pmd_t pmd)
 extern void pmdp_splitting_flush(struct vm_area_struct *vma,
 				 unsigned long addr, pmd_t *pmdp);
 
+#define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
+
+#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMD_WRITE
+static inline int pmd_write(pmd_t pmd)
+{
+	return (pmd_val(pmd) & _SEGMENT_ENTRY_RO) == 0;
+}
+
+static inline int pmd_young(pmd_t pmd)
+{
+	return 0;
+}
+
 static inline int pte_none(pte_t pte)
 {
 	return (pte_val(pte) & _PAGE_INVALID) && !(pte_val(pte) & _PAGE_SWT);
@@ -1165,6 +1189,22 @@ static inline pmd_t *pmd_offset(pud_t *p
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
 
+static inline void __pmd_idte(unsigned long address, pmd_t *pmdp)
+{
+	unsigned long sto = (unsigned long) pmdp -
+			    pmd_index(address) * sizeof(pmd_t);
+
+	if (!(pmd_val(*pmdp) & _SEGMENT_ENTRY_INV)) {
+		asm volatile(
+			"	.insn	rrf,0xb98e0000,%2,%3,0,0"
+			: "=m" (*pmdp)
+			: "m" (*pmdp), "a" (sto),
+			  "a" ((address & HPAGE_MASK))
+			: "cc"
+		);
+	}
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_deposit(struct mm_struct *mm, pgtable_t pgtable);
@@ -1176,6 +1216,142 @@ static inline int pmd_trans_splitting(pm
 {
 	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
 }
+
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t entry)
+{
+	*pmdp = entry;
+}
+
+static inline unsigned long massage_pgprot_pmd(pgprot_t pgprot)
+{
+	unsigned long pgprot_pmd = 0;
+
+	if (pgprot_val(pgprot) & _PAGE_INVALID) {
+		if (pgprot_val(pgprot) & _PAGE_SWT)
+			pgprot_pmd |= _HPAGE_TYPE_NONE;
+		pgprot_pmd |= _SEGMENT_ENTRY_INV;
+	}
+	if (pgprot_val(pgprot) & _PAGE_RO)
+		pgprot_pmd |= _SEGMENT_ENTRY_RO;
+	return pgprot_pmd;
+}
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	pmd_val(pmd) &= _SEGMENT_CHG_MASK;
+	pmd_val(pmd) |= massage_pgprot_pmd(newprot);
+	return pmd;
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
+	return pmd;
+}
+
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~_SEGMENT_ENTRY_RO;
+	return pmd;
+}
+
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	pmd_val(pmd) |= _SEGMENT_ENTRY_RO;
+	return pmd;
+}
+
+static inline pmd_t pmd_mkdirty(pmd_t pmd)
+{
+	/* No dirty bit in the segment table entry. */
+	return pmd;
+}
+
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	/* No referenced bit in the segment table entry. */
+	return pmd;
+}
+
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	/* No referenced bit in the segment table entry. */
+	return pmd;
+}
+
+#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+					    unsigned long address,
+					    pmd_t *pmdp)
+{
+	int rc = 0;
+	int counter = PTRS_PER_PTE;
+	unsigned long pmd_addr = pmd_val(*pmdp) & HPAGE_MASK;
+
+	asm volatile(
+		"0:	rrbe	0,%2\n"
+		"	la	%2,0(%3,%2)\n"
+		"	brc	12,1f\n"
+		"	lhi	%0,1\n"
+		"1:	brct	%1,0b\n"
+		: "+d" (rc), "+d" (counter), "+a" (pmd_addr)
+		: "a" (4096UL): "cc" );
+	return rc;
+}
+
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
+				       unsigned long address, pmd_t *pmdp)
+{
+	pmd_t pmd = *pmdp;
+
+	__pmd_idte(address, pmdp);
+	pmd_clear(pmdp);
+	return pmd;
+}
+
+#define __HAVE_ARCH_PMDP_CLEAR_FLUSH
+static inline pmd_t pmdp_clear_flush(struct vm_area_struct *vma,
+				     unsigned long address, pmd_t *pmdp)
+{
+	return pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+}
+
+#define __HAVE_ARCH_PMDP_INVALIDATE
+static inline void pmdp_invalidate(struct vm_area_struct *vma,
+				   unsigned long address, pmd_t *pmdp)
+{
+	__pmd_idte(address, pmdp);
+}
+
+static inline pmd_t mk_pmd_phys(unsigned long physpage, pgprot_t pgprot)
+{
+	pmd_t __pmd;
+	pmd_val(__pmd) = physpage + massage_pgprot_pmd(pgprot);
+	return __pmd;
+}
+
+#define pfn_pmd(pfn, pgprot)	mk_pmd_phys(__pa((pfn) << PAGE_SHIFT),(pgprot))
+#define mk_pmd(page, pgprot)	pfn_pmd(page_to_pfn(page), (pgprot))
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return pmd_val(pmd) & _SEGMENT_ENTRY_LARGE;
+}
+
+static inline int has_transparent_hugepage(void)
+{
+	return MACHINE_HAS_HPAGE ? 1 : 0;
+}
+
+static inline unsigned long pmd_pfn(pmd_t pmd)
+{
+	if (pmd_trans_huge(pmd))
+		return pmd_val(pmd) >> HPAGE_SHIFT;
+	else
+		return pmd_val(pmd) >> PAGE_SHIFT;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /*
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -137,6 +137,7 @@ static inline void pud_free_tlb(struct m
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 #define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
+#define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
 #define tlb_migrate_finish(mm)			do { } while (0)
 
 #endif /* _S390_TLB_H */
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -898,6 +898,28 @@ bool kernel_page_present(struct page *pa
 #endif /* CONFIG_HIBERNATION && CONFIG_DEBUG_PAGEALLOC */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int pmdp_clear_flush_young(struct vm_area_struct *vma, unsigned long address,
+			   pmd_t *pmdp)
+{
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	/* No need to flush TLB
+	 * On s390 reference bits are in storage key and never in TLB */
+	return pmdp_test_and_clear_young(vma, address, pmdp);
+}
+
+int pmdp_set_access_flags(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp,
+			  pmd_t entry, int dirty)
+{
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+	if (pmd_same(*pmdp, entry))
+		return 0;
+	pmdp_invalidate(vma, address, pmdp);
+	set_pmd_at(vma->vm_mm, address, pmdp, entry);
+	return 1;
+}
+
 static void pmdp_splitting_flush_sync(void *arg)
 {
 	/* Simply deliver the interrupt */
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -318,7 +318,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on X86 && MMU
+	depends on (X86 || (S390 && 64BIT)) && MMU
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
