Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11B8C6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:00:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so7216569wmd.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:00:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si6690730wja.236.2016.12.16.04.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 04:00:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/2] mm, page_alloc: avoid page_to_pfn() when merging buddies
Date: Fri, 16 Dec 2016 13:00:09 +0100
Message-Id: <20161216120009.20064-2-vbabka@suse.cz>
In-Reply-To: <20161216120009.20064-1-vbabka@suse.cz>
References: <20161216120009.20064-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On architectures that allow memory holes, page_is_buddy() has to perform
page_to_pfn() to check for the memory hole. After the previous patch, we have
the pfn already available in __free_one_page(), which is the only caller of
page_is_buddy(), so move the check there and avoid page_to_pfn().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c     | 10 +++++-----
 mm/page_isolation.c |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 771fc8e18736..f546eeea24d6 100644
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
 		buddy_pfn = __find_buddy_pfn(pfn, order);
 		buddy = page + (buddy_pfn - pfn);
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
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index dadb7e74d7d6..f4e17a57926a 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -106,7 +106,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 			buddy_pfn = __find_buddy_pfn(pfn, order);
 			buddy = page + (buddy_pfn - pfn);
 
-			if (pfn_valid_within(page_to_pfn(buddy)) &&
+			if (pfn_valid_within(buddy_pfn) &&
 			    !is_migrate_isolate_page(buddy)) {
 				__isolate_free_page(page, order);
 				isolated_page = true;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
