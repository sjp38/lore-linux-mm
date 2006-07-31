Subject: [PATCH 2/1] mm: swap failure update
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1154005275.30621.19.camel@taijtu>
References: <1154005275.30621.19.camel@taijtu>
Content-Type: text/plain
Date: Mon, 31 Jul 2006 09:56:52 +0200
Message-Id: <1154332612.12981.1.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Update the error message on write-failure to also print the bio->bi_sector.
And insert an equivalent message on the read-failure path.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---
 mm/page_io.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -63,9 +63,10 @@ static int end_swap_bio_write(struct bio
 		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
 		 */
 		set_page_dirty(page);
-		printk(KERN_ALERT "Write-error on swap-device (%d:%d)\n",
+		printk(KERN_ALERT "Write-error on swap-device (%u:%u:%Lu)\n",
 				imajor(bio->bi_bdev->bd_inode),
-				iminor(bio->bi_bdev->bd_inode));
+				iminor(bio->bi_bdev->bd_inode),
+				bio->bi_sector);
 		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
@@ -84,6 +85,10 @@ static int end_swap_bio_read(struct bio 
 	if (!uptodate) {
 		SetPageError(page);
 		ClearPageUptodate(page);
+		printk(KERN_ALERT "Read-error on swap-device (%u:%u:%Lu)\n",
+				imajor(bio->bi_bdev->bd_inode),
+				iminor(bio->bi_bdev->bd_inode),
+				bio->bi_sector);
 	} else {
 		SetPageUptodate(page);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
