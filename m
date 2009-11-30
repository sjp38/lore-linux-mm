Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 06B6C600309
	for <linux-mm@kvack.org>; Sun, 29 Nov 2009 22:00:25 -0500 (EST)
Received: by gxk21 with SMTP id 21so1864663gxk.10
        for <linux-mm@kvack.org>; Sun, 29 Nov 2009 19:00:24 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] remove the redundant code
Date: Mon, 30 Nov 2009 11:00:17 +0800
Message-Id: <1259550017-13263-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The check code for CONFIG_SWAP is redundant, because there is
a non-CONFIG_SWAP version for PageSwapCache() which just returns 0.

So the check code here is confusing when people see the code
in page-flags.h.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 include/linux/mm.h |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 24c3956..a85ed43 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -634,12 +634,9 @@ static inline struct address_space *page_mapping(struct page *page)
 	struct address_space *mapping = page->mapping;
 
 	VM_BUG_ON(PageSlab(page));
-#ifdef CONFIG_SWAP
 	if (unlikely(PageSwapCache(page)))
 		mapping = &swapper_space;
-	else
-#endif
-	if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
 	return mapping;
 }
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
