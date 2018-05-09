Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3D86B038C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f19-v6so19408578pgv.4
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id m8-v6si24931924plt.29.2018.05.09.00.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:33 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/6] block: sanitize blk_get_request calling conventions
Date: Wed,  9 May 2018 09:54:05 +0200
Message-Id: <20180509075408.16388-4-hch@lst.de>
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Switch everyone to blk_get_request_flags, and then rename
blk_get_request_flags to blk_get_request.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Hannes Reinecke <hare@suse.com>
---
 block/blk-core.c                   | 14 +++-----------
 block/bsg.c                        |  5 ++---
 block/scsi_ioctl.c                 |  8 +++-----
 drivers/block/paride/pd.c          |  2 +-
 drivers/block/pktcdvd.c            |  2 +-
 drivers/block/sx8.c                |  2 +-
 drivers/block/virtio_blk.c         |  2 +-
 drivers/cdrom/cdrom.c              |  2 +-
 drivers/ide/ide-atapi.c            |  2 +-
 drivers/ide/ide-cd.c               |  2 +-
 drivers/ide/ide-cd_ioctl.c         |  2 +-
 drivers/ide/ide-devsets.c          |  2 +-
 drivers/ide/ide-disk.c             |  2 +-
 drivers/ide/ide-ioctls.c           |  4 ++--
 drivers/ide/ide-park.c             |  4 ++--
 drivers/ide/ide-pm.c               |  5 ++---
 drivers/ide/ide-tape.c             |  2 +-
 drivers/ide/ide-taskfile.c         |  2 +-
 drivers/md/dm-mpath.c              |  3 ++-
 drivers/mmc/core/block.c           | 12 +++++-------
 drivers/scsi/osd/osd_initiator.c   |  2 +-
 drivers/scsi/osst.c                |  2 +-
 drivers/scsi/scsi_error.c          |  2 +-
 drivers/scsi/scsi_lib.c            |  2 +-
 drivers/scsi/sg.c                  |  2 +-
 drivers/scsi/st.c                  |  2 +-
 drivers/target/target_core_pscsi.c |  3 +--
 fs/nfsd/blocklayout.c              |  2 +-
 include/linux/blkdev.h             |  5 +----
 29 files changed, 42 insertions(+), 59 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 52f2d4623ec7..5013027eae70 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1606,13 +1606,13 @@ static struct request *blk_old_get_request(struct request_queue *q,
 }
 
 /**
- * blk_get_request_flags - allocate a request
+ * blk_get_request - allocate a request
  * @q: request queue to allocate a request for
  * @op: operation (REQ_OP_*) and REQ_* flags, e.g. REQ_SYNC.
  * @flags: BLK_MQ_REQ_* flags, e.g. BLK_MQ_REQ_NOWAIT.
  */
-struct request *blk_get_request_flags(struct request_queue *q, unsigned int op,
-				      blk_mq_req_flags_t flags)
+struct request *blk_get_request(struct request_queue *q, unsigned int op,
+				blk_mq_req_flags_t flags)
 {
 	struct request *req;
 
@@ -1631,14 +1631,6 @@ struct request *blk_get_request_flags(struct request_queue *q, unsigned int op,
 
 	return req;
 }
-EXPORT_SYMBOL(blk_get_request_flags);
-
-struct request *blk_get_request(struct request_queue *q, unsigned int op,
-				gfp_t gfp_mask)
-{
-	return blk_get_request_flags(q, op, gfp_mask & __GFP_DIRECT_RECLAIM ?
-				     0 : BLK_MQ_REQ_NOWAIT);
-}
 EXPORT_SYMBOL(blk_get_request);
 
 /**
diff --git a/block/bsg.c b/block/bsg.c
index defa06c11858..30876c5fbf15 100644
--- a/block/bsg.c
+++ b/block/bsg.c
@@ -226,8 +226,7 @@ bsg_map_hdr(struct request_queue *q, struct sg_io_v4 *hdr, fmode_t mode)
 		return ERR_PTR(ret);
 
 	rq = blk_get_request(q, hdr->dout_xfer_len ?
-			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			GFP_KERNEL);
+			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq))
 		return rq;
 
@@ -249,7 +248,7 @@ bsg_map_hdr(struct request_queue *q, struct sg_io_v4 *hdr, fmode_t mode)
 			goto out;
 		}
 
-		next_rq = blk_get_request(q, REQ_OP_SCSI_IN, GFP_KERNEL);
+		next_rq = blk_get_request(q, REQ_OP_SCSI_IN, 0);
 		if (IS_ERR(next_rq)) {
 			ret = PTR_ERR(next_rq);
 			goto out;
diff --git a/block/scsi_ioctl.c b/block/scsi_ioctl.c
index 60b471f8621b..04b54f9a4152 100644
--- a/block/scsi_ioctl.c
+++ b/block/scsi_ioctl.c
@@ -321,8 +321,7 @@ static int sg_io(struct request_queue *q, struct gendisk *bd_disk,
 		at_head = 1;
 
 	ret = -ENOMEM;
-	rq = blk_get_request(q, writing ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			GFP_KERNEL);
+	rq = blk_get_request(q, writing ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 	req = scsi_req(rq);
@@ -449,8 +448,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
 
 	}
 
-	rq = blk_get_request(q, in_len ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			__GFP_RECLAIM);
+	rq = blk_get_request(q, in_len ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq)) {
 		err = PTR_ERR(rq);
 		goto error_free_buffer;
@@ -538,7 +536,7 @@ static int __blk_send_generic(struct request_queue *q, struct gendisk *bd_disk,
 	struct request *rq;
 	int err;
 
-	rq = blk_get_request(q, REQ_OP_SCSI_OUT, __GFP_RECLAIM);
+	rq = blk_get_request(q, REQ_OP_SCSI_OUT, 0);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 	rq->timeout = BLK_DEFAULT_SG_TIMEOUT;
diff --git a/drivers/block/paride/pd.c b/drivers/block/paride/pd.c
index 27a44b97393a..8961b190e256 100644
--- a/drivers/block/paride/pd.c
+++ b/drivers/block/paride/pd.c
@@ -740,7 +740,7 @@ static int pd_special_command(struct pd_unit *disk,
 {
 	struct request *rq;
 
-	rq = blk_get_request(disk->gd->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(disk->gd->queue, REQ_OP_DRV_IN, 0);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index c61d20c9f3f8..4880a4a9f52d 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -704,7 +704,7 @@ static int pkt_generic_packet(struct pktcdvd_device *pd, struct packet_command *
 	int ret = 0;
 
 	rq = blk_get_request(q, (cgc->data_direction == CGC_DATA_WRITE) ?
-			     REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, __GFP_RECLAIM);
+			     REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 
diff --git a/drivers/block/sx8.c b/drivers/block/sx8.c
index 08586dc14e85..4d90e5eba2f5 100644
--- a/drivers/block/sx8.c
+++ b/drivers/block/sx8.c
@@ -567,7 +567,7 @@ static struct carm_request *carm_get_special(struct carm_host *host)
 	if (!crq)
 		return NULL;
 
-	rq = blk_get_request(host->oob_q, REQ_OP_DRV_OUT, GFP_KERNEL);
+	rq = blk_get_request(host->oob_q, REQ_OP_DRV_OUT, 0);
 	if (IS_ERR(rq)) {
 		spin_lock_irqsave(&host->lock, flags);
 		carm_put_request(host, crq);
diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 4a07593c2efd..0617b9922d59 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -298,7 +298,7 @@ static int virtblk_get_id(struct gendisk *disk, char *id_str)
 	struct request *req;
 	int err;
 
-	req = blk_get_request(q, REQ_OP_DRV_IN, GFP_KERNEL);
+	req = blk_get_request(q, REQ_OP_DRV_IN, 0);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
diff --git a/drivers/cdrom/cdrom.c b/drivers/cdrom/cdrom.c
index bfc566d3f31a..9adc8c3eb0fa 100644
--- a/drivers/cdrom/cdrom.c
+++ b/drivers/cdrom/cdrom.c
@@ -2192,7 +2192,7 @@ static int cdrom_read_cdda_bpc(struct cdrom_device_info *cdi, __u8 __user *ubuf,
 
 		len = nr * CD_FRAMESIZE_RAW;
 
-		rq = blk_get_request(q, REQ_OP_SCSI_IN, GFP_KERNEL);
+		rq = blk_get_request(q, REQ_OP_SCSI_IN, 0);
 		if (IS_ERR(rq)) {
 			ret = PTR_ERR(rq);
 			break;
diff --git a/drivers/ide/ide-atapi.c b/drivers/ide/ide-atapi.c
index 0e6bc631a1ca..8b2b72b93885 100644
--- a/drivers/ide/ide-atapi.c
+++ b/drivers/ide/ide-atapi.c
@@ -92,7 +92,7 @@ int ide_queue_pc_tail(ide_drive_t *drive, struct gendisk *disk,
 	struct request *rq;
 	int error;
 
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_MISC;
 	rq->special = (char *)pc;
 
diff --git a/drivers/ide/ide-cd.c b/drivers/ide/ide-cd.c
index 5a8e8e3c22cd..32af6f063cb3 100644
--- a/drivers/ide/ide-cd.c
+++ b/drivers/ide/ide-cd.c
@@ -437,7 +437,7 @@ int ide_cd_queue_pc(ide_drive_t *drive, const unsigned char *cmd,
 		bool delay = false;
 
 		rq = blk_get_request(drive->queue,
-			write ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN,  __GFP_RECLAIM);
+			write ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN, 0);
 		memcpy(scsi_req(rq)->cmd, cmd, BLK_MAX_CDB);
 		ide_req(rq)->type = ATA_PRIV_PC;
 		rq->rq_flags |= rq_flags;
diff --git a/drivers/ide/ide-cd_ioctl.c b/drivers/ide/ide-cd_ioctl.c
index 2acca12b9c94..b1322400887b 100644
--- a/drivers/ide/ide-cd_ioctl.c
+++ b/drivers/ide/ide-cd_ioctl.c
@@ -304,7 +304,7 @@ int ide_cdrom_reset(struct cdrom_device_info *cdi)
 	struct request *rq;
 	int ret;
 
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_MISC;
 	rq->rq_flags = RQF_QUIET;
 	blk_execute_rq(drive->queue, cd->disk, rq, 0);
diff --git a/drivers/ide/ide-devsets.c b/drivers/ide/ide-devsets.c
index 4e20747af32e..f4f8afdf8bbe 100644
--- a/drivers/ide/ide-devsets.c
+++ b/drivers/ide/ide-devsets.c
@@ -166,7 +166,7 @@ int ide_devset_execute(ide_drive_t *drive, const struct ide_devset *setting,
 	if (!(setting->flags & DS_SYNC))
 		return setting->set(drive, arg);
 
-	rq = blk_get_request(q, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(q, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_MISC;
 	scsi_req(rq)->cmd_len = 5;
 	scsi_req(rq)->cmd[0] = REQ_DEVSET_EXEC;
diff --git a/drivers/ide/ide-disk.c b/drivers/ide/ide-disk.c
index f1a7c58fe418..e3b4e659082d 100644
--- a/drivers/ide/ide-disk.c
+++ b/drivers/ide/ide-disk.c
@@ -478,7 +478,7 @@ static int set_multcount(ide_drive_t *drive, int arg)
 	if (drive->special_flags & IDE_SFLAG_SET_MULTMODE)
 		return -EBUSY;
 
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_TASKFILE;
 
 	drive->mult_req = arg;
diff --git a/drivers/ide/ide-ioctls.c b/drivers/ide/ide-ioctls.c
index 3661abb16a5f..af5119a73689 100644
--- a/drivers/ide/ide-ioctls.c
+++ b/drivers/ide/ide-ioctls.c
@@ -125,7 +125,7 @@ static int ide_cmd_ioctl(ide_drive_t *drive, unsigned long arg)
 	if (NULL == (void *) arg) {
 		struct request *rq;
 
-		rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+		rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 		ide_req(rq)->type = ATA_PRIV_TASKFILE;
 		blk_execute_rq(drive->queue, NULL, rq, 0);
 		err = scsi_req(rq)->result ? -EIO : 0;
@@ -222,7 +222,7 @@ static int generic_drive_reset(ide_drive_t *drive)
 	struct request *rq;
 	int ret = 0;
 
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_MISC;
 	scsi_req(rq)->cmd_len = 1;
 	scsi_req(rq)->cmd[0] = REQ_DRIVE_RESET;
diff --git a/drivers/ide/ide-park.c b/drivers/ide/ide-park.c
index 6465bcc7cea6..622f0edb3945 100644
--- a/drivers/ide/ide-park.c
+++ b/drivers/ide/ide-park.c
@@ -32,7 +32,7 @@ static void issue_park_cmd(ide_drive_t *drive, unsigned long timeout)
 	}
 	spin_unlock_irq(&hwif->lock);
 
-	rq = blk_get_request(q, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(q, REQ_OP_DRV_IN, 0);
 	scsi_req(rq)->cmd[0] = REQ_PARK_HEADS;
 	scsi_req(rq)->cmd_len = 1;
 	ide_req(rq)->type = ATA_PRIV_MISC;
@@ -47,7 +47,7 @@ static void issue_park_cmd(ide_drive_t *drive, unsigned long timeout)
 	 * Make sure that *some* command is sent to the drive after the
 	 * timeout has expired, so power management will be reenabled.
 	 */
-	rq = blk_get_request(q, REQ_OP_DRV_IN, GFP_NOWAIT);
+	rq = blk_get_request(q, REQ_OP_DRV_IN, BLK_MQ_REQ_NOWAIT);
 	if (IS_ERR(rq))
 		goto out;
 
diff --git a/drivers/ide/ide-pm.c b/drivers/ide/ide-pm.c
index ad8a125defdd..59217aa1d1fb 100644
--- a/drivers/ide/ide-pm.c
+++ b/drivers/ide/ide-pm.c
@@ -19,7 +19,7 @@ int generic_ide_suspend(struct device *dev, pm_message_t mesg)
 	}
 
 	memset(&rqpm, 0, sizeof(rqpm));
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_PM_SUSPEND;
 	rq->special = &rqpm;
 	rqpm.pm_step = IDE_PM_START_SUSPEND;
@@ -90,8 +90,7 @@ int generic_ide_resume(struct device *dev)
 	}
 
 	memset(&rqpm, 0, sizeof(rqpm));
-	rq = blk_get_request_flags(drive->queue, REQ_OP_DRV_IN,
-				   BLK_MQ_REQ_PREEMPT);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, BLK_MQ_REQ_PREEMPT);
 	ide_req(rq)->type = ATA_PRIV_PM_RESUME;
 	rq->special = &rqpm;
 	rqpm.pm_step = IDE_PM_START_RESUME;
diff --git a/drivers/ide/ide-tape.c b/drivers/ide/ide-tape.c
index fd57e8ccc47a..66661031f3f1 100644
--- a/drivers/ide/ide-tape.c
+++ b/drivers/ide/ide-tape.c
@@ -854,7 +854,7 @@ static int idetape_queue_rw_tail(ide_drive_t *drive, int cmd, int size)
 	BUG_ON(cmd != REQ_IDETAPE_READ && cmd != REQ_IDETAPE_WRITE);
 	BUG_ON(size < 0 || size % tape->blk_size);
 
-	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	rq = blk_get_request(drive->queue, REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_MISC;
 	scsi_req(rq)->cmd[13] = cmd;
 	rq->rq_disk = tape->disk;
diff --git a/drivers/ide/ide-taskfile.c b/drivers/ide/ide-taskfile.c
index abe0822dd429..6308bb0dab50 100644
--- a/drivers/ide/ide-taskfile.c
+++ b/drivers/ide/ide-taskfile.c
@@ -431,7 +431,7 @@ int ide_raw_taskfile(ide_drive_t *drive, struct ide_cmd *cmd, u8 *buf,
 
 	rq = blk_get_request(drive->queue,
 		(cmd->tf_flags & IDE_TFLAG_WRITE) ?
-			REQ_OP_DRV_OUT : REQ_OP_DRV_IN, __GFP_RECLAIM);
+			REQ_OP_DRV_OUT : REQ_OP_DRV_IN, 0);
 	ide_req(rq)->type = ATA_PRIV_TASKFILE;
 
 	/*
diff --git a/drivers/md/dm-mpath.c b/drivers/md/dm-mpath.c
index 203a0419d2b0..d94ba6f72ff5 100644
--- a/drivers/md/dm-mpath.c
+++ b/drivers/md/dm-mpath.c
@@ -520,7 +520,8 @@ static int multipath_clone_and_map(struct dm_target *ti, struct request *rq,
 
 	bdev = pgpath->path.dev->bdev;
 	q = bdev_get_queue(bdev);
-	clone = blk_get_request(q, rq->cmd_flags | REQ_NOMERGE, GFP_ATOMIC);
+	clone = blk_get_request(q, rq->cmd_flags | REQ_NOMERGE,
+			BLK_MQ_REQ_NOWAIT);
 	if (IS_ERR(clone)) {
 		/* EBUSY, ENODEV or EWOULDBLOCK: requeue */
 		if (blk_queue_dying(q)) {
diff --git a/drivers/mmc/core/block.c b/drivers/mmc/core/block.c
index 9e923cd1d80e..6e3bde824db8 100644
--- a/drivers/mmc/core/block.c
+++ b/drivers/mmc/core/block.c
@@ -244,7 +244,7 @@ static ssize_t power_ro_lock_store(struct device *dev,
 	mq = &md->queue;
 
 	/* Dispatch locking to the block layer */
-	req = blk_get_request(mq->queue, REQ_OP_DRV_OUT, __GFP_RECLAIM);
+	req = blk_get_request(mq->queue, REQ_OP_DRV_OUT, 0);
 	if (IS_ERR(req)) {
 		count = PTR_ERR(req);
 		goto out_put;
@@ -650,8 +650,7 @@ static int mmc_blk_ioctl_cmd(struct mmc_blk_data *md,
 	 */
 	mq = &md->queue;
 	req = blk_get_request(mq->queue,
-		idata->ic.write_flag ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN,
-		__GFP_RECLAIM);
+		idata->ic.write_flag ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN, 0);
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto cmd_done;
@@ -721,8 +720,7 @@ static int mmc_blk_ioctl_multi_cmd(struct mmc_blk_data *md,
 	 */
 	mq = &md->queue;
 	req = blk_get_request(mq->queue,
-		idata[0]->ic.write_flag ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN,
-		__GFP_RECLAIM);
+		idata[0]->ic.write_flag ? REQ_OP_DRV_OUT : REQ_OP_DRV_IN, 0);
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto cmd_err;
@@ -2750,7 +2748,7 @@ static int mmc_dbg_card_status_get(void *data, u64 *val)
 	int ret;
 
 	/* Ask the block layer about the card status */
-	req = blk_get_request(mq->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	req = blk_get_request(mq->queue, REQ_OP_DRV_IN, 0);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	req_to_mmc_queue_req(req)->drv_op = MMC_DRV_OP_GET_CARD_STATUS;
@@ -2786,7 +2784,7 @@ static int mmc_ext_csd_open(struct inode *inode, struct file *filp)
 		return -ENOMEM;
 
 	/* Ask the block layer for the EXT CSD */
-	req = blk_get_request(mq->queue, REQ_OP_DRV_IN, __GFP_RECLAIM);
+	req = blk_get_request(mq->queue, REQ_OP_DRV_IN, 0);
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto out_free;
diff --git a/drivers/scsi/osd/osd_initiator.c b/drivers/scsi/osd/osd_initiator.c
index f48bae267dc2..5a33e1ad9881 100644
--- a/drivers/scsi/osd/osd_initiator.c
+++ b/drivers/scsi/osd/osd_initiator.c
@@ -1570,7 +1570,7 @@ static struct request *_make_request(struct request_queue *q, bool has_write,
 	int ret;
 
 	req = blk_get_request(q, has_write ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			GFP_KERNEL);
+			0);
 	if (IS_ERR(req))
 		return req;
 
diff --git a/drivers/scsi/osst.c b/drivers/scsi/osst.c
index 20ec1c01dbd5..2bbe797f8c3d 100644
--- a/drivers/scsi/osst.c
+++ b/drivers/scsi/osst.c
@@ -368,7 +368,7 @@ static int osst_execute(struct osst_request *SRpnt, const unsigned char *cmd,
 	int write = (data_direction == DMA_TO_DEVICE);
 
 	req = blk_get_request(SRpnt->stp->device->request_queue,
-			write ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, GFP_KERNEL);
+			write ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(req))
 		return DRIVER_ERROR << 24;
 
diff --git a/drivers/scsi/scsi_error.c b/drivers/scsi/scsi_error.c
index 946039117bf4..61d280f560df 100644
--- a/drivers/scsi/scsi_error.c
+++ b/drivers/scsi/scsi_error.c
@@ -1937,7 +1937,7 @@ static void scsi_eh_lock_door(struct scsi_device *sdev)
 	 * blk_get_request with GFP_KERNEL (__GFP_RECLAIM) sleeps until a
 	 * request becomes available
 	 */
-	req = blk_get_request(sdev->request_queue, REQ_OP_SCSI_IN, GFP_KERNEL);
+	req = blk_get_request(sdev->request_queue, REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(req))
 		return;
 	rq = scsi_req(req);
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index e9b4f279d29c..6b0f3ec487bd 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -265,7 +265,7 @@ int scsi_execute(struct scsi_device *sdev, const unsigned char *cmd,
 	struct scsi_request *rq;
 	int ret = DRIVER_ERROR << 24;
 
-	req = blk_get_request_flags(sdev->request_queue,
+	req = blk_get_request(sdev->request_queue,
 			data_direction == DMA_TO_DEVICE ?
 			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, BLK_MQ_REQ_PREEMPT);
 	if (IS_ERR(req))
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index c198b96368dd..0512648ebc8e 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1715,7 +1715,7 @@ sg_start_req(Sg_request *srp, unsigned char *cmd)
 	 * does not sleep except under memory pressure.
 	 */
 	rq = blk_get_request(q, hp->dxfer_direction == SG_DXFER_TO_DEV ?
-			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, GFP_KERNEL);
+			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq)) {
 		kfree(long_cmdp);
 		return PTR_ERR(rq);
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 6c399480783d..a427ce9497be 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -545,7 +545,7 @@ static int st_scsi_execute(struct st_request *SRpnt, const unsigned char *cmd,
 
 	req = blk_get_request(SRpnt->stp->device->request_queue,
 			data_direction == DMA_TO_DEVICE ?
-			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, GFP_KERNEL);
+			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(req))
 		return DRIVER_ERROR << 24;
 	rq = scsi_req(req);
diff --git a/drivers/target/target_core_pscsi.c b/drivers/target/target_core_pscsi.c
index 6cb933ecc084..668934ea74cb 100644
--- a/drivers/target/target_core_pscsi.c
+++ b/drivers/target/target_core_pscsi.c
@@ -986,8 +986,7 @@ pscsi_execute_cmd(struct se_cmd *cmd)
 
 	req = blk_get_request(pdv->pdv_sd->request_queue,
 			cmd->data_direction == DMA_TO_DEVICE ?
-			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			GFP_KERNEL);
+			REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(req)) {
 		pr_err("PSCSI: blk_get_request() failed\n");
 		ret = TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 70b8bf781fce..a43dfedd69ec 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -227,7 +227,7 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
 	if (!buf)
 		return -ENOMEM;
 
-	rq = blk_get_request(q, REQ_OP_SCSI_IN, GFP_KERNEL);
+	rq = blk_get_request(q, REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(rq)) {
 		error = -ENOMEM;
 		goto out_free_buf;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 5c4eee043191..ffc81538a9cf 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -967,11 +967,8 @@ extern void blk_rq_init(struct request_queue *q, struct request *rq);
 extern void blk_init_request_from_bio(struct request *req, struct bio *bio);
 extern void blk_put_request(struct request *);
 extern void __blk_put_request(struct request_queue *, struct request *);
-extern struct request *blk_get_request_flags(struct request_queue *,
-					     unsigned int op,
-					     blk_mq_req_flags_t flags);
 extern struct request *blk_get_request(struct request_queue *, unsigned int op,
-				       gfp_t gfp_mask);
+				       blk_mq_req_flags_t flags);
 extern void blk_requeue_request(struct request_queue *, struct request *);
 extern int blk_lld_busy(struct request_queue *q);
 extern int blk_rq_prep_clone(struct request *rq, struct request *rq_src,
-- 
2.17.0
