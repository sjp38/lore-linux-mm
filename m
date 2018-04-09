Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A8B716B000A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:39:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so5232838pfi.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:39:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q7-v6si569208plk.129.2018.04.09.08.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:39:48 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 6/7] block: consistently use GFP_NOIO instead of __GFP_NORECLAIM
Date: Mon,  9 Apr 2018 17:39:15 +0200
Message-Id: <20180409153916.23901-7-hch@lst.de>
In-Reply-To: <20180409153916.23901-1-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Same numerical value (for now at least), but a much better documentation
of intent.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/scsi_ioctl.c               |  2 +-
 drivers/block/drbd/drbd_bitmap.c |  3 ++-
 drivers/block/pktcdvd.c          |  2 +-
 drivers/ide/ide-tape.c           |  2 +-
 drivers/ide/ide-taskfile.c       |  2 +-
 drivers/scsi/scsi_lib.c          |  2 +-
 fs/direct-io.c                   |  4 ++--
 kernel/power/swap.c              | 14 +++++++-------
 8 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/block/scsi_ioctl.c b/block/scsi_ioctl.c
index 04b54f9a4152..533f4aee8567 100644
--- a/block/scsi_ioctl.c
+++ b/block/scsi_ioctl.c
@@ -499,7 +499,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
 		break;
 	}
 
-	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, __GFP_RECLAIM)) {
+	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, GFP_NOIO)) {
 		err = DRIVER_ERROR << 24;
 		goto error;
 	}
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 9f4e6f502b84..d82237d534cf 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -1014,7 +1014,8 @@ static void bm_page_io_async(struct drbd_bm_aio_ctx *ctx, int page_nr) __must_ho
 	bm_set_page_unchanged(b->bm_pages[page_nr]);
 
 	if (ctx->flags & BM_AIO_COPY_PAGES) {
-		page = mempool_alloc(drbd_md_io_page_pool, __GFP_HIGHMEM|__GFP_RECLAIM);
+		page = mempool_alloc(drbd_md_io_page_pool,
+				GFP_NOIO | __GFP_HIGHMEM);
 		copy_highpage(page, b->bm_pages[page_nr]);
 		bm_store_page_idx(page, page_nr);
 	} else
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index 4880a4a9f52d..ccfcf544830f 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -710,7 +710,7 @@ static int pkt_generic_packet(struct pktcdvd_device *pd, struct packet_command *
 
 	if (cgc->buflen) {
 		ret = blk_rq_map_kern(q, rq, cgc->buffer, cgc->buflen,
-				      __GFP_RECLAIM);
+				      GFP_NOIO);
 		if (ret)
 			goto out;
 	}
diff --git a/drivers/ide/ide-tape.c b/drivers/ide/ide-tape.c
index 66661031f3f1..62c1a19a9aed 100644
--- a/drivers/ide/ide-tape.c
+++ b/drivers/ide/ide-tape.c
@@ -862,7 +862,7 @@ static int idetape_queue_rw_tail(ide_drive_t *drive, int cmd, int size)
 
 	if (size) {
 		ret = blk_rq_map_kern(drive->queue, rq, tape->buf, size,
-				      __GFP_RECLAIM);
+				      GFP_NOIO);
 		if (ret)
 			goto out_put;
 	}
diff --git a/drivers/ide/ide-taskfile.c b/drivers/ide/ide-taskfile.c
index 6308bb0dab50..c034cd965831 100644
--- a/drivers/ide/ide-taskfile.c
+++ b/drivers/ide/ide-taskfile.c
@@ -442,7 +442,7 @@ int ide_raw_taskfile(ide_drive_t *drive, struct ide_cmd *cmd, u8 *buf,
 	 */
 	if (nsect) {
 		error = blk_rq_map_kern(drive->queue, rq, buf,
-					nsect * SECTOR_SIZE, __GFP_RECLAIM);
+					nsect * SECTOR_SIZE, GFP_NOIO);
 		if (error)
 			goto put_req;
 	}
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 93cb1a9b6671..33d3bfa3e8ea 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -273,7 +273,7 @@ int scsi_execute(struct scsi_device *sdev, const unsigned char *cmd,
 	rq = scsi_req(req);
 
 	if (bufflen &&	blk_rq_map_kern(sdev->request_queue, req,
-					buffer, bufflen, __GFP_RECLAIM))
+					buffer, bufflen, GFP_NOIO))
 		goto out;
 
 	rq->cmd_len = COMMAND_SIZE(cmd[0]);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 874607bb6e02..093fb54cd316 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -432,8 +432,8 @@ dio_bio_alloc(struct dio *dio, struct dio_submit *sdio,
 	struct bio *bio;
 
 	/*
-	 * bio_alloc() is guaranteed to return a bio when called with
-	 * __GFP_RECLAIM and we request a valid number of vectors.
+	 * bio_alloc() is guaranteed to return a bio when allowed to sleep and
+	 * we request a valid number of vectors.
 	 */
 	bio = bio_alloc(GFP_KERNEL, nr_vecs);
 
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 11b4282c2d20..1efcb5b0c3ed 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -269,7 +269,7 @@ static int hib_submit_io(int op, int op_flags, pgoff_t page_off, void *addr,
 	struct bio *bio;
 	int error = 0;
 
-	bio = bio_alloc(__GFP_RECLAIM | __GFP_HIGH, 1);
+	bio = bio_alloc(GFP_NOIO | __GFP_HIGH, 1);
 	bio->bi_iter.bi_sector = page_off * (PAGE_SIZE >> 9);
 	bio_set_dev(bio, hib_resume_bdev);
 	bio_set_op_attrs(bio, op, op_flags);
@@ -376,7 +376,7 @@ static int write_page(void *buf, sector_t offset, struct hib_bio_batch *hb)
 		return -ENOSPC;
 
 	if (hb) {
-		src = (void *)__get_free_page(__GFP_RECLAIM | __GFP_NOWARN |
+		src = (void *)__get_free_page(GFP_NOIO | __GFP_NOWARN |
 		                              __GFP_NORETRY);
 		if (src) {
 			copy_page(src, buf);
@@ -384,7 +384,7 @@ static int write_page(void *buf, sector_t offset, struct hib_bio_batch *hb)
 			ret = hib_wait_io(hb); /* Free pages */
 			if (ret)
 				return ret;
-			src = (void *)__get_free_page(__GFP_RECLAIM |
+			src = (void *)__get_free_page(GFP_NOIO |
 			                              __GFP_NOWARN |
 			                              __GFP_NORETRY);
 			if (src) {
@@ -691,7 +691,7 @@ static int save_image_lzo(struct swap_map_handle *handle,
 	nr_threads = num_online_cpus() - 1;
 	nr_threads = clamp_val(nr_threads, 1, LZO_THREADS);
 
-	page = (void *)__get_free_page(__GFP_RECLAIM | __GFP_HIGH);
+	page = (void *)__get_free_page(GFP_NOIO | __GFP_HIGH);
 	if (!page) {
 		pr_err("Failed to allocate LZO page\n");
 		ret = -ENOMEM;
@@ -989,7 +989,7 @@ static int get_swap_reader(struct swap_map_handle *handle,
 		last = tmp;
 
 		tmp->map = (struct swap_map_page *)
-			   __get_free_page(__GFP_RECLAIM | __GFP_HIGH);
+			   __get_free_page(GFP_NOIO | __GFP_HIGH);
 		if (!tmp->map) {
 			release_swap_reader(handle);
 			return -ENOMEM;
@@ -1261,8 +1261,8 @@ static int load_image_lzo(struct swap_map_handle *handle,
 
 	for (i = 0; i < read_pages; i++) {
 		page[i] = (void *)__get_free_page(i < LZO_CMP_PAGES ?
-						  __GFP_RECLAIM | __GFP_HIGH :
-						  __GFP_RECLAIM | __GFP_NOWARN |
+						  GFP_NOIO | __GFP_HIGH :
+						  GFP_NOIO | __GFP_NOWARN |
 						  __GFP_NORETRY);
 
 		if (!page[i]) {
-- 
2.16.3
