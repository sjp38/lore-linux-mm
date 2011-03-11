Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6588D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:55:23 -0500 (EST)
Received: by qwa26 with SMTP id 26so101946qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:55:21 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:55:21 +0000
Message-ID: <AANLkTikPOCMcuU-y=LyKrJhcZ0tN=d8hKsFaLSAerasj@mail.gmail.com>
Subject: [RFC][PATCH 09/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/score/include/asm/pgalloc.h b/arch/score/include/asm/pgalloc.h
index 059a61b..5c2a47b 100644
--- a/arch/score/include/asm/pgalloc.h
+++ b/arch/score/include/asm/pgalloc.h
@@ -37,15 +37,17 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
    free_pages((unsigned long)pgd, PGD_ORDER);
 }

-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-   unsigned long address)
+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
-   pte_t *pte;
-
-   pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
+   return (pte_t *) __get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO,
                    PTE_ORDER);
+}

-   return pte;
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+   unsigned long address)
+{
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
