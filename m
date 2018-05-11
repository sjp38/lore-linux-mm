Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 401AC6B06C0
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:36 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x195-v6so3427525oix.18
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v125-v6si1197163oig.380.2018.05.11.12.10.34
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:34 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 33/40] iommu/arm-smmu-v3: Add stall support for platform devices
Date: Fri, 11 May 2018 20:06:34 +0100
Message-Id: <20180511190641.23008-34-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

The SMMU provides a Stall model for handling page faults in platform
devices. It is similar to PCI PRI, but doesn't require devices to have
their own translation cache. Instead, faulting transactions are parked and
the OS is given a chance to fix the page tables and retry the transaction.

Enable stall for devices that support it (opt-in by firmware). When an
event corresponds to a translation error, call the IOMMU fault handler. If
the fault is recoverable, it will call us back to terminate or continue
the stall.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3.c | 178 +++++++++++++++++++++++++++++++++++-
 1 file changed, 173 insertions(+), 5 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 0f2d8aa0deee..8a6a799ba04a 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -301,6 +301,11 @@
 #define CMDQ_PRI_1_GRPID		GENMASK_ULL(8, 0)
 #define CMDQ_PRI_1_RESP			GENMASK_ULL(13, 12)
 
+#define CMDQ_RESUME_0_SID		GENMASK_ULL(63, 32)
+#define CMDQ_RESUME_0_ACTION_RETRY	(1UL << 12)
+#define CMDQ_RESUME_0_ACTION_ABORT	(1UL << 13)
+#define CMDQ_RESUME_1_STAG		GENMASK_ULL(15, 0)
+
 #define CMDQ_SYNC_0_CS			GENMASK_ULL(13, 12)
 #define CMDQ_SYNC_0_CS_NONE		0
 #define CMDQ_SYNC_0_CS_IRQ		1
@@ -316,6 +321,25 @@
 
 #define EVTQ_0_ID			GENMASK_ULL(7, 0)
 
+#define EVT_ID_TRANSLATION_FAULT	0x10
+#define EVT_ID_ADDR_SIZE_FAULT		0x11
+#define EVT_ID_ACCESS_FAULT		0x12
+#define EVT_ID_PERMISSION_FAULT		0x13
+
+#define EVTQ_0_SSV			(1UL << 11)
+#define EVTQ_0_SSID			GENMASK_ULL(31, 12)
+#define EVTQ_0_SID			GENMASK_ULL(63, 32)
+#define EVTQ_1_STAG			GENMASK_ULL(15, 0)
+#define EVTQ_1_STALL			(1UL << 31)
+#define EVTQ_1_PRIV			(1UL << 33)
+#define EVTQ_1_EXEC			(1UL << 34)
+#define EVTQ_1_READ			(1UL << 35)
+#define EVTQ_1_S2			(1UL << 39)
+#define EVTQ_1_CLASS			GENMASK_ULL(41, 40)
+#define EVTQ_1_TT_READ			(1UL << 44)
+#define EVTQ_2_ADDR			GENMASK_ULL(63, 0)
+#define EVTQ_3_IPA			GENMASK_ULL(51, 12)
+
 /* PRI queue */
 #define PRIQ_ENT_DWORDS			2
 #define PRIQ_MAX_SZ_SHIFT		8
@@ -426,6 +450,13 @@ struct arm_smmu_cmdq_ent {
 			enum pri_resp		resp;
 		} pri;
 
+		#define CMDQ_OP_RESUME		0x44
+		struct {
+			u32			sid;
+			u16			stag;
+			enum page_response_code	resp;
+		} resume;
+
 		#define CMDQ_OP_CMD_SYNC	0x46
 		struct {
 			u32			msidata;
@@ -499,6 +530,8 @@ struct arm_smmu_strtab_ent {
 	bool				assigned;
 	struct arm_smmu_s1_cfg		*s1_cfg;
 	struct arm_smmu_s2_cfg		*s2_cfg;
+
+	bool				can_stall;
 };
 
 struct arm_smmu_strtab_cfg {
@@ -851,6 +884,21 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd, struct arm_smmu_cmdq_ent *ent)
 		}
 		cmd[1] |= FIELD_PREP(CMDQ_PRI_1_RESP, ent->pri.resp);
 		break;
+	case CMDQ_OP_RESUME:
+		cmd[0] |= FIELD_PREP(CMDQ_RESUME_0_SID, ent->resume.sid);
+		cmd[1] |= FIELD_PREP(CMDQ_RESUME_1_STAG, ent->resume.stag);
+		switch (ent->resume.resp) {
+		case IOMMU_PAGE_RESP_INVALID:
+		case IOMMU_PAGE_RESP_FAILURE:
+			cmd[0] |= CMDQ_RESUME_0_ACTION_ABORT;
+			break;
+		case IOMMU_PAGE_RESP_SUCCESS:
+			cmd[0] |= CMDQ_RESUME_0_ACTION_RETRY;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
 	case CMDQ_OP_CMD_SYNC:
 		if (ent->sync.msiaddr)
 			cmd[0] |= FIELD_PREP(CMDQ_SYNC_0_CS, CMDQ_SYNC_0_CS_IRQ);
@@ -1013,6 +1061,34 @@ static void arm_smmu_cmdq_issue_sync(struct arm_smmu_device *smmu)
 		dev_err_ratelimited(smmu->dev, "CMD_SYNC timeout\n");
 }
 
+static int arm_smmu_page_response(struct device *dev,
+				  struct page_response_msg *resp)
+{
+	int sid = dev->iommu_fwspec->ids[0];
+	struct arm_smmu_cmdq_ent cmd = {0};
+	struct arm_smmu_master_data *master = dev->iommu_fwspec->iommu_priv;
+
+	if (master->ste.can_stall) {
+		cmd.opcode		= CMDQ_OP_RESUME;
+		cmd.resume.sid		= sid;
+		cmd.resume.stag		= resp->page_req_group_id;
+		cmd.resume.resp		= resp->resp_code;
+	} else {
+		/* TODO: put PRI response here */
+		return -ENODEV;
+	}
+
+	arm_smmu_cmdq_issue_cmd(master->smmu, &cmd);
+	/*
+	 * Don't send a SYNC, it doesn't do anything for RESUME or PRI_RESP.
+	 * RESUME consumption guarantees that the stalled transaction will be
+	 * terminated... at some point in the future. PRI_RESP is fire and
+	 * forget.
+	 */
+
+	return 0;
+}
+
 /* Stream table manipulation functions */
 static void
 arm_smmu_write_strtab_l1_desc(__le64 *dst, struct arm_smmu_strtab_l1_desc *desc)
@@ -1123,7 +1199,8 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 			 FIELD_PREP(STRTAB_STE_1_STRW, strw));
 
 		if (smmu->features & ARM_SMMU_FEAT_STALLS &&
-		   !(smmu->features & ARM_SMMU_FEAT_STALL_FORCE))
+		   !(smmu->features & ARM_SMMU_FEAT_STALL_FORCE) &&
+		   !ste->can_stall)
 			dst[1] |= cpu_to_le64(STRTAB_STE_1_S1STALLD);
 
 		val |= (ste->s1_cfg->tables.base & STRTAB_STE_0_S1CTXPTR_MASK) |
@@ -1196,7 +1273,6 @@ static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
 	return 0;
 }
 
-__maybe_unused
 static struct arm_smmu_master_data *
 arm_smmu_find_master(struct arm_smmu_device *smmu, u32 sid)
 {
@@ -1222,10 +1298,86 @@ arm_smmu_find_master(struct arm_smmu_device *smmu, u32 sid)
 	return master;
 }
 
+static int arm_smmu_handle_evt(struct arm_smmu_device *smmu, u64 *evt)
+{
+	int ret;
+	struct arm_smmu_master_data *master;
+	u8 type = FIELD_GET(EVTQ_0_ID, evt[0]);
+	u32 sid = FIELD_GET(EVTQ_0_SID, evt[0]);
+
+	struct iommu_fault_event fault = {
+		.page_req_group_id	= FIELD_GET(EVTQ_1_STAG, evt[1]),
+		.addr			= FIELD_GET(EVTQ_2_ADDR, evt[2]),
+		.last_req		= true,
+	};
+
+	switch (type) {
+	case EVT_ID_TRANSLATION_FAULT:
+	case EVT_ID_ADDR_SIZE_FAULT:
+	case EVT_ID_ACCESS_FAULT:
+		fault.reason = IOMMU_FAULT_REASON_PTE_FETCH;
+		break;
+	case EVT_ID_PERMISSION_FAULT:
+		fault.reason = IOMMU_FAULT_REASON_PERMISSION;
+		break;
+	default:
+		/* TODO: report other unrecoverable faults. */
+		return -EFAULT;
+	}
+
+	/* Stage-2 is always pinned at the moment */
+	if (evt[1] & EVTQ_1_S2)
+		return -EFAULT;
+
+	master = arm_smmu_find_master(smmu, sid);
+	if (!master)
+		return -EINVAL;
+
+	/*
+	 * The domain is valid until the fault returns, because detach() flushes
+	 * the fault queue.
+	 */
+	if (evt[1] & EVTQ_1_STALL)
+		fault.type = IOMMU_FAULT_PAGE_REQ;
+	else
+		fault.type = IOMMU_FAULT_DMA_UNRECOV;
+
+	if (evt[1] & EVTQ_1_READ)
+		fault.prot |= IOMMU_FAULT_READ;
+	else
+		fault.prot |= IOMMU_FAULT_WRITE;
+
+	if (evt[1] & EVTQ_1_EXEC)
+		fault.prot |= IOMMU_FAULT_EXEC;
+
+	if (evt[1] & EVTQ_1_PRIV)
+		fault.prot |= IOMMU_FAULT_PRIV;
+
+	if (evt[0] & EVTQ_0_SSV) {
+		fault.pasid_valid = true;
+		fault.pasid = FIELD_GET(EVTQ_0_SSID, evt[0]);
+	}
+
+	ret = iommu_report_device_fault(master->dev, &fault);
+	if (ret && fault.type == IOMMU_FAULT_PAGE_REQ) {
+		/* Nobody cared, abort the access */
+		struct page_response_msg resp = {
+			.addr			= fault.addr,
+			.pasid			= fault.pasid,
+			.pasid_present		= fault.pasid_valid,
+			.page_req_group_id	= fault.page_req_group_id,
+			.resp_code		= IOMMU_PAGE_RESP_FAILURE,
+		};
+		arm_smmu_page_response(master->dev, &resp);
+	}
+
+	return ret;
+}
+
 /* IRQ and event handlers */
 static irqreturn_t arm_smmu_evtq_thread(int irq, void *dev)
 {
-	int i;
+	int i, ret;
 	int num_handled = 0;
 	struct arm_smmu_device *smmu = dev;
 	struct arm_smmu_queue *q = &smmu->evtq.q;
@@ -1237,12 +1389,19 @@ static irqreturn_t arm_smmu_evtq_thread(int irq, void *dev)
 		while (!queue_remove_raw(q, evt)) {
 			u8 id = FIELD_GET(EVTQ_0_ID, evt[0]);
 
+			spin_unlock(&q->wq.lock);
+			ret = arm_smmu_handle_evt(smmu, evt);
+			spin_lock(&q->wq.lock);
+
 			if (++num_handled == queue_size) {
 				q->batch++;
 				wake_up_all_locked(&q->wq);
 				num_handled = 0;
 			}
 
+			if (!ret)
+				continue;
+
 			dev_info(smmu->dev, "event 0x%02x received:\n", id);
 			for (i = 0; i < ARRAY_SIZE(evt); ++i)
 				dev_info(smmu->dev, "\t0x%016llx\n",
@@ -1374,7 +1533,9 @@ static int arm_smmu_flush_queues(void *cookie, struct device *dev)
 
 	if (dev) {
 		master = dev->iommu_fwspec->iommu_priv;
-		/* TODO: add support for PRI and Stall */
+		if (master->ste.can_stall)
+			arm_smmu_flush_queue(smmu, &smmu->evtq.q, "evtq");
+		/* TODO: add support for PRI */
 		return 0;
 	}
 
@@ -1688,7 +1849,8 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 		.order			= master->ssid_bits,
 		.sync			= &arm_smmu_ctx_sync,
 		.arm_smmu = {
-			.stall		= !!(smmu->features & ARM_SMMU_FEAT_STALL_FORCE),
+			.stall		= !!(smmu->features & ARM_SMMU_FEAT_STALL_FORCE) ||
+					  master->ste.can_stall,
 			.asid_bits	= smmu->asid_bits,
 			.hw_access	= !!(smmu->features & ARM_SMMU_FEAT_HA),
 			.hw_dirty	= !!(smmu->features & ARM_SMMU_FEAT_HD),
@@ -2239,6 +2401,11 @@ static int arm_smmu_add_device(struct device *dev)
 
 	master->ssid_bits = min(smmu->ssid_bits, fwspec->num_pasid_bits);
 
+	if (fwspec->can_stall && smmu->features & ARM_SMMU_FEAT_STALLS) {
+		master->can_fault = true;
+		master->ste.can_stall = true;
+	}
+
 	ret = iommu_device_link(&smmu->iommu, dev);
 	if (ret)
 		goto err_free_master;
@@ -2403,6 +2570,7 @@ static struct iommu_ops arm_smmu_ops = {
 	.mm_attach		= arm_smmu_mm_attach,
 	.mm_detach		= arm_smmu_mm_detach,
 	.mm_invalidate		= arm_smmu_mm_invalidate,
+	.page_response		= arm_smmu_page_response,
 	.map			= arm_smmu_map,
 	.unmap			= arm_smmu_unmap,
 	.map_sg			= default_iommu_map_sg,
-- 
2.17.0
