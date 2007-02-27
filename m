Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1RJYN3V023395
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:34:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1RJYNj7529074
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:34:23 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1RJYM4r026022
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:34:23 -0700
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/5] Lumpy Reclaim V3
References: <exportbomb.1172604830@kernel>
Message-ID: <96f80944962593738d72a803797dbddc@kernel>
Date: Tue, 27 Feb 2007 11:34:21 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When we are out of memory of a suitable size we enter reclaim.
The current reclaim algorithm targets pages in LRU order, which
is great for fairness but highly unsuitable if you desire pages at
higher orders.  To get pages of higher order we must shoot down a
very high proportion of memory; >95% in a lot of cases.

This patch set adds a lumpy reclaim algorithm to the allocator.
It targets groups of pages at the specified order anchored at the
end of the active and inactive lists.  This encourages groups of
pages at the requested orders to move from active to inactive,
and active to free lists.  This behaviour is only triggered out of
direct reclaim when higher order pages have been requested.

This patch set is particularly effective when utilised with
an anti-fragmentation scheme which groups pages of similar
reclaimability together.

This patch set is based on Peter Zijlstra's lumpy reclaim V2 patch
which forms the foundation.

[akpm@osdl.org: ia64 pfn_to_nid fixes and loop cleanup]
[bunk@stusta.de: static declarations for internal functions]

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---
diff --git a/fs/buffer.c b/fs/buffer.c
index 1b69d61..19d1d2c 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -363,7 +363,7 @@ static void free_more_memory(void)
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
 		if (*zones)
-			try_to_free_pages(zones, GFP_NOFS);
+			try_to_free_pages(zones, 0, GFP_NOFS);
 	}
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index eae023a..382a30b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -190,7 +190,8 @@ extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **, gfp_t);
+extern unsigned long try_to_free_pages(struct zone **zones, int order,
+					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 96451c5..887e435 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1415,7 +1415,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2c8f197..f15ffcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -68,6 +68,8 @@ struct scan_control {
 	int swappiness;
 
 	int all_unreclaimable;
+
+	int order;
 };
 
 /*
@@ -617,6 +619,36 @@ keep:
 }
 
 /*
+ * Attempt to remove the specified page from its LRU.  Only take this page
+ * if it is of the appropriate PageActive status.  Pages which are being
+ * freed elsewhere are also ignored.
+ *
+ * page:	page to consider
+ * active:	active/inactive flag only take pages of this type
+ *
+ * returns 0 on success, -ve errno on failure.
+ */
+static int __isolate_lru_page(struct page *page, int active)
+{
+	int ret = -EINVAL;
+
+	if (PageLRU(page) && (PageActive(page) == active)) {
+		ret = -EBUSY;
+		if (likely(get_page_unless_zero(page))) {
+			/*
+			 * Be careful not to clear PageLRU until after we're
+			 * sure the page is not being freed elsewhere -- the
+			 * page release code relies on it.
+			 */
+			ClearPageLRU(page);
+			ret = 0;
+		}
+	}
+
+	return ret;
+}
+
+/*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
@@ -630,38 +662,83 @@ keep:
  * @src:	The LRU list to pull pages off.
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
+ * @order:	The caller's attempted allocation order
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned)
+		unsigned long *scanned, int order)
 {
 	unsigned long nr_taken = 0;
-	struct page *page;
 	unsigned long scan;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
-		struct list_head *target;
+		struct page *page;
+		unsigned long pfn;
+		unsigned long end_pfn;
+		unsigned long page_pfn;
+		int active;
+		int zone_id;
+
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON(!PageLRU(page));
 
-		list_del(&page->lru);
-		target = src;
-		if (likely(get_page_unless_zero(page))) {
-			/*
-			 * Be careful not to clear PageLRU until after we're
-			 * sure the page is not being freed elsewhere -- the
-			 * page release code relies on it.
-			 */
-			ClearPageLRU(page);
-			target = dst;
+		active = PageActive(page);
+		switch (__isolate_lru_page(page, active)) {
+		case 0:
+			list_move(&page->lru, dst);
 			nr_taken++;
-		} /* else it is being freed elsewhere */
+			break;
+
+		case -EBUSY:
+			/* else it is being freed elsewhere */
+			list_move(&page->lru, src);
+			continue;
+
+		default:
+			BUG();
+		}
+
+		if (!order)
+			continue;
+
+		/*
+		 * Attempt to take all pages in the order aligned region
+		 * surrounding the tag page.  Only take those pages of
+		 * the same active state as that tag page.
+		 */
+		zone_id = page_zone_id(page);
+		page_pfn = page_to_pfn(page);
+		pfn = page_pfn & ~((1 << order) - 1);
+		end_pfn = pfn + (1 << order);
+		for (; pfn < end_pfn; pfn++) {
+			struct page *cursor_page;
+
+			if (unlikely(pfn == page_pfn))
+				continue;
+			if (unlikely(!pfn_valid(pfn)))
+				break;
 
-		list_add(&page->lru, target);
+			cursor_page = pfn_to_page(pfn);
+			if (unlikely(page_zone_id(cursor_page) != zone_id))
+				continue;
+			scan++;
+			switch (__isolate_lru_page(cursor_page, active)) {
+			case 0:
+				list_move(&cursor_page->lru, dst);
+				nr_taken++;
+				break;
+
+			case -EBUSY:
+				/* else it is being freed elsewhere */
+				list_move(&cursor_page->lru, src);
+			default:
+				break;
+			}
+		}
 	}
 
 	*scanned = scan;
@@ -692,7 +769,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 					     &zone->inactive_list,
-					     &page_list, &nr_scan);
+					     &page_list, &nr_scan, sc->order);
 		__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
 		zone->pages_scanned += nr_scan;
 		zone->total_scanned += nr_scan;
@@ -839,7 +916,7 @@ force_reclaim_mapped:
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
+				    &l_hold, &pgscanned, sc->order);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
@@ -1030,7 +1107,7 @@ static unsigned long shrink_zones(int priority, struct zone **zones,
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
 	int plugdepth;
 	int priority;
@@ -1046,6 +1123,7 @@ unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask)
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.may_swap = 1,
 		.swappiness = vm_swappiness,
+		.order = order,
 	};
 
 	delay_swap_prefetch();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
