Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 93AE26B0081
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:49 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id l13so6319308iga.9
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g7si7700163ioj.23.2014.12.15.15.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:48 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:46 -0800
From: akpm@linux-foundation.org
Subject: [patch 6/6] fs/mpage.c: forgotten WRITE_SYNC in case of data
 integrity write
Message-ID: <548f68d2.HLebq27pRWZsiR9S%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, r.peniaev@gmail.com, axboe@kernel.dk, jack@suse.cz, tj@kernel.org

From: Roman Pen <r.peniaev@gmail.com>
Subject: fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

In case of wbc->sync_mode == WB_SYNC_ALL we need to do data integrity
write, thus mark request as WRITE_SYNC.

akpm: afaict this change will cause the data integrity write bios to be
placed onto the second queue in cfq_io_cq.cfqq[], which presumably results
in special treatment.  The documentation for REQ_SYNC is horrid.

Signed-off-by: Roman Pen <r.peniaev@gmail.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/mpage.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff -puN fs/mpage.c~fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write fs/mpage.c
--- a/fs/mpage.c~fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write
+++ a/fs/mpage.c
@@ -482,6 +482,7 @@ static int __mpage_writepage(struct page
 	struct buffer_head map_bh;
 	loff_t i_size = i_size_read(inode);
 	int ret = 0;
+	int wr = (wbc->sync_mode == WB_SYNC_ALL ?  WRITE_SYNC : WRITE);
 
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
@@ -590,7 +591,7 @@ page_is_mapped:
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
 	if (bio && mpd->last_block_in_bio != blocks[0] - 1)
-		bio = mpage_bio_submit(WRITE, bio);
+		bio = mpage_bio_submit(wr, bio);
 
 alloc_new:
 	if (bio == NULL) {
@@ -614,7 +615,7 @@ alloc_new:
 	 */
 	length = first_unmapped << blkbits;
 	if (bio_add_page(bio, page, length, 0) < length) {
-		bio = mpage_bio_submit(WRITE, bio);
+		bio = mpage_bio_submit(wr, bio);
 		goto alloc_new;
 	}
 
@@ -624,7 +625,7 @@ alloc_new:
 	set_page_writeback(page);
 	unlock_page(page);
 	if (boundary || (first_unmapped != blocks_per_page)) {
-		bio = mpage_bio_submit(WRITE, bio);
+		bio = mpage_bio_submit(wr, bio);
 		if (boundary_block) {
 			write_boundary_block(boundary_bdev,
 					boundary_block, 1 << blkbits);
@@ -636,7 +637,7 @@ alloc_new:
 
 confused:
 	if (bio)
-		bio = mpage_bio_submit(WRITE, bio);
+		bio = mpage_bio_submit(wr, bio);
 
 	if (mpd->use_writepage) {
 		ret = mapping->a_ops->writepage(page, wbc);
@@ -692,8 +693,11 @@ mpage_writepages(struct address_space *m
 		};
 
 		ret = write_cache_pages(mapping, wbc, __mpage_writepage, &mpd);
-		if (mpd.bio)
-			mpage_bio_submit(WRITE, mpd.bio);
+		if (mpd.bio) {
+			int wr = (wbc->sync_mode == WB_SYNC_ALL ?
+				  WRITE_SYNC : WRITE);
+			mpage_bio_submit(wr, mpd.bio);
+		}
 	}
 	blk_finish_plug(&plug);
 	return ret;
@@ -710,8 +714,11 @@ int mpage_writepage(struct page *page, g
 		.use_writepage = 0,
 	};
 	int ret = __mpage_writepage(page, wbc, &mpd);
-	if (mpd.bio)
-		mpage_bio_submit(WRITE, mpd.bio);
+	if (mpd.bio) {
+		int wr = (wbc->sync_mode == WB_SYNC_ALL ?
+			  WRITE_SYNC : WRITE);
+		mpage_bio_submit(wr, mpd.bio);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(mpage_writepage);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
