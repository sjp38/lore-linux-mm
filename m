Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 08BDC6B00EA
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:04 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:04 -0800 (PST)
Subject: [PATCH v2 07/22] mm: rename lruvec->lists into lruvec->pages_lru
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:02 +0400
Message-ID: <20120220172302.22196.91038.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is much more unique and grep-friendly name.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_inline.h |    2 +-
 include/linux/mmzone.h    |    2 +-
 mm/memcontrol.c           |    6 +++---
 mm/page_alloc.c           |    2 +-
 mm/swap.c                 |    4 ++--
 mm/vmscan.c               |    6 +++---
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 227fd3e..8415596 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -27,7 +27,7 @@ add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 	struct lruvec *lruvec;
 
 	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
-	list_add(&page->lru, &lruvec->lists[lru]);
+	list_add(&page->lru, &lruvec->pages_lru[lru]);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f10a54c..0d2e6b6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -160,7 +160,7 @@ static inline int is_unevictable_lru(enum lru_list lru)
 }
 
 struct lruvec {
-	struct list_head lists[NR_LRU_LISTS];
+	struct list_head pages_lru[NR_LRU_LISTS];
 };
 
 /* Mask used at gathering information at once (see memcontrol.c) */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe0b8fb..b65c619 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1036,7 +1036,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
  * the lruvec for the given @zone and the memcg @page is charged to.
  *
  * The callsite is then responsible for physically linking the page to
- * the returned lruvec->lists[@lru].
+ * the returned lruvec->pages_lru[@lru].
  */
 struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 				       enum lru_list lru)
@@ -3611,7 +3611,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lruvec.lists[lru];
+	list = &mz->lruvec.pages_lru[lru];
 
 	loop = mz->lru_size[lru];
 	/* give some margin against EBUSY etc...*/
@@ -4737,7 +4737,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(lru)
-			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
+			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 85517af..b75af1e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4363,7 +4363,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(lru)
-			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
+			INIT_LIST_HEAD(&zone->lruvec.pages_lru[lru]);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
diff --git a/mm/swap.c b/mm/swap.c
index 0d8845c..f57604f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -243,7 +243,7 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
 						   page, lru, lru);
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		list_move_tail(&page->lru, &lruvec->pages_lru[lru]);
 		(*pgmoved)++;
 	}
 }
@@ -556,7 +556,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 * We moves tha page into tail of inactive.
 		 */
 		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		list_move_tail(&page->lru, &lruvec->pages_lru[lru]);
 		__count_vm_event(PGROTATED);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c54a75b..7083567 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1170,7 +1170,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	src = &lruvec->lists[lru];
+	src = &lruvec->pages_lru[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1669,7 +1669,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		SetPageLRU(page);
 
 		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
-		list_move(&page->lru, &lruvec->lists[lru]);
+		list_move(&page->lru, &lruvec->pages_lru[lru]);
 		pgmoved += hpage_nr_pages(page);
 
 		if (put_page_testzero(page)) {
@@ -3583,7 +3583,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			__dec_zone_state(zone, NR_UNEVICTABLE);
 			lruvec = mem_cgroup_lru_move_lists(zone, page,
 						LRU_UNEVICTABLE, lru);
-			list_move(&page->lru, &lruvec->lists[lru]);
+			list_move(&page->lru, &lruvec->pages_lru[lru]);
 			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
 			pgrescued++;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
