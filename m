Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04FA66B0289
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:26:52 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id n64so8938932ota.3
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:26:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c126si3740243oia.140.2017.12.18.04.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:26:50 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 16/45] block: rename rq_for_each_segment as rq_for_each_page
Date: Mon, 18 Dec 2017 20:22:18 +0800
Message-Id: <20171218122247.3488-17-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

rq_for_each_segment() still deceives us since this helper only returns
one page in each bvec, so fixes its name.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biodoc.txt |  6 +++---
 block/blk-core.c               |  2 +-
 drivers/block/floppy.c         |  4 ++--
 drivers/block/loop.c           | 12 ++++++------
 drivers/block/nbd.c            |  2 +-
 drivers/block/null_blk.c       |  2 +-
 drivers/block/ps3disk.c        |  4 ++--
 drivers/s390/block/dasd_diag.c |  4 ++--
 drivers/s390/block/dasd_eckd.c | 16 ++++++++--------
 drivers/s390/block/dasd_fba.c  |  6 +++---
 drivers/s390/block/scm_blk.c   |  2 +-
 include/linux/blkdev.h         |  4 ++--
 12 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/Documentation/block/biodoc.txt b/Documentation/block/biodoc.txt
index 86927029a52d..3aeca60e526a 100644
--- a/Documentation/block/biodoc.txt
+++ b/Documentation/block/biodoc.txt
@@ -458,7 +458,7 @@ With this multipage bio design:
 - A linked list of bios is used as before for unrelated merges (*) - this
   avoids reallocs and makes independent completions easier to handle.
 - Code that traverses the req list can find all the segments of a bio
-  by using rq_for_each_segment.  This handles the fact that a request
+  by using rq_for_each_page.  This handles the fact that a request
   has multiple bios, each of which can have multiple segments.
 - Drivers which can't process a large bio in one shot can use the bi_iter
   field to keep track of the next bio_vec entry to process.
@@ -640,13 +640,13 @@ in lvm or md.
 
 3.2.1 Traversing segments and completion units in a request
 
-The macro rq_for_each_segment() should be used for traversing the bios
+The macro rq_for_each_page() should be used for traversing the bios
 in the request list (drivers should avoid directly trying to do it
 themselves). Using these helpers should also make it easier to cope
 with block changes in the future.
 
 	struct req_iterator iter;
-	rq_for_each_segment(bio_vec, rq, iter)
+	rq_for_each_page(bio_vec, rq, iter)
 		/* bio_vec is now current segment */
 
 I/O completion callbacks are per-bio rather than per-segment, so drivers
diff --git a/block/blk-core.c b/block/blk-core.c
index b8881750a3ac..bc9d3c754a9a 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -3267,7 +3267,7 @@ void rq_flush_dcache_pages(struct request *rq)
 	struct req_iterator iter;
 	struct bio_vec bvec;
 
-	rq_for_each_segment(bvec, rq, iter)
+	rq_for_each_page(bvec, rq, iter)
 		flush_dcache_page(bvec.bv_page);
 }
 EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index eae484acfbbc..556c29dc94e1 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -2382,7 +2382,7 @@ static int buffer_chain_size(void)
 	base = bio_data(current_req->bio);
 	size = 0;
 
-	rq_for_each_segment(bv, current_req, iter) {
+	rq_for_each_page(bv, current_req, iter) {
 		if (page_address(bv.bv_page) + bv.bv_offset != base + size)
 			break;
 
@@ -2446,7 +2446,7 @@ static void copy_buffer(int ssize, int max_sector, int max_sector_2)
 
 	size = blk_rq_cur_bytes(current_req);
 
-	rq_for_each_segment(bv, current_req, iter) {
+	rq_for_each_page(bv, current_req, iter) {
 		if (!remaining)
 			break;
 
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index bc8e61506968..7f56422d0066 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -290,7 +290,7 @@ static int lo_write_simple(struct loop_device *lo, struct request *rq,
 	struct req_iterator iter;
 	int ret = 0;
 
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		ret = lo_write_bvec(lo->lo_backing_file, &bvec, &pos);
 		if (ret < 0)
 			break;
@@ -317,7 +317,7 @@ static int lo_write_transfer(struct loop_device *lo, struct request *rq,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		ret = lo_do_transfer(lo, WRITE, page, 0, bvec.bv_page,
 			bvec.bv_offset, bvec.bv_len, pos >> 9);
 		if (unlikely(ret))
@@ -343,7 +343,7 @@ static int lo_read_simple(struct loop_device *lo, struct request *rq,
 	struct iov_iter i;
 	ssize_t len;
 
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		iov_iter_bvec(&i, ITER_BVEC, &bvec, 1, bvec.bv_len);
 		len = vfs_iter_read(lo->lo_backing_file, &i, &pos, 0);
 		if (len < 0)
@@ -378,7 +378,7 @@ static int lo_read_transfer(struct loop_device *lo, struct request *rq,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		loff_t offset = pos;
 
 		b.bv_page = page;
@@ -508,10 +508,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		/*
 		 * The bios of the request may be started from the middle of
 		 * the 'bvec' because of bio splitting, so we can't directly
-		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_segment
+		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_page
 		 * API will take care of all details for us.
 		 */
-		rq_for_each_segment(tmp, rq, iter) {
+		rq_for_each_page(tmp, rq, iter) {
 			*bvec = tmp;
 			bvec++;
 		}
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index e23bf7bbaed6..4ddda8f2a2da 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -586,7 +586,7 @@ static struct nbd_cmd *nbd_read_stat(struct nbd_device *nbd, int index)
 		struct req_iterator iter;
 		struct bio_vec bvec;
 
-		rq_for_each_segment(bvec, req, iter) {
+		rq_for_each_page(bvec, req, iter) {
 			iov_iter_bvec(&to, ITER_BVEC | READ,
 				      &bvec, 1, bvec.bv_len);
 			result = sock_xmit(nbd, index, 0, &to, MSG_WAITALL, NULL);
diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index f759b52f4ce2..3d751c2900e3 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -1126,7 +1126,7 @@ static int null_handle_rq(struct nullb_cmd *cmd)
 	}
 
 	spin_lock_irq(&nullb->lock);
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		len = bvec.bv_len;
 		err = null_transfer(nullb, bvec.bv_page, len, bvec.bv_offset,
 				     op_is_write(req_op(rq)), sector,
diff --git a/drivers/block/ps3disk.c b/drivers/block/ps3disk.c
index 075662f2cf46..5ddae4965274 100644
--- a/drivers/block/ps3disk.c
+++ b/drivers/block/ps3disk.c
@@ -99,7 +99,7 @@ static void ps3disk_scatter_gather(struct ps3_storage_device *dev,
 	size_t size;
 	void *buf;
 
-	rq_for_each_segment(bvec, req, iter) {
+	rq_for_each_page(bvec, req, iter) {
 		unsigned long flags;
 		dev_dbg(&dev->sbd.core, "%s:%u: bio %u: %u sectors from %lu\n",
 			__func__, __LINE__, i, bio_sectors(iter.bio),
@@ -132,7 +132,7 @@ static int ps3disk_submit_request_sg(struct ps3_storage_device *dev,
 	struct bio_vec bv;
 	struct req_iterator iter;
 
-	rq_for_each_segment(bv, req, iter)
+	rq_for_each_page(bv, req, iter)
 		n++;
 	dev_dbg(&dev->sbd.core,
 		"%s:%u: %s req has %u bvecs for %u sectors\n",
diff --git a/drivers/s390/block/dasd_diag.c b/drivers/s390/block/dasd_diag.c
index f035c2f25d35..81f37d048ac5 100644
--- a/drivers/s390/block/dasd_diag.c
+++ b/drivers/s390/block/dasd_diag.c
@@ -525,7 +525,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 		(blk_rq_pos(req) + blk_rq_sectors(req) - 1) >> block->s2b_shift;
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		if (bv.bv_len & (blksize - 1))
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
@@ -545,7 +545,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	dreq->block_count = count;
 	dbio = dreq->bio;
 	recid = first_rec;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			memset(dbio, 0, sizeof (struct dasd_diag_bio));
diff --git a/drivers/s390/block/dasd_eckd.c b/drivers/s390/block/dasd_eckd.c
index a2edf2a7ace9..6b35799c5df6 100644
--- a/drivers/s390/block/dasd_eckd.c
+++ b/drivers/s390/block/dasd_eckd.c
@@ -3064,7 +3064,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
 	cidaw = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		if (bv.bv_len & (blksize - 1))
 			/* Eckd can only do full blocks. */
 			return ERR_PTR(-EINVAL);
@@ -3139,7 +3139,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 		locate_record(ccw++, LO_data++, first_trk, first_offs + 1,
 			      last_rec - recid + 1, cmd, basedev, blksize);
 	}
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
@@ -3298,7 +3298,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_track(
 	len_to_track_end = 0;
 	idaw_dst = NULL;
 	idaw_len = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		while (seg_len) {
@@ -3586,7 +3586,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 	 */
 	trkcount = last_trk - first_trk + 1;
 	ctidaw = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		++ctidaw;
 	}
 	if (rq_data_dir(req) == WRITE)
@@ -3635,7 +3635,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 	if (rq_data_dir(req) == WRITE) {
 		new_track = 1;
 		recid = first_rec;
-		rq_for_each_segment(bv, req, iter) {
+		rq_for_each_page(bv, req, iter) {
 			dst = page_address(bv.bv_page) + bv.bv_offset;
 			seg_len = bv.bv_len;
 			while (seg_len) {
@@ -3668,7 +3668,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 			}
 		}
 	} else {
-		rq_for_each_segment(bv, req, iter) {
+		rq_for_each_page(bv, req, iter) {
 			dst = page_address(bv.bv_page) + bv.bv_offset;
 			last_tidaw = itcw_add_tidaw(itcw, 0x00,
 						    dst, bv.bv_len);
@@ -3896,7 +3896,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_raw(struct dasd_device *startdev,
 		for (sectors = 0; sectors < start_padding_sectors; sectors += 8)
 			idaws = idal_create_words(idaws, rawpadpage, PAGE_SIZE);
 	}
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		if (cmd == DASD_ECKD_CCW_READ_TRACK)
@@ -3957,7 +3957,7 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	ccw++;
 	if (private->uses_cdl == 0 || recid > 2*blk_per_trk)
 		ccw++;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
diff --git a/drivers/s390/block/dasd_fba.c b/drivers/s390/block/dasd_fba.c
index a6b132f7e869..b1d86cda3784 100644
--- a/drivers/s390/block/dasd_fba.c
+++ b/drivers/s390/block/dasd_fba.c
@@ -465,7 +465,7 @@ static struct dasd_ccw_req *dasd_fba_build_cp_regular(
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
 	cidaw = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		if (bv.bv_len & (blksize - 1))
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
@@ -506,7 +506,7 @@ static struct dasd_ccw_req *dasd_fba_build_cp_regular(
 		locate_record(ccw++, LO_data++, rq_data_dir(req), 0, count);
 	}
 	recid = first_rec;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
@@ -588,7 +588,7 @@ dasd_fba_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	ccw++;
 	if (private->rdc_data.mode.bits.data_chain != 0)
 		ccw++;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
diff --git a/drivers/s390/block/scm_blk.c b/drivers/s390/block/scm_blk.c
index b4130c7880d8..9ef1ef63c606 100644
--- a/drivers/s390/block/scm_blk.c
+++ b/drivers/s390/block/scm_blk.c
@@ -198,7 +198,7 @@ static int scm_request_prepare(struct scm_request *scmrq)
 	msb->flags |= MSB_FLAG_IDA;
 	msb->data_addr = (u64) aidaw;
 
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		WARN_ON(bv.bv_offset);
 		msb->blk_count += bv.bv_len >> 12;
 		aidaw->data_addr = (u64) page_address(bv.bv_page);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index d7ff29298e2b..ecc1a24bb5a2 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -900,14 +900,14 @@ struct req_iterator {
 	struct bio *bio;
 };
 
-/* This should not be used directly - use rq_for_each_segment */
+/* This should not be used directly - use rq_for_each_page */
 #define for_each_bio(_bio)		\
 	for (; _bio; _bio = _bio->bi_next)
 #define __rq_for_each_bio(_bio, rq)	\
 	if ((rq->bio))			\
 		for (_bio = (rq)->bio; _bio; _bio = _bio->bi_next)
 
-#define rq_for_each_segment(bvl, _rq, _iter)			\
+#define rq_for_each_page(bvl, _rq, _iter)			\
 	__rq_for_each_bio(_iter.bio, _rq)			\
 		bio_for_each_page(bvl, _iter.bio, _iter.iter)
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
