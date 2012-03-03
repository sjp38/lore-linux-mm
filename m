Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1B9036B004D
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 04:16:55 -0500 (EST)
Received: by bkwq16 with SMTP id q16so2911098bkw.14
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 01:16:53 -0800 (PST)
Subject: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon filter
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 03 Mar 2012 13:16:48 +0400
Message-ID: <20120303091327.17599.80336.stgit@zurg>
In-Reply-To: <20120229091547.29236.28230.stgit@zurg>
References: <20120229091547.29236.28230.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch adds file/anon filter bits into isolate_mode_t,
this allows to simplify checks in __isolate_lru_page().

v2:
* use switch () instead of if ()
* fixed lumpy-reclaim isolation mode

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |    4 ++++
 include/linux/swap.h   |    2 +-
 mm/compaction.c        |    5 +++--
 mm/vmscan.c            |   49 +++++++++++++++++++++++++++++++-----------------
 4 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5f1e4ee..e60dcbd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -192,6 +192,10 @@ struct lruvec {
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
 /* Isolate for asynchronous migration */
 #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
+/* Isolate swap-backed pages */
+#define ISOLATE_ANON		((__force isolate_mode_t)0x20)
+/* Isolate file-backed pages */
+#define ISOLATE_FILE		((__force isolate_mode_t)0x40)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ba2c8d7..dc6e6a3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -254,7 +254,7 @@ static inline void lru_cache_add_file(struct page *page)
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
-extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
+extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
diff --git a/mm/compaction.c b/mm/compaction.c
index 74a8c82..cc054f7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,7 +261,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
-	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	isolate_mode_t mode = ISOLATE_ACTIVE | ISOLATE_INACTIVE |
+			      ISOLATE_FILE | ISOLATE_ANON;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -375,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode, 0) != 0)
+		if (__isolate_lru_page(page, mode) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7de3acc..cce1e14 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1029,28 +1029,35 @@ keep_lumpy:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
+int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 {
-	bool all_lru_mode;
 	int ret = -EINVAL;
 
 	/* Only take pages on the LRU. */
 	if (!PageLRU(page))
 		return ret;
 
-	all_lru_mode = (mode & (ISOLATE_ACTIVE|ISOLATE_INACTIVE)) ==
-		(ISOLATE_ACTIVE|ISOLATE_INACTIVE);
-
-	/*
-	 * When checking the active state, we need to be sure we are
-	 * dealing with comparible boolean values.  Take the logical not
-	 * of each.
-	 */
-	if (!all_lru_mode && !PageActive(page) != !(mode & ISOLATE_ACTIVE))
-		return ret;
+	switch (mode & (ISOLATE_ACTIVE | ISOLATE_INACTIVE)) {
+		case ISOLATE_ACTIVE:
+			if (!PageActive(page))
+				return ret;
+			break;
+		case ISOLATE_INACTIVE:
+			if (PageActive(page))
+				return ret;
+			break;
+	}
 
-	if (!all_lru_mode && !!page_is_file_cache(page) != file)
-		return ret;
+	switch (mode & (ISOLATE_FILE | ISOLATE_ANON)) {
+		case ISOLATE_FILE:
+			if (!page_is_file_cache(page))
+				return ret;
+			break;
+		case ISOLATE_ANON:
+			if (page_is_file_cache(page))
+				return ret;
+			break;
+	}
 
 	/*
 	 * When this function is being called for lumpy reclaim, we
@@ -1160,7 +1167,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode, file)) {
+		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
@@ -1218,7 +1225,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+			if (__isolate_lru_page(cursor_page, mode) == 0) {
 				unsigned int isolated_pages;
 
 				mem_cgroup_lru_del(cursor_page);
@@ -1503,7 +1510,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	set_reclaim_mode(priority, sc, false);
 	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
-		isolate_mode |= ISOLATE_ACTIVE;
+		isolate_mode |= ISOLATE_ACTIVE | ISOLATE_FILE | ISOLATE_ANON;
 
 	lru_add_drain();
 
@@ -1511,6 +1518,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
+	if (file)
+		isolate_mode |= ISOLATE_FILE;
+	else
+		isolate_mode |= ISOLATE_ANON;
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1677,6 +1688,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
+	if (file)
+		isolate_mode |= ISOLATE_FILE;
+	else
+		isolate_mode |= ISOLATE_ANON;
 
 	spin_lock_irq(&zone->lru_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
