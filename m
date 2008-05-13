Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4DHK2bW013250
	for <linux-mm@kvack.org>; Tue, 13 May 2008 13:20:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DHNCe2169692
	for <linux-mm@kvack.org>; Tue, 13 May 2008 11:23:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DHNB4c025613
	for <linux-mm@kvack.org>; Tue, 13 May 2008 11:23:12 -0600
Message-ID: <4829CE81.2040908@us.ibm.com>
Date: Tue, 13 May 2008 12:23:13 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 4/6 v2] powerpc: define page support for 16G pages
References: <4829CAC3.30900@us.ibm.com>
In-Reply-To: <4829CAC3.30900@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Paul Mackerras <paulus@samba.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The huge page size is defined for 16G pages.  If a hugepagesz of 16G is
specified at boot-time then it becomes the huge page size instead of
the default 16M.

The change in pgtable-64K.h is to the macro
pte_iterate_hashed_subpages to make the increment to va (the 1
being shifted) be a long so that it is not shifted to 0.  Otherwise it
would create an infinite loop when the shift value is for a 16G page
(when base page size is 64K).



Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 arch/powerpc/mm/hugetlbpage.c     |   62 ++++++++++++++++++++++++++------------
 include/asm-powerpc/pgtable-64k.h |    2 -
 2 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a27b80c..063ec36 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -24,8 +24,9 @@
 #include <asm/cputable.h>
 #include <asm/spu.h>
 
-#define HPAGE_SHIFT_64K	16
-#define HPAGE_SHIFT_16M	24
+#define PAGE_SHIFT_64K	16
+#define PAGE_SHIFT_16M	24
+#define PAGE_SHIFT_16G	34
 
 #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
 #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
@@ -95,7 +96,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 static inline
 pmd_t *hpmd_offset(pud_t *pud, unsigned long addr)
 {
-	if (HPAGE_SHIFT == HPAGE_SHIFT_64K)
+	if (HPAGE_SHIFT == PAGE_SHIFT_64K)
 		return pmd_offset(pud, addr);
 	else
 		return (pmd_t *) pud;
@@ -103,7 +104,7 @@ pmd_t *hpmd_offset(pud_t *pud, unsigned long addr)
 static inline
 pmd_t *hpmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long addr)
 {
-	if (HPAGE_SHIFT == HPAGE_SHIFT_64K)
+	if (HPAGE_SHIFT == PAGE_SHIFT_64K)
 		return pmd_alloc(mm, pud, addr);
 	else
 		return (pmd_t *) pud;
@@ -260,7 +261,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 			continue;
 		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
 #else
-		if (HPAGE_SHIFT == HPAGE_SHIFT_64K) {
+		if (HPAGE_SHIFT == PAGE_SHIFT_64K) {
 			if (pud_none_or_clear_bad(pud))
 				continue;
 			hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
@@ -591,20 +592,40 @@ void set_huge_psize(int psize)
 {
 	/* Check that it is a page size supported by the hardware and
 	 * that it fits within pagetable limits. */
-	if (mmu_psize_defs[psize].shift && mmu_psize_defs[psize].shift < SID_SHIFT &&
+	if (mmu_psize_defs[psize].shift &&
+		mmu_psize_defs[psize].shift < SID_SHIFT_1T &&
 		(mmu_psize_defs[psize].shift > MIN_HUGEPTE_SHIFT ||
-			mmu_psize_defs[psize].shift == HPAGE_SHIFT_64K)) {
+		 mmu_psize_defs[psize].shift == PAGE_SHIFT_64K ||
+		 mmu_psize_defs[psize].shift == PAGE_SHIFT_16G)) {
+		/* Return if huge page size is the same as the
+		 * base page size. */
+		if (mmu_psize_defs[psize].shift == PAGE_SHIFT)
+			return;
+
 		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
 		mmu_huge_psize = psize;
-#ifdef CONFIG_PPC_64K_PAGES
-		hugepte_shift = (PMD_SHIFT-HPAGE_SHIFT);
-#else
-		if (HPAGE_SHIFT == HPAGE_SHIFT_64K)
-			hugepte_shift = (PMD_SHIFT-HPAGE_SHIFT);
-		else
-			hugepte_shift = (PUD_SHIFT-HPAGE_SHIFT);
-#endif
 
+		switch (HPAGE_SHIFT) {
+		case PAGE_SHIFT_64K:
+		    /* We only allow 64k hpages with 4k base page,
+		     * which was checked above, and always put them
+		     * at the PMD */
+		    hugepte_shift = PMD_SHIFT;
+		    break;
+		case PAGE_SHIFT_16M:
+		    /* 16M pages can be at two different levels
+		     * of pagestables based on base page size */
+		    if (PAGE_SHIFT == PAGE_SHIFT_64K)
+			    hugepte_shift = PMD_SHIFT;
+		    else /* 4k base page */
+			    hugepte_shift = PUD_SHIFT;
+		    break;
+		case PAGE_SHIFT_16G:
+		    /* 16G pages are always at PGD level */
+		    hugepte_shift = PGDIR_SHIFT;
+		    break;
+		}
+		hugepte_shift -= HPAGE_SHIFT;
 	} else
 		HPAGE_SHIFT = 0;
 }
@@ -620,17 +641,22 @@ static int __init hugepage_setup_sz(char *str)
 	shift = __ffs(size);
 	switch (shift) {
 #ifndef CONFIG_PPC_64K_PAGES
-	case HPAGE_SHIFT_64K:
+	case PAGE_SHIFT_64K:
 		mmu_psize = MMU_PAGE_64K;
 		break;
 #endif
-	case HPAGE_SHIFT_16M:
+	case PAGE_SHIFT_16M:
 		mmu_psize = MMU_PAGE_16M;
 		break;
+	case PAGE_SHIFT_16G:
+		mmu_psize = MMU_PAGE_16G;
+		break;
 	}
 
-	if (mmu_psize >=0 && mmu_psize_defs[mmu_psize].shift)
+	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift) {
 		set_huge_psize(mmu_psize);
+		huge_add_hstate(shift - PAGE_SHIFT);
+	}
 	else
 		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n", size);
 
diff --git a/include/asm-powerpc/pgtable-64k.h b/include/asm-powerpc/pgtable-64k.h
index 1cbd6b3..55f0861 100644
--- a/include/asm-powerpc/pgtable-64k.h
+++ b/include/asm-powerpc/pgtable-64k.h
@@ -125,7 +125,7 @@ static inline struct subpage_prot_table *pgd_subpage_prot(pgd_t *pgd)
                 unsigned __split = (psize == MMU_PAGE_4K ||                 \
 				    psize == MMU_PAGE_64K_AP);              \
                 shift = mmu_psize_defs[psize].shift;                        \
-	        for (index = 0; va < __end; index++, va += (1 << shift)) {  \
+		for (index = 0; va < __end; index++, va += (1L << shift)) { \
 		        if (!__split || __rpte_sub_valid(rpte, index)) do { \
 
 #define pte_iterate_hashed_end() } while(0); } } while(0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
