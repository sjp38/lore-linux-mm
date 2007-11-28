Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAS422x5006646
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 23:02:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAS53HE7054886
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 22:03:17 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAS53HnX017917
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 22:03:17 -0700
Message-ID: <474CF694.8040700@us.ibm.com>
Date: Tue, 27 Nov 2007 23:03:16 -0600
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 2/2] powerpc: make 64K huge pages more reliable
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch adds reliability to the 64K huge page option by making use of 
the PMD for 64K huge pages when base pages are 4k.  So instead of a 12 
bit pte it would be 7 bit pmd and a 5 bit pte. The pgd and pud offsets 
would continue as 9 bits and 7 bits respectively.  This will allow the 
pgtable to fit in one base page.  This patch would have to be applied 
after part 1.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 hugetlbpage.c |   53 ++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index f4632ad..c6df45b 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -30,15 +30,11 @@
 #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
 #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
 
-#ifdef CONFIG_PPC_64K_PAGES
-#define HUGEPTE_INDEX_SIZE	(PMD_SHIFT-HPAGE_SHIFT)
-#else
-#define HUGEPTE_INDEX_SIZE	(PUD_SHIFT-HPAGE_SHIFT)
-#endif
-#define PTRS_PER_HUGEPTE	(1 << HUGEPTE_INDEX_SIZE)
-#define HUGEPTE_TABLE_SIZE	(sizeof(pte_t) << HUGEPTE_INDEX_SIZE)
+unsigned int hugepte_shift;
+#define PTRS_PER_HUGEPTE	(1 << hugepte_shift)
+#define HUGEPTE_TABLE_SIZE	(sizeof(pte_t) << hugepte_shift)
 
-#define HUGEPD_SHIFT		(HPAGE_SHIFT + HUGEPTE_INDEX_SIZE)
+#define HUGEPD_SHIFT		(HPAGE_SHIFT + hugepte_shift)
 #define HUGEPD_SIZE		(1UL << HUGEPD_SHIFT)
 #define HUGEPD_MASK		(~(HUGEPD_SIZE-1))
 
@@ -105,7 +101,14 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 			if (!pmd_none(*pm))
 				return hugepte_offset((hugepd_t *)pm, addr);
 #else
-			return hugepte_offset((hugepd_t *)pu, addr);
+			if (HPAGE_SHIFT == HPAGE_SHIFT_64K) {
+				pmd_t *pm;
+				pm = pmd_offset(pu, addr);
+				if (!pmd_none(*pm))
+					return hugepte_offset((hugepd_t *)pm, addr);
+			} else {
+				return hugepte_offset((hugepd_t *)pu, addr);
+			}
 #endif
 		}
 	}
@@ -133,7 +136,14 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 		if (pm)
 			hpdp = (hugepd_t *)pm;
 #else
-		hpdp = (hugepd_t *)pu;
+		if (HPAGE_SHIFT == HPAGE_SHIFT_64K) {
+			pmd_t *pm;
+			pm = pmd_alloc(mm, pu, addr);
+			if (pm)
+				hpdp = (hugepd_t *)pm;
+		} else {
+			hpdp = (hugepd_t *)pu;
+		}
 #endif
 	}
 
@@ -161,7 +171,6 @@ static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp)
 						 PGF_CACHENUM_MASK));
 }
 
-#ifdef CONFIG_PPC_64K_PAGES
 static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 				   unsigned long addr, unsigned long end,
 				   unsigned long floor, unsigned long ceiling)
@@ -194,7 +203,6 @@ static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	pud_clear(pud);
 	pmd_free_tlb(tlb, pmd);
 }
-#endif
 
 static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 				   unsigned long addr, unsigned long end,
@@ -213,9 +221,15 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 			continue;
 		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
 #else
-		if (pud_none(*pud))
-			continue;
-		free_hugepte_range(tlb, (hugepd_t *)pud);
+		if (HPAGE_SHIFT == HPAGE_SHIFT_64K) {
+			if (pud_none_or_clear_bad(pud))
+				continue;
+			hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+		} else {
+			if (pud_none(*pud))
+				continue;
+			free_hugepte_range(tlb, (hugepd_t *)pud);
+		}
 #endif
 	} while (pud++, addr = next, addr != end);
 
@@ -538,6 +552,15 @@ void set_huge_psize(int psize)
 			mmu_psize_defs[psize].shift == HPAGE_SHIFT_64K)) {
 		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
 		mmu_huge_psize = psize;
+#ifdef CONFIG_PPC_64K_PAGES
+		hugepte_shift = (PMD_SHIFT-HPAGE_SHIFT);
+#else
+		if (HPAGE_SHIFT == HPAGE_SHIFT_64K)
+			hugepte_shift = (PMD_SHIFT-HPAGE_SHIFT);
+		else
+			hugepte_shift = (PUD_SHIFT-HPAGE_SHIFT);
+#endif
+
 	} else
 		HPAGE_SHIFT = 0;
 }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
