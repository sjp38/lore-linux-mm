Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 929716B0288
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:26:39 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id q67so7031029oig.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:26:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q60si4128743ota.348.2017.12.18.04.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:26:36 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 15/45] block: rename bio_for_each_segment* with bio_for_each_page*
Date: Mon, 18 Dec 2017 20:22:17 +0800
Message-Id: <20171218122247.3488-16-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

It is a tree-wide mechanical replacement since both bio_for_each_segment()
and bio_for_each_segment_all() never returns real segment at all, and
both just return one page per bvec and deceive us for long time, so fix
their names.

This is a pre-patch for supporting multipage bvec. Once multipage bvec
is in, each bvec will store a real multipage segment, so people won't be
confused with these wrong names.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt     |  4 ++--
 arch/m68k/emu/nfblock.c             |  2 +-
 arch/powerpc/sysdev/axonram.c       |  2 +-
 arch/xtensa/platforms/iss/simdisk.c |  2 +-
 block/bio-integrity.c               |  2 +-
 block/bio.c                         | 24 ++++++++++++------------
 block/blk-merge.c                   |  6 +++---
 block/blk-zoned.c                   |  4 ++--
 block/bounce.c                      |  8 ++++----
 drivers/block/aoe/aoecmd.c          |  4 ++--
 drivers/block/brd.c                 |  2 +-
 drivers/block/drbd/drbd_main.c      |  4 ++--
 drivers/block/drbd/drbd_receiver.c  |  2 +-
 drivers/block/drbd/drbd_worker.c    |  2 +-
 drivers/block/nbd.c                 |  2 +-
 drivers/block/null_blk.c            |  2 +-
 drivers/block/ps3vram.c             |  2 +-
 drivers/block/rbd.c                 |  2 +-
 drivers/block/rsxx/dma.c            |  2 +-
 drivers/block/zram/zram_drv.c       |  2 +-
 drivers/md/bcache/btree.c           |  2 +-
 drivers/md/bcache/debug.c           |  2 +-
 drivers/md/bcache/request.c         |  2 +-
 drivers/md/bcache/util.c            |  2 +-
 drivers/md/dm-crypt.c               |  2 +-
 drivers/md/dm-integrity.c           |  4 ++--
 drivers/md/dm-log-writes.c          |  2 +-
 drivers/md/dm.c                     |  2 +-
 drivers/md/raid1.c                  |  2 +-
 drivers/md/raid5.c                  |  2 +-
 drivers/nvdimm/blk.c                |  2 +-
 drivers/nvdimm/btt.c                |  2 +-
 drivers/nvdimm/pmem.c               |  2 +-
 drivers/s390/block/dcssblk.c        |  2 +-
 drivers/s390/block/xpram.c          |  2 +-
 fs/block_dev.c                      |  4 ++--
 fs/btrfs/check-integrity.c          |  4 ++--
 fs/btrfs/compression.c              |  2 +-
 fs/btrfs/disk-io.c                  |  2 +-
 fs/btrfs/extent_io.c                |  6 +++---
 fs/btrfs/file-item.c                |  4 ++--
 fs/btrfs/inode.c                    |  8 ++++----
 fs/btrfs/raid56.c                   |  4 ++--
 fs/crypto/bio.c                     |  2 +-
 fs/direct-io.c                      |  2 +-
 fs/exofs/ore.c                      |  2 +-
 fs/exofs/ore_raid.c                 |  2 +-
 fs/ext4/page-io.c                   |  2 +-
 fs/ext4/readpage.c                  |  2 +-
 fs/f2fs/data.c                      |  6 +++---
 fs/gfs2/lops.c                      |  2 +-
 fs/gfs2/meta_io.c                   |  2 +-
 fs/iomap.c                          |  2 +-
 fs/mpage.c                          |  2 +-
 fs/xfs/xfs_aops.c                   |  2 +-
 include/linux/bio.h                 | 10 +++++-----
 include/linux/blkdev.h              |  2 +-
 57 files changed, 93 insertions(+), 93 deletions(-)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index 25689584e6e0..b4d238b8d9fc 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -28,10 +28,10 @@ normal code doesn't have to deal with bi_bvec_done.
    constructed from the raw biovecs but taking into account bi_bvec_done and
    bi_size.
 
-   bio_for_each_segment() has been updated to take a bvec_iter argument
+   bio_for_each_page() has been updated to take a bvec_iter argument
    instead of an integer (that corresponded to bi_idx); for a lot of code the
    conversion just required changing the types of the arguments to
-   bio_for_each_segment().
+   bio_for_each_page().
 
  * Advancing a bvec_iter is done with bio_advance_iter(); bio_advance() is a
    wrapper around bio_advance_iter() that operates on bio->bi_iter, and also
diff --git a/arch/m68k/emu/nfblock.c b/arch/m68k/emu/nfblock.c
index e9110b9b8bcd..8b226eac9289 100644
--- a/arch/m68k/emu/nfblock.c
+++ b/arch/m68k/emu/nfblock.c
@@ -69,7 +69,7 @@ static blk_qc_t nfhd_make_request(struct request_queue *queue, struct bio *bio)
 
 	dir = bio_data_dir(bio);
 	shift = dev->bshift;
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		len = bvec.bv_len;
 		len >>= 9;
 		nfhd_read_write(dev->id, 0, dir, sec >> shift, len >> shift,
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 1b307c80b401..c88e041a6a8e 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -121,7 +121,7 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
 				    AXON_RAM_SECTOR_SHIFT);
 	phys_end = bank->io_addr + bank->size;
 	transfered = 0;
-	bio_for_each_segment(vec, bio, iter) {
+	bio_for_each_page(vec, bio, iter) {
 		if (unlikely(phys_mem + vec.bv_len > phys_end)) {
 			bio_io_error(bio);
 			return BLK_QC_T_NONE;
diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index 1b6418407467..8e702e8c75de 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -109,7 +109,7 @@ static blk_qc_t simdisk_make_request(struct request_queue *q, struct bio *bio)
 	struct bvec_iter iter;
 	sector_t sector = bio->bi_iter.bi_sector;
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		char *buffer = kmap_atomic(bvec.bv_page) + bvec.bv_offset;
 		unsigned len = bvec.bv_len >> SECTOR_SHIFT;
 
diff --git a/block/bio-integrity.c b/block/bio-integrity.c
index 23b42e8aa03e..56233c0a1996 100644
--- a/block/bio-integrity.c
+++ b/block/bio-integrity.c
@@ -204,7 +204,7 @@ static blk_status_t bio_integrity_process(struct bio *bio,
 	iter.seed = proc_iter->bi_sector;
 	iter.prot_buf = prot_buf;
 
-	__bio_for_each_segment(bv, bio, bviter, *proc_iter) {
+	__bio_for_each_page(bv, bio, bviter, *proc_iter) {
 		void *kaddr = kmap_atomic(bv.bv_page);
 
 		iter.data_buf = kaddr + bv.bv_offset;
diff --git a/block/bio.c b/block/bio.c
index fe1efbeaf4aa..b93677f8f682 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -535,7 +535,7 @@ void zero_fill_bio(struct bio *bio)
 	struct bio_vec bv;
 	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_page(bv, bio, iter) {
 		char *data = bvec_kmap_irq(&bv, &flags);
 		memset(data, 0, bv.bv_len);
 		flush_dcache_page(bv.bv_page);
@@ -697,7 +697,7 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 		bio->bi_io_vec[bio->bi_vcnt++] = bio_src->bi_io_vec[0];
 		break;
 	default:
-		bio_for_each_segment(bv, bio_src, iter)
+		bio_for_each_page(bv, bio_src, iter)
 			bio->bi_io_vec[bio->bi_vcnt++] = bv;
 		break;
 	}
@@ -1064,7 +1064,7 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 	int i;
 	struct bio_vec *bvec;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1095,7 +1095,7 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 	int i;
 	struct bio_vec *bvec;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1118,7 +1118,7 @@ void bio_free_pages(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_page_all(bvec, bio, i)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1357,7 +1357,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_segment_all(bvec, bio, j) {
+	bio_for_each_page_all(bvec, bio, j) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1372,7 +1372,7 @@ static void __bio_unmap_user(struct bio *bio)
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
@@ -1465,7 +1465,7 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
@@ -1575,7 +1575,7 @@ void bio_set_pages_dirty(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
@@ -1588,7 +1588,7 @@ static void bio_release_pages(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (page)
@@ -1642,7 +1642,7 @@ void bio_check_pages_dirty(struct bio *bio)
 	int nr_clean_pages = 0;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (PageDirty(page) || PageCompound(page)) {
@@ -1700,7 +1700,7 @@ void bio_flush_dcache_pages(struct bio *bi)
 	struct bio_vec bvec;
 	struct bvec_iter iter;
 
-	bio_for_each_segment(bvec, bi, iter)
+	bio_for_each_page(bvec, bi, iter)
 		flush_dcache_page(bvec.bv_page);
 }
 EXPORT_SYMBOL(bio_flush_dcache_pages);
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 39f2c1113423..b571e91b67f6 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -111,7 +111,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 	const unsigned max_sectors = get_max_io_size(q, bio);
 	unsigned advance = 0;
 
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_page(bv, bio, iter) {
 		/*
 		 * If the queue doesn't support SG gaps and adding this
 		 * offset would create a gap, disallow it.
@@ -272,7 +272,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	seg_size = 0;
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
-		bio_for_each_segment(bv, bio, iter) {
+		bio_for_each_page(bv, bio, iter) {
 			/*
 			 * If SG merging is disabled, each bio vector is
 			 * a segment
@@ -456,7 +456,7 @@ static int __blk_bios_map_sg(struct request_queue *q, struct bio *bio,
 	int cluster = blk_queue_cluster(q), nsegs = 0;
 
 	for_each_bio(bio)
-		bio_for_each_segment(bvec, bio, iter)
+		bio_for_each_page(bvec, bio, iter)
 			__blk_segment_map_sg(q, &bvec, sglist, &bvprv, sg,
 					     &nsegs, &cluster);
 
diff --git a/block/blk-zoned.c b/block/blk-zoned.c
index ff57fb51b338..99f6e2cb6fd5 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -148,7 +148,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	n = 0;
 	nz = 0;
 	nr_rep = 0;
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 
 		if (!bv->bv_page)
 			break;
@@ -181,7 +181,7 @@ int blkdev_report_zones(struct block_device *bdev,
 
 	*nr_zones = nz;
 out:
-	bio_for_each_segment_all(bv, bio, i)
+	bio_for_each_page_all(bv, bio, i)
 		__free_page(bv->bv_page);
 	bio_put(bio);
 
diff --git a/block/bounce.c b/block/bounce.c
index c35a3d7f0528..67aa6cff16d6 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -122,7 +122,7 @@ static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 	 */
 	struct bvec_iter from_iter = BVEC_ITER_ALL_INIT;
 
-	bio_for_each_segment(tovec, to, iter) {
+	bio_for_each_page(tovec, to, iter) {
 		fromvec = bio_iter_iovec(from, from_iter);
 		if (tovec.bv_page != fromvec.bv_page) {
 			/*
@@ -150,7 +150,7 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	/*
 	 * free up bounce indirect pages used
 	 */
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
 		if (bvec->bv_page != orig_vec.bv_page) {
 			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
@@ -206,7 +206,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 
-	bio_for_each_segment(from, *bio_orig, iter) {
+	bio_for_each_page(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
 			sectors += from.bv_len >> 9;
 		if (page_to_pfn(from.bv_page) > q->limits.bounce_pfn)
@@ -223,7 +223,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	}
 	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, bounce_bio_set);
 
-	bio_for_each_segment_all(to, bio, i) {
+	bio_for_each_page_all(to, bio, i) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 812fed069708..812a3e11ce37 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -299,7 +299,7 @@ skb_fillup(struct sk_buff *skb, struct bio *bio, struct bvec_iter iter)
 	int frag = 0;
 	struct bio_vec bv;
 
-	__bio_for_each_segment(bv, bio, iter, iter)
+	__bio_for_each_page(bv, bio, iter, iter)
 		skb_fill_page_desc(skb, frag++, bv.bv_page,
 				   bv.bv_offset, bv.bv_len);
 }
@@ -1051,7 +1051,7 @@ bvcpy(struct sk_buff *skb, struct bio *bio, struct bvec_iter iter, long cnt)
 
 	iter.bi_size = cnt;
 
-	__bio_for_each_segment(bv, bio, iter, iter) {
+	__bio_for_each_page(bv, bio, iter, iter) {
 		char *p = page_address(bv.bv_page) + bv.bv_offset;
 		skb_copy_bits(skb, soff, p, bv.bv_len);
 		soff += bv.bv_len;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 8028a3a7e7fd..422a3a7c39ee 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -292,7 +292,7 @@ static blk_qc_t brd_make_request(struct request_queue *q, struct bio *bio)
 	if (bio_end_sector(bio) > get_capacity(bio->bi_disk))
 		goto io_error;
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		unsigned int len = bvec.bv_len;
 		int err;
 
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index 4b4697a1f963..c1ec5665ad8c 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -1601,7 +1601,7 @@ static int _drbd_send_bio(struct drbd_peer_device *peer_device, struct bio *bio)
 	struct bvec_iter iter;
 
 	/* hint all but last page with MSG_MORE */
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		int err;
 
 		err = _drbd_no_send_page(peer_device, bvec.bv_page,
@@ -1623,7 +1623,7 @@ static int _drbd_send_zc_bio(struct drbd_peer_device *peer_device, struct bio *b
 	struct bvec_iter iter;
 
 	/* hint all but last page with MSG_MORE */
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		int err;
 
 		err = _drbd_send_page(peer_device, bvec.bv_page,
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index cb2fa63f6bc0..42f6d1092a05 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -1918,7 +1918,7 @@ static int recv_dless_read(struct drbd_peer_device *peer_device, struct drbd_req
 	bio = req->master_bio;
 	D_ASSERT(peer_device->device, sector == bio->bi_iter.bi_sector);
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		void *mapped = kmap(bvec.bv_page) + bvec.bv_offset;
 		expect = min_t(int, data_size, bvec.bv_len);
 		err = drbd_recv_all_warn(peer_device->connection, mapped, expect);
diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 1476cb3439f4..61e1217920a1 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -337,7 +337,7 @@ void drbd_csum_bio(struct crypto_ahash *tfm, struct bio *bio, void *digest)
 	sg_init_table(&sg, 1);
 	crypto_ahash_init(req);
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		sg_set_page(&sg, bvec.bv_page, bvec.bv_len, bvec.bv_offset);
 		ahash_request_set_crypt(req, &sg, NULL, sg.length);
 		crypto_ahash_update(req);
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 5f2a4240a204..e23bf7bbaed6 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -484,7 +484,7 @@ static int nbd_send_cmd(struct nbd_device *nbd, struct nbd_cmd *cmd, int index)
 		struct bvec_iter iter;
 		struct bio_vec bvec;
 
-		bio_for_each_segment(bvec, bio, iter) {
+		bio_for_each_page(bvec, bio, iter) {
 			bool is_last = !next && bio_iter_last(bvec, iter);
 			int flags = is_last ? 0 : MSG_MORE;
 
diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index ccb9975a97fa..f759b52f4ce2 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -1161,7 +1161,7 @@ static int null_handle_bio(struct nullb_cmd *cmd)
 	}
 
 	spin_lock_irq(&nullb->lock);
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		len = bvec.bv_len;
 		err = null_transfer(nullb, bvec.bv_page, len, bvec.bv_offset,
 				     op_is_write(bio_op(bio)), sector,
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index 6a55959cbf78..c2c5eeefa620 100644
--- a/drivers/block/ps3vram.c
+++ b/drivers/block/ps3vram.c
@@ -557,7 +557,7 @@ static struct bio *ps3vram_do_bio(struct ps3_system_bus_device *dev,
 	struct bvec_iter iter;
 	struct bio *next;
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		/* PS3 is ppc64, so we don't handle highmem */
 		char *ptr = page_address(bvec.bv_page) + bvec.bv_offset;
 		size_t len = bvec.bv_len, retlen;
diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index 38fc5f397fde..18b23ec97d18 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -1279,7 +1279,7 @@ static void zero_bio_chain(struct bio *chain, int start_ofs)
 	int pos = 0;
 
 	while (chain) {
-		bio_for_each_segment(bv, chain, iter) {
+		bio_for_each_page(bv, chain, iter) {
 			if (pos + bv.bv_len > start_ofs) {
 				int remainder = max(start_ofs - pos, 0);
 				buf = bvec_kmap_irq(&bv, &flags);
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index beaccf197a5a..fec10b58a960 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -723,7 +723,7 @@ blk_status_t rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 			bv_len -= RSXX_HW_BLK_SIZE;
 		}
 	} else {
-		bio_for_each_segment(bvec, bio, iter) {
+		bio_for_each_page(bvec, bio, iter) {
 			bv_len = bvec.bv_len;
 			bv_off = bvec.bv_offset;
 
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0afa6c8c3857..3a4c6738f9a8 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1190,7 +1190,7 @@ static void __zram_make_request(struct zram *zram, struct bio *bio)
 		break;
 	}
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		struct bio_vec bv = bvec;
 		unsigned int unwritten = bvec.bv_len;
 
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index ebb1874218e7..a82100527495 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -424,7 +424,7 @@ static void do_btree_node_write(struct btree *b)
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
 
-		bio_for_each_segment_all(bv, b->bio, j)
+		bio_for_each_page_all(bv, b->bio, j)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index 879ab21074c6..995e3ca03066 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -122,7 +122,7 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 	submit_bio_wait(check);
 
 	citer.bi_size = UINT_MAX;
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_page(bv, bio, iter) {
 		void *p1 = kmap_atomic(bv.bv_page);
 		void *p2;
 
diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
index c493fb947dc9..6ee965171e31 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -43,7 +43,7 @@ static void bio_csum(struct bio *bio, struct bkey *k)
 	struct bvec_iter iter;
 	uint64_t csum = 0;
 
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_page(bv, bio, iter) {
 		void *d = kmap(bv.bv_page) + bv.bv_offset;
 		csum = bch_crc64_update(csum, d, bv.bv_len);
 		kunmap(bv.bv_page);
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index a23cd6a14b74..8f2d522822b1 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -298,7 +298,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	int i;
 	struct bio_vec *bv;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 		bv->bv_page = alloc_page(gfp_mask);
 		if (!bv->bv_page) {
 			while (--bv >= bio->bi_io_vec)
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 48332666fc38..970a761de621 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1443,7 +1443,7 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 	unsigned int i;
 	struct bio_vec *bv;
 
-	bio_for_each_segment_all(bv, clone, i) {
+	bio_for_each_page_all(bv, clone, i) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
 	}
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index 05c7bfd0c9d9..734e3005bfbe 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -1256,7 +1256,7 @@ static void integrity_metadata(struct work_struct *w)
 		if (!checksums)
 			checksums = checksums_onstack;
 
-		__bio_for_each_segment(bv, bio, iter, dio->orig_bi_iter) {
+		__bio_for_each_page(bv, bio, iter, dio->orig_bi_iter) {
 			unsigned pos;
 			char *mem, *checksums_ptr;
 
@@ -1376,7 +1376,7 @@ static int dm_integrity_map(struct dm_target *ti, struct bio *bio)
 	if (ic->sectors_per_block > 1) {
 		struct bvec_iter iter;
 		struct bio_vec bv;
-		bio_for_each_segment(bv, bio, iter) {
+		bio_for_each_page(bv, bio, iter) {
 			if (unlikely(bv.bv_len & ((ic->sectors_per_block << SECTOR_SHIFT) - 1))) {
 				DMERR("Bio vector (%u,%u) is not aligned on %u-sector boundary",
 					bv.bv_offset, bv.bv_len, ic->sectors_per_block);
diff --git a/drivers/md/dm-log-writes.c b/drivers/md/dm-log-writes.c
index 189badbeddaf..cd023ff6a33b 100644
--- a/drivers/md/dm-log-writes.c
+++ b/drivers/md/dm-log-writes.c
@@ -773,7 +773,7 @@ static int log_writes_map(struct dm_target *ti, struct bio *bio)
 	 * can't just hold onto the page until some later point, we have to
 	 * manually copy the contents.
 	 */
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_page(bv, bio, iter) {
 		struct page *page;
 		void *src, *dst;
 
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 7475739fee49..9f2d0f5c7eab 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1071,7 +1071,7 @@ void dm_remap_zone_report(struct dm_target *ti, struct bio *bio, sector_t start)
 	 * Remap the start sector of the reported zones. For sequential zones,
 	 * also remap the write pointer position.
 	 */
-	bio_for_each_segment(bvec, report_bio, iter) {
+	bio_for_each_page(bvec, report_bio, iter) {
 		addr = kmap_atomic(bvec.bv_page);
 
 		/* Remember the report header in the first page */
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 6df398e3a008..e64b49929b8d 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2089,7 +2089,7 @@ static void process_checks(struct r1bio *r1_bio)
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_segment_all(bi, sbio, j)
+		bio_for_each_page_all(bi, sbio, j)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 98ce4272ace9..f647c20c68a2 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -1247,7 +1247,7 @@ async_copy_data(int frombio, struct bio *bio, struct page **page,
 		flags |= ASYNC_TX_FENCE;
 	init_async_submit(&submit, flags, tx, NULL, NULL, NULL);
 
-	bio_for_each_segment(bvl, bio, iter) {
+	bio_for_each_page(bvl, bio, iter) {
 		int len = bvl.bv_len;
 		int clen;
 		int b_offset = 0;
diff --git a/drivers/nvdimm/blk.c b/drivers/nvdimm/blk.c
index 345acca576b3..918087381ec0 100644
--- a/drivers/nvdimm/blk.c
+++ b/drivers/nvdimm/blk.c
@@ -187,7 +187,7 @@ static blk_qc_t nd_blk_make_request(struct request_queue *q, struct bio *bio)
 	nsblk = q->queuedata;
 	rw = bio_data_dir(bio);
 	do_acct = nd_iostat_start(bio, &start);
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		unsigned int len = bvec.bv_len;
 
 		BUG_ON(len > PAGE_SIZE);
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index e949e3302af4..580ea01c0d09 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -1319,7 +1319,7 @@ static blk_qc_t btt_make_request(struct request_queue *q, struct bio *bio)
 		return BLK_QC_T_NONE;
 
 	do_acct = nd_iostat_start(bio, &start);
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		unsigned int len = bvec.bv_len;
 
 		if (len > PAGE_SIZE || len < btt->sector_size ||
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7fbc5c5dc8e1..f4caf635f76e 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -182,7 +182,7 @@ static blk_qc_t pmem_make_request(struct request_queue *q, struct bio *bio)
 		nvdimm_flush(nd_region);
 
 	do_acct = nd_iostat_start(bio, &start);
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		rc = pmem_do_bvec(pmem, bvec.bv_page, bvec.bv_len,
 				bvec.bv_offset, op_is_write(bio_op(bio)),
 				iter.bi_sector);
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 6aaefb780436..000a6423d584 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -884,7 +884,7 @@ dcssblk_make_request(struct request_queue *q, struct bio *bio)
 	}
 
 	index = (bio->bi_iter.bi_sector >> 3);
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		page_addr = (unsigned long)
 			page_address(bvec.bv_page) + bvec.bv_offset;
 		source_addr = dev_info->start + (index<<12) + bytes_done;
diff --git a/drivers/s390/block/xpram.c b/drivers/s390/block/xpram.c
index 2a6334ca750e..e488f6f959c6 100644
--- a/drivers/s390/block/xpram.c
+++ b/drivers/s390/block/xpram.c
@@ -203,7 +203,7 @@ static blk_qc_t xpram_make_request(struct request_queue *q, struct bio *bio)
 	if ((bio->bi_iter.bi_sector >> 3) > 0xffffffffU - xdev->offset)
 		goto fail;
 	index = (bio->bi_iter.bi_sector >> 3) + xdev->offset;
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		page_addr = (unsigned long)
 			kmap(bvec.bv_page) + bvec.bv_offset;
 		bytes = bvec.bv_len;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 4a181fcb5175..e73f635502e7 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -242,7 +242,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_segment_all(bvec, &bio, i) {
+	bio_for_each_page_all(bvec, &bio, i) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -310,7 +310,7 @@ static void blkdev_bio_end_io(struct bio *bio)
 		struct bio_vec *bvec;
 		int i;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_page_all(bvec, bio, i)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index 7d51b5a5b505..d200389099db 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2830,7 +2830,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 			goto leave;
 		cur_bytenr = dev_bytenr;
 
-		bio_for_each_segment(bvec, bio, iter) {
+		bio_for_each_page(bvec, bio, iter) {
 			BUG_ON(bvec.bv_len != PAGE_SIZE);
 			mapped_datav[i] = kmap(bvec.bv_page);
 			i++;
@@ -2845,7 +2845,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 					      mapped_datav, segs,
 					      bio, &bio_is_patched,
 					      NULL, bio->bi_opf);
-		bio_for_each_segment(bvec, bio, iter)
+		bio_for_each_page(bvec, bio, iter)
 			kunmap(bvec.bv_page);
 		kfree(mapped_datav);
 	} else if (NULL != dev_state && (bio->bi_opf & REQ_PREFLUSH)) {
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 75610d23d197..15430c9fc6d7 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -171,7 +171,7 @@ static void end_compressed_bio_read(struct bio *bio)
 		 * checked so the end_io handlers know about it
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
-		bio_for_each_segment_all(bvec, cb->orig_bio, i)
+		bio_for_each_page_all(bvec, cb->orig_bio, i)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index a8ecccfc36de..4f80361fbea9 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -805,7 +805,7 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	int i, ret = 0;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index d43360b33ef6..6984e0d5b00d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2453,7 +2453,7 @@ static void end_bio_extent_writepage(struct bio *bio)
 	int i;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2524,7 +2524,7 @@ static void end_bio_extent_readpage(struct bio *bio)
 	int i;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3683,7 +3683,7 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	int i, done;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index fdcb41002623..771189dcaa82 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -222,7 +222,7 @@ static blk_status_t __btrfs_lookup_bio_sums(struct inode *inode, struct bio *bio
 	if (dio)
 		offset = logical_offset;
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		page_bytes_left = bvec.bv_len;
 		if (count)
 			goto next;
@@ -464,7 +464,7 @@ blk_status_t btrfs_csum_one_bio(struct inode *inode, struct bio *bio,
 	sums->bytenr = (u64)bio->bi_iter.bi_sector << 9;
 	index = 0;
 
-	bio_for_each_segment(bvec, bio, iter) {
+	bio_for_each_page(bvec, bio, iter) {
 		if (!contig)
 			offset = page_offset(bvec.bv_page) + bvec.bv_offset;
 
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index cb1e2d201434..c279030ee5ed 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8080,7 +8080,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_page_all(bvec, bio, i)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -8110,7 +8110,7 @@ static blk_status_t __btrfs_correct_data_nocsum(struct inode *inode,
 	done.inode = inode;
 	io_bio->bio.bi_iter = io_bio->iter;
 
-	bio_for_each_segment(bvec, &io_bio->bio, iter) {
+	bio_for_each_page(bvec, &io_bio->bio, iter) {
 		nr_sectors = BTRFS_BYTES_TO_BLKS(fs_info, bvec.bv_len);
 		pgoff = bvec.bv_offset;
 
@@ -8172,7 +8172,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
@@ -8217,7 +8217,7 @@ static blk_status_t __btrfs_subio_endio_read(struct inode *inode,
 	done.inode = inode;
 	io_bio->bio.bi_iter = io_bio->iter;
 
-	bio_for_each_segment(bvec, &io_bio->bio, iter) {
+	bio_for_each_page(bvec, &io_bio->bio, iter) {
 		nr_sectors = BTRFS_BYTES_TO_BLKS(fs_info, bvec.bv_len);
 
 		pgoff = bvec.bv_offset;
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index a7f79254ecca..6d51d570988f 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -1154,7 +1154,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 		if (bio_flagged(bio, BIO_CLONED))
 			bio->bi_iter = btrfs_io_bio(bio)->iter;
 
-		bio_for_each_segment(bvec, bio, iter) {
+		bio_for_each_page(bvec, bio, iter) {
 			rbio->bio_pages[page_index + i] = bvec.bv_page;
 			i++;
 		}
@@ -1441,7 +1441,7 @@ static void set_bio_pages_uptodate(struct bio *bio)
 	if (bio_flagged(bio, BIO_CLONED))
 		bio->bi_iter = btrfs_io_bio(bio)->iter;
 
-	bio_for_each_segment(bvec, bio, iter)
+	bio_for_each_page(bvec, bio, iter)
 		SetPageUptodate(bvec.bv_page);
 }
 
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0d5e6a569d58..2dda77c3a89a 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -38,7 +38,7 @@ static void completion_pages(struct work_struct *work)
 	struct bio_vec *bv;
 	int i;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 3aafb3343a65..5e6f4a5772d2 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -530,7 +530,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	if (dio->is_async && dio->op == REQ_OP_READ && dio->should_dirty) {
 		bio_check_pages_dirty(bio);	/* transfers ownership */
 	} else {
-		bio_for_each_segment_all(bvec, bio, i) {
+		bio_for_each_page_all(bvec, bio, i) {
 			struct page *page = bvec->bv_page;
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 3c6a9c156b7a..80517934d7c4 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -407,7 +407,7 @@ static void _clear_bio(struct bio *bio)
 	struct bio_vec *bv;
 	unsigned i;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 		unsigned this_count = bv->bv_len;
 
 		if (likely(PAGE_SIZE == this_count))
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index 27cbdb697649..2c3346cd1b29 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -437,7 +437,7 @@ static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
 		if (!bio)
 			continue;
 
-		bio_for_each_segment_all(bv, bio, i) {
+		bio_for_each_page_all(bv, bio, i) {
 			struct page *page = bv->bv_page;
 
 			SetPageUptodate(page);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index db7590178dfc..52f2937f5603 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -64,7 +64,7 @@ static void ext4_finish_bio(struct bio *bio)
 	int i;
 	struct bio_vec *bvec;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 		struct page *data_page = NULL;
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 9ffa6fad18db..572b6296f709 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -81,7 +81,7 @@ static void mpage_end_io(struct bio *bio)
 			return;
 		}
 	}
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
 
 		if (!bio->bi_status) {
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 455f086cce3d..c404bd86169e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -71,7 +71,7 @@ static void f2fs_read_end_io(struct bio *bio)
 		}
 	}
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (!bio->bi_status) {
@@ -92,7 +92,7 @@ static void f2fs_write_end_io(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 		enum count_type type = WB_DATA_TYPE(page);
 
@@ -260,7 +260,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io,
 	if (!inode && !ino)
 		return true;
 
-	bio_for_each_segment_all(bvec, io->bio, i) {
+	bio_for_each_page_all(bvec, io->bio, i) {
 
 		if (bvec->bv_page->mapping)
 			target = bvec->bv_page;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index c8ff7b7954f0..4579b8433955 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -213,7 +213,7 @@ static void gfs2_end_log_write(struct bio *bio)
 		wake_up(&sdp->sd_logd_waitq);
 	}
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index 52de1036d9f9..1d720352310a 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -191,7 +191,7 @@ static void gfs2_meta_read_endio(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_page_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
diff --git a/fs/iomap.c b/fs/iomap.c
index 47d29ccffaef..286daad10ba2 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -815,7 +815,7 @@ static void iomap_dio_bio_end_io(struct bio *bio)
 		struct bio_vec *bvec;
 		int i;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_page_all(bvec, bio, i)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/mpage.c b/fs/mpage.c
index b7e7f570733a..1cf322c4d6f8 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -49,7 +49,7 @@ static void mpage_end_io(struct bio *bio)
 	struct bio_vec *bv;
 	int i;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_page_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
 		page_endio(page, op_is_write(bio_op(bio)),
 				blk_status_to_errno(bio->bi_status));
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 21e2d70884e1..8c19f7e0fd32 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -180,7 +180,7 @@ xfs_destroy_ioend(
 			next = bio->bi_private;
 
 		/* walk each page on bio, ending page IO on them */
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_page_all(bvec, bio, i)
 			xfs_finish_page_writeback(inode, bvec, error);
 
 		bio_put(bio);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 367a979fd4a6..27dd152697ac 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -153,7 +153,7 @@ static inline void *bio_data(struct bio *bio)
  * drivers should _never_ use the all version - the bio may have been split
  * before it got to the driver and the driver won't own all of it
  */
-#define bio_for_each_segment_all(bvl, bio, i)				\
+#define bio_for_each_page_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
 static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
@@ -184,14 +184,14 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 	return bvec_iter_rewind(bio->bi_io_vec, iter, bytes);
 }
 
-#define __bio_for_each_segment(bvl, bio, iter, start)			\
+#define __bio_for_each_page(bvl, bio, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
 		((bvl = bio_iter_iovec((bio), (iter))), 1);		\
 	     bio_advance_iter((bio), &(iter), (bvl).bv_len))
 
-#define bio_for_each_segment(bvl, bio, iter)				\
-	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
+#define bio_for_each_page(bvl, bio, iter)				\
+	__bio_for_each_page(bvl, bio, iter, (bio)->bi_iter)
 
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
@@ -217,7 +217,7 @@ static inline unsigned bio_segments(struct bio *bio)
 		break;
 	}
 
-	bio_for_each_segment(bv, bio, iter)
+	bio_for_each_page(bv, bio, iter)
 		segs++;
 
 	return segs;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 8089ca17db9a..d7ff29298e2b 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -909,7 +909,7 @@ struct req_iterator {
 
 #define rq_for_each_segment(bvl, _rq, _iter)			\
 	__rq_for_each_bio(_iter.bio, _rq)			\
-		bio_for_each_segment(bvl, _iter.bio, _iter.iter)
+		bio_for_each_page(bvl, _iter.bio, _iter.iter)
 
 #define rq_iter_last(bvec, _iter)				\
 		(_iter.bio->bi_next == NULL &&			\
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
