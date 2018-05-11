Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA536B06B0
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:52 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id a14-v6so4387352otf.1
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s92-v6si1329568ota.441.2018.05.11.12.09.50
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:50 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 25/40] iommu/arm-smmu-v3: Add support for VHE
Date: Fri, 11 May 2018 20:06:26 +0100
Message-Id: <20180511190641.23008-26-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

ARMv8.1 extensions added Virtualization Host Extensions (VHE), which allow
to run a host kernel at EL2. When using normal DMA, Device and CPU address
spaces are dissociated, and do not need to implement the same
capabilities, so VHE hasn't been used in the SMMU until now.

With shared address spaces however, ASIDs are shared between MMU and SMMU,
and broadcast TLB invalidations issued by a CPU are taken into account by
the SMMU. TLB entries on both sides need to have identical exception level
in order to be cleared with a single invalidation.

When the CPU is using VHE, enable VHE in the SMMU for all STEs. Normal DMA
mappings will need to use TLBI_EL2 commands instead of TLBI_NH, but
shouldn't be otherwise affected by this change.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 16b08f2fb8ac..280a5d9be839 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -24,6 +24,7 @@
 #include <linux/acpi_iort.h>
 #include <linux/bitfield.h>
 #include <linux/bitops.h>
+#include <linux/cpufeature.h>
 #include <linux/delay.h>
 #include <linux/dma-iommu.h>
 #include <linux/err.h>
@@ -400,6 +401,8 @@ struct arm_smmu_cmdq_ent {
 		#define CMDQ_OP_TLBI_NH_ASID	0x11
 		#define CMDQ_OP_TLBI_NH_VA	0x12
 		#define CMDQ_OP_TLBI_EL2_ALL	0x20
+		#define CMDQ_OP_TLBI_EL2_ASID	0x21
+		#define CMDQ_OP_TLBI_EL2_VA	0x22
 		#define CMDQ_OP_TLBI_S12_VMALL	0x28
 		#define CMDQ_OP_TLBI_S2_IPA	0x2a
 		#define CMDQ_OP_TLBI_NSNH_ALL	0x30
@@ -519,6 +522,7 @@ struct arm_smmu_device {
 #define ARM_SMMU_FEAT_HYP		(1 << 12)
 #define ARM_SMMU_FEAT_STALL_FORCE	(1 << 13)
 #define ARM_SMMU_FEAT_VAX		(1 << 14)
+#define ARM_SMMU_FEAT_E2H		(1 << 15)
 	u32				features;
 
 #define ARM_SMMU_OPT_SKIP_PREFETCH	(1 << 0)
@@ -777,6 +781,7 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd, struct arm_smmu_cmdq_ent *ent)
 		cmd[1] |= FIELD_PREP(CMDQ_CFGI_1_RANGE, 31);
 		break;
 	case CMDQ_OP_TLBI_NH_VA:
+	case CMDQ_OP_TLBI_EL2_VA:
 		cmd[0] |= FIELD_PREP(CMDQ_TLBI_0_ASID, ent->tlbi.asid);
 		cmd[1] |= FIELD_PREP(CMDQ_TLBI_1_LEAF, ent->tlbi.leaf);
 		cmd[1] |= ent->tlbi.addr & CMDQ_TLBI_1_VA_MASK;
@@ -792,6 +797,9 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd, struct arm_smmu_cmdq_ent *ent)
 	case CMDQ_OP_TLBI_S12_VMALL:
 		cmd[0] |= FIELD_PREP(CMDQ_TLBI_0_VMID, ent->tlbi.vmid);
 		break;
+	case CMDQ_OP_TLBI_EL2_ASID:
+		cmd[0] |= FIELD_PREP(CMDQ_TLBI_0_ASID, ent->tlbi.asid);
+		break;
 	case CMDQ_OP_PRI_RESP:
 		cmd[0] |= FIELD_PREP(CMDQ_0_SSV, ent->substream_valid);
 		cmd[0] |= FIELD_PREP(CMDQ_PRI_0_SSID, ent->pri.ssid);
@@ -1064,6 +1072,8 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 
 	if (ste->s1_cfg) {
 		struct iommu_pasid_table_cfg *cfg = &ste->s1_cfg->tables;
+		int strw = smmu->features & ARM_SMMU_FEAT_E2H ?
+			STRTAB_STE_1_STRW_EL2 : STRTAB_STE_1_STRW_NSEL1;
 
 		BUG_ON(ste_live);
 		dst[1] = cpu_to_le64(
@@ -1074,7 +1084,7 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 #ifdef CONFIG_PCI_ATS
 			 FIELD_PREP(STRTAB_STE_1_EATS, STRTAB_STE_1_EATS_TRANS) |
 #endif
-			 FIELD_PREP(STRTAB_STE_1_STRW, STRTAB_STE_1_STRW_NSEL1));
+			 FIELD_PREP(STRTAB_STE_1_STRW, strw));
 
 		if (smmu->features & ARM_SMMU_FEAT_STALLS &&
 		   !(smmu->features & ARM_SMMU_FEAT_STALL_FORCE))
@@ -1325,7 +1335,8 @@ static void arm_smmu_tlb_inv_context(void *cookie)
 	if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
 		if (unlikely(!smmu_domain->s1_cfg.cd0))
 			return;
-		cmd.opcode	= CMDQ_OP_TLBI_NH_ASID;
+		cmd.opcode	= smmu->features & ARM_SMMU_FEAT_E2H ?
+				  CMDQ_OP_TLBI_EL2_ASID : CMDQ_OP_TLBI_NH_ASID;
 		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd0->tag;
 		cmd.tlbi.vmid	= 0;
 	} else {
@@ -1352,7 +1363,8 @@ static void arm_smmu_tlb_inv_range_nosync(unsigned long iova, size_t size,
 	if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
 		if (unlikely(!smmu_domain->s1_cfg.cd0))
 			return;
-		cmd.opcode	= CMDQ_OP_TLBI_NH_VA;
+		cmd.opcode	= smmu->features & ARM_SMMU_FEAT_E2H ?
+				  CMDQ_OP_TLBI_EL2_VA : CMDQ_OP_TLBI_NH_VA;
 		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd0->tag;
 	} else {
 		cmd.opcode	= CMDQ_OP_TLBI_S2_IPA;
@@ -1422,7 +1434,8 @@ static void arm_smmu_tlb_inv_ssid(void *cookie, int ssid,
 	struct arm_smmu_domain *smmu_domain = cookie;
 	struct arm_smmu_device *smmu = smmu_domain->smmu;
 	struct arm_smmu_cmdq_ent cmd = {
-		.opcode		= CMDQ_OP_TLBI_NH_ASID,
+		.opcode		= smmu->features & ARM_SMMU_FEAT_E2H ?
+				  CMDQ_OP_TLBI_EL2_ASID : CMDQ_OP_TLBI_NH_ASID,
 		.tlbi.asid	= entry->tag,
 	};
 
@@ -2446,7 +2459,11 @@ static int arm_smmu_device_reset(struct arm_smmu_device *smmu, bool bypass)
 	writel_relaxed(reg, smmu->base + ARM_SMMU_CR1);
 
 	/* CR2 (random crap) */
-	reg = CR2_PTM | CR2_RECINVSID | CR2_E2H;
+	reg = CR2_PTM | CR2_RECINVSID;
+
+	if (smmu->features & ARM_SMMU_FEAT_E2H)
+		reg |= CR2_E2H;
+
 	writel_relaxed(reg, smmu->base + ARM_SMMU_CR2);
 
 	/* Stream table */
@@ -2594,8 +2611,11 @@ static int arm_smmu_device_hw_probe(struct arm_smmu_device *smmu)
 	if (reg & IDR0_MSI)
 		smmu->features |= ARM_SMMU_FEAT_MSI;
 
-	if (reg & IDR0_HYP)
+	if (reg & IDR0_HYP) {
 		smmu->features |= ARM_SMMU_FEAT_HYP;
+		if (cpus_have_cap(ARM64_HAS_VIRT_HOST_EXTN))
+			smmu->features |= ARM_SMMU_FEAT_E2H;
+	}
 
 	/*
 	 * The coherency feature as set by FW is used in preference to the ID
-- 
2.17.0
