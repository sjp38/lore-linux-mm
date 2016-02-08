Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8315F830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:33 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id ba1so145053100obb.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:33 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id li7si13352763oeb.50.2016.02.08.01.21.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:28 -0800 (PST)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:28 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5825319D8040
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:25 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LQM127525144
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:26 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LPq3028883
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:26 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 15/29] powerpc/mm: Rename hash specific page table bits (_PAGE* -> H_PAGE*)
Date: Mon,  8 Feb 2016 14:50:27 +0530
Message-Id: <1454923241-6681-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch renames _PAGE* -> H_PAGE*. This enables us to support
different page table format in the same kernel.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h      |  60 ++--
 arch/powerpc/include/asm/book3s/64/hash-64k.h     | 111 ++++---
 arch/powerpc/include/asm/book3s/64/hash.h         | 334 +++++++++++-----------
 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h |  16 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h      |  75 ++++-
 arch/powerpc/include/asm/kvm_book3s_64.h          |  10 +-
 arch/powerpc/include/asm/mmu-hash64.h             |   4 +-
 arch/powerpc/include/asm/page_64.h                |   2 +-
 arch/powerpc/include/asm/pte-common.h             |   3 +
 arch/powerpc/kernel/asm-offsets.c                 |   9 +-
 arch/powerpc/kernel/pci_64.c                      |   3 +-
 arch/powerpc/kvm/book3s_64_mmu_host.c             |   2 +-
 arch/powerpc/mm/copro_fault.c                     |   8 +-
 arch/powerpc/mm/hash64_4k.c                       |  25 +-
 arch/powerpc/mm/hash64_64k.c                      |  61 ++--
 arch/powerpc/mm/hash_native_64.c                  |  10 +-
 arch/powerpc/mm/hash_utils_64.c                   |  99 ++++---
 arch/powerpc/mm/hugepage-hash64.c                 |  22 +-
 arch/powerpc/mm/hugetlbpage-hash64.c              |  46 +--
 arch/powerpc/mm/mmu_context_hash64.c              |   4 +-
 arch/powerpc/mm/pgtable-hash64.c                  |  42 +--
 arch/powerpc/mm/pgtable_64.c                      |  96 +++++--
 arch/powerpc/mm/slb.c                             |   8 +-
 arch/powerpc/mm/slb_low.S                         |   4 +-
 arch/powerpc/mm/slice.c                           |   2 +-
 arch/powerpc/mm/tlb_hash64.c                      |   8 +-
 arch/powerpc/platforms/cell/spu_base.c            |   6 +-
 arch/powerpc/platforms/cell/spufs/fault.c         |   4 +-
 arch/powerpc/platforms/ps3/spu.c                  |   2 +-
 arch/powerpc/platforms/pseries/lpar.c             |  12 +-
 drivers/char/agp/uninorth-agp.c                   |   9 +-
 drivers/misc/cxl/fault.c                          |   6 +-
 32 files changed, 636 insertions(+), 467 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index c78f5928001b..1ef4b39f96fd 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -5,56 +5,56 @@
  * for each page table entry.  The PMD and PGD level use a 32b record for
  * each entry by assuming that each entry is page aligned.
  */
-#define PTE_INDEX_SIZE  9
-#define PMD_INDEX_SIZE  7
-#define PUD_INDEX_SIZE  9
-#define PGD_INDEX_SIZE  9
+#define H_PTE_INDEX_SIZE  9
+#define H_PMD_INDEX_SIZE  7
+#define H_PUD_INDEX_SIZE  9
+#define H_PGD_INDEX_SIZE  9
 
 #ifndef __ASSEMBLY__
-#define PTE_TABLE_SIZE	(sizeof(pte_t) << PTE_INDEX_SIZE)
-#define PMD_TABLE_SIZE	(sizeof(pmd_t) << PMD_INDEX_SIZE)
-#define PUD_TABLE_SIZE	(sizeof(pud_t) << PUD_INDEX_SIZE)
-#define PGD_TABLE_SIZE	(sizeof(pgd_t) << PGD_INDEX_SIZE)
+#define H_PTE_TABLE_SIZE	(sizeof(pte_t) << H_PTE_INDEX_SIZE)
+#define H_PMD_TABLE_SIZE	(sizeof(pmd_t) << H_PMD_INDEX_SIZE)
+#define H_PUD_TABLE_SIZE	(sizeof(pud_t) << H_PUD_INDEX_SIZE)
+#define H_PGD_TABLE_SIZE	(sizeof(pgd_t) << H_PGD_INDEX_SIZE)
 #endif	/* __ASSEMBLY__ */
 
-#define PTRS_PER_PTE	(1 << PTE_INDEX_SIZE)
-#define PTRS_PER_PMD	(1 << PMD_INDEX_SIZE)
-#define PTRS_PER_PUD	(1 << PUD_INDEX_SIZE)
-#define PTRS_PER_PGD	(1 << PGD_INDEX_SIZE)
+#define H_PTRS_PER_PTE	(1 << H_PTE_INDEX_SIZE)
+#define H_PTRS_PER_PMD	(1 << H_PMD_INDEX_SIZE)
+#define H_PTRS_PER_PUD	(1 << H_PUD_INDEX_SIZE)
+#define H_PTRS_PER_PGD	(1 << H_PGD_INDEX_SIZE)
 
 /* PMD_SHIFT determines what a second-level page table entry can map */
-#define PMD_SHIFT	(PAGE_SHIFT + PTE_INDEX_SIZE)
-#define PMD_SIZE	(1UL << PMD_SHIFT)
-#define PMD_MASK	(~(PMD_SIZE-1))
+#define H_PMD_SHIFT	(PAGE_SHIFT + H_PTE_INDEX_SIZE)
+#define H_PMD_SIZE	(1UL << H_PMD_SHIFT)
+#define H_PMD_MASK	(~(H_PMD_SIZE-1))
 
 /* With 4k base page size, hugepage PTEs go at the PMD level */
-#define MIN_HUGEPTE_SHIFT	PMD_SHIFT
+#define MIN_HUGEPTE_SHIFT	H_PMD_SHIFT
 
 /* PUD_SHIFT determines what a third-level page table entry can map */
-#define PUD_SHIFT	(PMD_SHIFT + PMD_INDEX_SIZE)
-#define PUD_SIZE	(1UL << PUD_SHIFT)
-#define PUD_MASK	(~(PUD_SIZE-1))
+#define H_PUD_SHIFT	(H_PMD_SHIFT + H_PMD_INDEX_SIZE)
+#define H_PUD_SIZE	(1UL << H_PUD_SHIFT)
+#define H_PUD_MASK	(~(H_PUD_SIZE-1))
 
 /* PGDIR_SHIFT determines what a fourth-level page table entry can map */
-#define PGDIR_SHIFT	(PUD_SHIFT + PUD_INDEX_SIZE)
-#define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
-#define PGDIR_MASK	(~(PGDIR_SIZE-1))
+#define H_PGDIR_SHIFT	(H_PUD_SHIFT + H_PUD_INDEX_SIZE)
+#define H_PGDIR_SIZE	(1UL << H_PGDIR_SHIFT)
+#define H_PGDIR_MASK	(~(H_PGDIR_SIZE-1))
 
 /* Bits to mask out from a PMD to get to the PTE page */
-#define PMD_MASKED_BITS		0
+#define H_PMD_MASKED_BITS		0
 /* Bits to mask out from a PUD to get to the PMD page */
-#define PUD_MASKED_BITS		0
+#define H_PUD_MASKED_BITS		0
 /* Bits to mask out from a PGD to get to the PUD page */
-#define PGD_MASKED_BITS		0
+#define H_PGD_MASKED_BITS		0
 
 /* PTE flags to conserve for HPTE identification */
-#define _PAGE_HPTEFLAGS (_PAGE_BUSY | _PAGE_HASHPTE | \
-			 _PAGE_F_SECOND | _PAGE_F_GIX)
+#define H_PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_HASHPTE | \
+			  H_PAGE_F_SECOND | H_PAGE_F_GIX)
 
 /* shift to put page number into pte */
-#define PTE_RPN_SHIFT	(18)
+#define H_PTE_RPN_SHIFT	(18)
 
-#define _PAGE_4K_PFN		0
+#define H_PAGE_4K_PFN		0
 #ifndef __ASSEMBLY__
 /*
  * On all 4K setups, remap_4k_pfn() equates to remap_pfn_range()
@@ -88,7 +88,7 @@ static inline int hugepd_ok(hugepd_t hpd)
 	 * if it is not a pte and have hugepd shift mask
 	 * set, then it is a hugepd directory pointer
 	 */
-	if (!(hpd.pd & _PAGE_PTE) &&
+	if (!(hpd.pd & H_PAGE_PTE) &&
 	    ((hpd.pd & HUGEPD_SHIFT_MASK) != 0))
 		return true;
 	return false;
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 5c9392b71a6b..8008c9a89416 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -1,72 +1,71 @@
 #ifndef _ASM_POWERPC_BOOK3S_64_HASH_64K_H
 #define _ASM_POWERPC_BOOK3S_64_HASH_64K_H
 
-#define PTE_INDEX_SIZE  8
-#define PMD_INDEX_SIZE  5
-#define PUD_INDEX_SIZE	5
-#define PGD_INDEX_SIZE  12
+#define H_PTE_INDEX_SIZE  8
+#define H_PMD_INDEX_SIZE  5
+#define H_PUD_INDEX_SIZE  5
+#define H_PGD_INDEX_SIZE  12
 
-#define PTRS_PER_PTE	(1 << PTE_INDEX_SIZE)
-#define PTRS_PER_PMD	(1 << PMD_INDEX_SIZE)
-#define PTRS_PER_PUD	(1 << PUD_INDEX_SIZE)
-#define PTRS_PER_PGD	(1 << PGD_INDEX_SIZE)
+#define H_PTRS_PER_PTE	(1 << H_PTE_INDEX_SIZE)
+#define H_PTRS_PER_PMD	(1 << H_PMD_INDEX_SIZE)
+#define H_PTRS_PER_PUD	(1 << H_PUD_INDEX_SIZE)
+#define H_PTRS_PER_PGD	(1 << H_PGD_INDEX_SIZE)
 
 /* With 4k base page size, hugepage PTEs go at the PMD level */
 #define MIN_HUGEPTE_SHIFT	PAGE_SHIFT
 
 /* PMD_SHIFT determines what a second-level page table entry can map */
-#define PMD_SHIFT	(PAGE_SHIFT + PTE_INDEX_SIZE)
-#define PMD_SIZE	(1UL << PMD_SHIFT)
-#define PMD_MASK	(~(PMD_SIZE-1))
+#define H_PMD_SHIFT	(PAGE_SHIFT + H_PTE_INDEX_SIZE)
+#define H_PMD_SIZE	(1UL << H_PMD_SHIFT)
+#define H_PMD_MASK	(~(H_PMD_SIZE-1))
 
 /* PUD_SHIFT determines what a third-level page table entry can map */
-#define PUD_SHIFT	(PMD_SHIFT + PMD_INDEX_SIZE)
-#define PUD_SIZE	(1UL << PUD_SHIFT)
-#define PUD_MASK	(~(PUD_SIZE-1))
+#define H_PUD_SHIFT	(H_PMD_SHIFT + H_PMD_INDEX_SIZE)
+#define H_PUD_SIZE	(1UL << H_PUD_SHIFT)
+#define H_PUD_MASK	(~(H_PUD_SIZE-1))
 
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
-#define PGDIR_SHIFT	(PUD_SHIFT + PUD_INDEX_SIZE)
-#define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
-#define PGDIR_MASK	(~(PGDIR_SIZE-1))
+#define H_PGDIR_SHIFT	(H_PUD_SHIFT + H_PUD_INDEX_SIZE)
+#define H_PGDIR_SIZE	(1UL << H_PGDIR_SHIFT)
+#define H_PGDIR_MASK	(~(H_PGDIR_SIZE-1))
 
-#define _PAGE_COMBO	0x00040000 /* this is a combo 4k page */
-#define _PAGE_4K_PFN	0x00080000 /* PFN is for a single 4k page */
+#define H_PAGE_COMBO	0x00040000 /* this is a combo 4k page */
+#define H_PAGE_4K_PFN	0x00080000 /* PFN is for a single 4k page */
 /*
  * Used to track subpage group valid if _PAGE_COMBO is set
  * This overloads _PAGE_F_GIX and _PAGE_F_SECOND
  */
-#define _PAGE_COMBO_VALID	(_PAGE_F_GIX | _PAGE_F_SECOND)
+#define H_PAGE_COMBO_VALID	(H_PAGE_F_GIX | H_PAGE_F_SECOND)
 
 /* PTE flags to conserve for HPTE identification */
-#define _PAGE_HPTEFLAGS (_PAGE_BUSY | _PAGE_F_SECOND | \
-			 _PAGE_F_GIX | _PAGE_HASHPTE | _PAGE_COMBO)
+#define H_PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_F_SECOND | \
+			  H_PAGE_F_GIX | H_PAGE_HASHPTE | H_PAGE_COMBO)
 
 /* Shift to put page number into pte.
  *
  * That gives us a max RPN of 34 bits, which means a max of 50 bits
  * of addressable physical space, or 46 bits for the special 4k PFNs.
  */
-#define PTE_RPN_SHIFT	(30)
+#define H_PTE_RPN_SHIFT	(30)
 /*
  * we support 16 fragments per PTE page of 64K size.
  */
-#define PTE_FRAG_NR	16
+#define H_PTE_FRAG_NR	16
 /*
  * We use a 2K PTE page fragment and another 2K for storing
  * real_pte_t hash index
  */
-#define PTE_FRAG_SIZE_SHIFT  12
-#define PTE_FRAG_SIZE (1UL << PTE_FRAG_SIZE_SHIFT)
-
+#define H_PTE_FRAG_SIZE_SHIFT  12
+#define H_PTE_FRAG_SIZE (1UL << H_PTE_FRAG_SIZE_SHIFT)
 /*
  * Bits to mask out from a PMD to get to the PTE page
  * PMDs point to PTE table fragments which are PTE_FRAG_SIZE aligned.
  */
-#define PMD_MASKED_BITS		(PTE_FRAG_SIZE - 1)
+#define H_PMD_MASKED_BITS		(H_PTE_FRAG_SIZE - 1)
 /* Bits to mask out from a PGD/PUD to get to the PMD page */
-#define PUD_MASKED_BITS		0x1ff
+#define H_PUD_MASKED_BITS		0x1ff
 /* FIXME!! check this */
-#define PGD_MASKED_BITS		0
+#define H_PGD_MASKED_BITS		0
 
 #ifndef __ASSEMBLY__
 
@@ -84,13 +83,13 @@ static inline real_pte_t __real_pte(pte_t pte, pte_t *ptep)
 
 	rpte.pte = pte;
 	rpte.hidx = 0;
-	if (pte_val(pte) & _PAGE_COMBO) {
+	if (pte_val(pte) & H_PAGE_COMBO) {
 		/*
 		 * Make sure we order the hidx load against the _PAGE_COMBO
 		 * check. The store side ordering is done in __hash_page_4K
 		 */
 		smp_rmb();
-		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+		hidxp = (unsigned long *)(ptep + H_PTRS_PER_PTE);
 		rpte.hidx = *hidxp;
 	}
 	return rpte;
@@ -98,9 +97,9 @@ static inline real_pte_t __real_pte(pte_t pte, pte_t *ptep)
 
 static inline unsigned long __rpte_to_hidx(real_pte_t rpte, unsigned long index)
 {
-	if ((pte_val(rpte.pte) & _PAGE_COMBO))
+	if ((pte_val(rpte.pte) & H_PAGE_COMBO))
 		return (rpte.hidx >> (index<<2)) & 0xf;
-	return (pte_val(rpte.pte) >> _PAGE_F_GIX_SHIFT) & 0xf;
+	return (pte_val(rpte.pte) >> H_PAGE_F_GIX_SHIFT) & 0xf;
 }
 
 #define __rpte_to_pte(r)	((r).pte)
@@ -123,21 +122,21 @@ extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
 #define pte_iterate_hashed_end() } while(0); } } while(0)
 
 #define pte_pagesize_index(mm, addr, pte)	\
-	(((pte) & _PAGE_COMBO)? MMU_PAGE_4K: MMU_PAGE_64K)
+	(((pte) & H_PAGE_COMBO)? MMU_PAGE_4K: MMU_PAGE_64K)
 
 #define remap_4k_pfn(vma, addr, pfn, prot)				\
-	(WARN_ON(((pfn) >= (1UL << (64 - PTE_RPN_SHIFT)))) ? -EINVAL :	\
+	(WARN_ON(((pfn) >= (1UL << (64 - H_PTE_RPN_SHIFT)))) ? -EINVAL :	\
 		remap_pfn_range((vma), (addr), (pfn), PAGE_SIZE,	\
-			__pgprot(pgprot_val((prot)) | _PAGE_4K_PFN)))
+			__pgprot(pgprot_val((prot)) | H_PAGE_4K_PFN)))
 
-#define PTE_TABLE_SIZE	PTE_FRAG_SIZE
+#define H_PTE_TABLE_SIZE	H_PTE_FRAG_SIZE
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define PMD_TABLE_SIZE	((sizeof(pmd_t) << PMD_INDEX_SIZE) + (sizeof(unsigned long) << PMD_INDEX_SIZE))
+#define H_PMD_TABLE_SIZE	((sizeof(pmd_t) << H_PMD_INDEX_SIZE) + (sizeof(unsigned long) << H_PMD_INDEX_SIZE))
 #else
-#define PMD_TABLE_SIZE	(sizeof(pmd_t) << PMD_INDEX_SIZE)
+#define H_PMD_TABLE_SIZE	(sizeof(pmd_t) <<H_PMD_INDEX_SIZE)
 #endif
-#define PUD_TABLE_SIZE	(sizeof(pud_t) << PUD_INDEX_SIZE)
-#define PGD_TABLE_SIZE	(sizeof(pgd_t) << PGD_INDEX_SIZE)
+#define H_PUD_TABLE_SIZE	(sizeof(pud_t) << H_PUD_INDEX_SIZE)
+#define H_PGD_TABLE_SIZE	(sizeof(pgd_t) << H_PGD_INDEX_SIZE)
 
 #ifdef CONFIG_HUGETLB_PAGE
 /*
@@ -152,7 +151,7 @@ static inline int pmd_huge(pmd_t pmd)
 	/*
 	 * leaf pte for huge page
 	 */
-	return !!(pmd_val(pmd) & _PAGE_PTE);
+	return !!(pmd_val(pmd) & H_PAGE_PTE);
 }
 
 static inline int pud_huge(pud_t pud)
@@ -160,7 +159,7 @@ static inline int pud_huge(pud_t pud)
 	/*
 	 * leaf pte for huge page
 	 */
-	return !!(pud_val(pud) & _PAGE_PTE);
+	return !!(pud_val(pud) & H_PAGE_PTE);
 }
 
 static inline int pgd_huge(pgd_t pgd)
@@ -168,7 +167,7 @@ static inline int pgd_huge(pgd_t pgd)
 	/*
 	 * leaf pte for huge page
 	 */
-	return !!(pgd_val(pgd) & _PAGE_PTE);
+	return !!(pgd_val(pgd) & H_PAGE_PTE);
 }
 #define pgd_huge pgd_huge
 
@@ -205,7 +204,7 @@ static inline char *get_hpte_slot_array(pmd_t *pmdp)
 	 * Order this load with the test for pmd_trans_huge in the caller
 	 */
 	smp_rmb();
-	return *(char **)(pmdp + PTRS_PER_PMD);
+	return *(char **)(pmdp + H_PTRS_PER_PMD);
 
 
 }
@@ -256,24 +255,24 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
  */
 static inline int pmd_trans_huge(pmd_t pmd)
 {
-	return !!((pmd_val(pmd) & (_PAGE_PTE | _PAGE_THP_HUGE)) ==
-		  (_PAGE_PTE | _PAGE_THP_HUGE));
+	return !!((pmd_val(pmd) & (H_PAGE_PTE | H_PAGE_THP_HUGE)) ==
+		  (H_PAGE_PTE | H_PAGE_THP_HUGE));
 }
 
 static inline int pmd_large(pmd_t pmd)
 {
-	return !!(pmd_val(pmd) & _PAGE_PTE);
+	return !!(pmd_val(pmd) & H_PAGE_PTE);
 }
 
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
-	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
+	return __pmd(pmd_val(pmd) & ~H_PAGE_PRESENT);
 }
 
 #define __HAVE_ARCH_PMD_SAME
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
-	return (((pmd_val(pmd_a) ^ pmd_val(pmd_b)) & ~_PAGE_HPTEFLAGS) == 0);
+	return (((pmd_val(pmd_a) ^ pmd_val(pmd_b)) & ~H_PAGE_HPTEFLAGS) == 0);
 }
 
 static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
@@ -281,10 +280,10 @@ static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
 {
 	unsigned long old;
 
-	if ((pmd_val(*pmdp) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
+	if ((pmd_val(*pmdp) & (H_PAGE_ACCESSED | H_PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pmd_hugepage_update(mm, addr, pmdp, _PAGE_ACCESSED, 0);
-	return ((old & _PAGE_ACCESSED) != 0);
+	old = pmd_hugepage_update(mm, addr, pmdp, H_PAGE_ACCESSED, 0);
+	return ((old & H_PAGE_ACCESSED) != 0);
 }
 
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
@@ -292,10 +291,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pmd_t *pmdp)
 {
 
-	if ((pmd_val(*pmdp) & _PAGE_RW) == 0)
+	if ((pmd_val(*pmdp) & H_PAGE_RW) == 0)
 		return;
 
-	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW, 0);
+	pmd_hugepage_update(mm, addr, pmdp, H_PAGE_RW, 0);
 }
 
 #endif /*  CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 05a048bc4a64..0bcd9f0d16c8 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -14,46 +14,44 @@
  * We could create separate kernel read-only if we used the 3 PP bits
  * combinations that newer processors provide but we currently don't.
  */
-#define _PAGE_PTE		0x00001
-#define _PAGE_PRESENT		0x00002 /* software: pte contains a translation */
-#define _PAGE_BIT_SWAP_TYPE	2
-#define _PAGE_USER		0x00004 /* matches one of the PP bits */
-#define _PAGE_EXEC		0x00008 /* No execute on POWER4 and newer (we invert) */
-#define _PAGE_GUARDED		0x00010
+#define H_PAGE_PTE		0x00001
+#define H_PAGE_PRESENT		0x00002 /* software: pte contains a translation */
+#define H_PAGE_BIT_SWAP_TYPE	2
+#define H_PAGE_USER		0x00004 /* matches one of the PP bits */
+#define H_PAGE_EXEC		0x00008 /* No execute on POWER4 and newer (we invert) */
+#define H_PAGE_GUARDED		0x00010
 /* We can derive Memory coherence from _PAGE_NO_CACHE */
-#define _PAGE_COHERENT		0x0
-#define _PAGE_NO_CACHE		0x00020 /* I: cache inhibit */
-#define _PAGE_WRITETHRU		0x00040 /* W: cache write-through */
-#define _PAGE_DIRTY		0x00080 /* C: page changed */
-#define _PAGE_ACCESSED		0x00100 /* R: page referenced */
-#define _PAGE_RW		0x00200 /* software: user write access allowed */
-#define _PAGE_HASHPTE		0x00400 /* software: pte has an associated HPTE */
-#define _PAGE_BUSY		0x00800 /* software: PTE & hash are busy */
-#define _PAGE_F_GIX		0x07000 /* full page: hidx bits */
-#define _PAGE_F_GIX_SHIFT	12
-#define _PAGE_F_SECOND		0x08000 /* Whether to use secondary hash or not */
-#define _PAGE_SPECIAL		0x10000 /* software: special page */
+#define H_PAGE_COHERENT		0x0
+#define H_PAGE_NO_CACHE		0x00020 /* I: cache inhibit */
+#define H_PAGE_WRITETHRU		0x00040 /* W: cache write-through */
+#define H_PAGE_DIRTY		0x00080 /* C: page changed */
+#define H_PAGE_ACCESSED		0x00100 /* R: page referenced */
+#define H_PAGE_RW		0x00200 /* software: user write access allowed */
+#define H_PAGE_HASHPTE		0x00400 /* software: pte has an associated HPTE */
+#define H_PAGE_BUSY		0x00800 /* software: PTE & hash are busy */
+#define H_PAGE_F_GIX		0x07000 /* full page: hidx bits */
+#define H_PAGE_F_GIX_SHIFT	12
+#define H_PAGE_F_SECOND		0x08000 /* Whether to use secondary hash or not */
+#define H_PAGE_SPECIAL		0x10000 /* software: special page */
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SOFT_DIRTY	0x20000 /* software: software dirty tracking */
+#define H_PAGE_SOFT_DIRTY	0x20000 /* software: software dirty tracking */
 #else
-#define _PAGE_SOFT_DIRTY	0x00000
+#define H_PAGE_SOFT_DIRTY	0x00000
 #endif
 
 /*
  * We need to differentiate between explicit huge page and THP huge
  * page, since THP huge page also need to track real subpage details
  */
-#define _PAGE_THP_HUGE  _PAGE_4K_PFN
+#define H_PAGE_THP_HUGE  H_PAGE_4K_PFN
 
 /*
  * set of bits not changed in pmd_modify.
  */
-#define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
-			 _PAGE_ACCESSED | _PAGE_THP_HUGE | _PAGE_PTE | \
-			 _PAGE_SOFT_DIRTY)
-
-
+#define H_HPAGE_CHG_MASK (H_PTE_RPN_MASK | H_PAGE_HPTEFLAGS |		\
+			   H_PAGE_DIRTY | H_PAGE_ACCESSED | \
+			   H_PAGE_THP_HUGE | H_PAGE_PTE | H_PAGE_SOFT_DIRTY)
 #ifdef CONFIG_PPC_64K_PAGES
 #include <asm/book3s/64/hash-64k.h>
 #else
@@ -63,29 +61,29 @@
 /*
  * Size of EA range mapped by our pagetables.
  */
-#define PGTABLE_EADDR_SIZE	(PTE_INDEX_SIZE + PMD_INDEX_SIZE + \
-				 PUD_INDEX_SIZE + PGD_INDEX_SIZE + PAGE_SHIFT)
-#define PGTABLE_RANGE		(ASM_CONST(1) << PGTABLE_EADDR_SIZE)
+#define H_PGTABLE_EADDR_SIZE	(H_PTE_INDEX_SIZE + H_PMD_INDEX_SIZE + \
+				 H_PUD_INDEX_SIZE + H_PGD_INDEX_SIZE + PAGE_SHIFT)
+#define H_PGTABLE_RANGE		(ASM_CONST(1) << H_PGTABLE_EADDR_SIZE)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define PMD_CACHE_INDEX	(PMD_INDEX_SIZE + 1)
+#define H_PMD_CACHE_INDEX	(H_PMD_INDEX_SIZE + 1)
 #else
-#define PMD_CACHE_INDEX	PMD_INDEX_SIZE
+#define H_PMD_CACHE_INDEX	H_PMD_INDEX_SIZE
 #endif
 /*
  * Define the address range of the kernel non-linear virtual area
  */
-#define KERN_VIRT_START ASM_CONST(0xD000000000000000)
-#define KERN_VIRT_SIZE	ASM_CONST(0x0000100000000000)
+#define H_KERN_VIRT_START	ASM_CONST(0xD000000000000000)
+#define H_KERN_VIRT_SIZE	ASM_CONST(0x0000100000000000)
 
 /*
  * The vmalloc space starts at the beginning of that region, and
  * occupies half of it on hash CPUs and a quarter of it on Book3E
  * (we keep a quarter for the virtual memmap)
  */
-#define VMALLOC_START	KERN_VIRT_START
-#define VMALLOC_SIZE	(KERN_VIRT_SIZE >> 1)
-#define VMALLOC_END	(VMALLOC_START + VMALLOC_SIZE)
+#define H_VMALLOC_START	H_KERN_VIRT_START
+#define H_VMALLOC_SIZE	(H_KERN_VIRT_SIZE >> 1)
+#define H_VMALLOC_END	(H_VMALLOC_START + H_VMALLOC_SIZE)
 
 /*
  * Region IDs
@@ -94,16 +92,16 @@
 #define REGION_MASK		(0xfUL << REGION_SHIFT)
 #define REGION_ID(ea)		(((unsigned long)(ea)) >> REGION_SHIFT)
 
-#define VMALLOC_REGION_ID	(REGION_ID(VMALLOC_START))
-#define KERNEL_REGION_ID	(REGION_ID(PAGE_OFFSET))
-#define VMEMMAP_REGION_ID	(0xfUL)	/* Server only */
-#define USER_REGION_ID		(0UL)
+#define H_VMALLOC_REGION_ID	(REGION_ID(H_VMALLOC_START))
+#define H_KERNEL_REGION_ID	(REGION_ID(PAGE_OFFSET))
+#define H_VMEMMAP_REGION_ID	(0xfUL)	/* Server only */
+#define H_USER_REGION_ID	(0UL)
 
 /*
  * Defines the address of the vmemap area, in its own region on
  * hash table CPUs.
  */
-#define VMEMMAP_BASE		(VMEMMAP_REGION_ID << REGION_SHIFT)
+#define H_VMEMMAP_BASE		(H_VMEMMAP_REGION_ID << REGION_SHIFT)
 
 #ifdef CONFIG_PPC_MM_SLICES
 #define HAVE_ARCH_UNMAPPED_AREA
@@ -111,51 +109,51 @@
 #endif /* CONFIG_PPC_MM_SLICES */
 
 /* No separate kernel read-only */
-#define _PAGE_KERNEL_RW		(_PAGE_RW | _PAGE_DIRTY) /* user access blocked by key */
-#define _PAGE_KERNEL_RO		 _PAGE_KERNEL_RW
-#define _PAGE_KERNEL_RWX	(_PAGE_DIRTY | _PAGE_RW | _PAGE_EXEC)
+#define H_PAGE_KERNEL_RW	(H_PAGE_RW | H_PAGE_DIRTY) /* user access blocked by key */
+#define _H_PAGE_KERNEL_RO	 H_PAGE_KERNEL_RW
+#define H_PAGE_KERNEL_RWX	(H_PAGE_DIRTY | H_PAGE_RW | H_PAGE_EXEC)
 
 /* Strong Access Ordering */
-#define _PAGE_SAO		(_PAGE_WRITETHRU | _PAGE_NO_CACHE | _PAGE_COHERENT)
+#define H_PAGE_SAO		(H_PAGE_WRITETHRU | H_PAGE_NO_CACHE | H_PAGE_COHERENT)
 
 /* No page size encoding in the linux PTE */
-#define _PAGE_PSIZE		0
+#define H_PAGE_PSIZE		0
 
 /* PTEIDX nibble */
-#define _PTEIDX_SECONDARY	0x8
-#define _PTEIDX_GROUP_IX	0x7
+#define H_PTEIDX_SECONDARY	0x8
+#define H_PTEIDX_GROUP_IX	0x7
 
 /* Hash table based platforms need atomic updates of the linux PTE */
 #define PTE_ATOMIC_UPDATES	1
-#define _PTE_NONE_MASK	_PAGE_HPTEFLAGS
+#define H_PTE_NONE_MASK	H_PAGE_HPTEFLAGS
 /*
  * The mask convered by the RPN must be a ULL on 32-bit platforms with
  * 64-bit PTEs
  */
-#define PTE_RPN_MASK	(~((1UL << PTE_RPN_SHIFT) - 1))
+#define H_PTE_RPN_MASK	(~((1UL << H_PTE_RPN_SHIFT) - 1))
 /*
  * _PAGE_CHG_MASK masks of bits that are to be preserved across
  * pgprot changes
  */
-#define _PAGE_CHG_MASK	(PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
-			 _PAGE_ACCESSED | _PAGE_SPECIAL | _PAGE_PTE | \
-			 _PAGE_SOFT_DIRTY)
+#define H_PAGE_CHG_MASK	(H_PTE_RPN_MASK | H_PAGE_HPTEFLAGS | H_PAGE_DIRTY | \
+			 H_PAGE_ACCESSED | H_PAGE_SPECIAL | H_PAGE_PTE | \
+			 H_PAGE_SOFT_DIRTY)
 /*
  * Mask of bits returned by pte_pgprot()
  */
-#define PAGE_PROT_BITS	(_PAGE_GUARDED | _PAGE_COHERENT | _PAGE_NO_CACHE | \
-			 _PAGE_WRITETHRU | _PAGE_4K_PFN | \
-			 _PAGE_USER | _PAGE_ACCESSED |  \
-			 _PAGE_RW |  _PAGE_DIRTY | _PAGE_EXEC | \
-			 _PAGE_SOFT_DIRTY)
+#define H_PAGE_PROT_BITS	(H_PAGE_GUARDED | H_PAGE_COHERENT | H_PAGE_NO_CACHE | \
+				 H_PAGE_WRITETHRU | H_PAGE_4K_PFN |	\
+				 H_PAGE_USER | H_PAGE_ACCESSED |	\
+				 H_PAGE_RW |  H_PAGE_DIRTY | H_PAGE_EXEC | \
+				 H_PAGE_SOFT_DIRTY)
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
  * cacheable kernel and user pages) and one for non cacheable
  * pages. We always set _PAGE_COHERENT when SMP is enabled or
  * the processor might need it for DMA coherency.
  */
-#define _PAGE_BASE_NC	(_PAGE_PRESENT | _PAGE_ACCESSED | _PAGE_PSIZE)
-#define _PAGE_BASE	(_PAGE_BASE_NC | _PAGE_COHERENT)
+#define H_PAGE_BASE_NC	(H_PAGE_PRESENT | H_PAGE_ACCESSED | H_PAGE_PSIZE)
+#define H_PAGE_BASE	(H_PAGE_BASE_NC | H_PAGE_COHERENT)
 
 /* Permission masks used to generate the __P and __S table,
  *
@@ -167,42 +165,42 @@
  *
  * Note due to the way vm flags are laid out, the bits are XWR
  */
-#define PAGE_NONE	__pgprot(_PAGE_BASE)
-#define PAGE_SHARED	__pgprot(_PAGE_BASE | _PAGE_USER | _PAGE_RW)
-#define PAGE_SHARED_X	__pgprot(_PAGE_BASE | _PAGE_USER | _PAGE_RW | \
-				 _PAGE_EXEC)
-#define PAGE_COPY	__pgprot(_PAGE_BASE | _PAGE_USER )
-#define PAGE_COPY_X	__pgprot(_PAGE_BASE | _PAGE_USER | _PAGE_EXEC)
-#define PAGE_READONLY	__pgprot(_PAGE_BASE | _PAGE_USER )
-#define PAGE_READONLY_X	__pgprot(_PAGE_BASE | _PAGE_USER | _PAGE_EXEC)
-
-#define __P000	PAGE_NONE
-#define __P001	PAGE_READONLY
-#define __P010	PAGE_COPY
-#define __P011	PAGE_COPY
-#define __P100	PAGE_READONLY_X
-#define __P101	PAGE_READONLY_X
-#define __P110	PAGE_COPY_X
-#define __P111	PAGE_COPY_X
-
-#define __S000	PAGE_NONE
-#define __S001	PAGE_READONLY
-#define __S010	PAGE_SHARED
-#define __S011	PAGE_SHARED
-#define __S100	PAGE_READONLY_X
-#define __S101	PAGE_READONLY_X
-#define __S110	PAGE_SHARED_X
-#define __S111	PAGE_SHARED_X
+#define H_PAGE_NONE	__pgprot(H_PAGE_BASE)
+#define H_PAGE_SHARED	__pgprot(H_PAGE_BASE | H_PAGE_USER | H_PAGE_RW)
+#define H_PAGE_SHARED_X	__pgprot(H_PAGE_BASE | H_PAGE_USER | H_PAGE_RW | \
+				 H_PAGE_EXEC)
+#define H_PAGE_COPY	__pgprot(H_PAGE_BASE | H_PAGE_USER )
+#define H_PAGE_COPY_X	__pgprot(H_PAGE_BASE | H_PAGE_USER | H_PAGE_EXEC)
+#define H_PAGE_READONLY	__pgprot(H_PAGE_BASE | H_PAGE_USER )
+#define H_PAGE_READONLY_X	__pgprot(H_PAGE_BASE | H_PAGE_USER | H_PAGE_EXEC)
+
+#define __HP000	H_PAGE_NONE
+#define __HP001	H_PAGE_READONLY
+#define __HP010	H_PAGE_COPY
+#define __HP011	H_PAGE_COPY
+#define __HP100	H_PAGE_READONLY_X
+#define __HP101	H_PAGE_READONLY_X
+#define __HP110	H_PAGE_COPY_X
+#define __HP111	H_PAGE_COPY_X
+
+#define __HS000	H_PAGE_NONE
+#define __HS001	H_PAGE_READONLY
+#define __HS010	H_PAGE_SHARED
+#define __HS011	H_PAGE_SHARED
+#define __HS100	H_PAGE_READONLY_X
+#define __HS101	H_PAGE_READONLY_X
+#define __HS110	H_PAGE_SHARED_X
+#define __HS111	H_PAGE_SHARED_X
 
 /* Permission masks used for kernel mappings */
-#define PAGE_KERNEL	__pgprot(_PAGE_BASE | _PAGE_KERNEL_RW)
-#define PAGE_KERNEL_NC	__pgprot(_PAGE_BASE_NC | _PAGE_KERNEL_RW | \
-				 _PAGE_NO_CACHE)
-#define PAGE_KERNEL_NCG	__pgprot(_PAGE_BASE_NC | _PAGE_KERNEL_RW | \
-				 _PAGE_NO_CACHE | _PAGE_GUARDED)
-#define PAGE_KERNEL_X	__pgprot(_PAGE_BASE | _PAGE_KERNEL_RWX)
-#define PAGE_KERNEL_RO	__pgprot(_PAGE_BASE | _PAGE_KERNEL_RO)
-#define PAGE_KERNEL_ROX	__pgprot(_PAGE_BASE | _PAGE_KERNEL_ROX)
+#define H_PAGE_KERNEL	__pgprot(H_PAGE_BASE | H_PAGE_KERNEL_RW)
+#define H_PAGE_KERNEL_NC	__pgprot(H_PAGE_BASE_NC | H_PAGE_KERNEL_RW | \
+				 H_PAGE_NO_CACHE)
+#define H_PAGE_KERNEL_NCG	__pgprot(H_PAGE_BASE_NC | H_PAGE_KERNEL_RW | \
+				 H_PAGE_NO_CACHE | H_PAGE_GUARDED)
+#define H_PAGE_KERNEL_X	__pgprot(H_PAGE_BASE | H_PAGE_KERNEL_RWX)
+#define H_PAGE_KERNEL_RO	__pgprot(H_PAGE_BASE | _H_PAGE_KERNEL_RO)
+#define H_PAGE_KERNEL_ROX	__pgprot(_PAGE_BASE | _H_PAGE_KERNEL_ROX)
 
 /* Protection used for kernel text. We want the debuggers to be able to
  * set breakpoints anywhere, so don't write protect the kernel text
@@ -210,31 +208,31 @@
  */
 #if defined(CONFIG_KGDB) || defined(CONFIG_XMON) || defined(CONFIG_BDI_SWITCH) ||\
 	defined(CONFIG_KPROBES) || defined(CONFIG_DYNAMIC_FTRACE)
-#define PAGE_KERNEL_TEXT	PAGE_KERNEL_X
+#define H_PAGE_KERNEL_TEXT	H_PAGE_KERNEL_X
 #else
-#define PAGE_KERNEL_TEXT	PAGE_KERNEL_ROX
+#define H_PAGE_KERNEL_TEXT	H_PAGE_KERNEL_ROX
 #endif
 
 /* Make modules code happy. We don't set RO yet */
-#define PAGE_KERNEL_EXEC	PAGE_KERNEL_X
-#define PAGE_AGP		(PAGE_KERNEL_NC)
+#define H_PAGE_KERNEL_EXEC	H_PAGE_KERNEL_X
+#define H_PAGE_AGP		(H_PAGE_KERNEL_NC)
 
-#define PMD_BAD_BITS		(PTE_TABLE_SIZE-1)
-#define PUD_BAD_BITS		(PMD_TABLE_SIZE-1)
+#define H_PMD_BAD_BITS		(H_PTE_TABLE_SIZE-1)
+#define H_PUD_BAD_BITS		(H_PMD_TABLE_SIZE-1)
 
 #ifndef __ASSEMBLY__
 #define	pmd_bad(pmd)		(!is_kernel_addr(pmd_val(pmd)) \
-				 || (pmd_val(pmd) & PMD_BAD_BITS))
-#define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
+				 || (pmd_val(pmd) & H_PMD_BAD_BITS))
+#define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~H_PMD_MASKED_BITS)
 
 #define	pud_bad(pud)		(!is_kernel_addr(pud_val(pud)) \
-				 || (pud_val(pud) & PUD_BAD_BITS))
-#define pud_page_vaddr(pud)	(pud_val(pud) & ~PUD_MASKED_BITS)
+				 || (pud_val(pud) & H_PUD_BAD_BITS))
+#define pud_page_vaddr(pud)	(pud_val(pud) & ~H_PUD_MASKED_BITS)
 
-#define pgd_index(address) (((address) >> (PGDIR_SHIFT)) & (PTRS_PER_PGD - 1))
-#define pud_index(address) (((address) >> (PUD_SHIFT)) & (PTRS_PER_PUD - 1))
-#define pmd_index(address) (((address) >> (PMD_SHIFT)) & (PTRS_PER_PMD - 1))
-#define pte_index(address) (((address) >> (PAGE_SHIFT)) & (PTRS_PER_PTE - 1))
+#define pgd_index(address) (((address) >> (H_PGDIR_SHIFT)) & (H_PTRS_PER_PGD - 1))
+#define pud_index(address) (((address) >> (H_PUD_SHIFT)) & (H_PTRS_PER_PUD - 1))
+#define pmd_index(address) (((address) >> (H_PMD_SHIFT)) & (H_PTRS_PER_PMD - 1))
+#define pte_index(address) (((address) >> (PAGE_SHIFT)) & (H_PTRS_PER_PTE - 1))
 
 /* Encode and de-code a swap entry */
 #define MAX_SWAPFILES_CHECK() do { \
@@ -243,46 +241,48 @@
 	 * Don't have overlapping bits with _PAGE_HPTEFLAGS	\
 	 * We filter HPTEFLAGS on set_pte.			\
 	 */							\
-	BUILD_BUG_ON(_PAGE_HPTEFLAGS & (0x1f << _PAGE_BIT_SWAP_TYPE)); \
-	BUILD_BUG_ON(_PAGE_HPTEFLAGS & _PAGE_SWP_SOFT_DIRTY);	\
+	BUILD_BUG_ON(H_PAGE_HPTEFLAGS & (0x1f << H_PAGE_BIT_SWAP_TYPE)); \
+	BUILD_BUG_ON(H_PAGE_HPTEFLAGS & H_PAGE_SWP_SOFT_DIRTY);	\
 	} while (0)
 /*
  * on pte we don't need handle RADIX_TREE_EXCEPTIONAL_SHIFT;
  */
 #define SWP_TYPE_BITS 5
-#define __swp_type(x)		(((x).val >> _PAGE_BIT_SWAP_TYPE) \
+#define __swp_type(x)		(((x).val >> H_PAGE_BIT_SWAP_TYPE) \
 				& ((1UL << SWP_TYPE_BITS) - 1))
-#define __swp_offset(x)		((x).val >> PTE_RPN_SHIFT)
+#define __swp_offset(x)		((x).val >> H_PTE_RPN_SHIFT)
 #define __swp_entry(type, offset)	((swp_entry_t) { \
-					((type) << _PAGE_BIT_SWAP_TYPE) \
-					| ((offset) << PTE_RPN_SHIFT) })
+					((type) << H_PAGE_BIT_SWAP_TYPE) \
+					| ((offset) << H_PTE_RPN_SHIFT) })
 /*
  * swp_entry_t must be independent of pte bits. We build a swp_entry_t from
  * swap type and offset we get from swap and convert that to pte to find a
  * matching pte in linux page table.
  * Clear bits not found in swap entries here.
  */
-#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
-#define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
+#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~H_PAGE_PTE })
+#define __swp_entry_to_pte(x)	__pte((x).val | H_PAGE_PTE)
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
+#define H_PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + H_PAGE_BIT_SWAP_TYPE))
 #else
-#define _PAGE_SWP_SOFT_DIRTY	0UL
+#define H_PAGE_SWP_SOFT_DIRTY	0UL
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_SWP_SOFT_DIRTY);
+	return __pte(pte_val(pte) | H_PAGE_SWP_SOFT_DIRTY);
 }
+
 static inline bool pte_swp_soft_dirty(pte_t pte)
 {
-	return !!(pte_val(pte) & _PAGE_SWP_SOFT_DIRTY);
+	return !!(pte_val(pte) & H_PAGE_SWP_SOFT_DIRTY);
 }
+
 static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
-	return __pte(pte_val(pte) & ~_PAGE_SWP_SOFT_DIRTY);
+	return __pte(pte_val(pte) & ~H_PAGE_SWP_SOFT_DIRTY);
 }
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
@@ -307,13 +307,13 @@ static inline unsigned long pte_update(struct mm_struct *mm,
 	stdcx.	%1,0,%3 \n\
 	bne-	1b"
 	: "=&r" (old), "=&r" (tmp), "=m" (*ptep)
-	: "r" (ptep), "r" (clr), "m" (*ptep), "i" (_PAGE_BUSY), "r" (set)
+	: "r" (ptep), "r" (clr), "m" (*ptep), "i" (H_PAGE_BUSY), "r" (set)
 	: "cc" );
 	/* huge pages use the old page table lock */
 	if (!huge)
 		assert_pte_locked(mm, addr);
 
-	if (old & _PAGE_HASHPTE)
+	if (old & H_PAGE_HASHPTE)
 		hpte_need_flush(mm, addr, ptep, old, huge);
 
 	return old;
@@ -324,10 +324,10 @@ static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
 {
 	unsigned long old;
 
-	if ((pte_val(*ptep) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
+	if ((pte_val(*ptep) & (H_PAGE_ACCESSED | H_PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0, 0);
-	return (old & _PAGE_ACCESSED) != 0;
+	old = pte_update(mm, addr, ptep, H_PAGE_ACCESSED, 0, 0);
+	return (old & H_PAGE_ACCESSED) != 0;
 }
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define ptep_test_and_clear_young(__vma, __addr, __ptep)		   \
@@ -342,19 +342,19 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pte_t *ptep)
 {
 
-	if ((pte_val(*ptep) & _PAGE_RW) == 0)
+	if ((pte_val(*ptep) & H_PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_RW, 0, 0);
+	pte_update(mm, addr, ptep, H_PAGE_RW, 0, 0);
 }
 
 static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 					   unsigned long addr, pte_t *ptep)
 {
-	if ((pte_val(*ptep) & _PAGE_RW) == 0)
+	if ((pte_val(*ptep) & H_PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_RW, 0, 1);
+	pte_update(mm, addr, ptep, H_PAGE_RW, 0, 1);
 }
 
 /*
@@ -394,8 +394,8 @@ static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 {
 	unsigned long bits = pte_val(entry) &
-		(_PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_RW | _PAGE_EXEC |
-		 _PAGE_SOFT_DIRTY);
+		(H_PAGE_DIRTY | H_PAGE_ACCESSED | H_PAGE_RW | H_PAGE_EXEC |
+		 H_PAGE_SOFT_DIRTY);
 
 	unsigned long old, tmp;
 
@@ -407,7 +407,7 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 		stdcx.	%0,0,%4\n\
 		bne-	1b"
 	:"=&r" (old), "=&r" (tmp), "=m" (*ptep)
-	:"r" (bits), "r" (ptep), "m" (*ptep), "i" (_PAGE_BUSY)
+	:"r" (bits), "r" (ptep), "m" (*ptep), "i" (H_PAGE_BUSY)
 	:"cc");
 }
 
@@ -417,31 +417,31 @@ static inline int pgd_bad(pgd_t pgd)
 }
 
 #define __HAVE_ARCH_PTE_SAME
-#define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~_PAGE_HPTEFLAGS) == 0)
-#define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~PGD_MASKED_BITS)
+#define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~H_PAGE_HPTEFLAGS) == 0)
+#define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~H_PGD_MASKED_BITS)
 
 
 /* Generic accessors to PTE bits */
-static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_RW);}
-static inline int pte_dirty(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_DIRTY); }
-static inline int pte_young(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_ACCESSED); }
-static inline int pte_special(pte_t pte)	{ return !!(pte_val(pte) & _PAGE_SPECIAL); }
-static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
-static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
+static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_RW);}
+static inline int pte_dirty(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_DIRTY); }
+static inline int pte_young(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_ACCESSED); }
+static inline int pte_special(pte_t pte)	{ return !!(pte_val(pte) & H_PAGE_SPECIAL); }
+static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~H_PTE_NONE_MASK) == 0; }
+static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & H_PAGE_PROT_BITS); }
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline bool pte_soft_dirty(pte_t pte)
 {
-	return !!(pte_val(pte) & _PAGE_SOFT_DIRTY);
+	return !!(pte_val(pte) & H_PAGE_SOFT_DIRTY);
 }
 static inline pte_t pte_mksoft_dirty(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_SOFT_DIRTY);
+	return __pte(pte_val(pte) | H_PAGE_SOFT_DIRTY);
 }
 
 static inline pte_t pte_clear_soft_dirty(pte_t pte)
 {
-	return __pte(pte_val(pte) & ~_PAGE_SOFT_DIRTY);
+	return __pte(pte_val(pte) & ~H_PAGE_SOFT_DIRTY);
 }
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
@@ -454,13 +454,13 @@ static inline pte_t pte_clear_soft_dirty(pte_t pte)
 static inline int pte_protnone(pte_t pte)
 {
 	return (pte_val(pte) &
-		(_PAGE_PRESENT | _PAGE_USER)) == _PAGE_PRESENT;
+		(H_PAGE_PRESENT | H_PAGE_USER)) == H_PAGE_PRESENT;
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
 static inline int pte_present(pte_t pte)
 {
-	return pte_val(pte) & _PAGE_PRESENT;
+	return pte_val(pte) & H_PAGE_PRESENT;
 }
 
 /* Conversion functions: convert a page and protection to a page entry,
@@ -471,49 +471,49 @@ static inline int pte_present(pte_t pte)
  */
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
 {
-	return __pte(((pte_basic_t)(pfn) << PTE_RPN_SHIFT) |
+	return __pte(((pte_basic_t)(pfn) << H_PTE_RPN_SHIFT) |
 		     pgprot_val(pgprot));
 }
 
 static inline unsigned long pte_pfn(pte_t pte)
 {
-	return pte_val(pte) >> PTE_RPN_SHIFT;
+	return pte_val(pte) >> H_PTE_RPN_SHIFT;
 }
 
 /* Generic modifiers for PTE bits */
 static inline pte_t pte_wrprotect(pte_t pte)
 {
-	return __pte(pte_val(pte) & ~_PAGE_RW);
+	return __pte(pte_val(pte) & ~H_PAGE_RW);
 }
 
 static inline pte_t pte_mkclean(pte_t pte)
 {
-	return __pte(pte_val(pte) & ~_PAGE_DIRTY);
+	return __pte(pte_val(pte) & ~H_PAGE_DIRTY);
 }
 
 static inline pte_t pte_mkold(pte_t pte)
 {
-	return __pte(pte_val(pte) & ~_PAGE_ACCESSED);
+	return __pte(pte_val(pte) & ~H_PAGE_ACCESSED);
 }
 
 static inline pte_t pte_mkwrite(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_RW);
+	return __pte(pte_val(pte) | H_PAGE_RW);
 }
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+	return __pte(pte_val(pte) | H_PAGE_DIRTY | H_PAGE_SOFT_DIRTY);
 }
 
 static inline pte_t pte_mkyoung(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_ACCESSED);
+	return __pte(pte_val(pte) | H_PAGE_ACCESSED);
 }
 
 static inline pte_t pte_mkspecial(pte_t pte)
 {
-	return __pte(pte_val(pte) | _PAGE_SPECIAL);
+	return __pte(pte_val(pte) | H_PAGE_SPECIAL);
 }
 
 static inline pte_t pte_mkhuge(pte_t pte)
@@ -523,7 +523,7 @@ static inline pte_t pte_mkhuge(pte_t pte)
 
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
-	return __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot));
+	return __pte((pte_val(pte) & H_PAGE_CHG_MASK) | pgprot_val(newprot));
 }
 
 /* This low level function performs the actual PTE insertion
@@ -545,41 +545,41 @@ static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
  * Macro to mark a page protection value as "uncacheable".
  */
 
-#define _PAGE_CACHE_CTL	(_PAGE_COHERENT | _PAGE_GUARDED | _PAGE_NO_CACHE | \
-			 _PAGE_WRITETHRU)
+#define H_PAGE_CACHE_CTL	(H_PAGE_COHERENT | H_PAGE_GUARDED | H_PAGE_NO_CACHE | \
+				 H_PAGE_WRITETHRU)
 
 #define pgprot_noncached pgprot_noncached
 static inline pgprot_t pgprot_noncached(pgprot_t prot)
 {
-	return __pgprot((pgprot_val(prot) & ~_PAGE_CACHE_CTL) |
-			_PAGE_NO_CACHE | _PAGE_GUARDED);
+	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
+			H_PAGE_NO_CACHE | H_PAGE_GUARDED);
 }
 
 #define pgprot_noncached_wc pgprot_noncached_wc
 static inline pgprot_t pgprot_noncached_wc(pgprot_t prot)
 {
-	return __pgprot((pgprot_val(prot) & ~_PAGE_CACHE_CTL) |
-			_PAGE_NO_CACHE);
+	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
+			H_PAGE_NO_CACHE);
 }
 
 #define pgprot_cached pgprot_cached
 static inline pgprot_t pgprot_cached(pgprot_t prot)
 {
-	return __pgprot((pgprot_val(prot) & ~_PAGE_CACHE_CTL) |
-			_PAGE_COHERENT);
+	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
+			H_PAGE_COHERENT);
 }
 
 #define pgprot_cached_wthru pgprot_cached_wthru
 static inline pgprot_t pgprot_cached_wthru(pgprot_t prot)
 {
-	return __pgprot((pgprot_val(prot) & ~_PAGE_CACHE_CTL) |
-			_PAGE_COHERENT | _PAGE_WRITETHRU);
+	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
+			H_PAGE_COHERENT | H_PAGE_WRITETHRU);
 }
 
 #define pgprot_cached_noncoherent pgprot_cached_noncoherent
 static inline pgprot_t pgprot_cached_noncoherent(pgprot_t prot)
 {
-	return __pgprot(pgprot_val(prot) & ~_PAGE_CACHE_CTL);
+	return __pgprot(pgprot_val(prot) & ~H_PAGE_CACHE_CTL);
 }
 
 #define pgprot_writecombine pgprot_writecombine
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
index 96f90c7e806f..dbf680970c12 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
@@ -15,45 +15,45 @@
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(H_PGD_INDEX_SIZE), GFP_KERNEL);
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
-	kmem_cache_free(PGT_CACHE(PGD_INDEX_SIZE), pgd);
+	kmem_cache_free(PGT_CACHE(H_PGD_INDEX_SIZE), pgd);
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
+	return kmem_cache_alloc(PGT_CACHE(H_PUD_INDEX_SIZE),
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 {
-	kmem_cache_free(PGT_CACHE(PUD_INDEX_SIZE), pud);
+	kmem_cache_free(PGT_CACHE(H_PUD_INDEX_SIZE), pud);
 }
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
+	return kmem_cache_alloc(PGT_CACHE(H_PMD_CACHE_INDEX),
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
-	kmem_cache_free(PGT_CACHE(PMD_CACHE_INDEX), pmd);
+	kmem_cache_free(PGT_CACHE(H_PMD_CACHE_INDEX), pmd);
 }
 
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
 				unsigned long address)
 {
-	return pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX);
+	return pgtable_free_tlb(tlb, pmd, H_PMD_CACHE_INDEX);
 }
 
 static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 				unsigned long address)
 {
-	pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE);
+	pgtable_free_tlb(tlb, pud, H_PUD_INDEX_SIZE);
 }
 #endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index dcdee03ec1b1..db109a4354e5 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -26,8 +26,6 @@
 #define IOREMAP_BASE	(PHB_IO_END)
 #define IOREMAP_END	(KERN_VIRT_START + KERN_VIRT_SIZE)
 
-#define vmemmap			((struct page *)VMEMMAP_BASE)
-
 /* Advertise special mapping type for AGP */
 #define HAVE_PAGE_AGP
 
@@ -35,6 +33,75 @@
 #define __HAVE_ARCH_PTE_SPECIAL
 
 #ifndef __ASSEMBLY__
+#ifdef CONFIG_PPC_BOOK3S_64
+extern struct page *vmemmap;
+extern unsigned long __vmalloc_start;
+extern unsigned long __vmalloc_end;
+#define VMALLOC_START	__vmalloc_start
+#define VMALLOC_END	__vmalloc_end
+
+extern unsigned long __kernel_virt_start;
+extern unsigned long __kernel_virt_size;
+#define KERN_VIRT_START __kernel_virt_start
+#define KERN_VIRT_SIZE  __kernel_virt_size
+
+extern unsigned long __ptrs_per_pte;
+#define PTRS_PER_PTE __ptrs_per_pte
+
+extern unsigned long __ptrs_per_pmd;
+#define PTRS_PER_PMD __ptrs_per_pmd
+
+extern unsigned long __pmd_shift;
+#define PMD_SHIFT	__pmd_shift
+#define PMD_SIZE	(1UL << __pmd_shift)
+#define PMD_MASK	(~(PMD_SIZE - 1))
+
+#ifndef __PAGETABLE_PUD_FOLDED
+extern unsigned long __pud_shift;
+#define PUD_SHIFT	__pud_shift
+#define PUD_SIZE	(1UL << __pud_shift)
+#define PUD_MASK	(~(PUD_SIZE - 1))
+#endif
+
+extern unsigned long __pgdir_shift;
+#define PGDIR_SHIFT	__pgdir_shift
+#define PGDIR_SIZE	(1UL << __pgdir_shift)
+#define PGDIR_MASK	(~(PGDIR_SIZE - 1))
+
+extern pgprot_t __kernel_page_prot;
+#define PAGE_KERNEL __kernel_page_prot
+
+extern pgprot_t __page_none;
+#define PAGE_NONE  __page_none
+
+extern pgprot_t __page_kernel_exec;
+#define PAGE_KERNEL_EXEC __page_kernel_exec
+
+extern unsigned long __page_no_cache;
+#define _PAGE_NO_CACHE  __page_no_cache
+
+extern unsigned long __page_guarded;
+#define _PAGE_GUARDED  __page_guarded
+
+extern unsigned long __page_user;
+#define _PAGE_USER __page_user
+
+extern unsigned long __page_coherent;
+#define _PAGE_COHERENT __page_coherent
+
+extern unsigned long __page_present;
+#define _PAGE_PRESENT __page_present
+
+extern unsigned long __page_rw;
+#define _PAGE_RW  __page_rw
+
+extern unsigned long __page_dirty;
+#define _PAGE_DIRTY  __page_dirty
+
+extern unsigned long __page_exec;
+#define _PAGE_EXEC  __page_exec
+#endif /* CONFIG_PPC_BOOK3S_64 */
+extern unsigned long ioremap_bot;
 
 /*
  * This is the default implementation of various PTE accessors, it's
@@ -45,7 +112,7 @@
 
 #define __real_pte(e,p)		((real_pte_t){(e)})
 #define __rpte_to_pte(r)	((r).pte)
-#define __rpte_to_hidx(r,index)	(pte_val(__rpte_to_pte(r)) >>_PAGE_F_GIX_SHIFT)
+#define __rpte_to_hidx(r,index)	(pte_val(__rpte_to_pte(r)) >> H_PAGE_F_GIX_SHIFT)
 
 #define pte_iterate_hashed_subpages(rpte, psize, va, index, shift)       \
 	do {							         \
@@ -216,7 +283,7 @@ static inline int pmd_protnone(pmd_t pmd)
 
 static inline pmd_t pmd_mkhuge(pmd_t pmd)
 {
-	return __pmd(pmd_val(pmd) | (_PAGE_PTE | _PAGE_THP_HUGE));
+	return __pmd(pmd_val(pmd) | (H_PAGE_PTE | H_PAGE_THP_HUGE));
 }
 
 #define __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
diff --git a/arch/powerpc/include/asm/kvm_book3s_64.h b/arch/powerpc/include/asm/kvm_book3s_64.h
index 2aa79c864e91..aa896458169f 100644
--- a/arch/powerpc/include/asm/kvm_book3s_64.h
+++ b/arch/powerpc/include/asm/kvm_book3s_64.h
@@ -309,12 +309,12 @@ static inline pte_t kvmppc_read_update_linux_pte(pte_t *ptep, int writing)
 		/*
 		 * wait until _PAGE_BUSY is clear then set it atomically
 		 */
-		if (unlikely(pte_val(old_pte) & _PAGE_BUSY)) {
+		if (unlikely(pte_val(old_pte) & H_PAGE_BUSY)) {
 			cpu_relax();
 			continue;
 		}
 		/* If pte is not present return None */
-		if (unlikely(!(pte_val(old_pte) & _PAGE_PRESENT)))
+		if (unlikely(!(pte_val(old_pte) & H_PAGE_PRESENT)))
 			return __pte(0);
 
 		new_pte = pte_mkyoung(old_pte);
@@ -334,11 +334,11 @@ static inline pte_t kvmppc_read_update_linux_pte(pte_t *ptep, int writing)
 /* Return HPTE cache control bits corresponding to Linux pte bits */
 static inline unsigned long hpte_cache_bits(unsigned long pte_val)
 {
-#if _PAGE_NO_CACHE == HPTE_R_I && _PAGE_WRITETHRU == HPTE_R_W
+#if H_PAGE_NO_CACHE == HPTE_R_I && H_PAGE_WRITETHRU == HPTE_R_W
 	return pte_val & (HPTE_R_W | HPTE_R_I);
 #else
-	return ((pte_val & _PAGE_NO_CACHE) ? HPTE_R_I : 0) +
-		((pte_val & _PAGE_WRITETHRU) ? HPTE_R_W : 0);
+	return ((pte_val & H_PAGE_NO_CACHE) ? HPTE_R_I : 0) +
+		((pte_val & H_PAGE_WRITETHRU) ? HPTE_R_W : 0);
 #endif
 }
 
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index 7352d3f212df..c3b77a1cf1a0 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -475,7 +475,7 @@ extern void slb_set_size(u16 size);
 	add	rt,rt,rx
 
 /* 4 bits per slice and we have one slice per 1TB */
-#define SLICE_ARRAY_SIZE  (PGTABLE_RANGE >> 41)
+#define SLICE_ARRAY_SIZE  (H_PGTABLE_RANGE >> 41)
 
 #ifndef __ASSEMBLY__
 
@@ -578,7 +578,7 @@ static inline unsigned long get_vsid(unsigned long context, unsigned long ea,
 	/*
 	 * Bad address. We return VSID 0 for that
 	 */
-	if ((ea & ~REGION_MASK) >= PGTABLE_RANGE)
+	if ((ea & ~REGION_MASK) >= H_PGTABLE_RANGE)
 		return 0;
 
 	if (ssize == MMU_SEGSIZE_256M)
diff --git a/arch/powerpc/include/asm/page_64.h b/arch/powerpc/include/asm/page_64.h
index d908a46d05c0..77488857c26d 100644
--- a/arch/powerpc/include/asm/page_64.h
+++ b/arch/powerpc/include/asm/page_64.h
@@ -93,7 +93,7 @@ extern u64 ppc64_pft_size;
 
 #define SLICE_LOW_TOP		(0x100000000ul)
 #define SLICE_NUM_LOW		(SLICE_LOW_TOP >> SLICE_LOW_SHIFT)
-#define SLICE_NUM_HIGH		(PGTABLE_RANGE >> SLICE_HIGH_SHIFT)
+#define SLICE_NUM_HIGH		(H_PGTABLE_RANGE >> SLICE_HIGH_SHIFT)
 
 #define GET_LOW_SLICE_INDEX(addr)	((addr) >> SLICE_LOW_SHIFT)
 #define GET_HIGH_SLICE_INDEX(addr)	((addr) >> SLICE_HIGH_SHIFT)
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index 1ec67b043065..583d5d610c68 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -28,6 +28,9 @@
 #ifndef _PAGE_4K_PFN
 #define _PAGE_4K_PFN		0
 #endif
+#ifndef H_PAGE_4K_PFN
+#define H_PAGE_4K_PFN		0
+#endif
 #ifndef _PAGE_SAO
 #define _PAGE_SAO	0
 #endif
diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
index 07cebc3514f3..21fca296c800 100644
--- a/arch/powerpc/kernel/asm-offsets.c
+++ b/arch/powerpc/kernel/asm-offsets.c
@@ -430,8 +430,15 @@ int main(void)
 #ifdef CONFIG_BUG
 	DEFINE(BUG_ENTRY_SIZE, sizeof(struct bug_entry));
 #endif
-
+	/*
+	 * Also make sure H_PGD_TABLE is largest pgd of all supported
+	 * We use that as swapper pgdir
+	 */
+#ifdef CONFIG_PPC_BOOK3S_64
+	DEFINE(PGD_TABLE_SIZE, H_PGD_TABLE_SIZE);
+#else
 	DEFINE(PGD_TABLE_SIZE, PGD_TABLE_SIZE);
+#endif
 	DEFINE(PTE_SIZE, sizeof(pte_t));
 
 #ifdef CONFIG_KVM
diff --git a/arch/powerpc/kernel/pci_64.c b/arch/powerpc/kernel/pci_64.c
index 60bb187cb46a..439d5f51d111 100644
--- a/arch/powerpc/kernel/pci_64.c
+++ b/arch/powerpc/kernel/pci_64.c
@@ -38,13 +38,14 @@
  * ISA drivers use hard coded offsets.  If no ISA bus exists nothing
  * is mapped on the first 64K of IO space
  */
-unsigned long pci_io_base = ISA_IO_BASE;
+unsigned long pci_io_base;
 EXPORT_SYMBOL(pci_io_base);
 
 static int __init pcibios_init(void)
 {
 	struct pci_controller *hose, *tmp;
 
+	pci_io_base =  ISA_IO_BASE;
 	printk(KERN_INFO "PCI: Probing PCI hardware\n");
 
 	/* For now, override phys_mem_access_prot. If we need it,g
diff --git a/arch/powerpc/kvm/book3s_64_mmu_host.c b/arch/powerpc/kvm/book3s_64_mmu_host.c
index 913cd2198fa6..30fc2d83dffa 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_host.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_host.c
@@ -189,7 +189,7 @@ map_again:
 
 		/* The ppc_md code may give us a secondary entry even though we
 		   asked for a primary. Fix up. */
-		if ((ret & _PTEIDX_SECONDARY) && !(vflags & HPTE_V_SECONDARY)) {
+		if ((ret & H_PTEIDX_SECONDARY) && !(vflags & HPTE_V_SECONDARY)) {
 			hash = ~hash;
 			hpteg = ((hash & htab_hash_mask) * HPTES_PER_GROUP);
 		}
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 6527882ce05e..a49b332c3966 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -104,16 +104,16 @@ int copro_calculate_slb(struct mm_struct *mm, u64 ea, struct copro_slb *slb)
 	int psize, ssize;
 
 	switch (REGION_ID(ea)) {
-	case USER_REGION_ID:
+	case H_USER_REGION_ID:
 		pr_devel("%s: 0x%llx -- USER_REGION_ID\n", __func__, ea);
 		psize = get_slice_psize(mm, ea);
 		ssize = user_segment_size(ea);
 		vsid = get_vsid(mm->context.id, ea, ssize);
 		vsidkey = SLB_VSID_USER;
 		break;
-	case VMALLOC_REGION_ID:
+	case H_VMALLOC_REGION_ID:
 		pr_devel("%s: 0x%llx -- VMALLOC_REGION_ID\n", __func__, ea);
-		if (ea < VMALLOC_END)
+		if (ea < H_VMALLOC_END)
 			psize = mmu_vmalloc_psize;
 		else
 			psize = mmu_io_psize;
@@ -121,7 +121,7 @@ int copro_calculate_slb(struct mm_struct *mm, u64 ea, struct copro_slb *slb)
 		vsid = get_kernel_vsid(ea, mmu_kernel_ssize);
 		vsidkey = SLB_VSID_KERNEL;
 		break;
-	case KERNEL_REGION_ID:
+	case H_KERNEL_REGION_ID:
 		pr_devel("%s: 0x%llx -- KERNEL_REGION_ID\n", __func__, ea);
 		psize = mmu_linear_psize;
 		ssize = mmu_kernel_ssize;
diff --git a/arch/powerpc/mm/hash64_4k.c b/arch/powerpc/mm/hash64_4k.c
index e7c04542ba62..c7b7e2fc3d3a 100644
--- a/arch/powerpc/mm/hash64_4k.c
+++ b/arch/powerpc/mm/hash64_4k.c
@@ -34,7 +34,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 
 		old_pte = pte_val(pte);
 		/* If PTE busy, retry the access */
-		if (unlikely(old_pte & _PAGE_BUSY))
+		if (unlikely(old_pte & H_PAGE_BUSY))
 			return 0;
 		/* If PTE permissions don't match, take page fault */
 		if (unlikely(access & ~old_pte))
@@ -44,9 +44,9 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * a write access. Since this is 4K insert of 64K page size
 		 * also add _PAGE_COMBO
 		 */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
-		if (access & _PAGE_RW)
-			new_pte |= _PAGE_DIRTY;
+		new_pte = old_pte | H_PAGE_BUSY | H_PAGE_ACCESSED | H_PAGE_HASHPTE;
+		if (access & H_PAGE_RW)
+			new_pte |= H_PAGE_DIRTY;
 	} while (old_pte != __cmpxchg_u64((unsigned long *)ptep,
 					  old_pte, new_pte));
 	/*
@@ -60,22 +60,22 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		rflags = hash_page_do_lazy_icache(rflags, __pte(old_pte), trap);
 
 	vpn  = hpt_vpn(ea, vsid, ssize);
-	if (unlikely(old_pte & _PAGE_HASHPTE)) {
+	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/*
 		 * There MIGHT be an HPTE for this pte
 		 */
 		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & _PAGE_F_SECOND)
+		if (old_pte & H_PAGE_F_SECOND)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & _PAGE_F_GIX) >> _PAGE_F_GIX_SHIFT;
+		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
 
 		if (ppc_md.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_4K,
 					 MMU_PAGE_4K, ssize, flags) == -1)
-			old_pte &= ~_PAGE_HPTEFLAGS;
+			old_pte &= ~H_PAGE_HPTEFLAGS;
 	}
 
-	if (likely(!(old_pte & _PAGE_HASHPTE))) {
+	if (likely(!(old_pte & H_PAGE_HASHPTE))) {
 
 		pa = pte_pfn(__pte(old_pte)) << PAGE_SHIFT;
 		hash = hpt_hash(vpn, shift, ssize);
@@ -115,9 +115,10 @@ repeat:
 					   MMU_PAGE_4K, MMU_PAGE_4K, old_pte);
 			return -1;
 		}
-		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | _PAGE_HASHPTE;
-		new_pte |= (slot << _PAGE_F_GIX_SHIFT) & (_PAGE_F_SECOND | _PAGE_F_GIX);
+		new_pte = (new_pte & ~H_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
+		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
+				(H_PAGE_F_SECOND | H_PAGE_F_GIX);
 	}
-	*ptep = __pte(new_pte & ~_PAGE_BUSY);
+	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 3c417f9099f9..02b012c122e8 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -23,7 +23,7 @@ bool __rpte_sub_valid(real_pte_t rpte, unsigned long index)
 	unsigned long g_idx;
 	unsigned long ptev = pte_val(rpte.pte);
 
-	g_idx = (ptev & _PAGE_COMBO_VALID) >> _PAGE_F_GIX_SHIFT;
+	g_idx = (ptev & H_PAGE_COMBO_VALID) >> H_PAGE_F_GIX_SHIFT;
 	index = index >> 2;
 	if (g_idx & (0x1 << index))
 		return true;
@@ -37,12 +37,12 @@ static unsigned long mark_subptegroup_valid(unsigned long ptev, unsigned long in
 {
 	unsigned long g_idx;
 
-	if (!(ptev & _PAGE_COMBO))
+	if (!(ptev & H_PAGE_COMBO))
 		return ptev;
 	index = index >> 2;
 	g_idx = 0x1 << index;
 
-	return ptev | (g_idx << _PAGE_F_GIX_SHIFT);
+	return ptev | (g_idx << H_PAGE_F_GIX_SHIFT);
 }
 
 int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
@@ -66,7 +66,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 
 		old_pte = pte_val(pte);
 		/* If PTE busy, retry the access */
-		if (unlikely(old_pte & _PAGE_BUSY))
+		if (unlikely(old_pte & H_PAGE_BUSY))
 			return 0;
 		/* If PTE permissions don't match, take page fault */
 		if (unlikely(access & ~old_pte))
@@ -76,9 +76,10 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * a write access. Since this is 4K insert of 64K page size
 		 * also add _PAGE_COMBO
 		 */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_COMBO | _PAGE_HASHPTE;
-		if (access & _PAGE_RW)
-			new_pte |= _PAGE_DIRTY;
+		new_pte = old_pte | H_PAGE_BUSY | H_PAGE_ACCESSED |
+				H_PAGE_COMBO | H_PAGE_HASHPTE;
+		if (access & H_PAGE_RW)
+			new_pte |= H_PAGE_DIRTY;
 	} while (old_pte != __cmpxchg_u64((unsigned long *)ptep,
 					  old_pte, new_pte));
 	/*
@@ -103,15 +104,15 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	/*
 	 *None of the sub 4k page is hashed
 	 */
-	if (!(old_pte & _PAGE_HASHPTE))
+	if (!(old_pte & H_PAGE_HASHPTE))
 		goto htab_insert_hpte;
 	/*
 	 * Check if the pte was already inserted into the hash table
 	 * as a 64k HW page, and invalidate the 64k HPTE if so.
 	 */
-	if (!(old_pte & _PAGE_COMBO)) {
+	if (!(old_pte & H_PAGE_COMBO)) {
 		flush_hash_page(vpn, rpte, MMU_PAGE_64K, ssize, flags);
-		old_pte &= ~_PAGE_HASHPTE | _PAGE_F_GIX | _PAGE_F_SECOND;
+		old_pte &= ~H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND;
 		goto htab_insert_hpte;
 	}
 	/*
@@ -122,10 +123,10 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 
 		hash = hpt_hash(vpn, shift, ssize);
 		hidx = __rpte_to_hidx(rpte, subpg_index);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 
 		ret = ppc_md.hpte_updatepp(slot, rflags, vpn,
 					   MMU_PAGE_4K, MMU_PAGE_4K,
@@ -137,7 +138,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		if (ret == -1)
 			goto htab_insert_hpte;
 
-		*ptep = __pte(new_pte & ~_PAGE_BUSY);
+		*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 		return 0;
 	}
 
@@ -145,7 +146,7 @@ htab_insert_hpte:
 	/*
 	 * handle _PAGE_4K_PFN case
 	 */
-	if (old_pte & _PAGE_4K_PFN) {
+	if (old_pte & H_PAGE_4K_PFN) {
 		/*
 		 * All the sub 4k page have the same
 		 * physical address.
@@ -197,16 +198,16 @@ repeat:
 	 * Since we have _PAGE_BUSY set on ptep, we can be sure
 	 * nobody is undating hidx.
 	 */
-	hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+	hidxp = (unsigned long *)(ptep + H_PTRS_PER_PTE);
 	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
 	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
 	new_pte = mark_subptegroup_valid(new_pte, subpg_index);
-	new_pte |=  _PAGE_HASHPTE;
+	new_pte |=  H_PAGE_HASHPTE;
 	/*
 	 * check __real_pte for details on matching smp_rmb()
 	 */
 	smp_wmb();
-	*ptep = __pte(new_pte & ~_PAGE_BUSY);
+	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
 
@@ -229,7 +230,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 
 		old_pte = pte_val(pte);
 		/* If PTE busy, retry the access */
-		if (unlikely(old_pte & _PAGE_BUSY))
+		if (unlikely(old_pte & H_PAGE_BUSY))
 			return 0;
 		/* If PTE permissions don't match, take page fault */
 		if (unlikely(access & ~old_pte))
@@ -239,16 +240,16 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		 * If so, bail out and refault as a 4k page
 		 */
 		if (!mmu_has_feature(MMU_FTR_CI_LARGE_PAGE) &&
-		    unlikely(old_pte & _PAGE_NO_CACHE))
+		    unlikely(old_pte & H_PAGE_NO_CACHE))
 			return 0;
 		/*
 		 * Try to lock the PTE, add ACCESSED and DIRTY if it was
 		 * a write access. Since this is 4K insert of 64K page size
 		 * also add _PAGE_COMBO
 		 */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
-		if (access & _PAGE_RW)
-			new_pte |= _PAGE_DIRTY;
+		new_pte = old_pte | H_PAGE_BUSY | H_PAGE_ACCESSED | H_PAGE_HASHPTE;
+		if (access & H_PAGE_RW)
+			new_pte |= H_PAGE_DIRTY;
 	} while (old_pte != __cmpxchg_u64((unsigned long *)ptep,
 					  old_pte, new_pte));
 
@@ -259,22 +260,22 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		rflags = hash_page_do_lazy_icache(rflags, __pte(old_pte), trap);
 
 	vpn  = hpt_vpn(ea, vsid, ssize);
-	if (unlikely(old_pte & _PAGE_HASHPTE)) {
+	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/*
 		 * There MIGHT be an HPTE for this pte
 		 */
 		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & _PAGE_F_SECOND)
+		if (old_pte & H_PAGE_F_SECOND)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & _PAGE_F_GIX) >> _PAGE_F_GIX_SHIFT;
+		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
 
 		if (ppc_md.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_64K,
 					 MMU_PAGE_64K, ssize, flags) == -1)
-			old_pte &= ~_PAGE_HPTEFLAGS;
+			old_pte &= ~H_PAGE_HPTEFLAGS;
 	}
 
-	if (likely(!(old_pte & _PAGE_HASHPTE))) {
+	if (likely(!(old_pte & H_PAGE_HASHPTE))) {
 
 		pa = pte_pfn(__pte(old_pte)) << PAGE_SHIFT;
 		hash = hpt_hash(vpn, shift, ssize);
@@ -314,9 +315,9 @@ repeat:
 					   MMU_PAGE_64K, MMU_PAGE_64K, old_pte);
 			return -1;
 		}
-		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | _PAGE_HASHPTE;
-		new_pte |= (slot << _PAGE_F_GIX_SHIFT) & (_PAGE_F_SECOND | _PAGE_F_GIX);
+		new_pte = (new_pte & ~H_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
+		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) & (H_PAGE_F_SECOND | H_PAGE_F_GIX);
 	}
-	*ptep = __pte(new_pte & ~_PAGE_BUSY);
+	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index 8eaac81347fd..a8376666083f 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -444,7 +444,7 @@ static void native_hugepage_invalidate(unsigned long vsid,
 	unsigned long hidx, vpn = 0, hash, slot;
 
 	shift = mmu_psize_defs[psize].shift;
-	max_hpte_count = 1U << (PMD_SHIFT - shift);
+	max_hpte_count = 1U << (H_PMD_SHIFT - shift);
 
 	local_irq_save(flags);
 	for (i = 0; i < max_hpte_count; i++) {
@@ -457,11 +457,11 @@ static void native_hugepage_invalidate(unsigned long vsid,
 		addr = s_addr + (i * (1ul << shift));
 		vpn = hpt_vpn(addr, vsid, ssize);
 		hash = hpt_hash(vpn, shift, ssize);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 
 		hptep = htab_address + slot;
 		want_v = hpte_encode_avpn(vpn, psize, ssize);
@@ -665,10 +665,10 @@ static void native_flush_hash_range(unsigned long number, int local)
 		pte_iterate_hashed_subpages(pte, psize, vpn, index, shift) {
 			hash = hpt_hash(vpn, shift, ssize);
 			hidx = __rpte_to_hidx(pte, index);
-			if (hidx & _PTEIDX_SECONDARY)
+			if (hidx & H_PTEIDX_SECONDARY)
 				hash = ~hash;
 			slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-			slot += hidx & _PTEIDX_GROUP_IX;
+			slot += hidx & H_PTEIDX_GROUP_IX;
 			hptep = htab_address + slot;
 			want_v = hpte_encode_avpn(vpn, psize, ssize);
 			native_lock_hpte(hptep);
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 3199bbc654c5..d5fcd96d9b63 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -164,7 +164,7 @@ unsigned long htab_convert_pte_flags(unsigned long pteflags)
 	unsigned long rflags = 0;
 
 	/* _PAGE_EXEC -> NOEXEC */
-	if ((pteflags & _PAGE_EXEC) == 0)
+	if ((pteflags & H_PAGE_EXEC) == 0)
 		rflags |= HPTE_R_N;
 	/*
 	 * PP bits:
@@ -174,9 +174,9 @@ unsigned long htab_convert_pte_flags(unsigned long pteflags)
 	 * User area mapped by 0x2 and read only use by
 	 * 0x3.
 	 */
-	if (pteflags & _PAGE_USER) {
+	if (pteflags & H_PAGE_USER) {
 		rflags |= 0x2;
-		if (!((pteflags & _PAGE_RW) && (pteflags & _PAGE_DIRTY)))
+		if (!((pteflags & H_PAGE_RW) && (pteflags & H_PAGE_DIRTY)))
 			rflags |= 0x1;
 	}
 	/*
@@ -186,11 +186,11 @@ unsigned long htab_convert_pte_flags(unsigned long pteflags)
 	/*
 	 * Add in WIG bits
 	 */
-	if (pteflags & _PAGE_WRITETHRU)
+	if (pteflags & H_PAGE_WRITETHRU)
 		rflags |= HPTE_R_W;
-	if (pteflags & _PAGE_NO_CACHE)
+	if (pteflags & H_PAGE_NO_CACHE)
 		rflags |= HPTE_R_I;
-	if (pteflags & _PAGE_GUARDED)
+	if (pteflags & H_PAGE_GUARDED)
 		rflags |= HPTE_R_G;
 
 	return rflags;
@@ -635,7 +635,7 @@ static unsigned long __init htab_get_table_size(void)
 int create_section_mapping(unsigned long start, unsigned long end)
 {
 	return htab_bolt_mapping(start, end, __pa(start),
-				 pgprot_val(PAGE_KERNEL), mmu_linear_psize,
+				 pgprot_val(H_PAGE_KERNEL), mmu_linear_psize,
 				 mmu_kernel_ssize);
 }
 
@@ -718,7 +718,7 @@ static void __init htab_initialize(void)
 		mtspr(SPRN_SDR1, _SDR1);
 	}
 
-	prot = pgprot_val(PAGE_KERNEL);
+	prot = pgprot_val(H_PAGE_KERNEL);
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	linear_map_hash_count = memblock_end_of_DRAM() >> PAGE_SHIFT;
@@ -800,6 +800,37 @@ static void __init htab_initialize(void)
 
 void __init early_init_mmu(void)
 {
+	/*
+	 * initialize global variables
+	 */
+	__ptrs_per_pte = H_PTRS_PER_PTE;
+	__ptrs_per_pmd = H_PTRS_PER_PMD;
+	__pmd_shift    = H_PMD_SHIFT;
+#ifndef __PAGETABLE_PUD_FOLDED
+	__pud_shift    = H_PUD_SHIFT;
+#endif
+	__pgdir_shift  = H_PGDIR_SHIFT;
+	__kernel_virt_start = H_KERN_VIRT_START;
+	__kernel_virt_size = H_KERN_VIRT_SIZE;
+	vmemmap = (struct page *)H_VMEMMAP_BASE;
+	__vmalloc_start = H_VMALLOC_START;
+	__vmalloc_end = H_VMALLOC_END;
+	ioremap_bot = IOREMAP_BASE;
+	/*
+	 * initialize page flags used by the core kernel
+	 */
+	__kernel_page_prot = H_PAGE_KERNEL;
+	__page_none = H_PAGE_NONE;
+	__page_no_cache = H_PAGE_NO_CACHE;
+	__page_guarded = H_PAGE_GUARDED;
+	__page_user = H_PAGE_USER;
+	__page_coherent = H_PAGE_COHERENT;
+	__page_present = H_PAGE_PRESENT;
+	__page_kernel_exec = H_PAGE_KERNEL_EXEC;
+	__page_rw = H_PAGE_RW;
+	__page_dirty = H_PAGE_DIRTY;
+	__page_exec = H_PAGE_EXEC;
+
 	/* Initialize the MMU Hash table and create the linear mapping
 	 * of memory. Has to be done before SLB initialization as this is
 	 * currently where the page size encoding is obtained.
@@ -921,8 +952,8 @@ static int subpage_protection(struct mm_struct *mm, unsigned long ea)
 	/* extract 2-bit bitfield for this 4k subpage */
 	spp >>= 30 - 2 * ((ea >> 12) & 0xf);
 
-	/* turn 0,1,2,3 into combination of _PAGE_USER and _PAGE_RW */
-	spp = ((spp & 2) ? _PAGE_USER : 0) | ((spp & 1) ? _PAGE_RW : 0);
+	/* turn 0,1,2,3 into combination of H_PAGE_USER and H_PAGE_RW */
+	spp = ((spp & 2) ? H_PAGE_USER : 0) | ((spp & 1) ? H_PAGE_RW : 0);
 	return spp;
 }
 
@@ -987,7 +1018,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 
 	/* Get region & vsid */
  	switch (REGION_ID(ea)) {
-	case USER_REGION_ID:
+	case H_USER_REGION_ID:
 		user_region = 1;
 		if (! mm) {
 			DBG_LOW(" user region with no mm !\n");
@@ -998,7 +1029,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 		ssize = user_segment_size(ea);
 		vsid = get_vsid(mm->context.id, ea, ssize);
 		break;
-	case VMALLOC_REGION_ID:
+	case H_VMALLOC_REGION_ID:
 		vsid = get_kernel_vsid(ea, mmu_kernel_ssize);
 		if (ea < VMALLOC_END)
 			psize = mmu_vmalloc_psize;
@@ -1054,7 +1085,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 	}
 
 	/* Add _PAGE_PRESENT to the required access perm */
-	access |= _PAGE_PRESENT;
+	access |= H_PAGE_PRESENT;
 
 	/* Pre-check access permissions (will be re-checked atomically
 	 * in __hash_page_XX but this pre-check is a fast path
@@ -1098,7 +1129,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 	/* Do actual hashing */
 #ifdef CONFIG_PPC_64K_PAGES
 	/* If _PAGE_4K_PFN is set, make sure this is a 4k segment */
-	if ((pte_val(*ptep) & _PAGE_4K_PFN) && psize == MMU_PAGE_64K) {
+	if ((pte_val(*ptep) & H_PAGE_4K_PFN) && psize == MMU_PAGE_64K) {
 		demote_segment_4k(mm, ea);
 		psize = MMU_PAGE_4K;
 	}
@@ -1107,7 +1138,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 	 * using non cacheable large pages, then we switch to 4k
 	 */
 	if (mmu_ci_restrictions && psize == MMU_PAGE_64K &&
-	    (pte_val(*ptep) & _PAGE_NO_CACHE)) {
+	    (pte_val(*ptep) & H_PAGE_NO_CACHE)) {
 		if (user_region) {
 			demote_segment_4k(mm, ea);
 			psize = MMU_PAGE_4K;
@@ -1171,7 +1202,7 @@ int hash_page(unsigned long ea, unsigned long access, unsigned long trap,
 	unsigned long flags = 0;
 	struct mm_struct *mm = current->mm;
 
-	if (REGION_ID(ea) == VMALLOC_REGION_ID)
+	if (REGION_ID(ea) == H_VMALLOC_REGION_ID)
 		mm = &init_mm;
 
 	if (dsisr & DSISR_NOHPTE)
@@ -1184,28 +1215,28 @@ EXPORT_SYMBOL_GPL(hash_page);
 int __hash_page(unsigned long ea, unsigned long msr, unsigned long trap,
 		unsigned long dsisr)
 {
-	unsigned long access = _PAGE_PRESENT;
+	unsigned long access = H_PAGE_PRESENT;
 	unsigned long flags = 0;
 	struct mm_struct *mm = current->mm;
 
-	if (REGION_ID(ea) == VMALLOC_REGION_ID)
+	if (REGION_ID(ea) == H_VMALLOC_REGION_ID)
 		mm = &init_mm;
 
 	if (dsisr & DSISR_NOHPTE)
 		flags |= HPTE_NOHPTE_UPDATE;
 
 	if (dsisr & DSISR_ISSTORE)
-		access |= _PAGE_RW;
+		access |= H_PAGE_RW;
 	/*
 	 * We need to set the _PAGE_USER bit if MSR_PR is set or if we are
 	 * accessing a userspace segment (even from the kernel). We assume
 	 * kernel addresses always have the high bit set.
 	 */
-	if ((msr & MSR_PR) || (REGION_ID(ea) == USER_REGION_ID))
-		access |= _PAGE_USER;
+	if ((msr & MSR_PR) || (REGION_ID(ea) == H_USER_REGION_ID))
+		access |= H_PAGE_USER;
 
 	if (trap == 0x400)
-		access |= _PAGE_EXEC;
+		access |= H_PAGE_EXEC;
 
 	return hash_page_mm(mm, ea, access, trap, flags);
 }
@@ -1220,7 +1251,7 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 	unsigned long flags;
 	int rc, ssize, update_flags = 0;
 
-	BUG_ON(REGION_ID(ea) != USER_REGION_ID);
+	BUG_ON(REGION_ID(ea) != H_USER_REGION_ID);
 
 #ifdef CONFIG_PPC_MM_SLICES
 	/* We only prefault standard pages for now */
@@ -1263,7 +1294,7 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 	 * That way we don't have to duplicate all of the logic for segment
 	 * page size demotion here
 	 */
-	if (pte_val(*ptep) & (_PAGE_4K_PFN | _PAGE_NO_CACHE))
+	if (pte_val(*ptep) & (H_PAGE_4K_PFN | H_PAGE_NO_CACHE))
 		goto out_exit;
 #endif /* CONFIG_PPC_64K_PAGES */
 
@@ -1306,10 +1337,10 @@ void flush_hash_page(unsigned long vpn, real_pte_t pte, int psize, int ssize,
 	pte_iterate_hashed_subpages(pte, psize, vpn, index, shift) {
 		hash = hpt_hash(vpn, shift, ssize);
 		hidx = __rpte_to_hidx(pte, index);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 		DBG_LOW(" sub %ld: hash=%lx, hidx=%lx\n", index, slot, hidx);
 		/*
 		 * We use same base page size and actual psize, because we don't
@@ -1380,11 +1411,11 @@ void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
 		addr = s_addr + (i * (1ul << shift));
 		vpn = hpt_vpn(addr, vsid, ssize);
 		hash = hpt_hash(vpn, shift, ssize);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 		ppc_md.hpte_invalidate(slot, vpn, psize,
 				       MMU_PAGE_16M, ssize, local);
 	}
@@ -1517,10 +1548,10 @@ static void kernel_unmap_linear_page(unsigned long vaddr, unsigned long lmi)
 	hidx = linear_map_hash_slots[lmi] & 0x7f;
 	linear_map_hash_slots[lmi] = 0;
 	spin_unlock(&linear_map_hash_lock);
-	if (hidx & _PTEIDX_SECONDARY)
+	if (hidx & H_PTEIDX_SECONDARY)
 		hash = ~hash;
 	slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-	slot += hidx & _PTEIDX_GROUP_IX;
+	slot += hidx & H_PTEIDX_GROUP_IX;
 	ppc_md.hpte_invalidate(slot, vpn, mmu_linear_psize, mmu_linear_psize,
 			       mmu_kernel_ssize, 0);
 }
@@ -1566,9 +1597,9 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 }
 
 static pgprot_t hash_protection_map[16] = {
-	__P000, __P001, __P010, __P011, __P100,
-	__P101, __P110, __P111, __S000, __S001,
-	__S010, __S011, __S100, __S101, __S110, __S111
+	__HP000, __HP001, __HP010, __HP011, __HP100,
+	__HP101, __HP110, __HP111, __HS000, __HS001,
+	__HS010, __HS011, __HS100, __HS101, __HS110, __HS111
 };
 
 pgprot_t vm_get_page_prot(unsigned long vm_flags)
@@ -1576,7 +1607,7 @@ pgprot_t vm_get_page_prot(unsigned long vm_flags)
 	pgprot_t prot_soa = __pgprot(0);
 
 	if (vm_flags & VM_SAO)
-		prot_soa = __pgprot(_PAGE_SAO);
+		prot_soa = __pgprot(H_PAGE_SAO);
 
 	return __pgprot(pgprot_val(hash_protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index 3c4bd4c0ade9..169b680b0aed 100644
--- a/arch/powerpc/mm/hugepage-hash64.c
+++ b/arch/powerpc/mm/hugepage-hash64.c
@@ -37,7 +37,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 
 		old_pmd = pmd_val(pmd);
 		/* If PMD busy, retry the access */
-		if (unlikely(old_pmd & _PAGE_BUSY))
+		if (unlikely(old_pmd & H_PAGE_BUSY))
 			return 0;
 		/* If PMD permissions don't match, take page fault */
 		if (unlikely(access & ~old_pmd))
@@ -46,9 +46,9 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * Try to lock the PTE, add ACCESSED and DIRTY if it was
 		 * a write access
 		 */
-		new_pmd = old_pmd | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
-		if (access & _PAGE_RW)
-			new_pmd |= _PAGE_DIRTY;
+		new_pmd = old_pmd | H_PAGE_BUSY | H_PAGE_ACCESSED | H_PAGE_HASHPTE;
+		if (access & H_PAGE_RW)
+			new_pmd |= H_PAGE_DIRTY;
 	} while (old_pmd != __cmpxchg_u64((unsigned long *)pmdp,
 					  old_pmd, new_pmd));
 	rflags = htab_convert_pte_flags(new_pmd);
@@ -68,7 +68,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 	 */
 	shift = mmu_psize_defs[psize].shift;
 	index = (ea & ~HPAGE_PMD_MASK) >> shift;
-	BUG_ON(index >= PTE_FRAG_SIZE);
+	BUG_ON(index >= H_PTE_FRAG_SIZE);
 
 	vpn = hpt_vpn(ea, vsid, ssize);
 	hpte_slot_array = get_hpte_slot_array(pmdp);
@@ -78,7 +78,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * base page size. This is because demote_segment won't flush
 		 * hash page table entries.
 		 */
-		if ((old_pmd & _PAGE_HASHPTE) && !(old_pmd & _PAGE_COMBO))
+		if ((old_pmd & H_PAGE_HASHPTE) && !(old_pmd & H_PAGE_COMBO))
 			flush_hash_hugepage(vsid, ea, pmdp, MMU_PAGE_64K,
 					    ssize, flags);
 	}
@@ -88,10 +88,10 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		/* update the hpte bits */
 		hash = hpt_hash(vpn, shift, ssize);
 		hidx =  hpte_hash_index(hpte_slot_array, index);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 
 		ret = ppc_md.hpte_updatepp(slot, rflags, vpn,
 					   psize, lpsize, ssize, flags);
@@ -115,7 +115,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		hash = hpt_hash(vpn, shift, ssize);
 		/* insert new entry */
 		pa = pmd_pfn(__pmd(old_pmd)) << PAGE_SHIFT;
-		new_pmd |= _PAGE_HASHPTE;
+		new_pmd |= H_PAGE_HASHPTE;
 
 repeat:
 		hpte_group = ((hash & htab_hash_mask) * HPTES_PER_GROUP) & ~0x7UL;
@@ -163,13 +163,13 @@ repeat:
 	 * base page size 4k.
 	 */
 	if (psize == MMU_PAGE_4K)
-		new_pmd |= _PAGE_COMBO;
+		new_pmd |= H_PAGE_COMBO;
 	/*
 	 * The hpte valid is stored in the pgtable whose address is in the
 	 * second half of the PMD. Order this against clearing of the busy bit in
 	 * huge pmd.
 	 */
 	smp_wmb();
-	*pmdp = __pmd(new_pmd & ~_PAGE_BUSY);
+	*pmdp = __pmd(new_pmd & ~H_PAGE_BUSY);
 	return 0;
 }
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 068ac0e8d07d..0126900c696e 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -59,16 +59,16 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	do {
 		old_pte = pte_val(*ptep);
 		/* If PTE busy, retry the access */
-		if (unlikely(old_pte & _PAGE_BUSY))
+		if (unlikely(old_pte & H_PAGE_BUSY))
 			return 0;
 		/* If PTE permissions don't match, take page fault */
 		if (unlikely(access & ~old_pte))
 			return 1;
 		/* Try to lock the PTE, add ACCESSED and DIRTY if it was
 		 * a write access */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
-		if (access & _PAGE_RW)
-			new_pte |= _PAGE_DIRTY;
+		new_pte = old_pte | H_PAGE_BUSY | H_PAGE_ACCESSED | H_PAGE_HASHPTE;
+		if (access & H_PAGE_RW)
+			new_pte |= H_PAGE_DIRTY;
 	} while(old_pte != __cmpxchg_u64((unsigned long *)ptep,
 					 old_pte, new_pte));
 	rflags = htab_convert_pte_flags(new_pte);
@@ -80,28 +80,28 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		rflags = hash_page_do_lazy_icache(rflags, __pte(old_pte), trap);
 
 	/* Check if pte already has an hpte (case 2) */
-	if (unlikely(old_pte & _PAGE_HASHPTE)) {
+	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/* There MIGHT be an HPTE for this pte */
 		unsigned long hash, slot;
 
 		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & _PAGE_F_SECOND)
+		if (old_pte & H_PAGE_F_SECOND)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & _PAGE_F_GIX) >> 12;
+		slot += (old_pte & H_PAGE_F_GIX) >> 12;
 
 		if (ppc_md.hpte_updatepp(slot, rflags, vpn, mmu_psize,
 					 mmu_psize, ssize, flags) == -1)
-			old_pte &= ~_PAGE_HPTEFLAGS;
+			old_pte &= ~H_PAGE_HPTEFLAGS;
 	}
 
-	if (likely(!(old_pte & _PAGE_HASHPTE))) {
+	if (likely(!(old_pte & H_PAGE_HASHPTE))) {
 		unsigned long hash = hpt_hash(vpn, shift, ssize);
 
 		pa = pte_pfn(__pte(old_pte)) << PAGE_SHIFT;
 
 		/* clear HPTE slot informations in new PTE */
-		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | _PAGE_HASHPTE;
+		new_pte = (new_pte & ~H_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
 
 		slot = hpte_insert_repeating(hash, vpn, pa, rflags, 0,
 					     mmu_psize, ssize);
@@ -117,13 +117,13 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 			return -1;
 		}
 
-		new_pte |= (slot << 12) & (_PAGE_F_SECOND | _PAGE_F_GIX);
+		new_pte |= (slot << 12) & (H_PAGE_F_SECOND | H_PAGE_F_GIX);
 	}
 
 	/*
 	 * No need to use ldarx/stdcx here
 	 */
-	*ptep = __pte(new_pte & ~_PAGE_BUSY);
+	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
 
@@ -188,25 +188,25 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	addr &= ~(sz-1);
 	pg = pgd_offset(mm, addr);
 
-	if (pshift == PGDIR_SHIFT)
+	if (pshift == H_PGDIR_SHIFT)
 		/* 16GB huge page */
 		return (pte_t *) pg;
-	else if (pshift > PUD_SHIFT)
+	else if (pshift > H_PUD_SHIFT)
 		/*
 		 * We need to use hugepd table
 		 */
 		hpdp = (hugepd_t *)pg;
 	else {
-		pdshift = PUD_SHIFT;
+		pdshift = H_PUD_SHIFT;
 		pu = pud_alloc(mm, pg, addr);
-		if (pshift == PUD_SHIFT)
+		if (pshift == H_PUD_SHIFT)
 			return (pte_t *)pu;
-		else if (pshift > PMD_SHIFT)
+		else if (pshift > H_PMD_SHIFT)
 			hpdp = (hugepd_t *)pu;
 		else {
-			pdshift = PMD_SHIFT;
+			pdshift = H_PMD_SHIFT;
 			pm = pmd_alloc(mm, pu, addr);
-			if (pshift == PMD_SHIFT)
+			if (pshift == H_PMD_SHIFT)
 				/* 16MB hugepage */
 				return (pte_t *)pm;
 			else
@@ -272,7 +272,7 @@ static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 			WARN_ON(!pmd_none_or_clear_bad(pmd));
 			continue;
 		}
-		free_hugepd_range(tlb, (hugepd_t *)pmd, PMD_SHIFT,
+		free_hugepd_range(tlb, (hugepd_t *)pmd, H_PMD_SHIFT,
 				  addr, next, floor, ceiling);
 	} while (addr = next, addr != end);
 
@@ -311,7 +311,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
 					       ceiling);
 		} else {
-			free_hugepd_range(tlb, (hugepd_t *)pud, PUD_SHIFT,
+			free_hugepd_range(tlb, (hugepd_t *)pud, H_PUD_SHIFT,
 					  addr, next, floor, ceiling);
 		}
 	} while (addr = next, addr != end);
@@ -320,7 +320,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 	if (start < floor)
 		return;
 	if (ceiling) {
-		ceiling &= PGDIR_MASK;
+		ceiling &= H_PGDIR_MASK;
 		if (!ceiling)
 			return;
 	}
@@ -367,7 +367,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 				continue;
 			hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
 		} else {
-			free_hugepd_range(tlb, (hugepd_t *)pgd, PGDIR_SHIFT,
+			free_hugepd_range(tlb, (hugepd_t *)pgd, H_PGDIR_SHIFT,
 					  addr, next, floor, ceiling);
 		}
 	} while (addr = next, addr != end);
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index 4e4efbc2658e..ff9baa5d2944 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -116,9 +116,9 @@ static void destroy_pagetable_page(struct mm_struct *mm)
 
 	page = virt_to_page(pte_frag);
 	/* drop all the pending references */
-	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
+	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> H_PTE_FRAG_SIZE_SHIFT;
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
-	count = atomic_sub_return(PTE_FRAG_NR - count, &page->_count);
+	count = atomic_sub_return(H_PTE_FRAG_NR - count, &page->_count);
 	if (!count) {
 		pgtable_page_dtor(page);
 		free_hot_cold_page(page, 0);
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index e4b01ee7703c..4813a3c2d457 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -21,49 +21,49 @@
 
 #include "mmu_decl.h"
 
-#if PGTABLE_RANGE > USER_VSID_RANGE
+#if H_PGTABLE_RANGE > USER_VSID_RANGE
 #warning Limited user VSID range means pagetable space is wasted
 #endif
 
-#if (TASK_SIZE_USER64 < PGTABLE_RANGE) && (TASK_SIZE_USER64 < USER_VSID_RANGE)
+#if (TASK_SIZE_USER64 < H_PGTABLE_RANGE) && (TASK_SIZE_USER64 < USER_VSID_RANGE)
 #warning TASK_SIZE is smaller than it needs to be.
 #endif
 
-#if (TASK_SIZE_USER64 > PGTABLE_RANGE)
+#if (TASK_SIZE_USER64 > H_PGTABLE_RANGE)
 #warning TASK_SIZE is larger than page table range
 #endif
 
 static void pgd_ctor(void *addr)
 {
-	memset(addr, 0, PGD_TABLE_SIZE);
+	memset(addr, 0, H_PGD_TABLE_SIZE);
 }
 
 static void pud_ctor(void *addr)
 {
-	memset(addr, 0, PUD_TABLE_SIZE);
+	memset(addr, 0, H_PUD_TABLE_SIZE);
 }
 
 static void pmd_ctor(void *addr)
 {
-	memset(addr, 0, PMD_TABLE_SIZE);
+	memset(addr, 0, H_PMD_TABLE_SIZE);
 }
 
 
 void pgtable_cache_init(void)
 {
-	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
-	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
+	pgtable_cache_add(H_PGD_INDEX_SIZE, pgd_ctor);
+	pgtable_cache_add(H_PMD_CACHE_INDEX, pmd_ctor);
 	/*
 	 * In all current configs, when the PUD index exists it's the
 	 * same size as either the pgd or pmd index except with THP enabled
 	 * on book3s 64
 	 */
-	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
-		pgtable_cache_add(PUD_INDEX_SIZE, pud_ctor);
+	if (H_PUD_INDEX_SIZE && !PGT_CACHE(H_PUD_INDEX_SIZE))
+		pgtable_cache_add(H_PUD_INDEX_SIZE, pud_ctor);
 
-	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
+	if (!PGT_CACHE(H_PGD_INDEX_SIZE) || !PGT_CACHE(H_PMD_CACHE_INDEX))
 		panic("Couldn't allocate pgtable caches");
-	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+	if (H_PUD_INDEX_SIZE && !PGT_CACHE(H_PUD_INDEX_SIZE))
 		panic("Couldn't allocate pud pgtable caches");
 }
 
@@ -77,7 +77,7 @@ void __meminit vmemmap_create_mapping(unsigned long start,
 				      unsigned long phys)
 {
 	int  mapped = htab_bolt_mapping(start, start + page_size, phys,
-					pgprot_val(PAGE_KERNEL),
+					pgprot_val(H_PAGE_KERNEL),
 					mmu_vmemmap_psize,
 					mmu_kernel_ssize);
 	BUG_ON(mapped < 0);
@@ -119,7 +119,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 		return;
 	trap = TRAP(current->thread.regs);
 	if (trap == 0x400)
-		access |= _PAGE_EXEC;
+		access |= H_PAGE_EXEC;
 	else if (trap != 0x300)
 		return;
 	hash_preload(vma->vm_mm, address, access, trap);
@@ -177,9 +177,9 @@ int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
  */
 static inline int pte_looks_normal(pte_t pte)
 {
-	return (pte_val(pte) &
-	    (_PAGE_PRESENT | _PAGE_SPECIAL | _PAGE_NO_CACHE | _PAGE_USER)) ==
-	    (_PAGE_PRESENT | _PAGE_USER);
+	return (pte_val(pte) & (H_PAGE_PRESENT | H_PAGE_SPECIAL |
+					H_PAGE_NO_CACHE | H_PAGE_USER)) ==
+		(H_PAGE_PRESENT | H_PAGE_USER);
 }
 
 static struct page *maybe_pte_to_page(pte_t pte)
@@ -202,7 +202,7 @@ static struct page *maybe_pte_to_page(pte_t pte)
  */
 static pte_t set_pte_filter(pte_t pte)
 {
-	pte = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
+	pte = __pte(pte_val(pte) & ~H_PAGE_HPTEFLAGS);
 	if (pte_looks_normal(pte) && !(cpu_has_feature(CPU_FTR_COHERENT_ICACHE) ||
 				       cpu_has_feature(CPU_FTR_NOEXECUTE))) {
 		struct page *pg = maybe_pte_to_page(pte);
@@ -228,13 +228,13 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
 	 * Hence we can use set_pte_at for them.
 	 */
-	VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
-		(_PAGE_PRESENT | _PAGE_USER));
+	VM_WARN_ON((pte_val(*ptep) & (H_PAGE_PRESENT | H_PAGE_USER)) ==
+		   (H_PAGE_PRESENT | H_PAGE_USER));
 
 	/*
 	 * Add the pte bit when tryint set a pte
 	 */
-	pte = __pte(pte_val(pte) | _PAGE_PTE);
+	pte = __pte(pte_val(pte) | H_PAGE_PTE);
 
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 5cf3b75fb847..8d203f1b1162 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -64,7 +64,59 @@
 #endif
 #endif
 
-unsigned long ioremap_bot = IOREMAP_BASE;
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * There are #defines that get defined in pgtable-book3s-64.h and are used
+ * by code outside ppc64 core mm code. We try to strike a balance between
+ * conditional code that switch between two different constants or a variable
+ * for as below.
+ */
+pgprot_t __kernel_page_prot;
+EXPORT_SYMBOL(__kernel_page_prot);
+pgprot_t __page_none;
+EXPORT_SYMBOL(__page_none);
+pgprot_t __page_kernel_exec;
+EXPORT_SYMBOL(__page_kernel_exec);
+unsigned long __page_no_cache;
+EXPORT_SYMBOL(__page_no_cache);
+unsigned long __page_guarded;
+EXPORT_SYMBOL(__page_guarded);
+unsigned long __page_user;
+EXPORT_SYMBOL(__page_user);
+unsigned long __page_coherent;
+EXPORT_SYMBOL(__page_coherent);
+unsigned long __page_present;
+EXPORT_SYMBOL(__page_present);
+unsigned long __page_rw;
+EXPORT_SYMBOL(__page_rw);
+unsigned long __page_dirty;
+EXPORT_SYMBOL(__page_dirty);
+unsigned long __page_exec;
+EXPORT_SYMBOL(__page_exec);
+
+/* kernel constants */
+unsigned long __ptrs_per_pte;
+EXPORT_SYMBOL(__ptrs_per_pte);
+unsigned long __ptrs_per_pmd;
+EXPORT_SYMBOL(__ptrs_per_pmd);
+unsigned long __pmd_shift;
+EXPORT_SYMBOL(__pmd_shift);
+unsigned long __pud_shift;
+EXPORT_SYMBOL(__pud_shift);
+unsigned long __pgdir_shift;
+EXPORT_SYMBOL(__pgdir_shift);
+unsigned long __kernel_virt_start;
+EXPORT_SYMBOL(__kernel_virt_start);
+unsigned long __kernel_virt_size;
+EXPORT_SYMBOL(__kernel_virt_size);
+unsigned long __vmalloc_start;
+EXPORT_SYMBOL(__vmalloc_start);
+unsigned long __vmalloc_end;
+EXPORT_SYMBOL(__vmalloc_end);
+struct page *vmemmap;
+EXPORT_SYMBOL(vmemmap);
+#endif
+unsigned long ioremap_bot;
 
 /**
  * __ioremap_at - Low level function to establish the page tables
@@ -84,7 +136,7 @@ void __iomem * __ioremap_at(phys_addr_t pa, void *ea, unsigned long size,
 		flags &= ~_PAGE_COHERENT;
 
 	/* We don't support the 4K PFN hack with ioremap */
-	if (flags & _PAGE_4K_PFN)
+	if (flags & H_PAGE_4K_PFN)
 		return NULL;
 
 	WARN_ON(pa & ~PAGE_MASK);
@@ -283,7 +335,7 @@ static pte_t *get_from_cache(struct mm_struct *mm)
 	spin_lock(&mm->page_table_lock);
 	ret = mm->context.pte_frag;
 	if (ret) {
-		pte_frag = ret + PTE_FRAG_SIZE;
+		pte_frag = ret + H_PTE_FRAG_SIZE;
 		/*
 		 * If we have taken up all the fragments mark PTE page NULL
 		 */
@@ -315,8 +367,8 @@ static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
 	 * count.
 	 */
 	if (likely(!mm->context.pte_frag)) {
-		atomic_set(&page->_count, PTE_FRAG_NR);
-		mm->context.pte_frag = ret + PTE_FRAG_SIZE;
+		atomic_set(&page->_count, H_PTE_FRAG_NR);
+		mm->context.pte_frag = ret + H_PTE_FRAG_SIZE;
 	}
 	spin_unlock(&mm->page_table_lock);
 
@@ -444,14 +496,14 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 		stdcx.	%1,0,%3 \n\
 		bne-	1b"
 	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
-	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (_PAGE_BUSY), "r" (set)
+	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (H_PAGE_BUSY), "r" (set)
 	: "cc" );
 #else
 	old = pmd_val(*pmdp);
 	*pmdp = __pmd((old & ~clr) | set);
 #endif
 	trace_hugepage_update(addr, old, clr, set);
-	if (old & _PAGE_HASHPTE)
+	if (old & H_PAGE_HASHPTE)
 		hpte_do_hugepage_flush(mm, addr, pmdp, old);
 	return old;
 }
@@ -527,7 +579,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 	/*
 	 * we store the pgtable in the second half of PMD
 	 */
-	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
 	*pgtable_slot = pgtable;
 	/*
 	 * expose the deposited pgtable to other cpus.
@@ -544,7 +596,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	pgtable_t *pgtable_slot;
 
 	assert_spin_locked(&mm->page_table_lock);
-	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
 	pgtable = *pgtable_slot;
 	/*
 	 * Once we withdraw, mark the entry NULL.
@@ -554,7 +606,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	 * We store HPTE information in the deposited PTE fragment.
 	 * zero out the content on withdraw.
 	 */
-	memset(pgtable, 0, PTE_FRAG_SIZE);
+	memset(pgtable, 0, H_PTE_FRAG_SIZE);
 	return pgtable;
 }
 
@@ -564,7 +616,7 @@ void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 #ifdef CONFIG_DEBUG_VM
-	BUG_ON(REGION_ID(address) != USER_REGION_ID);
+	BUG_ON(REGION_ID(address) != H_USER_REGION_ID);
 #endif
 	/*
 	 * We can't mark the pmd none here, because that will cause a race
@@ -578,7 +630,7 @@ void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
 	 * the translation is still valid, because we will withdraw
 	 * pgtable_t after this.
 	 */
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_USER, 0);
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, H_PAGE_USER, 0);
 }
 
 
@@ -590,8 +642,8 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 		pmd_t *pmdp, pmd_t pmd)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON((pmd_val(*pmdp) & (_PAGE_PRESENT | _PAGE_USER)) ==
-		(_PAGE_PRESENT | _PAGE_USER));
+	WARN_ON((pmd_val(*pmdp) & (H_PAGE_PRESENT | H_PAGE_USER)) ==
+		(H_PAGE_PRESENT | H_PAGE_USER));
 	assert_spin_locked(&mm->page_table_lock);
 	WARN_ON(!pmd_trans_huge(pmd));
 #endif
@@ -632,7 +684,7 @@ void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
 	psize = get_slice_psize(mm, addr);
 	BUG_ON(psize == MMU_PAGE_16M);
 #endif
-	if (old_pmd & _PAGE_COMBO)
+	if (old_pmd & H_PAGE_COMBO)
 		psize = MMU_PAGE_4K;
 	else
 		psize = MMU_PAGE_64K;
@@ -662,7 +714,7 @@ pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
 {
 	unsigned long pmdv;
 
-	pmdv = pfn << PTE_RPN_SHIFT;
+	pmdv = pfn << H_PTE_RPN_SHIFT;
 	return pmd_set_protbits(__pmd(pmdv), pgprot);
 }
 
@@ -676,7 +728,7 @@ pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	unsigned long pmdv;
 
 	pmdv = pmd_val(pmd);
-	pmdv &= _HPAGE_CHG_MASK;
+	pmdv &= H_HPAGE_CHG_MASK;
 	return pmd_set_protbits(__pmd(pmdv), newprot);
 }
 
@@ -707,13 +759,13 @@ pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	 * So we can safely go and clear the pgtable hash
 	 * index info.
 	 */
-	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
 	pgtable = *pgtable_slot;
 	/*
 	 * Let's zero out old valid and hash index details
 	 * hash fault look at them.
 	 */
-	memset(pgtable, 0, PTE_FRAG_SIZE);
+	memset(pgtable, 0, H_PTE_FRAG_SIZE);
 	/*
 	 * Serialize against find_linux_pte_or_hugepte which does lock-less
 	 * lookup in page tables with local interrupts disabled. For huge pages
@@ -731,10 +783,10 @@ pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 int has_transparent_hugepage(void)
 {
 
-	BUILD_BUG_ON_MSG((PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
+	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
 		"hugepages can't be allocated by the buddy allocator");
 
-	BUILD_BUG_ON_MSG((PMD_SHIFT - PAGE_SHIFT) < 2,
+	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) < 2,
 			 "We need more than 2 pages to do deferred thp split");
 
 	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
@@ -742,7 +794,7 @@ int has_transparent_hugepage(void)
 	/*
 	 * We support THP only if PMD_SIZE is 16MB.
 	 */
-	if (mmu_psize_defs[MMU_PAGE_16M].shift != PMD_SHIFT)
+	if (mmu_psize_defs[MMU_PAGE_16M].shift != H_PMD_SHIFT)
 		return 0;
 	/*
 	 * We need to make sure that we support 16MB hugepage in a segement
diff --git a/arch/powerpc/mm/slb.c b/arch/powerpc/mm/slb.c
index 825b6873391f..24af734fcbd7 100644
--- a/arch/powerpc/mm/slb.c
+++ b/arch/powerpc/mm/slb.c
@@ -129,8 +129,8 @@ static void __slb_flush_and_rebolt(void)
 		     /* Slot 2 - kernel stack */
 		     "slbmte	%2,%3\n"
 		     "isync"
-		     :: "r"(mk_vsid_data(VMALLOC_START, mmu_kernel_ssize, vflags)),
-		        "r"(mk_esid_data(VMALLOC_START, mmu_kernel_ssize, 1)),
+		     :: "r"(mk_vsid_data(H_VMALLOC_START, mmu_kernel_ssize, vflags)),
+		        "r"(mk_esid_data(H_VMALLOC_START, mmu_kernel_ssize, 1)),
 		        "r"(ksp_vsid_data),
 		        "r"(ksp_esid_data)
 		     : "memory");
@@ -156,7 +156,7 @@ void slb_vmalloc_update(void)
 	unsigned long vflags;
 
 	vflags = SLB_VSID_KERNEL | mmu_psize_defs[mmu_vmalloc_psize].sllp;
-	slb_shadow_update(VMALLOC_START, mmu_kernel_ssize, vflags, VMALLOC_INDEX);
+	slb_shadow_update(H_VMALLOC_START, mmu_kernel_ssize, vflags, VMALLOC_INDEX);
 	slb_flush_and_rebolt();
 }
 
@@ -332,7 +332,7 @@ void slb_initialize(void)
 	asm volatile("slbmte  %0,%0"::"r" (0) : "memory");
 	asm volatile("isync; slbia; isync":::"memory");
 	create_shadowed_slbe(PAGE_OFFSET, mmu_kernel_ssize, lflags, LINEAR_INDEX);
-	create_shadowed_slbe(VMALLOC_START, mmu_kernel_ssize, vflags, VMALLOC_INDEX);
+	create_shadowed_slbe(H_VMALLOC_START, mmu_kernel_ssize, vflags, VMALLOC_INDEX);
 
 	/* For the boot cpu, we're running on the stack in init_thread_union,
 	 * which is in the first segment of the linear mapping, and also
diff --git a/arch/powerpc/mm/slb_low.S b/arch/powerpc/mm/slb_low.S
index 736d18b3cefd..5d840b249fd4 100644
--- a/arch/powerpc/mm/slb_low.S
+++ b/arch/powerpc/mm/slb_low.S
@@ -35,7 +35,7 @@ _GLOBAL(slb_allocate_realmode)
 	 * check for bad kernel/user address
 	 * (ea & ~REGION_MASK) >= PGTABLE_RANGE
 	 */
-	rldicr. r9,r3,4,(63 - PGTABLE_EADDR_SIZE - 4)
+	rldicr. r9,r3,4,(63 - H_PGTABLE_EADDR_SIZE - 4)
 	bne-	8f
 
 	srdi	r9,r3,60		/* get region */
@@ -91,7 +91,7 @@ slb_miss_kernel_load_vmemmap:
 	 * can be demoted from 64K -> 4K dynamically on some machines
 	 */
 	clrldi	r11,r10,48
-	cmpldi	r11,(VMALLOC_SIZE >> 28) - 1
+	cmpldi	r11,(H_VMALLOC_SIZE >> 28) - 1
 	bgt	5f
 	lhz	r11,PACAVMALLOCSLLP(r13)
 	b	6f
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 42954f0b47ac..48a69e888b6a 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -37,7 +37,7 @@
 #include <asm/hugetlb.h>
 
 /* some sanity checks */
-#if (PGTABLE_RANGE >> 43) > SLICE_MASK_SIZE
+#if (H_PGTABLE_RANGE >> 43) > SLICE_MASK_SIZE
 #error PGTABLE_RANGE exceeds slice_mask high_slices size
 #endif
 
diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
index f7b80391bee7..98a85e426255 100644
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
@@ -218,7 +218,7 @@ void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 		pte = pte_val(*ptep);
 		if (is_thp)
 			trace_hugepage_invalidate(start, pte);
-		if (!(pte & _PAGE_HASHPTE))
+		if (!(pte & H_PAGE_HASHPTE))
 			continue;
 		if (unlikely(is_thp))
 			hpte_do_hugepage_flush(mm, start, (pmd_t *)ptep, pte);
@@ -235,7 +235,7 @@ void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd, unsigned long addr)
 	pte_t *start_pte;
 	unsigned long flags;
 
-	addr = _ALIGN_DOWN(addr, PMD_SIZE);
+	addr = _ALIGN_DOWN(addr, H_PMD_SIZE);
 	/* Note: Normally, we should only ever use a batch within a
 	 * PTE locked section. This violates the rule, but will work
 	 * since we don't actually modify the PTEs, we just flush the
@@ -246,9 +246,9 @@ void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd, unsigned long addr)
 	local_irq_save(flags);
 	arch_enter_lazy_mmu_mode();
 	start_pte = pte_offset_map(pmd, addr);
-	for (pte = start_pte; pte < start_pte + PTRS_PER_PTE; pte++) {
+	for (pte = start_pte; pte < start_pte + H_PTRS_PER_PTE; pte++) {
 		unsigned long pteval = pte_val(*pte);
-		if (pteval & _PAGE_HASHPTE)
+		if (pteval & H_PAGE_HASHPTE)
 			hpte_need_flush(mm, addr, pte, pteval, 0);
 		addr += PAGE_SIZE;
 	}
diff --git a/arch/powerpc/platforms/cell/spu_base.c b/arch/powerpc/platforms/cell/spu_base.c
index f7af74f83693..bc63c8a563dc 100644
--- a/arch/powerpc/platforms/cell/spu_base.c
+++ b/arch/powerpc/platforms/cell/spu_base.c
@@ -194,10 +194,10 @@ static int __spu_trap_data_map(struct spu *spu, unsigned long ea, u64 dsisr)
 	 * faults need to be deferred to process context.
 	 */
 	if ((dsisr & MFC_DSISR_PTE_NOT_FOUND) &&
-	    (REGION_ID(ea) != USER_REGION_ID)) {
+	    (REGION_ID(ea) != H_USER_REGION_ID)) {
 
 		spin_unlock(&spu->register_lock);
-		ret = hash_page(ea, _PAGE_PRESENT, 0x300, dsisr);
+		ret = hash_page(ea, H_PAGE_PRESENT, 0x300, dsisr);
 		spin_lock(&spu->register_lock);
 
 		if (!ret) {
@@ -222,7 +222,7 @@ static void __spu_kernel_slb(void *addr, struct copro_slb *slb)
 	unsigned long ea = (unsigned long)addr;
 	u64 llp;
 
-	if (REGION_ID(ea) == KERNEL_REGION_ID)
+	if (REGION_ID(ea) == H_KERNEL_REGION_ID)
 		llp = mmu_psize_defs[mmu_linear_psize].sllp;
 	else
 		llp = mmu_psize_defs[mmu_virtual_psize].sllp;
diff --git a/arch/powerpc/platforms/cell/spufs/fault.c b/arch/powerpc/platforms/cell/spufs/fault.c
index d98f845ac777..15f59ebe6ff3 100644
--- a/arch/powerpc/platforms/cell/spufs/fault.c
+++ b/arch/powerpc/platforms/cell/spufs/fault.c
@@ -141,8 +141,8 @@ int spufs_handle_class1(struct spu_context *ctx)
 	/* we must not hold the lock when entering copro_handle_mm_fault */
 	spu_release(ctx);
 
-	access = (_PAGE_PRESENT | _PAGE_USER);
-	access |= (dsisr & MFC_DSISR_ACCESS_PUT) ? _PAGE_RW : 0UL;
+	access = (H_PAGE_PRESENT | H_PAGE_USER);
+	access |= (dsisr & MFC_DSISR_ACCESS_PUT) ? H_PAGE_RW : 0UL;
 	local_irq_save(flags);
 	ret = hash_page(ea, access, 0x300, dsisr);
 	local_irq_restore(flags);
diff --git a/arch/powerpc/platforms/ps3/spu.c b/arch/powerpc/platforms/ps3/spu.c
index a0bca05e26b0..33dd82ec3c52 100644
--- a/arch/powerpc/platforms/ps3/spu.c
+++ b/arch/powerpc/platforms/ps3/spu.c
@@ -205,7 +205,7 @@ static void spu_unmap(struct spu *spu)
 static int __init setup_areas(struct spu *spu)
 {
 	struct table {char* name; unsigned long addr; unsigned long size;};
-	static const unsigned long shadow_flags = _PAGE_NO_CACHE | 3;
+	static const unsigned long shadow_flags = H_PAGE_NO_CACHE | 3;
 
 	spu_pdata(spu)->shadow = __ioremap(spu_pdata(spu)->shadow_addr,
 					   sizeof(struct spe_shadow),
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 477290ad855e..b543652bda81 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -153,7 +153,7 @@ static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 	flags = 0;
 
 	/* Make pHyp happy */
-	if ((rflags & _PAGE_NO_CACHE) && !(rflags & _PAGE_WRITETHRU))
+	if ((rflags & H_PAGE_NO_CACHE) && !(rflags & H_PAGE_WRITETHRU))
 		hpte_r &= ~HPTE_R_M;
 
 	if (firmware_has_feature(FW_FEATURE_XCMO) && !(hpte_r & HPTE_R_N))
@@ -459,7 +459,7 @@ static void pSeries_lpar_hugepage_invalidate(unsigned long vsid,
 	unsigned long shift, hidx, vpn = 0, hash, slot;
 
 	shift = mmu_psize_defs[psize].shift;
-	max_hpte_count = 1U << (PMD_SHIFT - shift);
+	max_hpte_count = 1U << (H_PMD_SHIFT - shift);
 
 	for (i = 0; i < max_hpte_count; i++) {
 		valid = hpte_valid(hpte_slot_array, i);
@@ -471,11 +471,11 @@ static void pSeries_lpar_hugepage_invalidate(unsigned long vsid,
 		addr = s_addr + (i * (1ul << shift));
 		vpn = hpt_vpn(addr, vsid, ssize);
 		hash = hpt_hash(vpn, shift, ssize);
-		if (hidx & _PTEIDX_SECONDARY)
+		if (hidx & H_PTEIDX_SECONDARY)
 			hash = ~hash;
 
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		slot += hidx & H_PTEIDX_GROUP_IX;
 
 		slot_array[index] = slot;
 		vpn_array[index] = vpn;
@@ -550,10 +550,10 @@ static void pSeries_lpar_flush_hash_range(unsigned long number, int local)
 		pte_iterate_hashed_subpages(pte, psize, vpn, index, shift) {
 			hash = hpt_hash(vpn, shift, ssize);
 			hidx = __rpte_to_hidx(pte, index);
-			if (hidx & _PTEIDX_SECONDARY)
+			if (hidx & H_PTEIDX_SECONDARY)
 				hash = ~hash;
 			slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-			slot += hidx & _PTEIDX_GROUP_IX;
+			slot += hidx & H_PTEIDX_GROUP_IX;
 			if (!firmware_has_feature(FW_FEATURE_BULK_REMOVE)) {
 				/*
 				 * lpar doesn't use the passed actual page size
diff --git a/drivers/char/agp/uninorth-agp.c b/drivers/char/agp/uninorth-agp.c
index 05755441250c..f4344c14bbed 100644
--- a/drivers/char/agp/uninorth-agp.c
+++ b/drivers/char/agp/uninorth-agp.c
@@ -419,7 +419,14 @@ static int uninorth_create_gatt_table(struct agp_bridge_data *bridge)
 	/* Need to clear out any dirty data still sitting in caches */
 	flush_dcache_range((unsigned long)table,
 			   (unsigned long)table_end + 1);
-	bridge->gatt_table = vmap(uninorth_priv.pages_arr, (1 << page_order), 0, PAGE_KERNEL_NCG);
+#ifdef CONFIG_PPC_BOOK3S_64
+	bridge->gatt_table = vmap(uninorth_priv.pages_arr,
+				  (1 << page_order), 0, H_PAGE_KERNEL_NCG);
+#else
+	bridge->gatt_table = vmap(uninorth_priv.pages_arr,
+				  (1 << page_order), 0, PAGE_KERNEL_NCG);
+#endif
+
 
 	if (bridge->gatt_table == NULL)
 		goto enomem;
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index 81c3f75b7330..7e94ab70605b 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -149,11 +149,11 @@ static void cxl_handle_page_fault(struct cxl_context *ctx,
 	 * update_mmu_cache() will not have loaded the hash since current->trap
 	 * is not a 0x400 or 0x300, so just call hash_page_mm() here.
 	 */
-	access = _PAGE_PRESENT;
+	access = H_PAGE_PRESENT;
 	if (dsisr & CXL_PSL_DSISR_An_S)
-		access |= _PAGE_RW;
+		access |= H_PAGE_RW;
 	if ((!ctx->kernel) || ~(dar & (1ULL << 63)))
-		access |= _PAGE_USER;
+		access |= H_PAGE_USER;
 
 	if (dsisr & DSISR_NOHPTE)
 		inv_flags |= HPTE_NOHPTE_UPDATE;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
