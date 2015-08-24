Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7BE6B025A
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:10:09 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so48118043wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:10:09 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id f5si21094498wiz.82.2015.08.24.05.09.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 747AB210017
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:54 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/12] mm, page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
Date: Mon, 24 Aug 2015 13:09:47 +0100
Message-Id: <1440418191-10894-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

__GFP_WAIT was used to signal that the caller was in atomic context and
could not sleep.  Now it is possible to distinguish between true atomic
context and callers that are not willing to sleep. The latter should clear
__GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
behaves differently, there is a risk that people will clear the wrong
flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
what it does -- setting it allows all reclaim activity, clearing them
prevents it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 block/blk-mq.c                               |  2 +-
 block/scsi_ioctl.c                           |  6 +++---
 drivers/block/drbd/drbd_bitmap.c             |  2 +-
 drivers/block/mtip32xx/mtip32xx.c            |  2 +-
 drivers/block/nvme-core.c                    |  4 ++--
 drivers/block/paride/pd.c                    |  2 +-
 drivers/block/pktcdvd.c                      |  4 ++--
 drivers/gpu/drm/i915/i915_gem.c              |  2 +-
 drivers/ide/ide-atapi.c                      |  2 +-
 drivers/ide/ide-cd.c                         |  2 +-
 drivers/ide/ide-cd_ioctl.c                   |  2 +-
 drivers/ide/ide-devsets.c                    |  2 +-
 drivers/ide/ide-disk.c                       |  2 +-
 drivers/ide/ide-ioctls.c                     |  4 ++--
 drivers/ide/ide-park.c                       |  2 +-
 drivers/ide/ide-pm.c                         |  4 ++--
 drivers/ide/ide-tape.c                       |  4 ++--
 drivers/ide/ide-taskfile.c                   |  4 ++--
 drivers/infiniband/hw/ipath/ipath_file_ops.c |  2 +-
 drivers/infiniband/hw/qib/qib_init.c         |  2 +-
 drivers/misc/vmw_balloon.c                   |  2 +-
 drivers/scsi/scsi_error.c                    |  2 +-
 drivers/scsi/scsi_lib.c                      |  4 ++--
 fs/cachefiles/internal.h                     |  2 +-
 fs/direct-io.c                               |  2 +-
 fs/nilfs2/mdt.h                              |  2 +-
 include/linux/gfp.h                          | 16 ++++++++--------
 kernel/power/swap.c                          | 14 +++++++-------
 lib/percpu_ida.c                             |  2 +-
 mm/failslab.c                                |  8 ++++----
 mm/filemap.c                                 |  2 +-
 mm/huge_memory.c                             |  2 +-
 mm/migrate.c                                 |  2 +-
 mm/page_alloc.c                              | 10 +++++-----
 security/integrity/ima/ima_crypto.c          |  2 +-
 35 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/block/blk-mq.c b/block/blk-mq.c
index 7d80379d7a38..16feffc93489 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -1221,7 +1221,7 @@ static struct request *blk_mq_map_request(struct request_queue *q,
 		ctx = blk_mq_get_ctx(q);
 		hctx = q->mq_ops->map_queue(q, ctx->cpu);
 		blk_mq_set_alloc_data(&alloc_data, q,
-				__GFP_WAIT|__GFP_HIGH, false, ctx, hctx);
+				__GFP_RECLAIM|__GFP_HIGH, false, ctx, hctx);
 		rq = __blk_mq_alloc_request(&alloc_data, rw);
 		ctx = alloc_data.ctx;
 		hctx = alloc_data.hctx;
diff --git a/block/scsi_ioctl.c b/block/scsi_ioctl.c
index dda653ce7b24..0774799942e0 100644
--- a/block/scsi_ioctl.c
+++ b/block/scsi_ioctl.c
@@ -444,7 +444,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
 
 	}
 
-	rq = blk_get_request(q, in_len ? WRITE : READ, __GFP_WAIT);
+	rq = blk_get_request(q, in_len ? WRITE : READ, __GFP_RECLAIM);
 	if (IS_ERR(rq)) {
 		err = PTR_ERR(rq);
 		goto error_free_buffer;
@@ -495,7 +495,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
 		break;
 	}
 
-	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, __GFP_WAIT)) {
+	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, __GFP_RECLAIM)) {
 		err = DRIVER_ERROR << 24;
 		goto error;
 	}
@@ -536,7 +536,7 @@ static int __blk_send_generic(struct request_queue *q, struct gendisk *bd_disk,
 	struct request *rq;
 	int err;
 
-	rq = blk_get_request(q, WRITE, __GFP_WAIT);
+	rq = blk_get_request(q, WRITE, __GFP_RECLAIM);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 	blk_rq_set_block_pc(rq);
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 434c77dcc99e..2940da0011e0 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -1016,7 +1016,7 @@ static void bm_page_io_async(struct drbd_bm_aio_ctx *ctx, int page_nr) __must_ho
 	bm_set_page_unchanged(b->bm_pages[page_nr]);
 
 	if (ctx->flags & BM_AIO_COPY_PAGES) {
-		page = mempool_alloc(drbd_md_io_page_pool, __GFP_HIGHMEM|__GFP_WAIT);
+		page = mempool_alloc(drbd_md_io_page_pool, __GFP_HIGHMEM|__GFP_RECLAIM);
 		copy_highpage(page, b->bm_pages[page_nr]);
 		bm_store_page_idx(page, page_nr);
 	} else
diff --git a/drivers/block/mtip32xx/mtip32xx.c b/drivers/block/mtip32xx/mtip32xx.c
index 4a2ef09e6704..a694b23cb8f9 100644
--- a/drivers/block/mtip32xx/mtip32xx.c
+++ b/drivers/block/mtip32xx/mtip32xx.c
@@ -173,7 +173,7 @@ static struct mtip_cmd *mtip_get_int_command(struct driver_data *dd)
 {
 	struct request *rq;
 
-	rq = blk_mq_alloc_request(dd->queue, 0, __GFP_WAIT, true);
+	rq = blk_mq_alloc_request(dd->queue, 0, __GFP_RECLAIM, true);
 	return blk_mq_rq_to_pdu(rq);
 }
 
diff --git a/drivers/block/nvme-core.c b/drivers/block/nvme-core.c
index 7920c2741b47..0a8b1682305f 100644
--- a/drivers/block/nvme-core.c
+++ b/drivers/block/nvme-core.c
@@ -1033,11 +1033,11 @@ int __nvme_submit_sync_cmd(struct request_queue *q, struct nvme_command *cmd,
 	req->special = (void *)0;
 
 	if (buffer && bufflen) {
-		ret = blk_rq_map_kern(q, req, buffer, bufflen, __GFP_WAIT);
+		ret = blk_rq_map_kern(q, req, buffer, bufflen, __GFP_RECLAIM);
 		if (ret)
 			goto out;
 	} else if (ubuffer && bufflen) {
-		ret = blk_rq_map_user(q, req, NULL, ubuffer, bufflen, __GFP_WAIT);
+		ret = blk_rq_map_user(q, req, NULL, ubuffer, bufflen, __GFP_RECLAIM);
 		if (ret)
 			goto out;
 		bio = req->bio;
diff --git a/drivers/block/paride/pd.c b/drivers/block/paride/pd.c
index b9242d78283d..562b5a4ca7b7 100644
--- a/drivers/block/paride/pd.c
+++ b/drivers/block/paride/pd.c
@@ -723,7 +723,7 @@ static int pd_special_command(struct pd_unit *disk,
 	struct request *rq;
 	int err = 0;
 
-	rq = blk_get_request(disk->gd->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(disk->gd->queue, READ, __GFP_RECLAIM);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index 4c20c228184c..e372a5f08847 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -704,14 +704,14 @@ static int pkt_generic_packet(struct pktcdvd_device *pd, struct packet_command *
 	int ret = 0;
 
 	rq = blk_get_request(q, (cgc->data_direction == CGC_DATA_WRITE) ?
-			     WRITE : READ, __GFP_WAIT);
+			     WRITE : READ, __GFP_RECLAIM);
 	if (IS_ERR(rq))
 		return PTR_ERR(rq);
 	blk_rq_set_block_pc(rq);
 
 	if (cgc->buflen) {
 		ret = blk_rq_map_kern(q, rq, cgc->buffer, cgc->buflen,
-				      __GFP_WAIT);
+				      __GFP_RECLAIM);
 		if (ret)
 			goto out;
 	}
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index c2b45081c5ab..2ca8638c5b81 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2226,7 +2226,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	mapping = file_inode(obj->base.filp)->i_mapping;
 	gfp = mapping_gfp_mask(mapping);
 	gfp |= __GFP_NORETRY | __GFP_NOWARN;
-	gfp &= ~(__GFP_IO | __GFP_WAIT);
+	gfp &= ~(__GFP_IO | __GFP_RECLAIM);
 	sg = st->sgl;
 	st->nents = 0;
 	for (i = 0; i < page_count; i++) {
diff --git a/drivers/ide/ide-atapi.c b/drivers/ide/ide-atapi.c
index 1362ad80a76c..05352f490d60 100644
--- a/drivers/ide/ide-atapi.c
+++ b/drivers/ide/ide-atapi.c
@@ -92,7 +92,7 @@ int ide_queue_pc_tail(ide_drive_t *drive, struct gendisk *disk,
 	struct request *rq;
 	int error;
 
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
 	rq->special = (char *)pc;
 
diff --git a/drivers/ide/ide-cd.c b/drivers/ide/ide-cd.c
index 64a6b827b3dd..ef907fd5ba98 100644
--- a/drivers/ide/ide-cd.c
+++ b/drivers/ide/ide-cd.c
@@ -441,7 +441,7 @@ int ide_cd_queue_pc(ide_drive_t *drive, const unsigned char *cmd,
 		struct request *rq;
 		int error;
 
-		rq = blk_get_request(drive->queue, write, __GFP_WAIT);
+		rq = blk_get_request(drive->queue, write, __GFP_RECLAIM);
 
 		memcpy(rq->cmd, cmd, BLK_MAX_CDB);
 		rq->cmd_type = REQ_TYPE_ATA_PC;
diff --git a/drivers/ide/ide-cd_ioctl.c b/drivers/ide/ide-cd_ioctl.c
index 066e39036518..474173eb31bb 100644
--- a/drivers/ide/ide-cd_ioctl.c
+++ b/drivers/ide/ide-cd_ioctl.c
@@ -303,7 +303,7 @@ int ide_cdrom_reset(struct cdrom_device_info *cdi)
 	struct request *rq;
 	int ret;
 
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
 	rq->cmd_flags = REQ_QUIET;
 	ret = blk_execute_rq(drive->queue, cd->disk, rq, 0);
diff --git a/drivers/ide/ide-devsets.c b/drivers/ide/ide-devsets.c
index b05a74d78ef5..0dd43b4fcec6 100644
--- a/drivers/ide/ide-devsets.c
+++ b/drivers/ide/ide-devsets.c
@@ -165,7 +165,7 @@ int ide_devset_execute(ide_drive_t *drive, const struct ide_devset *setting,
 	if (!(setting->flags & DS_SYNC))
 		return setting->set(drive, arg);
 
-	rq = blk_get_request(q, READ, __GFP_WAIT);
+	rq = blk_get_request(q, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
 	rq->cmd_len = 5;
 	rq->cmd[0] = REQ_DEVSET_EXEC;
diff --git a/drivers/ide/ide-disk.c b/drivers/ide/ide-disk.c
index 56b9708894a5..37a8a907febe 100644
--- a/drivers/ide/ide-disk.c
+++ b/drivers/ide/ide-disk.c
@@ -477,7 +477,7 @@ static int set_multcount(ide_drive_t *drive, int arg)
 	if (drive->special_flags & IDE_SFLAG_SET_MULTMODE)
 		return -EBUSY;
 
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_ATA_TASKFILE;
 
 	drive->mult_req = arg;
diff --git a/drivers/ide/ide-ioctls.c b/drivers/ide/ide-ioctls.c
index aa2e9b77b20d..d05db2469209 100644
--- a/drivers/ide/ide-ioctls.c
+++ b/drivers/ide/ide-ioctls.c
@@ -125,7 +125,7 @@ static int ide_cmd_ioctl(ide_drive_t *drive, unsigned long arg)
 	if (NULL == (void *) arg) {
 		struct request *rq;
 
-		rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+		rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 		rq->cmd_type = REQ_TYPE_ATA_TASKFILE;
 		err = blk_execute_rq(drive->queue, NULL, rq, 0);
 		blk_put_request(rq);
@@ -221,7 +221,7 @@ static int generic_drive_reset(ide_drive_t *drive)
 	struct request *rq;
 	int ret = 0;
 
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
 	rq->cmd_len = 1;
 	rq->cmd[0] = REQ_DRIVE_RESET;
diff --git a/drivers/ide/ide-park.c b/drivers/ide/ide-park.c
index c80868520488..2d7dca56dd24 100644
--- a/drivers/ide/ide-park.c
+++ b/drivers/ide/ide-park.c
@@ -31,7 +31,7 @@ static void issue_park_cmd(ide_drive_t *drive, unsigned long timeout)
 	}
 	spin_unlock_irq(&hwif->lock);
 
-	rq = blk_get_request(q, READ, __GFP_WAIT);
+	rq = blk_get_request(q, READ, __GFP_RECLAIM);
 	rq->cmd[0] = REQ_PARK_HEADS;
 	rq->cmd_len = 1;
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
diff --git a/drivers/ide/ide-pm.c b/drivers/ide/ide-pm.c
index 081e43458d50..e34af488693a 100644
--- a/drivers/ide/ide-pm.c
+++ b/drivers/ide/ide-pm.c
@@ -18,7 +18,7 @@ int generic_ide_suspend(struct device *dev, pm_message_t mesg)
 	}
 
 	memset(&rqpm, 0, sizeof(rqpm));
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_ATA_PM_SUSPEND;
 	rq->special = &rqpm;
 	rqpm.pm_step = IDE_PM_START_SUSPEND;
@@ -88,7 +88,7 @@ int generic_ide_resume(struct device *dev)
 	}
 
 	memset(&rqpm, 0, sizeof(rqpm));
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_ATA_PM_RESUME;
 	rq->cmd_flags |= REQ_PREEMPT;
 	rq->special = &rqpm;
diff --git a/drivers/ide/ide-tape.c b/drivers/ide/ide-tape.c
index f5d51d1d09ee..12fa04997dcc 100644
--- a/drivers/ide/ide-tape.c
+++ b/drivers/ide/ide-tape.c
@@ -852,7 +852,7 @@ static int idetape_queue_rw_tail(ide_drive_t *drive, int cmd, int size)
 	BUG_ON(cmd != REQ_IDETAPE_READ && cmd != REQ_IDETAPE_WRITE);
 	BUG_ON(size < 0 || size % tape->blk_size);
 
-	rq = blk_get_request(drive->queue, READ, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, READ, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_DRV_PRIV;
 	rq->cmd[13] = cmd;
 	rq->rq_disk = tape->disk;
@@ -860,7 +860,7 @@ static int idetape_queue_rw_tail(ide_drive_t *drive, int cmd, int size)
 
 	if (size) {
 		ret = blk_rq_map_kern(drive->queue, rq, tape->buf, size,
-				      __GFP_WAIT);
+				      __GFP_RECLAIM);
 		if (ret)
 			goto out_put;
 	}
diff --git a/drivers/ide/ide-taskfile.c b/drivers/ide/ide-taskfile.c
index 0979e126fff1..a716693417a3 100644
--- a/drivers/ide/ide-taskfile.c
+++ b/drivers/ide/ide-taskfile.c
@@ -430,7 +430,7 @@ int ide_raw_taskfile(ide_drive_t *drive, struct ide_cmd *cmd, u8 *buf,
 	int error;
 	int rw = !(cmd->tf_flags & IDE_TFLAG_WRITE) ? READ : WRITE;
 
-	rq = blk_get_request(drive->queue, rw, __GFP_WAIT);
+	rq = blk_get_request(drive->queue, rw, __GFP_RECLAIM);
 	rq->cmd_type = REQ_TYPE_ATA_TASKFILE;
 
 	/*
@@ -441,7 +441,7 @@ int ide_raw_taskfile(ide_drive_t *drive, struct ide_cmd *cmd, u8 *buf,
 	 */
 	if (nsect) {
 		error = blk_rq_map_kern(drive->queue, rq, buf,
-					nsect * SECTOR_SIZE, __GFP_WAIT);
+					nsect * SECTOR_SIZE, __GFP_RECLAIM);
 		if (error)
 			goto put_req;
 	}
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 450d15965005..c11f6c58ce53 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -905,7 +905,7 @@ static int ipath_create_user_egr(struct ipath_portdata *pd)
 	 * heavy filesystem activity makes these fail, and we can
 	 * use compound pages.
 	 */
-	gfp_flags = __GFP_WAIT | __GFP_IO | __GFP_COMP;
+	gfp_flags = __GFP_RECLAIM | __GFP_IO | __GFP_COMP;
 
 	egrcnt = dd->ipath_rcvegrcnt;
 	/* TID number offset for this port */
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index 7e00470adc30..4ff340fe904f 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -1680,7 +1680,7 @@ int qib_setup_eagerbufs(struct qib_ctxtdata *rcd)
 	 * heavy filesystem activity makes these fail, and we can
 	 * use compound pages.
 	 */
-	gfp_flags = __GFP_WAIT | __GFP_IO | __GFP_COMP;
+	gfp_flags = __GFP_RECLAIM | __GFP_IO | __GFP_COMP;
 
 	egrcnt = rcd->rcvegrcnt;
 	egroff = rcd->rcvegr_tid_base;
diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index 191617492181..5a312958c094 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -85,7 +85,7 @@ MODULE_LICENSE("GPL");
 
 /*
  * Use __GFP_HIGHMEM to allow pages from HIGHMEM zone. We don't
- * allow wait (__GFP_WAIT) for NOSLEEP page allocations. Use
+ * allow wait (__GFP_RECLAIM) for NOSLEEP page allocations. Use
  * __GFP_NOWARN, to suppress page allocation failure warnings.
  */
 #define VMW_PAGE_ALLOC_NOSLEEP		(__GFP_HIGHMEM|__GFP_NOWARN)
diff --git a/drivers/scsi/scsi_error.c b/drivers/scsi/scsi_error.c
index cfadccef045c..26416e21295d 100644
--- a/drivers/scsi/scsi_error.c
+++ b/drivers/scsi/scsi_error.c
@@ -1961,7 +1961,7 @@ static void scsi_eh_lock_door(struct scsi_device *sdev)
 	struct request *req;
 
 	/*
-	 * blk_get_request with GFP_KERNEL (__GFP_WAIT) sleeps until a
+	 * blk_get_request with GFP_KERNEL (__GFP_RECLAIM) sleeps until a
 	 * request becomes available
 	 */
 	req = blk_get_request(sdev->request_queue, READ, GFP_KERNEL);
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 448ebdaa3d69..2396259b682b 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -221,13 +221,13 @@ int scsi_execute(struct scsi_device *sdev, const unsigned char *cmd,
 	int write = (data_direction == DMA_TO_DEVICE);
 	int ret = DRIVER_ERROR << 24;
 
-	req = blk_get_request(sdev->request_queue, write, __GFP_WAIT);
+	req = blk_get_request(sdev->request_queue, write, __GFP_RECLAIM);
 	if (IS_ERR(req))
 		return ret;
 	blk_rq_set_block_pc(req);
 
 	if (bufflen &&	blk_rq_map_kern(sdev->request_queue, req,
-					buffer, bufflen, __GFP_WAIT))
+					buffer, bufflen, __GFP_RECLAIM))
 		goto out;
 
 	req->cmd_len = COMMAND_SIZE(cmd[0]);
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index aecd0859eacb..9c4b737a54df 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -30,7 +30,7 @@ extern unsigned cachefiles_debug;
 #define CACHEFILES_DEBUG_KLEAVE	2
 #define CACHEFILES_DEBUG_KDEBUG	4
 
-#define cachefiles_gfp (__GFP_WAIT | __GFP_NORETRY | __GFP_NOMEMALLOC)
+#define cachefiles_gfp (__GFP_RECLAIM | __GFP_NORETRY | __GFP_NOMEMALLOC)
 
 /*
  * node records
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 745d2342651a..b97cf506a20e 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -360,7 +360,7 @@ dio_bio_alloc(struct dio *dio, struct dio_submit *sdio,
 
 	/*
 	 * bio_alloc() is guaranteed to return a bio when called with
-	 * __GFP_WAIT and we request a valid number of vectors.
+	 * __GFP_RECLAIM and we request a valid number of vectors.
 	 */
 	bio = bio_alloc(GFP_KERNEL, nr_vecs);
 
diff --git a/fs/nilfs2/mdt.h b/fs/nilfs2/mdt.h
index fe529a87a208..03246cac3338 100644
--- a/fs/nilfs2/mdt.h
+++ b/fs/nilfs2/mdt.h
@@ -72,7 +72,7 @@ static inline struct nilfs_mdt_info *NILFS_MDT(const struct inode *inode)
 }
 
 /* Default GFP flags using highmem */
-#define NILFS_MDT_GFP      (__GFP_WAIT | __GFP_IO | __GFP_HIGHMEM)
+#define NILFS_MDT_GFP      (__GFP_RECLAIM | __GFP_IO | __GFP_HIGHMEM)
 
 int nilfs_mdt_get_block(struct inode *, unsigned long, int,
 			void (*init_block)(struct inode *,
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bd1937977d84..f928bdee2b96 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -104,7 +104,7 @@ struct vm_area_struct;
  * can be cleared when the reclaiming of pages would cause unnecessary
  * disruption.
  */
-#define __GFP_WAIT (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
+#define __GFP_RECLAIM (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
 #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
 #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
 
@@ -123,12 +123,12 @@ struct vm_area_struct;
  */
 #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
 #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
-#define GFP_NOIO	(__GFP_WAIT)
-#define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
-#define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+#define GFP_NOIO	(__GFP_RECLAIM)
+#define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
+#define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
+#define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
 			 __GFP_RECLAIMABLE)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
+#define GFP_USER	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS | __GFP_KSWAPD_RECLAIM)
@@ -141,12 +141,12 @@ struct vm_area_struct;
 #define GFP_MOVABLE_SHIFT 3
 
 /* Control page allocator reclaim behavior */
-#define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
+#define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
 			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
 
 /* Control slab gfp mask during early boot */
-#define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
+#define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_RECLAIM|__GFP_IO|__GFP_FS))
 
 /* Control allocation constraints */
 #define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 2f30ca91e4fa..3841af470cf9 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -261,7 +261,7 @@ static int hib_submit_io(int rw, pgoff_t page_off, void *addr,
 	struct bio *bio;
 	int error = 0;
 
-	bio = bio_alloc(__GFP_WAIT | __GFP_HIGH, 1);
+	bio = bio_alloc(__GFP_RECLAIM | __GFP_HIGH, 1);
 	bio->bi_iter.bi_sector = page_off * (PAGE_SIZE >> 9);
 	bio->bi_bdev = hib_resume_bdev;
 
@@ -360,7 +360,7 @@ static int write_page(void *buf, sector_t offset, struct hib_bio_batch *hb)
 		return -ENOSPC;
 
 	if (hb) {
-		src = (void *)__get_free_page(__GFP_WAIT | __GFP_NOWARN |
+		src = (void *)__get_free_page(__GFP_RECLAIM | __GFP_NOWARN |
 		                              __GFP_NORETRY);
 		if (src) {
 			copy_page(src, buf);
@@ -368,7 +368,7 @@ static int write_page(void *buf, sector_t offset, struct hib_bio_batch *hb)
 			ret = hib_wait_io(hb); /* Free pages */
 			if (ret)
 				return ret;
-			src = (void *)__get_free_page(__GFP_WAIT |
+			src = (void *)__get_free_page(__GFP_RECLAIM |
 			                              __GFP_NOWARN |
 			                              __GFP_NORETRY);
 			if (src) {
@@ -676,7 +676,7 @@ static int save_image_lzo(struct swap_map_handle *handle,
 	nr_threads = num_online_cpus() - 1;
 	nr_threads = clamp_val(nr_threads, 1, LZO_THREADS);
 
-	page = (void *)__get_free_page(__GFP_WAIT | __GFP_HIGH);
+	page = (void *)__get_free_page(__GFP_RECLAIM | __GFP_HIGH);
 	if (!page) {
 		printk(KERN_ERR "PM: Failed to allocate LZO page\n");
 		ret = -ENOMEM;
@@ -979,7 +979,7 @@ static int get_swap_reader(struct swap_map_handle *handle,
 		last = tmp;
 
 		tmp->map = (struct swap_map_page *)
-		           __get_free_page(__GFP_WAIT | __GFP_HIGH);
+		           __get_free_page(__GFP_RECLAIM | __GFP_HIGH);
 		if (!tmp->map) {
 			release_swap_reader(handle);
 			return -ENOMEM;
@@ -1246,8 +1246,8 @@ static int load_image_lzo(struct swap_map_handle *handle,
 
 	for (i = 0; i < read_pages; i++) {
 		page[i] = (void *)__get_free_page(i < LZO_CMP_PAGES ?
-		                                  __GFP_WAIT | __GFP_HIGH :
-		                                  __GFP_WAIT | __GFP_NOWARN |
+		                                  __GFP_RECLAIM | __GFP_HIGH :
+		                                  __GFP_RECLAIM | __GFP_NOWARN |
 		                                  __GFP_NORETRY);
 
 		if (!page[i]) {
diff --git a/lib/percpu_ida.c b/lib/percpu_ida.c
index f75715131f20..6d40944960de 100644
--- a/lib/percpu_ida.c
+++ b/lib/percpu_ida.c
@@ -135,7 +135,7 @@ static inline unsigned alloc_local_tag(struct percpu_ida_cpu *tags)
  * TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, of course).
  *
  * @gfp indicates whether or not to wait until a free id is available (it's not
- * used for internal memory allocations); thus if passed __GFP_WAIT we may sleep
+ * used for internal memory allocations); thus if passed __GFP_RECLAIM we may sleep
  * however long it takes until another thread frees an id (same semantics as a
  * mempool).
  *
diff --git a/mm/failslab.c b/mm/failslab.c
index fefaabaab76d..69f083146a37 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -3,11 +3,11 @@
 
 static struct {
 	struct fault_attr attr;
-	u32 ignore_gfp_wait;
+	u32 ignore_gfp_reclaim;
 	int cache_filter;
 } failslab = {
 	.attr = FAULT_ATTR_INITIALIZER,
-	.ignore_gfp_wait = 1,
+	.ignore_gfp_reclaim = 1,
 	.cache_filter = 0,
 };
 
@@ -16,7 +16,7 @@ bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_flags)
 	if (gfpflags & __GFP_NOFAIL)
 		return false;
 
-        if (failslab.ignore_gfp_wait && (gfpflags & __GFP_WAIT))
+        if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
 		return false;
 
 	if (failslab.cache_filter && !(cache_flags & SLAB_FAILSLAB))
@@ -42,7 +42,7 @@ static int __init failslab_debugfs_init(void)
 		return PTR_ERR(dir);
 
 	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				&failslab.ignore_gfp_wait))
+				&failslab.ignore_gfp_reclaim))
 		goto fail;
 	if (!debugfs_create_bool("cache-filter", mode, dir,
 				&failslab.cache_filter))
diff --git a/mm/filemap.c b/mm/filemap.c
index 1283fc825458..986fe45a5d27 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2673,7 +2673,7 @@ EXPORT_SYMBOL(generic_file_write_iter);
  * page is known to the local caching routines.
  *
  * The @gfp_mask argument specifies whether I/O may be performed to release
- * this page (__GFP_IO), and whether the call may block (__GFP_WAIT & __GFP_FS).
+ * this page (__GFP_IO), and whether the call may block (__GFP_RECLAIM & __GFP_FS).
  *
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 097c7a4bfbd9..36efda9ff8f1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -767,7 +767,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 {
-	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
+	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_RECLAIM)) | extra_gfp;
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/migrate.c b/mm/migrate.c
index 0e16c4047638..c6aa1ef906b4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1738,7 +1738,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_dropref;
 
 	new_page = alloc_pages_node(node,
-		(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_WAIT,
+		(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
 		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 68f961bdfdf8..d176be999b26 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2135,11 +2135,11 @@ static struct {
 	struct fault_attr attr;
 
 	u32 ignore_gfp_highmem;
-	u32 ignore_gfp_wait;
+	u32 ignore_gfp_reclaim;
 	u32 min_order;
 } fail_page_alloc = {
 	.attr = FAULT_ATTR_INITIALIZER,
-	.ignore_gfp_wait = 1,
+	.ignore_gfp_reclaim = 1,
 	.ignore_gfp_highmem = 1,
 	.min_order = 1,
 };
@@ -2158,7 +2158,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 		return false;
 	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
 		return false;
-	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
+	if (fail_page_alloc.ignore_gfp_reclaim && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		return false;
 
 	return should_fail(&fail_page_alloc.attr, 1 << order);
@@ -2177,7 +2177,7 @@ static int __init fail_page_alloc_debugfs(void)
 		return PTR_ERR(dir);
 
 	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				&fail_page_alloc.ignore_gfp_wait))
+				&fail_page_alloc.ignore_gfp_reclaim))
 		goto fail;
 	if (!debugfs_create_bool("ignore-gfp-highmem", mode, dir,
 				&fail_page_alloc.ignore_gfp_highmem))
@@ -2660,7 +2660,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		if (test_thread_flag(TIF_MEMDIE) ||
 		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
 			filter &= ~SHOW_MEM_FILTER_NODES;
-	if (in_interrupt() || !(gfp_mask & __GFP_WAIT) || (gfp_mask & __GFP_ATOMIC))
+	if (in_interrupt() || !(gfp_mask & __GFP_RECLAIM) || (gfp_mask & __GFP_ATOMIC))
 		filter &= ~SHOW_MEM_FILTER_NODES;
 
 	if (fmt) {
diff --git a/security/integrity/ima/ima_crypto.c b/security/integrity/ima/ima_crypto.c
index e24121afb2f2..6eb62936c672 100644
--- a/security/integrity/ima/ima_crypto.c
+++ b/security/integrity/ima/ima_crypto.c
@@ -126,7 +126,7 @@ static void *ima_alloc_pages(loff_t max_size, size_t *allocated_size,
 {
 	void *ptr;
 	int order = ima_maxorder;
-	gfp_t gfp_mask = __GFP_WAIT | __GFP_NOWARN | __GFP_NORETRY;
+	gfp_t gfp_mask = __GFP_RECLAIM | __GFP_NOWARN | __GFP_NORETRY;
 
 	if (order)
 		order = min(get_order(max_size), order);
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
