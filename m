Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 683F26B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:45:57 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so8794679pdj.17
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:45:57 -0800 (PST)
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
        by mx.google.com with ESMTPS id sd2si32118236pbb.139.2013.11.26.16.45.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 16:45:55 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so9186530pbb.16
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:45:55 -0800 (PST)
From: Kent Overstreet <kmo@daterainc.com>
Subject: [PATCH 07/25] block: Convert bio_for_each_segment() to bvec_iter
Date: Tue, 26 Nov 2013 16:45:10 -0800
Message-Id: <1385513128-5035-7-git-send-email-kmo@daterainc.com>
In-Reply-To: <1385513128-5035-1-git-send-email-kmo@daterainc.com>
References: <20131127004422.GB21305@kmo>
 <1385513128-5035-1-git-send-email-kmo@daterainc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, hch@infradead.org
Cc: Kent Overstreet <kmo@daterainc.com>, Jens Axboe <axboe@kernel.dk>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Ed L. Cashin" <ecashin@coraid.com>, Nick Piggin <npiggin@kernel.dk>, Lars Ellenberg <drbd-dev@lists.linbit.com>, Jiri Kosina <jkosina@suse.cz>, Paul Clements <Paul.Clements@steeleye.com>, Jim Paris <jim@jtan.com>, Geoff Levand <geoff@infradead.org>, Yehuda Sadeh <yehuda@inktank.com>, Sage Weil <sage@inktank.com>, Alex Elder <elder@inktank.com>, ceph-devel@vger.kernel.org, Joshua Morris <josh.h.morris@us.ibm.com>, Philip Kelleher <pjk1939@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Neil Brown <neilb@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>, Sreekanth Reddy <Sreekanth.Reddy@lsi.com>, support@lsi.com, "James E.J. Bottomley" <JBottomley@parallels.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guo Chao <yan@linux.vnet.ibm.com>, Asai Thambi S P <asamymuthupa@micron.com>, Selvan Mani <smani@micron.com>, Sam Bradshaw <sbradshaw@micron.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Keith Busch <keith.busch@intel.com>, Stephen Hemminger <shemminger@vyatta.com>, Quoc-Son Anh <quoc-sonx.anh@intel.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Mike Snitzer <snitzer@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Chris Metcalf <cmetcalf@tilera.com>, Jan Kara <jack@suse.cz>, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, drbd-user@lists.linbit.com, nbd-general@lists.sourceforge.net, cbe-oss-dev@lists.ozlabs.org, xen-devel@lists.xensource.com, virtualization@lists.linux-foundation.org, linux-raid@vger.kernel.org, linux-s390@vger.kernel.org, DL-MPTFusionLinux@lsi.com, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, cluster-devel@redhat.com, linux-mm@kvack.org

More prep work for immutable biovecs - with immutable bvecs drivers
won't be able to use the biovec directly, they'll need to use helpers
that take into account bio->bi_iter.bi_bvec_done.

This updates callers for the new usage without changing the
implementation yet.

Signed-off-by: Kent Overstreet <kmo@daterainc.com>
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
Acked-by: Geoff Levand <geoff@infradead.org>
---
 arch/m68k/emu/nfblock.c                     | 11 ++---
 arch/powerpc/sysdev/axonram.c               | 18 ++++----
 block/blk-core.c                            |  4 +-
 block/blk-merge.c                           | 49 ++++++++++----------
 drivers/block/aoe/aoecmd.c                  | 16 +++----
 drivers/block/brd.c                         | 12 ++---
 drivers/block/drbd/drbd_main.c              | 27 ++++++-----
 drivers/block/drbd/drbd_receiver.c          | 13 +++---
 drivers/block/drbd/drbd_worker.c            |  8 ++--
 drivers/block/floppy.c                      | 12 ++---
 drivers/block/loop.c                        | 23 +++++-----
 drivers/block/mtip32xx/mtip32xx.c           | 13 +++---
 drivers/block/nbd.c                         | 12 ++---
 drivers/block/nvme-core.c                   | 33 ++++++++------
 drivers/block/ps3disk.c                     | 10 ++---
 drivers/block/ps3vram.c                     | 10 ++---
 drivers/block/rbd.c                         | 38 ++++++++--------
 drivers/block/rsxx/dma.c                    | 11 ++---
 drivers/md/bcache/btree.c                   |  4 +-
 drivers/md/bcache/debug.c                   | 19 ++++----
 drivers/md/bcache/io.c                      | 69 ++++++++++++-----------------
 drivers/md/bcache/request.c                 | 26 +++++------
 drivers/md/raid5.c                          | 12 ++---
 drivers/s390/block/dasd_diag.c              | 10 ++---
 drivers/s390/block/dasd_eckd.c              | 48 ++++++++++----------
 drivers/s390/block/dasd_fba.c               | 26 +++++------
 drivers/s390/block/dcssblk.c                | 16 +++----
 drivers/s390/block/scm_blk.c                |  8 ++--
 drivers/s390/block/scm_blk_cluster.c        |  4 +-
 drivers/s390/block/xpram.c                  | 10 ++---
 drivers/scsi/mpt2sas/mpt2sas_transport.c    | 31 ++++++-------
 drivers/scsi/mpt3sas/mpt3sas_transport.c    | 31 ++++++-------
 drivers/staging/lustre/lustre/llite/lloop.c | 14 +++---
 drivers/staging/zram/zram_drv.c             | 19 ++++----
 fs/bio-integrity.c                          | 30 +++++++------
 fs/bio.c                                    | 22 ++++-----
 include/linux/bio.h                         | 28 ++++++------
 include/linux/blkdev.h                      |  7 +--
 mm/bounce.c                                 | 44 +++++++++---------
 39 files changed, 401 insertions(+), 397 deletions(-)

diff --git a/arch/m68k/emu/nfblock.c b/arch/m68k/emu/nfblock.c
index 0a9d0b3..2d75ae2 100644
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
diff --git a/block/blk-core.c b/block/blk-core.c
index 5c2ab2c..5da8e90 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -2746,10 +2746,10 @@ void blk_rq_bio_prep(struct request_queue *q, struct request *rq,
 void rq_flush_dcache_pages(struct request *rq)
 {
 	struct req_iterator iter;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
 
 	rq_for_each_segment(bvec, rq, iter)
-		flush_dcache_page(bvec->bv_page);
+		flush_dcache_page(bvec.bv_page);
 }
 EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
 #endif
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 03bc083..a1ead90 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -12,10 +12,11 @@
 static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 					     struct bio *bio)
 {
-	struct bio_vec *bv, *bvprv = NULL;
-	int cluster, i, high, highprv = 1;
+	struct bio_vec bv, bvprv = { NULL };
+	int cluster, high, highprv = 1;
 	unsigned int seg_size, nr_phys_segs;
 	struct bio *fbio, *bbio;
+	struct bvec_iter iter;
 
 	if (!bio)
 		return 0;
@@ -25,25 +26,23 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
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
-			if (high || highprv)
-				goto new_segment;
-			if (cluster) {
-				if (seg_size + bv->bv_len
+			high = page_to_pfn(bv.bv_page) > queue_bounce_pfn(q);
+			if (!high && !highprv && cluster) {
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
@@ -54,7 +53,7 @@ new_segment:
 
 			nr_phys_segs++;
 			bvprv = bv;
-			seg_size = bv->bv_len;
+			seg_size = bv.bv_len;
 			highprv = high;
 		}
 		bbio = bio;
@@ -110,21 +109,21 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
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
@@ -150,7 +149,7 @@ new_segment:
 		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
 		(*nsegs)++;
 	}
-	*bvprv = bvec;
+	*bvprv = *bvec;
 }
 
 /*
@@ -160,7 +159,7 @@ new_segment:
 int blk_rq_map_sg(struct request_queue *q, struct request *rq,
 		  struct scatterlist *sglist)
 {
-	struct bio_vec *bvec, *bvprv;
+	struct bio_vec bvec, bvprv;
 	struct req_iterator iter;
 	struct scatterlist *sg;
 	int nsegs, cluster;
@@ -171,10 +170,9 @@ int blk_rq_map_sg(struct request_queue *q, struct request *rq,
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
 
@@ -223,18 +221,17 @@ EXPORT_SYMBOL(blk_rq_map_sg);
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
index 77c24ab..7a06aec 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -897,15 +897,15 @@ rqbiocnt(struct request *r)
 static void
 bio_pageinc(struct bio *bio)
 {
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	struct page *page;
-	int i;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, i) {
+	bio_for_each_segment(bv, bio, iter) {
 		/* Non-zero page count for non-head members of
 		 * compound pages is no longer allowed by the kernel.
 		 */
-		page = compound_trans_head(bv->bv_page);
+		page = compound_trans_head(bv.bv_page);
 		atomic_inc(&page->_count);
 	}
 }
@@ -913,12 +913,12 @@ bio_pageinc(struct bio *bio)
 static void
 bio_pagedec(struct bio *bio)
 {
-	struct bio_vec *bv;
 	struct page *page;
-	int i;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, i) {
-		page = compound_trans_head(bv->bv_page);
+	bio_for_each_segment(bv, bio, iter) {
+		page = compound_trans_head(bv.bv_page);
 		atomic_dec(&page->_count);
 	}
 }
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 66f5aaa..e73b85c 100644
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
index 9e3818b..f4e5440 100644
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
index 5326c22..d073305 100644
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
index 6a86fe7..6b29c44 100644
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
index f5e3998..33fde3a 100644
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
index 69e9eb5..52b2f2a 100644
--- a/drivers/block/mtip32xx/mtip32xx.c
+++ b/drivers/block/mtip32xx/mtip32xx.c
@@ -3962,8 +3962,9 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct driver_data *dd = queue->queuedata;
 	struct scatterlist *sg;
-	struct bio_vec *bvec;
-	int i, nents = 0;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
+	int nents = 0;
 	int tag = 0, unaligned = 0;
 
 	if (unlikely(dd->dd_flag & MTIP_DDF_STOP_IO)) {
@@ -4026,11 +4027,11 @@ static void mtip_make_request(struct request_queue *queue, struct bio *bio)
 		}
 
 		/* Create the scatter list for this bio. */
-		bio_for_each_segment(bvec, bio, i) {
+		bio_for_each_segment(bvec, bio, iter) {
 			sg_set_page(&sg[nents],
-					bvec->bv_page,
-					bvec->bv_len,
-					bvec->bv_offset);
+					bvec.bv_page,
+					bvec.bv_len,
+					bvec.bv_offset);
 			nents++;
 		}
 
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 2dc3b51..aa362f4 100644
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
index 53d2173..5539d29 100644
--- a/drivers/block/nvme-core.c
+++ b/drivers/block/nvme-core.c
@@ -550,9 +550,11 @@ static int nvme_split_and_submit(struct bio *bio, struct nvme_queue *nvmeq,
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
@@ -560,25 +562,28 @@ static int nvme_map_bio(struct nvme_queue *nvmeq, struct nvme_iod *iod,
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
diff --git a/drivers/block/ps3disk.c b/drivers/block/ps3disk.c
index 464be78..1c6edb9 100644
--- a/drivers/block/ps3disk.c
+++ b/drivers/block/ps3disk.c
@@ -94,7 +94,7 @@ static void ps3disk_scatter_gather(struct ps3_storage_device *dev,
 {
 	unsigned int offset = 0;
 	struct req_iterator iter;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
 	unsigned int i = 0;
 	size_t size;
 	void *buf;
@@ -106,14 +106,14 @@ static void ps3disk_scatter_gather(struct ps3_storage_device *dev,
 			__func__, __LINE__, i, bio_segments(iter.bio),
 			bio_sectors(iter.bio), iter.bio->bi_iter.bi_sector);
 
-		size = bvec->bv_len;
-		buf = bvec_kmap_irq(bvec, &flags);
+		size = bvec.bv_len;
+		buf = bvec_kmap_irq(&bvec, &flags);
 		if (gather)
 			memcpy(dev->bounce_buf+offset, buf, size);
 		else
 			memcpy(buf, dev->bounce_buf+offset, size);
 		offset += size;
-		flush_kernel_dcache_page(bvec->bv_page);
+		flush_kernel_dcache_page(bvec.bv_page);
 		bvec_kunmap_irq(buf, &flags);
 		i++;
 	}
@@ -130,7 +130,7 @@ static int ps3disk_submit_request_sg(struct ps3_storage_device *dev,
 
 #ifdef DEBUG
 	unsigned int n = 0;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	struct req_iterator iter;
 
 	rq_for_each_segment(bv, req, iter)
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index 320bbfc..ef45cfb 100644
--- a/drivers/block/ps3vram.c
+++ b/drivers/block/ps3vram.c
@@ -555,14 +555,14 @@ static struct bio *ps3vram_do_bio(struct ps3_system_bus_device *dev,
 	const char *op = write ? "write" : "read";
 	loff_t offset = bio->bi_iter.bi_sector << 9;
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
index a8f4fe2..20e8ab3 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -1109,23 +1109,23 @@ static void bio_chain_put(struct bio *chain)
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
-				flush_dcache_page(bv->bv_page);
+				       bv.bv_len - remainder);
+				flush_dcache_page(bv.bv_page);
 				bvec_kunmap_irq(buf, &flags);
 			}
-			pos += bv->bv_len;
+			pos += bv.bv_len;
 		}
 
 		chain = chain->bi_next;
@@ -1173,11 +1173,11 @@ static struct bio *bio_clone_range(struct bio *bio_src,
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
 
@@ -1196,22 +1196,22 @@ static struct bio *bio_clone_range(struct bio *bio_src,
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
 
@@ -1229,7 +1229,7 @@ static struct bio *bio_clone_range(struct bio *bio_src,
 	 * Copy over our part of the bio_vec, then update the first
 	 * and last (or only) entries.
 	 */
-	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[idx],
+	memcpy(&bio->bi_io_vec[0], &bio_src->bi_io_vec[iter.bi_idx],
 			vcnt * sizeof (struct bio_vec));
 	bio->bi_io_vec[0].bv_offset += voff;
 	if (vcnt > 1) {
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index 3716633..cf8cd29 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -684,7 +684,8 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 			   void *cb_data)
 {
 	struct list_head dma_list[RSXX_MAX_TARGETS];
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 	unsigned long long addr8;
 	unsigned int laddr;
 	unsigned int bv_len;
@@ -722,9 +723,9 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
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
@@ -736,7 +737,7 @@ int rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 				st = rsxx_queue_dma(card, &dma_list[tgt],
 							bio_data_dir(bio),
 							dma_off, dma_len,
-							laddr, bvec->bv_page,
+							laddr, bvec.bv_page,
 							bv_off, cb, cb_data);
 				if (st)
 					goto bvec_err;
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 038a6d2..b62f379 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -362,7 +362,7 @@ static void btree_node_write_done(struct closure *cl)
 	struct bio_vec *bv;
 	int n;
 
-	__bio_for_each_segment(bv, b->bio, n, 0)
+	bio_for_each_segment_all(bv, b->bio, n)
 		__free_page(bv->bv_page);
 
 	__btree_node_write_done(cl);
@@ -421,7 +421,7 @@ static void do_btree_node_write(struct btree *b)
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
 
-		bio_for_each_segment(bv, b->bio, j)
+		bio_for_each_segment_all(bv, b->bio, j)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index 92b3fd4..03cb4d1 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -173,7 +173,8 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 {
 	char name[BDEVNAME_SIZE];
 	struct bio *check;
-	struct bio_vec *bv;
+	struct bio_vec bv, *bv2;
+	struct bvec_iter iter;
 	int i;
 
 	check = bio_clone(bio, GFP_NOIO);
@@ -185,13 +186,13 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 
 	submit_bio_wait(READ_SYNC, check);
 
-	bio_for_each_segment(bv, bio, i) {
-		void *p1 = kmap_atomic(bv->bv_page);
-		void *p2 = page_address(check->bi_io_vec[i].bv_page);
+	bio_for_each_segment(bv, bio, iter) {
+		void *p1 = kmap_atomic(bv.bv_page);
+		void *p2 = page_address(check->bi_io_vec[iter.bi_idx].bv_page);
 
-		cache_set_err_on(memcmp(p1 + bv->bv_offset,
-					p2 + bv->bv_offset,
-					bv->bv_len),
+		cache_set_err_on(memcmp(p1 + bv.bv_offset,
+					p2 + bv.bv_offset,
+					bv.bv_len),
 				 dc->disk.c,
 				 "verify failed at dev %s sector %llu",
 				 bdevname(dc->bdev, name),
@@ -200,8 +201,8 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 		kunmap_atomic(p1);
 	}
 
-	bio_for_each_segment_all(bv, check, i)
-		__free_page(bv->bv_page);
+	bio_for_each_segment_all(bv2, check, i)
+		__free_page(bv2->bv_page);
 out_put:
 	bio_put(check);
 }
diff --git a/drivers/md/bcache/io.c b/drivers/md/bcache/io.c
index dc44f06..9b5b6a4 100644
--- a/drivers/md/bcache/io.c
+++ b/drivers/md/bcache/io.c
@@ -22,12 +22,12 @@ static void bch_bi_idx_hack_endio(struct bio *bio, int error)
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
@@ -73,8 +73,9 @@ static void bch_generic_make_request_hack(struct bio *bio)
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
@@ -86,49 +87,35 @@ struct bio *bch_bio_split(struct bio *bio, int sectors,
 		ret = bio_alloc_bioset(gfp, 1, bs);
 		if (!ret)
 			return NULL;
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
@@ -137,9 +124,10 @@ out:
 		}
 
 		bio_integrity_trim(ret, 0, bio_sectors(ret));
-		bio_integrity_trim(bio, bio_sectors(ret), bio_sectors(bio));
 	}
 
+	bio_advance(bio, ret->bi_iter.bi_size);
+
 	return ret;
 }
 
@@ -155,12 +143,13 @@ static unsigned bch_bio_max_sectors(struct bio *bio)
 
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
@@ -172,11 +161,11 @@ static unsigned bch_bio_max_sectors(struct bio *bio)
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
index 47a9bbc..4c0a422 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -198,14 +198,14 @@ static bool verify(struct cached_dev *dc, struct bio *bio)
 
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
@@ -1182,17 +1182,17 @@ void bch_cached_dev_request_init(struct cached_dev *dc)
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
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index a5d9c0e..bef353c 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -937,9 +937,9 @@ static struct dma_async_tx_descriptor *
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
@@ -953,8 +953,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
 		flags |= ASYNC_TX_FENCE;
 	init_async_submit(&submit, flags, tx, NULL, NULL, NULL);
 
-	bio_for_each_segment(bvl, bio, i) {
-		int len = bvl->bv_len;
+	bio_for_each_segment(bvl, bio, iter) {
+		int len = bvl.bv_len;
 		int clen;
 		int b_offset = 0;
 
@@ -970,8 +970,8 @@ async_copy_data(int frombio, struct bio *bio, struct page *page,
 			clen = len;
 
 		if (clen > 0) {
-			b_offset += bvl->bv_offset;
-			bio_page = bvl->bv_page;
+			b_offset += bvl.bv_offset;
+			bio_page = bvl.bv_page;
 			if (frombio)
 				tx = async_memcpy(page, bio_page, page_offset,
 						  b_offset, clen, &submit);
diff --git a/drivers/s390/block/dasd_diag.c b/drivers/s390/block/dasd_diag.c
index 92bd22c..9cbc567 100644
--- a/drivers/s390/block/dasd_diag.c
+++ b/drivers/s390/block/dasd_diag.c
@@ -504,7 +504,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	struct dasd_diag_req *dreq;
 	struct dasd_diag_bio *dbio;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst;
 	unsigned int count, datasize;
 	sector_t recid, first_rec, last_rec;
@@ -525,10 +525,10 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	/* Check struct bio and count the number of blocks for the request. */
 	count = 0;
 	rq_for_each_segment(bv, req, iter) {
-		if (bv->bv_len & (blksize - 1))
+		if (bv.bv_len & (blksize - 1))
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
-		count += bv->bv_len >> (block->s2b_shift + 9);
+		count += bv.bv_len >> (block->s2b_shift + 9);
 	}
 	/* Paranoia. */
 	if (count != last_rec - first_rec + 1)
@@ -545,8 +545,8 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	dbio = dreq->bio;
 	recid = first_rec;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
-		for (off = 0; off < bv->bv_len; off += blksize) {
+		dst = page_address(bv.bv_page) + bv.bv_offset;
+		for (off = 0; off < bv.bv_len; off += blksize) {
 			memset(dbio, 0, sizeof (struct dasd_diag_bio));
 			dbio->type = rw_cmd;
 			dbio->block_number = recid + 1;
diff --git a/drivers/s390/block/dasd_eckd.c b/drivers/s390/block/dasd_eckd.c
index cee7e27..70d1770 100644
--- a/drivers/s390/block/dasd_eckd.c
+++ b/drivers/s390/block/dasd_eckd.c
@@ -2551,7 +2551,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 	struct dasd_ccw_req *cqr;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst;
 	unsigned int off;
 	int count, cidaw, cplength, datasize;
@@ -2573,13 +2573,13 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 	count = 0;
 	cidaw = 0;
 	rq_for_each_segment(bv, req, iter) {
-		if (bv->bv_len & (blksize - 1))
+		if (bv.bv_len & (blksize - 1))
 			/* Eckd can only do full blocks. */
 			return ERR_PTR(-EINVAL);
-		count += bv->bv_len >> (block->s2b_shift + 9);
+		count += bv.bv_len >> (block->s2b_shift + 9);
 #if defined(CONFIG_64BIT)
-		if (idal_is_needed (page_address(bv->bv_page), bv->bv_len))
-			cidaw += bv->bv_len >> (block->s2b_shift + 9);
+		if (idal_is_needed (page_address(bv.bv_page), bv.bv_len))
+			cidaw += bv.bv_len >> (block->s2b_shift + 9);
 #endif
 	}
 	/* Paranoia. */
@@ -2650,16 +2650,16 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 			      last_rec - recid + 1, cmd, basedev, blksize);
 	}
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
+		dst = page_address(bv.bv_page) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
 						      GFP_DMA | __GFP_NOWARN);
 			if (copy && rq_data_dir(req) == WRITE)
-				memcpy(copy + bv->bv_offset, dst, bv->bv_len);
+				memcpy(copy + bv.bv_offset, dst, bv.bv_len);
 			if (copy)
-				dst = copy + bv->bv_offset;
+				dst = copy + bv.bv_offset;
 		}
-		for (off = 0; off < bv->bv_len; off += blksize) {
+		for (off = 0; off < bv.bv_len; off += blksize) {
 			sector_t trkid = recid;
 			unsigned int recoffs = sector_div(trkid, blk_per_trk);
 			rcmd = cmd;
@@ -2735,7 +2735,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_track(
 	struct dasd_ccw_req *cqr;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst, *idaw_dst;
 	unsigned int cidaw, cplength, datasize;
 	unsigned int tlf;
@@ -2813,8 +2813,8 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_track(
 	idaw_dst = NULL;
 	idaw_len = 0;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
-		seg_len = bv->bv_len;
+		dst = page_address(bv.bv_page) + bv.bv_offset;
+		seg_len = bv.bv_len;
 		while (seg_len) {
 			if (new_track) {
 				trkid = recid;
@@ -3039,7 +3039,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 {
 	struct dasd_ccw_req *cqr;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst;
 	unsigned int trkcount, ctidaw;
 	unsigned char cmd;
@@ -3125,8 +3125,8 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 		new_track = 1;
 		recid = first_rec;
 		rq_for_each_segment(bv, req, iter) {
-			dst = page_address(bv->bv_page) + bv->bv_offset;
-			seg_len = bv->bv_len;
+			dst = page_address(bv.bv_page) + bv.bv_offset;
+			seg_len = bv.bv_len;
 			while (seg_len) {
 				if (new_track) {
 					trkid = recid;
@@ -3158,9 +3158,9 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 		}
 	} else {
 		rq_for_each_segment(bv, req, iter) {
-			dst = page_address(bv->bv_page) + bv->bv_offset;
+			dst = page_address(bv.bv_page) + bv.bv_offset;
 			last_tidaw = itcw_add_tidaw(itcw, 0x00,
-						    dst, bv->bv_len);
+						    dst, bv.bv_len);
 			if (IS_ERR(last_tidaw)) {
 				ret = -EINVAL;
 				goto out_error;
@@ -3276,7 +3276,7 @@ static struct dasd_ccw_req *dasd_raw_build_cp(struct dasd_device *startdev,
 	struct dasd_ccw_req *cqr;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst;
 	unsigned char cmd;
 	unsigned int trkcount;
@@ -3376,8 +3376,8 @@ static struct dasd_ccw_req *dasd_raw_build_cp(struct dasd_device *startdev,
 			idaws = idal_create_words(idaws, rawpadpage, PAGE_SIZE);
 	}
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
-		seg_len = bv->bv_len;
+		dst = page_address(bv.bv_page) + bv.bv_offset;
+		seg_len = bv.bv_len;
 		if (cmd == DASD_ECKD_CCW_READ_TRACK)
 			memset(dst, 0, seg_len);
 		if (!len_to_track_end) {
@@ -3422,7 +3422,7 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	struct dasd_eckd_private *private;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst, *cda;
 	unsigned int blksize, blk_per_trk, off;
 	sector_t recid;
@@ -3440,8 +3440,8 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	if (private->uses_cdl == 0 || recid > 2*blk_per_trk)
 		ccw++;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
-		for (off = 0; off < bv->bv_len; off += blksize) {
+		dst = page_address(bv.bv_page) + bv.bv_offset;
+		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
 			if (private->uses_cdl && recid <= 2*blk_per_trk)
 				ccw++;
@@ -3452,7 +3452,7 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 					cda = (char *)((addr_t) ccw->cda);
 				if (dst != cda) {
 					if (rq_data_dir(req) == READ)
-						memcpy(dst, cda, bv->bv_len);
+						memcpy(dst, cda, bv.bv_len);
 					kmem_cache_free(dasd_page_cache,
 					    (void *)((addr_t)cda & PAGE_MASK));
 				}
diff --git a/drivers/s390/block/dasd_fba.c b/drivers/s390/block/dasd_fba.c
index 9cbc8c3..2c8e68b 100644
--- a/drivers/s390/block/dasd_fba.c
+++ b/drivers/s390/block/dasd_fba.c
@@ -260,7 +260,7 @@ static struct dasd_ccw_req *dasd_fba_build_cp(struct dasd_device * memdev,
 	struct dasd_ccw_req *cqr;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst;
 	int count, cidaw, cplength, datasize;
 	sector_t recid, first_rec, last_rec;
@@ -283,13 +283,13 @@ static struct dasd_ccw_req *dasd_fba_build_cp(struct dasd_device * memdev,
 	count = 0;
 	cidaw = 0;
 	rq_for_each_segment(bv, req, iter) {
-		if (bv->bv_len & (blksize - 1))
+		if (bv.bv_len & (blksize - 1))
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
-		count += bv->bv_len >> (block->s2b_shift + 9);
+		count += bv.bv_len >> (block->s2b_shift + 9);
 #if defined(CONFIG_64BIT)
-		if (idal_is_needed (page_address(bv->bv_page), bv->bv_len))
-			cidaw += bv->bv_len / blksize;
+		if (idal_is_needed (page_address(bv.bv_page), bv.bv_len))
+			cidaw += bv.bv_len / blksize;
 #endif
 	}
 	/* Paranoia. */
@@ -326,16 +326,16 @@ static struct dasd_ccw_req *dasd_fba_build_cp(struct dasd_device * memdev,
 	}
 	recid = first_rec;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
+		dst = page_address(bv.bv_page) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
 						      GFP_DMA | __GFP_NOWARN);
 			if (copy && rq_data_dir(req) == WRITE)
-				memcpy(copy + bv->bv_offset, dst, bv->bv_len);
+				memcpy(copy + bv.bv_offset, dst, bv.bv_len);
 			if (copy)
-				dst = copy + bv->bv_offset;
+				dst = copy + bv.bv_offset;
 		}
-		for (off = 0; off < bv->bv_len; off += blksize) {
+		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Locate record for stupid devices. */
 			if (private->rdc_data.mode.bits.data_chain == 0) {
 				ccw[-1].flags |= CCW_FLAG_CC;
@@ -384,7 +384,7 @@ dasd_fba_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	struct dasd_fba_private *private;
 	struct ccw1 *ccw;
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	char *dst, *cda;
 	unsigned int blksize, off;
 	int status;
@@ -399,8 +399,8 @@ dasd_fba_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	if (private->rdc_data.mode.bits.data_chain != 0)
 		ccw++;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv->bv_page) + bv->bv_offset;
-		for (off = 0; off < bv->bv_len; off += blksize) {
+		dst = page_address(bv.bv_page) + bv.bv_offset;
+		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
 			if (private->rdc_data.mode.bits.data_chain == 0)
 				ccw++;
@@ -411,7 +411,7 @@ dasd_fba_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 					cda = (char *)((addr_t) ccw->cda);
 				if (dst != cda) {
 					if (rq_data_dir(req) == READ)
-						memcpy(dst, cda, bv->bv_len);
+						memcpy(dst, cda, bv.bv_len);
 					kmem_cache_free(dasd_page_cache,
 					    (void *)((addr_t)cda & PAGE_MASK));
 				}
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 16814a8..ebf41e2 100644
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
-		if (unlikely((page_addr & 4095) != 0) || (bvec->bv_len & 4095) != 0)
+		if (unlikely((page_addr & 4095) != 0) || (bvec.bv_len & 4095) != 0)
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
diff --git a/drivers/s390/block/scm_blk.c b/drivers/s390/block/scm_blk.c
index d0ab501..76bed17 100644
--- a/drivers/s390/block/scm_blk.c
+++ b/drivers/s390/block/scm_blk.c
@@ -130,7 +130,7 @@ static void scm_request_prepare(struct scm_request *scmrq)
 	struct aidaw *aidaw = scmrq->aidaw;
 	struct msb *msb = &scmrq->aob->msb[0];
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 
 	msb->bs = MSB_BS_4K;
 	scmrq->aob->request.msb_count = 1;
@@ -142,9 +142,9 @@ static void scm_request_prepare(struct scm_request *scmrq)
 	msb->data_addr = (u64) aidaw;
 
 	rq_for_each_segment(bv, scmrq->request, iter) {
-		WARN_ON(bv->bv_offset);
-		msb->blk_count += bv->bv_len >> 12;
-		aidaw->data_addr = (u64) page_address(bv->bv_page);
+		WARN_ON(bv.bv_offset);
+		msb->blk_count += bv.bv_len >> 12;
+		aidaw->data_addr = (u64) page_address(bv.bv_page);
 		aidaw++;
 	}
 }
diff --git a/drivers/s390/block/scm_blk_cluster.c b/drivers/s390/block/scm_blk_cluster.c
index 27f930c..9aae909 100644
--- a/drivers/s390/block/scm_blk_cluster.c
+++ b/drivers/s390/block/scm_blk_cluster.c
@@ -122,7 +122,7 @@ static void scm_prepare_cluster_request(struct scm_request *scmrq)
 	struct aidaw *aidaw = scmrq->aidaw;
 	struct msb *msb = &scmrq->aob->msb[0];
 	struct req_iterator iter;
-	struct bio_vec *bv;
+	struct bio_vec bv;
 	int i = 0;
 	u64 addr;
 
@@ -163,7 +163,7 @@ static void scm_prepare_cluster_request(struct scm_request *scmrq)
 			i++;
 		}
 		rq_for_each_segment(bv, req, iter) {
-			aidaw->data_addr = (u64) page_address(bv->bv_page);
+			aidaw->data_addr = (u64) page_address(bv.bv_page);
 			aidaw++;
 			i++;
 		}
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
index 9d26637..7143e86 100644
--- a/drivers/scsi/mpt2sas/mpt2sas_transport.c
+++ b/drivers/scsi/mpt2sas/mpt2sas_transport.c
@@ -1901,7 +1901,7 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	struct MPT2SAS_ADAPTER *ioc = shost_priv(shost);
 	Mpi2SmpPassthroughRequest_t *mpi_request;
 	Mpi2SmpPassthroughReply_t *mpi_reply;
-	int rc, i;
+	int rc;
 	u16 smid;
 	u32 ioc_state;
 	unsigned long timeleft;
@@ -1916,7 +1916,8 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	void *pci_addr_out = NULL;
 	u16 wait_state_count;
 	struct request *rsp = req->next_rq;
-	struct bio_vec *bvec = NULL;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	if (!rsp) {
 		printk(MPT2SAS_ERR_FMT "%s: the smp response space is "
@@ -1955,11 +1956,11 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
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
@@ -2106,19 +2107,19 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
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
index e771a88..196a67f 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_transport.c
+++ b/drivers/scsi/mpt3sas/mpt3sas_transport.c
@@ -1884,7 +1884,7 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	struct MPT3SAS_ADAPTER *ioc = shost_priv(shost);
 	Mpi2SmpPassthroughRequest_t *mpi_request;
 	Mpi2SmpPassthroughReply_t *mpi_reply;
-	int rc, i;
+	int rc;
 	u16 smid;
 	u32 ioc_state;
 	unsigned long timeleft;
@@ -1898,7 +1898,8 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
 	void *pci_addr_out = NULL;
 	u16 wait_state_count;
 	struct request *rsp = req->next_rq;
-	struct bio_vec *bvec = NULL;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
 	if (!rsp) {
 		pr_err(MPT3SAS_FMT "%s: the smp response space is missing\n",
@@ -1938,11 +1939,11 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
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
@@ -2067,19 +2068,19 @@ _transport_smp_handler(struct Scsi_Host *shost, struct sas_rphy *rphy,
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
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 53741be..581ff78 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -194,10 +194,10 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 	struct cl_object     *obj = ll_i2info(inode)->lli_clob;
 	pgoff_t	       offset;
 	int		   ret;
-	int		   i;
 	int		   rw;
 	obd_count	     page_count = 0;
-	struct bio_vec       *bvec;
+	struct bio_vec       bvec;
+	struct bvec_iter   iter;
 	struct bio	   *bio;
 	ssize_t	       bytes;
 
@@ -221,14 +221,14 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 		LASSERT(rw == bio->bi_rw);
 
 		offset = (pgoff_t)(bio->bi_iter.bi_sector << 9) + lo->lo_offset;
-		bio_for_each_segment(bvec, bio, i) {
-			BUG_ON(bvec->bv_offset != 0);
-			BUG_ON(bvec->bv_len != PAGE_CACHE_SIZE);
+		bio_for_each_segment(bvec, bio, iter) {
+			BUG_ON(bvec.bv_offset != 0);
+			BUG_ON(bvec.bv_len != PAGE_CACHE_SIZE);
 
-			pages[page_count] = bvec->bv_page;
+			pages[page_count] = bvec.bv_page;
 			offsets[page_count] = offset;
 			page_count++;
-			offset += bvec->bv_len;
+			offset += bvec.bv_len;
 		}
 		LASSERT(page_count <= LLOOP_MAX_SEGMENTS);
 	}
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index e9e6f98..6f98838 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -672,9 +672,10 @@ static ssize_t reset_store(struct device *dev,
 
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
@@ -689,33 +690,33 @@ static void __zram_make_request(struct zram *zram, struct bio *bio, int rw)
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
index 08e3d13..9127db8 100644
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
index 7bb281f..8b7f14a 100644
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
@@ -1687,11 +1687,11 @@ void bio_check_pages_dirty(struct bio *bio)
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
 void bio_flush_dcache_pages(struct bio *bi)
 {
-	int i;
-	struct bio_vec *bvec;
+	struct bio_vec bvec;
+	struct bvec_iter iter;
 
-	bio_for_each_segment(bvec, bi, i)
-		flush_dcache_page(bvec->bv_page);
+	bio_for_each_segment(bvec, bi, iter)
+		flush_dcache_page(bvec.bv_page);
 }
 EXPORT_SYMBOL(bio_flush_dcache_pages);
 #endif
@@ -1840,7 +1840,7 @@ void bio_trim(struct bio *bio, int offset, int size)
 		bio->bi_iter.bi_idx = 0;
 	}
 	/* Make sure vcnt and last bv are not too big */
-	bio_for_each_segment(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i) {
 		if (sofar + bvec->bv_len > size)
 			bvec->bv_len = size - sofar;
 		if (bvec->bv_len == 0) {
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 9f182fc..c16adb5 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -63,10 +63,13 @@
  */
 #define bio_iovec_idx(bio, idx)	(&((bio)->bi_io_vec[(idx)]))
 #define __bio_iovec(bio)	bio_iovec_idx((bio), (bio)->bi_iter.bi_idx)
-#define bio_iovec(bio)		(*__bio_iovec(bio))
+
+#define bio_iter_iovec(bio, iter) ((bio)->bi_io_vec[(iter).bi_idx])
 
 #define bio_page(bio)		(bio_iovec((bio)).bv_page)
 #define bio_offset(bio)		(bio_iovec((bio)).bv_offset)
+#define bio_iovec(bio)		(*__bio_iovec(bio))
+
 #define bio_segments(bio)	((bio)->bi_vcnt - (bio)->bi_iter.bi_idx)
 #define bio_sectors(bio)	((bio)->bi_iter.bi_size >> 9)
 #define bio_end_sector(bio)	((bio)->bi_iter.bi_sector + bio_sectors((bio)))
@@ -134,15 +137,6 @@ static inline void *bio_data(struct bio *bio)
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
@@ -151,10 +145,16 @@ static inline void *bio_data(struct bio *bio)
 	     bvl = bio_iovec_idx((bio), (i)), i < (bio)->bi_vcnt;	\
 	     i++)
 
-#define bio_for_each_segment(bvl, bio, i)				\
-	for (i = (bio)->bi_iter.bi_idx;					\
-	     bvl = bio_iovec_idx((bio), (i)), i < (bio)->bi_vcnt;	\
-	     i++)
+#define __bio_for_each_segment(bvl, bio, iter, start)			\
+	for (iter = (start);						\
+	     bvl = bio_iter_iovec((bio), (iter)),			\
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
index 1b135d4..337b92a 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -735,7 +735,7 @@ struct rq_map_data {
 };
 
 struct req_iterator {
-	int i;
+	struct bvec_iter iter;
 	struct bio *bio;
 };
 
@@ -748,10 +748,11 @@ struct req_iterator {
 
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
index 5a7d58f..523918b 100644
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
 
@@ -201,13 +198,14 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 {
 	struct bio *bio;
 	int rw = bio_data_dir(*bio_orig);
-	struct bio_vec *to, *from;
+	struct bio_vec *to, from;
+	struct bvec_iter iter;
 	unsigned i;
 
 	if (force)
 		goto bounce;
-	bio_for_each_segment(from, *bio_orig, i)
-		if (page_to_pfn(from->bv_page) > queue_bounce_pfn(q))
+	bio_for_each_segment(from, *bio_orig, iter)
+		if (page_to_pfn(from.bv_page) > queue_bounce_pfn(q))
 			goto bounce;
 
 	return;
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
