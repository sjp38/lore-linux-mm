Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D80CA6B0070
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:26 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:25:21 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3BD693940059
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:28:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wIct38535220
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:18 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wIvA026866
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:20 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 18/25] powerpc/THP: Double the PMD table size for THP
Date: Thu,  4 Apr 2013 11:27:56 +0530
Message-Id: <1365055083-31956-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

THP code does PTE page allocation along with large page request and deposit them
for later use. This is to ensure that we won't have any failures when we split
hugepages to regular pages.

On powerpc we want to use the deposited PTE page for storing hash pte slot and
secondary bit information for the HPTEs. We use the second half
of the pmd table to save the deposted PTE page.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgalloc-64.h    |    6 +++---
 arch/powerpc/include/asm/pgtable-ppc64.h |    6 +++++-
 arch/powerpc/mm/init_64.c                |    9 ++++++---
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 3418989..46c6ffa 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -208,17 +208,17 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
-	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
+	kmem_cache_free(PGT_CACHE(PMD_CACHE_INDEX), pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
-	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
+	pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX)
 #ifndef CONFIG_PPC_64K_PAGES
 #define __pud_free_tlb(tlb, pud, addr)		      \
 	pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE)
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index c0747c7..d4e845c 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -20,7 +20,11 @@
                 	    PUD_INDEX_SIZE + PGD_INDEX_SIZE + PAGE_SHIFT)
 #define PGTABLE_RANGE (ASM_CONST(1) << PGTABLE_EADDR_SIZE)
 
-
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define PMD_CACHE_INDEX	(PMD_INDEX_SIZE + 1)
+#else
+#define PMD_CACHE_INDEX	PMD_INDEX_SIZE
+#endif
 /*
  * Define the address range of the kernel non-linear virtual area
  */
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 95a4529..7608b0d 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -88,7 +88,11 @@ static void pgd_ctor(void *addr)
 
 static void pmd_ctor(void *addr)
 {
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	memset(addr, 0, PMD_TABLE_SIZE * 2);
+#else
 	memset(addr, 0, PMD_TABLE_SIZE);
+#endif
 }
 
 struct kmem_cache *pgtable_cache[MAX_PGTABLE_INDEX_SIZE];
@@ -138,10 +142,9 @@ void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 void pgtable_cache_init(void)
 {
 	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
-	pgtable_cache_add(PMD_INDEX_SIZE, pmd_ctor);
-	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_INDEX_SIZE))
+	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
+	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
 		panic("Couldn't allocate pgtable caches");
-
 	/* In all current configs, when the PUD index exists it's the
 	 * same size as either the pgd or pmd index.  Verify that the
 	 * initialization above has also created a PUD cache.  This
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
