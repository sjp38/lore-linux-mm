Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16N7SI1007254
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:07:28 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16N7SHi213174
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:07:28 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16N7RFM030455
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:07:28 -0700
Date: Wed, 6 Feb 2008 15:07:26 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 1/2] Smarter retry of costly-order allocations
Message-ID: <20080206230726.GF3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: melgor@ie.ibm.com
Cc: apw@shadowen.org, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Smarter retry of costly-order allocations

Because of page order checks in __alloc_pages(), hugepage (and similarly
large order) allocations will not retry unless explicitly marked
__GFP_REPEAT. However, the current retry logic is nearly an infinite
loop (or until reclaim does no progress whatsoever). For these costly
allocations, that seems like overkill and could potentially never
terminate. Modify try_to_free_pages() to indicate what order of pages
were reclaimed and use that in __alloc_pages() to eventually fail large
allocations, when we've supposedly reclaimed a similar order of pages.
This relies on lumpy reclaim (and perhaps grouping of pages by
mobility?) functioning as advertised.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
The next patch makes hugepages uses __GFP_REPEAT and demonstrates the
difference

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 353153e..e6e8030 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -180,7 +180,7 @@ extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **zones, int order,
+extern int try_to_free_pages(struct zone **zones, int order,
 					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9153cb8..22b892b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1461,6 +1461,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 	int do_retry;
 	int alloc_flags;
 	int did_some_progress;
+	unsigned long pages_reclaimed = 0;
 
 	might_sleep_if(wait);
 
@@ -1569,7 +1570,7 @@ nofail_alloc:
 	if (order != 0)
 		drain_all_pages();
 
-	if (likely(did_some_progress)) {
+	if (likely(did_some_progress != 0)) {
 		page = get_page_from_freelist(gfp_mask, order,
 						zonelist, alloc_flags);
 		if (page)
@@ -1608,15 +1609,28 @@ nofail_alloc:
 	 * Don't let big-order allocations loop unless the caller explicitly
 	 * requests that.  Wait for some write requests to complete then retry.
 	 *
-	 * In this implementation, either order <= PAGE_ALLOC_COSTLY_ORDER or
-	 * __GFP_REPEAT mean __GFP_NOFAIL, but that may not be true in other
+	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
+	 * means __GFP_NOFAIL, but that may not be true in other
 	 * implementations.
+	 *
+	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
+	 * specified, then we retry until we no longer reclaim any pages
+	 * (above), or we've reclaimed an order of pages at least as
+	 * large as the allocation's order. In both cases, if the
+	 * allocation still fails, we stop retrying.
 	 */
+	if (did_some_progress != -EAGAIN)
+		pages_reclaimed += did_some_progress;
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
-		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
-						(gfp_mask & __GFP_REPEAT))
+		if (order <= PAGE_ALLOC_COSTLY_ORDER) {
 			do_retry = 1;
+		} else {
+			if (gfp_mask & __GFP_REPEAT &&
+				(did_some_progress == -EAGAIN ||
+				pages_reclaimed < (1 << order)))
+					do_retry = 1;
+		}
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5a9597..c9d67b4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1205,8 +1205,14 @@ static unsigned long shrink_zones(int priority, struct zone **zones,
  * hope that some of these pages can be written.  But if the allocating task
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
+ *
+ * returns:	0, if no pages reclaimed
+ * 		-EAGAIN, if insufficient pages were reclaimed to satisfy the
+ * 			order specified, but further reclaim might
+ * 			succeed
+ * 		else, the order of pages reclaimed
  */
-unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+int try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
 	int priority;
 	int ret = 0;
@@ -1248,7 +1254,7 @@ unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 		}
 		total_scanned += sc.nr_scanned;
 		if (nr_reclaimed >= sc.swap_cluster_max) {
-			ret = 1;
+			ret = nr_reclaimed;
 			goto out;
 		}
 
@@ -1270,8 +1276,12 @@ unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
-	if (!sc.all_unreclaimable)
-		ret = 1;
+	if (!sc.all_unreclaimable) {
+		if (nr_reclaimed >= (1 << order))
+			ret = nr_reclaimed;
+		else
+			ret = -EAGAIN;
+	}
 out:
 	/*
 	 * Now that we've scanned all the zones at this priority level, note

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
