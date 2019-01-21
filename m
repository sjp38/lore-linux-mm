Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 130398E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:21:50 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d35so20341654qtd.20
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:21:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g24si5043773qtm.208.2019.01.21.00.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:21:49 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V14 14/18] block: enable multipage bvecs
Date: Mon, 21 Jan 2019 16:18:01 +0800
Message-Id: <20190121081805.32727-15-ming.lei@redhat.com>
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
References: <20190121081805.32727-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

This patch pulls the trigger for multi-page bvecs.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c         | 22 +++++++++++++++-------
 fs/iomap.c          |  4 ++--
 fs/xfs/xfs_aops.c   |  4 ++--
 include/linux/bio.h |  2 +-
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 968b12fea564..83a2dfa417ca 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -753,6 +753,8 @@ EXPORT_SYMBOL(bio_add_pc_page);
  * @page: page to add
  * @len: length of the data to add
  * @off: offset of the data in @page
+ * @same_page: if %true only merge if the new data is in the same physical
+ *		page as the last segment of the bio.
  *
  * Try to add the data at @page + @off to the last bvec of @bio.  This is a
  * a useful optimisation for file systems with a block size smaller than the
@@ -761,19 +763,25 @@ EXPORT_SYMBOL(bio_add_pc_page);
  * Return %true on success or %false on failure.
  */
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off)
+		unsigned int len, unsigned int off, bool same_page)
 {
 	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
 		return false;
 
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
+		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
+			bv->bv_offset + bv->bv_len - 1;
+		phys_addr_t page_addr = page_to_phys(page);
 
-		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
-			bv->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
+		if (vec_end_addr + 1 != page_addr + off)
+			return false;
+		if (same_page && (vec_end_addr & PAGE_MASK) != page_addr)
+			return false;
+
+		bv->bv_len += len;
+		bio->bi_iter.bi_size += len;
+		return true;
 	}
 	return false;
 }
@@ -819,7 +827,7 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
 int bio_add_page(struct bio *bio, struct page *page,
 		 unsigned int len, unsigned int offset)
 {
-	if (!__bio_try_merge_page(bio, page, len, offset)) {
+	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
 		if (bio_full(bio))
 			return 0;
 		__bio_add_page(bio, page, len, offset);
diff --git a/fs/iomap.c b/fs/iomap.c
index af736acd9006..0c350e658b7f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -318,7 +318,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	 */
 	sector = iomap_sector(iomap, pos);
 	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
-		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
+		if (__bio_try_merge_page(ctx->bio, page, plen, poff, true))
 			goto done;
 		is_contig = true;
 	}
@@ -349,7 +349,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		ctx->bio->bi_end_io = iomap_read_end_io;
 	}
 
-	__bio_add_page(ctx->bio, page, plen, poff);
+	bio_add_page(ctx->bio, page, plen, poff);
 done:
 	/*
 	 * Move the caller beyond our range so that it keeps making progress.
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 1f1829e506e8..b9fd44168f61 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -616,12 +616,12 @@ xfs_add_to_ioend(
 				bdev, sector);
 	}
 
-	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
+	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff, true)) {
 		if (iop)
 			atomic_inc(&iop->write_count);
 		if (bio_full(wpc->ioend->io_bio))
 			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
-		__bio_add_page(wpc->ioend->io_bio, page, len, poff);
+		bio_add_page(wpc->ioend->io_bio, page, len, poff);
 	}
 
 	wpc->ioend->io_size += len;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index e6a6f3d78afd..af288f6e8ab0 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -441,7 +441,7 @@ extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
 extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
 			   unsigned int, unsigned int);
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off);
+		unsigned int len, unsigned int off, bool same_page);
 void __bio_add_page(struct bio *bio, struct page *page,
 		unsigned int len, unsigned int off);
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
-- 
2.9.5
