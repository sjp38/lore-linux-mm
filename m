Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B15776B06BA
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:19 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s84-v6so3426169oig.17
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e79-v6si1161323oib.370.2018.05.11.12.10.18
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:18 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 30/40] iommu/arm-smmu-v3: Register I/O Page Fault queue
Date: Fri, 11 May 2018 20:06:31 +0100
Message-Id: <20180511190641.23008-31-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

When using PRI or Stall, the PRI or event handler enqueues faults into the
core fault queue. Register it based on the SMMU features.

When the core stops using a PASID, it notifies the SMMU to flush all
instances of this PASID from the PRI queue. Add a way to flush the PRI and
event queue. PRI and event thread now take a spinlock while processing the
queue. The flush handler takes this lock to inspect the queue state.
We avoid livelock, where the SMMU adds fault to the queue faster than we
can consume them, by incrementing a 'batch' number on every cycle so the
flush handler only has to wait a complete cycle (two batch increments).

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: Use an iopf_queue for each SMMU
---
 drivers/iommu/Kconfig       |   1 +
 drivers/iommu/arm-smmu-v3.c | 111 +++++++++++++++++++++++++++++++++++-
 2 files changed, 110 insertions(+), 2 deletions(-)

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 70900670a9fa..41db49795c90 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -344,6 +344,7 @@ config ARM_SMMU_V3
 	depends on ARM64
 	select IOMMU_API
 	select IOMMU_SVA
+	select IOMMU_PAGE_FAULT
 	select IOMMU_IO_PGTABLE_LPAE
 	select ARM_SMMU_V3_CONTEXT
 	select GENERIC_MSI_IRQ_DOMAIN
diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 7c839d305d97..5d57f41f79b4 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -448,6 +448,10 @@ struct arm_smmu_queue {
 
 	u32 __iomem			*prod_reg;
 	u32 __iomem			*cons_reg;
+
+	/* Event and PRI */
+	u64				batch;
+	wait_queue_head_t		wq;
 };
 
 struct arm_smmu_cmdq {
@@ -565,6 +569,8 @@ struct arm_smmu_device {
 
 	/* IOMMU core code handle */
 	struct iommu_device		iommu;
+
+	struct iopf_queue		*iopf_queue;
 };
 
 /* SMMU private data for each master */
@@ -577,6 +583,7 @@ struct arm_smmu_master_data {
 
 	struct device			*dev;
 	size_t				ssid_bits;
+	bool				can_fault;
 };
 
 /* SMMU private data for an IOMMU domain */
@@ -1183,14 +1190,23 @@ static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
 static irqreturn_t arm_smmu_evtq_thread(int irq, void *dev)
 {
 	int i;
+	int num_handled = 0;
 	struct arm_smmu_device *smmu = dev;
 	struct arm_smmu_queue *q = &smmu->evtq.q;
+	size_t queue_size = 1 << q->max_n_shift;
 	u64 evt[EVTQ_ENT_DWORDS];
 
+	spin_lock(&q->wq.lock);
 	do {
 		while (!queue_remove_raw(q, evt)) {
 			u8 id = FIELD_GET(EVTQ_0_ID, evt[0]);
 
+			if (++num_handled == queue_size) {
+				q->batch++;
+				wake_up_all_locked(&q->wq);
+				num_handled = 0;
+			}
+
 			dev_info(smmu->dev, "event 0x%02x received:\n", id);
 			for (i = 0; i < ARRAY_SIZE(evt); ++i)
 				dev_info(smmu->dev, "\t0x%016llx\n",
@@ -1208,6 +1224,11 @@ static irqreturn_t arm_smmu_evtq_thread(int irq, void *dev)
 
 	/* Sync our overflow flag, as we believe we're up to speed */
 	q->cons = Q_OVF(q, q->prod) | Q_WRP(q, q->cons) | Q_IDX(q, q->cons);
+
+	q->batch++;
+	wake_up_all_locked(&q->wq);
+	spin_unlock(&q->wq.lock);
+
 	return IRQ_HANDLED;
 }
 
@@ -1251,13 +1272,24 @@ static void arm_smmu_handle_ppr(struct arm_smmu_device *smmu, u64 *evt)
 
 static irqreturn_t arm_smmu_priq_thread(int irq, void *dev)
 {
+	int num_handled = 0;
 	struct arm_smmu_device *smmu = dev;
 	struct arm_smmu_queue *q = &smmu->priq.q;
+	size_t queue_size = 1 << q->max_n_shift;
 	u64 evt[PRIQ_ENT_DWORDS];
 
+	spin_lock(&q->wq.lock);
 	do {
-		while (!queue_remove_raw(q, evt))
+		while (!queue_remove_raw(q, evt)) {
+			spin_unlock(&q->wq.lock);
 			arm_smmu_handle_ppr(smmu, evt);
+			spin_lock(&q->wq.lock);
+			if (++num_handled == queue_size) {
+				q->batch++;
+				wake_up_all_locked(&q->wq);
+				num_handled = 0;
+			}
+		}
 
 		if (queue_sync_prod(q) == -EOVERFLOW)
 			dev_err(smmu->dev, "PRIQ overflow detected -- requests lost\n");
@@ -1265,9 +1297,60 @@ static irqreturn_t arm_smmu_priq_thread(int irq, void *dev)
 
 	/* Sync our overflow flag, as we believe we're up to speed */
 	q->cons = Q_OVF(q, q->prod) | Q_WRP(q, q->cons) | Q_IDX(q, q->cons);
+
+	q->batch++;
+	wake_up_all_locked(&q->wq);
+	spin_unlock(&q->wq.lock);
+
 	return IRQ_HANDLED;
 }
 
+/*
+ * arm_smmu_flush_queue - wait until all events/PPRs currently in the queue have
+ * been consumed.
+ *
+ * Wait until the queue thread finished a batch, or until the queue is empty.
+ * Note that we don't handle overflows on q->batch. If it occurs, just wait for
+ * the queue to be empty.
+ */
+static int arm_smmu_flush_queue(struct arm_smmu_device *smmu,
+				struct arm_smmu_queue *q, const char *name)
+{
+	int ret;
+	u64 batch;
+
+	spin_lock(&q->wq.lock);
+	if (queue_sync_prod(q) == -EOVERFLOW)
+		dev_err(smmu->dev, "%s overflow detected -- requests lost\n", name);
+
+	batch = q->batch;
+	ret = wait_event_interruptible_locked(q->wq, queue_empty(q) ||
+					      q->batch >= batch + 2);
+	spin_unlock(&q->wq.lock);
+
+	return ret;
+}
+
+static int arm_smmu_flush_queues(void *cookie, struct device *dev)
+{
+	struct arm_smmu_master_data *master;
+	struct arm_smmu_device *smmu = cookie;
+
+	if (dev) {
+		master = dev->iommu_fwspec->iommu_priv;
+		/* TODO: add support for PRI and Stall */
+		return 0;
+	}
+
+	/* No target device, flush all queues. */
+	if (smmu->features & ARM_SMMU_FEAT_STALLS)
+		arm_smmu_flush_queue(smmu, &smmu->evtq.q, "evtq");
+	if (smmu->features & ARM_SMMU_FEAT_PRI)
+		arm_smmu_flush_queue(smmu, &smmu->priq.q, "priq");
+
+	return 0;
+}
+
 static int arm_smmu_device_disable(struct arm_smmu_device *smmu);
 
 static irqreturn_t arm_smmu_gerror_handler(int irq, void *dev)
@@ -1864,15 +1947,24 @@ arm_smmu_iova_to_phys(struct iommu_domain *domain, dma_addr_t iova)
 
 static int arm_smmu_sva_init(struct device *dev, struct iommu_sva_param *param)
 {
+	int ret;
 	struct arm_smmu_master_data *master = dev->iommu_fwspec->iommu_priv;
 
 	/* SSID support is mandatory for the moment */
 	if (!master->ssid_bits)
 		return -EINVAL;
 
-	if (param->features)
+	if (param->features & ~IOMMU_SVA_FEAT_IOPF)
 		return -EINVAL;
 
+	if (param->features & IOMMU_SVA_FEAT_IOPF) {
+		if (!master->can_fault)
+			return -EINVAL;
+		ret = iopf_queue_add_device(master->smmu->iopf_queue, dev);
+		if (ret)
+			return ret;
+	}
+
 	if (!param->max_pasid)
 		param->max_pasid = 0xfffffU;
 
@@ -1886,6 +1978,7 @@ static int arm_smmu_sva_init(struct device *dev, struct iommu_sva_param *param)
 static void arm_smmu_sva_shutdown(struct device *dev,
 				  struct iommu_sva_param *param)
 {
+	iopf_queue_remove_device(dev);
 }
 
 static struct io_mm *arm_smmu_mm_alloc(struct iommu_domain *domain,
@@ -2063,6 +2156,7 @@ static void arm_smmu_remove_device(struct device *dev)
 
 	master = fwspec->iommu_priv;
 	smmu = master->smmu;
+	iopf_queue_remove_device(dev);
 	if (master && master->ste.assigned)
 		arm_smmu_detach_dev(dev);
 	iommu_group_remove_device(dev);
@@ -2222,6 +2316,10 @@ static int arm_smmu_init_one_queue(struct arm_smmu_device *smmu,
 	q->q_base |= FIELD_PREP(Q_BASE_LOG2SIZE, q->max_n_shift);
 
 	q->prod = q->cons = 0;
+
+	init_waitqueue_head(&q->wq);
+	q->batch = 0;
+
 	return 0;
 }
 
@@ -3128,6 +3226,14 @@ static int arm_smmu_device_probe(struct platform_device *pdev)
 	if (ret)
 		return ret;
 
+	if (smmu->features & (ARM_SMMU_FEAT_STALLS | ARM_SMMU_FEAT_PRI)) {
+		smmu->iopf_queue = iopf_queue_alloc(dev_name(dev),
+						    arm_smmu_flush_queues,
+						    smmu);
+		if (!smmu->iopf_queue)
+			return -ENOMEM;
+	}
+
 	/* And we're up. Go go go! */
 	ret = iommu_device_sysfs_add(&smmu->iommu, dev, NULL,
 				     "smmu3.%pa", &ioaddr);
@@ -3170,6 +3276,7 @@ static int arm_smmu_device_remove(struct platform_device *pdev)
 {
 	struct arm_smmu_device *smmu = platform_get_drvdata(pdev);
 
+	iopf_queue_free(smmu->iopf_queue);
 	arm_smmu_device_disable(smmu);
 
 	return 0;
-- 
2.17.0
