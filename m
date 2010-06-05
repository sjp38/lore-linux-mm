Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D153B6B01B2
	for <linux-mm@kvack.org>; Sat,  5 Jun 2010 19:14:48 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Jun 2010 23:14:44 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH v2 2/3] kernel/power/block_io.c: do not use end_swap_bio_read
Date: Sat,  5 Jun 2010 20:14:35 -0300
Message-Id: <1275779676-19120-2-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4C0ADA44.4020406@cesarb.net>
References: <4C0ADA44.4020406@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Hugh Dickins <hughd@google.com>, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

The swap checksum patches will change end_swap_bio_read to also verify
the page's checksum. This is not compatible with its use at submit()
from kernel/power/block_io.c.

Make kernel/power/block_io.c use a private copy of end_swap_bio_read,
and modify it to not say "Read-error" if the error was on a write.

Changes since -v1:
  Rebase to 2.6.35-rc1 (code moved from swap.c to block_io.c)
  Use bio_data_dir() instead of acessing bi_rw directly

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 include/linux/swap.h    |    1 -
 kernel/power/block_io.c |   22 +++++++++++++++++++++-
 mm/page_io.c            |    2 +-
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ff4acea..33a98a6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -293,7 +293,6 @@ extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
-extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
 extern struct address_space swapper_space;
diff --git a/kernel/power/block_io.c b/kernel/power/block_io.c
index 97024fd..18df8ac 100644
--- a/kernel/power/block_io.c
+++ b/kernel/power/block_io.c
@@ -14,6 +14,26 @@
 
 #include "power.h"
 
+static void end_swap_bio(struct bio *bio, int err)
+{
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct page *page = bio->bi_io_vec[0].bv_page;
+
+	if (!uptodate) {
+		SetPageError(page);
+		ClearPageUptodate(page);
+		printk(KERN_ALERT "%s-error on swap-device (%u:%u:%Lu)\n",
+				bio_data_dir(bio) == READ ? "Read" : "Write",
+				imajor(bio->bi_bdev->bd_inode),
+				iminor(bio->bi_bdev->bd_inode),
+				(unsigned long long)bio->bi_sector);
+	} else {
+		SetPageUptodate(page);
+	}
+	unlock_page(page);
+	bio_put(bio);
+}
+
 /**
  *	submit - submit BIO request.
  *	@rw:	READ or WRITE.
@@ -34,7 +54,7 @@ static int submit(int rw, struct block_device *bdev, sector_t sector,
 	bio = bio_alloc(__GFP_WAIT | __GFP_HIGH, 1);
 	bio->bi_sector = sector;
 	bio->bi_bdev = bdev;
-	bio->bi_end_io = end_swap_bio_read;
+	bio->bi_end_io = end_swap_bio;
 
 	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
 		printk(KERN_ERR "PM: Adding page to bio failed at %llu\n",
diff --git a/mm/page_io.c b/mm/page_io.c
index 31a3b96..0e2d4e8 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -66,7 +66,7 @@ static void end_swap_bio_write(struct bio *bio, int err)
 	bio_put(bio);
 }
 
-void end_swap_bio_read(struct bio *bio, int err)
+static void end_swap_bio_read(struct bio *bio, int err)
 {
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct page *page = bio->bi_io_vec[0].bv_page;
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
