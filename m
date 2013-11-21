Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B348E6B003A
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 08:01:39 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so8966544pde.21
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 05:01:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id yd9si16902591pab.292.2013.11.21.05.01.37
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 05:01:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: place page->pmd_huge_pte to right union
Date: Thu, 21 Nov 2013 15:00:10 +0200
Message-Id: <1385038810-15513-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I don't know what went wrong, mis-merge or something, but ->pmd_huge_pte
placed in wrong union within struct page.

In original patch[1] it's placed to union with ->lru and ->slab, but in
commit e009bb30c8df it's in union with ->index and ->freelist.

That union seems also unused for pages with table tables and safe to
re-use, but it's not what I've tested.

Let's move it to original place. It fixes indentation at least. :)

[1] https://lkml.org/lkml/2013/10/7/288

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 10f5a7272b80..011eb85d7b0f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -65,9 +65,6 @@ struct page {
 						 * this page is only used to
 						 * free other pages.
 						 */
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-		pgtable_t pmd_huge_pte; /* protected by page->ptl */
-#endif
 		};
 
 		union {
@@ -135,6 +132,9 @@ struct page {
 
 		struct list_head list;	/* slobs list of pages */
 		struct slab *slab_page; /* slab fields */
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
+		pgtable_t pmd_huge_pte; /* protected by page->ptl */
+#endif
 	};
 
 	/* Remainder is not double word aligned */
-- 
1.8.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
