Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6AB26B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:56:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y65so193369161pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:56:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i63si22955816pge.267.2017.05.24.04.56.10
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 04:56:11 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 6/8] mm/hugetlb: Allow architectures to override huge_pte_clear()
Date: Wed, 24 May 2017 12:54:07 +0100
Message-Id: <20170524115409.31309-7-punit.agrawal@arm.com>
In-Reply-To: <20170524115409.31309-1-punit.agrawal@arm.com>
References: <20170524115409.31309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>

When unmapping a hugepage range, huge_pte_clear() is used to clear the
page table entries that are marked as not present. huge_pte_clear()
internally just ends up calling pte_clear() which does not correctly
deal with hugepages consisting of contiguous page table entries.

Add a size argument to address this issue and allow architectures to
override huge_pte_clear() by wrapping it in a #ifndef block.

Update s390 implementation with the size parameter as well.

Note that the change only affects huge_pte_clear() - the other generic
hugetlb functions don't need any change.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/s390/include/asm/hugetlb.h | 2 +-
 include/asm-generic/hugetlb.h   | 4 +++-
 mm/hugetlb.c                    | 2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index cd546a245c68..c0443500baec 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -39,7 +39,7 @@ static inline int prepare_hugepage_range(struct file *file,
 #define arch_clear_hugepage_flags(page)		do { } while (0)
 
 static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
-				  pte_t *ptep)
+				  pte_t *ptep, unsigned long sz)
 {
 	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
 		pte_val(*ptep) = _REGION3_ENTRY_EMPTY;
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 99b490b4d05a..540354f94f83 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -31,10 +31,12 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
+#ifndef huge_pte_clear
 static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
-				  pte_t *ptep)
+		    pte_t *ptep, unsigned long sz)
 {
 	pte_clear(mm, addr, ptep);
 }
+#endif
 
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0e4d1fb3122f..ddfed20cd637 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3338,7 +3338,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 * unmapped and its refcount is dropped, so just clear pte here.
 		 */
 		if (unlikely(!pte_present(pte))) {
-			huge_pte_clear(mm, address, ptep);
+			huge_pte_clear(mm, address, ptep, sz);
 			spin_unlock(ptl);
 			continue;
 		}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
