Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16E736B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 04:38:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so4987701wjc.4
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 01:38:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 81si15304924wmq.96.2016.12.09.01.38.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 01:38:15 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/2] mm, page_alloc: avoid page_to_pfn() when merging buddies
Date: Fri,  9 Dec 2016 10:37:54 +0100
Message-Id: <20161209093754.3515-2-vbabka@suse.cz>
In-Reply-To: <20161209093754.3515-1-vbabka@suse.cz>
References: <20161209093754.3515-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On architectures that allow memory holes, page_is_buddy() has to perform
page_to_pfn() to check for the memory hole. After the previous patch, we have
the pfn already available in __free_one_page(), which is the only caller of
page_is_buddy(), so move the check there and avoid page_to_pfn().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 812475bff8f3..6ba0782f7892 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -714,7 +714,7 @@ static inline void rmv_page_order(struct page *page)
 /*
  * This function checks whether a page is free && is the buddy
  * we can do coalesce a page and its buddy if
- * (a) the buddy is not in a hole &&
+ * (a) the buddy is not in a hole (check before calling!) &&
  * (b) the buddy is in the buddy system &&
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
@@ -729,9 +729,6 @@ static inline void rmv_page_order(struct page *page)
 static inline int page_is_buddy(struct page *page, struct page *buddy,
 							unsigned int order)
 {
-	if (!pfn_valid_within(page_to_pfn(buddy)))
-		return 0;
-
 	if (page_is_guard(buddy) && page_order(buddy) == order) {
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
@@ -808,6 +805,9 @@ static inline void __free_one_page(struct page *page,
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(page_pfn, order);
 		buddy = page + (buddy_pfn - page_pfn);
+
+		if (!pfn_valid_within(buddy_pfn))
+			goto done_merging;
 		if (!page_is_buddy(page, buddy, order))
 			goto done_merging;
 		/*
@@ -862,7 +862,7 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(page_to_pfn(buddy))) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & page_pfn;
 		higher_page = page + (combined_pfn - page_pfn);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
