Message-ID: <417F5604.3000908@yahoo.com.au>
Date: Wed, 27 Oct 2004 18:02:12 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 2/3] higher order watermarks
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au>
In-Reply-To: <417F55B9.7090306@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010402030903050409000306"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010402030903050409000306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/3

--------------010402030903050409000306
Content-Type: text/x-patch;
 name="vm-alloc-order-watermarks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-alloc-order-watermarks.patch"



Move the watermark checking code into a single function. Extend it to account
for the order of the allocation and the number of free pages that could satisfy
such a request.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/linux/mmzone.h |    2 +
 linux-2.6-npiggin/mm/page_alloc.c        |   58 ++++++++++++++++++++-----------
 2 files changed, 41 insertions(+), 19 deletions(-)

diff -puN mm/page_alloc.c~vm-alloc-order-watermarks mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-alloc-order-watermarks	2004-10-27 16:41:32.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-10-27 17:53:33.000000000 +1000
@@ -586,6 +586,37 @@ buffered_rmqueue(struct zone *zone, int 
 }
 
 /*
+ * Return 1 if free pages are above 'mark'. This takes into account the order
+ * of the allocation.
+ */
+int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+		int alloc_type, int can_try_harder, int gfp_high)
+{
+	/* free_pages my go negative - that's OK */
+	long min = mark, free_pages = z->free_pages - (1 << order) + 1;
+	int o;
+
+	if (gfp_high)
+		min -= min / 2;
+	if (can_try_harder)
+		min -= min / 4;
+
+	if (free_pages <= min + z->protection[alloc_type])
+		return 0;
+	for (o = 0; o < order; o++) {
+		/* At the next order, this order's pages become unavailable */
+		free_pages -= z->free_area[order].nr_free << o;
+
+		/* Require fewer higher order pages to be free */
+		min >>= 1;
+
+		if (free_pages <= min)
+			return 0;
+	}
+	return 1;
+}
+
+/*
  * This is the 'heart' of the zoned buddy allocator.
  *
  * Herein lies the mysterious "incremental min".  That's the
@@ -606,7 +637,6 @@ __alloc_pages(unsigned int gfp_mask, uns
 		struct zonelist *zonelist)
 {
 	const int wait = gfp_mask & __GFP_WAIT;
-	unsigned long min;
 	struct zone **zones, *z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
@@ -636,9 +666,9 @@ __alloc_pages(unsigned int gfp_mask, uns
 
 	/* Go through the zonelist once, looking for a zone with enough free */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
-		min = z->pages_low + (1<<order) + z->protection[alloc_type];
 
-		if (z->free_pages < min)
+		if (!zone_watermark_ok(z, order, z->pages_low,
+				alloc_type, 0, 0))
 			continue;
 
 		page = buffered_rmqueue(z, order, gfp_mask);
@@ -654,14 +684,9 @@ __alloc_pages(unsigned int gfp_mask, uns
 	 * coming from realtime tasks to go deeper into reserves
 	 */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
-		min = z->pages_min;
-		if (gfp_mask & __GFP_HIGH)
-			min /= 2;
-		if (can_try_harder)
-			min -= min / 4;
-		min += (1<<order) + z->protection[alloc_type];
-
-		if (z->free_pages < min)
+		if (!zone_watermark_ok(z, order, z->pages_min,
+				alloc_type, can_try_harder,
+				gfp_mask & __GFP_HIGH))
 			continue;
 
 		page = buffered_rmqueue(z, order, gfp_mask);
@@ -697,14 +722,9 @@ rebalance:
 
 	/* go through the zonelist yet one more time */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
-		min = z->pages_min;
-		if (gfp_mask & __GFP_HIGH)
-			min /= 2;
-		if (can_try_harder)
-			min -= min / 4;
-		min += (1<<order) + z->protection[alloc_type];
-
-		if (z->free_pages < min)
+		if (!zone_watermark_ok(z, order, z->pages_min,
+				alloc_type, can_try_harder,
+				gfp_mask & __GFP_HIGH))
 			continue;
 
 		page = buffered_rmqueue(z, order, gfp_mask);
diff -puN include/linux/mmzone.h~vm-alloc-order-watermarks include/linux/mmzone.h
--- linux-2.6/include/linux/mmzone.h~vm-alloc-order-watermarks	2004-10-27 16:41:32.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mmzone.h	2004-10-27 17:52:07.000000000 +1000
@@ -279,6 +279,8 @@ void get_zone_counts(unsigned long *acti
 			unsigned long *free);
 void build_all_zonelists(void);
 void wakeup_kswapd(struct zone *zone);
+int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+		int alloc_type, int can_try_harder, int gfp_high);
 
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.

_

--------------010402030903050409000306--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
