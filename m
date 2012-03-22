Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 293BC6B00E9
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:39 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:38 -0700 (PDT)
Subject: [PATCH v6 5/7] mm: remove lru type checks from __isolate_lru_page()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:35 +0400
Message-ID: <20120322215635.27814.30008.stgit@zurg>
In-Reply-To: <20120322214944.27814.42039.stgit@zurg>
References: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

After patch "mm: forbid lumpy-reclaim in shrink_active_list()" we can completely
remove anon/file and active/inactive lru type filters from __isolate_lru_page(),
because isolation for 0-order reclaim always isolates pages from right lru list.
And pages-isolation for lumpy shrink_inactive_list() or memory-compaction anyway
allowed to isolate pages from all evictable lru lists.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>

---

add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-148 (-148)
function                                     old     new   delta
shrink_inactive_list                        1259    1243     -16
__isolate_lru_page                           301     253     -48
static.isolate_lru_pages                    1055     971     -84
---
 include/linux/mmzone.h |   10 +++-------
 include/linux/swap.h   |    2 +-
 mm/compaction.c        |    4 ++--
 mm/vmscan.c            |   27 +++++----------------------
 4 files changed, 11 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9316931..71d81b0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -183,16 +183,12 @@ struct lruvec {
 #define LRU_ALL_EVICTABLE (LRU_ALL_FILE | LRU_ALL_ANON)
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
-/* Isolate inactive pages */
-#define ISOLATE_INACTIVE	((__force isolate_mode_t)0x1)
-/* Isolate active pages */
-#define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
 /* Isolate clean file */
-#define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
+#define ISOLATE_CLEAN		((__force isolate_mode_t)0x1)
 /* Isolate unmapped file */
-#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
+#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
-#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
+#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x4)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b86b5c2..bef952f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -248,7 +248,7 @@ static inline void lru_cache_add_file(struct page *page)
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
-extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
+extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
diff --git a/mm/compaction.c b/mm/compaction.c
index 74a8c82..dd2fea5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,7 +261,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
-	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	isolate_mode_t mode = 0;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -375,7 +375,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode, 0) != 0)
+		if (__isolate_lru_page(page, mode) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fb6d54e..5f6ed98 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1028,29 +1028,14 @@ keep_lumpy:
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
-
-	if (!all_lru_mode && !!page_is_file_cache(page) != file)
-		return ret;
-
 	/*
 	 * When this function is being called for lumpy reclaim, we
 	 * initially look into all LRU pages, active, inactive and
@@ -1160,7 +1145,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode, file)) {
+		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
@@ -1218,7 +1203,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+			if (__isolate_lru_page(cursor_page, mode) == 0) {
 				unsigned int isolated_pages;
 
 				mem_cgroup_lru_del(cursor_page);
@@ -1492,7 +1477,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
-	isolate_mode_t isolate_mode = ISOLATE_INACTIVE;
+	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
@@ -1506,8 +1491,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	}
 
 	set_reclaim_mode(priority, sc, false);
-	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
-		isolate_mode |= ISOLATE_ACTIVE;
 
 	lru_add_drain();
 
@@ -1668,7 +1651,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	unsigned long nr_rotated = 0;
-	isolate_mode_t isolate_mode = ISOLATE_ACTIVE;
+	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
