Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCD046B0292
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:27 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so188845659pgj.6
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:27 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i80si11649802pfa.223.2017.01.29.21.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:26 -0800 (PST)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U5o2IP027739
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 288r78dnkv-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 21eeb8eee6b011e6891b0002c9521c9e-94bf9a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 1/6] mm: add wrap for page accouting index
Date: Sun, 29 Jan 2017 21:51:18 -0800
Message-ID: <20e89d29d24b10f850128963e731529ce7869392.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

We calculate page/lru accouting index with checking if the page/lru is
file. This will be a problem when we introduce a new LRU list. So add a
wrap for the calculation.

The patch is based on Minchan's previous patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/mm_inline.h     | 26 ++++++++++++++++++++++++++
 include/trace/events/vmscan.h | 23 ++++++++++++-----------
 mm/compaction.c               |  3 +--
 mm/khugepaged.c               |  6 ++----
 mm/memory-failure.c           |  3 +--
 mm/memory_hotplug.c           |  3 +--
 mm/mempolicy.c                |  3 +--
 mm/migrate.c                  | 27 +++++++++------------------
 mm/vmscan.c                   | 19 ++++++++++---------
 9 files changed, 63 insertions(+), 50 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e030a68..0dddc2c 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -124,6 +124,32 @@ static __always_inline enum lru_list page_lru(struct page *page)
 	return lru;
 }
 
+/*
+ * lru_isolate_index - which item should a lru be accounted for
+ * @lru: the lru list
+ *
+ * Returns the accounting item index of the lru
+ */
+static inline int lru_isolate_index(enum lru_list lru)
+{
+	if (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE)
+		return NR_ISOLATED_FILE;
+	return NR_ISOLATED_ANON;
+}
+
+/*
+ * page_isolate_index - which item should a page be accounted for
+ * @page: the page to test
+ *
+ * Returns the accounting item index of the page
+ */
+static inline int page_isolate_index(struct page *page)
+{
+	if (!PageSwapBacked(page))
+		return NR_ISOLATED_FILE;
+	return NR_ISOLATED_ANON;
+}
+
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
 #endif
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 27e8a5c..fab386d 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -31,9 +31,10 @@
 	(RECLAIM_WB_ASYNC) \
 	)
 
-#define trace_shrink_flags(file) \
+#define trace_shrink_flags(isolate_index) \
 	( \
-		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+		(isolate_index == NR_ISOLATED_FILE ? RECLAIM_WB_FILE : \
+			RECLAIM_WB_ANON) | \
 		(RECLAIM_WB_ASYNC) \
 	)
 
@@ -345,11 +346,11 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		unsigned long nr_congested, unsigned long nr_immediate,
 		unsigned long nr_activate, unsigned long nr_ref_keep,
 		unsigned long nr_unmap_fail,
-		int priority, int file),
+		int priority, int isolate_index),
 
 	TP_ARGS(nid, nr_scanned, nr_reclaimed, nr_dirty, nr_writeback,
 		nr_congested, nr_immediate, nr_activate, nr_ref_keep,
-		nr_unmap_fail, priority, file),
+		nr_unmap_fail, priority, isolate_index),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
@@ -378,7 +379,7 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nr_ref_keep = nr_ref_keep;
 		__entry->nr_unmap_fail = nr_unmap_fail;
 		__entry->priority = priority;
-		__entry->reclaim_flags = trace_shrink_flags(file);
+		__entry->reclaim_flags = trace_shrink_flags(isolate_index);
 	),
 
 	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
@@ -395,9 +396,9 @@ TRACE_EVENT(mm_vmscan_lru_shrink_active,
 
 	TP_PROTO(int nid, unsigned long nr_taken,
 		unsigned long nr_active, unsigned long nr_deactivated,
-		unsigned long nr_referenced, int priority, int file),
+		unsigned long nr_referenced, int priority, int isolate_index),
 
-	TP_ARGS(nid, nr_taken, nr_active, nr_deactivated, nr_referenced, priority, file),
+	TP_ARGS(nid, nr_taken, nr_active, nr_deactivated, nr_referenced, priority, isolate_index),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
@@ -416,7 +417,7 @@ TRACE_EVENT(mm_vmscan_lru_shrink_active,
 		__entry->nr_deactivated = nr_deactivated;
 		__entry->nr_referenced = nr_referenced;
 		__entry->priority = priority;
-		__entry->reclaim_flags = trace_shrink_flags(file);
+		__entry->reclaim_flags = trace_shrink_flags(isolate_index);
 	),
 
 	TP_printk("nid=%d nr_taken=%ld nr_active=%ld nr_deactivated=%ld nr_referenced=%ld priority=%d flags=%s",
@@ -432,9 +433,9 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
 	TP_PROTO(int nid, int reclaim_idx,
 		unsigned long total_inactive, unsigned long inactive,
 		unsigned long total_active, unsigned long active,
-		unsigned long ratio, int file),
+		unsigned long ratio, int isolate_index),
 
-	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, ratio, file),
+	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, ratio, isolate_index),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
@@ -455,7 +456,7 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
 		__entry->total_active = total_active;
 		__entry->active = active;
 		__entry->ratio = ratio;
-		__entry->reclaim_flags = trace_shrink_flags(file) & RECLAIM_WB_LRU;
+		__entry->reclaim_flags = trace_shrink_flags(isolate_index) & RECLAIM_WB_LRU;
 	),
 
 	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
diff --git a/mm/compaction.c b/mm/compaction.c
index 0aa2757..3918c48 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -857,8 +857,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
+		inc_node_page_state(page, page_isolate_index(page));
 
 isolate_success:
 		list_add(&page->lru, &cc->migratepages);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 34bce5c..fd43a0a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -481,8 +481,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
-	/* 0 stands for page_is_file_cache(page) == false */
-	dec_node_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_node_page_state(page, page_isolate_index(page));
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -577,8 +576,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			result = SCAN_DEL_PAGE_LRU;
 			goto out;
 		}
-		/* 0 stands for page_is_file_cache(page) == false */
-		inc_node_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_node_page_state(page, page_isolate_index(page));
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 3f3cfd4..695ecb72 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1667,8 +1667,7 @@ static int __soft_offline_page(struct page *page, int flags)
 		 * cannot have PAGE_MAPPING_MOVABLE.
 		 */
 		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
+			inc_node_page_state(page, page_isolate_index(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3e3db7a..e2115c8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1620,8 +1620,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_node_page_state(page, page_isolate_index(page));
 
 		} else {
 #ifdef CONFIG_DEBUG_VM
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1e7873e..c894925 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -964,8 +964,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (!isolate_lru_page(page)) {
 			list_add_tail(&page->lru, pagelist);
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_node_page_state(page, page_isolate_index(page));
 		}
 	}
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 87f4d0f..502ebea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -184,8 +184,7 @@ void putback_movable_pages(struct list_head *l)
 			put_page(page);
 		} else {
 			putback_lru_page(page);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			dec_node_page_state(page, page_isolate_index(page));
 		}
 	}
 }
@@ -1130,8 +1129,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * as __PageMovable
 		 */
 		if (likely(!__PageMovable(page)))
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			dec_node_page_state(page, page_isolate_index(page));
 	}
 
 	/*
@@ -1471,8 +1469,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_node_page_state(page, page_isolate_index(page));
 		}
 put_and_set:
 		/*
@@ -1816,8 +1813,6 @@ static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int page_lru;
-
 	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
@@ -1839,8 +1834,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		return 0;
 	}
 
-	page_lru = page_is_file_cache(page);
-	mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON + page_lru,
+	mod_node_page_state(page_pgdat(page), page_isolate_index(page),
 				hpage_nr_pages(page));
 
 	/*
@@ -1898,8 +1892,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			dec_node_page_state(page, page_isolate_index(page));
 			putback_lru_page(page);
 		}
 		isolated = 0;
@@ -1929,7 +1922,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	int page_lru = page_is_file_cache(page);
+	int isolate_index = page_isolate_index(page);
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
 	pmd_t orig_entry;
@@ -1991,8 +1984,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_node_page_state(page_pgdat(page),
-			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
+		mod_node_page_state(page_pgdat(page), isolate_index,
+			-HPAGE_PMD_NR);
 
 		goto out_unlock;
 	}
@@ -2042,9 +2035,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_node_page_state(page_pgdat(page),
-			NR_ISOLATED_ANON + page_lru,
-			-HPAGE_PMD_NR);
+	mod_node_page_state(page_pgdat(page), isolate_index, -HPAGE_PMD_NR);
 	return isolated;
 
 out_fail:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 947ab6f..abb64b7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1736,7 +1736,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
+	__mod_node_page_state(pgdat, lru_isolate_index(lru), nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
@@ -1765,7 +1765,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	putback_inactive_pages(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_node_page_state(pgdat, lru_isolate_index(lru), -nr_taken);
 
 	spin_unlock_irq(&pgdat->lru_lock);
 
@@ -1843,7 +1843,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 			stat.nr_congested, stat.nr_immediate,
 			stat.nr_activate, stat.nr_ref_keep,
 			stat.nr_unmap_fail,
-			sc->priority, file);
+			sc->priority, lru_isolate_index(lru));
 	return nr_reclaimed;
 }
 
@@ -1940,7 +1940,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
+	__mod_node_page_state(pgdat, lru_isolate_index(lru), nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc))
@@ -2003,13 +2003,13 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_node_page_state(pgdat, lru_isolate_index(lru), -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
 	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
-			nr_deactivate, nr_rotated, sc->priority, file);
+		nr_deactivate, nr_rotated, sc->priority, lru_isolate_index(lru));
 }
 
 /*
@@ -2038,11 +2038,12 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
+static bool inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru,
 						struct scan_control *sc, bool trace)
 {
 	unsigned long inactive_ratio;
 	unsigned long inactive, active;
+	bool file = is_file_lru(lru);
 	enum lru_list inactive_lru = file * LRU_FILE;
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
 	unsigned long gb;
@@ -2068,7 +2069,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 				sc->reclaim_idx,
 				lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
 				lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
-				inactive_ratio, file);
+				inactive_ratio, lru_isolate_index(lru));
 
 	return inactive * inactive_ratio < active;
 }
@@ -2077,7 +2078,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
+		if (inactive_list_is_low(lruvec, lru, sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
