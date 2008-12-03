Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB353GWi027503
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:03:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CA1945DE51
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:03:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5104945DE50
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:03:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2716D1DB8042
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:03:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 620181DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:03:15 +0900 (JST)
Date: Wed, 3 Dec 2008 14:02:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  13/21] memcg-make-zone_reclaim_stat.patch
Message-Id: <20081203140226.059cb4c2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

introduce mem_cgroup_per_zone::reclaim_stat member and its statics collecting
function.

Now, get_scan_ratio() can calculate correct value on memcg reclaim.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
 include/linux/memcontrol.h |   16 ++++++++++++++++
 mm/memcontrol.c            |   23 +++++++++++++++++++++++
 mm/swap.c                  |   14 ++++++++++++++
 mm/vmscan.c                |   27 +++++++++++++--------------
 4 files changed, 66 insertions(+), 14 deletions(-)

Index: mmotm-2.6.28-Dec02/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec02.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec02/include/linux/memcontrol.h
@@ -105,6 +105,10 @@ int mem_cgroup_inactive_anon_is_low(stru
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
+struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
+						      struct zone *zone);
+struct zone_reclaim_stat*
+mem_cgroup_get_reclaim_stat_by_page(struct page *page);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -271,6 +275,18 @@ mem_cgroup_zone_nr_pages(struct mem_cgro
 }
 
 
+static inline struct zone_reclaim_stat*
+mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
+{
+	return NULL;
+}
+
+static inline struct zone_reclaim_stat*
+mem_cgroup_get_reclaim_stat_by_page(struct page *page)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -103,6 +103,8 @@ struct mem_cgroup_per_zone {
 	 */
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
+
+	struct zone_reclaim_stat reclaim_stat;
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -458,6 +460,27 @@ unsigned long mem_cgroup_zone_nr_pages(s
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
+						      struct zone *zone)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	return &mz->reclaim_stat;
+}
+
+struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat_by_page(struct page *page)
+{
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+
+	if (!mz)
+		return NULL;
+
+	return &mz->reclaim_stat;
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
Index: mmotm-2.6.28-Dec02/mm/swap.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/swap.c
+++ mmotm-2.6.28-Dec02/mm/swap.c
@@ -158,6 +158,7 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
+	struct zone_reclaim_stat *memcg_reclaim_stat;
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
@@ -172,6 +173,12 @@ void activate_page(struct page *page)
 
 		reclaim_stat->recent_rotated[!!file]++;
 		reclaim_stat->recent_scanned[!!file]++;
+
+		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
+		if (memcg_reclaim_stat) {
+			memcg_reclaim_stat->recent_rotated[!!file]++;
+			memcg_reclaim_stat->recent_scanned[!!file]++;
+		}
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
@@ -400,6 +407,7 @@ void ____pagevec_lru_add(struct pagevec 
 	int i;
 	struct zone *zone = NULL;
 	struct zone_reclaim_stat *reclaim_stat = NULL;
+	struct zone_reclaim_stat *memcg_reclaim_stat = NULL;
 
 	VM_BUG_ON(is_unevictable_lru(lru));
 
@@ -413,6 +421,8 @@ void ____pagevec_lru_add(struct pagevec 
 				spin_unlock_irq(&zone->lru_lock);
 			zone = pagezone;
 			reclaim_stat = &zone->reclaim_stat;
+			memcg_reclaim_stat =
+				mem_cgroup_get_reclaim_stat_by_page(page);
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageActive(page));
@@ -421,9 +431,13 @@ void ____pagevec_lru_add(struct pagevec 
 		SetPageLRU(page);
 		file = is_file_lru(lru);
 		reclaim_stat->recent_scanned[file]++;
+		if (memcg_reclaim_stat)
+			memcg_reclaim_stat->recent_scanned[file]++;
 		if (is_active_lru(lru)) {
 			SetPageActive(page);
 			reclaim_stat->recent_rotated[file]++;
+			if (memcg_reclaim_stat)
+				memcg_reclaim_stat->recent_rotated[file]++;
 		}
 		add_page_to_lru_list(zone, page, lru);
 	}
Index: mmotm-2.6.28-Dec02/mm/vmscan.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/vmscan.c
+++ mmotm-2.6.28-Dec02/mm/vmscan.c
@@ -134,6 +134,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
+	if (!scan_global_lru(sc))
+		mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
+
 	return &zone->reclaim_stat;
 }
 
@@ -1141,17 +1144,14 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
 						-count[LRU_INACTIVE_ANON]);
 
-		if (scan_global_lru(sc)) {
+		if (scan_global_lru(sc))
 			zone->pages_scanned += nr_scan;
-			reclaim_stat->recent_scanned[0] +=
-						      count[LRU_INACTIVE_ANON];
-			reclaim_stat->recent_scanned[0] +=
-						      count[LRU_ACTIVE_ANON];
-			reclaim_stat->recent_scanned[1] +=
-						      count[LRU_INACTIVE_FILE];
-			reclaim_stat->recent_scanned[1] +=
-						      count[LRU_ACTIVE_FILE];
-		}
+
+		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
+		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
+		reclaim_stat->recent_scanned[1] += count[LRU_INACTIVE_FILE];
+		reclaim_stat->recent_scanned[1] += count[LRU_ACTIVE_FILE];
+
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
@@ -1209,7 +1209,7 @@ static unsigned long shrink_inactive_lis
 			SetPageLRU(page);
 			lru = page_lru(page);
 			add_page_to_lru_list(zone, page, lru);
-			if (PageActive(page) && scan_global_lru(sc)) {
+			if (PageActive(page)) {
 				int file = !!page_is_file_cache(page);
 				reclaim_stat->recent_rotated[file]++;
 			}
@@ -1284,8 +1284,8 @@ static void shrink_active_list(unsigned 
 	 */
 	if (scan_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
-		reclaim_stat->recent_scanned[!!file] += pgmoved;
 	}
+	reclaim_stat->recent_scanned[!!file] += pgmoved;
 
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
@@ -1319,8 +1319,7 @@ static void shrink_active_list(unsigned 
 	 * This helps balance scan pressure between file and anonymous
 	 * pages in get_scan_ratio.
 	 */
-	if (scan_global_lru(sc))
-		reclaim_stat->recent_rotated[!!file] += pgmoved;
+	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
 	/*
 	 * Move the pages to the [file or anon] inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
