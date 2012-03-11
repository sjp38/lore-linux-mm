Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 32D216B0044
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 10:36:21 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2893079bkw.14
        for <linux-mm@kvack.org>; Sun, 11 Mar 2012 07:36:19 -0700 (PDT)
Subject: [PATCH v5 4.5/7] mm: optimize isolate_lru_pages()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sun, 11 Mar 2012 18:36:16 +0400
Message-ID: <20120311141334.29756.79407.stgit@zurg>
In-Reply-To: <20120308175752.27621.54781.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch moves lru checks from __isolate_lru_page() to its callers.

They aren't required on non-lumpy reclaim: all pages are came from right lru.
Pages isolation on memory compaction should skip only unevictable pages.
Thus we need to check page lru only on pages isolation for lumpy-reclaim.

Plus this patch kills mem_cgroup_lru_del() and uses mem_cgroup_lru_del_list()
instead, because now we already have lru list index.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

add/remove: 0/1 grow/shrink: 2/1 up/down: 101/-164 (-63)
function                                     old     new   delta
static.isolate_lru_pages                    1018    1103     +85
compact_zone                                2230    2246     +16
mem_cgroup_lru_del                            65       -     -65
__isolate_lru_page                           287     188     -99
---
 include/linux/memcontrol.h |    5 -----
 mm/compaction.c            |    3 ++-
 mm/memcontrol.c            |    5 -----
 mm/vmscan.c                |   38 +++++++++++++++++---------------------
 4 files changed, 19 insertions(+), 32 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4c4b968..8af2a61 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -66,7 +66,6 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
 				       enum lru_list);
 void mem_cgroup_lru_del_list(struct page *, enum lru_list);
-void mem_cgroup_lru_del(struct page *);
 struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
 					 enum lru_list, enum lru_list);
 
@@ -259,10 +258,6 @@ static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 {
 }
 
-static inline void mem_cgroup_lru_del(struct page *page)
-{
-}
-
 static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
 						       struct page *page,
 						       enum lru_list from,
diff --git a/mm/compaction.c b/mm/compaction.c
index 5b02dbd..c2e783d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -358,7 +358,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
-		if (!PageLRU(page))
+		/* Isolate only evictable pages */
+		if (!PageLRU(page) || PageUnevictable(page))
 			continue;
 
 		/*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6864f57..6f62621 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1095,11 +1095,6 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 	mz->lru_size[lru] -= 1 << compound_order(page);
 }
 
-void mem_cgroup_lru_del(struct page *page)
-{
-	mem_cgroup_lru_del_list(page, page_lru(page));
-}
-
 /**
  * mem_cgroup_lru_move_lists - account for moving a page between lrus
  * @zone: zone of the page
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0966f11..6a13a05 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1030,21 +1030,11 @@ keep_lumpy:
  */
 int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 {
-	int ret = -EINVAL;
-
-	/* Only take pages on the LRU. */
-	if (!PageLRU(page))
-		return ret;
-
-	/* Isolate pages only from allowed LRU lists */
-	if (!(mode & BIT(page_lru(page))))
-		return ret;
+	int ret = -EBUSY;
 
 	/* All possible LRU lists must fit into isolation mask area */
 	BUILD_BUG_ON(LRU_ALL & ~ISOLATE_LRU_MASK);
 
-	ret = -EBUSY;
-
 	/*
 	 * To minimise LRU disruption, the caller can indicate that it only
 	 * wants to isolate pages it will be able to operate on without
@@ -1143,21 +1133,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON(!PageLRU(page));
+		VM_BUG_ON(page_lru(page) != lru);
 
-		switch (__isolate_lru_page(page, mode)) {
-		case 0:
-			mem_cgroup_lru_del(page);
+		if (__isolate_lru_page(page, mode) == 0) {
+			mem_cgroup_lru_del_list(page, lru);
 			list_move(&page->lru, dst);
 			nr_taken += hpage_nr_pages(page);
-			break;
-
-		case -EBUSY:
+		} else {
 			/* else it is being freed elsewhere */
 			list_move(&page->lru, src);
 			continue;
-
-		default:
-			BUG();
 		}
 
 		if (!sc->order || !(sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
@@ -1178,6 +1163,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		end_pfn = pfn + (1 << sc->order);
 		for (; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
+			enum lru_list cursor_lru;
 
 			/* The target page is in the block, ignore it. */
 			if (unlikely(pfn == page_pfn))
@@ -1202,10 +1188,19 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
+			if (!PageLRU(cursor_page))
+				goto skip_free;
+
+			/* Isolate pages only from allowed LRU lists */
+			cursor_lru = page_lru(cursor_page);
+			if (!(mode & BIT(cursor_lru)))
+				goto skip_free;
+
 			if (__isolate_lru_page(cursor_page, mode) == 0) {
 				unsigned int isolated_pages;
 
-				mem_cgroup_lru_del(cursor_page);
+				mem_cgroup_lru_del_list(cursor_page,
+							cursor_lru);
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
 				nr_taken += isolated_pages;
@@ -1227,6 +1222,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				 * track the head status without a
 				 * page pin.
 				 */
+skip_free:
 				if (!PageTail(cursor_page) &&
 				    !atomic_read(&cursor_page->_count))
 					continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
