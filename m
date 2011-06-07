Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0286B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:31 -0400 (EDT)
Received: by mail-px0-f177.google.com with SMTP id 10so3802021pxi.8
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:29 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 09/10] compaction: make compaction use in-order putback
Date: Tue,  7 Jun 2011 23:38:22 +0900
Message-Id: <879964b37a406096a4fcb5d064b3f6f159b868bb.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

Compaction is good solution to get contiguous page but it makes
LRU churing which is not good. Moreover, LRU order is important
when VM has memory pressure to select right victim pages.

This patch makes that compaction code use in-order putback so
after compaction completion, migrated pages are keeping LRU ordering.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 54dbdbe..29e6aa9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -28,7 +28,7 @@
  */
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
-	struct list_head migratepages;	/* List of pages being migrated */
+	struct inorder_lru migratepages;/* List of pages being migrated */
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
@@ -210,7 +210,7 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	struct page *page;
 	unsigned int count[2] = { 0, };
 
-	list_for_each_entry(page, &cc->migratepages, lru)
+	list_for_each_migrate_entry(page, &cc->migratepages, ilru)
 		count[!!page_is_file_cache(page)]++;
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
@@ -242,7 +242,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	unsigned long low_pfn, end_pfn;
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
-	struct list_head *migratelist = &cc->migratepages;
+	struct inorder_lru *migratelist = &cc->migratepages;
 	enum ISOLATE_MODE mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
 
 	/* Do not scan outside zone boundaries */
@@ -273,7 +273,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	cond_resched();
 	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
-		struct page *page;
+		struct page *page, *prev_page;
 		bool locked = true;
 
 		/* give a chance to irqs before checking need_resched() */
@@ -331,14 +331,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
 			mode |= ISOLATE_CLEAN;
  
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode, 0, NULL) != 0)
+		if (__isolate_lru_page(page, mode, 0, &prev_page) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
 		del_page_from_lru_list(zone, page, page_lru(page));
-		list_add(&page->lru, migratelist);
+		migratelist_add(page, prev_page, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
 
@@ -394,7 +394,7 @@ static void update_nr_listpages(struct compact_control *cc)
 	int nr_freepages = 0;
 	struct page *page;
 
-	list_for_each_entry(page, &cc->migratepages, lru)
+	list_for_each_migrate_entry(page, &cc->migratepages, ilru)
 		nr_migratepages++;
 	list_for_each_entry(page, &cc->freepages, lru)
 		nr_freepages++;
@@ -522,7 +522,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			continue;
 
 		nr_migrate = cc->nr_migratepages;
-		err = migrate_pages(&cc->migratepages, compaction_alloc,
+		err = migrate_ilru_pages(&cc->migratepages,
+				compaction_alloc,
 				(unsigned long)cc, false,
 				cc->sync);
 		update_nr_listpages(cc);
@@ -537,7 +538,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		/* Release LRU pages not migrated */
 		if (err) {
-			putback_lru_pages(&cc->migratepages);
+			putback_ilru_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
 		}
 
@@ -563,7 +564,7 @@ unsigned long compact_zone_order(struct zone *zone,
 		.sync = sync,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
-	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_MIGRATE_LIST(&cc.migratepages);
 
 	return compact_zone(zone, &cc);
 }
@@ -645,12 +646,12 @@ static int compact_node(int nid)
 
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
+		INIT_MIGRATE_LIST(&cc.migratepages);
 
 		compact_zone(zone, &cc);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
-		VM_BUG_ON(!list_empty(&cc.migratepages));
+		VM_BUG_ON(!migratelist_empty(&cc.migratepages));
 	}
 
 	return 0;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
