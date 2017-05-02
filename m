Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A43396B02F4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 01:17:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s72so43874284pfi.19
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:17:28 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id i136si2955452pgc.412.2017.05.01.22.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 22:17:27 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id o68so11507924pfj.2
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:17:27 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v3 2/3] powerpc/mm/book(e)(3s)/32: Add page table accounting
Date: Tue,  2 May 2017 15:17:05 +1000
Message-Id: <20170502051706.19043-3-bsingharora@gmail.com>
In-Reply-To: <20170502051706.19043-1-bsingharora@gmail.com>
References: <20170502051706.19043-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, mpe@ellerman.id.au, oss@buserror.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

Add support in pte_alloc_one() and pgd_alloc() by
passing __GFP_ACCOUNT in the flags

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/include/asm/nohash/32/pgalloc.h | 3 ++-
 arch/powerpc/mm/pgtable_32.c                 | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/nohash/32/pgalloc.h b/arch/powerpc/include/asm/nohash/32/pgalloc.h
index 6331392..cc369a7 100644
--- a/arch/powerpc/include/asm/nohash/32/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/32/pgalloc.h
@@ -31,7 +31,8 @@ extern struct kmem_cache *pgtable_cache[];
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE),
+			pgtable_gfp_flags(mm, GFP_KERNEL));
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index a65c0b4..dc1e0c2 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -60,7 +60,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
 
-	gfp_t flags = GFP_KERNEL | __GFP_ZERO;
+	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT;
 
 	ptepage = alloc_pages(flags, 0);
 	if (!ptepage)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
