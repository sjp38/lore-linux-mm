Received: from surriel.ddts.net (unknown [200.181.137.248])
	by netbank.com.br (Postfix) with ESMTP id D480B46807
	for <linux-mm@kvack.org>; Thu, 26 Apr 2001 00:50:09 -0300 (BRST)
Received: from localhost (erztvl@localhost [127.0.0.1])
	by surriel.ddts.net (8.11.2/8.11.2) with ESMTP id f3Q3nUY27043
	for <linux-mm@kvack.org>; Thu, 26 Apr 2001 00:49:30 -0300
Date: Thu, 26 Apr 2001 00:49:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] refill_inactive balance + background aging
Message-ID: <Pine.LNX.4.21.0104260036300.19012-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch, against 2.4.4-pre7, does the following things:

- fix the background aging to only work to _increase_ the
  page aging information in the system ... if we have lots
  of inactive pages we scan less ... if we have even more
  inactive pages we stop with background scanning

- change refill_inactive_scan to take a count of the number
  of pages to deactivate as an argument, this gets rid of
  the somewhat cryptic "oneshot" argument and semantics

- change the loop in refill_inactive to use this count
  argument ... now we call swap_out and refill_inactive_scan
  in the same way, which makes the balancing in refill_inactive
  a LOT easier to understand

To illustrate this last point, previously refill_inactive_scan
only had to find _1_ page that could be deactivated every time
it was called in order to be called indefinately ... this can
mean 1 page at the end of every scan, which in turn means that
we'll scan all active pages pretty much in a loop without ever
realising that we might want to try swap_out() and make a few
little-used mapped pages freeable ...

Now both functions are called in the same way and it should be
possible again to understand and tune the balancing in any way
that makes sense.

Please try this patch on your workload and tell me how it works
for you, it is important to get this balancing part of the VM
better ASAP...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/



--- linux-2.4.4-pre7/mm/vmscan.c.orig	Wed Apr 25 23:59:48 2001
+++ linux-2.4.4-pre7/mm/vmscan.c	Thu Apr 26 00:31:31 2001
@@ -24,6 +24,8 @@
 
 #include <asm/pgalloc.h>
 
+#define MAX(a,b) ((a) > (b) ? (a) : (b))
+
 /*
  * The swap-out function returns 1 if it successfully
  * scanned all the pages it was asked to (`count').
@@ -631,17 +633,45 @@
 /**
  * refill_inactive_scan - scan the active list and find pages to deactivate
  * @priority: the priority at which to scan
- * @oneshot: exit after deactivating one page
+ * @count: the number of pages to deactivate
  *
  * This function will scan a portion of the active list to find
  * unused pages, those pages will then be moved to the inactive list.
  */
-int refill_inactive_scan(unsigned int priority, int oneshot)
+int refill_inactive_scan(unsigned int priority, int count)
 {
 	struct list_head * page_lru;
 	struct page * page;
-	int maxscan, page_active = 0;
-	int ret = 0;
+	int maxscan = nr_active_pages >> priority;
+	int page_active = 0;
+
+	/*
+	 * If no count was specified, we do background page aging.
+	 * This is done so, after periods of little VM activity, we
+	 * know which pages to swap out and we can handle load spikes.
+	 * However, if we scan unlimited and deactivate all pages,
+	 * we still wouldn't know which pages to swap ...
+	 *
+	 * The obvious solution is to do less background scanning when
+	 * we have lots of inactive pages and to completely stop if we
+	 * have tons of them...
+	 */
+	if (!count) {
+		int nr_active, nr_inactive;
+		
+		/* Active pages can be "hidden" in ptes, take a saner number. */
+		nr_active = MAX(nr_active_pages, num_physpages / 2);
+		nr_inactive = nr_inactive_dirty_pages + nr_free_pages() +
+					nr_inactive_clean_pages();
+
+		if (nr_inactive * 10 < nr_active) {
+			maxscan = nr_active_pages >> 4;
+		} else if (nr_inactive * 3 < nr_active_pages) {
+			maxscan = nr_active >> 8;
+		} else {
+			maxscan = 0;
+		}
+	}
 
 	/* Take the lock while messing with the list... */
 	spin_lock(&pagemap_lru_lock);
@@ -690,14 +720,13 @@
 			list_del(page_lru);
 			list_add(page_lru, &active_list);
 		} else {
-			ret = 1;
-			if (oneshot)
+			if (--count <= 0)
 				break;
 		}
 	}
 	spin_unlock(&pagemap_lru_lock);
 
-	return ret;
+	return count;
 }
 
 /*
@@ -805,10 +834,9 @@
 			schedule();
 		}
 
-		while (refill_inactive_scan(DEF_PRIORITY, 1)) {
-			if (--count <= 0)
-				goto done;
-		}
+		count -= refill_inactive_scan(DEF_PRIORITY, count);
+		if (--count <= 0)
+			goto done;
 
 		/* If refill_inactive_scan failed, try to page stuff out.. */
 		swap_out(DEF_PRIORITY, gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
