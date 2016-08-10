Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C79E5828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:16:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so65478093pfg.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:27 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id oy8si46771089pac.126.2016.08.09.23.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:16:25 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i6so2242780pfe.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:19 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/5] mm/debug_pagealloc: clean-up guard page handling code
Date: Wed, 10 Aug 2016 15:16:20 +0900
Message-Id: <1470809784-11516-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can make code clean by moving decision condition
for set_page_guard() into set_page_guard() itself. It will
help code readability. There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 277c3d0..5e7944b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -638,17 +638,20 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 }
 __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
 
-static inline void set_page_guard(struct zone *zone, struct page *page,
+static inline bool set_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
 {
 	struct page_ext *page_ext;
 
 	if (!debug_guardpage_enabled())
-		return;
+		return false;
+
+	if (order >= debug_guardpage_minorder())
+		return false;
 
 	page_ext = lookup_page_ext(page);
 	if (unlikely(!page_ext))
-		return;
+		return false;
 
 	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
 
@@ -656,6 +659,8 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
 	set_page_private(page, order);
 	/* Guard pages are not available for any usage */
 	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
+
+	return true;
 }
 
 static inline void clear_page_guard(struct zone *zone, struct page *page,
@@ -678,8 +683,8 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 }
 #else
 struct page_ext_operations debug_guardpage_ops = { NULL, };
-static inline void set_page_guard(struct zone *zone, struct page *page,
-				unsigned int order, int migratetype) {}
+static inline bool set_page_guard(struct zone *zone, struct page *page,
+			unsigned int order, int migratetype) { return false; }
 static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype) {}
 #endif
@@ -1650,18 +1655,15 @@ static inline void expand(struct zone *zone, struct page *page,
 		size >>= 1;
 		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
 
-		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
-			debug_guardpage_enabled() &&
-			high < debug_guardpage_minorder()) {
-			/*
-			 * Mark as guard pages (or page), that will allow to
-			 * merge back to allocator when buddy will be freed.
-			 * Corresponding page table entries will not be touched,
-			 * pages will stay not present in virtual address space
-			 */
-			set_page_guard(zone, &page[size], high, migratetype);
+		/*
+		 * Mark as guard pages (or page), that will allow to
+		 * merge back to allocator when buddy will be freed.
+		 * Corresponding page table entries will not be touched,
+		 * pages will stay not present in virtual address space
+		 */
+		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
-		}
+
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
