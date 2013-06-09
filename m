Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 21B8F6B0031
	for <linux-mm@kvack.org>; Sat,  8 Jun 2013 22:19:49 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so2626178pdj.31
        for <linux-mm@kvack.org>; Sat, 08 Jun 2013 19:19:48 -0700 (PDT)
From: Kent Overstreet <koverstreet@google.com>
Subject: [PATCH 06/26] block: Convert bio_for_each_segment() to bvec_iter
Date: Sat,  8 Jun 2013 19:18:48 -0700
Message-Id: <1370744348-15407-7-git-send-email-koverstreet@google.com>
In-Reply-To: <1370744348-15407-1-git-send-email-koverstreet@google.com>
References: <1370744348-15407-1-git-send-email-koverstreet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Kent Overstreet <koverstreet@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Ed L. Cashin" <ecashin@coraid.com>, Nick Piggin <npiggin@kernel.dk>, Lars Ellenberg <drbd-dev@lists.linbit.com>, Jiri Kosina <jkosina@suse.cz>, Paul Clements <Paul.Clements@steeleye.com>, Jim Paris <jim@jtan.com>, Geoff Levand <geoff@infradead.org>, Yehuda Sadeh <yehuda@inktank.com>, Sage Weil <sage@inktank.com>, Alex Elder <elder@inktank.com>, ceph-devel@vger.kernel.org, Joshua Morris <josh.h.morris@us.ibm.com>, Philip Kelleher <pjk1939@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Neil Brown <neilb@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>, Sreekanth Reddy <Sreekanth.Reddy@lsi.com>, support@lsi.com, "James E.J. Bottomley" <JBottomley@parallels.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guo Chao <yan@linux.vnet.ibm.com>, Asai Thambi S P <asamymuthupa@micron.com>, Selvan Mani <smani@micron.com>, Sam Bradshaw <sbradshaw@micron.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Keith Busch <keith.busch@intel.com>, Stephen Hemminger <shemminger@vyatta.com>, Quoc-Son Anh <quoc-sonx.anh@intel.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Mike Snitzer <snitzer@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Chris Metcalf <cmetcalf@tilera.com>, Jan Kara <jack@suse.cz>, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, drbd-user@lists.linbit.com, nbd-general@lists.sourceforge.net, cbe-oss-dev@lists.ozlabs.org, xen-devel@lists.xensource.com, virtualization@lists.linux-foundation.org, linux-raid@vger.kernel.org, linux-s390@vger.kernel.org, DL-MPTFusionLinux@lsi.com, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, cluster-devel@redhat.com, linux-mm@kvack.org

More prep work for immutable biovecs - with immutable bvecs drivers
won't be able to use the biovec directly, they'll need to use helpers
that take into account bio->bi_iter.bi_bvec_done.

This updates callers for the new usage without changing the
implementation yet.

Signed-off-by: Kent Overstreet <koverstreet@google.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: "Ed L. Cashin" <ecashin@coraid.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Lars Ellenberg <drbd-dev@lists.linbit.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Paul Clements <Paul.Clements@steeleye.com>
Cc: Jim Paris <jim@jtan.com>
Cc: Geoff Levand <geoff@infradead.org>
Cc: Yehuda Sadeh <yehuda@inktank.com>
Cc: Sage Weil <sage@inktank.com>
Cc: Alex Elder <elder@inktank.com>
Cc: ceph-devel@vger.kernel.org
Cc: Joshua Morris <josh.h.morris@us.ibm.com>
Cc: Philip Kelleher <pjk1939@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>
Cc: Sreekanth Reddy <Sreekanth.Reddy@lsi.com>
Cc: support@lsi.com
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Kent Overstreet <koverstreet@google.com>
Cc: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Guo Chao <yan@linux.vnet.ibm.com>
Cc: Asai Thambi S P <asamymuthupa@micron.com>
Cc: Selvan Mani <smani@micron.com>
Cc: Sam Bradshaw <sbradshaw@micron.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Quoc-Son Anh <quoc-sonx.anh@intel.com>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Jan Kara <jack@suse.cz>
Cc: linux-m68k@lists.linux-m68k.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: drbd-user@lists.linbit.com
Cc: nbd-general@lists.sourceforge.net
Cc: cbe-oss-dev@lists.ozlabs.org
Cc: xen-devel@lists.xensource.com
Cc: virtualization@lists.linux-foundation.org
Cc: linux-raid@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: DL-MPTFusionLinux@lsi.com
Cc: linux-scsi@vger.kernel.org
Cc: devel@driverdev.osuosl.org
Cc: linux-fsdevel@vger.kernel.org
Cc: cluster-devel@redhat.com
Cc: linux-mm@kvack.org
---
 arch/m68k/emu/nfblock.c                  | 11 ++---
 arch/powerpc/sysdev/axonram.c            | 18 ++++-----
 block/blk-merge.c                        | 45 ++++++++++-----------
 drivers/block/aoe/aoecmd.c               | 16 ++++----
 drivers/block/brd.c                      | 12 +++---
 drivers/block/drbd/drbd_main.c           | 27 +++++++------
 drivers/block/drbd/drbd_receiver.c       | 13 +++---
 drivers/block/drbd/drbd_worker.c         |  8 ++--
 drivers/block/floppy.c                   | 12 +++---
 drivers/block/loop.c                     | 23 ++++++-----
 drivers/block/mtip32xx/mtip32xx.c        | 13 +++---
 drivers/block/nbd.c                      | 12 +++---
 drivers/block/nvme-core.c                | 33 ++++++++-------
 drivers/block/ps3vram.c                  | 10 ++---
 drivers/block/rbd.c                      | 36 ++++++++---------
 drivers/block/rsxx/dma.c                 | 11 ++---
 drivers/block/xen-blkfront.c             | 14 +++----
 drivers/md/bcache/btree.c                |  4 +-
 drivers/md/bcache/debug.c                | 23 ++++++-----
 drivers/md/bcache/io.c                   | 69 ++++++++++++++------------------
 drivers/md/bcache/request.c              | 28 ++++++-------
 drivers/md/md.c                          | 16 ++++----
 drivers/md/raid5.c                       | 12 +++---
 drivers/s390/block/dcssblk.c             | 14 +++----
 drivers/s390/block/xpram.c               | 10 ++---
 drivers/scsi/mpt2sas/mpt2sas_transport.c | 31 +++++++-------
 drivers/scsi/mpt3sas/mpt3sas_transport.c | 31 +++++++-------
 drivers/staging/zram/zram_drv.c          | 19 ++++-----
 fs/bio-integrity.c                       | 30 +++++++-------
 fs/bio.c                                 | 16 ++++----
 include/linux/bio.h                      | 25 ++++++------
 include/linux/blkdev.h                   |  7 ++--
 mm/bounce.c                              | 44 ++++++++++----------
 33 files changed, 349 insertions(+), 344 deletions(-)

diff --git a/arch/m68k/emu/nfblock.c b/arch/m68k/emu/nfblock.c
index 9070d6c..d2b260c 100644
--- a/arch/m68k/emu/nfblock.c
+++ b/arch/m68k/emu/nfblock.c
@@ -62,17 +62,18 @@ struct nfhd_device {
 static void nfhd_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct nfhd_device *dev = queue->queuedata;
-	struct bio_vec *bvec;
-	int i, dir, len, shift;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
+	int dir, len, shift;
 	sector_t sec = bio->bi_iter.bi_sector;
 
 	dir = bio_data_dir(bio);
 	shift = dev->bshift;
-	bio_for_each_segment(bvec, bio, i) {
-		len = bvec->bv_len;
+	bio_for_each_segment(bvec, bio, iter) {
+		len = bvec.bv_len;
 		len >>= 9;
 		nfhd_read_write(dev->id, 0, dir, sec >> shift, len >> shift,
-				bvec_to_phys(bvec));
+				bvec_to_phys(&bvec));
 		sec += len;
 	}
 	bio_endio(bio, 0);
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index f33bcba..47b6b9f 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -109,28 +109,28 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
 	struct axon_ram_bank *bank = bio->bi_bdev->bd_disk->private_data;
 	unsigned long phys_mem, phys_end;
 	void *user_mem;
-	struct bio_vec *vec;
+	struct bio_vec vec;
 	unsigned int transfered;
-	unsigned short idx;
+	struct bvec_iter iter;
 
 	phys_mem = bank->io_addr + (bio->bi_iter.bi_sector <<
 				    AXON_RAM_SECTOR_SHIFT);
 	phys_end = bank->io_addr + bank->size;
 	transfered = 0;
-	bio_for_each_segment(vec, bio, idx) {
-		if (unlikely(phys_mem + vec->bv_len > phys_end)) {
+	bio_for_each_segment(vec, bio, iter) {
+		if (unlikely(phys_mem + vec.bv_len > phys_end)) {
 			bio_io_error(bio);
 			return;
 		}
 
-		user_mem = page_address(vec->bv_page) + vec->bv_offset;
+		user_mem = page_address(vec.bv_page) + vec.bv_offset;
 		if (bio_data_dir(bio) == READ)
-			memcpy(user_mem, (void *) phys_mem, vec->bv_len);
+			memcpy(user_mem, (void *) phys_mem, vec.bv_len);
 		else
-			memcpy((void *) phys_mem, user_mem, vec->bv_len);
+			memcpy((void *) phys_mem, user_mem, vec.bv_len);
 
-		phys_mem += vec->bv_len;
-		transfered += vec->bv_len;
+		phys_mem += vec.bv_len;
+		transfered += vec.bv_len;
 	}
 	bio_endio(bio, 0);
 }
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 7750b25..8940562 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -12,10 +12,11 @@
 static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 					     struct bio *bio)
 {
-	struct bio_vec *bv, *bvprv = NULL;
-	int cluster, i, high, highprv = 1;
+	struct bio_vec bv, bvprv;
+	int cluster, high, highprv = 1;
 	unsigned int seg_size, nr_phys_segs;
 	struct bio *fbio, *bbio;
+	struct bvec_iter iter;
 
 	if (!bio)
 		return 0;
@@ -25,25 +26,25 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	seg_size = 0;
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
-		bio_for_each_segment(bv, bio, i) {
+		bio_for_each_segment(bv, bio, iter) {
 			/*
 			 * the trick here is making sure that a high page is
 			 * never considered part of another segment, since that
 			 * might change with the bounce page.
 			 */
-			high = page_to_pfn(bv->bv_page) > queue_bounce_pfn(q);
+			high = page_to_pfn(bv.bv_page) > queue_bounce_pfn(q);
 			if (high || highprv)
 				goto new_segment;
 			if (cluster) {
-				if (seg_size + bv->bv_len
+				if (seg_size + bv.bv_len
 				    > queue_max_segment_size(q))
 					goto new_segment;
-				if (!BIOVEC_PHYS_MERGEABLE(bvprv, bv))
+				if (!BIOVEC_PHYS_MERGEABLE(&bvprv, &bv))
 					goto new_segment;
-				if (!BIOVEC_SEG_BOUNDARY(q, bvprv, bv))
+				if (!BIOVEC_SEG_BOUNDARY(q, &bvprv, &bv))
 					goto new_segment;
 
-				seg_size += bv->bv_len;
+				seg_size += bv.bv_len;
 				bvprv = bv;
 				continue;
 			}
@@ -54,7 +55,7 @@ new_segment:
 
 			nr_phys_segs++;
 			bvprv = bv;
-			seg_size = bv->bv_len;
+			seg_size = bv.bv_len;
 			highprv = high;
 		}
 		bbio = bio;
@@ -110,21 +111,21 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 	return 0;
 }
 
-static void
+static inline void
 __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
-		     struct scatterlist *sglist, struct bio_vec **bvprv,
+		     struct scatterlist *sglist, struct bio_vec *bvprv,
 		     struct scatterlist **sg, int *nsegs, int *cluster)
 {
 
 	int nbytes = bvec->bv_len;
 
-	if (*bvprv && *cluster) {
+	if (*sg && *cluster) {
 		if ((*sg)->length + nbytes > queue_max_segment_size(q))
 			goto new_segment;
 
-		if (!BIOVEC_PHYS_MERGEABLE(*bvprv, bvec))
+		if (!BIOVEC_PHYS_MERGEABLE(bvprv, bvec))
 			goto new_segment;
-		if (!BIOVEC_SEG_BOUNDARY(q, *bvprv, bvec))
+		if (!BIOVEC_SEG_BOUNDARY(q, bvprv, bvec))
 			goto new_segment;
 
 		(*sg)->length += nbytes;
@@ -150,7 +151,7 @@ new_segment:
 		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
 		(*nsegs)++;
 	}
-	*bvprv = bvec;
+	*bvprv = *bvec;
 }
 
 /*
@@ -160,7 +161,7 @@ new_segment:
 int blk_rq_map_sg(struct request_queue *q, struct request *rq,
 		  struct scatterlist *sglist)
 {
-	struct bio_vec *bvec, *bvprv;
+	struct bio_vec bvec, bvprv;
 	struct req_iterator iter;
 	struct scatterlist *sg;
 	int nsegs, cluster;
@@ -171,10 +172,9 @@ int blk_rq_map_sg(struct request_queue *q, struct request *rq,
 	/*
 	 * for each bio in rq
 	 */
-	bvprv = NULL;
 	sg = NULL;
 	rq_for_each_segment(bvec, rq, iter) {
-		__blk_segment_map_sg(q, bvec, sglist, &bvprv, &sg,
+		__blk_segment_map_sg(q, &bvec, sglist, &bvprv, &sg,
 				     &nsegs, &cluster);
 	} /* segments in rq */
 
@@ -223,18 +223,17 @@ EXPORT_SYMBOL(blk_rq_map_sg);
 int blk_bio_map_sg(struct request_queue *q, struct bio *bio,
 		   struct scatterlist *sglist)
 {
-	struct bio_vec *bvec, *bvprv;
+	struct bio_vec bvec, bvprv;
 	struct scatterlist *sg;
 	int nsegs, cluster;
-	unsigned long i;
+	struct bvec_iter iter;
 
 	nsegs = 0;
 	cluster = blk_queue_cluster(q);
 
-	bvprv = NULL;
 	sg = NULL;
-	bio_for_each_segment(bvec, bio, i) {
-		__blk_segment_map_sg(q, bvec, sglist, &bvprv, &sg,
+	bio_for_each_segment(bvec, bio, iter) {
+		__blk_segment_map_sg(q, &bvec, sglist, &bvprv, &sg,
 				     &nsegs, &cluster);
 	} /* segments in bio */
 
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 1fb2d6d..a52975a 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -888,12 +888,12 @@ rqbiocnt(struct request *r)
 static void
 bio_pageinc(struct bio *bio)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	struct page *page;
-	int i;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, i) {
-		page = bv->bv_page;
+	bio_for_each_segment(bv, bio, iter) {
+		page = bv.bv_page;
 		/* Non-zero page count for non-head members of
 		 * compound pages is no longer allowed by the kernel,
 		 * but this has never been seen here.
@@ -910,11 +910,11 @@ bio_pageinc(struct bio *bio)
 static void
 bio_pagedec(struct bio *bio)
 {
-	struct bio_vec *bv;
-	int i;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, i)
-		atomic_dec(&bv->bv_page->_count);
+	bio_for_each_segment(bv, bio, iter)
+		atomic_dec(&bv.bv_page->_count);
 }
 
 static void
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index e269532..0395a3f 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -328,9 +328,9 @@ static void brd_make_request(struct request_queue *q, struct bio *bio)
 	struct block_device *bdev = bio->bi_bdev;
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	int rw;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
 	sector_t sector;
-	int i;
+	struct bvec_iter iter;
 	int err = -EIO;
 
 	sector = bio->bi_iter.bi_sector;
@@ -347,10 +347,10 @@ static void brd_make_request(struct request_queue *q, struct bio *bio)
 	if (rw == READA)
 		rw = READ;
 
-	bio_for_each_segment(bvec, bio, i) {
-		unsigned int len = bvec->bv_len;
-		err = brd_do_bvec(brd, bvec->bv_page, len,
-					bvec->bv_offset, rw, sector);
+	bio_for_each_segment(bvec, bio, iter) {
+		unsigned int len = bvec.bv_len;
+		err = brd_do_bvec(brd, bvec.bv_page, len,
+					bvec.bv_offset, rw, sector);
 		if (err)
 			break;
 		sector += len >> SECTOR_SHIFT;
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index a5dca6a..30b0f91 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -1537,15 +1537,17 @@ static int _drbd_send_page(struct drbd_conf *mdev, struct page *page,
 
 static int _drbd_send_bio(struct drbd_conf *mdev, struct bio *bio)
 {
-	struct bio_vec *bvec;
-	int i;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
+
 	/* hint all but last page with MSG_MORE */
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		int err;
 
-		err = _drbd_no_send_page(mdev, bvec->bv_page,
-					 bvec->bv_offset, bvec->bv_len,
-					 i == bio->bi_vcnt - 1 ? 0 : MSG_MORE);
+		err = _drbd_no_send_page(mdev, bvec.bv_page,
+					 bvec.bv_offset, bvec.bv_len,
+					 bio_iter_last(bio, iter)
+					 ? 0 : MSG_MORE);
 		if (err)
 			return err;
 	}
@@ -1554,15 +1556,16 @@ static int _drbd_send_bio(struct drbd_conf *mdev, struct bio *bio)
 
 static int _drbd_send_zc_bio(struct drbd_conf *mdev, struct bio *bio)
 {
-	struct bio_vec *bvec;
-	int i;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
+
 	/* hint all but last page with MSG_MORE */
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		int err;
 
-		err = _drbd_send_page(mdev, bvec->bv_page,
-				      bvec->bv_offset, bvec->bv_len,
-				      i == bio->bi_vcnt - 1 ? 0 : MSG_MORE);
+		err = _drbd_send_page(mdev, bvec.bv_page,
+				      bvec.bv_offset, bvec.bv_len,
+				      bio_iter_last(bio, iter) ? 0 : MSG_MORE);
 		if (err)
 			return err;
 	}
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index c342f93..2c92af4 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -1595,9 +1595,10 @@ static int drbd_drain_block(struct drbd_conf *mdev, int data_size)
 static int recv_dless_read(struct drbd_conf *mdev, struct drbd_request *req,
 			   sector_t sector, int data_size)
 {
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	struct bio *bio;
-	int dgs, err, i, expect;
+	int dgs, err, expect;
 	void *dig_in = mdev->tconn->int_dig_in;
 	void *dig_vv = mdev->tconn->int_dig_vv;
 
@@ -1617,11 +1618,11 @@ static int recv_dless_read(struct drbd_conf *mdev, struct drbd_request *req,
 	bio = req->master_bio;
 	D_ASSERT(sector == bio->bi_iter.bi_sector);
 
-	bio_for_each_segment(bvec, bio, i) {
-		void *mapped = kmap(bvec->bv_page) + bvec->bv_offset;
-		expect = min_t(int, data_size, bvec->bv_len);
+	bio_for_each_segment(bvec, bio, iter) {
+		void *mapped = kmap(bvec.bv_page) + bvec.bv_offset;
+		expect = min_t(int, data_size, bvec.bv_len);
 		err = drbd_recv_all_warn(mdev->tconn, mapped, expect);
-		kunmap(bvec->bv_page);
+		kunmap(bvec.bv_page);
 		if (err)
 			return err;
 		data_size -= expect;
diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 891c0ec..84d3175 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -313,8 +313,8 @@ void drbd_csum_bio(struct drbd_conf *mdev, struct crypto_hash *tfm, struct bio *
 {
 	struct hash_desc desc;
 	struct scatterlist sg;
-	struct bio_vec *bvec;
-	int i;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	desc.tfm = tfm;
 	desc.flags = 0;
@@ -322,8 +322,8 @@ void drbd_csum_bio(struct drbd_conf *mdev, struct crypto_hash *tfm, struct bio *
 	sg_init_table(&sg, 1);
 	crypto_hash_init(&desc);
 
-	bio_for_each_segment(bvec, bio, i) {
-		sg_set_page(&sg, bvec->bv_page, bvec->bv_len, bvec->bv_offset);
+	bio_for_each_segment(bvec, bio, iter) {
+		sg_set_page(&sg, bvec.bv_page, bvec.bv_len, bvec.bv_offset);
 		crypto_hash_update(&desc, &sg, sg.length);
 	}
 	crypto_hash_final(&desc, digest);
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index bf7b8b2..f312e06 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -2351,7 +2351,7 @@ static void rw_interrupt(void)
 /* Compute maximal contiguous buffer size. */
 static int buffer_chain_size(void)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	int size;
 	struct req_iterator iter;
 	char *base;
@@ -2360,10 +2360,10 @@ static int buffer_chain_size(void)
 	size = 0;
 
 	rq_for_each_segment(bv, current_req, iter) {
-		if (page_address(bv->bv_page) + bv->bv_offset != base + size)
+		if (page_address(bv.bv_page) + bv.bv_offset != base + size)
 			break;
 
-		size += bv->bv_len;
+		size += bv.bv_len;
 	}
 
 	return size >> 9;
@@ -2389,7 +2389,7 @@ static int transfer_size(int ssize, int max_sector, int max_size)
 static void copy_buffer(int ssize, int max_sector, int max_sector_2)
 {
 	int remaining;		/* number of transferred 512-byte sectors */
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *buffer;
 	char *dma_buffer;
 	int size;
@@ -2427,10 +2427,10 @@ static void copy_buffer(int ssize, int max_sector, int max_sector_2)
 		if (!remaining)
 			break;
 
-		size = bv->bv_len;
+		size = bv.bv_len;
 		SUPBOUND(size, remaining);
 
-		buffer = page_address(bv->bv_page) + bv->bv_offset;
+		buffer = page_address(bv.bv_page) + bv.bv_offset;
 		if (dma_buffer + size >
 		    floppy_track_buffer + (max_buffer_sectors << 10) ||
 		    dma_buffer < floppy_track_buffer) {
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 3df42e6..c41f188 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -288,9 +288,10 @@ static int lo_send(struct loop_device *lo, struct bio *bio, loff_t pos)
 {
 	int (*do_lo_send)(struct loop_device *, struct bio_vec *, loff_t,
 			struct page *page);
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	struct page *page = NULL;
-	int i, ret = 0;
+	int ret = 0;
 
 	if (lo->transfer != transfer_none) {
 		page = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
@@ -302,11 +303,11 @@ static int lo_send(struct loop_device *lo, struct bio *bio, loff_t pos)
 		do_lo_send = do_lo_send_direct_write;
 	}
 
-	bio_for_each_segment(bvec, bio, i) {
-		ret = do_lo_send(lo, bvec, pos, page);
+	bio_for_each_segment(bvec, bio, iter) {
+		ret = do_lo_send(lo, &bvec, pos, page);
 		if (ret < 0)
 			break;
-		pos += bvec->bv_len;
+		pos += bvec.bv_len;
 	}
 	if (page) {
 		kunmap(page);
@@ -392,20 +393,20 @@ do_lo_receive(struct loop_device *lo,
 static int
 lo_receive(struct loop_device *lo, struct bio *bio, int bsize, loff_t pos)
 {
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	ssize_t s;
-	int i;
 
-	bio_for_each_segment(bvec, bio, i) {
-		s = do_lo_receive(lo, bvec, bsize, pos);
+	bio_for_each_segment(bvec, bio, iter) {
+		s = do_lo_receive(lo, &bvec, bsize, pos);
 		if (s < 0)
 			return s;
 
-		if (s != bvec->bv_len) {
+		if (s != bvec.bv_len) {
 			zero_fill_bio(bio);
 			break;
 		}
-		pos += bvec->bv_len;
+		pos += bvec.bv_len;
 	}
 	return 0;
 }
diff --git a/drivers/block/mtip32xx/mtip32xx.c b/drivers/block/mtip32xx/mtip32xx.c
index 8d6729c..9fd1751 100644
--- a/drivers/block/mtip32xx/mtip32xx.c
+++ b/drivers/block/mtip32xx/mtip32xx.c
@@ -3862,7 +3862,8 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct driver_data *dd = queue->queuedata;
 	struct scatterlist *sg;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	int nents = 0;
 	int tag = 0, unaligned = 0;
 
@@ -3922,11 +3923,11 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
 		}
 
 		/* Create the scatter list for this bio. */
-		bio_for_each_segment(bvec, bio, nents) {
-			sg_set_page(&sg[nents],
-					bvec->bv_page,
-					bvec->bv_len,
-					bvec->bv_offset);
+		bio_for_each_segment(bvec, bio, iter) {
+			sg_set_page(&sg[nents++],
+					bvec.bv_page,
+					bvec.bv_len,
+					bvec.bv_offset);
 		}
 
 		/* Issue the read/write. */
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 037288e..b446f50 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -271,7 +271,7 @@ static int nbd_send_req(struct nbd_device *nbd, struct request *req)
 
 	if (nbd_cmd(req) == NBD_CMD_WRITE) {
 		struct req_iterator iter;
-		struct bio_vec *bvec;
+		struct bio_vec bvec;
 		/*
 		 * we are really probing at internals to determine
 		 * whether to set MSG_MORE or not...
@@ -281,8 +281,8 @@ static int nbd_send_req(struct nbd_device *nbd, struct request *req)
 			if (!rq_iter_last(req, iter))
 				flags = MSG_MORE;
 			dprintk(DBG_TX, "%s: request %p: sending %d bytes data\n",
-					nbd->disk->disk_name, req, bvec->bv_len);
-			result = sock_send_bvec(nbd, bvec, flags);
+					nbd->disk->disk_name, req, bvec.bv_len);
+			result = sock_send_bvec(nbd, &bvec, flags);
 			if (result <= 0) {
 				dev_err(disk_to_dev(nbd->disk),
 					"Send data failed (result %d)\n",
@@ -378,10 +378,10 @@ static struct request *nbd_read_stat(struct nbd_device *nbd)
 			nbd->disk->disk_name, req);
 	if (nbd_cmd(req) == NBD_CMD_READ) {
 		struct req_iterator iter;
-		struct bio_vec *bvec;
+		struct bio_vec bvec;
 
 		rq_for_each_segment(bvec, req, iter) {
-			result = sock_recv_bvec(nbd, bvec);
+			result = sock_recv_bvec(nbd, &bvec);
 			if (result <= 0) {
 				dev_err(disk_to_dev(nbd->disk), "Receive data failed (result %d)\n",
 					result);
@@ -389,7 +389,7 @@ static struct request *nbd_read_stat(struct nbd_device *nbd)
 				return req;
 			}
 			dprintk(DBG_RX, "%s: request %p: got %d bytes data\n",
-				nbd->disk->disk_name, req, bvec->bv_len);
+				nbd->disk->disk_name, req, bvec.bv_len);
 		}
 	}
 	return req;
diff --git a/drivers/block/nvme-core.c b/drivers/block/nvme-core.c
index c80d308..e4f2c37 100644
--- a/drivers/block/nvme-core.c
+++ b/drivers/block/nvme-core.c
@@ -517,9 +517,11 @@ static int nvme_split_and_submit(struct bio *bio, struct nvme_queue *nvmeq,
 static int nvme_map_bio(struct nvme_queue *nvmeq, struct nvme_iod *iod,
 		struct bio *bio, enum dma_data_direction dma_dir, int psegs)
 {
-	struct bio_vec *bvec, *bvprv = NULL;
+	struct bio_vec bvec, bvprv;
+	struct bvec_iter iter;
 	struct scatterlist *sg = NULL;
-	int i, length = 0, nsegs = 0, split_len = bio->bi_iter.bi_size;
+	int length = 0, nsegs = 0, split_len = bio->bi_iter.bi_size;
+	int first = 1;
 
 	if (nvmeq->dev->stripe_size)
 		split_len = nvmeq->dev->stripe_size -
@@ -527,25 +529,28 @@ static int nvme_map_bio(struct nvme_queue *nvmeq, struct nvme_iod *iod,
 			 (nvmeq->dev->stripe_size - 1));
 
 	sg_init_table(iod->sg, psegs);
-	bio_for_each_segment(bvec, bio, i) {
-		if (bvprv && BIOVEC_PHYS_MERGEABLE(bvprv, bvec)) {
-			sg->length += bvec->bv_len;
+	bio_for_each_segment(bvec, bio, iter) {
+		if (!first && BIOVEC_PHYS_MERGEABLE(&bvprv, &bvec)) {
+			sg->length += bvec.bv_len;
 		} else {
-			if (bvprv && BIOVEC_NOT_VIRT_MERGEABLE(bvprv, bvec))
-				return nvme_split_and_submit(bio, nvmeq, i,
-								length, 0);
+			if (!first && BIOVEC_NOT_VIRT_MERGEABLE(&bvprv, &bvec))
+				return nvme_split_and_submit(bio, nvmeq,
+							     iter.bi_idx,
+							     length, 0);
 
 			sg = sg ? sg + 1 : iod->sg;
-			sg_set_page(sg, bvec->bv_page, bvec->bv_len,
-							bvec->bv_offset);
+			sg_set_page(sg, bvec.bv_page,
+				    bvec.bv_len, bvec.bv_offset);
 			nsegs++;
 		}
 
-		if (split_len - length < bvec->bv_len)
-			return nvme_split_and_submit(bio, nvmeq, i, split_len,
-							split_len - length);
-		length += bvec->bv_len;
+		if (split_len - length < bvec.bv_len)
+			return nvme_split_and_submit(bio, nvmeq, iter.bi_idx,
+						     split_len,
+						     split_len - length);
+		length += bvec.bv_len;
 		bvprv = bvec;
+		first = 0;
 	}
 	iod->nents = nsegs;
 	sg_mark_end(sg);
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index 06a2e53..e473c2e 100644
--- a/drivers/block/ps3vram.c
+++ b/drivers/block/ps3vram.c
@@ -555,14 +555,14 @@ static struct bio *ps3vram_do_bio(struct ps3_system_bus_device *dev,
 	const char *op = write ? "write" : "read";
 	loff_t offset = bio->bi_sector << 9;
 	int error = 0;
-	struct bio_vec *bvec;
-	unsigned int i;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	struct bio *next;
 
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		/* PS3 is ppc64, so we don't handle highmem */
-		char *ptr = page_address(bvec->bv_page) + bvec->bv_offset;
-		size_t len = bvec->bv_len, retlen;
+		char *ptr = page_address(bvec.bv_page) + bvec.bv_offset;
+		size_t len = bvec.bv_len, retlen;
 
 		dev_dbg(&dev->core, "    %s %zu bytes at offset %llu\n", op,
 			len, offset);
diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index ce7b1aa..2a27dca 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -1108,22 +1108,22 @@ static void bio_chain_put(struct bio *chain)
  */
 static void zero_bio_chain(struct bio *chain, int start_ofs)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 	unsigned long flags;
 	void *buf;
-	int i;
 	int pos = 0;
 
 	while (chain) {
-		bio_for_each_segment(bv, chain, i) {
-			if (pos + bv->bv_len > start_ofs) {
+		bio_for_each_segment(bv, chain, iter) {
+			if (pos + bv.bv_len > start_ofs) {
 				int remainder = max(start_ofs - pos, 0);
-				buf = bvec_kmap_irq(bv, &flags);
+				buf = bvec_kmap_irq(&bv, &flags);
 				memset(buf + remainder, 0,
-				       bv->bv_len - remainder);
+				       bv.bv_len - remainder);
 				bvec_kunmap_irq(buf, &flags);
 			}
-			pos += bv->bv_len;
+			pos += bv.bv_len;
 		}
 
 		chain = chain->bi_next;
@@ -1170,11 +1170,11 @@ static struct bio *bio_clone_range(struct bio *bio_src,
 					unsigned int len,
 					gfp_t gfpmask)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
+	struct bvec_iter iter;
+	struct bvec_iter end_iter;
 	unsigned int resid;
-	unsigned short idx;
 	unsigned int voff;
-	unsigned short end_idx;
 	unsigned short vcnt;
 	struct bio *bio;
 
@@ -1193,22 +1193,22 @@ static struct bio *bio_clone_range(struct bio *bio_src,
 	/* Find first affected segment... */
 
 	resid = offset;
-	bio_for_each_segment(bv, bio_src, idx) {
-		if (resid < bv->bv_len)
+	bio_for_each_segment(bv, bio_src, iter) {
+		if (resid < bv.bv_len)
 			break;
-		resid -= bv->bv_len;
+		resid -= bv.bv_len;
 	}
 	voff = resid;
 
 	/* ...and the last affected segment */
 
 	resid += len;
-	__bio_for_each_segment(bv, bio_src, end_idx, idx) {
-		if (resid <= bv->bv_len)
+	__bio_for_each_segment(bv, bio_src, end_iter, iter) {
+		if (resid <= bv.bv_len)
 			break;
-		resid -= bv->bv_len;
+		resid -= bv.bv_len;
 	}
-	vcnt = end_idx - idx + 1;
+	vcnt = end_iter.bi_idx = iter.bi_idx + 1;
 
 	/* Build the clone */
 
@@ -1226,7 +1226,7 @@ static struct bio *bio_clone_range(struct bio *bio_src,
 	 * Copy over our part of the bio_vec, then update the first
 	 * and last (or only) entries.
 	 */
-	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[idx],
+	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[iter.bi_idx],
 			vcnt * sizeof (struct bio_vec));
 	bio->bi_io_vec[0].bv_offset += voff;
 	if (vcnt > 1) {
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index c9bba8b..ac3fa93 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -630,7 +630,8 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 			   void *cb_data)
 {
 	struct list_head dma_list[RSXX_MAX_TARGETS];
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	unsigned long long addr8;
 	unsigned int laddr;
 	unsigned int bv_len;
@@ -668,9 +669,9 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 			bv_len -= RSXX_HW_BLK_SIZE;
 		}
 	} else {
-		bio_for_each_segment(bvec, bio, i) {
-			bv_len = bvec->bv_len;
-			bv_off = bvec->bv_offset;
+		bio_for_each_segment(bvec, bio, iter) {
+			bv_len = bvec.bv_len;
+			bv_off = bvec.bv_offset;
 
 			while (bv_len > 0) {
 				tgt   = rsxx_get_dma_tgt(card, addr8);
@@ -682,7 +683,7 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 				st = rsxx_queue_dma(card, &dma_list[tgt],
 							bio_data_dir(bio),
 							dma_off, dma_len,
-							laddr, bvec->bv_page,
+							laddr, bvec.bv_page,
 							bv_off, cb, cb_data);
 				if (st)
 					goto bvec_err;
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index d89ef86..eed3987 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -867,7 +867,7 @@ static void blkif_completion(struct blk_shadow *s, struct blkfront_info *info,
 			     struct blkif_response *bret)
 {
 	int i = 0;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
 	struct req_iterator iter;
 	unsigned long flags;
 	char *bvec_data;
@@ -882,18 +882,18 @@ static void blkif_completion(struct blk_shadow *s, struct blkfront_info *info,
 		 * to be sure we are copying the data from the right shared page.
 		 */
 		rq_for_each_segment(bvec, s->request, iter) {
-			BUG_ON((bvec->bv_offset + bvec->bv_len) > PAGE_SIZE);
-			if (bvec->bv_offset < offset)
+			BUG_ON((bvec.bv_offset + bvec.bv_len) > PAGE_SIZE);
+			if (bvec.bv_offset < offset)
 				i++;
 			BUG_ON(i >= s->req.u.rw.nr_segments);
 			shared_data = kmap_atomic(
 				pfn_to_page(s->grants_used[i]->pfn));
-			bvec_data = bvec_kmap_irq(bvec, &flags);
-			memcpy(bvec_data, shared_data + bvec->bv_offset,
-				bvec->bv_len);
+			bvec_data = bvec_kmap_irq(&bvec, &flags);
+			memcpy(bvec_data, shared_data + bvec.bv_offset,
+				bvec.bv_len);
 			bvec_kunmap_irq(bvec_data, &flags);
 			kunmap_atomic(shared_data);
-			offset = bvec->bv_offset + bvec->bv_len;
+			offset = bvec.bv_offset + bvec.bv_len;
 		}
 	}
 	/* Add the persistent grant into the list of free grants */
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index d43f480..b6c3a05 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -310,7 +310,7 @@ static void btree_write_done(struct closure *cl)
 	struct bio_vec *bv;
 	int n;
 
-	__bio_for_each_segment(bv, b->bio, n, 0)
+	bio_for_each_segment_all(bv, b->bio, n)
 		__free_page(bv->bv_page);
 
 	__btree_write_done(cl);
@@ -338,7 +338,7 @@ static void do_btree_write(struct btree *b)
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
 
-		bio_for_each_segment(bv, b->bio, j)
+		bio_for_each_segment_all(bv, b->bio, j)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index 4bc7c14..2077848 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -189,7 +189,8 @@ void bch_data_verify(struct search *s)
 	struct cached_dev *dc = container_of(s->d, struct cached_dev, disk);
 	struct closure *cl = &s->cl;
 	struct bio *check;
-	struct bio_vec *bv;
+	struct bio_vec bv, *bv2;
+	struct bvec_iter iter;
 	int i;
 
 	check = bio_clone(s->orig_bio, GFP_NOIO);
@@ -206,24 +207,24 @@ void bch_data_verify(struct search *s)
 	closure_bio_submit(check, cl, &dc->disk);
 	closure_sync(cl);
 
-	bio_for_each_segment(bv, s->orig_bio, i) {
-		void *p1 = kmap(bv->bv_page);
-		void *p2 = kmap(check->bi_io_vec[i].bv_page);
+	bio_for_each_segment(bv, s->orig_bio, iter) {
+		void *p1 = kmap(bv.bv_page);
+		void *p2 = kmap(check->bi_io_vec[iter.bi_idx].bv_page);
 
-		if (memcmp(p1 + bv->bv_offset,
-			   p2 + bv->bv_offset,
-			   bv->bv_len))
+		if (memcmp(p1 + bv.bv_offset,
+			   p2 + bv.bv_offset,
+			   bv.bv_len))
 			printk(KERN_ERR
 			       "bcache (%s): verify failed at sector %llu\n",
 			       bdevname(dc->bdev, name),
 			       (uint64_t) s->orig_bio->bi_iter.bi_sector);
 
-		kunmap(bv->bv_page);
-		kunmap(check->bi_io_vec[i].bv_page);
+		kunmap(bv.bv_page);
+		kunmap(check->bi_io_vec[iter.bi_idx].bv_page);
 	}
 
-	__bio_for_each_segment(bv, check, i, 0)
-		__free_page(bv->bv_page);
+	bio_for_each_segment_all(bv2, check, i)
+		__free_page(bv2->bv_page);
 out_put:
 	bio_put(check);
 }
diff --git a/drivers/md/bcache/io.c b/drivers/md/bcache/io.c
index 13580e5..da198da 100644
--- a/drivers/md/bcache/io.c
+++ b/drivers/md/bcache/io.c
@@ -20,12 +20,12 @@ static void bch_bi_idx_hack_endio(struct bio *bio, int error)
 static void bch_generic_make_request_hack(struct bio *bio)
 {
 	if (bio->bi_iter.bi_idx) {
-		int i;
-		struct bio_vec *bv;
+		struct bio_vec bv;
+		struct bvec_iter iter;
 		struct bio *clone = bio_alloc(GFP_NOIO, bio_segments(bio));
 
-		bio_for_each_segment(bv, bio, i)
-			clone->bi_io_vec[clone->bi_vcnt++] = *bv;
+		bio_for_each_segment(bv, bio, iter)
+			clone->bi_io_vec[clone->bi_vcnt++] = bv;
 
 		clone->bi_iter.bi_sector = bio->bi_iter.bi_sector;
 		clone->bi_bdev		= bio->bi_bdev;
@@ -71,8 +71,9 @@ static void bch_generic_make_request_hack(struct bio *bio)
 struct bio *bch_bio_split(struct bio *bio, int sectors,
 			  gfp_t gfp, struct bio_set *bs)
 {
-	unsigned idx = bio->bi_iter.bi_idx, vcnt = 0, nbytes = sectors << 9;
-	struct bio_vec *bv;
+	unsigned vcnt = 0, nbytes = sectors << 9;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 	struct bio *ret = NULL;
 
 	BUG_ON(sectors <= 0);
@@ -82,49 +83,35 @@ struct bio *bch_bio_split(struct bio *bio, int sectors,
 
 	if (bio->bi_rw & REQ_DISCARD) {
 		ret = bio_alloc_bioset(gfp, 1, bs);
-		idx = 0;
 		goto out;
 	}
 
-	bio_for_each_segment(bv, bio, idx) {
-		vcnt = idx - bio->bi_iter.bi_idx;
+	bio_for_each_segment(bv, bio, iter) {
+		vcnt++;
 
-		if (!nbytes) {
-			ret = bio_alloc_bioset(gfp, vcnt, bs);
-			if (!ret)
-				return NULL;
+		if (nbytes <= bv.bv_len)
+			break;
 
-			memcpy(ret->bi_io_vec, __bio_iovec(bio),
-			       sizeof(struct bio_vec) * vcnt);
+		nbytes -= bv.bv_len;
+	}
 
-			break;
-		} else if (nbytes < bv->bv_len) {
-			ret = bio_alloc_bioset(gfp, ++vcnt, bs);
-			if (!ret)
-				return NULL;
+	ret = bio_alloc_bioset(gfp, vcnt, bs);
+	if (!ret)
+		return NULL;
 
-			memcpy(ret->bi_io_vec, __bio_iovec(bio),
-			       sizeof(struct bio_vec) * vcnt);
+	bio_for_each_segment(bv, bio, iter) {
+		ret->bi_io_vec[ret->bi_vcnt++] = bv;
 
-			ret->bi_io_vec[vcnt - 1].bv_len = nbytes;
-			bv->bv_offset	+= nbytes;
-			bv->bv_len	-= nbytes;
+		if (ret->bi_vcnt == vcnt)
 			break;
-		}
-
-		nbytes -= bv->bv_len;
 	}
+
+	ret->bi_io_vec[ret->bi_vcnt - 1].bv_len = nbytes;
 out:
 	ret->bi_bdev	= bio->bi_bdev;
 	ret->bi_iter.bi_sector	= bio->bi_iter.bi_sector;
 	ret->bi_iter.bi_size	= sectors << 9;
 	ret->bi_rw	= bio->bi_rw;
-	ret->bi_vcnt	= vcnt;
-	ret->bi_max_vecs = vcnt;
-
-	bio->bi_iter.bi_sector	+= sectors;
-	bio->bi_iter.bi_size	-= sectors << 9;
-	bio->bi_iter.bi_idx	 = idx;
 
 	if (bio_integrity(bio)) {
 		if (bio_integrity_clone(ret, bio, gfp)) {
@@ -133,9 +120,10 @@ out:
 		}
 
 		bio_integrity_trim(ret, 0, bio_sectors(ret));
-		bio_integrity_trim(bio, bio_sectors(ret), bio_sectors(bio));
 	}
 
+	bio_advance(bio, ret->bi_iter.bi_size);
+
 	return ret;
 }
 
@@ -151,12 +139,13 @@ static unsigned bch_bio_max_sectors(struct bio *bio)
 
 	if (bio_segments(bio) > max_segments ||
 	    q->merge_bvec_fn) {
-		struct bio_vec *bv;
-		int i, seg = 0;
+		struct bio_vec bv;
+		struct bvec_iter iter;
+		unsigned seg = 0;
 
 		ret = 0;
 
-		bio_for_each_segment(bv, bio, i) {
+		bio_for_each_segment(bv, bio, iter) {
 			struct bvec_merge_data bvm = {
 				.bi_bdev	= bio->bi_bdev,
 				.bi_sector	= bio->bi_iter.bi_sector,
@@ -168,11 +157,11 @@ static unsigned bch_bio_max_sectors(struct bio *bio)
 				break;
 
 			if (q->merge_bvec_fn &&
-			    q->merge_bvec_fn(q, &bvm, bv) < (int) bv->bv_len)
+			    q->merge_bvec_fn(q, &bvm, &bv) < (int) bv.bv_len)
 				break;
 
 			seg++;
-			ret += bv->bv_len >> 9;
+			ret += bv.bv_len >> 9;
 		}
 	}
 
diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
index 6360df5..b0de7a43 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -199,14 +199,14 @@ static bool verify(struct cached_dev *dc, struct bio *bio)
 
 static void bio_csum(struct bio *bio, struct bkey *k)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 	uint64_t csum = 0;
-	int i;
 
-	bio_for_each_segment(bv, bio, i) {
-		void *d = kmap(bv->bv_page) + bv->bv_offset;
-		csum = bch_crc64_update(csum, d, bv->bv_len);
-		kunmap(bv->bv_page);
+	bio_for_each_segment(bv, bio, iter) {
+		void *d = kmap(bv.bv_page) + bv.bv_offset;
+		csum = bch_crc64_update(csum, d, bv.bv_len);
+		kunmap(bv.bv_page);
 	}
 
 	k->ptr[KEY_PTRS(k)] = csum & (~0ULL >> 1);
@@ -757,7 +757,7 @@ static void cached_dev_read_complete(struct closure *cl)
 		int i;
 		struct bio_vec *bv;
 
-		__bio_for_each_segment(bv, s->op.cache_bio, i, 0)
+		bio_for_each_segment_all(bv, s->op.cache_bio, i)
 			__free_page(bv->bv_page);
 	}
 
@@ -1224,17 +1224,17 @@ void bch_cached_dev_request_init(struct cached_dev *dc)
 static int flash_dev_cache_miss(struct btree *b, struct search *s,
 				struct bio *bio, unsigned sectors)
 {
-	struct bio_vec *bv;
-	int i;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 
 	/* Zero fill bio */
 
-	bio_for_each_segment(bv, bio, i) {
-		unsigned j = min(bv->bv_len >> 9, sectors);
+	bio_for_each_segment(bv, bio, iter) {
+		unsigned j = min(bv.bv_len >> 9, sectors);
 
-		void *p = kmap(bv->bv_page);
-		memset(p + bv->bv_offset, 0, j << 9);
-		kunmap(bv->bv_page);
+		void *p = kmap(bv.bv_page);
+		memset(p + bv.bv_offset, 0, j << 9);
+		kunmap(bv.bv_page);
 
 		sectors	-= j;
 	}
diff --git a/drivers/md/md.c b/drivers/md/md.c
index 38464ce..1ed2426 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -189,8 +189,8 @@ void md_trim_bio(struct bio *bio, int offset, int size)
 	 * the given offset and size.
 	 * This requires adjusting bi_sector, bi_size, and bi_io_vec
 	 */
-	int i;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	int sofar = 0;
 
 	size <<= 9;
@@ -212,14 +212,14 @@ void md_trim_bio(struct bio *bio, int offset, int size)
 		bio->bi_iter.bi_idx = 0;
 	}
 	/* Make sure vcnt and last bv are not too big */
-	bio_for_each_segment(bvec, bio, i) {
-		if (sofar + bvec->bv_len > size)
-			bvec->bv_len = size - sofar;
-		if (bvec->bv_len == 0) {
-			bio->bi_vcnt = i;
+	bio_for_each_segment(bvec, bio, iter) {
+		if (sofar + bvec.bv_len > size)
+			bvec.bv_len = size - sofar;
+		if (bvec.bv_len == 0) {
+			bio->bi_vcnt = iter.bi_idx;
 			break;
 		}
-		sofar += bvec->bv_len;
+		sofar += bvec.bv_len;
 	}
 }
 EXPORT_SYMBOL_GPL(md_trim_bio);
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 1b87468..a54eb37 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -725,9 +725,9 @@ static struct dma_async_tx_descriptor *
 async_copy_data(int frombio, struct bio *bio, struct page *page,
 	sector_t sector, struct dma_async_tx_descriptor *tx)
 {
-	struct bio_vec *bvl;
+	struct bio_vec bvl;
+	struct bvec_iter iter;
 	struct page *bio_page;
-	int i;
 	int page_offset;
 	struct async_submit_ctl submit;
 	enum async_tx_flags flags = 0;
@@ -741,8 +741,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
 		flags |= ASYNC_TX_FENCE;
 	init_async_submit(&submit, flags, tx, NULL, NULL, NULL);
 
-	bio_for_each_segment(bvl, bio, i) {
-		int len = bvl->bv_len;
+	bio_for_each_segment(bvl, bio, iter) {
+		int len = bvl.bv_len;
 		int clen;
 		int b_offset = 0;
 
@@ -758,8 +758,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
 			clen = len;
 
 		if (clen > 0) {
-			b_offset += bvl->bv_offset;
-			bio_page = bvl->bv_page;
+			b_offset += bvl.bv_offset;
+			bio_page = bvl.bv_page;
 			if (frombio)
 				tx = async_memcpy(page, bio_page, page_offset,
 						  b_offset, clen, &submit);
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 16814a8..7fef1f9 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -808,12 +808,12 @@ static void
 dcssblk_make_request(struct request_queue *q, struct bio *bio)
 {
 	struct dcssblk_dev_info *dev_info;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	unsigned long index;
 	unsigned long page_addr;
 	unsigned long source_addr;
 	unsigned long bytes_done;
-	int i;
 
 	bytes_done = 0;
 	dev_info = bio->bi_bdev->bd_disk->private_data;
@@ -844,21 +844,21 @@ dcssblk_make_request(struct request_queue *q, struct bio *bio)
 	}
 
 	index = (bio->bi_iter.bi_sector >> 3);
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		page_addr = (unsigned long)
-			page_address(bvec->bv_page) + bvec->bv_offset;
+			page_address(bvec.bv_page) + bvec.bv_offset;
 		source_addr = dev_info->start + (index<<12) + bytes_done;
 		if (unlikely((page_addr & 4095) != 0) || (bvec->bv_len & 4095) != 0)
 			// More paranoia.
 			goto fail;
 		if (bio_data_dir(bio) == READ) {
 			memcpy((void*)page_addr, (void*)source_addr,
-				bvec->bv_len);
+				bvec.bv_len);
 		} else {
 			memcpy((void*)source_addr, (void*)page_addr,
-				bvec->bv_len);
+				bvec.bv_len);
 		}
-		bytes_done += bvec->bv_len;
+		bytes_done += bvec.bv_len;
 	}
 	bio_endio(bio, 0);
 	return;
diff --git a/drivers/s390/block/xpram.c b/drivers/s390/block/xpram.c
index dd4e73f..3e530f9 100644
--- a/drivers/s390/block/xpram.c
+++ b/drivers/s390/block/xpram.c
@@ -184,11 +184,11 @@ static unsigned long xpram_highest_page_index(void)
 static void xpram_make_request(struct request_queue *q, struct bio *bio)
 {
 	xpram_device_t *xdev = bio->bi_bdev->bd_disk->private_data;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	unsigned int index;
 	unsigned long page_addr;
 	unsigned long bytes;
-	int i;
 
 	if ((bio->bi_iter.bi_sector & 7) != 0 ||
 	    (bio->bi_iter.bi_size & 4095) != 0)
@@ -200,10 +200,10 @@ static void xpram_make_request(struct request_queue *q, struct bio *bio)
 	if ((bio->bi_iter.bi_sector >> 3) > 0xffffffffU - xdev->offset)
 		goto fail;
 	index = (bio->bi_iter.bi_sector >> 3) + xdev->offset;
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		page_addr = (unsigned long)
-			kmap(bvec->bv_page) + bvec->bv_offset;
-		bytes = bvec->bv_len;
+			kmap(bvec.bv_page) + bvec.bv_offset;
+		bytes = bvec.bv_len;
 		if ((page_addr & 4095) != 0 || (bytes & 4095) != 0)
 			/* More paranoia. */
 			goto fail;
diff --git a/drivers/scsi/mpt2sas/mpt2sas_transport.c b/drivers/scsi/mpt2sas/mpt2sas_transport.c
index 193e7ae..2c2e01e 100644
--- a/drivers/scsi/mpt2sas/mpt2sas_transport.c
+++ b/drivers/scsi/mpt2sas/mpt2sas_transport.c
@@ -1898,7 +1898,7 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	struct MPT2SAS_ADAPTER *ioc = shost_priv(shost);
 	Mpi2SmpPassthroughRequest_t *mpi_request;
 	Mpi2SmpPassthroughReply_t *mpi_reply;
-	int rc, i;
+	int rc;
 	u16 smid;
 	u32 ioc_state;
 	unsigned long timeleft;
@@ -1913,7 +1913,8 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	void *pci_addr_out = NULL;
 	u16 wait_state_count;
 	struct request *rsp = req->next_rq;
-	struct bio_vec *bvec = NULL;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	if (!rsp) {
 		printk(MPT2SAS_ERR_FMT "%s: the smp response space is "
@@ -1952,11 +1953,11 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 			goto out;
 		}
 
-		bio_for_each_segment(bvec, req->bio, i) {
+		bio_for_each_segment(bvec, req->bio, iter) {
 			memcpy(pci_addr_out + offset,
-			    page_address(bvec->bv_page) + bvec->bv_offset,
-			    bvec->bv_len);
-			offset += bvec->bv_len;
+			    page_address(bvec.bv_page) + bvec.bv_offset,
+			    bvec.bv_len);
+			offset += bvec.bv_len;
 		}
 	} else {
 		dma_addr_out = pci_map_single(ioc->pdev, bio_data(req->bio),
@@ -2103,19 +2104,19 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 			u32 offset = 0;
 			u32 bytes_to_copy =
 			    le16_to_cpu(mpi_reply->ResponseDataLength);
-			bio_for_each_segment(bvec, rsp->bio, i) {
-				if (bytes_to_copy <= bvec->bv_len) {
-					memcpy(page_address(bvec->bv_page) +
-					    bvec->bv_offset, pci_addr_in +
+			bio_for_each_segment(bvec, rsp->bio, iter) {
+				if (bytes_to_copy <= bvec.bv_len) {
+					memcpy(page_address(bvec.bv_page) +
+					    bvec.bv_offset, pci_addr_in +
 					    offset, bytes_to_copy);
 					break;
 				} else {
-					memcpy(page_address(bvec->bv_page) +
-					    bvec->bv_offset, pci_addr_in +
-					    offset, bvec->bv_len);
-					bytes_to_copy -= bvec->bv_len;
+					memcpy(page_address(bvec.bv_page) +
+					    bvec.bv_offset, pci_addr_in +
+					    offset, bvec.bv_len);
+					bytes_to_copy -= bvec.bv_len;
 				}
-				offset += bvec->bv_len;
+				offset += bvec.bv_len;
 			}
 		}
 	} else {
diff --git a/drivers/scsi/mpt3sas/mpt3sas_transport.c b/drivers/scsi/mpt3sas/mpt3sas_transport.c
index 87ca2b7..dd15b2d 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_transport.c
+++ b/drivers/scsi/mpt3sas/mpt3sas_transport.c
@@ -1881,7 +1881,7 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	struct MPT3SAS_ADAPTER *ioc = shost_priv(shost);
 	Mpi2SmpPassthroughRequest_t *mpi_request;
 	Mpi2SmpPassthroughReply_t *mpi_reply;
-	int rc, i;
+	int rc;
 	u16 smid;
 	u32 ioc_state;
 	unsigned long timeleft;
@@ -1895,7 +1895,8 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	void *pci_addr_out = NULL;
 	u16 wait_state_count;
 	struct request *rsp = req->next_rq;
-	struct bio_vec *bvec = NULL;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	if (!rsp) {
 		pr_err(MPT3SAS_FMT "%s: the smp response space is missing\n",
@@ -1935,11 +1936,11 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 			goto out;
 		}
 
-		bio_for_each_segment(bvec, req->bio, i) {
+		bio_for_each_segment(bvec, req->bio, iter) {
 			memcpy(pci_addr_out + offset,
-			    page_address(bvec->bv_page) + bvec->bv_offset,
-			    bvec->bv_len);
-			offset += bvec->bv_len;
+			    page_address(bvec.bv_page) + bvec.bv_offset,
+			    bvec.bv_len);
+			offset += bvec.bv_len;
 		}
 	} else {
 		dma_addr_out = pci_map_single(ioc->pdev, bio_data(req->bio),
@@ -2064,19 +2065,19 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 			u32 offset = 0;
 			u32 bytes_to_copy =
 			    le16_to_cpu(mpi_reply->ResponseDataLength);
-			bio_for_each_segment(bvec, rsp->bio, i) {
-				if (bytes_to_copy <= bvec->bv_len) {
-					memcpy(page_address(bvec->bv_page) +
-					    bvec->bv_offset, pci_addr_in +
+			bio_for_each_segment(bvec, rsp->bio, iter) {
+				if (bytes_to_copy <= bvec.bv_len) {
+					memcpy(page_address(bvec.bv_page) +
+					    bvec.bv_offset, pci_addr_in +
 					    offset, bytes_to_copy);
 					break;
 				} else {
-					memcpy(page_address(bvec->bv_page) +
-					    bvec->bv_offset, pci_addr_in +
-					    offset, bvec->bv_len);
-					bytes_to_copy -= bvec->bv_len;
+					memcpy(page_address(bvec.bv_page) +
+					    bvec.bv_offset, pci_addr_in +
+					    offset, bvec.bv_len);
+					bytes_to_copy -= bvec.bv_len;
 				}
-				offset += bvec->bv_len;
+				offset += bvec.bv_len;
 			}
 		}
 	} else {
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 7680d53..9a45129 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -364,9 +364,10 @@ static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
 
 static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
 {
-	int i, offset;
+	int offset;
 	u32 index;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	switch (rw) {
 	case READ:
@@ -381,33 +382,33 @@ static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
 	offset = (bio->bi_iter.bi_sector &
 		  (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
 
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment(bvec, bio, iter) {
 		int max_transfer_size = PAGE_SIZE - offset;
 
-		if (bvec->bv_len > max_transfer_size) {
+		if (bvec.bv_len > max_transfer_size) {
 			/*
 			 * zram_bvec_rw() can only make operation on a single
 			 * zram page. Split the bio vector.
 			 */
 			struct bio_vec bv;
 
-			bv.bv_page = bvec->bv_page;
+			bv.bv_page = bvec.bv_page;
 			bv.bv_len = max_transfer_size;
-			bv.bv_offset = bvec->bv_offset;
+			bv.bv_offset = bvec.bv_offset;
 
 			if (zram_bvec_rw(zram, &bv, index, offset, bio, rw) < 0)
 				goto out;
 
-			bv.bv_len = bvec->bv_len - max_transfer_size;
+			bv.bv_len = bvec.bv_len - max_transfer_size;
 			bv.bv_offset += max_transfer_size;
 			if (zram_bvec_rw(zram, &bv, index+1, 0, bio, rw) < 0)
 				goto out;
 		} else
-			if (zram_bvec_rw(zram, bvec, index, offset, bio, rw)
+			if (zram_bvec_rw(zram, &bvec, index, offset, bio, rw)
 			    < 0)
 				goto out;
 
-		update_position(&index, &offset, bvec);
+		update_position(&index, &offset, &bvec);
 	}
 
 	set_bit(BIO_UPTODATE, &bio->bi_flags);
diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
index f824c30..4220b96 100644
--- a/fs/bio-integrity.c
+++ b/fs/bio-integrity.c
@@ -299,25 +299,26 @@ static void bio_integrity_generate(struct bio *bio)
 {
 	struct blk_integrity *bi = bdev_get_integrity(bio->bi_bdev);
 	struct blk_integrity_exchg bix;
-	struct bio_vec *bv;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 	sector_t sector = bio->bi_iter.bi_sector;
-	unsigned int i, sectors, total;
+	unsigned int sectors, total;
 	void *prot_buf = bio->bi_integrity->bip_buf;
 
 	total = 0;
 	bix.disk_name = bio->bi_bdev->bd_disk->disk_name;
 	bix.sector_size = bi->sector_size;
 
-	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page);
-		bix.data_buf = kaddr + bv->bv_offset;
-		bix.data_size = bv->bv_len;
+	bio_for_each_segment(bv, bio, iter) {
+		void *kaddr = kmap_atomic(bv.bv_page);
+		bix.data_buf = kaddr + bv.bv_offset;
+		bix.data_size = bv.bv_len;
 		bix.prot_buf = prot_buf;
 		bix.sector = sector;
 
 		bi->generate_fn(&bix);
 
-		sectors = bv->bv_len / bi->sector_size;
+		sectors = bv.bv_len / bi->sector_size;
 		sector += sectors;
 		prot_buf += sectors * bi->tuple_size;
 		total += sectors * bi->tuple_size;
@@ -441,19 +442,20 @@ static int bio_integrity_verify(struct bio *bio)
 {
 	struct blk_integrity *bi = bdev_get_integrity(bio->bi_bdev);
 	struct blk_integrity_exchg bix;
-	struct bio_vec *bv;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 	sector_t sector = bio->bi_integrity->bip_sector;
-	unsigned int i, sectors, total, ret;
+	unsigned int sectors, total, ret;
 	void *prot_buf = bio->bi_integrity->bip_buf;
 
 	ret = total = 0;
 	bix.disk_name = bio->bi_bdev->bd_disk->disk_name;
 	bix.sector_size = bi->sector_size;
 
-	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page);
-		bix.data_buf = kaddr + bv->bv_offset;
-		bix.data_size = bv->bv_len;
+	bio_for_each_segment(bv, bio, iter) {
+		void *kaddr = kmap_atomic(bv.bv_page);
+		bix.data_buf = kaddr + bv.bv_offset;
+		bix.data_size = bv.bv_len;
 		bix.prot_buf = prot_buf;
 		bix.sector = sector;
 
@@ -464,7 +466,7 @@ static int bio_integrity_verify(struct bio *bio)
 			return ret;
 		}
 
-		sectors = bv->bv_len / bi->sector_size;
+		sectors = bv.bv_len / bi->sector_size;
 		sector += sectors;
 		prot_buf += sectors * bi->tuple_size;
 		total += sectors * bi->tuple_size;
diff --git a/fs/bio.c b/fs/bio.c
index f1e7c68..018e3a8 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -473,13 +473,13 @@ EXPORT_SYMBOL(bio_alloc_bioset);
 void zero_fill_bio(struct bio *bio)
 {
 	unsigned long flags;
-	struct bio_vec *bv;
-	int i;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, i) {
-		char *data = bvec_kmap_irq(bv, &flags);
-		memset(data, 0, bv->bv_len);
-		flush_dcache_page(bv->bv_page);
+	bio_for_each_segment(bv, bio, iter) {
+		char *data = bvec_kmap_irq(&bv, &flags);
+		memset(data, 0, bv.bv_len);
+		flush_dcache_page(bv.bv_page);
 		bvec_kunmap_irq(data, &flags);
 	}
 }
@@ -1677,10 +1677,10 @@ void bio_check_pages_dirty(struct bio *bio)
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
 void bio_flush_dcache_pages(struct bio *bi)
 {
-	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bvec, bi, i)
+	bio_for_each_segment(bvec, bi, iter)
 		flush_dcache_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_flush_dcache_pages);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 580c9ae..a31bcd2 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -61,6 +61,8 @@
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
  */
+#define bio_iovec_iter(bio, iter) ((bio)->bi_io_vec[(iter).bi_idx])
+
 #define bio_iovec_idx(bio, idx)	(&((bio)->bi_io_vec[(idx)]))
 #define __bio_iovec(bio)	bio_iovec_idx((bio), (bio)->bi_iter.bi_idx)
 #define bio_iovec(bio)		(*__bio_iovec(bio))
@@ -134,15 +136,6 @@ static inline void *bio_data(struct bio *bio)
 #define bio_io_error(bio) bio_endio((bio), -EIO)
 
 /*
- * drivers should not use the __ version unless they _really_ know what
- * they're doing
- */
-#define __bio_for_each_segment(bvl, bio, i, start_idx)			\
-	for (bvl = bio_iovec_idx((bio), (start_idx)), i = (start_idx);	\
-	     i < (bio)->bi_vcnt;					\
-	     bvl++, i++)
-
-/*
  * drivers should _never_ use the all version - the bio may have been split
  * before it got to the driver and the driver won't own all of it
  */
@@ -151,10 +144,16 @@ static inline void *bio_data(struct bio *bio)
 	     bvl = bio_iovec_idx((bio), (i)), i < (bio)->bi_vcnt;	\
 	     i++)
 
-#define bio_for_each_segment(bvl, bio, i)				\
-	for (i = (bio)->bi_iter.bi_idx;					\
-	     bvl = bio_iovec_idx((bio), (i)), i < (bio)->bi_vcnt;	\
-	     i++)
+#define __bio_for_each_segment(bvl, bio, iter, start)			\
+	for (iter = (start);						\
+	     bvl = bio_iovec_iter((bio), (iter)),			\
+	     (iter).bi_idx < (bio)->bi_vcnt;				\
+	     (iter).bi_idx++)
+
+#define bio_for_each_segment(bvl, bio, iter)				\
+	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
+
+#define bio_iter_last(bio, iter) ((iter).bi_idx == (bio)->bi_vcnt - 1)
 
 /*
  * get a reference to a bio, so it won't disappear. the intended use is
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 2fdb4a4..1b9d47b 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -699,7 +699,7 @@ struct rq_map_data {
 };
 
 struct req_iterator {
-	int i;
+	struct bvec_iter iter;
 	struct bio *bio;
 };
 
@@ -712,10 +712,11 @@ struct req_iterator {
 
 #define rq_for_each_segment(bvl, _rq, _iter)			\
 	__rq_for_each_bio(_iter.bio, _rq)			\
-		bio_for_each_segment(bvl, _iter.bio, _iter.i)
+		bio_for_each_segment(bvl, _iter.bio, _iter.iter)
 
 #define rq_iter_last(rq, _iter)					\
-		(_iter.bio->bi_next == NULL && _iter.i == _iter.bio->bi_vcnt-1)
+		(_iter.bio->bi_next == NULL &&			\
+		 bio_iter_last(_iter.bio, _iter.iter))
 
 #ifndef ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
 # error	"You should define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE for your platform"
diff --git a/mm/bounce.c b/mm/bounce.c
index c9f0a43..4525e3d 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -98,27 +98,24 @@ int init_emergency_isa_pool(void)
 static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 {
 	unsigned char *vfrom;
-	struct bio_vec *tovec, *fromvec;
-	int i;
-
-	bio_for_each_segment(tovec, to, i) {
-		fromvec = from->bi_io_vec + i;
-
-		/*
-		 * not bounced
-		 */
-		if (tovec->bv_page == fromvec->bv_page)
-			continue;
-
-		/*
-		 * fromvec->bv_offset and fromvec->bv_len might have been
-		 * modified by the block layer, so use the original copy,
-		 * bounce_copy_vec already uses tovec->bv_len
-		 */
-		vfrom = page_address(fromvec->bv_page) + tovec->bv_offset;
+	struct bio_vec tovec, *fromvec = from->bi_io_vec;
+	struct bvec_iter iter;
+
+	bio_for_each_segment(tovec, to, iter) {
+		if (tovec.bv_page != fromvec->bv_page) {
+			/*
+			 * fromvec->bv_offset and fromvec->bv_len might have
+			 * been modified by the block layer, so use the original
+			 * copy, bounce_copy_vec already uses tovec->bv_len
+			 */
+			vfrom = page_address(fromvec->bv_page) +
+				tovec.bv_offset;
+
+			bounce_copy_vec(&tovec, vfrom);
+			flush_dcache_page(tovec.bv_page);
+		}
 
-		bounce_copy_vec(tovec, vfrom);
-		flush_dcache_page(tovec->bv_page);
+		fromvec++;
 	}
 }
 
@@ -201,11 +198,12 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 {
 	struct bio *bio;
 	int rw = bio_data_dir(*bio_orig);
-	struct bio_vec *to, *from;
+	struct bio_vec *to, from;
+	struct bvec_iter iter;
 	unsigned i;
 
-	bio_for_each_segment(from, *bio_orig, i)
-		if (page_to_pfn(from->bv_page) > queue_bounce_pfn(q))
+	bio_for_each_segment(from, *bio_orig, iter)
+		if (page_to_pfn(from.bv_page) > queue_bounce_pfn(q))
 			goto bounce;
 
 	return;
-- 
1.8.3.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
