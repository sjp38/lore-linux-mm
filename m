Subject: [RFC] mm - background_writeout exits when pages_skipped ?
From: richard kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Thu, 11 Oct 2007 18:19:34 +0100
Message-Id: <1192123174.3082.41.camel@castor.rsk.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When background_writeout() (mm/page-writeback.c) finds any pages_skipped
in writeback_inodes() and it didn't meet any congestion, it exits even
when it hasn't written enough pages yet.

Performing 2 ( or more) concurrent copies of a large file, often creates
lots of skipped pages (1000+) making background_writeout exit and so
pages don't get written out until we reach dirty_ratio.

I added some instrumentation to fs/buffer.c in
__block_write_full_page(..) and all the skipped pages come from here :-

done:
	if (nr_underway == 0) {
		/*
		 * The page was marked dirty, but the buffers were
		 * clean.  Someone wrote them back by hand with
		 * ll_rw_block/submit_bh.  A rare case.
		 */
		end_page_writeback(page);

		/*
		 * The page and buffer_heads can be released at any time from
		 * here on.
		 */
		wbc->pages_skipped++;	/* We didn't write this page */

maybe not such a rare case! :)

I've been testing 2.6.23 on an AMD64x2.

Here's a quick patch for background_writeout to ignore pages_skipped. It
helps keep nr_dirty between dirty_background_ratio & dirty_ratio, and
once the copies have finish nr_dirty quickly drops back to
dirty_background_ratio.

Without the patch during the copy nr_dirty stays around dirty_ratio and
takes a long time to drop after it finishes.   

It seems that this patch tackles the problem, but is there a better way
to fix it? 
And is there a good reason to abandon this writeout loop if a page gets
skipped for any other reason? 

thanks
richard



diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4472036..5a6747b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -371,6 +371,7 @@ static void background_writeout(unsigned long _min_pages)
 		.nr_to_write	= 0,
 		.nonblocking	= 1,
 		.range_cyclic	= 1,
+		.encountered_congestion = 0,
 	};
 
 	for ( ; ; ) {
@@ -382,17 +383,16 @@ static void background_writeout(unsigned long _min_pages)
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
 			break;
-		wbc.encountered_congestion = 0;
+		if (wbc.encountered_congestion) {
+			congestion_wait(WRITE, HZ/10);
+			wbc.encountered_congestion = 0;
+		}
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
 		writeback_inodes(&wbc);
 		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
-		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
-			/* Wrote less than expected */
-			congestion_wait(WRITE, HZ/10);
-			if (!wbc.encountered_congestion)
-				break;
-		}
+		if (wbc.nr_to_write > 0 && !wbc.encountered_congestion)
+			break;
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
