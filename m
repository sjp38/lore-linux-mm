Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 962BA6B0256
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:26 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so201697379wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:26 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id f88si39743968wmh.22.2016.02.23.05.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:17 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 84FE31C1DF4
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:17 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/27] mm, vmscan: Move lru_lock to the node
Date: Tue, 23 Feb 2016 13:44:53 +0000
Message-Id: <1456235116-32385-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Node-based reclaim requires node-based LRUs and locking. This is a
preparation patch that just moves the lru_lock to the node so later patches
are easier to review. It is a mechanical change but note this patch makes
contention worse because the LRU lock is hotter and direct reclaim and kswapd
can contend on the same lock even when reclaiming from different zones.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/cgroup-v1/memcg_test.txt |  4 +--
 Documentation/cgroup-v1/memory.txt     |  4 +--
 include/linux/mm_types.h               |  2 +-
 include/linux/mmzone.h                 | 10 +++++--
 mm/compaction.c                        |  6 ++---
 mm/filemap.c                           |  4 +--
 mm/huge_memory.c                       |  4 +--
 mm/memcontrol.c                        |  6 ++---
 mm/mlock.c                             | 10 +++----
 mm/page_alloc.c                        |  4 +--
 mm/page_idle.c                         |  4 +--
 mm/rmap.c                              |  2 +-
 mm/swap.c                              | 30 ++++++++++-----------
 mm/vmscan.c                            | 48 +++++++++++++++++-----------------
 14 files changed, 72 insertions(+), 66 deletions(-)

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
index ff71e16cc752..2060e402869c 100644
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
index 944b2b37313b..73a06e582bfa 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -112,7 +112,7 @@ struct page {
 	 */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
+					 * protected by zone_lru_lock !
 					 * Can be used as a generic list
 					 * by the page owner.
 					 */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 291719dadea6..86539225067e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -100,7 +100,7 @@ struct free_area {
 struct pglist_data;
 
 /*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * zone->lock and the zone lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
  * cachelines.  There are very few zone structures in the machine, so space
  * consumption is not a concern here.
@@ -498,7 +498,6 @@ struct zone {
 	/* Write-intensive fields used by page reclaim */
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	/*
@@ -693,6 +692,9 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/* Write-intensive fields used from the page allocator */
+	ZONE_PADDING(_pad1_)
+	spinlock_t		lru_lock;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	/*
@@ -724,6 +726,10 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
+static inline spinlock_t *zone_lru_lock(struct zone *zone)
+{
+	return &zone->zone_pgdat->lru_lock;
+}
 
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index 4cb1c2ef5abb..c85bd016754f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -670,7 +670,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if contended.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(&zone->lru_lock, flags,
+		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
 								&locked, cc))
 			break;
 
@@ -747,7 +747,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(&zone->lru_lock,
+			locked = compact_trylock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
 			if (!locked)
 				break;
@@ -798,7 +798,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		low_pfn = end_pfn;
 
 	if (locked)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
diff --git a/mm/filemap.c b/mm/filemap.c
index 6414803972f7..99d921e1e1bb 100644
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
index 8caec8f13dfc..59ca13bb13f9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3356,7 +3356,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	int i;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
 	/* complete memcg works before add pages to LRU */
@@ -3366,7 +3366,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 		__split_huge_page_tail(head, i, lruvec, list);
 
 	ClearPageCompound(head);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	unfreeze_page(page_anon_vma(head), head);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c55685..c1acf0edd3b4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2088,7 +2088,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
@@ -2112,7 +2112,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
@@ -2377,7 +2377,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone->lru_lock and migration entries setup in all page mappings.
+ * zone_lru_lock and migration entries setup in all page mappings.
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
diff --git a/mm/mlock.c b/mm/mlock.c
index 96f001041928..ce7dabd53e7e 100644
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
index e06d548521af..288015b5ee24 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5570,10 +5570,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
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
index 02f0bfc3c80a..6ed6699c45fc 100644
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
index 09fe5e97714a..4067911033e1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -59,12 +59,12 @@ static void __page_cache_release(struct page *page)
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
@@ -186,16 +186,16 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 
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
@@ -315,9 +315,9 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 }
 #endif
 
@@ -446,13 +446,13 @@ void add_page_to_unevictable_list(struct page *page)
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
@@ -724,7 +724,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		 * same zone. The lock is held only if zone != NULL.
 		 */
 		if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 			zone = NULL;
 		}
 
@@ -734,7 +734,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		if (PageCompound(page)) {
 			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 				zone = NULL;
 			}
 			__put_compound_page(page);
@@ -746,11 +746,11 @@ void release_pages(struct page **pages, int nr, bool cold)
 
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
@@ -765,7 +765,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
@@ -801,7 +801,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
+		  !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index de8d6226e026..13a8ca37ab42 100644
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
@@ -1441,7 +1441,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(zone_lru_lock(zone));
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1450,7 +1450,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(zone_lru_lock(zone));
 	}
 	return ret;
 }
@@ -1509,9 +1509,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
 
@@ -1532,10 +1532,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
@@ -1597,7 +1597,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1612,7 +1612,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	if (nr_taken == 0)
 		return 0;
@@ -1622,7 +1622,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				&nr_writeback, &nr_immediate,
 				false);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
@@ -1639,7 +1639,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_hot_cold_page_list(&page_list, true);
@@ -1713,9 +1713,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
@@ -1752,10 +1752,10 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
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
@@ -1790,7 +1790,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1802,7 +1802,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1847,7 +1847,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1859,7 +1859,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
@@ -2094,7 +2094,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(zone_lru_lock(zone));
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2115,7 +2115,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(zone_lru_lock(zone));
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3809,9 +3809,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
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
 
@@ -3832,7 +3832,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
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
