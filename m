Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21D658D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:58:31 -0500 (EST)
Received: by qwa26 with SMTP id 26so104071qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:58:28 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:58:28 +0000
Message-ID: <AANLkTi=+7jS+9AEWWZOSPa6EtX1nN0KKZDcAya70=G-O@mail.gmail.com>
Subject: [RFC][PATCH 13/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
index bc7e8ae..2eb4824 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -51,10 +51,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
    quicklist_free(QUICK_PGD, NULL, pgd);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+                     unsigned long address, gfp_t gfp_mask)
+{
+   return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
                      unsigned long address)
 {
-   return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
