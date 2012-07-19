Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6E4636B0071
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:56 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/34] mm: zone_reclaim: make isolate_lru_page() filter-aware
Date: Thu, 19 Jul 2012 15:36:24 +0100
Message-Id: <1342708604-26540-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Minchan Kim <minchan.kim@gmail.com>

commit f80c0673610e36ae29d63e3297175e22f70dde5f upstream.

Stable note: Not tracked in Bugzilla. THP and compaction disrupt the LRU list
	leading to poor reclaim decisions which has a variable performance
	impact.

In __zone_reclaim case, we don't want to shrink mapped page.  Nonetheless,
we have isolated mapped page and re-add it into LRU's head.  It's
unnecessary CPU overhead and makes LRU churning.

Of course, when we isolate the page, the page might be mapped but when we
try to migrate the page, the page would be not mapped.  So it could be
migrated.  But race is rare and although it happens, it's no big deal.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    2 ++
 mm/vmscan.c            |   20 ++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 632107e..951ed81 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -164,6 +164,8 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
 /* Isolate clean file */
 #define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
+/* Isolate unmapped file */
+#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 032f35e..9aa75e9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1048,6 +1048,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 	if ((mode & ISOLATE_CLEAN) && (PageDirty(page) || PageWriteback(page)))
 		return ret;
 
+	if ((mode & ISOLATE_UNMAPPED) && page_mapped(page))
+		return ret;
+
 	if (likely(get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
@@ -1471,6 +1474,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		reclaim_mode |= ISOLATE_ACTIVE;
 
 	lru_add_drain();
+
+	if (!sc->may_unmap)
+		reclaim_mode |= ISOLATE_UNMAPPED;
+	if (!sc->may_writepage)
+		reclaim_mode |= ISOLATE_CLEAN;
+
 	spin_lock_irq(&zone->lru_lock);
 
 	if (scanning_global_lru(sc)) {
@@ -1588,19 +1597,26 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	isolate_mode_t reclaim_mode = ISOLATE_ACTIVE;
 
 	lru_add_drain();
+
+	if (!sc->may_unmap)
+		reclaim_mode |= ISOLATE_UNMAPPED;
+	if (!sc->may_writepage)
+		reclaim_mode |= ISOLATE_CLEAN;
+
 	spin_lock_irq(&zone->lru_lock);
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_pages, &l_hold,
 						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
+						reclaim_mode, zone,
 						1, file);
 		zone->pages_scanned += pgscanned;
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
+						reclaim_mode, zone,
 						sc->mem_cgroup, 1, file);
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
