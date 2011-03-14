Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43C8C8D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:34:06 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1815507qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:34:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:34:03 +0000
Message-ID: <AANLkTimp6xeoCJYh-xXqKv9qytYU3dMK8MjUQ90-am0W@mail.gmail.com>
Subject: [RFC][PATCH v2 04/23] (cris) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/cris/include/asm/pgalloc.h |   10 ++++++++--
1 files changed, 8 insertions(+), 2 deletions(-)
---
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
index 6da975d..20254ee 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -22,10 +22,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+	gfp_t gfp_mask)
+{
+  	return (pte_t *) __get_free_page(gfp_mask | __GFP_ZERO);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
 {
-  	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
- 	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned
long address)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
