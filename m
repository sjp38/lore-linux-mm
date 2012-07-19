Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B93316B0082
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:55 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/34] mm: compaction: make isolate_lru_page() filter-aware
Date: Thu, 19 Jul 2012 15:36:23 +0100
Message-Id: <1342708604-26540-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Minchan Kim <minchan.kim@gmail.com>

commit 39deaf8585152f1a35c1676d3d7dc6ae0fb65967 upstream.

Stable note: Not tracked in Bugzilla. THP and compaction disrupt the LRU
	list leading to poor reclaim decisions which has a variable
	performance impact.

In async mode, compaction doesn't migrate dirty or writeback pages.  So,
it's meaningless to pick the page and re-add it to lru list.

Of course, when we isolate the page in compaction, the page might be dirty
or writeback but when we try to migrate the page, the page would be not
dirty, writeback.  So it could be migrated.  But it's very unlikely as
isolate and migration cycle is much faster than writeout.

So, this patch helps cpu overhead and prevent unnecessary LRU churning.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    2 ++
 mm/compaction.c        |    7 +++++--
 mm/vmscan.c            |    3 +++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5a5286d..632107e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -162,6 +162,8 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define ISOLATE_INACTIVE	((__force isolate_mode_t)0x1)
 /* Isolate active pages */
 #define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
+/* Isolate clean file */
+#define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/compaction.c b/mm/compaction.c
index 4fbbbd0..61e68a5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,6 +261,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
+	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -370,9 +371,11 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
+		if (!cc->sync)
+			mode |= ISOLATE_CLEAN;
+
 		/* Try isolate the page */
-		if (__isolate_lru_page(page,
-				ISOLATE_ACTIVE|ISOLATE_INACTIVE, 0) != 0)
+		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4bb2010..032f35e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1045,6 +1045,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 
 	ret = -EBUSY;
 
+	if ((mode & ISOLATE_CLEAN) && (PageDirty(page) || PageWriteback(page)))
+		return ret;
+
 	if (likely(get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
