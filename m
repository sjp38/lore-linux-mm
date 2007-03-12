From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/3] Lumpy Reclaim V4
References: <exportbomb.1173723760@pinky>
Message-ID: <5239d2d31cd39bf4fc33426648f97be0@pinky>
Date: Mon, 12 Mar 2007 18:23:16 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When we are out of memory of a suitable size we enter reclaim.
The current reclaim algorithm targets pages in LRU order, which
is great for fairness at order-0 but highly unsuitable if you desire
pages at higher orders.  To get pages of higher order we must shoot
down a very high proportion of memory; >95% in a lot of cases.

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
which forms the foundation.  Credit to Mel Gorman for sanitity
checking.

[akpm@osdl.org: ia64 pfn_to_nid fixes and loop cleanup]
[bunk@stusta.de: static declarations for internal functions]
[a.p.zijlstra@chello.nl: initial lumpy V2 implementation]

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@osdl.org>

--- 8< ----
Changes in lumpy V4:

   Andy Whitcroft:
      lumpy: isolate_lru_pages wants to specifically take active or inactive pages
      lumpy: ensure that we compare PageActive and active safely
      lumpy: update commentry on subtle comparisons and rounding assumptions
      lumpy: only check for valid pages when holes are present

Changes in lumpy V3:

   Adrian Bunk:
      lumpy-reclaim-cleanup

   Andrew Morton:
      lumpy-reclaim-v2-page_to_pfn-fix
      lumpy-reclaim-v2-tidy

   Andy Whitcroft:
      lumpy: ensure we respect zone boundaries
      lumpy: take the other active/inactive pages in the area
---
diff --git a/fs/buffer.c b/fs/buffer.c
index 8666f62..a9273ab 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -371,7 +371,7 @@ static void free_more_memory(void)
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
 		if (*zones)
-			try_to_free_pages(zones, GFP_NOFS);
+			try_to_free_pages(zones, 0, GFP_NOFS);
 	}
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a461480..5b9ee5a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -189,7 +189,8 @@ extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **, gfp_t);
+extern unsigned long try_to_free_pages(struct zone **zones, int order,
+					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6abe947..23917f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1694,7 +1694,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 963a1c4..bda63a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -68,6 +68,8 @@ struct scan_control {
 	int swappiness;
 
 	int all_unreclaimable;
+
+	int order;
 };
 
 /*
@@ -611,6 +613,41 @@ keep:
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
+	/*
+	 * When checking the active state, we need to be sure we are
+	 * dealing with comparible boolean values.  Take the logical not
+	 * of each.
+	 */
+	if (PageLRU(page) && (!PageActive(page) == !active)) {
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
@@ -624,38 +661,88 @@ keep:
  * @src:	The LRU list to pull pages off.
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
+ * @order:	The caller's attempted allocation order
+ * @active:	The caller's trying to obtain active or inactive pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned)
+		unsigned long *scanned, int order, int active)
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
+		switch (__isolate_lru_page(page, active)) {
+		case 0:
+			list_move(&page->lru, dst);
 			nr_taken++;
-		} /* else it is being freed elsewhere */
+			break;
+
+		default:
+			/* page is being freed, or is a missmatch */
+			list_move(&page->lru, src);
+			continue;
+		}
+
+		if (!order)
+			continue;
 
-		list_add(&page->lru, target);
+		/*
+		 * Attempt to take all pages in the order aligned region
+		 * surrounding the tag page.  Only take those pages of
+		 * the same active state as that tag page.  We may safely
+		 * round the target page pfn down to the requested order
+		 * as the mem_map is guarenteed valid out to MAX_ORDER,
+		 * where that page is in a different zone we will detect
+		 * it from its zone id and abort this block scan.
+		 */
+		zone_id = page_zone_id(page);
+		page_pfn = page_to_pfn(page);
+		pfn = page_pfn & ~((1 << order) - 1);
+		end_pfn = pfn + (1 << order);
+		for (; pfn < end_pfn; pfn++) {
+			struct page *cursor_page;
+
+			/* The target page is in the block, ignore it. */
+			if (unlikely(pfn == page_pfn))
+				continue;
+#ifdef CONFIG_HOLES_IN_ZONE
+			/* Avoid holes within the zone. */
+			if (unlikely(!pfn_valid(pfn)))
+				break;
+#endif
+
+			cursor_page = pfn_to_page(pfn);
+			/* Check that we have not crossed a zone boundary. */
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
@@ -685,8 +772,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
-					     &page_list, &nr_scan);
+				     &zone->inactive_list,
+				     &page_list, &nr_scan, sc->order, 0);
 		__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
 		zone->pages_scanned += nr_scan;
 		zone->total_scanned += nr_scan;
@@ -833,7 +920,7 @@ force_reclaim_mapped:
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
+				    &l_hold, &pgscanned, sc->order, 1);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
@@ -1028,7 +1115,7 @@ static unsigned long shrink_zones(int priority, struct zone **zones,
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
 	int priority;
 	int ret = 0;
@@ -1043,6 +1130,7 @@ unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask)
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
