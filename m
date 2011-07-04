Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E20E39000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 10:05:20 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 8so6219561iyl.14
        for <linux-mm@kvack.org>; Mon, 04 Jul 2011 07:05:19 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 03/10] compaction: make isolate_lru_page with filter aware
Date: Mon,  4 Jul 2011 23:04:36 +0900
Message-Id: <0e4a2d5d0cb59c9db03bcd89aa6fa8dae3491d59.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

In async mode, compaction doesn't migrate dirty or writeback pages.
So, it's meaningless to pick the page and re-add it to lru list.

Of course, when we isolate the page in compaction, the page might
be dirty or writeback but when we try to migrate the page, the page
would be not dirty, writeback. So it could be migrated. But it's
very unlikely as isolate and migration cycle is much faster than
writeout.

So, this patch helps cpu overhead and prevent unnecessary LRU churning.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/mmzone.h |    3 ++-
 mm/compaction.c        |    7 +++++--
 mm/vmscan.c            |    3 +++
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0efdd6e..84819b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -162,7 +162,8 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define ISOLATE_INACTIVE	((__force fmode_t)0x1)
 /* Isolate active pages */
 #define ISOLATE_ACTIVE		((__force fmode_t)0x2)
-
+/* Isolate clean file */
+#define ISOLATE_CLEAN		((__force fmode_t)0x4)
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 47f717f..a0e4202 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,6 +261,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
+	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -348,9 +349,11 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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
index 1736ecf..64e78a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1005,6 +1005,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 
 	ret = -EBUSY;
 
+	if ((mode & ISOLATE_CLEAN) && (PageDirty(page) || PageWriteback(page)))
+		return ret;
+
 	if (likely(get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
