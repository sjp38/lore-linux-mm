Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDE06B0260
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:33:07 -0500 (EST)
Received: by pasz6 with SMTP id z6so54064828pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:33:07 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id cd5si17184159pbb.185.2015.11.11.20.32.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:46 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 14/17] mm: introduce wrappers to add new LRU
Date: Thu, 12 Nov 2015 13:33:10 +0900
Message-Id: <1447302793-5376-15-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

We have used binary variable "file" to identify whether it is anon LRU
or file LRU. It's good but it becomes obstacle if we add new LRU.

So, this patch introduces some wrapper functions to handle it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_inline.h     | 64 +++++++++++++++++++++++++++++++++++++++++--
 include/trace/events/vmscan.h | 24 ++++++++--------
 mm/compaction.c               |  2 +-
 mm/huge_memory.c              |  5 ++--
 mm/memory-failure.c           |  7 ++---
 mm/memory_hotplug.c           |  3 +-
 mm/mempolicy.c                |  3 +-
 mm/migrate.c                  | 26 ++++++------------
 mm/swap.c                     | 22 ++++++---------
 mm/vmscan.c                   | 12 ++++----
 10 files changed, 104 insertions(+), 64 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945c83fb..5e08a354f936 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -8,8 +8,8 @@
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
  *
- * Returns 1 if @page is page cache page backed by a regular filesystem,
- * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
+ * Returns true if @page is page cache page backed by a regular filesystem,
+ * or false if @page is anonymous, tmpfs or otherwise ram or swap backed.
  * Used by functions that manipulate the LRU lists, to sort a page
  * onto the right LRU list.
  *
@@ -17,7 +17,7 @@
  * needs to survive until the page is last deleted from the LRU, which
  * could be as far down as __page_cache_release.
  */
-static inline int page_is_file_cache(struct page *page)
+static inline bool page_is_file_cache(struct page *page)
 {
 	return !PageSwapBacked(page);
 }
@@ -56,6 +56,64 @@ static inline enum lru_list page_lru_base_type(struct page *page)
 }
 
 /**
+ * lru_index - which LRU list is lru on for accouting update_page_reclaim_stat
+ *
+ * Used for LRU list index arithmetic.
+ *
+ * Returns 0 if @lru is anon, 1 if it is file.
+ */
+static inline int lru_index(enum lru_list lru)
+{
+	int base;
+
+	switch (lru) {
+	case LRU_INACTIVE_ANON:
+	case LRU_ACTIVE_ANON:
+		base = 0;
+		break;
+	case LRU_INACTIVE_FILE:
+	case LRU_ACTIVE_FILE:
+		base = 1;
+		break;
+	default:
+		BUG();
+	}
+	return base;
+}
+
+/*
+ * page_off_isolate - which LRU list was page on for accouting NR_ISOLATED.
+ * @page: the page to test
+ *
+ * Returns the LRU list a page was on, as an index into the array of
+ * zone_page_state;
+ */
+static inline int page_off_isolate(struct page *page)
+{
+	int lru = NR_ISOLATED_ANON;
+
+	if (!PageSwapBacked(page))
+		lru = NR_ISOLATED_FILE;
+	return lru;
+}
+
+/**
+ * lru_off_isolate - which LRU list was @lru on for accouting NR_ISOLATED.
+ * @lru: the lru to test
+ *
+ * Returns the LRU list a page was on, as an index into the array of
+ * zone_page_state;
+ */
+static inline int lru_off_isolate(enum lru_list lru)
+{
+	int base = NR_ISOLATED_FILE;
+
+	if (lru <= LRU_ACTIVE_ANON)
+		base = NR_ISOLATED_ANON;
+	return base;
+}
+
+/**
  * page_off_lru - which LRU list was page on? clearing its lru flags.
  * @page: the page to test
  *
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f66476b96264..4e9e86733849 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -30,9 +30,9 @@
 	(RECLAIM_WB_ASYNC) \
 	)
 
-#define trace_shrink_flags(file) \
+#define trace_shrink_flags(lru) \
 	( \
-		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+		(lru ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
 		(RECLAIM_WB_ASYNC) \
 	)
 
@@ -271,9 +271,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, lru),
 
 	TP_STRUCT__entry(
 		__field(int, order)
@@ -281,7 +281,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_taken)
 		__field(isolate_mode_t, isolate_mode)
-		__field(int, file)
+		__field(enum lru_list, lru)
 	),
 
 	TP_fast_assign(
@@ -290,16 +290,16 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_taken = nr_taken;
 		__entry->isolate_mode = isolate_mode;
-		__entry->file = file;
+		__entry->lru = lru;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu lru=%d",
 		__entry->isolate_mode,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
 		__entry->nr_taken,
-		__entry->file)
+		__entry->lru)
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
@@ -309,9 +309,9 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, lru)
 
 );
 
@@ -322,9 +322,9 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, lru)
 
 );
 
diff --git a/mm/compaction.c b/mm/compaction.c
index c5c627aae996..d888fa248ebb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -632,7 +632,7 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 		return;
 
 	list_for_each_entry(page, &cc->migratepages, lru)
-		count[!!page_is_file_cache(page)]++;
+		count[page_off_isolate(page) - NR_ISOLATED_ANON]++;
 
 	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b8c9b44af864..d020aec63717 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2218,8 +2218,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
-	/* 0 stands for page_is_file_cache(page) == false */
-	dec_zone_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_zone_page_state(page, page_off_isolate(page));
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -2302,7 +2301,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
-		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_zone_page_state(page, page_off_isolate(page));
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 95882692e747..abf50e00705b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1682,16 +1682,15 @@ static int __soft_offline_page(struct page *page, int flags)
 	put_hwpoison_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-		inc_zone_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+		inc_zone_page_state(page, page_off_isolate(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
 			if (!list_empty(&pagelist)) {
 				list_del(&page->lru);
-				dec_zone_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
+				dec_zone_page_state(page,
+						page_off_isolate(page));
 				putback_lru_page(page);
 			}
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index aa992e2df58a..7c8360744551 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1449,8 +1449,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_zone_page_state(page, page_off_isolate(page));
 
 		} else {
 #ifdef CONFIG_DEBUG_VM
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 87a177917cb2..856b6eb07e42 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -930,8 +930,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (!isolate_lru_page(page)) {
 			list_add_tail(&page->lru, pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_zone_page_state(page, page_off_isolate(page));
 		}
 	}
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 842ecd7aaf7f..87ebf0833b84 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -91,8 +91,7 @@ void putback_movable_pages(struct list_head *l)
 			continue;
 		}
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
+		dec_zone_page_state(page, page_off_isolate(page));
 		if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
 		else
@@ -964,8 +963,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * restored.
 		 */
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
+		dec_zone_page_state(page, page_off_isolate(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
 		if (reason == MR_MEMORY_FAILURE) {
 			put_page(page);
@@ -1278,8 +1276,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			inc_zone_page_state(page, page_off_isolate(page));
 		}
 put_and_set:
 		/*
@@ -1622,8 +1619,6 @@ static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int page_lru;
-
 	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
@@ -1645,8 +1640,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		return 0;
 	}
 
-	page_lru = page_is_file_cache(page);
-	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
+	mod_zone_page_state(page_zone(page), page_off_isolate(page),
 				hpage_nr_pages(page));
 
 	/*
@@ -1704,8 +1698,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_zone_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			dec_zone_page_state(page, page_off_isolate(page));
 			putback_lru_page(page);
 		}
 		isolated = 0;
@@ -1735,7 +1728,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	int page_lru = page_is_file_cache(page);
+	int page_lru = page_off_isolate(page);
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
 	pmd_t orig_entry;
@@ -1794,8 +1787,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_zone_page_state(page_zone(page),
-			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
+		mod_zone_page_state(page_zone(page), page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
 	}
@@ -1847,9 +1839,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_zone_page_state(page_zone(page),
-			NR_ISOLATED_ANON + page_lru,
-			-HPAGE_PMD_NR);
+	mod_zone_page_state(page_zone(page), page_lru, -HPAGE_PMD_NR);
 	return isolated;
 
 out_fail:
diff --git a/mm/swap.c b/mm/swap.c
index a2f2cd458de0..367940d093ad 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -490,21 +490,20 @@ void rotate_reclaimable_page(struct page *page)
 }
 
 static void update_page_reclaim_stat(struct lruvec *lruvec,
-				     int file, int rotated)
+				     int lru, int rotated)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	reclaim_stat->recent_scanned[file]++;
+	reclaim_stat->recent_scanned[lru]++;
 	if (rotated)
-		reclaim_stat->recent_rotated[file]++;
+		reclaim_stat->recent_rotated[lru]++;
 }
 
 static void __activate_page(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
-		int lru = page_lru_base_type(page);
+		enum lru_list lru = page_lru_base_type(page);
 
 		del_page_from_lru_list(page, lruvec, lru);
 		SetPageActive(page);
@@ -513,7 +512,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		trace_mm_lru_activate(page);
 
 		__count_vm_event(PGACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 1);
+		update_page_reclaim_stat(lruvec, lru_index(lru), 1);
 	}
 }
 
@@ -758,7 +757,7 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 			      void *arg)
 {
-	int lru;
+	enum lru_list lru;
 	bool file, active;
 
 	if (!PageLRU(page) || PageUnevictable(page))
@@ -801,7 +800,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
 
-	update_page_reclaim_stat(lruvec, file, 0);
+	update_page_reclaim_stat(lruvec, lru_index(lru), 0);
 }
 
 /*
@@ -1002,8 +1001,6 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct page *page, struct page *page_tail,
 		       struct lruvec *lruvec, struct list_head *list)
 {
-	const int file = 0;
-
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
@@ -1034,14 +1031,13 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	}
 
 	if (!PageUnevictable(page))
-		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
+		update_page_reclaim_stat(lruvec, 0, PageActive(page_tail));
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 				 void *arg)
 {
-	int file = page_is_file_cache(page);
 	int active = PageActive(page);
 	enum lru_list lru = page_lru(page);
 
@@ -1049,7 +1045,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, lru);
-	update_page_reclaim_stat(lruvec, file, active);
+	update_page_reclaim_stat(lruvec, lru_index(lru), active);
 	trace_mm_lru_insertion(page, lru);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7a415b9fdd34..f731084c3a23 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1398,7 +1398,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
-				    nr_taken, mode, is_file_lru(lru));
+				    nr_taken, mode, lru_index(lru));
 	return nr_taken;
 }
 
@@ -1599,7 +1599,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				     &nr_scanned, sc, isolate_mode, lru);
 
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+	__mod_zone_page_state(zone, lru_off_isolate(lru), nr_taken);
 
 	if (global_reclaim(sc)) {
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
@@ -1633,7 +1633,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	putback_inactive_pages(lruvec, &page_list);
 
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_zone_page_state(zone, lru_off_isolate(lru), -nr_taken);
 
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -1701,7 +1701,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
 		sc->priority,
-		trace_shrink_flags(file));
+		trace_shrink_flags(lru));
 	return nr_reclaimed;
 }
 
@@ -1800,7 +1800,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+	__mod_zone_page_state(zone, lru_off_isolate(lru), nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
@@ -1857,7 +1857,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_zone_page_state(zone, lru_off_isolate(lru), -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
