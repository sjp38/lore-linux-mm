Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 082B36B025B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:25:02 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id n128so46404148pfn.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:25:02 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id kw9si3851498pab.63.2016.01.29.11.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 11:25:01 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id gi1so4002144pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:25:01 -0800 (PST)
Date: Sat, 30 Jan 2016 03:24:56 +0800
From: ChengYi He <chengyihetaipei@gmail.com>
Subject: [RFC PATCH 1/2] mm/page_alloc: let migration fallback support pages
 of requested order
Message-ID: <5ae5eeb4bd12d5aa95a88590594139887257276e.1454094692.git.chengyihetaipei@gmail.com>
References: <cover.1454094692.git.chengyihetaipei@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1454094692.git.chengyihetaipei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, chengyihetaipei@gmail.com

This helper function only factors out the code flow within each order
during fallback. There is no function change.

Signed-off-by: ChengYi He <chengyihetaipei@gmail.com>
---
 mm/page_alloc.c | 79 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63358d9..50c325a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1752,51 +1752,64 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	}
 }
 
-/* Remove an element from the buddy allocator from the fallback list */
 static inline struct page *
-__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
+__rmqueue_fallback_order(struct zone *zone, unsigned int order,
+		int start_migratetype, int current_order)
 {
 	struct free_area *area;
-	unsigned int current_order;
 	struct page *page;
 	int fallback_mt;
 	bool can_steal;
 
-	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
-				--current_order) {
-		area = &(zone->free_area[current_order]);
-		fallback_mt = find_suitable_fallback(area, current_order,
-				start_migratetype, false, &can_steal);
-		if (fallback_mt == -1)
-			continue;
+	area = &(zone->free_area[current_order]);
+	fallback_mt = find_suitable_fallback(area, current_order,
+			start_migratetype, false, &can_steal);
+	if (fallback_mt == -1)
+		return NULL;
 
-		page = list_first_entry(&area->free_list[fallback_mt],
-						struct page, lru);
-		if (can_steal)
-			steal_suitable_fallback(zone, page, start_migratetype);
+	page = list_first_entry(&area->free_list[fallback_mt],
+					struct page, lru);
+	if (can_steal)
+		steal_suitable_fallback(zone, page, start_migratetype);
 
-		/* Remove the page from the freelists */
-		area->nr_free--;
-		list_del(&page->lru);
-		rmv_page_order(page);
+	/* Remove the page from the freelists */
+	area->nr_free--;
+	list_del(&page->lru);
+	rmv_page_order(page);
 
-		expand(zone, page, order, current_order, area,
-					start_migratetype);
-		/*
-		 * The pcppage_migratetype may differ from pageblock's
-		 * migratetype depending on the decisions in
-		 * find_suitable_fallback(). This is OK as long as it does not
-		 * differ for MIGRATE_CMA pageblocks. Those can be used as
-		 * fallback only via special __rmqueue_cma_fallback() function
-		 */
-		set_pcppage_migratetype(page, start_migratetype);
+	expand(zone, page, order, current_order, area,
+				start_migratetype);
+	/*
+	 * The pcppage_migratetype may differ from pageblock's
+	 * migratetype depending on the decisions in
+	 * find_suitable_fallback(). This is OK as long as it does not
+	 * differ for MIGRATE_CMA pageblocks. Those can be used as
+	 * fallback only via special __rmqueue_cma_fallback() function
+	 */
+	set_pcppage_migratetype(page, start_migratetype);
 
-		trace_mm_page_alloc_extfrag(page, order, current_order,
-			start_migratetype, fallback_mt);
+	trace_mm_page_alloc_extfrag(page, order, current_order,
+		start_migratetype, fallback_mt);
 
-		return page;
+	return page;
+}
+
+/* Remove an element from the buddy allocator from the fallback list */
+static inline struct page *
+__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
+{
+	unsigned int current_order;
+	struct page *page;
+
+	/* Find the largest possible block of pages in the other list */
+	for (current_order = MAX_ORDER-1;
+				current_order >= order && current_order <= MAX_ORDER-1;
+				--current_order) {
+		page = __rmqueue_fallback_order(zone, order, start_migratetype,
+				current_order);
+
+		if (page)
+			return page;
 	}
 
 	return NULL;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
