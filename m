Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00F7E828DF
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:08:47 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id u206so99255208wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:47 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id kh8si28252850wjb.218.2016.04.11.04.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:34 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so20428526wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 11/19] powerpc: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 13:08:04 +0200
Message-Id: <1460372892-8157-12-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

{pud,pmd}_alloc_one are allocating from {PGT,PUD}_CACHE initialized in
pgtable_cache_init which doesn't have larger than sizeof(void *) << 12
size and that fits into !costly allocation request size. This means that
this flag has never been actually useful here because it has always been
used only for PAGE_ALLOC_COSTLY requests.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/powerpc/include/asm/pgalloc-64.h | 6 +++---
 arch/powerpc/mm/hugetlbpage.c         | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 5dcfde5dc673..aaa6d3bc5d86 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -58,7 +58,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+				GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -181,7 +181,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+				GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -245,7 +245,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
-				GFP_KERNEL|__GFP_REPEAT);
+				GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a4a90a869999..6cfc48c94d4b 100644
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
