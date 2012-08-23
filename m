Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B3BF96B005D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:18:59 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHIob111075650
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:50 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHItgo018775
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:56 -0600
Message-Id: <20120823171854.686004941@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:37 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 4/7] thp, s390: thp splitting backend for System z
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-s390-split.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

This patch is part of the architecture backend for thp on System z.
It provides the functions related to thp splitting, including
serialization against gup. Unlike other archs, pmdp_splitting_flush()
cannot use a tlb flushing operation to serialize against gup on s390,
because that wouldn't be stopped by the disabled IRQs. So instead,
smp_call_function() is called with an empty function, which will have
the expected effect.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h |   13 +++++++++++++
 arch/s390/mm/gup.c              |   11 ++++++++++-
 arch/s390/mm/pgtable.c          |   18 ++++++++++++++++++
 3 files changed, 41 insertions(+), 1 deletion(-)

--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -347,6 +347,8 @@ extern struct page *vmemmap;
 
 #define _SEGMENT_ENTRY_LARGE	0x400	/* STE-format control, large page   */
 #define _SEGMENT_ENTRY_CO	0x100	/* change-recording override   */
+#define _SEGMENT_ENTRY_SPLIT_BIT 0	/* THP splitting bit number */
+#define _SEGMENT_ENTRY_SPLIT	(1UL << _SEGMENT_ENTRY_SPLIT_BIT)
 
 /* Page status table bits for virtualization */
 #define RCP_ACC_BITS	0xf000000000000000UL
@@ -506,6 +508,10 @@ static inline int pmd_bad(pmd_t pmd)
 	return (pmd_val(pmd) & mask) != _SEGMENT_ENTRY;
 }
 
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long addr, pmd_t *pmdp);
+
 static inline int pte_none(pte_t pte)
 {
 	return (pte_val(pte) & _PAGE_INVALID) && !(pte_val(pte) & _PAGE_SWT);
@@ -1159,6 +1165,13 @@ static inline pmd_t *pmd_offset(pud_t *p
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 /*
  * 31 bit swap entry format:
  * A page-table entry has some bits we have to treat in a special way.
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -115,7 +115,16 @@ static inline int gup_pmd_range(pud_t *p
 		pmd = *pmdp;
 		barrier();
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		/*
+		 * The pmd_trans_splitting() check below explains why
+		 * pmdp_splitting_flush() has to serialize with
+		 * smp_call_function() against our disabled IRQs, to stop
+		 * this gup-fast code from running while we set the
+		 * splitting bit in the pmd. Returning zero will take
+		 * the slow path that will call wait_split_huge_page()
+		 * if the pmd is still in splitting state.
+		 */
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
 		if (unlikely(pmd_huge(pmd))) {
 			if (!gup_huge_pmd(pmdp, pmd, addr, next,
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -866,3 +866,21 @@ bool kernel_page_present(struct page *pa
 	return cc == 0;
 }
 #endif /* CONFIG_HIBERNATION && CONFIG_DEBUG_PAGEALLOC */
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static void pmdp_splitting_flush_sync(void *arg)
+{
+	/* Simply deliver the interrupt */
+}
+
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	if (!test_and_set_bit(_SEGMENT_ENTRY_SPLIT_BIT,
+			      (unsigned long *) pmdp)) {
+		/* need to serialize against gup-fast (IRQ disabled) */
+		smp_call_function(pmdp_splitting_flush_sync, NULL, 1);
+	}
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
