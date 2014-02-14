Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id BB1C16B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:54:07 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so11987185pbb.3
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:54:07 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qx4si4648280pbc.105.2014.02.13.22.54.05
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:54:06 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 1/5] mm/compaction: disallow high-order page for migration target
Date: Fri, 14 Feb 2014 15:53:59 +0900
Message-Id: <1392360843-22261-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Purpose of compaction is to get a high order page. Currently, if we find
high-order page while searching migration target page, we break it to
order-0 pages and use them as migration target. It is contrary to purpose
of compaction, so disallow high-order page to be used for
migration target.

Additionally, clean-up logic in suitable_migration_target() to simplify
the code. There is no functional changes from this clean-up.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 3a91a2e..bbe1260 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -217,21 +217,12 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
-	int migratetype = get_pageblock_migratetype(page);
-
-	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
-	if (migratetype == MIGRATE_RESERVE)
-		return false;
-
-	if (is_migrate_isolate(migratetype))
-		return false;
-
-	/* If the page is a large free page, then allow migration */
+	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
+		return false;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
+	if (migrate_async_suitable(get_pageblock_migratetype(page)))
 		return true;
 
 	/* Otherwise skip the block */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
