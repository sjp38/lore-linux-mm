Date: Tue, 14 Aug 2001 03:41:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] "drop behind" for buffers
Message-ID: <Pine.LNX.4.33L.0108140339250.6118-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

the patch below bypasses page aging and drops buffers directly
onto the inactive_dirty list when we have an excessive amount
of buffercache pages.

This should provide some of the benefits of drop behind for
buffercache pages, while still giving the buffercache pages
a good chance to stay resident in memory by being referenced
while on the inactive_dirty list (and moved back onto the
active list).

regards,

Rik
--
IA64: a worthy successor to i860.


--- linux/mm/vmscan.c.buffer	Thu Aug  9 17:54:24 2001
+++ linux/mm/vmscan.c	Thu Aug  9 17:55:09 2001
@@ -708,6 +708,8 @@
  * This function will scan a portion of the active list to find
  * unused pages, those pages will then be moved to the inactive list.
  */
+#define too_many_buffers (atomic_read(&buffermem_pages) > \
+		(num_physpages * buffer_mem.borrow_percent / 100))
 int refill_inactive_scan(zone_t *zone, unsigned int priority, int target)
 {
 	struct list_head * page_lru;
@@ -770,6 +772,18 @@
 				page_active = 1;
 			}
 		}
+
+		/*
+		 * If the amount of buffer cache pages is too
+		 * high we just move every buffer cache page we
+		 * find to the inactive list. Eventually they'll
+		 * be reclaimed there...
+		 */
+		if (page->buffers && !page->mapping && too_many_buffers) {
+			deactivate_page_nolock(page);
+			page_active = 0;
+		}
+
 		/*
 		 * If the page is still on the active list, move it
 		 * to the other end of the list. Otherwise we exit if

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
