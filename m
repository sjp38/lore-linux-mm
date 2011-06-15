Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 323136B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 23:08:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V1 2/2] Move the lru_lock into the lruvec struct.
Date: Tue, 14 Jun 2011 20:08:11 -0700
Message-Id: <1308107291-2909-3-git-send-email-yinghan@google.com>
In-Reply-To: <1308107291-2909-1-git-send-email-yinghan@google.com>
References: <1308107291-2909-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The lruvec structure is introduced as part of Johannes patchset. It
exists for both global zone and per-memcg-per-zone struct. All the
lru operations are done in generic code after this addition.

It is straight-forward to move the lru_lock within the struct.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    4 ++--
 include/linux/mm_types.h   |    2 +-
 include/linux/mmzone.h     |    8 ++++----
 mm/memcontrol.c            |   23 +++++++++++------------
 mm/page_alloc.c            |    2 +-
 mm/rmap.c                  |    2 +-
 mm/swap.c                  |    2 +-
 mm/vmscan.c                |    8 ++++----
 8 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 505f9a13..5df371b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -387,13 +387,13 @@ static inline spinlock_t *page_lru_lock(struct page *page)
 	struct zone *zone;
 
 	zone = page_zone(page);
-	return &zone->lru_lock;
+	return &zone->lruvec.lru_lock;
 }
 
 static inline spinlock_t *
 mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone)
 {
-	return &zone->lru_lock;
+	return &zone->lruvec.lru_lock;
 }
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 27c498b..7f303f9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -73,7 +73,7 @@ struct page {
 		void *freelist;		/* SLUB: freelist req. slab lock */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
+					 * protected by lruvec.lru_lock !
 					 */
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4840238..1e1388c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -62,10 +62,10 @@ struct free_area {
 struct pglist_data;
 
 /*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * zone->lock and lruvec.lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
- * cachelines.  There are very few zone structures in the machine, so space
- * consumption is not a concern here.
+ * cachelines.  There are very few zone structures in the machine, so
+ * space consumption is not a concern here.
  */
 #if defined(CONFIG_SMP)
 struct zone_padding {
@@ -160,6 +160,7 @@ static inline int is_unevictable_lru(enum lru_list l)
 
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
+	spinlock_t lru_lock;
 };
 
 enum zone_watermarks {
@@ -343,7 +344,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	struct zone_reclaim_stat reclaim_stat;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f18669b..925a2e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -144,7 +144,6 @@ struct mem_cgroup_stat_cpu {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	spinlock_t lru_lock;
 	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
@@ -737,7 +736,7 @@ spinlock_t *page_lru_lock(struct page *page)
 
 	zone = page_zone(page);
 	if (mem_cgroup_disabled())
-		return &zone->lru_lock;
+		return &zone->lruvec.lru_lock;
 
 	pc = lookup_page_cgroup(page);
 
@@ -751,7 +750,7 @@ spinlock_t *page_lru_lock(struct page *page)
 
 	mz = page_cgroup_zoneinfo(mem, page);
 
-	return &mz->lru_lock;
+	return &mz->lruvec.lru_lock;
 }
 
 spinlock_t *mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone)
@@ -760,12 +759,12 @@ spinlock_t *mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone)
 	int nid, zid;
 
 	if (mem_cgroup_disabled())
-		return &zone->lru_lock;
+		return &zone->lruvec.lru_lock;
 
 	nid = zone_to_nid(zone);
 	zid = zone_idx(zone);
 	mz = mem_cgroup_zoneinfo(mem, nid, zid);
-	return &mz->lru_lock;
+	return &mz->lruvec.lru_lock;
 }
 
 /**
@@ -920,7 +919,7 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
  * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
  * while it's linked to lru because the page may be reused after it's fully
  * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
- * It's done under lock_page and expected that zone->lru_lock isnever held.
+ * It's done under lock_page and expected that lruvec.lru_lock is never held.
  */
 static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
@@ -2218,7 +2217,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 			(1 << PCG_ACCT_LRU) | (1 << PCG_MIGRATION))
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone->lru_lock, 'splitting on pmd' and compund_lock.
+ * lruvec.lru_lock, 'splitting on pmd' and compund_lock.
  */
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
 {
@@ -3313,19 +3312,19 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		spin_lock_irqsave(&mz->lruvec.lru_lock, flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 
 		pc = lookup_page_cgroup(page);
 
@@ -4378,7 +4377,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	mem->info.nodeinfo[node] = pn;
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		spin_lock_init(&mz->lru_lock);
+		spin_lock_init(&mz->lruvec.lru_lock);
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8992e1..fbd47b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4316,7 +4316,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->lruvec.lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 4a726e0..a94e8d0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -27,7 +27,7 @@
  *       mapping->i_mmap_mutex
  *         anon_vma->mutex
  *           mm->page_table_lock or pte_lock
- *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *             lruvec.lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
diff --git a/mm/swap.c b/mm/swap.c
index dce5871..2904547 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -560,7 +560,7 @@ int lru_add_drain_all(void)
  * passed pages.  If it fell to zero then remove the page from the LRU and
  * free it.
  *
- * Avoid taking zone->lru_lock if possible, but if it is taken, retain it
+ * Avoid taking lruvec.lru_lock if possible, but if it is taken, retain it
  * for the remainder of the operation.
  *
  * The locking in this function is against shrink_inactive_list(): we recheck
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b132cc2..215bb17 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1050,7 +1050,7 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 }
 
 /*
- * zone->lru_lock is heavily contended.  Some of the functions that
+ * lruvec.lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -1520,9 +1520,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone->lru_lock across the whole operation.  But if
+ * appropriate to hold lruvec.lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balance
+ * should drop lruvec.lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
@@ -3228,7 +3228,7 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  * Checks a page for evictability and moves the page to the appropriate
  * zone lru list.
  *
- * Restrictions: zone->lru_lock must be held, page must be on LRU and must
+ * Restrictions: lruvec.lru_lock must be held, page must be on LRU and must
  * have PageUnevictable set.
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
