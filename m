Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 24FCB6B00E7
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 13:04:21 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id q16so787924bkw.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 10:04:20 -0800 (PST)
Subject: [PATCH v5 4/7] mm: rework __isolate_lru_page() page lru filter
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 08 Mar 2012 22:04:15 +0400
Message-ID: <20120308180415.27621.23390.stgit@zurg>
In-Reply-To: <20120308175752.27621.54781.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch adds lru bit mask into lower byte of isolate_mode_t,
this allows to simplify checks in __isolate_lru_page().

v5:
* lru bit mask instead of special file/anon active/inactive bits
* mark page_lru() as __always_inline, it helps gcc generate more compact code

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

add/remove: 0/0 grow/shrink: 3/4 up/down: 35/-67 (-32)
function                                     old     new   delta
static.shrink_active_list                    837     853     +16
__isolate_lru_page                           301     317     +16
page_evictable                               170     173      +3
__remove_mapping                             322     319      -3
mem_cgroup_lru_del                            73      65      -8
static.isolate_lru_pages                    1055    1035     -20
__mem_cgroup_commit_charge                   676     640     -36
---
 include/linux/mm_inline.h |    2 +-
 include/linux/mmzone.h    |   12 +++++-------
 include/linux/swap.h      |    2 +-
 mm/compaction.c           |    4 ++--
 mm/vmscan.c               |   44 +++++++++++++++-----------------------------
 5 files changed, 24 insertions(+), 40 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 227fd3e..71e7d76 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -85,7 +85,7 @@ static inline enum lru_list page_off_lru(struct page *page)
  * Returns the LRU list a page should be on, as an index
  * into the array of LRU lists.
  */
-static inline enum lru_list page_lru(struct page *page)
+static __always_inline enum lru_list page_lru(struct page *page)
 {
 	enum lru_list lru;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aa881de..3370a8c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -183,16 +183,14 @@ struct lruvec {
 #define LRU_ALL_EVICTABLE (LRU_ALL_FILE | LRU_ALL_ANON)
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
-/* Isolate inactive pages */
-#define ISOLATE_INACTIVE	((__force isolate_mode_t)0x1)
-/* Isolate active pages */
-#define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
+/* Mask of LRU lists allowed for isolation */
+#define ISOLATE_LRU_MASK	((__force isolate_mode_t)0xFF)
 /* Isolate clean file */
-#define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
+#define ISOLATE_CLEAN		((__force isolate_mode_t)0x100)
 /* Isolate unmapped file */
-#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
+#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x200)
 /* Isolate for asynchronous migration */
-#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
+#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x400)
 
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
index 74a8c82..5b02dbd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,7 +261,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
-	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	isolate_mode_t mode = LRU_ALL_EVICTABLE;
 
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
index 9769970..0966f11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1028,36 +1028,20 @@ keep_lumpy:
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
+	/* Isolate pages only from allowed LRU lists */
+	if (!(mode & BIT(page_lru(page))))
 		return ret;
 
-	if (!all_lru_mode && !!page_is_file_cache(page) != file)
-		return ret;
-
-	/*
-	 * When this function is being called for lumpy reclaim, we
-	 * initially look into all LRU pages, active, inactive and
-	 * unevictable; only give shrink_page_list evictable pages.
-	 */
-	if (PageUnevictable(page))
-		return ret;
+	/* All possible LRU lists must fit into isolation mask area */
+	BUILD_BUG_ON(LRU_ALL & ~ISOLATE_LRU_MASK);
 
 	ret = -EBUSY;
 
@@ -1160,7 +1144,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode, file)) {
+		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
@@ -1218,7 +1202,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+			if (__isolate_lru_page(cursor_page, mode) == 0) {
 				unsigned int isolated_pages;
 
 				mem_cgroup_lru_del(cursor_page);
@@ -1492,7 +1476,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
-	isolate_mode_t isolate_mode = ISOLATE_INACTIVE;
+	isolate_mode_t isolate_mode;
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
@@ -1505,12 +1489,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	set_reclaim_mode(priority, sc, false);
-	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
-		isolate_mode |= ISOLATE_ACTIVE;
-
 	lru_add_drain();
 
+	set_reclaim_mode(priority, sc, false);
+
+	isolate_mode = BIT(lru);
+	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
+		isolate_mode |= LRU_ALL_EVICTABLE;
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
@@ -1668,12 +1653,13 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	unsigned long nr_rotated = 0;
-	isolate_mode_t isolate_mode = ISOLATE_ACTIVE;
+	isolate_mode_t isolate_mode;
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 
 	lru_add_drain();
 
+	isolate_mode = BIT(lru);
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
