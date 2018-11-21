Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F06196B23BA
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:29:29 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k203so5536876qke.2
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:29:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s91si726982qtd.154.2018.11.20.19.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 19:29:28 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V11 19/19] block: kill BLK_MQ_F_SG_MERGE
Date: Wed, 21 Nov 2018 11:23:27 +0800
Message-Id: <20181121032327.8434-20-ming.lei@redhat.com>
In-Reply-To: <20181121032327.8434-1-ming.lei@redhat.com>
References: <20181121032327.8434-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

QUEUE_FLAG_NO_SG_MERGE has been killed, so kill BLK_MQ_F_SG_MERGE too.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-mq-debugfs.c       | 1 -
 drivers/block/loop.c         | 2 +-
 drivers/block/nbd.c          | 2 +-
 drivers/block/rbd.c          | 2 +-
 drivers/block/skd_main.c     | 1 -
 drivers/block/xen-blkfront.c | 2 +-
 drivers/md/dm-rq.c           | 2 +-
 drivers/mmc/core/queue.c     | 3 +--
 drivers/scsi/scsi_lib.c      | 2 +-
 include/linux/blk-mq.h       | 1 -
 10 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/block/blk-mq-debugfs.c b/block/blk-mq-debugfs.c
index d752fe4461af..a6ec055b54fa 100644
--- a/block/blk-mq-debugfs.c
+++ b/block/blk-mq-debugfs.c
@@ -249,7 +249,6 @@ static const char *const alloc_policy_name[] = {
 static const char *const hctx_flag_name[] = {
 	HCTX_FLAG_NAME(SHOULD_MERGE),
 	HCTX_FLAG_NAME(TAG_SHARED),
-	HCTX_FLAG_NAME(SG_MERGE),
 	HCTX_FLAG_NAME(BLOCKING),
 	HCTX_FLAG_NAME(NO_SCHED),
 };
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index e3683211f12d..4cf5486689de 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1906,7 +1906,7 @@ static int loop_add(struct loop_device **l, int i)
 	lo->tag_set.queue_depth = 128;
 	lo->tag_set.numa_node = NUMA_NO_NODE;
 	lo->tag_set.cmd_size = sizeof(struct loop_cmd);
-	lo->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE;
+	lo->tag_set.flags = BLK_MQ_F_SHOULD_MERGE;
 	lo->tag_set.driver_data = lo;
 
 	err = blk_mq_alloc_tag_set(&lo->tag_set);
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 08696f5f00bb..999c94de78e5 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -1570,7 +1570,7 @@ static int nbd_dev_add(int index)
 	nbd->tag_set.numa_node = NUMA_NO_NODE;
 	nbd->tag_set.cmd_size = sizeof(struct nbd_cmd);
 	nbd->tag_set.flags = BLK_MQ_F_SHOULD_MERGE |
-		BLK_MQ_F_SG_MERGE | BLK_MQ_F_BLOCKING;
+		BLK_MQ_F_BLOCKING;
 	nbd->tag_set.driver_data = nbd;
 
 	err = blk_mq_alloc_tag_set(&nbd->tag_set);
diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index 8e5140bbf241..3dfd300b5283 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -3988,7 +3988,7 @@ static int rbd_init_disk(struct rbd_device *rbd_dev)
 	rbd_dev->tag_set.ops = &rbd_mq_ops;
 	rbd_dev->tag_set.queue_depth = rbd_dev->opts->queue_depth;
 	rbd_dev->tag_set.numa_node = NUMA_NO_NODE;
-	rbd_dev->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE;
+	rbd_dev->tag_set.flags = BLK_MQ_F_SHOULD_MERGE;
 	rbd_dev->tag_set.nr_hw_queues = 1;
 	rbd_dev->tag_set.cmd_size = sizeof(struct work_struct);
 
diff --git a/drivers/block/skd_main.c b/drivers/block/skd_main.c
index a10d5736d8f7..a7040f9a1b1b 100644
--- a/drivers/block/skd_main.c
+++ b/drivers/block/skd_main.c
@@ -2843,7 +2843,6 @@ static int skd_cons_disk(struct skd_device *skdev)
 		skdev->sgs_per_request * sizeof(struct scatterlist);
 	skdev->tag_set.numa_node = NUMA_NO_NODE;
 	skdev->tag_set.flags = BLK_MQ_F_SHOULD_MERGE |
-		BLK_MQ_F_SG_MERGE |
 		BLK_ALLOC_POLICY_TO_MQ_FLAG(BLK_TAG_ALLOC_FIFO);
 	skdev->tag_set.driver_data = skdev;
 	rc = blk_mq_alloc_tag_set(&skdev->tag_set);
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index 0ed4b200fa58..d43a5677ccbc 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -977,7 +977,7 @@ static int xlvbd_init_blk_queue(struct gendisk *gd, u16 sector_size,
 	} else
 		info->tag_set.queue_depth = BLK_RING_SIZE(info);
 	info->tag_set.numa_node = NUMA_NO_NODE;
-	info->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE;
+	info->tag_set.flags = BLK_MQ_F_SHOULD_MERGE;
 	info->tag_set.cmd_size = sizeof(struct blkif_req);
 	info->tag_set.driver_data = info;
 
diff --git a/drivers/md/dm-rq.c b/drivers/md/dm-rq.c
index 1f1fe9a618ea..afbac62a02a2 100644
--- a/drivers/md/dm-rq.c
+++ b/drivers/md/dm-rq.c
@@ -536,7 +536,7 @@ int dm_mq_init_request_queue(struct mapped_device *md, struct dm_table *t)
 	md->tag_set->ops = &dm_mq_ops;
 	md->tag_set->queue_depth = dm_get_blk_mq_queue_depth();
 	md->tag_set->numa_node = md->numa_node_id;
-	md->tag_set->flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE;
+	md->tag_set->flags = BLK_MQ_F_SHOULD_MERGE;
 	md->tag_set->nr_hw_queues = dm_get_blk_mq_nr_hw_queues();
 	md->tag_set->driver_data = md;
 
diff --git a/drivers/mmc/core/queue.c b/drivers/mmc/core/queue.c
index 35cc138b096d..cc19e71c71d4 100644
--- a/drivers/mmc/core/queue.c
+++ b/drivers/mmc/core/queue.c
@@ -410,8 +410,7 @@ int mmc_init_queue(struct mmc_queue *mq, struct mmc_card *card)
 	else
 		mq->tag_set.queue_depth = MMC_QUEUE_DEPTH;
 	mq->tag_set.numa_node = NUMA_NO_NODE;
-	mq->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE |
-			    BLK_MQ_F_BLOCKING;
+	mq->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_BLOCKING;
 	mq->tag_set.nr_hw_queues = 1;
 	mq->tag_set.cmd_size = sizeof(struct mmc_queue_req);
 	mq->tag_set.driver_data = mq;
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 0df15cb738d2..4091a67d23e5 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -1890,7 +1890,7 @@ int scsi_mq_setup_tags(struct Scsi_Host *shost)
 	shost->tag_set.queue_depth = shost->can_queue;
 	shost->tag_set.cmd_size = cmd_size;
 	shost->tag_set.numa_node = NUMA_NO_NODE;
-	shost->tag_set.flags = BLK_MQ_F_SHOULD_MERGE | BLK_MQ_F_SG_MERGE;
+	shost->tag_set.flags = BLK_MQ_F_SHOULD_MERGE;
 	shost->tag_set.flags |=
 		BLK_ALLOC_POLICY_TO_MQ_FLAG(shost->hostt->tag_alloc_policy);
 	shost->tag_set.driver_data = shost;
diff --git a/include/linux/blk-mq.h b/include/linux/blk-mq.h
index 929e8abc5535..ca7389d7e04f 100644
--- a/include/linux/blk-mq.h
+++ b/include/linux/blk-mq.h
@@ -211,7 +211,6 @@ struct blk_mq_ops {
 enum {
 	BLK_MQ_F_SHOULD_MERGE	= 1 << 0,
 	BLK_MQ_F_TAG_SHARED	= 1 << 1,
-	BLK_MQ_F_SG_MERGE	= 1 << 2,
 	BLK_MQ_F_BLOCKING	= 1 << 5,
 	BLK_MQ_F_NO_SCHED	= 1 << 6,
 	BLK_MQ_F_ALLOC_POLICY_START_BIT = 8,
-- 
2.9.5
