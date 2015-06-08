Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1396B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:40 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so87285832wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lk1si1334885wic.42.2015.06.08.06.56.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:38 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/25] mm, vmscan: Move lru_lock to the node
Date: Mon,  8 Jun 2015 14:56:08 +0100
Message-Id: <1433771791-30567-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Node-based reclaim means that the we need node-based LRUs and node-based
locking.  This is a preparation patch that just moves the lru_lock to the
node as it makes later patches easier to review. It's a mechanical change
but note this patch makes contention actively worse because now the LRU
lock is hotter and direct reclaim and kswapd can contend on the same lock
even when reclaiming from different zones.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h | 10 ++++++++--
 mm/compaction.c        |  6 +++---
 mm/filemap.c           |  4 ++--
 mm/huge_memory.c       |  4 ++--
 mm/memcontrol.c        |  4 ++--
 mm/mlock.c             | 10 +++++-----
 mm/page_alloc.c        |  4 ++--
 mm/rmap.c              |  2 +-
 mm/swap.c              | 30 +++++++++++++++---------------
 mm/vmscan.c            | 42 +++++++++++++++++++++---------------------
 10 files changed, 61 insertions(+), 55 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c52a3e3f178c..4c824d6996eb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -97,7 +97,7 @@ struct free_area {
 struct pglist_data;
 
 /*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * zone->lock and the zone lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
  * cachelines.  There are very few zone structures in the machine, so space
  * consumption is not a concern here.
@@ -497,7 +497,6 @@ struct zone {
 	/* Write-intensive fields used by page reclaim */
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	/* Evictions & activations on the inactive file list */
@@ -771,6 +770,9 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/* Write-intensive fields used from the page allocator */
+	ZONE_PADDING(_pad1_)
+	spinlock_t		lru_lock;
 
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
@@ -787,6 +789,10 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
+static inline spinlock_t *zone_lru_lock(struct zone *zone)
+{
+	return &zone->zone_pgdat->lru_lock;
+}
 
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d9459b54a..e0b547953e36 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -702,7 +702,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if contended.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(&zone->lru_lock, flags,
+		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
 								&locked, cc))
 			break;
 
@@ -780,7 +780,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(&zone->lru_lock,
+			locked = compact_trylock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
 			if (!locked)
 				break;
@@ -825,7 +825,7 @@ isolate_success:
 		low_pfn = end_pfn;
 
 	if (locked)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
diff --git a/mm/filemap.c b/mm/filemap.c
index ad7242043bdb..12a47ccd8565 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -95,8 +95,8 @@
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->tree_lock		(try_to_unmap_one)
- *    ->zone.lru_lock		(follow_page->mark_page_accessed)
- *    ->zone.lru_lock		(check_pte_range->isolate_lru_page)
+ *    ->zone_lru_lock		(follow_page->mark_page_accessed)
+ *    ->zone_lru_lock		(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6817b0350c71..cdc87f90c4eb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1634,7 +1634,7 @@ static void __split_huge_page_refcount(struct page *page,
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	lruvec = mem_cgroup_page_lruvec(page, zone);
 
 	compound_lock(page);
@@ -1723,7 +1723,7 @@ static void __split_huge_page_refcount(struct page *page,
 
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b34ef4a32a3b..1e7932a5f921 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2392,7 +2392,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
@@ -2416,7 +2416,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
diff --git a/mm/mlock.c b/mm/mlock.c
index 8a54cd214925..4b5b4a0a2191 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -183,7 +183,7 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_pages = hpage_nr_pages(page);
 	if (!TestClearPageMlocked(page))
@@ -192,14 +192,14 @@ unsigned int munlock_vma_page(struct page *page)
 	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
 
 	if (__munlock_isolate_lru_page(page, true)) {
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 		__munlock_isolated_page(page);
 		goto out;
 	}
 	__munlock_isolation_failed(page);
 
 unlock_out:
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 out:
 	return nr_pages - 1;
@@ -340,7 +340,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	pagevec_init(&pvec_putback, 0);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -366,7 +366,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	}
 	delta_munlocked = -nr + pagevec_count(&pvec_putback);
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b58c27b13061..3dde181c3b8b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4933,10 +4933,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
+		zone->zone_pgdat = pgdat;
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(zone_lru_lock(zone));
 		zone_seqlock_init(zone);
-		zone->zone_pgdat = pgdat;
 		zone_pcp_init(zone);
 
 		/* For bootup, initialized properly in watermark setup */
diff --git a/mm/rmap.c b/mm/rmap.c
index c161a14b6a8f..75f1e06f3339 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -26,7 +26,7 @@
  *       mapping->i_mmap_rwsem
  *         anon_vma->rwsem
  *           mm->page_table_lock or pte_lock
- *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *             zone_lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
diff --git a/mm/swap.c b/mm/swap.c
index cd3a5e64cea9..e31761ec280c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -55,12 +55,12 @@ static void __page_cache_release(struct page *page)
 		struct lruvec *lruvec;
 		unsigned long flags;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		spin_lock_irqsave(zone_lru_lock(zone), flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 	}
 	mem_cgroup_uncharge(page);
 }
@@ -422,16 +422,16 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 
 		if (pagezone != zone) {
 			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
+			spin_lock_irqsave(zone_lru_lock(zone), flags);
 		}
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		(*move_fn)(page, lruvec, arg);
 	}
 	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -551,9 +551,9 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 #endif
 
@@ -679,13 +679,13 @@ void add_page_to_unevictable_list(struct page *page)
 	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	lruvec = mem_cgroup_page_lruvec(page, zone);
 	ClearPageActive(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 
 /**
@@ -910,7 +910,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		if (unlikely(PageCompound(page))) {
 			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 				zone = NULL;
 			}
 			put_compound_page(page);
@@ -923,7 +923,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		 * same zone. The lock is held only if zone != NULL.
 		 */
 		if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 			zone = NULL;
 		}
 
@@ -935,11 +935,11 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 			if (pagezone != zone) {
 				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
+					spin_unlock_irqrestore(zone_lru_lock(zone),
 									flags);
 				lock_batch = 0;
 				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
+				spin_lock_irqsave(zone_lru_lock(zone), flags);
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, zone);
@@ -954,7 +954,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
@@ -990,7 +990,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
+		  !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd71bac..8ebdc4e5e720 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1387,7 +1387,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(zone_lru_lock(zone));
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1396,7 +1396,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 	}
 	return ret;
 }
@@ -1455,9 +1455,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(zone_lru_lock(zone));
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(zone_lru_lock(zone));
 			continue;
 		}
 
@@ -1478,10 +1478,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irq(zone_lru_lock(zone));
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				spin_lock_irq(zone_lru_lock(zone));
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1543,7 +1543,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1558,7 +1558,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	if (nr_taken == 0)
 		return 0;
@@ -1568,7 +1568,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				&nr_writeback, &nr_immediate,
 				false);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
@@ -1585,7 +1585,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_hot_cold_page_list(&page_list, true);
@@ -1701,10 +1701,10 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irq(zone_lru_lock(zone));
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				spin_lock_irq(zone_lru_lock(zone));
 			} else
 				list_add(&page->lru, pages_to_free);
 		}
@@ -1739,7 +1739,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1751,7 +1751,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1796,7 +1796,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1808,7 +1808,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
@@ -2039,7 +2039,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2060,7 +2060,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3799,9 +3799,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		pagezone = page_zone(page);
 		if (pagezone != zone) {
 			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irq(zone_lru_lock(zone));
 			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(zone_lru_lock(zone));
 		}
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
@@ -3822,7 +3822,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	if (zone) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 	}
 }
 #endif /* CONFIG_SHMEM */
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
