Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id EFEB06B0039
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:08:54 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so2761488pbb.39
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:08:54 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id fl7si3469700pad.316.2014.02.06.21.08.51
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:08:52 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/5] mm/compaction: check pageblock suitability once per pageblock
Date: Fri,  7 Feb 2014 14:08:45 +0900
Message-Id: <1391749726-28910-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

isolation_suitable() and migrate_async_suitable() is used to be sure
that this pageblock range is fine to be migragted. It isn't needed to
call it on every page. Current code do well if not suitable, but, don't
do well when suitable. It re-check it on every valid pageblock.
This patch fix this situation by updating last_pageblock_nr.

Additionally, move PageBuddy() check after pageblock unit check,
since pageblock check is the first thing we should do and makes things
more simple.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index b1ba297..985b782 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -520,26 +520,32 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 		/* If isolation recently failed, do not retry */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!isolation_suitable(cc, page))
-			goto next_pageblock;
+		if (last_pageblock_nr != pageblock_nr) {
+			int mt;
+
+			if (!isolation_suitable(cc, page))
+				goto next_pageblock;
+
+			/*
+			 * For async migration, also only scan in MOVABLE
+			 * blocks. Async migration is optimistic to see if
+			 * the minimum amount of work satisfies the allocation
+			 */
+			mt = get_pageblock_migratetype(page);
+			if (!cc->sync && !migrate_async_suitable(mt)) {
+				cc->finished_update_migrate = true;
+				skipped_async_unsuitable = true;
+				goto next_pageblock;
+			}
+
+			last_pageblock_nr = pageblock_nr;
+		}
 
 		/* Skip if free */
 		if (PageBuddy(page))
 			continue;
 
 		/*
-		 * For async migration, also only scan in MOVABLE blocks. Async
-		 * migration is optimistic to see if the minimum amount of work
-		 * satisfies the allocation
-		 */
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
-		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
-			cc->finished_update_migrate = true;
-			skipped_async_unsuitable = true;
-			goto next_pageblock;
-		}
-
-		/*
 		 * Check may be lockless but that's ok as we recheck later.
 		 * It's possible to migrate LRU pages and balloon pages
 		 * Skip any other type of page
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
