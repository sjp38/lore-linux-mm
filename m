Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5F2546B026E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:22 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 07/11] mm: vmscan: convert unevictable page rescue scanner to per-memcg LRU lists
Date: Mon, 12 Sep 2011 12:57:24 +0200
Message-Id: <1315825048-3437-8-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The global per-zone LRU lists are about to go away on memcg-enabled
kernels, the unevictable page rescue scanner must be able to find its
pages on the per-memcg LRU lists.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 include/linux/memcontrol.h |    3 ++
 mm/memcontrol.c            |   11 ++++++++
 mm/vmscan.c                |   61 ++++++++++++++++++++++++++++---------------
 3 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6575931..7795b72 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -40,6 +40,9 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
+struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
+				    enum lru_list);
+
 struct mem_cgroup_iter {
 	struct zone *zone;
 	int priority;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 518f640..27d78dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -937,6 +937,17 @@ EXPORT_SYMBOL(mem_cgroup_count_vm_event);
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
index 8419e8f..bb4d8b8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3477,6 +3477,17 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 
 }
 
+/*
+ * XXX: Temporary helper to get to the last page of a mem_cgroup_zone
+ * lru list.  This will be reasonably unified in a second.
+ */
+static struct page *lru_tailpage(struct mem_cgroup_zone *mz, enum lru_list lru)
+{
+	if (!scanning_global_lru(mz))
+		return mem_cgroup_lru_to_page(mz->zone, mz->mem_cgroup, lru);
+	return lru_to_page(&mz->zone->lru[lru].list);
+}
+
 /**
  * scan_zone_unevictable_pages - check unevictable list for evictable pages
  * @zone - zone of which to scan the unevictable list
@@ -3490,32 +3501,40 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
-	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
-	unsigned long scan;
-	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
-
-	while (nr_to_scan > 0) {
-		unsigned long batch_size = min(nr_to_scan,
-						SCAN_UNEVICTABLE_BATCH_SIZE);
-
-		spin_lock_irq(&zone->lru_lock);
-		for (scan = 0;  scan < batch_size; scan++) {
-			struct page *page = lru_to_page(l_unevictable);
+	struct mem_cgroup *mem;
 
-			if (!trylock_page(page))
-				continue;
+	mem = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = mem,
+			.zone = zone,
+		};
+		unsigned long nr_to_scan;
 
-			prefetchw_prev_lru_page(page, l_unevictable, flags);
+		nr_to_scan = zone_nr_lru_pages(&mz, LRU_UNEVICTABLE);
+		while (nr_to_scan > 0) {
+			unsigned long batch_size;
+			unsigned long scan;
 
-			if (likely(PageLRU(page) && PageUnevictable(page)))
-				check_move_unevictable_page(page, zone);
+			batch_size = min(nr_to_scan,
+					 SCAN_UNEVICTABLE_BATCH_SIZE);
+			spin_lock_irq(&zone->lru_lock);
+			for (scan = 0; scan < batch_size; scan++) {
+				struct page *page;
 
-			unlock_page(page);
+				page = lru_tailpage(&mz, LRU_UNEVICTABLE);
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
+		mem = mem_cgroup_iter(NULL, mem, NULL);
+	} while (mem);
 }
 
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
