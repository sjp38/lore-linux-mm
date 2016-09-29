Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2A26B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:05:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b80so3880127wme.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si685072wmc.122.2016.09.29.14.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:05:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/4] mm, compaction: change migrate_async_suitable() to suitable_migration_source()
Date: Thu, 29 Sep 2016 23:05:45 +0200
Message-Id: <20160929210548.26196-2-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Preparation for making the decisions more complex and depending on
compact_control flags. No functional change.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  5 +++++
 mm/compaction.c        | 19 +++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 454495cc00fe..9cd3ee58ab2b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -72,6 +72,11 @@ extern char * const migratetype_names[MIGRATE_TYPES];
 #  define is_migrate_cma(migratetype) false
 #endif
 
+static inline bool is_migrate_movable(int mt)
+{
+	return is_migrate_cma(mt) || mt == MIGRATE_MOVABLE;
+}
+
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
diff --git a/mm/compaction.c b/mm/compaction.c
index 6e77b2016da1..673a81618534 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -88,11 +88,6 @@ static void map_pages(struct list_head *list)
 	list_splice(&tmp_list, list);
 }
 
-static inline bool migrate_async_suitable(int migratetype)
-{
-	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
-}
-
 #ifdef CONFIG_COMPACTION
 
 int PageMovable(struct page *page)
@@ -996,6 +991,15 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
 
+static bool suitable_migration_source(struct compact_control *cc,
+							struct page *page)
+{
+	if (cc->mode != MIGRATE_ASYNC)
+		return true;
+
+	return is_migrate_movable(get_pageblock_migratetype(page));
+}
+
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct compact_control *cc,
 							struct page *page)
@@ -1015,7 +1019,7 @@ static bool suitable_migration_target(struct compact_control *cc,
 	}
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
+	if (is_migrate_movable(get_pageblock_migratetype(page)))
 		return true;
 
 	/* Otherwise skip the block */
@@ -1250,8 +1254,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * Async compaction is optimistic to see if the minimum amount
 		 * of work satisfies the allocation.
 		 */
-		if (cc->mode == MIGRATE_ASYNC &&
-		    !migrate_async_suitable(get_pageblock_migratetype(page)))
+		if (!suitable_migration_source(cc, page))
 			continue;
 
 		/* Perform the isolation */
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
