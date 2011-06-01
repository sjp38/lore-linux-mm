Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD856B0027
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:54 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
Date: Wed,  1 Jun 2011 08:25:18 +0200
Message-Id: <1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Once the per-memcg lru lists are exclusive, the unevictable page
rescue scanner can no longer work on the global zone lru lists.

This converts it to go through all memcgs and scan their respective
unevictable lists instead.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    2 +
 mm/memcontrol.c            |   11 +++++++++
 mm/vmscan.c                |   53 +++++++++++++++++++++++++++----------------
 3 files changed, 46 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cb02c00..56c1def 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -60,6 +60,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
+struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
+				    enum lru_list);
 extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
 extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
 extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 78ae4dd..d9d1a7e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -656,6 +656,17 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
  * When moving account, the page is not on LRU. It's isolated.
  */
 
+struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *mem,
+				    enum lru_list lru)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
+	pc = list_entry(mz->lists[lru].prev, struct page_cgroup, lru);
+	return lookup_cgroup_page(pc);
+}
+
 void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c51ec8..23fd2b1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3233,6 +3233,14 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 
 }
 
+static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup *mem,
+				 enum lru_list lru)
+{
+	if (mem)
+		return mem_cgroup_lru_to_page(zone, mem, lru);
+	return lru_to_page(&zone->lru[lru].list);
+}
+
 /**
  * scan_zone_unevictable_pages - check unevictable list for evictable pages
  * @zone - zone of which to scan the unevictable list
@@ -3246,32 +3254,37 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
-	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
-	unsigned long scan;
-	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
+	struct mem_cgroup *first, *mem = NULL;
 
-	while (nr_to_scan > 0) {
-		unsigned long batch_size = min(nr_to_scan,
-						SCAN_UNEVICTABLE_BATCH_SIZE);
+	first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
+	do {
+		unsigned long nr_to_scan;
 
-		spin_lock_irq(&zone->lru_lock);
-		for (scan = 0;  scan < batch_size; scan++) {
-			struct page *page = lru_to_page(l_unevictable);
+		nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
+		while (nr_to_scan > 0) {
+			unsigned long batch_size;
+			unsigned long scan;
 
-			if (!trylock_page(page))
-				continue;
+			batch_size = min(nr_to_scan,
+					 SCAN_UNEVICTABLE_BATCH_SIZE);
 
-			prefetchw_prev_lru_page(page, l_unevictable, flags);
-
-			if (likely(PageLRU(page) && PageUnevictable(page)))
-				check_move_unevictable_page(page, zone);
+			spin_lock_irq(&zone->lru_lock);
+			for (scan = 0; scan < batch_size; scan++) {
+				struct page *page;
 
-			unlock_page(page);
+				page = lru_tailpage(zone, mem, LRU_UNEVICTABLE);
+				if (!trylock_page(page))
+					continue;
+				if (likely(PageLRU(page) &&
+					   PageUnevictable(page)))
+					check_move_unevictable_page(page, zone);
+				unlock_page(page);
+			}
+			spin_unlock_irq(&zone->lru_lock);
+			nr_to_scan -= batch_size;
 		}
-		spin_unlock_irq(&zone->lru_lock);
-
-		nr_to_scan -= batch_size;
-	}
+		mem = mem_cgroup_hierarchy_walk(NULL, mem);
+	} while (mem != first);
 }
 
 
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
