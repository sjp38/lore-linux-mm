Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 19EC06B005C
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:02:45 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A4BA31258051
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:09:25 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbdGb35651752
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:39 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbivW003121
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 08/18] powerpc: New hugepage directory format
Date: Mon, 29 Apr 2013 01:07:29 +0530
Message-Id: <1367177859-7893-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Change the hugepage directory format so that we can have leaf ptes directly
at page directory avoiding the allocation of hugepage directory.

With the new table format we have 3 cases for pgds and pmds:
(1) invalid (all zeroes)
(2) pointer to next table, as normal; bottom 6 bits == 0
(4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table

Instead of storing shift value in hugepd pointer we use mmu_psize_def index
so that we can fit all the supported hugepage size in 4 bits

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/hugetlb.h    | 30 ++++++++++++++++++++++++++++++
 arch/powerpc/include/asm/mmu-hash64.h | 20 +++++++++++++++++++-
 arch/powerpc/include/asm/page.h       | 13 +++++++++++++
 arch/powerpc/include/asm/pgalloc-64.h |  5 ++++-
 arch/powerpc/mm/hugetlbpage.c         | 26 ++++++++------------------
 arch/powerpc/mm/init_64.c             |  3 +--
 6 files changed, 75 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 62e11a3..4daf7e6 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -6,6 +6,33 @@
 
 extern struct kmem_cache *hugepte_cache;
 
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * This should work for other subarchs too. But right now we use the
+ * new format only for 64bit book3s
+ */
+static inline pte_t *hugepd_page(hugepd_t hpd)
+{
+	BUG_ON(!hugepd_ok(hpd));
+	/*
+	 * We have only four bits to encode, MMU page size
+	 */
+	BUILD_BUG_ON((MMU_PAGE_COUNT - 1) > 0xf);
+	return (pte_t *)(hpd.pd & ~HUGEPD_SHIFT_MASK);
+}
+
+static inline unsigned int hugepd_mmu_psize(hugepd_t hpd)
+{
+	return (hpd.pd & HUGEPD_SHIFT_MASK) >> 2;
+}
+
+static inline unsigned int hugepd_shift(hugepd_t hpd)
+{
+	return mmu_psize_to_shift(hugepd_mmu_psize(hpd));
+}
+
+#else
+
 static inline pte_t *hugepd_page(hugepd_t hpd)
 {
 	BUG_ON(!hugepd_ok(hpd));
@@ -17,6 +44,9 @@ static inline unsigned int hugepd_shift(hugepd_t hpd)
 	return hpd.pd & HUGEPD_SHIFT_MASK;
 }
 
+#endif /* CONFIG_PPC_BOOK3S_64 */
+
+
 static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
 				    unsigned pdshift)
 {
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index b59e06f..05895cf 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -21,6 +21,7 @@
  * complete pgtable.h but only a portion of it.
  */
 #include <asm/pgtable-ppc64.h>
+#include <asm/bug.h>
 
 /*
  * Segment table
@@ -159,6 +160,24 @@ struct mmu_psize_def
 	unsigned long	avpnm;	/* bits to mask out in AVPN in the HPTE */
 	unsigned long	sllp;	/* SLB L||LP (exact mask to use in slbmte) */
 };
+extern struct mmu_psize_def mmu_psize_defs[MMU_PAGE_COUNT];
+
+static inline int shift_to_mmu_psize(unsigned int shift)
+{
+	int psize;
+
+	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize)
+		if (mmu_psize_defs[psize].shift == shift)
+			return psize;
+	return -1;
+}
+
+static inline unsigned int mmu_psize_to_shift(unsigned int mmu_psize)
+{
+	if (mmu_psize_defs[mmu_psize].shift)
+		return mmu_psize_defs[mmu_psize].shift;
+	BUG();
+}
 
 #endif /* __ASSEMBLY__ */
 
@@ -193,7 +212,6 @@ static inline int segment_shift(int ssize)
 /*
  * The current system page and segment sizes
  */
-extern struct mmu_psize_def mmu_psize_defs[MMU_PAGE_COUNT];
 extern int mmu_linear_psize;
 extern int mmu_virtual_psize;
 extern int mmu_vmalloc_psize;
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index f072e97..652719c 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -249,6 +249,7 @@ extern long long virt_phys_offset;
 #define is_kernel_addr(x)	((x) >= PAGE_OFFSET)
 #endif
 
+#ifndef CONFIG_PPC_BOOK3S_64
 /*
  * Use the top bit of the higher-level page table entries to indicate whether
  * the entries we point to contain hugepages.  This works because we know that
@@ -260,6 +261,7 @@ extern long long virt_phys_offset;
 #else
 #define PD_HUGE 0x80000000
 #endif
+#endif /* CONFIG_PPC_BOOK3S_64 */
 
 /*
  * Some number of bits at the level of the page table that points to
@@ -354,10 +356,21 @@ typedef unsigned long pgprot_t;
 typedef struct { signed long pd; } hugepd_t;
 
 #ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_PPC_BOOK3S_64
+static inline int hugepd_ok(hugepd_t hpd)
+{
+	/*
+	 * hugepd pointer, bottom two bits == 00 and next 4 bits
+	 * indicate size of table
+	 */
+	return (((hpd.pd & 0x3) == 0x0) && ((hpd.pd & HUGEPD_SHIFT_MASK) != 0));
+}
+#else
 static inline int hugepd_ok(hugepd_t hpd)
 {
 	return (hpd.pd > 0);
 }
+#endif
 
 #define is_hugepd(pdep)               (hugepd_ok(*((hugepd_t *)(pdep))))
 #else /* CONFIG_HUGETLB_PAGE */
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..69e352a 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -35,7 +35,10 @@ struct vmemmap_backing {
 #define MAX_PGTABLE_INDEX_SIZE	0xf
 
 extern struct kmem_cache *pgtable_cache[];
-#define PGT_CACHE(shift) (pgtable_cache[(shift)-1])
+#define PGT_CACHE(shift) ({				\
+			BUG_ON(!(shift));		\
+			pgtable_cache[(shift) - 1];	\
+		})
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 1a6de0a..b5f4a5f 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -48,23 +48,6 @@ static u64 gpage_freearray[MAX_NUMBER_GPAGES];
 static unsigned nr_gpages;
 #endif
 
-static inline int shift_to_mmu_psize(unsigned int shift)
-{
-	int psize;
-
-	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize)
-		if (mmu_psize_defs[psize].shift == shift)
-			return psize;
-	return -1;
-}
-
-static inline unsigned int mmu_psize_to_shift(unsigned int mmu_psize)
-{
-	if (mmu_psize_defs[mmu_psize].shift)
-		return mmu_psize_defs[mmu_psize].shift;
-	BUG();
-}
-
 #define hugepd_none(hpd)	((hpd).pd == 0)
 
 pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift)
@@ -145,6 +128,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 		if (unlikely(!hugepd_none(*hpdp)))
 			break;
 		else
+			/* We use the old format for PPC_FSL_BOOK3E */
 			hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
 	}
 	/* If we bailed from the for loop early, an error occurred, clean up */
@@ -156,9 +140,15 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 #else
 	if (!hugepd_none(*hpdp))
 		kmem_cache_free(cachep, new);
-	else
+	else {
+#ifdef CONFIG_PPC_BOOK3S_64
+		hpdp->pd = (unsigned long)new |
+			    (shift_to_mmu_psize(pshift) << 2);
+#else
 		hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
 #endif
+	}
+#endif
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 7e2246f..a56de85 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -129,8 +129,7 @@ void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 	align = max_t(unsigned long, align, minalign);
 	name = kasprintf(GFP_KERNEL, "pgtable-2^%d", shift);
 	new = kmem_cache_create(name, table_size, align, 0, ctor);
-	PGT_CACHE(shift) = new;
-
+	pgtable_cache[shift - 1] = new;
 	pr_debug("Allocated pgtable cache for order %d\n", shift);
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
