Message-ID: <39EBA758.D0B89C1F@norran.net>
Date: Tue, 17 Oct 2000 03:11:52 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH/RFC] 2.4.0-test10-pre3 vmfix?
Content-Type: multipart/mixed;
 boundary="------------3C8966813D5A963A433B7929"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------3C8966813D5A963A433B7929
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Attached is patch that does the included part below.
With the addition of some questions to Riel and addition of
inactive_target in SysRq-M output.

Back to the included part. It is from __alloc_pages_limit
with the original code - won't the test fail always until
free_pages == pages_min + 8 resulting in only allocating from
free pages - no reclaims, might be ok.

When this situation is reached it will only reclaim_pages
and the different limits will give little effect.

The patch below will give a more interesting allocations.
When water_mark is PAGES_HIGH then first alloc pages from
free until pages_high, then if direct_reclaim is allowed
from inactive_clean else continue to use free pages.
If the freeable pages gets below pages_high, retry with
new limit...

It gives comparable performance with plain test10, but with
more pages free. Limits can be trimmed down...

Note: that you could/should remove the first loop in
__alloc_pages, not tried it should really be done with
this patch - problem is where to start kreclaimd...

/RogerL

--- linux/mm/page_alloc.c.orig  Mon Oct 16 23:54:03 2000
+++ linux/mm/page_alloc.c       Tue Oct 17 01:16:13 2000
@@ -264,7 +264,8 @@ static struct page * __alloc_pages_limit
                if (z->free_pages + z->inactive_clean_pages >=
water_mark) {
                        struct page *page = NULL;
                        /* If possible, reclaim a page directly. */
-                       if (direct_reclaim && z->free_pages <
z->pages_min + 8)
+                       /* Riel: the magical "+ 8" please explain */
+                       if (direct_reclaim && z->free_pages < water_mark
+ 8)
                                page = reclaim_page(z);
                        /* If that fails, fall back to rmqueue. */
                        if (!page)

--
Home page:
  http://www.norran.net/nra02596/
--------------3C8966813D5A963A433B7929
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test10-pre3-vmfix.rl"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test10-pre3-vmfix.rl"

--- linux/mm/page_alloc.c.orig	Mon Oct 16 23:54:03 2000
+++ linux/mm/page_alloc.c	Tue Oct 17 01:16:13 2000
@@ -264,7 +264,8 @@ static struct page * __alloc_pages_limit
 		if (z->free_pages + z->inactive_clean_pages >= water_mark) {
 			struct page *page = NULL;
 			/* If possible, reclaim a page directly. */
-			if (direct_reclaim && z->free_pages < z->pages_min + 8)
+			/* Riel: the magical "+ 8" please explain */ 
+			if (direct_reclaim && z->free_pages < water_mark + 8)
 				page = reclaim_page(z);
 			/* If that fails, fall back to rmqueue. */
 			if (!page)
@@ -340,6 +341,8 @@ try_again:
 		if (!z->size)
 			BUG();
 
+		/* Riel: what about using z->pages_min instead of low when
+		 * !direct_reclaim or are they too common? */
 		if (z->free_pages >= z->pages_low) {
 			page = rmqueue(z, order);
 			if (page)
@@ -382,7 +385,7 @@ try_again:
 	 * resolve this situation before memory gets tight.
 	 *
 	 * We also yield the CPU, because that:
-	 * - gives kswapd a chance to do something
+	 * - gives kswapd/kreclaimd/bdflush a chance to do something
 	 * - slows down allocations, in particular the
 	 *   allocations from the fast allocator that's
 	 *   causing the problems ...
@@ -666,14 +669,15 @@ void show_free_areas_core(pg_data_t *pgd
 		nr_free_pages() << (PAGE_SHIFT-10),
 		nr_free_highpages() << (PAGE_SHIFT-10));
 
-	printk("( Active: %d, inactive_dirty: %d, inactive_clean: %d, free: %d (%d %d %d) )\n",
+	printk("( Active: %d, inactive_dirty: %d, inactive_clean: %d, free: %d (%d %d %d) inactive_target: %d)\n",
 		nr_active_pages,
 		nr_inactive_dirty_pages,
 		nr_inactive_clean_pages(),
 		nr_free_pages(),
 		freepages.min,
 		freepages.low,
-		freepages.high);
+		freepages.high,
+	       inactive_target);
 
 	for (type = 0; type < MAX_NR_ZONES; type++) {
 		struct list_head *head, *curr;

--------------3C8966813D5A963A433B7929--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
