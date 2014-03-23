Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A84D46B00C9
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:08:42 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so4503720pab.18
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:08:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id f1si7600405pbn.489.2014.03.23.12.08.41
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:08:41 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 5/6] NVMe: Add support for rw_page
Date: Sun, 23 Mar 2014 15:08:27 -0400
Message-Id: <a66cfddda7ce7e502e1ea73f5e0e089ca9f42bb9.1395593198.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395593198.git.matthew.r.wilcox@intel.com>
References: <cover.1395593198.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395593198.git.matthew.r.wilcox@intel.com>
References: <cover.1395593198.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, willy@linux.intel.com, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Keith Busch <keith.busch@intel.com>

This demonstrates the full potential of rw_page in a real device driver.
By adding a dma_addr_t to the preallocated per-command data structure, we
can avoid doing any memory allocation in the rw_page path.  For example,
that lets us swap without allocating any memory.

Signed-off-by: Keith Busch <keith.busch@intel.com>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 drivers/block/nvme-core.c | 129 +++++++++++++++++++++++++++++++++++++---------
 1 file changed, 105 insertions(+), 24 deletions(-)

diff --git a/drivers/block/nvme-core.c b/drivers/block/nvme-core.c
index 51824d1..10ccd80 100644
--- a/drivers/block/nvme-core.c
+++ b/drivers/block/nvme-core.c
@@ -118,12 +118,13 @@ static inline void _nvme_check_size(void)
 	BUILD_BUG_ON(sizeof(struct nvme_smart_log) != 512);
 }
 
-typedef void (*nvme_completion_fn)(struct nvme_dev *, void *,
+typedef void (*nvme_completion_fn)(struct nvme_dev *, void *, dma_addr_t,
 						struct nvme_completion *);
 
 struct nvme_cmd_info {
 	nvme_completion_fn fn;
 	void *ctx;
+	dma_addr_t dma;
 	unsigned long timeout;
 	int aborted;
 };
@@ -153,7 +154,7 @@ static unsigned nvme_queue_extra(int depth)
  * May be called with local interrupts disabled and the q_lock held,
  * or with interrupts enabled and no locks held.
  */
-static int alloc_cmdid(struct nvme_queue *nvmeq, void *ctx,
+static int alloc_cmdid(struct nvme_queue *nvmeq, void *ctx, dma_addr_t dma,
 				nvme_completion_fn handler, unsigned timeout)
 {
 	int depth = nvmeq->q_depth - 1;
@@ -168,17 +169,18 @@ static int alloc_cmdid(struct nvme_queue *nvmeq, void *ctx,
 
 	info[cmdid].fn = handler;
 	info[cmdid].ctx = ctx;
+	info[cmdid].dma = dma;
 	info[cmdid].timeout = jiffies + timeout;
 	info[cmdid].aborted = 0;
 	return cmdid;
 }
 
-static int alloc_cmdid_killable(struct nvme_queue *nvmeq, void *ctx,
+static int alloc_cmdid_killable(struct nvme_queue *nvmeq, void *ctx, dma_addr_t dma,
 				nvme_completion_fn handler, unsigned timeout)
 {
 	int cmdid;
 	wait_event_killable(nvmeq->sq_full,
-		(cmdid = alloc_cmdid(nvmeq, ctx, handler, timeout)) >= 0);
+		(cmdid = alloc_cmdid(nvmeq, ctx, dma, handler, timeout)) >= 0);
 	return (cmdid < 0) ? -EINTR : cmdid;
 }
 
@@ -190,7 +192,7 @@ static int alloc_cmdid_killable(struct nvme_queue *nvmeq, void *ctx,
 #define CMD_CTX_FLUSH		(0x318 + CMD_CTX_BASE)
 #define CMD_CTX_ABORT		(0x31C + CMD_CTX_BASE)
 
-static void special_completion(struct nvme_dev *dev, void *ctx,
+static void special_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
 						struct nvme_completion *cqe)
 {
 	if (ctx == CMD_CTX_CANCELLED)
@@ -217,7 +219,7 @@ static void special_completion(struct nvme_dev *dev, void *ctx,
 	dev_warn(&dev->pci_dev->dev, "Unknown special completion %p\n", ctx);
 }
 
-static void async_completion(struct nvme_dev *dev, void *ctx,
+static void async_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
 						struct nvme_completion *cqe)
 {
 	struct async_cmd_info *cmdinfo = ctx;
@@ -229,7 +231,7 @@ static void async_completion(struct nvme_dev *dev, void *ctx,
 /*
  * Called with local interrupts disabled and the q_lock held.  May not sleep.
  */
-static void *free_cmdid(struct nvme_queue *nvmeq, int cmdid,
+static void *free_cmdid(struct nvme_queue *nvmeq, int cmdid, dma_addr_t *dmap,
 						nvme_completion_fn *fn)
 {
 	void *ctx;
@@ -241,6 +243,8 @@ static void *free_cmdid(struct nvme_queue *nvmeq, int cmdid,
 	}
 	if (fn)
 		*fn = info[cmdid].fn;
+	if (dmap)
+		*dmap = info[cmdid].dma;
 	ctx = info[cmdid].ctx;
 	info[cmdid].fn = special_completion;
 	info[cmdid].ctx = CMD_CTX_COMPLETED;
@@ -249,13 +253,15 @@ static void *free_cmdid(struct nvme_queue *nvmeq, int cmdid,
 	return ctx;
 }
 
-static void *cancel_cmdid(struct nvme_queue *nvmeq, int cmdid,
+static void *cancel_cmdid(struct nvme_queue *nvmeq, int cmdid, dma_addr_t *dmap,
 						nvme_completion_fn *fn)
 {
 	void *ctx;
 	struct nvme_cmd_info *info = nvme_cmd_info(nvmeq);
 	if (fn)
 		*fn = info[cmdid].fn;
+	if (dmap)
+		*dmap = info[cmdid].dma;
 	ctx = info[cmdid].ctx;
 	info[cmdid].fn = special_completion;
 	info[cmdid].ctx = CMD_CTX_CANCELLED;
@@ -371,7 +377,7 @@ static void nvme_end_io_acct(struct bio *bio, unsigned long start_time)
 	part_stat_unlock();
 }
 
-static void bio_completion(struct nvme_dev *dev, void *ctx,
+static void bio_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
 						struct nvme_completion *cqe)
 {
 	struct nvme_iod *iod = ctx;
@@ -593,7 +599,7 @@ static int nvme_submit_flush(struct nvme_queue *nvmeq, struct nvme_ns *ns,
 
 int nvme_submit_flush_data(struct nvme_queue *nvmeq, struct nvme_ns *ns)
 {
-	int cmdid = alloc_cmdid(nvmeq, (void *)CMD_CTX_FLUSH,
+	int cmdid = alloc_cmdid(nvmeq, (void *)CMD_CTX_FLUSH, 0,
 					special_completion, NVME_IO_TIMEOUT);
 	if (unlikely(cmdid < 0))
 		return cmdid;
@@ -628,7 +634,7 @@ static int nvme_submit_bio_queue(struct nvme_queue *nvmeq, struct nvme_ns *ns,
 	iod->private = bio;
 
 	result = -EBUSY;
-	cmdid = alloc_cmdid(nvmeq, iod, bio_completion, NVME_IO_TIMEOUT);
+	cmdid = alloc_cmdid(nvmeq, iod, 0, bio_completion, NVME_IO_TIMEOUT);
 	if (unlikely(cmdid < 0))
 		goto free_iod;
 
@@ -684,7 +690,7 @@ static int nvme_submit_bio_queue(struct nvme_queue *nvmeq, struct nvme_ns *ns,
 	return 0;
 
  free_cmdid:
-	free_cmdid(nvmeq, cmdid, NULL);
+	free_cmdid(nvmeq, cmdid, NULL, NULL);
  free_iod:
 	nvme_free_iod(nvmeq->dev, iod);
  nomem:
@@ -700,6 +706,7 @@ static int nvme_process_cq(struct nvme_queue *nvmeq)
 
 	for (;;) {
 		void *ctx;
+		dma_addr_t dma;
 		nvme_completion_fn fn;
 		struct nvme_completion cqe = nvmeq->cqes[head];
 		if ((le16_to_cpu(cqe.status) & 1) != phase)
@@ -710,8 +717,8 @@ static int nvme_process_cq(struct nvme_queue *nvmeq)
 			phase = !phase;
 		}
 
-		ctx = free_cmdid(nvmeq, cqe.command_id, &fn);
-		fn(nvmeq->dev, ctx, &cqe);
+		ctx = free_cmdid(nvmeq, cqe.command_id, &dma, &fn);
+		fn(nvmeq->dev, ctx, dma, &cqe);
 	}
 
 	/* If the controller ignores the cq head doorbell and continuously
@@ -781,7 +788,7 @@ static irqreturn_t nvme_irq_check(int irq, void *data)
 static void nvme_abort_command(struct nvme_queue *nvmeq, int cmdid)
 {
 	spin_lock_irq(&nvmeq->q_lock);
-	cancel_cmdid(nvmeq, cmdid, NULL);
+	cancel_cmdid(nvmeq, cmdid, NULL, NULL);
 	spin_unlock_irq(&nvmeq->q_lock);
 }
 
@@ -791,7 +798,7 @@ struct sync_cmd_info {
 	int status;
 };
 
-static void sync_completion(struct nvme_dev *dev, void *ctx,
+static void sync_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
 						struct nvme_completion *cqe)
 {
 	struct sync_cmd_info *cmdinfo = ctx;
@@ -813,7 +820,7 @@ int nvme_submit_sync_cmd(struct nvme_queue *nvmeq, struct nvme_command *cmd,
 	cmdinfo.task = current;
 	cmdinfo.status = -EINTR;
 
-	cmdid = alloc_cmdid_killable(nvmeq, &cmdinfo, sync_completion,
+	cmdid = alloc_cmdid_killable(nvmeq, &cmdinfo, 0, sync_completion,
 								timeout);
 	if (cmdid < 0)
 		return cmdid;
@@ -838,9 +845,8 @@ static int nvme_submit_async_cmd(struct nvme_queue *nvmeq,
 			struct nvme_command *cmd,
 			struct async_cmd_info *cmdinfo, unsigned timeout)
 {
-	int cmdid;
-
-	cmdid = alloc_cmdid_killable(nvmeq, cmdinfo, async_completion, timeout);
+	int cmdid = alloc_cmdid_killable(nvmeq, cmdinfo, 0, async_completion,
+								timeout);
 	if (cmdid < 0)
 		return cmdid;
 	cmdinfo->status = -EINTR;
@@ -1001,8 +1007,8 @@ static void nvme_abort_cmd(int cmdid, struct nvme_queue *nvmeq)
 	if (!dev->abort_limit)
 		return;
 
-	a_cmdid = alloc_cmdid(dev->queues[0], CMD_CTX_ABORT, special_completion,
-								ADMIN_TIMEOUT);
+	a_cmdid = alloc_cmdid(dev->queues[0], CMD_CTX_ABORT, 0,
+				special_completion, ADMIN_TIMEOUT);
 	if (a_cmdid < 0)
 		return;
 
@@ -1035,6 +1041,7 @@ static void nvme_cancel_ios(struct nvme_queue *nvmeq, bool timeout)
 
 	for_each_set_bit(cmdid, nvmeq->cmdid_data, depth) {
 		void *ctx;
+		dma_addr_t dma;
 		nvme_completion_fn fn;
 		static struct nvme_completion cqe = {
 			.status = cpu_to_le16(NVME_SC_ABORT_REQ << 1),
@@ -1050,8 +1057,8 @@ static void nvme_cancel_ios(struct nvme_queue *nvmeq, bool timeout)
 		}
 		dev_warn(nvmeq->q_dmadev, "Cancelling I/O %d QID %d\n", cmdid,
 								nvmeq->qid);
-		ctx = cancel_cmdid(nvmeq, cmdid, &fn);
-		fn(nvmeq->dev, ctx, &cqe);
+		ctx = cancel_cmdid(nvmeq, cmdid, &dma, &fn);
+		fn(nvmeq->dev, ctx, dma, &cqe);
 	}
 }
 
@@ -1539,6 +1546,79 @@ static int nvme_submit_io(struct nvme_ns *ns, struct nvme_user_io __user *uio)
 	return status;
 }
 
+static void pgrd_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
+						struct nvme_completion *cqe)
+{
+	struct page *page = ctx;
+	u16 status = le16_to_cpup(&cqe->status) >> 1;
+
+	dma_unmap_page(&dev->pci_dev->dev, dma,
+			PAGE_CACHE_SIZE, DMA_FROM_DEVICE);
+	page_endio(page, READ, status != NVME_SC_SUCCESS);
+}
+
+static void pgwr_completion(struct nvme_dev *dev, void *ctx, dma_addr_t dma,
+						struct nvme_completion *cqe)
+{
+	struct page *page = ctx;
+	u16 status = le16_to_cpup(&cqe->status) >> 1;
+
+	dma_unmap_page(&dev->pci_dev->dev, dma, PAGE_CACHE_SIZE, DMA_TO_DEVICE);
+	page_endio(page, WRITE, status != NVME_SC_SUCCESS);
+}
+
+static const enum dma_data_direction nvme_to_direction[] = {
+	DMA_NONE, DMA_TO_DEVICE, DMA_FROM_DEVICE, DMA_BIDIRECTIONAL
+};
+
+static int nvme_rw_page(struct block_device *bdev, sector_t sector,
+			struct page *page, int rw)
+{
+	struct nvme_ns *ns = bdev->bd_disk->private_data;
+	u8 op = (rw & WRITE) ? nvme_cmd_write : nvme_cmd_read;
+	nvme_completion_fn fn = (rw & WRITE) ? pgwr_completion :
+					       pgrd_completion;
+	dma_addr_t dma;
+	int cmdid;
+	struct nvme_command *cmd;
+	enum dma_data_direction dma_dir = nvme_to_direction[op & 3];
+	struct nvme_queue *nvmeq = get_nvmeq(ns->dev);
+	dma = dma_map_page(nvmeq->q_dmadev, page, 0, PAGE_CACHE_SIZE, dma_dir);
+
+	if (rw == WRITE)
+		cmdid = alloc_cmdid(nvmeq, page, dma, fn, NVME_IO_TIMEOUT);
+	else
+		cmdid = alloc_cmdid_killable(nvmeq, page, dma, fn,
+							NVME_IO_TIMEOUT);
+	if (unlikely(cmdid < 0)) {
+		dma_unmap_page(nvmeq->q_dmadev, dma, PAGE_CACHE_SIZE,
+							DMA_FROM_DEVICE);
+		put_nvmeq(nvmeq);
+		return -EBUSY;
+	}
+
+	spin_lock_irq(&nvmeq->q_lock);
+	cmd = &nvmeq->sq_cmds[nvmeq->sq_tail];
+	memset(cmd, 0, sizeof(*cmd));
+
+	cmd->rw.opcode = op;
+	cmd->rw.command_id = cmdid;
+	cmd->rw.nsid = cpu_to_le32(ns->ns_id);
+	cmd->rw.slba = cpu_to_le64(nvme_block_nr(ns, sector));
+	cmd->rw.length = cpu_to_le16((PAGE_CACHE_SIZE >> ns->lba_shift) - 1);
+	cmd->rw.prp1 = cpu_to_le64(dma);
+
+	if (++nvmeq->sq_tail == nvmeq->q_depth)
+		nvmeq->sq_tail = 0;
+	writel(nvmeq->sq_tail, nvmeq->q_db);
+
+	nvme_process_cq(nvmeq);
+	spin_unlock_irq(&nvmeq->q_lock);
+	put_nvmeq(nvmeq);
+
+	return 0;
+}
+
 static int nvme_user_admin_cmd(struct nvme_dev *dev,
 					struct nvme_admin_cmd __user *ucmd)
 {
@@ -1655,6 +1735,7 @@ static void nvme_release(struct gendisk *disk, fmode_t mode)
 
 static const struct block_device_operations nvme_fops = {
 	.owner		= THIS_MODULE,
+	.rw_page	= nvme_rw_page,
 	.ioctl		= nvme_ioctl,
 	.compat_ioctl	= nvme_compat_ioctl,
 	.open		= nvme_open,
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
