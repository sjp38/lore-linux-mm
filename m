Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2EC9C6B00A1
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:43:52 -0500 (EST)
Received: by iacb35 with SMTP id b35so33331106iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:43:51 -0800 (PST)
Date: Sat, 31 Dec 2011 23:43:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/6] mm: enum lru_list lru
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312342540.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Mostly we use "enum lru_list lru": change those few "l"s to "lru"s.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm_inline.h |   26 +++++++++++++-------------
 include/linux/mmzone.h    |   16 ++++++++--------
 mm/page_alloc.c           |    6 +++---
 mm/vmscan.c               |   22 +++++++++++-----------
 4 files changed, 35 insertions(+), 35 deletions(-)

--- mmotm.orig/include/linux/mm_inline.h	2011-12-30 21:21:34.531338585 -0800
+++ mmotm/include/linux/mm_inline.h	2011-12-31 14:49:11.044022084 -0800
@@ -22,21 +22,21 @@ static inline int page_is_file_cache(str
 }
 
 static inline void
-add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
 	struct lruvec *lruvec;
 
-	lruvec = mem_cgroup_lru_add_list(zone, page, l);
-	list_add(&page->lru, &lruvec->lists[l]);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
+	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+	list_add(&page->lru, &lruvec->lists[lru]);
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
 }
 
 static inline void
-del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	mem_cgroup_lru_del_list(page, l);
+	mem_cgroup_lru_del_list(page, lru);
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
 }
 
 /**
@@ -57,21 +57,21 @@ static inline enum lru_list page_lru_bas
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
-	enum lru_list l;
+	enum lru_list lru;
 
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
-		l = LRU_UNEVICTABLE;
+		lru = LRU_UNEVICTABLE;
 	} else {
-		l = page_lru_base_type(page);
+		lru = page_lru_base_type(page);
 		if (PageActive(page)) {
 			__ClearPageActive(page);
-			l += LRU_ACTIVE;
+			lru += LRU_ACTIVE;
 		}
 	}
-	mem_cgroup_lru_del_list(page, l);
+	mem_cgroup_lru_del_list(page, lru);
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
 }
 
 /**
--- mmotm.orig/include/linux/mmzone.h	2011-12-30 21:21:34.531338585 -0800
+++ mmotm/include/linux/mmzone.h	2011-12-31 14:49:11.044022084 -0800
@@ -140,23 +140,23 @@ enum lru_list {
 	NR_LRU_LISTS
 };
 
-#define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
+#define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
 
-#define for_each_evictable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
 
-static inline int is_file_lru(enum lru_list l)
+static inline int is_file_lru(enum lru_list lru)
 {
-	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE);
+	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
 }
 
-static inline int is_active_lru(enum lru_list l)
+static inline int is_active_lru(enum lru_list lru)
 {
-	return (l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE);
+	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
 }
 
-static inline int is_unevictable_lru(enum lru_list l)
+static inline int is_unevictable_lru(enum lru_list lru)
 {
-	return (l == LRU_UNEVICTABLE);
+	return (lru == LRU_UNEVICTABLE);
 }
 
 struct lruvec {
--- mmotm.orig/mm/page_alloc.c	2011-12-30 21:21:34.531338585 -0800
+++ mmotm/mm/page_alloc.c	2011-12-31 14:49:11.048022293 -0800
@@ -4275,7 +4275,7 @@ static void __paginginit free_area_init_
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
-		enum lru_list l;
+		enum lru_list lru;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -4325,8 +4325,8 @@ static void __paginginit free_area_init_
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		for_each_lru(l)
-			INIT_LIST_HEAD(&zone->lruvec.lists[l]);
+		for_each_lru(lru)
+			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
--- mmotm.orig/mm/vmscan.c	2011-12-31 14:36:24.704004318 -0800
+++ mmotm/mm/vmscan.c	2011-12-31 14:49:11.048022293 -0800
@@ -1920,7 +1920,7 @@ static void get_scan_count(struct mem_cg
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	u64 fraction[2], denominator;
-	enum lru_list l;
+	enum lru_list lru;
 	int noswap = 0;
 	bool force_scan = false;
 
@@ -2010,18 +2010,18 @@ static void get_scan_count(struct mem_cg
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
-	for_each_evictable_lru(l) {
-		int file = is_file_lru(l);
+	for_each_evictable_lru(lru) {
+		int file = is_file_lru(lru);
 		unsigned long scan;
 
-		scan = zone_nr_lru_pages(mz, l);
+		scan = zone_nr_lru_pages(mz, lru);
 		if (priority || noswap) {
 			scan >>= priority;
 			if (!scan && force_scan)
 				scan = SWAP_CLUSTER_MAX;
 			scan = div64_u64(scan * fraction[file], denominator);
 		}
-		nr[l] = scan;
+		nr[lru] = scan;
 	}
 }
 
@@ -2097,7 +2097,7 @@ static void shrink_mem_cgroup_zone(int p
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
-	enum lru_list l;
+	enum lru_list lru;
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
@@ -2110,13 +2110,13 @@ restart:
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-		for_each_evictable_lru(l) {
-			if (nr[l]) {
+		for_each_evictable_lru(lru) {
+			if (nr[lru]) {
 				nr_to_scan = min_t(unsigned long,
-						   nr[l], SWAP_CLUSTER_MAX);
-				nr[l] -= nr_to_scan;
+						   nr[lru], SWAP_CLUSTER_MAX);
+				nr[lru] -= nr_to_scan;
 
-				nr_reclaimed += shrink_list(l, nr_to_scan,
+				nr_reclaimed += shrink_list(lru, nr_to_scan,
 							    mz, sc, priority);
 			}
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
