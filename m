Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF6E66B0011
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:35 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id o42so11184616uao.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:35 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z9si1267372vkz.391.2018.01.31.15.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:34 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 07/13] mm: convert to-be-refactored lru_lock callsites to lock-all API
Date: Wed, 31 Jan 2018 18:04:07 -0500
Message-Id: <20180131230413.27653-8-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Use the heavy locking API for now to allow us to focus on the path we're
measuring to prove the concept--the release_pages path.  In that path,
LRU batch locking will be used, but everywhere else will be heavy.

For now, exclude compaction since this would be a nontrivial
refactoring.  We can deal with that in a future series.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/huge_memory.c |  6 +++---
 mm/memcontrol.c  |  4 ++--
 mm/mlock.c       | 10 +++++-----
 mm/page_idle.c   |  4 ++--
 mm/swap.c        | 10 +++++-----
 mm/vmscan.c      | 38 +++++++++++++++++++-------------------
 6 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0e7ded98d114..787ad5ba55bb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2461,7 +2461,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		spin_unlock(&head->mapping->tree_lock);
 	}
 
-	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+	lru_unlock_all(page_zone(head)->zone_pgdat, &flags);
 
 	unfreeze_page(head);
 
@@ -2661,7 +2661,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		lru_add_drain();
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
+	lru_lock_all(page_zone(head)->zone_pgdat, &flags);
 
 	if (mapping) {
 		void **pslot;
@@ -2709,7 +2709,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spin_unlock(&pgdata->split_queue_lock);
 fail:		if (mapping)
 			spin_unlock(&mapping->tree_lock);
-		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+		lru_unlock_all(page_zone(head)->zone_pgdat, &flags);
 		unfreeze_page(head);
 		ret = -EBUSY;
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac2ffd5e02b9..99a54df760e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2071,7 +2071,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	lru_lock_all(zone->zone_pgdat, NULL);
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
@@ -2095,7 +2095,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	lru_unlock_all(zone->zone_pgdat, NULL);
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
diff --git a/mm/mlock.c b/mm/mlock.c
index 30472d438794..6ba6a5887aeb 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -188,7 +188,7 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(zone_lru_lock(zone));
+	lru_lock_all(zone->zone_pgdat, NULL);
 
 	if (!TestClearPageMlocked(page)) {
 		/* Potentially, PTE-mapped THP: do not skip the rest PTEs */
@@ -200,14 +200,14 @@ unsigned int munlock_vma_page(struct page *page)
 	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
 
 	if (__munlock_isolate_lru_page(page, true)) {
-		spin_unlock_irq(zone_lru_lock(zone));
+		lru_unlock_all(zone->zone_pgdat, NULL);
 		__munlock_isolated_page(page);
 		goto out;
 	}
 	__munlock_isolation_failed(page);
 
 unlock_out:
-	spin_unlock_irq(zone_lru_lock(zone));
+	lru_unlock_all(zone->zone_pgdat, NULL);
 
 out:
 	return nr_pages - 1;
@@ -292,7 +292,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	pagevec_init(&pvec_putback);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(zone_lru_lock(zone));
+	lru_lock_all(zone->zone_pgdat, NULL);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -319,7 +319,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		pvec->pages[i] = NULL;
 	}
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(zone_lru_lock(zone));
+	lru_unlock_all(zone->zone_pgdat, NULL);
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 0a49374e6931..3324527c1c34 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -42,12 +42,12 @@ static struct page *page_idle_get_page(unsigned long pfn)
 		return NULL;
 
 	zone = page_zone(page);
-	spin_lock_irq(zone_lru_lock(zone));
+	lru_lock_all(zone->zone_pgdat, NULL);
 	if (unlikely(!PageLRU(page))) {
 		put_page(page);
 		page = NULL;
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	lru_unlock_all(zone->zone_pgdat, NULL);
 	return page;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 67eb89fc9435..c4ca7e1c7c03 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -200,16 +200,16 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 
 		if (pagepgdat != pgdat) {
 			if (pgdat)
-				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+				lru_unlock_all(pgdat, &flags);
 			pgdat = pagepgdat;
-			spin_lock_irqsave(&pgdat->lru_lock, flags);
+			lru_lock_all(pgdat, &flags);
 		}
 
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
 	if (pgdat)
-		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+		lru_unlock_all(pgdat, &flags);
 	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
@@ -330,9 +330,9 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	page = compound_head(page);
-	spin_lock_irq(zone_lru_lock(zone));
+	lru_lock_all(zone->zone_pgdat, NULL);
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone->zone_pgdat), NULL);
-	spin_unlock_irq(zone_lru_lock(zone));
+	lru_unlock_all(zone->zone_pgdat, NULL);
 }
 #endif
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b4c32a65a40f..b893200a397d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1691,9 +1691,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
-			spin_unlock_irq(&pgdat->lru_lock);
+			lru_unlock_all(pgdat, NULL);
 			putback_lru_page(page);
-			spin_lock_irq(&pgdat->lru_lock);
+			lru_lock_all(pgdat, NULL);
 			continue;
 		}
 
@@ -1714,10 +1714,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&pgdat->lru_lock);
+				lru_unlock_all(pgdat, NULL);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&pgdat->lru_lock);
+				lru_lock_all(pgdat, NULL);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1779,7 +1779,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 
-	spin_lock_irq(&pgdat->lru_lock);
+	lru_lock_all(pgdat, NULL);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1798,7 +1798,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
 				   nr_scanned);
 	}
-	spin_unlock_irq(&pgdat->lru_lock);
+	lru_unlock_all(pgdat, NULL);
 
 	if (nr_taken == 0)
 		return 0;
@@ -1806,7 +1806,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, 0,
 				&stat, false);
 
-	spin_lock_irq(&pgdat->lru_lock);
+	lru_lock_all(pgdat, NULL);
 
 	if (current_is_kswapd()) {
 		if (global_reclaim(sc))
@@ -1824,7 +1824,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(&pgdat->lru_lock);
+	lru_unlock_all(pgdat, NULL);
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_unref_page_list(&page_list);
@@ -1951,10 +1951,10 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&pgdat->lru_lock);
+				lru_unlock_all(pgdat, NULL);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&pgdat->lru_lock);
+				lru_lock_all(pgdat, NULL);
 			} else
 				list_add(&page->lru, pages_to_free);
 		} else {
@@ -1995,7 +1995,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 
-	spin_lock_irq(&pgdat->lru_lock);
+	lru_lock_all(pgdat, NULL);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -2006,7 +2006,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGREFILL, nr_scanned);
 	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
 
-	spin_unlock_irq(&pgdat->lru_lock);
+	lru_unlock_all(pgdat, NULL);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -2051,7 +2051,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&pgdat->lru_lock);
+	lru_lock_all(pgdat, NULL);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -2063,7 +2063,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&pgdat->lru_lock);
+	lru_unlock_all(pgdat, NULL);
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_unref_page_list(&l_hold);
@@ -2306,7 +2306,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES) +
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES);
 
-	spin_lock_irq(&pgdat->lru_lock);
+	lru_lock_all(pgdat, NULL);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2327,7 +2327,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&pgdat->lru_lock);
+	lru_unlock_all(pgdat, NULL);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3978,9 +3978,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		pgscanned++;
 		if (pagepgdat != pgdat) {
 			if (pgdat)
-				spin_unlock_irq(&pgdat->lru_lock);
+				lru_unlock_all(pgdat, NULL);
 			pgdat = pagepgdat;
-			spin_lock_irq(&pgdat->lru_lock);
+			lru_lock_all(pgdat, NULL);
 		}
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
@@ -4001,7 +4001,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	if (pgdat) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&pgdat->lru_lock);
+		lru_unlock_all(pgdat, NULL);
 	}
 }
 #endif /* CONFIG_SHMEM */
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
