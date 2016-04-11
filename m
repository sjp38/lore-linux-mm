Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7939F6B0263
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:08:32 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id f198so140617292wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:32 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id o8si28213502wjo.165.2016.04.11.04.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:28 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n3so20451839wmn.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 04/19] arm: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 13:07:57 +0200
Message-Id: <1460372892-8157-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

PGALLOC_GFP uses __GFP_REPEAT but none of the allocation which uses
this flag is for more than order-2. This means that this flag has never
been actually useful here because it has always been used only for
PAGE_ALLOC_COSTLY requests.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm/include/asm/pgalloc.h | 2 +-
 arch/arm/mm/pgd.c              | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 20febb368844..b2902a5cd780 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -57,7 +57,7 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 static inline void clean_pte_table(pte_t *pte)
 {
diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
index b8d477321730..c1c1a5c67da1 100644
--- a/arch/arm/mm/pgd.c
+++ b/arch/arm/mm/pgd.c
@@ -23,7 +23,7 @@
 #define __pgd_alloc()	kmalloc(PTRS_PER_PGD * sizeof(pgd_t), GFP_KERNEL)
 #define __pgd_free(pgd)	kfree(pgd)
 #else
-#define __pgd_alloc()	(pgd_t *)__get_free_pages(GFP_KERNEL | __GFP_REPEAT, 2)
+#define __pgd_alloc()	(pgd_t *)__get_free_pages(GFP_KERNEL, 2)
 #define __pgd_free(pgd)	free_pages((unsigned long)pgd, 2)
 #endif
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
