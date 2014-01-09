Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 455B06B003B
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:39 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so2932045pab.33
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:38 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id eb3si2955614pbd.257.2014.01.08.23.04.36
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:38 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 6/7] mm/page_alloc: store freelist migratetype to the page on buddy properly
Date: Thu,  9 Jan 2014 16:04:46 +0900
Message-Id: <1389251087-10224-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To maintain freelist migratetype information on buddy pages, migratetype
should be set again whenever the page order is changed. set_page_order()
is the best place to do, because it is called whenever the page order is
changed, so this patch adds set_buddy_migratetype() to set_page_order().

And this patch makes set/get_buddy_migratetype() only enabled if it is
really needed, because it has some overhead.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2733e0b..046e09f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -258,6 +258,12 @@ struct inode;
 #define set_page_private(page, v)	((page)->private = (v))
 
 /*
+ * This is for tracking the type of the list on buddy.
+ * It imposes some performance overhead to the buddy allocator,
+ * so we make it enabled only if it is needed.
+ */
+#if defined(CONFIG_MEMORY_ISOLATION) || defined(CONFIG_CMA)
+/*
  * It's valid only if the page is on buddy. It represents
  * which freelist the page is linked.
  */
@@ -270,6 +276,10 @@ static inline int get_buddy_migratetype(struct page *page)
 {
 	return page->index;
 }
+#else
+static inline void set_buddy_migratetype(struct page *page, int migratetype) {}
+static inline int get_buddy_migratetype(struct page *page) { return 0; }
+#endif
 
 /*
  * It's valid only if the page is on pcp list. It represents
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c9e6622..2548b42 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -446,9 +446,11 @@ static inline void set_page_guard_flag(struct page *page) { }
 static inline void clear_page_guard_flag(struct page *page) { }
 #endif
 
-static inline void set_page_order(struct page *page, int order)
+static inline void set_page_order(struct page *page, int order,
+						int migratetype)
 {
 	set_page_private(page, order);
+	set_buddy_migratetype(page, migratetype);
 	__SetPageBuddy(page);
 }
 
@@ -588,7 +590,7 @@ static inline void __free_one_page(struct page *page,
 		page_idx = combined_idx;
 		order++;
 	}
-	set_page_order(page, order);
+	set_page_order(page, order, migratetype);
 
 	/*
 	 * If this is not the largest possible page, check if the buddy
@@ -745,7 +747,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
 	migratetype = get_pageblock_migratetype(page);
-	set_buddy_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -834,7 +835,7 @@ static inline void expand(struct zone *zone, struct page *page,
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
