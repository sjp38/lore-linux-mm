Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 116FE6B0274
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:42:04 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n1so17859111pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:42:04 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id gc5si9816188pac.224.2016.04.05.13.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:42:03 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id zm5so17635259pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:42:03 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:42:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 02/10] mm: update_lru_size do the __mod_zone_page_state
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051340120.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Konstantin Khlebnikov pointed out (nearly four years ago, when lumpy
reclaim was removed) that lru_size can be updated by -nr_taken once
per call to isolate_lru_pages(), instead of page by page.

Update it inside isolate_lru_pages(), or at its two callsites?  I
chose to update it at the callsites, rearranging and grouping the
updates by nr_taken and nr_scanned together in both.

With one exception, mem_cgroup_update_lru_size(,lru,) is then used
where __mod_zone_page_state(,NR_LRU_BASE+lru,) is used; and we shall
be adding some more calls in a future commit.  Make the code a little
smaller and simpler by incorporating stat update in lru_size update.

The exception was move_active_pages_to_lru(), which aggregated the
pgmoved stat update separately from the individual lru_size updates;
but I still think this a simplification worth making.

However, the __mod_zone_page_state is not peculiar to mem_cgroups: so
better use the name update_lru_size, calls mem_cgroup_update_lru_size
when CONFIG_MEMCG.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    6 ------
 include/linux/mm_inline.h  |   24 ++++++++++++++++++------
 mm/memcontrol.c            |    2 ++
 mm/vmscan.c                |   23 ++++++++++-------------
 4 files changed, 30 insertions(+), 25 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -658,12 +658,6 @@ mem_cgroup_get_lru_size(struct lruvec *l
 	return 0;
 }
 
-static inline void
-mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
-			      int increment)
-{
-}
-
 static inline unsigned long
 mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			     int nid, unsigned int lru_mask)
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -22,22 +22,34 @@ static inline int page_is_file_cache(str
 	return !PageSwapBacked(page);
 }
 
+static __always_inline void __update_lru_size(struct lruvec *lruvec,
+				enum lru_list lru, int nr_pages)
+{
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
+}
+
+static __always_inline void update_lru_size(struct lruvec *lruvec,
+				enum lru_list lru, int nr_pages)
+{
+#ifdef CONFIG_MEMCG
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+#else
+	__update_lru_size(lruvec, lru, nr_pages);
+#endif
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	int nr_pages = hpage_nr_pages(page);
-	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+	update_lru_size(lruvec, lru, hpage_nr_pages(page));
 	list_add(&page->lru, &lruvec->lists[lru]);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	int nr_pages = hpage_nr_pages(page);
 	list_del(&page->lru);
-	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
+	update_lru_size(lruvec, lru, -hpage_nr_pages(page));
 }
 
 /**
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1034,6 +1034,8 @@ void mem_cgroup_update_lru_size(struct l
 	long size;
 	bool empty;
 
+	__update_lru_size(lruvec, lru, nr_pages);
+
 	if (mem_cgroup_disabled())
 		return;
 
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1374,7 +1374,6 @@ static unsigned long isolate_lru_pages(u
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
 					!list_empty(src); scan++) {
 		struct page *page;
-		int nr_pages;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1383,10 +1382,8 @@ static unsigned long isolate_lru_pages(u
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
-			nr_pages = hpage_nr_pages(page);
-			mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
+			nr_taken += hpage_nr_pages(page);
 			list_move(&page->lru, dst);
-			nr_taken += nr_pages;
 			break;
 
 		case -EBUSY:
@@ -1602,8 +1599,9 @@ shrink_inactive_list(unsigned long nr_to
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
+	update_lru_size(lruvec, lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
@@ -1624,8 +1622,6 @@ shrink_inactive_list(unsigned long nr_to
 
 	spin_lock_irq(&zone->lru_lock);
 
-	reclaim_stat->recent_scanned[file] += nr_taken;
-
 	if (global_reclaim(sc)) {
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSTEAL_KSWAPD, zone,
@@ -1742,7 +1738,7 @@ static void move_active_pages_to_lru(str
 		SetPageLRU(page);
 
 		nr_pages = hpage_nr_pages(page);
-		mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+		update_lru_size(lruvec, lru, nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += nr_pages;
 
@@ -1760,7 +1756,7 @@ static void move_active_pages_to_lru(str
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1794,14 +1790,15 @@ static void shrink_active_list(unsigned
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
-	if (global_reclaim(sc))
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 
+	update_lru_size(lruvec, lru, -nr_taken);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
+	if (global_reclaim(sc))
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
