Message-ID: <39DC06B6.9D020C47@norran.net>
Date: Thu, 05 Oct 2000 06:42:30 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] test9: another vm lockup bug - squashed
Content-Type: multipart/mixed;
 boundary="------------56A75B241433DC47EA832D7D"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------56A75B241433DC47EA832D7D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This is applicable on Riels latest addition.
(freepages v. zone->"limit")
That is probably not needed, and you should be able
to change your limits with this patch.

This patch adds equality check in several comparisons.

It is strictly only the one in __alloc_pages_limit
that is needed, it interacts with the test in
free_shortage. Without this patch you get stuck on
exactly zone->pages_min. Too few pages to alloc and
too many to free...


Ying Chen has reported that this patch cures his problem.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------56A75B241433DC47EA832D7D
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test9-vmfix.rl"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test9-vmfix.rl"

--- linux/mm/page_alloc.c.orig	Wed Oct  4 21:27:41 2000
+++ linux/mm/page_alloc.c	Wed Oct  4 21:32:17 2000
@@ -268,7 +268,7 @@ static struct page * __alloc_pages_limit
 				water_mark = z->pages_high;
 		}
 
-		if (z->free_pages + z->inactive_clean_pages > water_mark) {
+		if (z->free_pages + z->inactive_clean_pages >= water_mark) {
 			struct page *page = NULL;
 			/* If possible, reclaim a page directly. */
 			if (direct_reclaim && z->free_pages < z->pages_min + 8)
@@ -329,7 +329,7 @@ struct page * __alloc_pages(zonelist_t *
 	 * wake up bdflush.
 	 */
 	else if (free_shortage() && nr_inactive_dirty_pages > free_shortage()
-			&& nr_inactive_dirty_pages > freepages.high)
+			&& nr_inactive_dirty_pages >= freepages.high)
 		wakeup_bdflush(0);
 
 try_again:
@@ -347,7 +347,7 @@ try_again:
 		if (!z->size)
 			BUG();
 
-		if (z->free_pages > z->pages_low) {
+		if (z->free_pages >= z->pages_low) {
 			page = rmqueue(z, order);
 			if (page)
 				return page;

--------------56A75B241433DC47EA832D7D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
