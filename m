Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38E2A6B02C3
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:17:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so27658641pga.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 22:17:50 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 29si17337pfl.465.2017.08.10.22.17.48
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 22:17:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 3/7] fs: use on-stack-bio if backing device has BDI_CAP_SYNCHRONOUS capability
Date: Fri, 11 Aug 2017 14:17:23 +0900
Message-Id: <1502428647-28928-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1502428647-28928-1-git-send-email-minchan@kernel.org>
References: <1502428647-28928-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

There is no need to use dynamic bio allocation for BDI_CAP_SYNCHRONOUS
devices. They can with on-stack bio without concern about waiting
bio allocation from mempool under heavy memory pressure.

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---

Hi Mattew,

I didn't use sbvec[nr_pages] as you suggested[1] because I don't think
it's pointless in do_mpage_readpage which works per-page base as
I replied to you.
If I misunderstood something, please correct me.

[1] http://lkml.kernel.org/r/<20170808132904.GC31390@bombadil.infradead.org>

 fs/mpage.c | 47 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 40 insertions(+), 7 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 2e4c41ccb5c9..d3b777fdfd5a 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -162,6 +162,9 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	int fully_mapped = 1;
 	unsigned nblocks;
 	unsigned relative_block;
+	/* on-stack bio for synchronous devices */
+	struct bio sbio;
+	struct bio_vec sbvec;
 
 	if (page_has_buffers(page))
 		goto confused;
@@ -282,10 +285,22 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 								page))
 				goto out;
 		}
-		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
+
+		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
+			bio = &sbio;
+			/* mpage_end_io calls bio_put unconditionally */
+			bio_get(&sbio);
+
+			bio_init(&sbio, &sbvec, 1);
+			sbio.bi_bdev = bdev;
+			sbio.bi_iter.bi_sector = blocks[0] << (blkbits - 9);
+		} else {
+
+			bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				min_t(int, nr_pages, BIO_MAX_PAGES), gfp);
-		if (bio == NULL)
-			goto confused;
+			if (bio == NULL)
+				goto confused;
+		}
 	}
 
 	length = first_hole << blkbits;
@@ -302,6 +317,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	else
 		*last_block_in_bio = blocks[blocks_per_page - 1];
 out:
+	if (bio == &sbio)
+		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);
 	return bio;
 
 confused:
@@ -492,6 +509,9 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	loff_t i_size = i_size_read(inode);
 	int ret = 0;
 	int op_flags = wbc_to_write_flags(wbc);
+	/* on-stack-bio */
+	struct bio sbio;
+	struct bio_vec sbvec;
 
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
@@ -610,10 +630,21 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 				goto out;
 			}
 		}
-		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
-				BIO_MAX_PAGES, GFP_NOFS|__GFP_HIGH);
-		if (bio == NULL)
-			goto confused;
+
+		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
+			bio = &sbio;
+			/* mpage_end_io calls bio_put unconditionally */
+			bio_get(&sbio);
+
+			bio_init(&sbio, &sbvec, 1);
+			sbio.bi_bdev = bdev;
+			sbio.bi_iter.bi_sector = blocks[0] << (blkbits - 9);
+		} else {
+			bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
+					BIO_MAX_PAGES, GFP_NOFS|__GFP_HIGH);
+			if (bio == NULL)
+				goto confused;
+		}
 
 		wbc_init_bio(wbc, bio);
 		bio->bi_write_hint = inode->i_write_hint;
@@ -662,6 +693,8 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	 */
 	mapping_set_error(mapping, ret);
 out:
+	if (bio == &sbio)
+		bio = mpage_bio_submit(REQ_OP_WRITE, op_flags, bio);
 	mpd->bio = bio;
 	return ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
