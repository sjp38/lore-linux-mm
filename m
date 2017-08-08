Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C54A6B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:50:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b83so24752091pfl.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:50:34 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r68si457886pfa.50.2017.08.07.23.50.32
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 23:50:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 2/6] fs: use on-stack-bio if backing device has BDI_CAP_SYNC capability
Date: Tue,  8 Aug 2017 15:50:20 +0900
Message-Id: <1502175024-28338-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1502175024-28338-1-git-send-email-minchan@kernel.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

There is no need to use dynamic bio allocation for BDI_CAP_SYNC
devices. They can with on-stack-bio without concern about waiting
bio allocation from mempool under heavy memory pressure.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/mpage.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/fs/mpage.c b/fs/mpage.c
index 2e4c41ccb5c9..eaeaef27d693 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -31,6 +31,14 @@
 #include <linux/cleancache.h>
 #include "internal.h"
 
+static void on_stack_page_end_io(struct bio *bio)
+{
+	struct page *page = bio->bi_io_vec->bv_page;
+
+	page_endio(page, op_is_write(bio_op(bio)),
+		blk_status_to_errno(bio->bi_status));
+}
+
 /*
  * I/O completion handler for multipage BIOs.
  *
@@ -278,6 +286,22 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 alloc_new:
 	if (bio == NULL) {
 		if (first_hole == blocks_per_page) {
+			if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
+				/* on-stack-bio */
+				struct bio sbio;
+				struct bio_vec bvec;
+
+				bio_init(&sbio, &bvec, 1);
+				sbio.bi_bdev = bdev;
+				sbio.bi_iter.bi_sector =
+					blocks[0] << (blkbits - 9);
+				sbio.bi_end_io = on_stack_page_end_io;
+				bio_add_page(&sbio, page, PAGE_SIZE, 0);
+				bio_set_op_attrs(&sbio, REQ_OP_READ, 0);
+				submit_bio(&sbio);
+				goto out;
+			}
+
 			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
 								page))
 				goto out;
@@ -604,6 +628,25 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 alloc_new:
 	if (bio == NULL) {
 		if (first_unmapped == blocks_per_page) {
+			if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
+				/* on-stack-bio */
+				struct bio sbio;
+				struct bio_vec bvec;
+
+				bio_init(&sbio, &bvec, 1);
+				sbio.bi_bdev = bdev;
+				sbio.bi_iter.bi_sector =
+					blocks[0] << (blkbits - 9);
+				sbio.bi_end_io = on_stack_page_end_io;
+				bio_add_page(&sbio, page, PAGE_SIZE, 0);
+				bio_set_op_attrs(&sbio, REQ_OP_WRITE, op_flags);
+				WARN_ON_ONCE(PageWriteback(page));
+				set_page_writeback(page);
+				unlock_page(page);
+				submit_bio(&sbio);
+				clean_buffers(page, first_unmapped);
+			}
+
 			if (!bdev_write_page(bdev, blocks[0] << (blkbits - 9),
 								page, wbc)) {
 				clean_buffers(page, first_unmapped);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
