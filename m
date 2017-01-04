Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 934FB6B0268
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:19:58 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id qs7so61090961wjc.4
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:58 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id m63si77239023wmm.107.2017.01.04.02.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:19:57 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id qs7so37298070wjc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:57 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Date: Wed,  4 Jan 2017 11:19:37 +0100
Message-Id: <20170104101942.4860-3-mhocko@kernel.org>
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
References: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Our reclaim process has several tracepoints to tell us more about how
things are progressing. We are, however, missing a tracepoint to track
active list aging. Introduce mm_vmscan_lru_shrink_active which reports
the number of
	- nr_scanned, nr_taken pages to tell us the LRU isolation
	  effectiveness.
	- nr_referenced pages which tells us that we are hitting referenced
	  pages which are deactivated. If this is a large part of the
	  reported nr_deactivated pages then we might be hitting into
	  the active list too early because they might be still part of
	  the working set. This might help to debug performance issues.
	- nr_activated pages which tells us how many pages are kept on the
	  active list - mostly exec file backed pages. A high number can
	  indicate that we might be trashing on executables.

Changes since v1
- report nr_taken pages as per Minchan
- report nr_activated as per Minchan
- do not report nr_freed pages because that would add a tiny overhead to
  free_hot_cold_page_list which is a hot path
- do not report nr_unevictable because we can report this number via a
  different and more generic tracepoint in putback_lru_page
- fix move_active_pages_to_lru to report proper page count when we hit
  into large pages
- drop nr_scanned because this can be obtained from
  trace_mm_vmscan_lru_isolate as per Minchan

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 36 ++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   | 18 ++++++++++++++----
 2 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 39bad8921ca1..087c0b625ba7 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -363,6 +363,42 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
+TRACE_EVENT(mm_vmscan_lru_shrink_active,
+
+	TP_PROTO(int nid, unsigned long nr_taken,
+		unsigned long nr_activate, unsigned long nr_deactivated,
+		unsigned long nr_referenced, int priority, int file),
+
+	TP_ARGS(nid, nr_taken, nr_activate, nr_deactivated, nr_referenced, priority, file),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(unsigned long, nr_taken)
+		__field(unsigned long, nr_activate)
+		__field(unsigned long, nr_deactivated)
+		__field(unsigned long, nr_referenced)
+		__field(int, priority)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->nr_taken = nr_taken;
+		__entry->nr_activate = nr_activate;
+		__entry->nr_deactivated = nr_deactivated;
+		__entry->nr_referenced = nr_referenced;
+		__entry->priority = priority;
+		__entry->reclaim_flags = trace_shrink_flags(file);
+	),
+
+	TP_printk("nid=%d nr_taken=%ld nr_activated=%ld nr_deactivated=%ld nr_referenced=%ld priority=%d flags=%s",
+		__entry->nid,
+		__entry->nr_taken,
+		__entry->nr_activate, __entry->nr_deactivated, __entry->nr_referenced,
+		__entry->priority,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
+
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4abf08861d2..70d1c55463c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1846,9 +1846,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  *
  * The downside is that we have to touch page->_refcount against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns the number of pages moved to the given lru.
  */
 
-static void move_active_pages_to_lru(struct lruvec *lruvec,
+static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
@@ -1857,6 +1859,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
+	int nr_moved = 0;
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
@@ -1882,11 +1885,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, pages_to_free);
+		} else {
+			nr_moved += nr_pages;
 		}
 	}
 
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	return nr_moved;
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
@@ -1902,7 +1909,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	unsigned long nr_rotated = 0;
+	unsigned nr_deactivate, nr_activate;
+	unsigned nr_rotated = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1980,13 +1988,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
+	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
+	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
+			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
