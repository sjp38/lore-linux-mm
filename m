Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 269B08D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:01:41 -0500 (EST)
Received: by mail-qy0-f169.google.com with SMTP id 2so6926893qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:01:40 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:01:40 +0000
Message-ID: <AANLkTimWWOcQ+NVOz5m9O6=Fmyga-PTA3++424ZYBk64@mail.gmail.com>
Subject: [RFC][PATCH 18/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
index 6da975d..453a388 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -22,10 +22,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
    free_page((unsigned long)pgd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+   gfp_t gfp_mask)
+{
+   return (pte_t *) __get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
 {
-   pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-   return pte;
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned
long address)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
