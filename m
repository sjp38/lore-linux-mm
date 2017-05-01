Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78B8A6B02EE
	for <linux-mm@kvack.org>; Mon,  1 May 2017 02:34:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z185so41007414pgz.11
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:34:56 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s25si14320447pgd.54.2017.04.30.23.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 23:34:55 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id v14so26689929pfd.3
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:34:55 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v2 1/3] powerpc/mm/book(e)(3s)/64: Add page table accounting
Date: Mon,  1 May 2017 16:34:36 +1000
Message-Id: <20170501063438.25237-2-bsingharora@gmail.com>
In-Reply-To: <20170501063438.25237-1-bsingharora@gmail.com>
References: <20170501063438.25237-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com, mpe@ellerman.id.au, oss@buserror.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

Introduce a helper pgtable_gfp_flags() which
just returns the current gfp flags and adds
__GFP_ACCOUNT to account for page table allocation.
The generic helper is added to include/asm/pgalloc.h
and has two variants - WARNING ugly bits ahead

1. If the header is included from a module, no check
for mm == &init_mm is done, since init_mm is not
exported
2. For kernel includes, the check is done and required
see (3e79ec7 arch: x86: charge page tables to kmemcg)

The fundamental assumption is that no module should be
doing pgd/pud/pmd and pte alloc's on behalf of init_mm
directly.

NOTE: This adds an overhead to pmd/pud/pgd allocations
similar to x86.  The other alternative was to implement
pmd_alloc_kernel/pud_alloc_kernel and pgd_alloc_kernel
with their offset variants.

For 4k page size, pte_alloc_one no longer calls
pte_alloc_one_kernel.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/include/asm/book3s/32/pgalloc.h |  3 ++-
 arch/powerpc/include/asm/book3s/64/pgalloc.h | 17 +++++++++++------
 arch/powerpc/include/asm/nohash/64/pgalloc.h | 12 ++++++++----
 arch/powerpc/include/asm/pgalloc.h           | 14 ++++++++++++++
 arch/powerpc/mm/pgtable_64.c                 |  3 ++-
 5 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgalloc.h b/arch/powerpc/include/asm/book3s/32/pgalloc.h
index d310546..a120e7f 100644
--- a/arch/powerpc/include/asm/book3s/32/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/32/pgalloc.h
@@ -31,7 +31,8 @@ extern struct kmem_cache *pgtable_cache[];
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE),
+			pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index cd5e7aa..9aa904f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -53,10 +53,11 @@ extern void __tlb_remove_table(void *_table);
 static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
 {
 #ifdef CONFIG_PPC_64K_PAGES
-	return (pgd_t *)__get_free_page(PGALLOC_GFP);
+	return (pgd_t *)__get_free_page(pgtable_gfp_flags(mm, PGALLOC_GFP));
 #else
 	struct page *page;
-	page = alloc_pages(PGALLOC_GFP | __GFP_REPEAT, 4);
+	page = alloc_pages(pgtable_gfp_flags(mm, PGALLOC_GFP | __GFP_REPEAT),
+				4);
 	if (!page)
 		return NULL;
 	return (pgd_t *) page_address(page);
@@ -76,7 +77,8 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	if (radix_enabled())
 		return radix__pgd_alloc(mm);
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE),
+		pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
@@ -93,7 +95,8 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
+		pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -119,7 +122,8 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
+		pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -168,7 +172,8 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	pte_t *pte;
 
-	pte = pte_alloc_one_kernel(mm, address);
+	pte = (pte_t *)__get_free_page(pgtable_gfp_flags(mm,
+					GFP_KERNEL | __GFP_ZERO));
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
diff --git a/arch/powerpc/include/asm/nohash/64/pgalloc.h b/arch/powerpc/include/asm/nohash/64/pgalloc.h
index 897d2e1..0d5e37b 100644
--- a/arch/powerpc/include/asm/nohash/64/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/64/pgalloc.h
@@ -43,7 +43,8 @@ extern struct kmem_cache *pgtable_cache[];
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE),
+			pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
@@ -57,7 +58,8 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
+			pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -96,7 +98,8 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	pte_t *pte;
 
-	pte = pte_alloc_one_kernel(mm, address);
+	pte = (pte_t *)__get_free_page(
+		pgtable_gfp_flags(mm, GFP_KERNEL | __GFP_ZERO));
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
@@ -189,7 +192,8 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
+			pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/powerpc/include/asm/pgalloc.h b/arch/powerpc/include/asm/pgalloc.h
index 0413457..d795c5d 100644
--- a/arch/powerpc/include/asm/pgalloc.h
+++ b/arch/powerpc/include/asm/pgalloc.h
@@ -3,6 +3,20 @@
 
 #include <linux/mm.h>
 
+#ifndef MODULE
+static inline gfp_t pgtable_gfp_flags(struct mm_struct *mm, gfp_t gfp)
+{
+	if (unlikely(mm == &init_mm))
+		return gfp;
+	return gfp | __GFP_ACCOUNT;
+}
+#else /* !MODULE */
+static inline gfp_t pgtable_gfp_flags(struct mm_struct *mm, gfp_t gfp)
+{
+	return gfp | __GFP_ACCOUNT;
+}
+#endif /* MODULE */
+
 #ifdef CONFIG_PPC_BOOK3S
 #include <asm/book3s/pgalloc.h>
 #else
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index db93cf7..b322262 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -351,9 +351,10 @@ static pte_t *get_from_cache(struct mm_struct *mm)
 static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
 {
 	void *ret = NULL;
-	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
+	struct page *page = alloc_page(pgtable_gfp_flags(mm, PGALLOC_GFP));
 	if (!page)
 		return NULL;
+
 	if (!kernel && !pgtable_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
