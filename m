Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 255D0828DF
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:08:50 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id n3so99493001wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:50 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id a145si17798116wmd.61.2016.04.11.04.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:34 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so20452493wmn.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:34 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 12/19] sparc: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 13:08:05 +0200
Message-Id: <1460372892-8157-13-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "David S. Miller" <davem@davemloft.net>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

{pud,pmd}_alloc_one is using __GFP_REPEAT but it always allocates from
pgtable_cache which is initialzed to PAGE_SIZE objects. This means that
this flag has never been actually useful here because it has always been
used only for PAGE_ALLOC_COSTLY requests.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/sparc/include/asm/pgalloc_64.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 5e3187185b4a..3529f1378cd8 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -41,8 +41,7 @@ static inline void __pud_populate(pud_t *pud, pmd_t *pmd)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -52,8 +51,7 @@ static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
