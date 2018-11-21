Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA1A6B23B0
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:28:18 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q3so2203683qtq.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:28:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d42si5034877qve.68.2018.11.20.19.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 19:28:16 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V11 14/19] block: handle non-cluster bio out of blk_bio_segment_split
Date: Wed, 21 Nov 2018 11:23:22 +0800
Message-Id: <20181121032327.8434-15-ming.lei@redhat.com>
In-Reply-To: <20181121032327.8434-1-ming.lei@redhat.com>
References: <20181121032327.8434-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

We will enable multi-page bvec soon, but non-cluster queue can't
handle the multi-page bvec at all. This patch borrows bounce's
idea to clone new single-page bio for non-cluster queue, and moves
its handling out of blk_bio_segment_split().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/Makefile      |  3 ++-
 block/blk-merge.c   |  6 ++++-
 block/blk.h         |  2 ++
 block/non-cluster.c | 70 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 79 insertions(+), 2 deletions(-)
 create mode 100644 block/non-cluster.c

diff --git a/block/Makefile b/block/Makefile
index eee1b4ceecf9..e07d59438c4b 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -9,7 +9,8 @@ obj-$(CONFIG_BLOCK) := bio.o elevator.o blk-core.o blk-sysfs.o \
 			blk-lib.o blk-mq.o blk-mq-tag.o blk-stat.o \
 			blk-mq-sysfs.o blk-mq-cpumap.o blk-mq-sched.o ioctl.o \
 			genhd.o partition-generic.o ioprio.o \
-			badblocks.o partitions/ blk-rq-qos.o
+			badblocks.o partitions/ blk-rq-qos.o \
+			non-cluster.o
 
 obj-$(CONFIG_BOUNCE)		+= bounce.o
 obj-$(CONFIG_BLK_SCSI_REQUEST)	+= scsi_ioctl.o
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 8829c51b4e75..7c44216c1b58 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -247,7 +247,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			goto split;
 		}
 
-		if (bvprvp && blk_queue_cluster(q)) {
+		if (bvprvp) {
 			if (seg_size + bv.bv_len > queue_max_segment_size(q))
 				goto new_segment;
 			if (!biovec_phys_mergeable(q, bvprvp, &bv))
@@ -307,6 +307,10 @@ void blk_queue_split(struct request_queue *q, struct bio **bio)
 		split = blk_bio_write_same_split(q, *bio, &q->bio_split, &nsegs);
 		break;
 	default:
+		if (!blk_queue_cluster(q)) {
+			blk_queue_non_cluster_bio(q, bio);
+			return;
+		}
 		split = blk_bio_segment_split(q, *bio, &q->bio_split, &nsegs);
 		break;
 	}
diff --git a/block/blk.h b/block/blk.h
index 31c0e45aba3a..6fc5821ced55 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -338,6 +338,8 @@ struct bio *blk_next_bio(struct bio *bio, unsigned int nr_pages, gfp_t gfp);
 
 struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask, struct bio_set *bs);
 
+void blk_queue_non_cluster_bio(struct request_queue *q, struct bio **bio_orig);
+
 #ifdef CONFIG_BLK_DEV_ZONED
 void blk_queue_free_zone_bitmaps(struct request_queue *q);
 #else
diff --git a/block/non-cluster.c b/block/non-cluster.c
new file mode 100644
index 000000000000..9c2910be9404
--- /dev/null
+++ b/block/non-cluster.c
@@ -0,0 +1,70 @@
+// SPDX-License-Identifier: GPL-2.0
+/* non-cluster handling for block devices */
+
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/swap.h>
+#include <linux/gfp.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/backing-dev.h>
+#include <linux/init.h>
+#include <linux/printk.h>
+
+#include "blk.h"
+
+static struct bio_set non_cluster_bio_set, non_cluster_bio_split;
+
+static __init int init_non_cluster_bioset(void)
+{
+	WARN_ON(bioset_init(&non_cluster_bio_set, BIO_POOL_SIZE, 0,
+			   BIOSET_NEED_BVECS));
+	WARN_ON(bioset_integrity_create(&non_cluster_bio_set, BIO_POOL_SIZE));
+	WARN_ON(bioset_init(&non_cluster_bio_split, BIO_POOL_SIZE, 0, 0));
+
+	return 0;
+}
+__initcall(init_non_cluster_bioset);
+
+static void non_cluster_end_io(struct bio *bio)
+{
+	struct bio *bio_orig = bio->bi_private;
+
+	bio_orig->bi_status = bio->bi_status;
+	bio_endio(bio_orig);
+	bio_put(bio);
+}
+
+void blk_queue_non_cluster_bio(struct request_queue *q, struct bio **bio_orig)
+{
+	struct bio *bio;
+	struct bvec_iter iter;
+	struct bio_vec from;
+	unsigned i = 0;
+	unsigned sectors = 0;
+	unsigned short max_segs = min_t(unsigned short, BIO_MAX_PAGES,
+					queue_max_segments(q));
+
+	bio_for_each_segment(from, *bio_orig, iter) {
+		if (i++ < max_segs)
+			sectors += from.bv_len >> 9;
+		else
+			break;
+	}
+
+	if (sectors < bio_sectors(*bio_orig)) {
+		bio = bio_split(*bio_orig, sectors, GFP_NOIO,
+				&non_cluster_bio_split);
+		bio_chain(bio, *bio_orig);
+		generic_make_request(*bio_orig);
+		*bio_orig = bio;
+	}
+	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, &non_cluster_bio_set);
+
+	bio->bi_phys_segments = bio_segments(bio);
+        bio_set_flag(bio, BIO_SEG_VALID);
+	bio->bi_end_io = non_cluster_end_io;
+
+	bio->bi_private = *bio_orig;
+	*bio_orig = bio;
+}
-- 
2.9.5
