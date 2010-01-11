Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62E396B0071
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 23:37:40 -0500 (EST)
Received: by mail-qy0-f184.google.com with SMTP id 14so9443617qyk.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 20:37:39 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH 3/4] mm/page_alloc : modify the return type of __free_one_page
Date: Mon, 11 Jan 2010 12:37:13 +0800
Message-Id: <1263184634-15447-3-git-send-email-shijie8@gmail.com>
In-Reply-To: <1263184634-15447-2-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
 <1263184634-15447-2-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

  Modify the return type for __free_one_page.
It will return 1 on success, and return 0 when
the check of the compound page is failed.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 00aa83a..290dfc3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -445,17 +445,18 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * triggers coalescing into a block of larger size.            
  *
  * -- wli
+ *
+ *  Returns 1 on success, else return 0;
  */
 
-static inline void __free_one_page(struct page *page,
-		struct zone *zone, unsigned int order,
-		int migratetype)
+static inline int __free_one_page(struct page *page, struct zone *zone,
+		       unsigned int order, int migratetype)
 {
 	unsigned long page_idx;
 
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
-			return;
+			return 0;
 
 	VM_BUG_ON(migratetype == -1);
 
@@ -485,6 +486,7 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru,
 		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;
+	return 1;
 }
 
 /*
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
