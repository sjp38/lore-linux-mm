Received: from surriel.ddts.net (unknown [200.181.137.248])
	by netbank.com.br (Postfix) with ESMTP id 5AE324686A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2001 22:08:34 -0300 (BRST)
Received: from localhost (ondips@localhost [127.0.0.1])
	by surriel.ddts.net (8.11.2/8.11.2) with ESMTP id f3R186Y18519
	for <linux-mm@kvack.org>; Thu, 26 Apr 2001 22:08:06 -0300
Date: Thu, 26 Apr 2001 22:08:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] bgaging + balance  v2
Message-ID: <Pine.LNX.4.21.0104262206310.19012-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

in my patch yesterday evening there was a big mistake;
the old line calculating maxscan wasn't removed, so all
the fancy recalculation wouldn't do anything ;)

A new patch with this one line fixed is below.

Thanks to Adrian Drzewiecki for discovering this one...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/



--- linux-2.4.4-pre7/mm/vmscan.c.orig	Wed Apr 25 23:59:48 2001
+++ linux-2.4.4-pre7/mm/vmscan.c	Thu Apr 26 22:06:23 2001
@@ -24,6 +24,8 @@
 
 #include <asm/pgalloc.h>
 
+#define MAX(a,b) ((a) > (b) ? (a) : (b))
+
 /*
  * The swap-out function returns 1 if it successfully
  * scanned all the pages it was asked to (`count').
@@ -631,21 +633,48 @@
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
-	maxscan = nr_active_pages >> priority;
 	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
 		page = list_entry(page_lru, struct page, lru);
 
@@ -690,14 +719,13 @@
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
@@ -805,10 +833,9 @@
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
