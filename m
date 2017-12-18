Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1F0C6B028A
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:27:05 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id v8so8917913otd.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:27:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t194si3747621oih.344.2017.12.18.04.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:27:04 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 17/45] block: rename bio_segments() with bio_pages()
Date: Mon, 18 Dec 2017 20:22:19 +0800
Message-Id: <20171218122247.3488-18-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bio_segments() never returns count of actual segment, just like
original bio_for_each_segment(), so rename it as bio_pages().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c                        | 2 +-
 block/blk-merge.c                  | 2 +-
 drivers/block/loop.c               | 4 ++--
 drivers/md/dm-log-writes.c         | 2 +-
 drivers/target/target_core_pscsi.c | 2 +-
 fs/btrfs/check-integrity.c         | 2 +-
 fs/btrfs/inode.c                   | 2 +-
 include/linux/bio.h                | 2 +-
 8 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index b93677f8f682..1649dc465af7 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -679,7 +679,7 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 	 *    __bio_clone_fast() anyways.
 	 */
 
-	bio = bio_alloc_bioset(gfp_mask, bio_segments(bio_src), bs);
+	bio = bio_alloc_bioset(gfp_mask, bio_pages(bio_src), bs);
 	if (!bio)
 		return NULL;
 	bio->bi_disk		= bio_src->bi_disk;
diff --git a/block/blk-merge.c b/block/blk-merge.c
index b571e91b67f6..25ffb84be058 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -329,7 +329,7 @@ void blk_recount_segments(struct request_queue *q, struct bio *bio)
 
 	/* estimate segment number by bi_vcnt for non-cloned bio */
 	if (bio_flagged(bio, BIO_CLONED))
-		seg_cnt = bio_segments(bio);
+		seg_cnt = bio_pages(bio);
 	else
 		seg_cnt = bio->bi_vcnt;
 
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 7f56422d0066..8e30d081ad2a 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -499,7 +499,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		struct bio_vec tmp;
 
 		__rq_for_each_bio(bio, rq)
-			segments += bio_segments(bio);
+			segments += bio_pages(bio);
 		bvec = kmalloc(sizeof(struct bio_vec) * segments, GFP_NOIO);
 		if (!bvec)
 			return -EIO;
@@ -525,7 +525,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		 */
 		offset = bio->bi_iter.bi_bvec_done;
 		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
-		segments = bio_segments(bio);
+		segments = bio_pages(bio);
 	}
 	atomic_set(&cmd->ref, 2);
 
diff --git a/drivers/md/dm-log-writes.c b/drivers/md/dm-log-writes.c
index cd023ff6a33b..1a7436a8aa2a 100644
--- a/drivers/md/dm-log-writes.c
+++ b/drivers/md/dm-log-writes.c
@@ -723,7 +723,7 @@ static int log_writes_map(struct dm_target *ti, struct bio *bio)
 	if (discard_bio)
 		alloc_size = sizeof(struct pending_block);
 	else
-		alloc_size = sizeof(struct pending_block) + sizeof(struct bio_vec) * bio_segments(bio);
+		alloc_size = sizeof(struct pending_block) + sizeof(struct bio_vec) * bio_pages(bio);
 
 	block = kzalloc(alloc_size, GFP_NOIO);
 	if (!block) {
diff --git a/drivers/target/target_core_pscsi.c b/drivers/target/target_core_pscsi.c
index 7c69b4a9694d..88b0502fffbc 100644
--- a/drivers/target/target_core_pscsi.c
+++ b/drivers/target/target_core_pscsi.c
@@ -914,7 +914,7 @@ pscsi_map_sg(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 			rc = bio_add_pc_page(pdv->pdv_sd->request_queue,
 					bio, page, bytes, off);
 			pr_debug("PSCSI: bio->bi_vcnt: %d nr_vecs: %d\n",
-				bio_segments(bio), nr_vecs);
+				bio_pages(bio), nr_vecs);
 			if (rc != bytes) {
 				pr_debug("PSCSI: Reached bio->bi_vcnt max:"
 					" %d i: %d bio: %p, allocating another"
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index d200389099db..aac952f47636 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2813,7 +2813,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 		struct bvec_iter iter;
 		int bio_is_patched;
 		char **mapped_datav;
-		unsigned int segs = bio_segments(bio);
+		unsigned int segs = bio_pages(bio);
 
 		dev_bytenr = 512 * bio->bi_iter.bi_sector;
 		bio_is_patched = 0;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index c279030ee5ed..fda9f2a92f7a 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8030,7 +8030,7 @@ static blk_status_t dio_read_error(struct inode *inode, struct bio *failed_bio,
 		return BLK_STS_IOERR;
 	}
 
-	segs = bio_segments(failed_bio);
+	segs = bio_pages(failed_bio);
 	bio_get_first_bvec(failed_bio, &bvec);
 	if (segs > 1 ||
 	    (bvec.bv_len > btrfs_inode_sectorsize(inode)))
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 27dd152697ac..95ca5ddc72ef 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -195,7 +195,7 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
-static inline unsigned bio_segments(struct bio *bio)
+static inline unsigned bio_pages(struct bio *bio)
 {
 	unsigned segs = 0;
 	struct bio_vec bv;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
