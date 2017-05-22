Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5D7E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:37:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l73so128602711pfj.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:37:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f125si11038331pgc.180.2017.05.22.06.37.10
        for <linux-mm@kvack.org>;
        Mon, 22 May 2017 06:37:10 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v3 4/6] mm/hugetlb: Allow architectures to override huge_pte_clear()
Date: Mon, 22 May 2017 14:36:02 +0100
Message-Id: <20170522133604.11392-5-punit.agrawal@arm.com>
In-Reply-To: <20170522133604.11392-1-punit.agrawal@arm.com>
References: <20170522133604.11392-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, hillf.zj@alibaba-inc.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>

When unmapping a hugepage range, huge_pte_clear() is used to clear the
page table entries that are marked as not present. huge_pte_clear()
internally just ends up calling pte_clear() which does not correctly
deal with hugepages consisting of contiguous page table entries.

Add a size argument to address this issue and allow architectures to
override huge_pte_clear() in subsequent patches by making it a weak
function.

Update the s390 to use the new mechanism to override huge_pte_clear().

Note that the change only affects huge_pte_clear() - the other generic
hugetlb functions don't need any change.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/s390/include/asm/hugetlb.h | 10 ++--------
 arch/s390/mm/hugetlbpage.c      |  9 +++++++++
 include/asm-generic/hugetlb.h   |  7 ++-----
 mm/hugetlb.c                    |  8 +++++++-
 4 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index cd546a245c68..aa8489c07f24 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -38,14 +38,8 @@ static inline int prepare_hugepage_range(struct file *file,
 
 #define arch_clear_hugepage_flags(page)		do { } while (0)
 
-static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
-				  pte_t *ptep)
-{
-	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
-		pte_val(*ptep) = _REGION3_ENTRY_EMPTY;
-	else
-		pte_val(*ptep) = _SEGMENT_ENTRY_EMPTY;
-}
+void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+		    pte_t *ptep, unsigned long sz);
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long address, pte_t *ptep)
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index ae23afc18493..48e19b324017 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -144,6 +144,15 @@ pte_t huge_ptep_get(pte_t *ptep)
 	return __rste_to_pte(pte_val(*ptep));
 }
 
+void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+		    pte_t *ptep, unsigned long sz)
+{
+	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
+		pte_val(*ptep) = _REGION3_ENTRY_EMPTY;
+	else
+		pte_val(*ptep) = _SEGMENT_ENTRY_EMPTY;
+}
+
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 			      unsigned long addr, pte_t *ptep)
 {
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 99b490b4d05a..3138e126f43b 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -31,10 +31,7 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
-static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
-				  pte_t *ptep)
-{
-	pte_clear(mm, addr, ptep);
-}
+void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+		    pte_t *ptep, unsigned long sz);
 
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0e4d1fb3122f..2b0f6f96f2c1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3289,6 +3289,12 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	return ret;
 }
 
+void __weak huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+			   pte_t *ptep, unsigned long sz)
+{
+	pte_clear(mm, addr, ptep);
+}
+
 void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			    unsigned long start, unsigned long end,
 			    struct page *ref_page)
@@ -3338,7 +3344,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
