Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A21B96B025E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:05:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k192so20745569lfb.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:05:16 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id f5si9109514wje.247.2016.06.09.11.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 11:05:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 88E891C1F36
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:05:14 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/27] mm, vmscan: Move lru_lock to the node
Date: Thu,  9 Jun 2016 19:04:18 +0100
Message-Id: <1465495483-11855-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Node-based reclaim requires node-based LRUs and locking. This is a
preparation patch that just moves the lru_lock to the node so later patches
are easier to review. It is a mechanical change but note this patch makes
contention worse because the LRU lock is hotter and direct reclaim and kswapd
can contend on the same lock even when reclaiming from different zones.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroup-v1/memcg_test.txt |  4 +--
 Documentation/cgroup-v1/memory.txt     |  4 +--
 include/linux/mm_types.h               |  2 +-
 include/linux/mmzone.h                 | 10 +++++--
 mm/compaction.c                        | 10 +++----
 mm/filemap.c                           |  4 +--
 mm/huge_memory.c                       |  4 +--
 mm/memcontrol.c                        |  6 ++---
 mm/mlock.c                             | 10 +++----
 mm/page_alloc.c                        |  4 +--
 mm/page_idle.c                         |  4 +--
 mm/rmap.c                              |  2 +-
 mm/swap.c                              | 30 ++++++++++-----------
 mm/vmscan.c                            | 48 +++++++++++++++++-----------------
 14 files changed, 74 insertions(+), 68 deletions(-)

diff --git a/Documentation/cgroup-v1/memcg_test.txt b/Documentation/cgroup-v1/memcg_test.txt
index 8870b0212150..78a8c2963b38 100644
--- a/Documentation/cgroup-v1/memcg_test.txt
+++ b/Documentation/cgroup-v1/memcg_test.txt
@@ -107,9 +107,9 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 
 8. LRU
         Each memcg has its own private LRU. Now, its handling is under global
-	VM's control (means that it's handled under global zone->lru_lock).
+	VM's control (means that it's handled under global zone_lru_lock).
 	Almost all routines around memcg's LRU is called by global LRU's
-	list management functions under zone->lru_lock().
+	list management functions under zone_lru_lock().
 
 	A special function is mem_cgroup_isolate_pages(). This scans
 	memcg's private LRU and call __isolate_lru_page() to extract a page
diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index b14abf217239..946e69103cdd 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
    Other lock order is following:
    PG_locked.
    mm->page_table_lock
-       zone->lru_lock
+       zone_lru_lock
 	  lock_page_cgroup.
   In many cases, just lock_page_cgroup() is called.
   per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
-  zone->lru_lock, it has no lock of its own.
+  zone_lru_lock, it has no lock of its own.
 
 2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d3285b..ca2ed9a6c8d8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -118,7 +118,7 @@ struct page {
 	 */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
+					 * protected by zone_lru_lock !
 					 * Can be used as a generic list
 					 * by the page owner.
 					 */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b299c3af798e..70623b6ac833 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -93,7 +93,7 @@ struct free_area {
 struct pglist_data;
 
 /*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * zone->lock and the zone lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
  * cachelines.  There are very few zone structures in the machine, so space
  * consumption is not a concern here.
@@ -494,7 +494,6 @@ struct zone {
 	/* Write-intensive fields used by page reclaim */
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	/*
@@ -688,6 +687,9 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/* Write-intensive fields used from the page allocator */
+	ZONE_PADDING(_pad1_)
+	spinlock_t		lru_lock;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	/*
@@ -719,6 +721,10 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
+static inline spinlock_t *zone_lru_lock(struct zone *zone)
+{
+	return &zone->zone_pgdat->lru_lock;
+}
 
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index fbb7b38bc0be..5aba9e6c1975 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -754,7 +754,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if contended.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(&zone->lru_lock, flags,
+		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
 								&locked, cc))
 			break;
 
@@ -816,7 +816,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (unlikely(__PageMovable(page)) &&
 					!PageIsolated(page)) {
 				if (locked) {
-					spin_unlock_irqrestore(&zone->lru_lock,
+					spin_unlock_irqrestore(zone_lru_lock(zone),
 									flags);
 					locked = false;
 				}
@@ -839,7 +839,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(&zone->lru_lock,
+			locked = compact_trylock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
 			if (!locked)
 				break;
@@ -902,7 +902,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (nr_isolated) {
 			if (locked) {
-				spin_unlock_irqrestore(&zone->lru_lock,	flags);
+				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 				locked = false;
 			}
 			acct_isolated(zone, cc);
@@ -930,7 +930,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		low_pfn = end_pfn;
 
 	if (locked)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
diff --git a/mm/filemap.c b/mm/filemap.c
index 00ae878b2a38..bce091ed90d7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -95,8 +95,8 @@
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->tree_lock		(try_to_unmap_one)
- *    ->zone.lru_lock		(follow_page->mark_page_accessed)
- *    ->zone.lru_lock		(check_pte_range->isolate_lru_page)
+ *    ->zone_lru_lock(zone)	(follow_page->mark_page_accessed)
+ *    ->zone_lru_lock(zone)	(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55ad87c80e0a..8d535b778ead 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3300,7 +3300,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	int i;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
 	/* complete memcg works before add pages to LRU */
@@ -3310,7 +3310,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 		__split_huge_page_tail(head, i, lruvec, list);
 
 	ClearPageCompound(head);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	unfreeze_page(head);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 83a6a2b92301..605e8b5fc0db 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2107,7 +2107,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
@@ -2131,7 +2131,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
@@ -2431,7 +2431,7 @@ void memcg_kmem_uncharge(struct page *page, int order)
 
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone->lru_lock and migration entries setup in all page mappings.
+ * zone_lru_lock and migration entries setup in all page mappings.
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
diff --git a/mm/mlock.c b/mm/mlock.c
index ef8dc9f395c4..997f63082ff5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -188,7 +188,7 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_pages = hpage_nr_pages(page);
 	if (!TestClearPageMlocked(page))
@@ -197,14 +197,14 @@ unsigned int munlock_vma_page(struct page *page)
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
@@ -289,7 +289,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	pagevec_init(&pvec_putback, 0);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -315,7 +315,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	}
 	delta_munlocked = -nr + pagevec_count(&pvec_putback);
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d71af25acf9..1e0ad06c33bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5944,10 +5944,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
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
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 4ea9c4ef5146..ae11aa914e55 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -41,12 +41,12 @@ static struct page *page_idle_get_page(unsigned long pfn)
 		return NULL;
 
 	zone = page_zone(page);
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (unlikely(!PageLRU(page))) {
 		put_page(page);
 		page = NULL;
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 	return page;
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 0ea5d9071b32..67457f691528 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -27,7 +27,7 @@
  *         mapping->i_mmap_rwsem
  *           anon_vma->rwsem
  *             mm->page_table_lock or pte_lock
- *               zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *               zone_lru_lock (in mark_page_accessed, isolate_lru_page)
  *               swap_lock (in swap_duplicate, swap_info_get)
  *                 mmlist_lock (in mmput, drain_mmlist and others)
  *                 mapping->private_lock (in __set_page_dirty_buffers)
diff --git a/mm/swap.c b/mm/swap.c
index 59f5fafa6e1f..1aca06977a0a 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -62,12 +62,12 @@ static void __page_cache_release(struct page *page)
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
@@ -189,16 +189,16 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 
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
@@ -316,9 +316,9 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 #endif
 
@@ -447,13 +447,13 @@ void add_page_to_unevictable_list(struct page *page)
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
@@ -743,7 +743,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		 * same zone. The lock is held only if zone != NULL.
 		 */
 		if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 			zone = NULL;
 		}
 
@@ -758,7 +758,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		if (PageCompound(page)) {
 			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 				zone = NULL;
 			}
 			__put_compound_page(page);
@@ -770,11 +770,11 @@ void release_pages(struct page **pages, int nr, bool cold)
 
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
@@ -789,7 +789,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
@@ -825,7 +825,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
+		  !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 93ba33789ac6..e5c577c40ff9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1343,7 +1343,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 }
 
 /*
- * zone->lru_lock is heavily contended.  Some of the functions that
+ * zone_lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -1438,7 +1438,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(zone_lru_lock(zone));
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1447,7 +1447,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 	}
 	return ret;
 }
@@ -1506,9 +1506,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
 
@@ -1529,10 +1529,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
@@ -1594,7 +1594,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1610,7 +1610,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	if (nr_taken == 0)
 		return 0;
@@ -1620,7 +1620,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				&nr_writeback, &nr_immediate,
 				false);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	if (global_reclaim(sc)) {
 		if (current_is_kswapd())
@@ -1635,7 +1635,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_hot_cold_page_list(&page_list, true);
@@ -1709,9 +1709,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone->lru_lock across the whole operation.  But if
+ * appropriate to hold zone_lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balance
+ * should drop zone_lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
@@ -1748,10 +1748,10 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
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
@@ -1786,7 +1786,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1799,7 +1799,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1844,7 +1844,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1856,7 +1856,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
@@ -2071,7 +2071,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2092,7 +2092,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3785,9 +3785,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
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
 
@@ -3808,7 +3808,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	if (zone) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 	}
 }
 #endif /* CONFIG_SHMEM */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
