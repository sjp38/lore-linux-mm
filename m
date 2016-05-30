Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88473828E1
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:15:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so26425548wma.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z7si39006486wje.128.2016.05.30.02.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:15:15 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a136so20672666wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 11/17] powerpc: get rid of superfluous __GFP_REPEAT
Date: Mon, 30 May 2016 11:14:53 +0200
Message-Id: <1464599699-30131-12-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

{pud,pmd}_alloc_one are allocating from {PGT,PUD}_CACHE initialized in
pgtable_cache_init which doesn't have larger than sizeof(void *) << 12
size and that fits into !costly allocation request size.

PGALLOC_GFP is used only in radix__pgd_alloc which uses either order-0
or order-4 requests. The first one doesn't need the flag while the
second does. Drop __GFP_REPEAT from PGALLOC_GFP and add it for the
order-4 one.

This means that this flag has never been actually useful here because it
has always been used only for PAGE_ALLOC_COSTLY requests.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/powerpc/include/asm/book3s/64/pgalloc.h | 10 ++++------
 arch/powerpc/include/asm/nohash/64/pgalloc.h |  6 ++----
 arch/powerpc/mm/hugetlbpage.c                |  2 +-
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 049b80359db6..d14fcf82c00c 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -41,7 +41,7 @@ extern struct kmem_cache *pgtable_cache[];
 			pgtable_cache[(shift) - 1];	\
 		})
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO
 
 extern pte_t *pte_fragment_alloc(struct mm_struct *, unsigned long, int);
 extern void pte_fragment_free(unsigned long *, int);
@@ -56,7 +56,7 @@ static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
 	return (pgd_t *)__get_free_page(PGALLOC_GFP);
 #else
 	struct page *page;
-	page = alloc_pages(PGALLOC_GFP, 4);
+	page = alloc_pages(PGALLOC_GFP | __GFP_REPEAT, 4);
 	if (!page)
 		return NULL;
 	return (pgd_t *) page_address(page);
@@ -93,8 +93,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE), GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -115,8 +114,7 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX), GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/powerpc/include/asm/nohash/64/pgalloc.h b/arch/powerpc/include/asm/nohash/64/pgalloc.h
index a50981293d06..f4f72b7e676a 100644
--- a/arch/powerpc/include/asm/nohash/64/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/64/pgalloc.h
@@ -57,8 +57,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE), GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -190,8 +189,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX), GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 5aac1a3f86cd..119d18611500 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -73,7 +73,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 	cachep = PGT_CACHE(pdshift - pshift);
 #endif
 
-	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
+	new = kmem_cache_zalloc(cachep, GFP_KERNEL);
 
 	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
 	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
