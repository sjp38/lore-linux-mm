Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E62336B0038
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:52:01 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so10168275pad.29
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:52:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id f1si11530591pbn.59.2014.04.15.14.52.00
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 14:52:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: consilidate assert checks in __split_huge_page()
Date: Wed, 16 Apr 2014 00:51:49 +0300
Message-Id: <1397598709-25598-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It doesn't make sense to have two assert checks for each invariant: one
for printing and one for BUG().

Let's trigger BUG() if we print error message.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 64635f5278ff..5025709bb3b5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1823,10 +1823,11 @@ static void __split_huge_page(struct page *page,
 	 * the newly established pmd of the child later during the
 	 * walk, to be able to set it as pmd_trans_splitting too.
 	 */
-	if (mapcount != page_mapcount(page))
+	if (mapcount != page_mapcount(page)) {
 		printk(KERN_ERR "mapcount %d page_mapcount %d\n",
 		       mapcount, page_mapcount(page));
-	BUG_ON(mapcount != page_mapcount(page));
+		BUG();
+	}
 
 	__split_huge_page_refcount(page, list);
 
@@ -1837,10 +1838,11 @@ static void __split_huge_page(struct page *page,
 		BUG_ON(is_vma_temporary_stack(vma));
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
-	if (mapcount != mapcount2)
+	if (mapcount != mapcount2) {
 		printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount %d\n",
 		       mapcount, mapcount2, page_mapcount(page));
-	BUG_ON(mapcount != mapcount2);
+		BUG();
+	}
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
