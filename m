Date: Thu, 27 Sep 2007 17:08:16 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] kswapd should only wait on IO if there is IO
Message-ID: <20070927170816.055548fd@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The current kswapd (and try_to_free_pages) code has an oddity where the
code will wait on IO, even if there is no IO in flight.  This problem is
notable especially when the system scans through many unfreeable pages,
causing unnecessary stalls in the VM.

Signed-off-by: Rik van Riel <riel@surriel.com>

diff -up linux-2.6.22.x86_64/mm/vmscan.c.wait linux-2.6.22.x86_64/mm/vmscan.c
--- linux-2.6.22.x86_64/mm/vmscan.c.wait	2007-09-25 11:33:30.000000000 -0400
+++ linux-2.6.22.x86_64/mm/vmscan.c	2007-09-25 21:27:08.000000000 -0400
@@ -68,6 +68,8 @@ struct scan_control {
 	int all_unreclaimable;
 
 	int order;
+
+	int nr_io_pages;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -489,8 +491,10 @@ static unsigned long shrink_page_list(st
 			 */
 			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
 				wait_on_page_writeback(page);
-			else
+			else {
+				sc->nr_io_pages++;
 				goto keep_locked;
+			}
 		}
 
 		referenced = page_referenced(page, 1);
@@ -541,8 +545,10 @@ static unsigned long shrink_page_list(st
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
-				if (PageWriteback(page) || PageDirty(page))
+				if (PageWriteback(page) || PageDirty(page)) {
+					sc->nr_io_pages++;
 					goto keep;
+				}
 				/*
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
@@ -1201,6 +1207,7 @@ unsigned long try_to_free_pages(struct z
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.nr_scanned = 0;
+		sc.nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
@@ -1229,7 +1236,8 @@ unsigned long try_to_free_pages(struct z
 		}
 
 		/* Take a nap, wait for some writeback to complete */
-		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
+		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 &&
+				sc.nr_io_pages > sc.swap_cluster_max)
 			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
@@ -1315,6 +1323,7 @@ loop_again:
 		if (!priority)
 			disable_swap_token();
 
+		sc.nr_io_pages = 0;
 		all_zones_ok = 1;
 
 		/*
@@ -1398,7 +1407,8 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
+		if (total_scanned && priority < DEF_PRIORITY - 2 &&
+					sc.nr_io_pages > sc.swap_cluster_max)
 			congestion_wait(WRITE, HZ/10);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
