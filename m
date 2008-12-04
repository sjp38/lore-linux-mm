Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB48Hj4c010227
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 17:17:45 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A8A145DD81
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:17:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C05745DD78
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:17:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 005F1E08001
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:17:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D0F1DB8038
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:17:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH] memcg: memcg reclaim stat trivial fixes
In-Reply-To: <20081204170937.1D7A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081204170937.1D7A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081204171605.1D7D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 17:17:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

applied after: memcg-add-zone_reclaim_stat.patch

Andrew, if you like folded patch instead incremental patch, 
please let me know it.


==
This patch has three trivial fixes.

 - rename mem_cgroup_get_reclaim_stat_by_page to mem_cgroup_get_reclaim_stat_from_page
 - repair silly forgotten "return" in get_reclaim_stat()
 - make update_zone_reclaim_stat() helper function for cleanup


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/linux/memcontrol.h |    4 +--
 mm/memcontrol.c            |    3 +-
 mm/swap.c                  |   48 +++++++++++++++++++++++----------------------
 mm/vmscan.c                |    2 -
 4 files changed, 30 insertions(+), 27 deletions(-)

Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -108,7 +108,7 @@ unsigned long mem_cgroup_zone_nr_pages(s
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_by_page(struct page *page);
+mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -282,7 +282,7 @@ mem_cgroup_get_reclaim_stat(struct mem_c
 }
 
 static inline struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_by_page(struct page *page)
+mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
 	return NULL;
 }
Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -470,7 +470,8 @@ struct zone_reclaim_stat *mem_cgroup_get
 	return &mz->reclaim_stat;
 }
 
-struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat_by_page(struct page *page)
+struct zone_reclaim_stat *
+mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -151,14 +151,32 @@ void  rotate_reclaimable_page(struct pag
 	}
 }
 
+static void update_page_reclaim_stat(struct zone *zone, struct page *page,
+				     int file, int rotated)
+{
+	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
+	struct zone_reclaim_stat *memcg_reclaim_stat;
+
+	memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_from_page(page);
+
+	reclaim_stat->recent_scanned[file]++;
+	if (rotated)
+		reclaim_stat->recent_rotated[file]++;
+
+	if (!memcg_reclaim_stat)
+		return;
+
+	memcg_reclaim_stat->recent_scanned[file]++;
+	if (rotated)
+		memcg_reclaim_stat->recent_rotated[file]++;
+}
+
 /*
  * FIXME: speed this up?
  */
 void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
-	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
-	struct zone_reclaim_stat *memcg_reclaim_stat;
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
@@ -171,14 +189,7 @@ void activate_page(struct page *page)
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		reclaim_stat->recent_rotated[!!file]++;
-		reclaim_stat->recent_scanned[!!file]++;
-
-		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
-		if (memcg_reclaim_stat) {
-			memcg_reclaim_stat->recent_rotated[!!file]++;
-			memcg_reclaim_stat->recent_scanned[!!file]++;
-		}
+		update_page_reclaim_stat(zone, page, !!file, 1);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
@@ -406,8 +417,6 @@ void ____pagevec_lru_add(struct pagevec 
 {
 	int i;
 	struct zone *zone = NULL;
-	struct zone_reclaim_stat *reclaim_stat = NULL;
-	struct zone_reclaim_stat *memcg_reclaim_stat = NULL;
 
 	VM_BUG_ON(is_unevictable_lru(lru));
 
@@ -415,30 +424,23 @@ void ____pagevec_lru_add(struct pagevec 
 		struct page *page = pvec->pages[i];
 		struct zone *pagezone = page_zone(page);
 		int file;
+		int active;
 
 		if (pagezone != zone) {
 			if (zone)
 				spin_unlock_irq(&zone->lru_lock);
 			zone = pagezone;
-			reclaim_stat = &zone->reclaim_stat;
-			memcg_reclaim_stat =
-				mem_cgroup_get_reclaim_stat_by_page(page);
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageActive(page));
 		VM_BUG_ON(PageUnevictable(page));
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
+		active = is_active_lru(lru);
 		file = is_file_lru(lru);
-		reclaim_stat->recent_scanned[file]++;
-		if (memcg_reclaim_stat)
-			memcg_reclaim_stat->recent_scanned[file]++;
-		if (is_active_lru(lru)) {
+		if (active)
 			SetPageActive(page);
-			reclaim_stat->recent_rotated[file]++;
-			if (memcg_reclaim_stat)
-				memcg_reclaim_stat->recent_rotated[file]++;
-		}
+		update_page_reclaim_stat(zone, page, file, active);
 		add_page_to_lru_list(zone, page, lru);
 	}
 	if (zone)
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -135,7 +135,7 @@ static struct zone_reclaim_stat *get_rec
 						  struct scan_control *sc)
 {
 	if (!scan_global_lru(sc))
-		mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
+		return mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
 
 	return &zone->reclaim_stat;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
