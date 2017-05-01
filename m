Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 296326B02F2
	for <linux-mm@kvack.org>; Mon,  1 May 2017 02:35:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b67so19779342pfk.0
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:35:00 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id u70si13660696pgc.241.2017.04.30.23.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 23:34:59 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id t7so14919747pgt.1
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:34:59 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v2 2/3] powerpc/mm/book(e)(3s)/32: Add page table accounting
Date: Mon,  1 May 2017 16:34:37 +1000
Message-Id: <20170501063438.25237-3-bsingharora@gmail.com>
In-Reply-To: <20170501063438.25237-1-bsingharora@gmail.com>
References: <20170501063438.25237-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com, mpe@ellerman.id.au, oss@buserror.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

Add support in pte_alloc_one() and pgd_alloc() by
passing __GFP_ACCOUNT in the flags

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/include/asm/nohash/32/pgalloc.h | 3 ++-
 arch/powerpc/mm/pgtable_32.c                 | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/nohash/32/pgalloc.h b/arch/powerpc/include/asm/nohash/32/pgalloc.h
index 6331392..1900d9c 100644
--- a/arch/powerpc/include/asm/nohash/32/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/32/pgalloc.h
@@ -31,7 +31,8 @@ extern struct kmem_cache *pgtable_cache[];
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE),
+			pgtable_gfp_flags(GFP_KERNEL));
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
