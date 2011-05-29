Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A62C96B0026
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:14:21 -0400 (EDT)
Received: by mail-px0-f177.google.com with SMTP id 10so2040762pxi.8
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:14:20 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 05/10] compaction: make isolate_lru_page with filter aware
Date: Mon, 30 May 2011 03:13:44 +0900
Message-Id: <4feb21bdac4c00a30f3c0d9361bd3565e6afa72f.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

In async mode, compaction doesn't migrate dirty or writeback pages.
So, it's meaningless to pick the page and re-add it to lru list.

Of course, when we isolate the page in compaction, the page might
be dirty or writeback but when we try to migrate the page, the page
would be not dirty, writeback. So it could be migrated. But it's
very unlikely as isolate and migration cycle is much faster than
writeout.

So, this patch helps cpu and prevent unnecessary LRU churning.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 61eab88..e218562 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -243,6 +243,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
+	enum ISOLATE_PAGE_MODE mode = ISOLATE_BOTH;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -327,7 +328,9 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
+		if (!cc->sync)
+			mode |= ISOLATE_CLEAN;
+		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
