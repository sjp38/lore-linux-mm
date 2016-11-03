Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9106B02C1
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 05:29:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j198so8445736oih.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 02:29:28 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id y52si4329115otd.127.2016.11.03.02.29.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 02:29:27 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH] mm: cma: improve utilization of cma pages
Date: Thu, 3 Nov 2016 16:58:19 +0800
Message-ID: <1478163499-110185-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: puck.chen@hisilicon.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: oliver.fu@hisilicon.com, suzhuangluan@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, puck.chen@foxmail.com

Currently, cma pages can only be use by fallback of movable.
When there is no movable pages, the pcp pages will also be refilled.

So use the cma type before movable pages, and let cma-type fallback to
movable type.

I also have seen Joonsoo Kim on cma-zone. Makes cma pages a zone. It's
a good idea. But while testing it, the cma zone can be exhausted soon.
Then the cma zone will always doing balance. The slab_scans and swap
ion/out will be too high.

CC: Qiu xishi <qiuxishi@huawei.com>
Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
Reviewd-by: Fu Jun <oliver.fu@hisilicon.com>
---
 include/linux/gfp.h    |  3 +++
 include/linux/mmzone.h |  4 ++--
 mm/page_alloc.c        | 24 ++++++++----------------
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de..0bb8599 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -270,6 +270,9 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 	BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
 	BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
 
+	if (IS_ENABLED(CONFIG_CMA) && gfp_flags & __GFP_MOVABLE)
+		return MIGRATE_CMA;
+
 	if (unlikely(page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3..c7875c1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -39,8 +39,6 @@ enum {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_MOVABLE,
 	MIGRATE_RECLAIMABLE,
-	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
-	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
 	/*
 	 * MIGRATE_CMA migration type is designed to mimic the way
@@ -57,6 +55,8 @@ enum {
 	 */
 	MIGRATE_CMA,
 #endif
+	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
+	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
 #ifdef CONFIG_MEMORY_ISOLATION
 	MIGRATE_ISOLATE,	/* can't allocate from here */
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fd42aa..33ed6f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1828,17 +1828,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 #endif
 };
 
-#ifdef CONFIG_CMA
-static struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order)
-{
-	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
-}
-#else
-static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order) { return NULL; }
-#endif
-
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -2171,10 +2160,13 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 	struct page *page;
 
 	page = __rmqueue_smallest(zone, order, migratetype);
-	if (unlikely(!page)) {
-		if (migratetype == MIGRATE_MOVABLE)
-			page = __rmqueue_cma_fallback(zone, order);
+	/* Fallback cma type to movable here */
+	if (!page && migratetype == MIGRATE_CMA) {
+		migratetype = MIGRATE_MOVABLE;
+		page = __rmqueue_smallest(zone, order, migratetype);
+	}
 
+	if (unlikely(!page)) {
 		if (!page)
 			page = __rmqueue_fallback(zone, order, migratetype);
 	}
@@ -2787,7 +2779,7 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		if (alloc_harder)
 			return true;
 
-		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
+		for (mt = 0; mt < MIGRATE_PCPTYPES - 1; mt++) {
 			if (!list_empty(&area->free_list[mt]))
 				return true;
 		}
@@ -4206,10 +4198,10 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_UNMOVABLE]	= 'U',
 		[MIGRATE_MOVABLE]	= 'M',
 		[MIGRATE_RECLAIMABLE]	= 'E',
-		[MIGRATE_HIGHATOMIC]	= 'H',
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
+		[MIGRATE_HIGHATOMIC]	= 'H',
 #ifdef CONFIG_MEMORY_ISOLATION
 		[MIGRATE_ISOLATE]	= 'I',
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
