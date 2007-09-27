Date: Thu, 27 Sep 2007 19:08:57 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] kswapd should only wait on IO if there is IO
Message-ID: <20070927190857.74a04166@bree.surriel.com>
In-Reply-To: <20070927155907.a4dce0d8.akpm@linux-foundation.org>
References: <20070927170816.055548fd@bree.surriel.com>
	<20070927144702.a9124c7a.akpm@linux-foundation.org>
	<20070927181325.21aae460@bree.surriel.com>
	<20070927152121.3f5b6830.akpm@linux-foundation.org>
	<20070927185027.1a1b4c13@bree.surriel.com>
	<20070927155907.a4dce0d8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Sep 2007 15:59:07 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> And lost the changelog ;)

Good point.

The current kswapd (and try_to_free_pages) code has an oddity where the
code will wait on IO, even if there is no IO in flight.  This problem is
notable especially when the system scans through many unfreeable pages,
causing unnecessary stalls in the VM.

Additionally, tasks without __GFP_FS or __GFP_IO in the direct reclaim
path will sleep if a significant number of pages are encountered that
should be written out.  This gives kswapd a chance to write out those
pages, while the direct reclaim task sleeps.

Signed-off-by: Rik van Riel <riel@redhat.com>

diff -up linux-2.6.22/mm/vmscan.c.wait linux-2.6.22/mm/vmscan.c
--- linux-2.6.22/mm/vmscan.c.wait	2007-09-27 18:45:57.000000000 -0400
+++ linux-2.6.22/mm/vmscan.c	2007-09-27 18:48:43.000000000 -0400
@@ -68,6 +68,13 @@ struct scan_control {
 	int all_unreclaimable;
 
 	int order;
+
+	/*
+	 * Pages that have (or should have) IO pending.  If we run into
+	 * a lot of these, we're better off waiting a little for IO to
+	 * finish rather than scanning more pages in the VM.
+	 */
+	int nr_io_pages;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -489,8 +496,10 @@ static unsigned long shrink_page_list(st
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
@@ -529,8 +538,10 @@ static unsigned long shrink_page_list(st
 		if (PageDirty(page)) {
 			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
 				goto keep_locked;
-			if (!may_enter_fs)
+			if (!may_enter_fs) {
+				sc->nr_io_pages++;
 				goto keep_locked;
+			}
 			if (!sc->may_writepage)
 				goto keep_locked;
 
@@ -541,8 +552,10 @@ static unsigned long shrink_page_list(st
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
@@ -1201,6 +1214,7 @@ unsigned long try_to_free_pages(struct z
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.nr_scanned = 0;
+		sc.nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
@@ -1229,7 +1243,8 @@ unsigned long try_to_free_pages(struct z
 		}
 
 		/* Take a nap, wait for some writeback to complete */
-		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
+		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 &&
+				sc.nr_io_pages > sc.swap_cluster_max)
 			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
@@ -1315,6 +1330,7 @@ loop_again:
 		if (!priority)
 			disable_swap_token();
 
+		sc.nr_io_pages = 0;
 		all_zones_ok = 1;
 
 		/*
@@ -1398,7 +1414,8 @@ loop_again:
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
