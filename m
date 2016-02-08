Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 40269830E0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:22:10 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wb13so146232289obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:22:10 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id uv5si15264605obc.18.2016.02.08.01.22.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:22:07 -0800 (PST)
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:22:06 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 02BF619D8041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:47 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LmMr30212130
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:48 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LldS009752
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:48 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 26/29] powerpc/mm: Hash linux abstraction for HugeTLB
Date: Mon,  8 Feb 2016 14:50:38 +0530
Message-Id: <1454923241-6681-27-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h      | 10 ++++----
 arch/powerpc/include/asm/book3s/64/hash-64k.h     | 14 +++++------
 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h |  7 ++++++
 arch/powerpc/include/asm/book3s/64/pgalloc.h      |  9 +++++++
 arch/powerpc/include/asm/book3s/64/pgtable.h      | 30 +++++++++++++++++++++++
 arch/powerpc/include/asm/hugetlb.h                |  4 ---
 arch/powerpc/include/asm/nohash/pgalloc.h         |  7 ++++++
 arch/powerpc/mm/hugetlbpage-hash64.c              | 11 ++++-----
 arch/powerpc/mm/hugetlbpage.c                     | 16 ++++++++++++
 9 files changed, 86 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index 1ef4b39f96fd..5fc9e4e1db5f 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -66,23 +66,23 @@
 /*
  * For 4k page size, we support explicit hugepage via hugepd
  */
-static inline int pmd_huge(pmd_t pmd)
+static inline int hlpmd_huge(pmd_t pmd)
 {
 	return 0;
 }
 
-static inline int pud_huge(pud_t pud)
+static inline int hlpud_huge(pud_t pud)
 {
 	return 0;
 }
 
-static inline int pgd_huge(pgd_t pgd)
+static inline int hlpgd_huge(pgd_t pgd)
 {
 	return 0;
 }
 #define pgd_huge pgd_huge
 
-static inline int hugepd_ok(hugepd_t hpd)
+static inline int hlhugepd_ok(hugepd_t hpd)
 {
 	/*
 	 * if it is not a pte and have hugepd shift mask
@@ -93,7 +93,7 @@ static inline int hugepd_ok(hugepd_t hpd)
 		return true;
 	return false;
 }
-#define is_hugepd(hpd)		(hugepd_ok(hpd))
+#define is_hlhugepd(hpd)	(hlhugepd_ok(hpd))
 #endif
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index e697fc528c0a..4fff8b12ba0f 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -146,7 +146,7 @@ extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
  * Defined in such a way that we can optimize away code block at build time
  * if CONFIG_HUGETLB_PAGE=n.
  */
-static inline int pmd_huge(pmd_t pmd)
+static inline int hlpmd_huge(pmd_t pmd)
 {
 	/*
 	 * leaf pte for huge page
@@ -154,7 +154,7 @@ static inline int pmd_huge(pmd_t pmd)
 	return !!(pmd_val(pmd) & H_PAGE_PTE);
 }
 
-static inline int pud_huge(pud_t pud)
+static inline int hlpud_huge(pud_t pud)
 {
 	/*
 	 * leaf pte for huge page
@@ -162,7 +162,7 @@ static inline int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & H_PAGE_PTE);
 }
 
-static inline int pgd_huge(pgd_t pgd)
+static inline int hlpgd_huge(pgd_t pgd)
 {
 	/*
 	 * leaf pte for huge page
@@ -172,19 +172,19 @@ static inline int pgd_huge(pgd_t pgd)
 #define pgd_huge pgd_huge
 
 #ifdef CONFIG_DEBUG_VM
-extern int hugepd_ok(hugepd_t hpd);
-#define is_hugepd(hpd)               (hugepd_ok(hpd))
+extern int hlhugepd_ok(hugepd_t hpd);
+#define is_hlhugepd(hpd)               (hlhugepd_ok(hpd))
 #else
 /*
  * With 64k page size, we have hugepage ptes in the pgd and pmd entries. We don't
  * need to setup hugepage directory for them. Our pte and page directory format
  * enable us to have this enabled.
  */
-static inline int hugepd_ok(hugepd_t hpd)
+static inline int hlhugepd_ok(hugepd_t hpd)
 {
 	return 0;
 }
-#define is_hugepd(pdep)			0
+#define is_hlhugepd(pdep)			0
 #endif /* CONFIG_DEBUG_VM */
 
 #endif /* CONFIG_HUGETLB_PAGE */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
index dbf680970c12..1dcfe7b75f06 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
@@ -56,4 +56,11 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 {
 	pgtable_free_tlb(tlb, pud, H_PUD_INDEX_SIZE);
 }
+
+extern pte_t *huge_hlpte_alloc(struct mm_struct *mm, unsigned long addr,
+			       unsigned long sz);
+extern void hugetlb_free_hlpgd_range(struct mmu_gather *tlb, unsigned long addr,
+				     unsigned long end, unsigned long floor,
+				     unsigned long ceiling);
+
 #endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index ff3c0e36fe3d..fa2ddda14b3d 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -66,4 +66,13 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 #include <asm/book3s/64/pgalloc-hash.h>
 #endif
 
+#ifdef CONFIG_HUGETLB_PAGE
+static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
+					  unsigned long end, unsigned long floor,
+					  unsigned long ceiling)
+{
+	return hugetlb_free_hlpgd_range(tlb, addr, end, floor, ceiling);
+}
+#endif
+
 #endif /* __ASM_POWERPC_BOOK3S_64_PGALLOC_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 921784c0aa05..61f4d26bdaa9 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -718,6 +718,36 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 	return true;
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
+
+static inline int pmd_huge(pmd_t pmd)
+{
+	return hlpmd_huge(pmd);
+}
+
+static inline int pud_huge(pud_t pud)
+{
+	return hlpud_huge(pud);
+}
+
+static inline int pgd_huge(pgd_t pgd)
+{
+	return hlpgd_huge(pgd);
+}
+
+static inline bool hugepd_ok(hugepd_t hpd)
+{
+	return hlhugepd_ok(hpd);
+}
+
+static inline bool is_hugepd(hugepd_t hpd)
+{
+	return is_hlhugepd(hpd);
+}
+#define is_hugepd is_hugepd
+
+#endif /* CONFIG_HUGETLB_PAGE */
+
 #define pgprot_noncached pgprot_noncached
 static inline pgprot_t pgprot_noncached(pgprot_t prot)
 {
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 0525f1c29afb..c938150c440c 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -88,10 +88,6 @@ void book3e_hugetlb_preload(struct vm_area_struct *vma, unsigned long ea,
 			    pte_t pte);
 void flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
 
-void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
-			    unsigned long end, unsigned long floor,
-			    unsigned long ceiling);
-
 /*
  * The version of vma_mmu_pagesize() in arch/powerpc/mm/hugetlbpage.c needs
  * to override the version in mm/hugetlb.c
diff --git a/arch/powerpc/include/asm/nohash/pgalloc.h b/arch/powerpc/include/asm/nohash/pgalloc.h
index b39ec956d71e..2967ca3148da 100644
--- a/arch/powerpc/include/asm/nohash/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/pgalloc.h
@@ -20,4 +20,11 @@ static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
 #else
 #include <asm/nohash/32/pgalloc.h>
 #endif
+
+#ifdef CONFIG_HUGETLB_PAGE
+void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
+			    unsigned long end, unsigned long floor,
+			    unsigned long ceiling);
+#endif
+
 #endif /* _ASM_POWERPC_NOHASH_PGALLOC_H */
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 0126900c696e..84dd590b4a93 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -132,7 +132,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
  * This enables us to catch the wrong page directory format
  * Moved here so that we can use WARN() in the call.
  */
-int hugepd_ok(hugepd_t hpd)
+int hlhugepd_ok(hugepd_t hpd)
 {
 	bool is_hugepd;
 
@@ -176,7 +176,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
  * At this point we do the placement change only for BOOK3S 64. This would
  * possibly work on other subarchs.
  */
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+pte_t *huge_hlpte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
 	pgd_t *pg;
 	pud_t *pu;
@@ -335,9 +335,9 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 /*
  * This function frees user-level page tables of a process.
  */
-void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-			    unsigned long addr, unsigned long end,
-			    unsigned long floor, unsigned long ceiling)
+void hugetlb_free_hlpgd_range(struct mmu_gather *tlb,
+			      unsigned long addr, unsigned long end,
+			      unsigned long floor, unsigned long ceiling)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -373,7 +373,6 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 	} while (addr = next, addr != end);
 }
 
-
 /* Build list of addresses of gigantic pages.  This function is used in early
  * boot before the buddy allocator is setup.
  */
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 26fb814f289f..1e5e4d4cac55 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -454,3 +454,19 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 
 	return 1;
 }
+
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * Generic book3s code. We didn't want to create a separate header just for this
+ * ideally we want this static inline. But that require larger changes
+ */
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	return huge_hlpte_alloc(mm, addr, sz);
+#else
+	WARN(1, "%s called with HUGETLB disabled\n", __func__);
+	return NULL;
+#endif
+}
+#endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
