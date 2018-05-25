Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B722A6B028E
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:47:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t143-v6so2905384qke.18
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:47:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b25-v6si4828176qtb.276.2018.05.24.20.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:47:16 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 02/33] block: rename rq_for_each_segment as rq_for_each_page
Date: Fri, 25 May 2018 11:45:50 +0800
Message-Id: <20180525034621.31147-3-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index 43370faee935..6548b9170ae5 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -3423,7 +3423,7 @@ void rq_flush_dcache_pages(struct request *rq)
 	struct req_iterator iter;
 	struct bio_vec bvec;
 
-	rq_for_each_segment(bvec, rq, iter)
+	rq_for_each_page(bvec, rq, iter)
 		flush_dcache_page(bvec.bv_page);
 }
 EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index 8ec7235fc93b..922cc9d0120a 100644
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
index 5f0df2efc26c..d04ba3f0c5de 100644
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
@@ -530,10 +530,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
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
index 52f683bb2b9a..939a8012d25f 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -600,7 +600,7 @@ static struct nbd_cmd *nbd_read_stat(struct nbd_device *nbd, int index)
 		struct req_iterator iter;
 		struct bio_vec bvec;
 
-		rq_for_each_segment(bvec, req, iter) {
+		rq_for_each_page(bvec, req, iter) {
 			iov_iter_bvec(&to, ITER_BVEC | READ,
 				      &bvec, 1, bvec.bv_len);
 			result = sock_xmit(nbd, index, 0, &to, MSG_WAITALL, NULL);
diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index 506c74501114..6e95955576e2 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -1136,7 +1136,7 @@ static int null_handle_rq(struct nullb_cmd *cmd)
 	}
 
 	spin_lock_irq(&nullb->lock);
-	rq_for_each_segment(bvec, rq, iter) {
+	rq_for_each_page(bvec, rq, iter) {
 		len = bvec.bv_len;
 		err = null_transfer(nullb, bvec.bv_page, len, bvec.bv_offset,
 				     op_is_write(req_op(rq)), sector,
diff --git a/drivers/block/ps3disk.c b/drivers/block/ps3disk.c
index afe1508d82c6..8d816bee18ac 100644
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
index 131f1989f6f3..02f154056153 100644
--- a/drivers/s390/block/dasd_diag.c
+++ b/drivers/s390/block/dasd_diag.c
@@ -524,7 +524,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 		(blk_rq_pos(req) + blk_rq_sectors(req) - 1) >> block->s2b_shift;
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		if (bv.bv_len & (blksize - 1))
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
@@ -544,7 +544,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	dreq->block_count = count;
 	dbio = dreq->bio;
 	recid = first_rec;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			memset(dbio, 0, sizeof (struct dasd_diag_bio));
diff --git a/drivers/s390/block/dasd_eckd.c b/drivers/s390/block/dasd_eckd.c
index be208e7adcb4..7941ab50ed77 100644
--- a/drivers/s390/block/dasd_eckd.c
+++ b/drivers/s390/block/dasd_eckd.c
@@ -3065,7 +3065,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
 	cidaw = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		if (bv.bv_len & (blksize - 1))
 			/* Eckd can only do full blocks. */
 			return ERR_PTR(-EINVAL);
@@ -3140,7 +3140,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 		locate_record(ccw++, LO_data++, first_trk, first_offs + 1,
 			      last_rec - recid + 1, cmd, basedev, blksize);
 	}
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
@@ -3299,7 +3299,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_track(
 	len_to_track_end = 0;
 	idaw_dst = NULL;
 	idaw_len = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		while (seg_len) {
@@ -3587,7 +3587,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 	 */
 	trkcount = last_trk - first_trk + 1;
 	ctidaw = 0;
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		++ctidaw;
 	}
 	if (rq_data_dir(req) == WRITE)
@@ -3636,7 +3636,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 	if (rq_data_dir(req) == WRITE) {
 		new_track = 1;
 		recid = first_rec;
-		rq_for_each_segment(bv, req, iter) {
+		rq_for_each_page(bv, req, iter) {
 			dst = page_address(bv.bv_page) + bv.bv_offset;
 			seg_len = bv.bv_len;
 			while (seg_len) {
@@ -3669,7 +3669,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 			}
 		}
 	} else {
-		rq_for_each_segment(bv, req, iter) {
+		rq_for_each_page(bv, req, iter) {
 			dst = page_address(bv.bv_page) + bv.bv_offset;
 			last_tidaw = itcw_add_tidaw(itcw, 0x00,
 						    dst, bv.bv_len);
@@ -3897,7 +3897,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_raw(struct dasd_device *startdev,
 		for (sectors = 0; sectors < start_padding_sectors; sectors += 8)
 			idaws = idal_create_words(idaws, rawpadpage, PAGE_SIZE);
 	}
-	rq_for_each_segment(bv, req, iter) {
+	rq_for_each_page(bv, req, iter) {
 		dst = page_address(bv.bv_page) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		if (cmd == DASD_ECKD_CCW_READ_TRACK)
@@ -3958,7 +3958,7 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
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
index b1fcb76dd272..68c0007f3ec0 100644
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
index dfa750fd7a41..1e8e9b430008 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -942,14 +942,14 @@ struct req_iterator {
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
