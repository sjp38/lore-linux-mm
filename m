Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADB26B003C
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:52:53 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so1613680pab.2
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:52:53 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id cv2si34739433pbc.135.2014.07.04.00.52.50
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:52:52 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 07/10] mm/page_alloc: store migratetype of the buddy list into freepage correctly
Date: Fri,  4 Jul 2014 16:57:52 +0900
Message-Id: <1404460675-24456-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Whenever page is splited or merged, we don't set migratetype to new page,
so there can be no accurate onbuddy_migratetype information. To maintain
it correctly, we should reset whenever page order is changed.
I think that set_page_order() is the best place to do, because it is
called whenever page is merged or splited. Hence, this patch adds
set_onbuddy_migratetype() to set_page_order().

And this patch makes set/get_onbuddy_migratetype() only enabled if
memory isolation is enabeld, because it doesn't needed in other case.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h |    6 ++++++
 mm/page_alloc.c    |    9 +++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 278ecfd..b35bd3b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -281,6 +281,7 @@ struct inode;
 #define page_private(page)		((page)->private)
 #define set_page_private(page, v)	((page)->private = (v))
 
+#if defined(CONFIG_MEMORY_ISOLATION)
 static inline void set_onbuddy_migratetype(struct page *page, int migratetype)
 {
 	page->index = migratetype;
@@ -294,6 +295,11 @@ static inline int get_onbuddy_migratetype(struct page *page)
 {
 	return page->index;
 }
+#else
+static inline void set_onbuddy_migratetype(struct page *page,
+						int migratetype) {}
+static inline int get_onbuddy_migratetype(struct page *page) { return 0; }
+#endif
 
 static inline void set_onpcp_migratetype(struct page *page, int migratetype)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d8ba2d..e1c4c3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -465,9 +465,11 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype) {}
 #endif
 
-static inline void set_page_order(struct page *page, unsigned int order)
+static inline void set_page_order(struct page *page, unsigned int order,
+							int migratetype)
 {
 	set_page_private(page, order);
+	set_onbuddy_migratetype(page, migratetype);
 	__SetPageBuddy(page);
 }
 
@@ -633,7 +635,7 @@ static inline void __free_one_page(struct page *page,
 		page_idx = combined_idx;
 		order++;
 	}
-	set_page_order(page, order);
+	set_page_order(page, order, migratetype);
 
 	/*
 	 * If this is not the largest possible page, check if the buddy
@@ -797,7 +799,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	set_onbuddy_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -943,7 +944,7 @@ static inline void expand(struct zone *zone, struct page *page,
 #endif
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
-		set_page_order(&page[size], high);
+		set_page_order(&page[size], high, migratetype);
 	}
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
