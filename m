Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7C56B025E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:45:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so3121260wmr.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:11 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id g130si2417380wma.147.2017.01.18.05.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 05:45:09 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r126so4197051wmr.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
Date: Wed, 18 Jan 2017 14:44:52 +0100
Message-Id: <20170118134453.11725-2-mhocko@kernel.org>
In-Reply-To: <20170118134453.11725-1-mhocko@kernel.org>
References: <20170118134453.11725-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

599d0c954f91 ("mm, vmscan: move LRU lists to node") has moved
NR_ISOLATED* counters from zones to nodes. This is not the best fit
especially for systems with high/lowmem because a heavy memory pressure
on the highmem zone might block lowmem requests from making progress. Or
we might allow to reclaim lowmem zone even though there are too many
pages already isolated from the eligible zones just because highmem
pages will easily bias too_many_isolated to say no.

Fix these potential issues by moving isolated stats back to zones and
teach too_many_isolated to consider only eligible zones. Per zone
isolation counters are a bit tricky with the node reclaim because
we have to track each page separatelly.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  4 ++--
 mm/compaction.c        | 16 +++++++-------
 mm/khugepaged.c        |  4 ++--
 mm/memory_hotplug.c    |  2 +-
 mm/migrate.c           |  4 ++--
 mm/page_alloc.c        | 14 ++++++------
 mm/vmscan.c            | 58 ++++++++++++++++++++++++++++----------------------
 mm/vmstat.c            |  4 ++--
 8 files changed, 56 insertions(+), 50 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 91f69aa0d581..100e7f37b7dc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -119,6 +119,8 @@ enum zone_stat_item {
 	NR_ZONE_INACTIVE_FILE,
 	NR_ZONE_ACTIVE_FILE,
 	NR_ZONE_UNEVICTABLE,
+	NR_ZONE_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
+	NR_ZONE_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
@@ -148,8 +150,6 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
-	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
-	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
diff --git a/mm/compaction.c b/mm/compaction.c
index 43a6cf1dc202..f84104217887 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -639,12 +639,12 @@ static bool too_many_isolated(struct zone *zone)
 {
 	unsigned long active, inactive, isolated;
 
-	inactive = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
-			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
-	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
-			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
-	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
-			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
+	inactive = zone_page_state(zone, NR_ZONE_INACTIVE_FILE) +
+			zone_page_state(zone, NR_ZONE_INACTIVE_ANON);
+	active = zone_page_state(zone, NR_ZONE_ACTIVE_FILE) +
+			zone_page_state(zone, NR_ZONE_ACTIVE_ANON);
+	isolated = zone_page_state(zone, NR_ZONE_ISOLATED_FILE) +
+			zone_page_state(zone, NR_ZONE_ISOLATED_ANON);
 
 	return isolated > (inactive + active) / 2;
 }
@@ -857,8 +857,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
+		inc_zone_page_state(page,
+				NR_ZONE_ISOLATED_ANON + page_is_file_cache(page));
 
 isolate_success:
 		list_add(&page->lru, &cc->migratepages);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 34bce5c308e3..8e692b683cac 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -482,7 +482,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 static void release_pte_page(struct page *page)
 {
 	/* 0 stands for page_is_file_cache(page) == false */
-	dec_node_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_zone_page_state(page, NR_ZONE_ISOLATED_ANON + 0);
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -578,7 +578,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
-		inc_node_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_zone_page_state(page, NR_ZONE_ISOLATED_ANON + 0);
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d47b186892b4..8b88dd63bf3d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1616,7 +1616,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_node_page_state(page, NR_ISOLATED_ANON +
+			inc_zone_page_state(page, NR_ZONE_ISOLATED_ANON +
 					    page_is_file_cache(page));
 
 		} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index 87f4d0f81819..e5589dee3022 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -184,7 +184,7 @@ void putback_movable_pages(struct list_head *l)
 			put_page(page);
 		} else {
 			putback_lru_page(page);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
+			dec_zone_page_state(page, NR_ZONE_ISOLATED_ANON +
 					page_is_file_cache(page));
 		}
 	}
@@ -1130,7 +1130,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * as __PageMovable
 		 */
 		if (likely(!__PageMovable(page)))
-			dec_node_page_state(page, NR_ISOLATED_ANON +
+			dec_zone_page_state(page, NR_ZONE_ISOLATED_ANON +
 					page_is_file_cache(page));
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8ff25883c172..997c9bfdf9e5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4318,18 +4318,16 @@ void show_free_areas(unsigned int filter)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 	}
 
-	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
-		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
+	printk("active_anon:%lu inactive_anon:%lu\n"
+		" active_file:%lu inactive_file:%lu\n"
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
-		global_node_page_state(NR_ISOLATED_ANON),
 		global_node_page_state(NR_ACTIVE_FILE),
 		global_node_page_state(NR_INACTIVE_FILE),
-		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
 		global_node_page_state(NR_FILE_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
@@ -4351,8 +4349,6 @@ void show_free_areas(unsigned int filter)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
-			" isolated(anon):%lukB"
-			" isolated(file):%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
 			" writeback:%lukB"
@@ -4373,8 +4369,6 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
-			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
-			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
@@ -4410,8 +4404,10 @@ void show_free_areas(unsigned int filter)
 			" high:%lukB"
 			" active_anon:%lukB"
 			" inactive_anon:%lukB"
+			" isolated_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+			" isolated_file:%lukB"
 			" unevictable:%lukB"
 			" writepending:%lukB"
 			" present:%lukB"
@@ -4433,8 +4429,10 @@ void show_free_areas(unsigned int filter)
 			K(high_wmark_pages(zone)),
 			K(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
+			K(zone_page_state(zone, NR_ZONE_ISOLATED_ANON)),
 			K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
+			K(zone_page_state(zone, NR_ZONE_ISOLATED_FILE)),
 			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
 			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
 			K(zone->present_pages),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f3255702f3df..4b1ed1b1f1db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -216,14 +216,13 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 {
 	unsigned long nr;
 
+	/* TODO can we live without NR_*ISOLATED*? */
 	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
+	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE);
 
 	if (get_nr_swap_pages() > 0)
 		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
+		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON);
 
 	return nr;
 }
@@ -1245,8 +1244,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					 * increment nr_reclaimed here (and
 					 * leave it off the LRU).
 					 */
-					nr_reclaimed++;
-					continue;
+					goto drop_isolated;
 				}
 			}
 		}
@@ -1267,13 +1265,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (ret == SWAP_LZFREE)
 			count_vm_event(PGLAZYFREED);
 
-		nr_reclaimed++;
-
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
 		 */
 		list_add(&page->lru, &free_pages);
+drop_isolated:
+		nr_reclaimed++;
+		mod_zone_page_state(page_zone(page),
+				NR_ZONE_ISOLATED_ANON + page_is_file_cache(page),
+				-hpage_nr_pages(page));
 		continue;
 
 cull_mlocked:
@@ -1340,7 +1341,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
 	list_splice(&clean_pages, page_list);
-	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1433,6 +1433,9 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
 			continue;
 
 		__update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
+		mod_zone_page_state(&lruvec_pgdat(lruvec)->node_zones[zid],
+				NR_ZONE_ISOLATED_ANON + !!is_file_lru(lru),
+				nr_zone_taken[zid]);
 #ifdef CONFIG_MEMCG
 		mem_cgroup_update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
 #endif
@@ -1603,10 +1606,11 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct pglist_data *pgdat, int file,
+static int too_many_isolated(struct pglist_data *pgdat, enum lru_list lru,
 		struct scan_control *sc)
 {
-	unsigned long inactive, isolated;
+	unsigned long inactive = 0, isolated = 0;
+	int zid;
 
 	if (current_is_kswapd())
 		return 0;
@@ -1614,12 +1618,12 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if (!sane_reclaim(sc))
 		return 0;
 
-	if (file) {
-		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
-		isolated = node_page_state(pgdat, NR_ISOLATED_FILE);
-	} else {
-		inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
-		isolated = node_page_state(pgdat, NR_ISOLATED_ANON);
+	for (zid = 0; zid <= sc->reclaim_idx; zid++) {
+		struct zone *zone = &pgdat->node_zones[zid];
+
+		inactive += zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE + lru);
+		isolated += zone_page_state_snapshot(zone,
+				NR_ZONE_ISOLATED_ANON + !!is_file_lru(lru));
 	}
 
 	/*
@@ -1649,6 +1653,11 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
+
+		mod_zone_page_state(page_zone(page),
+				NR_ZONE_ISOLATED_ANON + !!page_is_file_cache(page),
+				-hpage_nr_pages(page));
+
 		if (unlikely(!page_evictable(page))) {
 			spin_unlock_irq(&pgdat->lru_lock);
 			putback_lru_page(page);
@@ -1719,7 +1728,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(pgdat, file, sc))) {
+	while (unlikely(too_many_isolated(pgdat, lru, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
@@ -1739,7 +1748,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
@@ -1768,8 +1776,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	putback_inactive_pages(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
@@ -1939,7 +1945,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc))
@@ -1955,7 +1960,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 		if (unlikely(!page_evictable(page))) {
 			putback_lru_page(page);
-			continue;
+			goto drop_isolated;
 		}
 
 		if (unlikely(buffer_heads_over_limit)) {
@@ -1980,12 +1985,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			 */
 			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
 				list_add(&page->lru, &l_active);
-				continue;
+				goto drop_isolated;
 			}
 		}
 
 		ClearPageActive(page);	/* we are de-activating */
 		list_add(&page->lru, &l_inactive);
+drop_isolated:
+		mod_zone_page_state(page_zone(page),
+				NR_ZONE_ISOLATED_ANON + !!is_file_lru(lru),
+				-hpage_nr_pages(page));
 	}
 
 	/*
@@ -2002,7 +2011,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index bed3c3845936..059c29d14d23 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -926,6 +926,8 @@ const char * const vmstat_text[] = {
 	"nr_zone_inactive_file",
 	"nr_zone_active_file",
 	"nr_zone_unevictable",
+	"nr_zone_anon_isolated",
+	"nr_zone_file_isolated",
 	"nr_zone_write_pending",
 	"nr_mlock",
 	"nr_slab_reclaimable",
@@ -952,8 +954,6 @@ const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
-	"nr_isolated_anon",
-	"nr_isolated_file",
 	"nr_pages_scanned",
 	"workingset_refault",
 	"workingset_activate",
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
