Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23526B06B6
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:13 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k136-v6so3492816oih.4
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t32-v6si1396630oti.338.2018.05.11.12.10.12
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:12 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 29/40] iommu/arm-smmu-v3: Add support for Hardware Translation Table Update
Date: Fri, 11 May 2018 20:06:30 +0100
Message-Id: <20180511190641.23008-30-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

If the SMMU supports it and the kernel was built with HTTU support, enable
hardware update of access and dirty flags. This is essential for shared
page tables, to reduce the number of access faults on the fault queue.

We can enable HTTU even if CPUs don't support it, because the kernel
always checks for HW dirty bit and updates the PTE flags atomically.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3-context.c | 16 ++++++++++++++--
 drivers/iommu/arm-smmu-v3.c         | 12 ++++++++++++
 drivers/iommu/iommu-pasid-table.h   |  4 ++++
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3-context.c b/drivers/iommu/arm-smmu-v3-context.c
index 0e12f6804e16..bdc9bfd1f35d 100644
--- a/drivers/iommu/arm-smmu-v3-context.c
+++ b/drivers/iommu/arm-smmu-v3-context.c
@@ -52,6 +52,11 @@
 #define CTXDESC_CD_0_TCR_TBI0		(1ULL << 38)
 #define ARM64_TCR_TBI0			(1ULL << 37)
 
+#define CTXDESC_CD_0_TCR_HA		(1UL << 43)
+#define ARM64_TCR_HA			(1ULL << 39)
+#define CTXDESC_CD_0_TCR_HD		(1UL << 42)
+#define ARM64_TCR_HD			(1ULL << 40)
+
 #define CTXDESC_CD_0_AA64		(1UL << 41)
 #define CTXDESC_CD_0_S			(1UL << 44)
 #define CTXDESC_CD_0_R			(1UL << 45)
@@ -182,7 +187,7 @@ static __le64 *arm_smmu_get_cd_ptr(struct arm_smmu_cd_tables *tbl, u32 ssid)
 	return l1_desc->ptr + idx * CTXDESC_CD_DWORDS;
 }
 
-static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
+static u64 arm_smmu_cpu_tcr_to_cd(struct arm_smmu_context_cfg *cfg, u64 tcr)
 {
 	u64 val = 0;
 
@@ -197,6 +202,12 @@ static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
 	val |= ARM_SMMU_TCR2CD(tcr, IPS);
 	val |= ARM_SMMU_TCR2CD(tcr, TBI0);
 
+	if (cfg->hw_access)
+		val |= ARM_SMMU_TCR2CD(tcr, HA);
+
+	if (cfg->hw_dirty)
+		val |= ARM_SMMU_TCR2CD(tcr, HD);
+
 	return val;
 }
 
@@ -250,7 +261,7 @@ static int __arm_smmu_write_ctx_desc(struct arm_smmu_cd_tables *tbl, int ssid,
 		iommu_pasid_flush(&tbl->pasid, ssid, true);
 
 
-		val = arm_smmu_cpu_tcr_to_cd(cd->tcr) |
+		val = arm_smmu_cpu_tcr_to_cd(cfg, cd->tcr) |
 #ifdef __BIG_ENDIAN
 		      CTXDESC_CD_0_ENDI |
 #endif
@@ -455,6 +466,7 @@ arm_smmu_alloc_shared_cd(struct iommu_pasid_table_ops *ops, struct mm_struct *mm
 	reg = read_sanitised_ftr_reg(SYS_ID_AA64MMFR0_EL1);
 	par = cpuid_feature_extract_unsigned_field(reg, ID_AA64MMFR0_PARANGE_SHIFT);
 	tcr |= par << ARM_LPAE_TCR_IPS_SHIFT;
+	tcr |= TCR_HA | TCR_HD;
 
 	cd->ttbr	= virt_to_phys(mm->pgd);
 	cd->tcr		= tcr;
diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index c2c96025ac3b..7c839d305d97 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -66,6 +66,8 @@
 #define IDR0_ASID16			(1 << 12)
 #define IDR0_ATS			(1 << 10)
 #define IDR0_HYP			(1 << 9)
+#define IDR0_HD				(1 << 7)
+#define IDR0_HA				(1 << 6)
 #define IDR0_BTM			(1 << 5)
 #define IDR0_COHACC			(1 << 4)
 #define IDR0_TTF			GENMASK(3, 2)
@@ -528,6 +530,8 @@ struct arm_smmu_device {
 #define ARM_SMMU_FEAT_E2H		(1 << 15)
 #define ARM_SMMU_FEAT_BTM		(1 << 16)
 #define ARM_SMMU_FEAT_SVA		(1 << 17)
+#define ARM_SMMU_FEAT_HA		(1 << 18)
+#define ARM_SMMU_FEAT_HD		(1 << 19)
 	u32				features;
 
 #define ARM_SMMU_OPT_SKIP_PREFETCH	(1 << 0)
@@ -1567,6 +1571,8 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 		.arm_smmu = {
 			.stall		= !!(smmu->features & ARM_SMMU_FEAT_STALL_FORCE),
 			.asid_bits	= smmu->asid_bits,
+			.hw_access	= !!(smmu->features & ARM_SMMU_FEAT_HA),
+			.hw_dirty	= !!(smmu->features & ARM_SMMU_FEAT_HD),
 		},
 	};
 
@@ -2818,6 +2824,12 @@ static int arm_smmu_device_hw_probe(struct arm_smmu_device *smmu)
 			smmu->features |= ARM_SMMU_FEAT_E2H;
 	}
 
+	if (reg & (IDR0_HA | IDR0_HD)) {
+		smmu->features |= ARM_SMMU_FEAT_HA;
+		if (reg & IDR0_HD)
+			smmu->features |= ARM_SMMU_FEAT_HD;
+	}
+
 	/*
 	 * If the CPU is using VHE, but the SMMU doesn't support it, the SMMU
 	 * will create TLB entries for NH-EL1 world and will miss the
diff --git a/drivers/iommu/iommu-pasid-table.h b/drivers/iommu/iommu-pasid-table.h
index b84709e297bc..a7243579a4cb 100644
--- a/drivers/iommu/iommu-pasid-table.h
+++ b/drivers/iommu/iommu-pasid-table.h
@@ -78,12 +78,16 @@ struct iommu_pasid_sync_ops {
  * SMMU properties:
  * @stall: devices attached to the domain are allowed to stall.
  * @asid_bits: number of ASID bits supported by the SMMU
+ * @hw_dirty: hardware may update dirty flag
+ * @hw_access: hardware may update access flag
  *
  * @s1fmt: PASID table format, chosen by the allocator.
  */
 struct arm_smmu_context_cfg {
 	u8				stall:1;
 	u8				asid_bits;
+	u8				hw_dirty:1;
+	u8				hw_access:1;
 
 #define ARM_SMMU_S1FMT_LINEAR		0x0
 #define ARM_SMMU_S1FMT_4K_L2		0x1
-- 
2.17.0
