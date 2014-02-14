Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7B76B0038
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:54:09 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so11576710pde.13
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:54:09 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xk2si4652379pab.71.2014.02.13.22.54.07
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:54:08 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 4/5] mm/compaction: check pageblock suitability once per pageblock
Date: Fri, 14 Feb 2014 15:54:02 +0900
Message-Id: <1392360843-22261-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

isolation_suitable() and migrate_async_suitable() is used to be sure
that this pageblock range is fine to be migragted. It isn't needed to
call it on every page. Current code do well if not suitable, but, don't
do well when suitable.

1) It re-checks isolation_suitable() on each page of a pageblock that was
already estabilished as suitable.
2) It re-checks migrate_async_suitable() on each page of a pageblock that
was not entered through the next_pageblock: label, because
last_pageblock_nr is not otherwise updated.

This patch fixes situation by 1) calling isolation_suitable() only once
per pageblock and 2) always updating last_pageblock_nr to the pageblock
that was just checked.

Additionally, move PageBuddy() check after pageblock unit check,
since pageblock check is the first thing we should do and makes things
more simple.

[vbabka@suse.cz: rephrase commit description]
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index b1ba297..56536d3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -520,26 +520,31 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 		/* If isolation recently failed, do not retry */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!isolation_suitable(cc, page))
-			goto next_pageblock;
+		if (last_pageblock_nr != pageblock_nr) {
+			int mt;
+
+			last_pageblock_nr = pageblock_nr;
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
@@ -621,7 +626,6 @@ check_compact_cluster:
 
 next_pageblock:
 		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
-		last_pageblock_nr = pageblock_nr;
 	}
 
 	acct_isolated(zone, locked, cc);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
