Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED1C6B0290
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:47:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g12-v6so2785130qtj.22
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:47:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s57-v6si764659qvs.140.2018.05.24.20.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:47:29 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 03/33] block: rename bio_segments() with bio_pages()
Date: Fri, 25 May 2018 11:45:51 +0800
Message-Id: <20180525034621.31147-4-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index 5495dc30d080..d0debb22ee34 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -682,7 +682,7 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 	 *    __bio_clone_fast() anyways.
 	 */
 
-	bio = bio_alloc_bioset(gfp_mask, bio_segments(bio_src), bs);
+	bio = bio_alloc_bioset(gfp_mask, bio_pages(bio_src), bs);
 	if (!bio)
 		return NULL;
 	bio->bi_disk		= bio_src->bi_disk;
diff --git a/block/blk-merge.c b/block/blk-merge.c
index fc2aa21b7959..545609fc4905 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -302,7 +302,7 @@ void blk_recount_segments(struct request_queue *q, struct bio *bio)
 
 	/* estimate segment number by bi_vcnt for non-cloned bio */
 	if (bio_flagged(bio, BIO_CLONED))
-		seg_cnt = bio_segments(bio);
+		seg_cnt = bio_pages(bio);
 	else
 		seg_cnt = bio->bi_vcnt;
 
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index d04ba3f0c5de..8d7d5581ca9c 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -521,7 +521,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		struct bio_vec tmp;
 
 		__rq_for_each_bio(bio, rq)
-			segments += bio_segments(bio);
+			segments += bio_pages(bio);
 		bvec = kmalloc(sizeof(struct bio_vec) * segments, GFP_NOIO);
 		if (!bvec)
 			return -EIO;
@@ -547,7 +547,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		 */
 		offset = bio->bi_iter.bi_bvec_done;
 		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
-		segments = bio_segments(bio);
+		segments = bio_pages(bio);
 	}
 	atomic_set(&cmd->ref, 2);
 
diff --git a/drivers/md/dm-log-writes.c b/drivers/md/dm-log-writes.c
index ab31ba9c3b37..e5d455245ed9 100644
--- a/drivers/md/dm-log-writes.c
+++ b/drivers/md/dm-log-writes.c
@@ -680,7 +680,7 @@ static int log_writes_map(struct dm_target *ti, struct bio *bio)
 	if (discard_bio)
 		alloc_size = sizeof(struct pending_block);
 	else
-		alloc_size = sizeof(struct pending_block) + sizeof(struct bio_vec) * bio_segments(bio);
+		alloc_size = sizeof(struct pending_block) + sizeof(struct bio_vec) * bio_pages(bio);
 
 	block = kzalloc(alloc_size, GFP_NOIO);
 	if (!block) {
diff --git a/drivers/target/target_core_pscsi.c b/drivers/target/target_core_pscsi.c
index 668934ea74cb..01116cf9d634 100644
--- a/drivers/target/target_core_pscsi.c
+++ b/drivers/target/target_core_pscsi.c
@@ -915,7 +915,7 @@ pscsi_map_sg(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 			rc = bio_add_pc_page(pdv->pdv_sd->request_queue,
 					bio, page, bytes, off);
 			pr_debug("PSCSI: bio->bi_vcnt: %d nr_vecs: %d\n",
-				bio_segments(bio), nr_vecs);
+				bio_pages(bio), nr_vecs);
 			if (rc != bytes) {
 				pr_debug("PSCSI: Reached bio->bi_vcnt max:"
 					" %d i: %d bio: %p, allocating another"
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index e5f7df09683f..55c4db22cfb9 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2800,7 +2800,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 		struct bvec_iter iter;
 		int bio_is_patched;
 		char **mapped_datav;
-		unsigned int segs = bio_segments(bio);
+		unsigned int segs = bio_pages(bio);
 
 		dev_bytenr = 512 * bio->bi_iter.bi_sector;
 		bio_is_patched = 0;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index f78155e3a4dc..9d816dc725c4 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7844,7 +7844,7 @@ static blk_status_t dio_read_error(struct inode *inode, struct bio *failed_bio,
 		return BLK_STS_IOERR;
 	}
 
-	segs = bio_segments(failed_bio);
+	segs = bio_pages(failed_bio);
 	bio_get_first_bvec(failed_bio, &bvec);
 	if (segs > 1 ||
 	    (bvec.bv_len > btrfs_inode_sectorsize(inode)))
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 63b988043eff..7f92af1299ad 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -199,7 +199,7 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
-static inline unsigned bio_segments(struct bio *bio)
+static inline unsigned bio_pages(struct bio *bio)
 {
 	unsigned segs = 0;
 	struct bio_vec bv;
-- 
2.9.5
