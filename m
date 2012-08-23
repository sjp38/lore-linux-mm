Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id DF1486B0071
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:19:00 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:59 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHIorL22741228
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:50 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHIs05018764
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:55 -0600
Message-Id: <20120823171854.473831303@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:35 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 2/7] thp: introduce pmdp_invalidate()
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-pmd-flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On System z, a valid page table entry must not be changed while it is
attached to any CPU. So instead of pmd_mknotpresent() and set_pmd_at(),
an IDTE operation would be necessary there. This patch introduces the
pmdp_invalidate() function, to allow architecture-specific
implementations.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 include/asm-generic/pgtable.h |   11 +++++++++++
 mm/huge_memory.c              |    3 +--
 2 files changed, 12 insertions(+), 2 deletions(-)

--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -93,6 +93,17 @@ static inline pmd_t pmdp_get_and_clear(s
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_INVALIDATE
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void pmdp_invalidate(struct vm_area_struct *vma,
+				   unsigned long address, pmd_t *pmdp)
+{
+	set_pmd_at(vma->vm_mm, address, pmd, pmd_mknotpresent(*pmd));
+	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pte_t *ptep,
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1374,8 +1374,7 @@ static int __split_huge_page_map(struct
 		 * SMP TLB and finally we write the non-huge version
 		 * of the pmd entry with pmd_populate.
 		 */
-		set_pmd_at(mm, address, pmd, pmd_mknotpresent(*pmd));
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		pmdp_invalidate(vma, address, pmd);
 		pmd_populate(mm, pmd, pgtable);
 		ret = 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
