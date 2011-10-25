Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CB2C36B0030
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 22:52:06 -0400 (EDT)
Subject: [patch 5/5]thp: split huge page if head page is isolated
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Oct 2011 10:59:40 +0800
Message-ID: <1319511580.22361.141.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

With current logic, if page reclaim finds a huge page, it will just reclaim
the head page and leave tail pages reclaimed later. Let's take an example,
lru list has page A and B, page A is huge page:
1. page A is isolated
2. page B is isolated
3. shrink_page_list() adds page A to swap page cache. so page A is split.
page A+1, page A+2, ... are added to lru list.
4. shrink_page_list() adds page B to swap page cache.
5. page A and B is written out and reclaimed.
6. page A+1, A+2 ... is isolated and reclaimed later.
So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...

We expected the whole huge page A is reclaimed in the meantime, so
the order is A, A+1, ... A+HPAGE_PMD_NR-1, B, ....

With this patch, we do huge page split just after the head page is isolated
for inactive lru list, so the tail pages will be reclaimed immediately.

In a test, a range of anonymous memory is written and will trigger swap.
Without the patch:
#cat /proc/vmstat|grep thp
thp_fault_alloc 451
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 238

With the patch:
#cat /proc/vmstat|grep thp
thp_fault_alloc 450
thp_fault_fallback 1
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 103

So the thp_split number is reduced a lot, though there is one extra
thp_fault_fallback.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/memcontrol.h |    3 +-
 mm/memcontrol.c            |   12 +++++++++--
 mm/vmscan.c                |   49 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 50 insertions(+), 14 deletions(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-10-25 08:36:08.000000000 +0800
+++ linux/mm/vmscan.c	2011-10-25 09:51:44.000000000 +0800
@@ -1076,7 +1076,8 @@ int __isolate_lru_page(struct page *page
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode, int file)
+		unsigned long *scanned, int order, int mode, int file,
+		struct page **split_page)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1100,7 +1101,12 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
-			nr_taken += hpage_nr_pages(page);
+			if (PageTransHuge(page) && split_page) {
+				nr_taken++;
+				*split_page = page;
+				goto out;
+			} else
+				nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
@@ -1158,11 +1164,16 @@ static unsigned long isolate_lru_pages(u
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
-				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
 					nr_lumpy_dirty++;
 				scan++;
+				if (PageTransHuge(page) && split_page) {
+					nr_taken++;
+					*split_page = page;
+					goto out;
+				} else
+					nr_taken += hpage_nr_pages(page);
 			} else {
 				/*
 				 * Check if the page is freed already.
@@ -1188,6 +1199,7 @@ static unsigned long isolate_lru_pages(u
 			nr_lumpy_failed++;
 	}
 
+out:
 	*scanned = scan;
 
 	trace_mm_vmscan_lru_isolate(order,
@@ -1202,7 +1214,8 @@ static unsigned long isolate_pages_globa
 					struct list_head *dst,
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
-					int active, int file)
+					int active, int file,
+					struct page **split_page)
 {
 	int lru = LRU_BASE;
 	if (active)
@@ -1210,7 +1223,7 @@ static unsigned long isolate_pages_globa
 	if (file)
 		lru += LRU_FILE;
 	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+							mode, file, split_page);
 }
 
 /*
@@ -1444,10 +1457,12 @@ shrink_inactive_list(unsigned long nr_to
 {
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
+	unsigned long total_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	struct page *split_page;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1458,16 +1473,19 @@ shrink_inactive_list(unsigned long nr_to
 	}
 
 	set_reclaim_mode(priority, sc, false);
+again:
 	lru_add_drain();
+	split_page = NULL;
 	spin_lock_irq(&zone->lru_lock);
 
 	if (scanning_global_lru(sc)) {
-		nr_taken = isolate_pages_global(nr_to_scan,
+		nr_taken = isolate_pages_global(nr_to_scan - total_scanned,
 			&page_list, &nr_scanned, sc->order,
 			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, 0, file);
+			zone, 0, file, &split_page);
 		zone->pages_scanned += nr_scanned;
+		total_scanned += nr_scanned;
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
 					       nr_scanned);
@@ -1475,12 +1493,13 @@ shrink_inactive_list(unsigned long nr_to
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
 	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
+		nr_taken = mem_cgroup_isolate_pages(nr_to_scan - total_scanned,
 			&page_list, &nr_scanned, sc->order,
 			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, sc->mem_cgroup,
-			0, file);
+			0, file, &split_page);
+		total_scanned += nr_scanned;
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
@@ -1491,11 +1510,19 @@ shrink_inactive_list(unsigned long nr_to
 		spin_unlock_irq(&zone->lru_lock);
 		return 0;
 	}
+	if (split_page && total_scanned < nr_to_scan) {
+		spin_unlock_irq(&zone->lru_lock);
+		split_huge_page(split_page);
+		goto again;
+	}
 
 	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
 
 	spin_unlock_irq(&zone->lru_lock);
 
+	if (split_page)
+		split_huge_page(split_page);
+
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc);
 
 	/* Check if we should syncronously wait for writeback */
@@ -1589,13 +1616,13 @@ static void shrink_active_list(unsigned
 		nr_taken = isolate_pages_global(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						ISOLATE_ACTIVE, zone,
-						1, file);
+						1, file, NULL);
 		zone->pages_scanned += pgscanned;
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						ISOLATE_ACTIVE, zone,
-						sc->mem_cgroup, 1, file);
+						sc->mem_cgroup, 1, file, NULL);
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
Index: linux/mm/memcontrol.c
===================================================================
--- linux.orig/mm/memcontrol.c	2011-10-25 08:36:08.000000000 +0800
+++ linux/mm/memcontrol.c	2011-10-25 09:33:51.000000000 +0800
@@ -1187,7 +1187,8 @@ unsigned long mem_cgroup_isolate_pages(u
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active, int file)
+					int active, int file,
+					struct page **split_page)
 {
 	unsigned long nr_taken = 0;
 	struct page *page;
@@ -1224,7 +1225,13 @@ unsigned long mem_cgroup_isolate_pages(u
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
-			nr_taken += hpage_nr_pages(page);
+			if (PageTransHuge(page) && split_page) {
+				nr_taken++;
+				*split_page = page;
+				goto out;
+			} else
+				nr_taken += hpage_nr_pages(page);
+
 			break;
 		case -EBUSY:
 			/* we don't affect global LRU but rotate in our LRU */
@@ -1235,6 +1242,7 @@ unsigned long mem_cgroup_isolate_pages(u
 		}
 	}
 
+out:
 	*scanned = scan;
 
 	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
Index: linux/include/linux/memcontrol.h
===================================================================
--- linux.orig/include/linux/memcontrol.h	2011-10-25 08:36:08.000000000 +0800
+++ linux/include/linux/memcontrol.h	2011-10-25 09:33:51.000000000 +0800
@@ -37,7 +37,8 @@ extern unsigned long mem_cgroup_isolate_
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active, int file);
+					int active, int file,
+					struct page **split_page);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
