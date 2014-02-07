Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 678F36B0037
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:08:52 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so2667925pdj.25
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:08:52 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id fl7si3469700pad.316.2014.02.06.21.08.48
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:08:50 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/5] mm/compaction: disallow high-order page for migration target
Date: Fri,  7 Feb 2014 14:08:42 +0900
Message-Id: <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Purpose of compaction is to get a high order page. Currently, if we find
high-order page while searching migration target page, we break it to
order-0 pages and use them as migration target. It is contrary to purpose
of compaction, so disallow high-order page to be used for
migration target.

Additionally, clean-up logic in suitable_migration_target() to simply.
There is no functional changes from this clean-up.

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
