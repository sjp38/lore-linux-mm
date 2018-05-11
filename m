Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21BA66B06C4
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:48 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 37-v6so4379170otv.2
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v22-v6si1235391oth.410.2018.05.11.12.10.46
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:46 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 35/40] iommu/arm-smmu-v3: Add support for PCI ATS
Date: Fri, 11 May 2018 20:06:36 +0100
Message-Id: <20180511190641.23008-36-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

PCIe devices can implement their own TLB, named Address Translation Cache
(ATC). Enable Address Translation Service (ATS) for devices that support
it and send them invalidation requests whenever we invalidate the IOTLBs.

  Range calculation
  -----------------

The invalidation packet itself is a bit awkward: range must be naturally
aligned, which means that the start address is a multiple of the range
size. In addition, the size must be a power of two number of 4k pages. We
have a few options to enforce this constraint:

(1) Find the smallest naturally aligned region that covers the requested
    range. This is simple to compute and only takes one ATC_INV, but it
    will spill on lots of neighbouring ATC entries.

(2) Align the start address to the region size (rounded up to a power of
    two), and send a second invalidation for the next range of the same
    size. Still not great, but reduces spilling.

(3) Cover the range exactly with the smallest number of naturally aligned
    regions. This would be interesting to implement but as for (2),
    requires multiple ATC_INV.

As I suspect ATC invalidation packets will be a very scarce resource, I'll
go with option (1) for now, and only send one big invalidation. We can
move to (2), which is both easier to read and more gentle with the ATC,
once we've observed on real systems that we can send multiple smaller
Invalidation Requests for roughly the same price as a single big one.

Note that with io-pgtable, the unmap function is called for each page, so
this doesn't matter. The problem shows up when sharing page tables with
the MMU.

  Timeout
  -------

ATC invalidation is allowed to take up to 90 seconds, according to the
PCIe spec, so it is possible to hit the SMMU command queue timeout during
normal operations.

Some SMMU implementations will raise a CERROR_ATC_INV_SYNC when a CMD_SYNC
fails because of an ATC invalidation. Some will just abort the CMD_SYNC.
Others might let CMD_SYNC complete and have an asynchronous IMPDEF
mechanism to record the error. When we receive a CERROR_ATC_INV_SYNC, we
could retry sending all ATC_INV since last successful CMD_SYNC. When a
CMD_SYNC fails without CERROR_ATC_INV_SYNC, we could retry sending *all*
commands since last successful CMD_SYNC.

We cannot afford to wait 90 seconds in iommu_unmap, let alone MMU
notifiers. So we'd have to introduce a more clever system if this timeout
becomes a problem, like keeping hold of mappings and invalidating in the
background. Implementing safe delayed invalidations is a very complex
problem and deserves a series of its own. We'll assess whether more work
is needed to properly handle ATC invalidation timeouts once this code runs
on real hardware.

  Misc
  ----

I didn't put ATC and TLB invalidations in the same functions for three
reasons:

* TLB invalidation by range is batched and committed with a single sync.
  Batching ATC invalidation is inconvenient, endpoints limit the number of
  inflight invalidations. We'd have to count the number of invalidations
  queued and send a sync periodically. In addition, I suspect we always
  need a sync between TLB and ATC invalidation for the same page.

* Doing ATC invalidation outside tlb_inv_range also allows to send less
  requests, since TLB invalidations are done per page or block, while ATC
  invalidations target IOVA ranges.

* TLB invalidation by context is performed when freeing the domain, at
  which point there isn't any device attached anymore.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: display error if ats is supported but cannot be enabled
---
 drivers/iommu/arm-smmu-v3.c | 225 +++++++++++++++++++++++++++++++++++-
 1 file changed, 219 insertions(+), 6 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 8a6a799ba04a..7034b0bdcbdf 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -39,6 +39,7 @@
 #include <linux/of_iommu.h>
 #include <linux/of_platform.h>
 #include <linux/pci.h>
+#include <linux/pci-ats.h>
 #include <linux/platform_device.h>
 #include <linux/sched/mm.h>
 
@@ -103,6 +104,7 @@
 #define IDR5_VAX_52_BIT			1
 
 #define ARM_SMMU_CR0			0x20
+#define CR0_ATSCHK			(1 << 4)
 #define CR0_CMDQEN			(1 << 3)
 #define CR0_EVTQEN			(1 << 2)
 #define CR0_PRIQEN			(1 << 1)
@@ -277,6 +279,7 @@
 #define CMDQ_ERR_CERROR_NONE_IDX	0
 #define CMDQ_ERR_CERROR_ILL_IDX		1
 #define CMDQ_ERR_CERROR_ABT_IDX		2
+#define CMDQ_ERR_CERROR_ATC_INV_IDX	3
 
 #define CMDQ_0_OP			GENMASK_ULL(7, 0)
 #define CMDQ_0_SSV			(1UL << 11)
@@ -296,6 +299,12 @@
 #define CMDQ_TLBI_1_VA_MASK		GENMASK_ULL(63, 12)
 #define CMDQ_TLBI_1_IPA_MASK		GENMASK_ULL(51, 12)
 
+#define CMDQ_ATC_0_SSID			GENMASK_ULL(31, 12)
+#define CMDQ_ATC_0_SID			GENMASK_ULL(63, 32)
+#define CMDQ_ATC_0_GLOBAL		(1UL << 9)
+#define CMDQ_ATC_1_SIZE			GENMASK_ULL(5, 0)
+#define CMDQ_ATC_1_ADDR_MASK		GENMASK_ULL(63, 12)
+
 #define CMDQ_PRI_0_SSID			GENMASK_ULL(31, 12)
 #define CMDQ_PRI_0_SID			GENMASK_ULL(63, 32)
 #define CMDQ_PRI_1_GRPID		GENMASK_ULL(8, 0)
@@ -369,6 +378,11 @@ module_param_named(disable_bypass, disable_bypass, bool, S_IRUGO);
 MODULE_PARM_DESC(disable_bypass,
 	"Disable bypass streams such that incoming transactions from devices that are not attached to an iommu domain will report an abort back to the device and will not be allowed to pass through the SMMU.");
 
+static bool disable_ats_check;
+module_param_named(disable_ats_check, disable_ats_check, bool, S_IRUGO);
+MODULE_PARM_DESC(disable_ats_check,
+	"By default, the SMMU checks whether each incoming transaction marked as translated is allowed by the stream configuration. This option disables the check.");
+
 enum pri_resp {
 	PRI_RESP_DENY = 0,
 	PRI_RESP_FAIL = 1,
@@ -442,6 +456,16 @@ struct arm_smmu_cmdq_ent {
 			u64			addr;
 		} tlbi;
 
+		#define CMDQ_OP_ATC_INV		0x40
+		#define ATC_INV_SIZE_ALL	52
+		struct {
+			u32			sid;
+			u32			ssid;
+			u64			addr;
+			u8			size;
+			bool			global;
+		} atc;
+
 		#define CMDQ_OP_PRI_RESP	0x41
 		struct {
 			u32			sid;
@@ -869,6 +893,14 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd, struct arm_smmu_cmdq_ent *ent)
 	case CMDQ_OP_TLBI_EL2_ASID:
 		cmd[0] |= FIELD_PREP(CMDQ_TLBI_0_ASID, ent->tlbi.asid);
 		break;
+	case CMDQ_OP_ATC_INV:
+		cmd[0] |= FIELD_PREP(CMDQ_0_SSV, ent->substream_valid);
+		cmd[0] |= FIELD_PREP(CMDQ_ATC_0_GLOBAL, ent->atc.global);
+		cmd[0] |= FIELD_PREP(CMDQ_ATC_0_SSID, ent->atc.ssid);
+		cmd[0] |= FIELD_PREP(CMDQ_ATC_0_SID, ent->atc.sid);
+		cmd[1] |= FIELD_PREP(CMDQ_ATC_1_SIZE, ent->atc.size);
+		cmd[1] |= ent->atc.addr & CMDQ_ATC_1_ADDR_MASK;
+		break;
 	case CMDQ_OP_PRI_RESP:
 		cmd[0] |= FIELD_PREP(CMDQ_0_SSV, ent->substream_valid);
 		cmd[0] |= FIELD_PREP(CMDQ_PRI_0_SSID, ent->pri.ssid);
@@ -922,6 +954,7 @@ static void arm_smmu_cmdq_skip_err(struct arm_smmu_device *smmu)
 		[CMDQ_ERR_CERROR_NONE_IDX]	= "No error",
 		[CMDQ_ERR_CERROR_ILL_IDX]	= "Illegal command",
 		[CMDQ_ERR_CERROR_ABT_IDX]	= "Abort on command fetch",
+		[CMDQ_ERR_CERROR_ATC_INV_IDX]	= "ATC invalidate timeout",
 	};
 
 	int i;
@@ -941,6 +974,14 @@ static void arm_smmu_cmdq_skip_err(struct arm_smmu_device *smmu)
 		dev_err(smmu->dev, "retrying command fetch\n");
 	case CMDQ_ERR_CERROR_NONE_IDX:
 		return;
+	case CMDQ_ERR_CERROR_ATC_INV_IDX:
+		/*
+		 * ATC Invalidation Completion timeout. CONS is still pointing
+		 * at the CMD_SYNC. Attempt to complete other pending commands
+		 * by repeating the CMD_SYNC, though we might well end up back
+		 * here since the ATC invalidation may still be pending.
+		 */
+		return;
 	case CMDQ_ERR_CERROR_ILL_IDX:
 		/* Fallthrough */
 	default:
@@ -1193,9 +1234,6 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 			 FIELD_PREP(STRTAB_STE_1_S1CIR, STRTAB_STE_1_S1C_CACHE_WBRA) |
 			 FIELD_PREP(STRTAB_STE_1_S1COR, STRTAB_STE_1_S1C_CACHE_WBRA) |
 			 FIELD_PREP(STRTAB_STE_1_S1CSH, ARM_SMMU_SH_ISH) |
-#ifdef CONFIG_PCI_ATS
-			 FIELD_PREP(STRTAB_STE_1_EATS, STRTAB_STE_1_EATS_TRANS) |
-#endif
 			 FIELD_PREP(STRTAB_STE_1_STRW, strw));
 
 		if (smmu->features & ARM_SMMU_FEAT_STALLS &&
@@ -1225,6 +1263,10 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 		val |= FIELD_PREP(STRTAB_STE_0_CFG, STRTAB_STE_0_CFG_S2_TRANS);
 	}
 
+	if (IS_ENABLED(CONFIG_PCI_ATS))
+		dst[1] |= cpu_to_le64(FIELD_PREP(STRTAB_STE_1_EATS,
+						 STRTAB_STE_1_EATS_TRANS));
+
 	arm_smmu_sync_ste_for_sid(smmu, sid);
 	dst[0] = cpu_to_le64(val);
 	arm_smmu_sync_ste_for_sid(smmu, sid);
@@ -1613,6 +1655,104 @@ static irqreturn_t arm_smmu_combined_irq_handler(int irq, void *dev)
 	return IRQ_WAKE_THREAD;
 }
 
+/* ATS invalidation */
+static bool arm_smmu_master_has_ats(struct arm_smmu_master_data *master)
+{
+	return dev_is_pci(master->dev) && to_pci_dev(master->dev)->ats_enabled;
+}
+
+static void
+arm_smmu_atc_inv_to_cmd(int ssid, unsigned long iova, size_t size,
+			struct arm_smmu_cmdq_ent *cmd)
+{
+	size_t log2_span;
+	size_t span_mask;
+	/* ATC invalidates are always on 4096 bytes pages */
+	size_t inval_grain_shift = 12;
+	unsigned long page_start, page_end;
+
+	*cmd = (struct arm_smmu_cmdq_ent) {
+		.opcode			= CMDQ_OP_ATC_INV,
+		.substream_valid	= !!ssid,
+		.atc.ssid		= ssid,
+	};
+
+	if (!size) {
+		cmd->atc.size = ATC_INV_SIZE_ALL;
+		return;
+	}
+
+	page_start	= iova >> inval_grain_shift;
+	page_end	= (iova + size - 1) >> inval_grain_shift;
+
+	/*
+	 * Find the smallest power of two that covers the range. Most
+	 * significant differing bit between start and end address indicates the
+	 * required span, ie. fls(start ^ end). For example:
+	 *
+	 * We want to invalidate pages [8; 11]. This is already the ideal range:
+	 *		x = 0b1000 ^ 0b1011 = 0b11
+	 *		span = 1 << fls(x) = 4
+	 *
+	 * To invalidate pages [7; 10], we need to invalidate [0; 15]:
+	 *		x = 0b0111 ^ 0b1010 = 0b1101
+	 *		span = 1 << fls(x) = 16
+	 */
+	log2_span	= fls_long(page_start ^ page_end);
+	span_mask	= (1ULL << log2_span) - 1;
+
+	page_start	&= ~span_mask;
+
+	cmd->atc.addr	= page_start << inval_grain_shift;
+	cmd->atc.size	= log2_span;
+}
+
+static int arm_smmu_atc_inv_master(struct arm_smmu_master_data *master,
+				   struct arm_smmu_cmdq_ent *cmd)
+{
+	int i;
+	struct iommu_fwspec *fwspec = master->dev->iommu_fwspec;
+
+	if (!arm_smmu_master_has_ats(master))
+		return 0;
+
+	for (i = 0; i < fwspec->num_ids; i++) {
+		cmd->atc.sid = fwspec->ids[i];
+		arm_smmu_cmdq_issue_cmd(master->smmu, cmd);
+	}
+
+	arm_smmu_cmdq_issue_sync(master->smmu);
+
+	return 0;
+}
+
+static int arm_smmu_atc_inv_master_all(struct arm_smmu_master_data *master,
+				       int ssid)
+{
+	struct arm_smmu_cmdq_ent cmd;
+
+	arm_smmu_atc_inv_to_cmd(ssid, 0, 0, &cmd);
+	return arm_smmu_atc_inv_master(master, &cmd);
+}
+
+static size_t
+arm_smmu_atc_inv_domain(struct arm_smmu_domain *smmu_domain, int ssid,
+			unsigned long iova, size_t size)
+{
+	unsigned long flags;
+	struct arm_smmu_cmdq_ent cmd;
+	struct arm_smmu_master_data *master;
+
+	arm_smmu_atc_inv_to_cmd(ssid, iova, size, &cmd);
+
+	spin_lock_irqsave(&smmu_domain->devices_lock, flags);
+	list_for_each_entry(master, &smmu_domain->devices, list)
+		arm_smmu_atc_inv_master(master, &cmd);
+	spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
+
+	return size;
+}
+
 /* IO_PGTABLE API */
 static void __arm_smmu_tlb_sync(struct arm_smmu_device *smmu)
 {
@@ -2026,6 +2166,8 @@ static void arm_smmu_detach_dev(struct device *dev)
 	if (smmu_domain) {
 		__iommu_sva_unbind_dev_all(dev);
 
+		arm_smmu_atc_inv_master_all(master, 0);
+
 		spin_lock_irqsave(&smmu_domain->devices_lock, flags);
 		list_del(&master->list);
 		spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
@@ -2113,12 +2255,19 @@ static int arm_smmu_map(struct iommu_domain *domain, unsigned long iova,
 static size_t
 arm_smmu_unmap(struct iommu_domain *domain, unsigned long iova, size_t size)
 {
-	struct io_pgtable_ops *ops = to_smmu_domain(domain)->pgtbl_ops;
+	int ret;
+	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
+	struct io_pgtable_ops *ops = smmu_domain->pgtbl_ops;
 
 	if (!ops)
 		return 0;
 
-	return ops->unmap(ops, iova, size);
+	ret = ops->unmap(ops, iova, size);
+
+	if (ret && smmu_domain->smmu->features & ARM_SMMU_FEAT_ATS)
+		ret = arm_smmu_atc_inv_domain(smmu_domain, 0, iova, size);
+
+	return ret;
 }
 
 static void arm_smmu_iotlb_sync(struct iommu_domain *domain)
@@ -2284,6 +2433,54 @@ static bool arm_smmu_sid_in_range(struct arm_smmu_device *smmu, u32 sid)
 	return sid < limit;
 }
 
+static int arm_smmu_enable_ats(struct arm_smmu_master_data *master)
+{
+	size_t stu;
+	int ret, pos;
+	struct pci_dev *pdev;
+	struct arm_smmu_device *smmu = master->smmu;
+	struct iommu_fwspec *fwspec = master->dev->iommu_fwspec;
+
+	if (!(smmu->features & ARM_SMMU_FEAT_ATS) || !dev_is_pci(master->dev) ||
+	    (fwspec->flags & IOMMU_FWSPEC_PCI_NO_ATS))
+		return -ENOSYS;
+
+	pdev = to_pci_dev(master->dev);
+
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ATS);
+	if (!pos)
+		return -ENOSYS;
+
+	/* Smallest Translation Unit: log2 of the smallest supported granule */
+	stu = __ffs(smmu->pgsize_bitmap);
+
+	ret = pci_enable_ats(pdev, stu);
+	if (ret) {
+		dev_err(&pdev->dev, "could not enable ATS: %d\n", ret);
+		return ret;
+	}
+
+	dev_dbg(&pdev->dev, "enabled ATS (STU=%zu, QDEP=%d)\n", stu,
+		pci_ats_queue_depth(pdev));
+
+	return 0;
+}
+
+static void arm_smmu_disable_ats(struct arm_smmu_master_data *master)
+{
+	struct pci_dev *pdev;
+
+	if (!dev_is_pci(master->dev))
+		return;
+
+	pdev = to_pci_dev(master->dev);
+
+	if (!pdev->ats_enabled)
+		return;
+
+	pci_disable_ats(pdev);
+}
+
 static int arm_smmu_insert_master(struct arm_smmu_device *smmu,
 				  struct arm_smmu_master_data *master)
 {
@@ -2406,9 +2603,11 @@ static int arm_smmu_add_device(struct device *dev)
 		master->ste.can_stall = true;
 	}
 
+	arm_smmu_enable_ats(master);
+
 	ret = iommu_device_link(&smmu->iommu, dev);
 	if (ret)
-		goto err_free_master;
+		goto err_disable_ats;
 
 	ret = arm_smmu_insert_master(smmu, master);
 	if (ret)
@@ -2430,6 +2629,9 @@ static int arm_smmu_add_device(struct device *dev)
 err_unlink:
 	iommu_device_unlink(&smmu->iommu, dev);
 
+err_disable_ats:
+	arm_smmu_disable_ats(master);
+
 err_free_master:
 	kfree(master);
 	fwspec->iommu_priv = NULL;
@@ -2457,6 +2659,7 @@ static void arm_smmu_remove_device(struct device *dev)
 	iommu_group_remove_device(dev);
 	arm_smmu_remove_master(smmu, master);
 	iommu_device_unlink(&smmu->iommu, dev);
+	arm_smmu_disable_ats(master);
 	kfree(master);
 	iommu_fwspec_free(dev);
 }
@@ -3069,6 +3272,16 @@ static int arm_smmu_device_reset(struct arm_smmu_device *smmu, bool bypass)
 		}
 	}
 
+	if (smmu->features & ARM_SMMU_FEAT_ATS && !disable_ats_check) {
+		enables |= CR0_ATSCHK;
+		ret = arm_smmu_write_reg_sync(smmu, enables, ARM_SMMU_CR0,
+					      ARM_SMMU_CR0ACK);
+		if (ret) {
+			dev_err(smmu->dev, "failed to enable ATS check\n");
+			return ret;
+		}
+	}
+
 	ret = arm_smmu_setup_irqs(smmu);
 	if (ret) {
 		dev_err(smmu->dev, "failed to setup irqs\n");
-- 
2.17.0
