Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4AD166B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 13:40:23 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bi5so2273564pad.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:40:22 -0700 (PDT)
From: Kent Overstreet <koverstreet@google.com>
Subject: [PATCH 04/22] block: Convert bio_for_each_segment() to bvec_iter
Date: Wed, 27 Mar 2013 10:39:34 -0700
Message-Id: <1364405992-28424-5-git-send-email-koverstreet@google.com>
In-Reply-To: <1364405992-28424-1-git-send-email-koverstreet@google.com>
References: <1364405992-28424-1-git-send-email-koverstreet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, dm-devel@vger.kernel.org
Cc: tj@kernel.org, neilb@suse.de, Kent Overstreet <koverstreet@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Ed L. Cashin" <ecashin@coraid.com>, Nick Piggin <npiggin@kernel.dk>, Lars Ellenberg <drbd-dev@lists.linbit.com>, Jiri Kosina <jkosina@suse.cz>, Paul Clements <Paul.Clements@steeleye.com>, Jim Paris <jim@jtan.com>, Geoff Levand <geoff@infradead.org>, Yehuda Sadeh <yehuda@inktank.com>, Sage Weil <sage@inktank.com>, Alex Elder <elder@inktank.com>, ceph-devel@vger.kernel.org, Joshua Morris <josh.h.morris@us.ibm.com>, Philip Kelleher <pjk1939@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>, Sreekanth Reddy <Sreekanth.Reddy@lsi.com>, support@lsi.com, "James E.J. Bottomley" <JBottomley@parallels.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Guo Chao <yan@linux.vnet.ibm.com>, Asai Thambi S P <asamymuthupa@micron.com>, Selvan Mani <smani@micron.com>, Sam Bradshaw <sbradshaw@micron.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Keith Busch <keith.busch@intel.com>, Stephen Hemminger <shemminger@vyatta.com>, Quoc-Son Anh <quoc-sonx.anh@intel.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Mike Snitzer <snitzer@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Chris Metcalf <cmetcalf@tilera.com>, Jan Kara <jack@suse.cz>, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, drbd-user@lists.linbit.com, nbd-general@lists.sourceforge.net, cbe-oss-dev@lists.ozlabs.org, xen-devel@lists.xensource.com, virtualization@lists.linux-foundation.org, linux-raid@vger.kernel.org, linux-s390@vger.kernel.org, DL-MPTFusionLinux@lsi.com, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, cluster-devel@redhat.com, linux-mm@kvack.org

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
 arch/m68k/emu/nfblock.c                  | 11 ++++---
 arch/powerpc/sysdev/axonram.c            | 18 +++++------
 block/blk-merge.c                        | 45 ++++++++++++++-------------
 drivers/block/aoe/aoecmd.c               | 16 +++++-----
 drivers/block/brd.c                      | 12 ++++----
 drivers/block/drbd/drbd_main.c           | 27 +++++++++--------
 drivers/block/drbd/drbd_receiver.c       | 13 ++++----
 drivers/block/drbd/drbd_worker.c         |  8 ++---
 drivers/block/floppy.c                   | 12 ++++----
 drivers/block/loop.c                     | 23 +++++++-------
 drivers/block/mtip32xx/mtip32xx.c        | 13 ++++----
 drivers/block/nbd.c                      | 12 ++++----
 drivers/block/nvme.c                     | 27 +++++++++--------
 drivers/block/ps3vram.c                  | 10 +++---
 drivers/block/rbd.c                      | 36 +++++++++++-----------
 drivers/block/rsxx/dma.c                 | 11 ++++---
 drivers/block/xen-blkfront.c             | 14 ++++-----
 drivers/md/md.c                          | 16 +++++-----
 drivers/md/raid5.c                       | 12 ++++----
 drivers/s390/block/dcssblk.c             | 14 ++++-----
 drivers/s390/block/xpram.c               | 10 +++---
 drivers/scsi/mpt2sas/mpt2sas_transport.c | 31 ++++++++++---------
 drivers/scsi/mpt3sas/mpt3sas_transport.c | 31 ++++++++++---------
 drivers/staging/zram/zram_drv.c          | 19 ++++++------
 fs/bio-integrity.c                       | 30 +++++++++---------
 fs/bio.c                                 | 16 +++++-----
 fs/gfs2/lops.c                           | 10 +++---
 include/linux/bio.h                      | 25 ++++++++-------
 include/linux/blkdev.h                   |  7 +++--
 mm/bounce.c                              | 52 +++++++++++++++-----------------
 30 files changed, 296 insertions(+), 285 deletions(-)

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
index 5b04c25..cd15b38 100644
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
index 80e5d65..63acfa1 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -887,12 +887,12 @@ rqbiocnt(struct request *r)
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
@@ -909,11 +909,11 @@ bio_pageinc(struct bio *bio)
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
index ddf2b79..0f3a3bb 100644
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
index e98da67..e90074c 100644
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
index bd27a65..7735ce0 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -1593,9 +1593,10 @@ static int drbd_drain_block(struct drbd_conf *mdev, int data_size)
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
 
@@ -1615,11 +1616,11 @@ static int recv_dless_read(struct drbd_conf *mdev, struct drbd_request *req,
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
index 424dc7b..f961a3b 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -312,8 +312,8 @@ void drbd_csum_bio(struct drbd_conf *mdev, struct crypto_hash *tfm, struct bio *
 {
 	struct hash_desc desc;
 	struct scatterlist sg;
-	struct bio_vec *bvec;
-	int i;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	desc.tfm = tfm;
 	desc.flags = 0;
@@ -321,8 +321,8 @@ void drbd_csum_bio(struct drbd_conf *mdev, struct crypto_hash *tfm, struct bio *
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
index f09fb23..ffea352 100644
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
index 2e4e0be..cd4a90e 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -286,9 +286,10 @@ static int lo_send(struct loop_device *lo, struct bio *bio, loff_t pos)
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
@@ -300,11 +301,11 @@ static int lo_send(struct loop_device *lo, struct bio *bio, loff_t pos)
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
@@ -390,20 +391,20 @@ do_lo_receive(struct loop_device *lo,
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
index 85b9f12..daf84a3 100644
--- a/drivers/block/mtip32xx/mtip32xx.c
+++ b/drivers/block/mtip32xx/mtip32xx.c
@@ -3731,7 +3731,8 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct driver_data *dd = queue->queuedata;
 	struct scatterlist *sg;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	int nents = 0;
 	int tag = 0;
 
@@ -3782,11 +3783,11 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
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
index 7fecc78..c426d18 100644
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
diff --git a/drivers/block/nvme.c b/drivers/block/nvme.c
index bc97493..faddcf3 100644
--- a/drivers/block/nvme.c
+++ b/drivers/block/nvme.c
@@ -380,7 +380,7 @@ static void bio_completion(struct nvme_dev *dev, void *ctx,
 	nvme_free_iod(dev, iod);
 	if (status) {
 		bio_endio(bio, -EIO);
-	} else if (bio->bi_vcnt > bio->bi_iter.bi_idx) {
+	} else if (bio->bi_iter.bi_size) {
 		requeue_bio(dev, bio);
 	} else {
 		bio_endio(bio, 0);
@@ -476,33 +476,34 @@ static int nvme_setup_prps(struct nvme_dev *dev,
 static int nvme_map_bio(struct device *dev, struct nvme_iod *iod,
 		struct bio *bio, enum dma_data_direction dma_dir, int psegs)
 {
-	struct bio_vec *bvec, *bvprv = NULL;
+	struct bio_vec bvec, bvprv;
+	struct bvec_iter iter;
 	struct scatterlist *sg = NULL;
-	int i, old_idx, length = 0, nsegs = 0;
+	int length = 0, nsegs = 0, first = 1;
 
 	sg_init_table(iod->sg, psegs);
-	old_idx = bio->bi_iter.bi_idx;
-	bio_for_each_segment(bvec, bio, i) {
-		if (bvprv && BIOVEC_PHYS_MERGEABLE(bvprv, bvec)) {
-			sg->length += bvec->bv_len;
+	bio_for_each_segment(bvec, bio, iter) {
+		if (!first && BIOVEC_PHYS_MERGEABLE(&bvprv, &bvec)) {
+			sg->length += bvec.bv_len;
 		} else {
-			if (bvprv && BIOVEC_NOT_VIRT_MERGEABLE(bvprv, bvec))
+			if (!first && BIOVEC_NOT_VIRT_MERGEABLE(&bvprv, &bvec))
 				break;
 			sg = sg ? sg + 1 : iod->sg;
-			sg_set_page(sg, bvec->bv_page, bvec->bv_len,
-							bvec->bv_offset);
+			sg_set_page(sg, bvec.bv_page,
+				    bvec.bv_len, bvec.bv_offset);
 			nsegs++;
 		}
-		length += bvec->bv_len;
+		length += bvec.bv_len;
 		bvprv = bvec;
+		first = 0;
 	}
-	bio->bi_iter.bi_idx = i;
 	iod->nents = nsegs;
 	sg_mark_end(sg);
 	if (dma_map_sg(dev, iod->sg, iod->nents, dma_dir) == 0) {
-		bio->bi_iter.bi_idx = old_idx;
 		return -ENOMEM;
 	}
+
+	bio->bi_iter = iter;
 	return length;
 }
 
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index 75e112d..c30864d 100644
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
index 8115eb2..d1e4fd8 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -898,22 +898,22 @@ static void bio_chain_put(struct bio *chain)
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
@@ -929,11 +929,11 @@ static struct bio *bio_clone_range(struct bio *bio_src,
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
 
@@ -952,22 +952,22 @@ static struct bio *bio_clone_range(struct bio *bio_src,
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
 
@@ -985,7 +985,7 @@ static struct bio *bio_clone_range(struct bio *bio_src,
 	 * Copy over our part of the bio_vec, then update the first
 	 * and last (or only) entries.
 	 */
-	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[idx],
+	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[iter.bi_idx],
 			vcnt * sizeof (struct bio_vec));
 	bio->bi_io_vec[0].bv_offset += voff;
 	if (vcnt > 1) {
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index 81d92cb..3b35bb6 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -638,7 +638,8 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 			   void *cb_data)
 {
 	struct list_head dma_list[RSXX_MAX_TARGETS];
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	unsigned long long addr8;
 	unsigned int laddr;
 	unsigned int bv_len;
@@ -676,9 +677,9 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
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
@@ -690,7 +691,7 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 				st = rsxx_queue_dma(card, &dma_list[tgt],
 							bio_data_dir(bio),
 							dma_off, dma_len,
-							laddr, bvec->bv_page,
+							laddr, bvec.bv_page,
 							bv_off, cb, cb_data);
 				if (st)
 					goto bvec_err;
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index c3dae2e..ce5d5ad 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -844,7 +844,7 @@ static void blkif_completion(struct blk_shadow *s, struct blkfront_info *info,
 			     struct blkif_response *bret)
 {
 	int i = 0;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
 	struct req_iterator iter;
 	unsigned long flags;
 	char *bvec_data;
@@ -859,18 +859,18 @@ static void blkif_completion(struct blk_shadow *s, struct blkfront_info *info,
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
diff --git a/drivers/md/md.c b/drivers/md/md.c
index 4fae0aa..2421ccf 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -186,8 +186,8 @@ void md_trim_bio(struct bio *bio, int offset, int size)
 	 * the given offset and size.
 	 * This requires adjusting bi_sector, bi_size, and bi_io_vec
 	 */
-	int i;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	int sofar = 0;
 
 	size <<= 9;
@@ -209,14 +209,14 @@ void md_trim_bio(struct bio *bio, int offset, int size)
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
index a98cbbe..53e3a9e 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -720,9 +720,9 @@ static struct dma_async_tx_descriptor *
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
@@ -736,8 +736,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
 		flags |= ASYNC_TX_FENCE;
 	init_async_submit(&submit, flags, tx, NULL, NULL, NULL);
 
-	bio_for_each_segment(bvl, bio, i) {
-		int len = bvl->bv_len;
+	bio_for_each_segment(bvl, bio, iter) {
+		int len = bvl.bv_len;
 		int clen;
 		int b_offset = 0;
 
@@ -753,8 +753,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
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
index bcebfba..3621e5a 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -812,12 +812,12 @@ static void
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
@@ -848,21 +848,21 @@ dcssblk_make_request(struct request_queue *q, struct bio *bio)
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
index 0330859..c478839 100644
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
index 4d395a5..cd0ed36 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -367,9 +367,10 @@ static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
 
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
@@ -384,33 +385,33 @@ static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
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
index 8543f85..400f90c 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -472,13 +472,13 @@ EXPORT_SYMBOL(bio_alloc_bioset);
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
@@ -1676,10 +1676,10 @@ void bio_check_pages_dirty(struct bio *bio)
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
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 7b2399b..fa9fceb 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -203,19 +203,19 @@ static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
 static void gfs2_end_log_write(struct bio *bio, int error)
 {
 	struct gfs2_sbd *sdp = bio->bi_private;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	struct page *page;
-	int i;
 
 	if (error) {
 		sdp->sd_log_error = error;
 		fs_err(sdp, "Error %d writing to log\n", error);
 	}
 
-	bio_for_each_segment(bvec, bio, i) {
-		page = bvec->bv_page;
+	bio_for_each_segment(bvec, bio, iter) {
+		page = bvec.bv_page;
 		if (page_has_buffers(page))
-			gfs2_end_log_write_bh(sdp, bvec, error);
+			gfs2_end_log_write_bh(sdp, &bvec, error);
 		else
 			mempool_free(page, gfs2_page_pool);
 	}
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
index 89d89c7..f589ed3 100644
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
index f5326b2..deaf1b0 100644
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
 
@@ -184,8 +181,8 @@ static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
 	struct page *page;
 	struct backing_dev_info *bdi;
 	struct address_space *mapping;
-	struct bio_vec *from;
-	int i;
+	struct bio_vec from;
+	struct bvec_iter iter;
 
 	if (bio_data_dir(bio) != WRITE)
 		return 0;
@@ -197,8 +194,8 @@ static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
 	 * Based on the first page that has a valid mapping, decide whether or
 	 * not we have to employ bounce buffering to guarantee stable pages.
 	 */
-	bio_for_each_segment(from, bio, i) {
-		page = from->bv_page;
+	bio_for_each_segment(from, bio, iter) {
+		page = from.bv_page;
 		mapping = page_mapping(page);
 		if (!mapping)
 			continue;
@@ -220,11 +217,12 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
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
1.8.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
