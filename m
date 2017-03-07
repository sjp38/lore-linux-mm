Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8F86B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:16:24 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so438273wry.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:16:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si20710234wra.223.2017.03.07.05.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:16:22 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 5/8] mm, compaction: change migrate_async_suitable() to suitable_migration_source()
Date: Tue,  7 Mar 2017 14:15:42 +0100
Message-Id: <20170307131545.28577-6-vbabka@suse.cz>
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
References: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Preparation for making the decisions more complex and depending on
compact_control flags. No functional change.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  5 +++++
 mm/compaction.c        | 19 +++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 446cf68c1c09..618499159a7c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -74,6 +74,11 @@ extern char * const migratetype_names[MIGRATE_TYPES];
 #  define is_migrate_cma_page(_page) false
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
index 9222ff362f33..a7c2f0da7228 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -89,11 +89,6 @@ static void map_pages(struct list_head *list)
 	list_splice(&tmp_list, list);
 }
 
-static inline bool migrate_async_suitable(int migratetype)
-{
-	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
-}
-
 #ifdef CONFIG_COMPACTION
 
 int PageMovable(struct page *page)
@@ -988,6 +983,15 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
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
@@ -1007,7 +1011,7 @@ static bool suitable_migration_target(struct compact_control *cc,
 	}
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
+	if (is_migrate_movable(get_pageblock_migratetype(page)))
 		return true;
 
 	/* Otherwise skip the block */
@@ -1242,8 +1246,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * Async compaction is optimistic to see if the minimum amount
 		 * of work satisfies the allocation.
 		 */
-		if (cc->mode == MIGRATE_ASYNC &&
-		    !migrate_async_suitable(get_pageblock_migratetype(page)))
+		if (!suitable_migration_source(cc, page))
 			continue;
 
 		/* Perform the isolation */
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
