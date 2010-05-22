Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 22EA86B01B5
	for <linux-mm@kvack.org>; Sat, 22 May 2010 14:09:02 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 22 May 2010 18:08:57 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 2/3] kernel/power/swap.c: do not use end_swap_bio_read
Date: Sat, 22 May 2010 15:08:50 -0300
Message-Id: <1274551731-4534-2-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4BF81D87.6010506@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

The swap checksum patches will change end_swap_bio_read to also verify
the page's checksum. This is not compatible with its use at submit()
from kernel/power/swap.c.

Make kernel/power/swap.c use a private copy of end_swap_bio_read, and
modify it to not say "Read-error" if the error was on a write.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 include/linux/swap.h |    1 -
 kernel/power/swap.c  |   21 ++++++++++++++++++++-
 mm/page_io.c         |    2 +-
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1f59d93..86a0d64 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -291,7 +291,6 @@ extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
-extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
 extern struct address_space swapper_space;
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 66824d7..7305a3f 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -147,6 +147,25 @@ int swsusp_swap_in_use(void)
 static unsigned short root_swap = 0xffff;
 static struct block_device *resume_bdev;
 
+static void end_swap_bio(struct bio *bio, int err)
+{
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct page *page = bio->bi_io_vec[0].bv_page;
+
+	if (!uptodate) {
+		SetPageError(page);
+		ClearPageUptodate(page);
+		printk(KERN_ALERT "%s-error on swap-device (%u:%u:%Lu)\n",
+				bio->bi_rw & BIO_RW ? "Write" : "Read",
+				imajor(bio->bi_bdev->bd_inode),
+				iminor(bio->bi_bdev->bd_inode),
+				(unsigned long long)bio->bi_sector);
+	} else {
+		SetPageUptodate(page);
+	}
+	unlock_page(page);
+	bio_put(bio);
+}
 /**
  *	submit - submit BIO request.
  *	@rw:	READ or WRITE.
@@ -167,7 +186,7 @@ static int submit(int rw, pgoff_t page_off, struct page *page,
 	bio = bio_alloc(__GFP_WAIT | __GFP_HIGH, 1);
 	bio->bi_sector = page_off * (PAGE_SIZE >> 9);
 	bio->bi_bdev = resume_bdev;
-	bio->bi_end_io = end_swap_bio_read;
+	bio->bi_end_io = end_swap_bio;
 
 	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
 		printk(KERN_ERR "PM: Adding page to bio failed at %ld\n",
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
