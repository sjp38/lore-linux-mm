Subject: [PATCH] mm: swap write failure fixup
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Thu, 27 Jul 2006 15:01:15 +0200
Message-Id: <1154005275.30621.19.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Currently we can silently drop data if the write to swap failed. It usually
doesn't result in data-corruption because on page-in the process will receive
SIGBUS (assuming write-failure implies read-failure).

This assumption might or might not be valid.

This patch will avoid the page being discarded after a failed write. But
will print a warning the sysadmin _should_ take to heart, if a lot of swap
space becomes un-writeable, OOM is not far off.

Tested by making the write fail 'randomly' once every 50 writes or so.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_io.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -52,8 +52,22 @@ static int end_swap_bio_write(struct bio
 	if (bio->bi_size)
 		return 1;
 
-	if (!uptodate)
+	if (!uptodate) {
 		SetPageError(page);
+		/*
+		 * We failed to write the page out to swap-space.
+		 * Re-dirty the page in order to avoid it being reclaimed.
+		 * Also print a dire warning that things will go BAD (tm)
+		 * very quickly.
+		 *
+		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
+		 */
+		set_page_dirty(page);
+		printk(KERN_ALERT "Write-error on swap-device (%d:%d)\n",
+				imajor(bio->bi_bdev->bd_inode),
+				iminor(bio->bi_bdev->bd_inode));
+		ClearPageReclaim(page);
+	}
 	end_page_writeback(page);
 	bio_put(bio);
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
