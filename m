Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1B506B0027
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:14 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c9so16220519qth.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c18si1111870qtp.433.2018.04.04.12.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:14 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 29/79] fs/block: add struct address_space to bdev_write_page() arguments
Date: Wed,  4 Apr 2018 15:18:03 -0400
Message-Id: <20180404191831.5378-14-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to bdev_write_page() arguments.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/block_dev.c         | 4 +++-
 fs/mpage.c             | 2 +-
 include/linux/blkdev.h | 5 +++--
 mm/page_io.c           | 7 ++++---
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 9ac6bf760272..502b6643bc74 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -678,6 +678,7 @@ EXPORT_SYMBOL_GPL(bdev_read_page);
  * bdev_write_page() - Start writing a page to a block device
  * @bdev: The device to write the page to
  * @sector: The offset on the device to write the page to (need not be aligned)
+ * @mapping: The address space the page belongs to
  * @page: The page to write
  * @wbc: The writeback_control for the write
  *
@@ -694,7 +695,8 @@ EXPORT_SYMBOL_GPL(bdev_read_page);
  * Return: negative errno if an error occurs, 0 if submission was successful.
  */
 int bdev_write_page(struct block_device *bdev, sector_t sector,
-			struct page *page, struct writeback_control *wbc)
+			struct address_space *mapping, struct page *page,
+			struct writeback_control *wbc)
 {
 	int result;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
diff --git a/fs/mpage.c b/fs/mpage.c
index 52a6028e2066..a75cea232f1a 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -619,7 +619,7 @@ static int __mpage_writepage(struct page *page, struct address_space *_mapping,
 	if (bio == NULL) {
 		if (first_unmapped == blocks_per_page) {
 			if (!bdev_write_page(bdev, blocks[0] << (blkbits - 9),
-								page, wbc))
+						mapping, page, wbc))
 				goto out;
 		}
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index ed63f3b69c12..0cf66b6993f4 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -2053,8 +2053,9 @@ struct block_device_operations {
 extern int __blkdev_driver_ioctl(struct block_device *, fmode_t, unsigned int,
 				 unsigned long);
 extern int bdev_read_page(struct block_device *, sector_t, struct page *);
-extern int bdev_write_page(struct block_device *, sector_t, struct page *,
-						struct writeback_control *);
+extern int bdev_write_page(struct block_device *bdev, sector_t sector,
+			struct address_space *mapping, struct page *page,
+			struct writeback_control *wbc);
 
 #ifdef CONFIG_BLK_DEV_ZONED
 bool blk_req_needs_zone_write_lock(struct request *rq);
diff --git a/mm/page_io.c b/mm/page_io.c
index 402231dd1286..6e548b588490 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -282,12 +282,12 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	struct bio *bio;
 	int ret;
 	struct swap_info_struct *sis = page_swap_info(page);
+	struct file *swap_file = sis->swap_file;
+	struct address_space *mapping = swap_file->f_mapping;
 
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
-		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
 		struct bio_vec bv = {
 			.bv_page = page,
 			.bv_len  = PAGE_SIZE,
@@ -325,7 +325,8 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		return ret;
 	}
 
-	ret = bdev_write_page(sis->bdev, swap_page_sector(page), page, wbc);
+	ret = bdev_write_page(sis->bdev, swap_page_sector(page),
+			      mapping, page, wbc);
 	if (!ret) {
 		count_swpout_vm_event(page);
 		return 0;
-- 
2.14.3
