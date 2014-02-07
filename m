Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E8DC26B003A
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:08:55 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so2673808pde.35
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:08:55 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id x3si3533396pbf.91.2014.02.06.21.08.51
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:08:52 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/5] mm/compaction: clean-up code on success of ballon isolation
Date: Fri,  7 Feb 2014 14:08:46 +0900
Message-Id: <1391749726-28910-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is just for clean-up to reduce code size and improve readability.
There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 985b782..7a4e3b7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -554,11 +554,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			if (unlikely(balloon_page_movable(page))) {
 				if (locked && balloon_page_isolate(page)) {
 					/* Successfully isolated */
-					cc->finished_update_migrate = true;
-					list_add(&page->lru, migratelist);
-					cc->nr_migratepages++;
-					nr_isolated++;
-					goto check_compact_cluster;
+					goto isolate_success;
 				}
 			}
 			continue;
@@ -610,13 +606,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
-		cc->finished_update_migrate = true;
 		del_page_from_lru_list(page, lruvec, page_lru(page));
+
+isolate_success:
+		cc->finished_update_migrate = true;
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
 
-check_compact_cluster:
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
