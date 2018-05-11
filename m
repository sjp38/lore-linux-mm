Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61E516B06A8
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:25 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id y49-v6so4296856oti.11
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:25 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w16-v6si1395708oti.389.2018.05.11.12.09.23
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:23 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 20/40] iommu/arm-smmu-v3: Move context descriptor code
Date: Fri, 11 May 2018 20:06:21 +0100
Message-Id: <20180511190641.23008-21-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

In preparation for substream ID support, move the context descriptor code
into a separate module. At the moment it only manages context descriptor
zero, which is used for non-PASID translations.

One important behavior change is the ASID allocator, which is now global
instead of per-SMMU. If we end up needing per-SMMU ASIDs after all, it
would be relatively simple to move back to per-device allocator instead
of a global one. Sharing ASIDs will require an IDR, so implement the
ASID allocator with an IDA instead of porting the bitmap, to ease the
transition.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: try to simplify
---
 MAINTAINERS                         |   3 +-
 drivers/iommu/Kconfig               |  11 ++
 drivers/iommu/Makefile              |   1 +
 drivers/iommu/arm-smmu-v3-context.c | 257 ++++++++++++++++++++++++++++
 drivers/iommu/arm-smmu-v3.c         | 191 +++++++--------------
 drivers/iommu/iommu-pasid-table.c   |   1 +
 drivers/iommu/iommu-pasid-table.h   |  20 +++
 7 files changed, 355 insertions(+), 129 deletions(-)
 create mode 100644 drivers/iommu/arm-smmu-v3-context.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 9b996a94e460..c08c0c71a568 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1112,8 +1112,7 @@ M:	Will Deacon <will.deacon@arm.com>
 R:	Robin Murphy <robin.murphy@arm.com>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 S:	Maintained
-F:	drivers/iommu/arm-smmu.c
-F:	drivers/iommu/arm-smmu-v3.c
+F:	drivers/iommu/arm-smmu*
 F:	drivers/iommu/io-pgtable-arm*
 
 ARM SUB-ARCHITECTURES
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index fae34d6a522d..11c8492b3763 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -65,6 +65,16 @@ menu "Generic PASID table support"
 config IOMMU_PASID_TABLE
 	bool
 
+config ARM_SMMU_V3_CONTEXT
+	bool "ARM SMMU v3 Context Descriptor tables"
+	select IOMMU_PASID_TABLE
+	depends on ARM64
+	help
+	  Enable support for ARM SMMU v3 Context Descriptor tables, used for
+	  DMA and PASID support.
+
+	  If unsure, say N here.
+
 endmenu
 
 config IOMMU_IOVA
@@ -334,6 +344,7 @@ config ARM_SMMU_V3
 	depends on ARM64
 	select IOMMU_API
 	select IOMMU_IO_PGTABLE_LPAE
+	select ARM_SMMU_V3_CONTEXT
 	select GENERIC_MSI_IRQ_DOMAIN
 	help
 	  Support for implementations of the ARM System MMU architecture
diff --git a/drivers/iommu/Makefile b/drivers/iommu/Makefile
index 8e335a7f10aa..244ad7913a81 100644
--- a/drivers/iommu/Makefile
+++ b/drivers/iommu/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_IOMMU_IO_PGTABLE) += io-pgtable.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_ARMV7S) += io-pgtable-arm-v7s.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_LPAE) += io-pgtable-arm.o
 obj-$(CONFIG_IOMMU_PASID_TABLE) += iommu-pasid-table.o
+obj-$(CONFIG_ARM_SMMU_V3_CONTEXT) += arm-smmu-v3-context.o
 obj-$(CONFIG_IOMMU_IOVA) += iova.o
 obj-$(CONFIG_OF_IOMMU)	+= of_iommu.o
 obj-$(CONFIG_MSM_IOMMU) += msm_iommu.o
diff --git a/drivers/iommu/arm-smmu-v3-context.c b/drivers/iommu/arm-smmu-v3-context.c
new file mode 100644
index 000000000000..15d3d02c59b2
--- /dev/null
+++ b/drivers/iommu/arm-smmu-v3-context.c
@@ -0,0 +1,257 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Context descriptor table driver for SMMUv3
+ *
+ * Copyright (C) 2018 ARM Ltd.
+ */
+
+#include <linux/bitfield.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/idr.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+#include "iommu-pasid-table.h"
+
+#define CTXDESC_CD_DWORDS		8
+#define CTXDESC_CD_0_TCR_T0SZ		GENMASK_ULL(5, 0)
+#define ARM64_TCR_T0SZ			GENMASK_ULL(5, 0)
+#define CTXDESC_CD_0_TCR_TG0		GENMASK_ULL(7, 6)
+#define ARM64_TCR_TG0			GENMASK_ULL(15, 14)
+#define CTXDESC_CD_0_TCR_IRGN0		GENMASK_ULL(9, 8)
+#define ARM64_TCR_IRGN0			GENMASK_ULL(9, 8)
+#define CTXDESC_CD_0_TCR_ORGN0		GENMASK_ULL(11, 10)
+#define ARM64_TCR_ORGN0			GENMASK_ULL(11, 10)
+#define CTXDESC_CD_0_TCR_SH0		GENMASK_ULL(13, 12)
+#define ARM64_TCR_SH0			GENMASK_ULL(13, 12)
+#define CTXDESC_CD_0_TCR_EPD0		(1ULL << 14)
+#define ARM64_TCR_EPD0			(1ULL << 7)
+#define CTXDESC_CD_0_TCR_EPD1		(1ULL << 30)
+#define ARM64_TCR_EPD1			(1ULL << 23)
+
+#define CTXDESC_CD_0_ENDI		(1UL << 15)
+#define CTXDESC_CD_0_V			(1UL << 31)
+
+#define CTXDESC_CD_0_TCR_IPS		GENMASK_ULL(34, 32)
+#define ARM64_TCR_IPS			GENMASK_ULL(34, 32)
+#define CTXDESC_CD_0_TCR_TBI0		(1ULL << 38)
+#define ARM64_TCR_TBI0			(1ULL << 37)
+
+#define CTXDESC_CD_0_AA64		(1UL << 41)
+#define CTXDESC_CD_0_S			(1UL << 44)
+#define CTXDESC_CD_0_R			(1UL << 45)
+#define CTXDESC_CD_0_A			(1UL << 46)
+#define CTXDESC_CD_0_ASET		(1UL << 47)
+#define CTXDESC_CD_0_ASID		GENMASK_ULL(63, 48)
+
+#define CTXDESC_CD_1_TTB0_MASK		GENMASK_ULL(51, 4)
+
+/* Convert between AArch64 (CPU) TCR format and SMMU CD format */
+#define ARM_SMMU_TCR2CD(tcr, fld)	FIELD_PREP(CTXDESC_CD_0_TCR_##fld, \
+					FIELD_GET(ARM64_TCR_##fld, tcr))
+
+struct arm_smmu_cd {
+	struct iommu_pasid_entry	entry;
+
+	u64				ttbr;
+	u64				tcr;
+	u64				mair;
+};
+
+#define pasid_entry_to_cd(entry) \
+	container_of((entry), struct arm_smmu_cd, entry)
+
+struct arm_smmu_cd_tables {
+	struct iommu_pasid_table	pasid;
+
+	void				*ptr;
+	dma_addr_t			ptr_dma;
+};
+
+#define pasid_to_cd_tables(pasid_table) \
+	container_of((pasid_table), struct arm_smmu_cd_tables, pasid)
+
+#define pasid_ops_to_tables(ops) \
+	pasid_to_cd_tables(iommu_pasid_table_ops_to_table(ops))
+
+static DEFINE_IDA(asid_ida);
+
+static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
+{
+	u64 val = 0;
+
+	/* Repack the TCR. Just care about TTBR0 for now */
+	val |= ARM_SMMU_TCR2CD(tcr, T0SZ);
+	val |= ARM_SMMU_TCR2CD(tcr, TG0);
+	val |= ARM_SMMU_TCR2CD(tcr, IRGN0);
+	val |= ARM_SMMU_TCR2CD(tcr, ORGN0);
+	val |= ARM_SMMU_TCR2CD(tcr, SH0);
+	val |= ARM_SMMU_TCR2CD(tcr, EPD0);
+	val |= ARM_SMMU_TCR2CD(tcr, EPD1);
+	val |= ARM_SMMU_TCR2CD(tcr, IPS);
+	val |= ARM_SMMU_TCR2CD(tcr, TBI0);
+
+	return val;
+}
+
+static void arm_smmu_write_ctx_desc(struct arm_smmu_cd_tables *tbl,
+				    struct arm_smmu_cd *cd)
+{
+	u64 val;
+	__u64 *cdptr = tbl->ptr;
+	struct arm_smmu_context_cfg *cfg = &tbl->pasid.cfg.arm_smmu;
+
+	/*
+	 * We don't need to issue any invalidation here, as we'll invalidate
+	 * the STE when installing the new entry anyway.
+	 */
+	val = arm_smmu_cpu_tcr_to_cd(cd->tcr) |
+#ifdef __BIG_ENDIAN
+	      CTXDESC_CD_0_ENDI |
+#endif
+	      CTXDESC_CD_0_R | CTXDESC_CD_0_A | CTXDESC_CD_0_ASET |
+	      CTXDESC_CD_0_AA64 | FIELD_PREP(CTXDESC_CD_0_ASID, cd->entry.tag) |
+	      CTXDESC_CD_0_V;
+
+	if (cfg->stall)
+		val |= CTXDESC_CD_0_S;
+
+	cdptr[0] = cpu_to_le64(val);
+
+	val = cd->ttbr & CTXDESC_CD_1_TTB0_MASK;
+	cdptr[1] = cpu_to_le64(val);
+
+	cdptr[3] = cpu_to_le64(cd->mair);
+}
+
+static void arm_smmu_free_cd(struct iommu_pasid_entry *entry)
+{
+	struct arm_smmu_cd *cd = pasid_entry_to_cd(entry);
+
+	ida_simple_remove(&asid_ida, (u16)entry->tag);
+	kfree(cd);
+}
+
+static struct iommu_pasid_entry *
+arm_smmu_alloc_shared_cd(struct iommu_pasid_table_ops *ops, struct mm_struct *mm)
+{
+	return ERR_PTR(-ENODEV);
+}
+
+static struct iommu_pasid_entry *
+arm_smmu_alloc_priv_cd(struct iommu_pasid_table_ops *ops,
+		       enum io_pgtable_fmt fmt,
+		       struct io_pgtable_cfg *cfg)
+{
+	int ret;
+	int asid;
+	struct arm_smmu_cd *cd;
+	struct arm_smmu_cd_tables *tbl = pasid_ops_to_tables(ops);
+	struct arm_smmu_context_cfg *ctx_cfg = &tbl->pasid.cfg.arm_smmu;
+
+	cd = kzalloc(sizeof(*cd), GFP_KERNEL);
+	if (!cd)
+		return ERR_PTR(-ENOMEM);
+
+	asid = ida_simple_get(&asid_ida, 0, 1 << ctx_cfg->asid_bits,
+			      GFP_KERNEL);
+	if (asid < 0) {
+		kfree(cd);
+		return ERR_PTR(asid);
+	}
+
+	cd->entry.tag = asid;
+	cd->entry.release = arm_smmu_free_cd;
+
+	switch (fmt) {
+	case ARM_64_LPAE_S1:
+		cd->ttbr	= cfg->arm_lpae_s1_cfg.ttbr[0];
+		cd->tcr		= cfg->arm_lpae_s1_cfg.tcr;
+		cd->mair	= cfg->arm_lpae_s1_cfg.mair[0];
+		break;
+	default:
+		pr_err("Unsupported pgtable format 0x%x\n", fmt);
+		ret = -EINVAL;
+		goto err_free_cd;
+	}
+
+	return &cd->entry;
+
+err_free_cd:
+	arm_smmu_free_cd(&cd->entry);
+
+	return ERR_PTR(ret);
+}
+
+static int arm_smmu_set_cd(struct iommu_pasid_table_ops *ops, int pasid,
+			   struct iommu_pasid_entry *entry)
+{
+	struct arm_smmu_cd_tables *tbl = pasid_ops_to_tables(ops);
+	struct arm_smmu_cd *cd = pasid_entry_to_cd(entry);
+
+	arm_smmu_write_ctx_desc(tbl, cd);
+	return 0;
+}
+
+static void arm_smmu_clear_cd(struct iommu_pasid_table_ops *ops, int pasid,
+			      struct iommu_pasid_entry *entry)
+{
+	struct arm_smmu_cd_tables *tbl = pasid_ops_to_tables(ops);
+
+	arm_smmu_write_ctx_desc(tbl, NULL);
+}
+
+static struct iommu_pasid_table *
+arm_smmu_alloc_cd_tables(struct iommu_pasid_table_cfg *cfg, void *cookie)
+{
+	struct arm_smmu_cd_tables *tbl;
+	struct device *dev = cfg->iommu_dev;
+
+	if (cfg->order) {
+		/* TODO: support SSID */
+		return NULL;
+	}
+
+	tbl = devm_kzalloc(dev, sizeof(*tbl), GFP_KERNEL);
+	if (!tbl)
+		return NULL;
+
+	tbl->ptr = dmam_alloc_coherent(dev, CTXDESC_CD_DWORDS << 3,
+				       &tbl->ptr_dma, GFP_KERNEL | __GFP_ZERO);
+	if (!tbl->ptr) {
+		dev_warn(dev, "failed to allocate context descriptor\n");
+		goto err_free_tbl;
+	}
+
+	tbl->pasid.ops = (struct iommu_pasid_table_ops) {
+		.alloc_priv_entry	= arm_smmu_alloc_priv_cd,
+		.alloc_shared_entry	= arm_smmu_alloc_shared_cd,
+		.set_entry		= arm_smmu_set_cd,
+		.clear_entry		= arm_smmu_clear_cd,
+	};
+	cfg->base = tbl->ptr_dma;
+
+	return &tbl->pasid;
+
+err_free_tbl:
+	devm_kfree(dev, tbl);
+
+	return NULL;
+}
+
+static void arm_smmu_free_cd_tables(struct iommu_pasid_table *pasid_table)
+{
+	struct iommu_pasid_table_cfg *cfg = &pasid_table->cfg;
+	struct device *dev = cfg->iommu_dev;
+	struct arm_smmu_cd_tables *tbl = pasid_to_cd_tables(pasid_table);
+
+	dmam_free_coherent(dev, CTXDESC_CD_DWORDS << 3,
+			   tbl->ptr, tbl->ptr_dma);
+	devm_kfree(dev, tbl);
+}
+
+struct iommu_pasid_init_fns arm_smmu_v3_pasid_init_fns = {
+	.alloc	= arm_smmu_alloc_cd_tables,
+	.free	= arm_smmu_free_cd_tables,
+};
diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index c892f012fb43..68764a200e44 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -42,6 +42,7 @@
 #include <linux/amba/bus.h>
 
 #include "io-pgtable.h"
+#include "iommu-pasid-table.h"
 
 /* MMIO registers */
 #define ARM_SMMU_IDR0			0x0
@@ -258,44 +259,6 @@
 
 #define STRTAB_STE_3_S2TTB_MASK		GENMASK_ULL(51, 4)
 
-/* Context descriptor (stage-1 only) */
-#define CTXDESC_CD_DWORDS		8
-#define CTXDESC_CD_0_TCR_T0SZ		GENMASK_ULL(5, 0)
-#define ARM64_TCR_T0SZ			GENMASK_ULL(5, 0)
-#define CTXDESC_CD_0_TCR_TG0		GENMASK_ULL(7, 6)
-#define ARM64_TCR_TG0			GENMASK_ULL(15, 14)
-#define CTXDESC_CD_0_TCR_IRGN0		GENMASK_ULL(9, 8)
-#define ARM64_TCR_IRGN0			GENMASK_ULL(9, 8)
-#define CTXDESC_CD_0_TCR_ORGN0		GENMASK_ULL(11, 10)
-#define ARM64_TCR_ORGN0			GENMASK_ULL(11, 10)
-#define CTXDESC_CD_0_TCR_SH0		GENMASK_ULL(13, 12)
-#define ARM64_TCR_SH0			GENMASK_ULL(13, 12)
-#define CTXDESC_CD_0_TCR_EPD0		(1ULL << 14)
-#define ARM64_TCR_EPD0			(1ULL << 7)
-#define CTXDESC_CD_0_TCR_EPD1		(1ULL << 30)
-#define ARM64_TCR_EPD1			(1ULL << 23)
-
-#define CTXDESC_CD_0_ENDI		(1UL << 15)
-#define CTXDESC_CD_0_V			(1UL << 31)
-
-#define CTXDESC_CD_0_TCR_IPS		GENMASK_ULL(34, 32)
-#define ARM64_TCR_IPS			GENMASK_ULL(34, 32)
-#define CTXDESC_CD_0_TCR_TBI0		(1ULL << 38)
-#define ARM64_TCR_TBI0			(1ULL << 37)
-
-#define CTXDESC_CD_0_AA64		(1UL << 41)
-#define CTXDESC_CD_0_S			(1UL << 44)
-#define CTXDESC_CD_0_R			(1UL << 45)
-#define CTXDESC_CD_0_A			(1UL << 46)
-#define CTXDESC_CD_0_ASET		(1UL << 47)
-#define CTXDESC_CD_0_ASID		GENMASK_ULL(63, 48)
-
-#define CTXDESC_CD_1_TTB0_MASK		GENMASK_ULL(51, 4)
-
-/* Convert between AArch64 (CPU) TCR format and SMMU CD format */
-#define ARM_SMMU_TCR2CD(tcr, fld)	FIELD_PREP(CTXDESC_CD_0_TCR_##fld, \
-					FIELD_GET(ARM64_TCR_##fld, tcr))
-
 /* Command queue */
 #define CMDQ_ENT_DWORDS			2
 #define CMDQ_MAX_SZ_SHIFT		8
@@ -494,15 +457,9 @@ struct arm_smmu_strtab_l1_desc {
 };
 
 struct arm_smmu_s1_cfg {
-	__le64				*cdptr;
-	dma_addr_t			cdptr_dma;
-
-	struct arm_smmu_ctx_desc {
-		u16	asid;
-		u64	ttbr;
-		u64	tcr;
-		u64	mair;
-	}				cd;
+	struct iommu_pasid_table_cfg	tables;
+	struct iommu_pasid_table_ops	*ops;
+	struct iommu_pasid_entry	*cd0; /* Default context */
 };
 
 struct arm_smmu_s2_cfg {
@@ -572,9 +529,7 @@ struct arm_smmu_device {
 	unsigned long			oas; /* PA */
 	unsigned long			pgsize_bitmap;
 
-#define ARM_SMMU_MAX_ASIDS		(1 << 16)
 	unsigned int			asid_bits;
-	DECLARE_BITMAP(asid_map, ARM_SMMU_MAX_ASIDS);
 
 #define ARM_SMMU_MAX_VMIDS		(1 << 16)
 	unsigned int			vmid_bits;
@@ -999,54 +954,6 @@ static void arm_smmu_cmdq_issue_sync(struct arm_smmu_device *smmu)
 		dev_err_ratelimited(smmu->dev, "CMD_SYNC timeout\n");
 }
 
-/* Context descriptor manipulation functions */
-static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
-{
-	u64 val = 0;
-
-	/* Repack the TCR. Just care about TTBR0 for now */
-	val |= ARM_SMMU_TCR2CD(tcr, T0SZ);
-	val |= ARM_SMMU_TCR2CD(tcr, TG0);
-	val |= ARM_SMMU_TCR2CD(tcr, IRGN0);
-	val |= ARM_SMMU_TCR2CD(tcr, ORGN0);
-	val |= ARM_SMMU_TCR2CD(tcr, SH0);
-	val |= ARM_SMMU_TCR2CD(tcr, EPD0);
-	val |= ARM_SMMU_TCR2CD(tcr, EPD1);
-	val |= ARM_SMMU_TCR2CD(tcr, IPS);
-	val |= ARM_SMMU_TCR2CD(tcr, TBI0);
-
-	return val;
-}
-
-static void arm_smmu_write_ctx_desc(struct arm_smmu_device *smmu,
-				    struct arm_smmu_s1_cfg *cfg)
-{
-	u64 val;
-
-	/*
-	 * We don't need to issue any invalidation here, as we'll invalidate
-	 * the STE when installing the new entry anyway.
-	 */
-	val = arm_smmu_cpu_tcr_to_cd(cfg->cd.tcr) |
-#ifdef __BIG_ENDIAN
-	      CTXDESC_CD_0_ENDI |
-#endif
-	      CTXDESC_CD_0_R | CTXDESC_CD_0_A | CTXDESC_CD_0_ASET |
-	      CTXDESC_CD_0_AA64 | FIELD_PREP(CTXDESC_CD_0_ASID, cfg->cd.asid) |
-	      CTXDESC_CD_0_V;
-
-	/* STALL_MODEL==0b10 && CD.S==0 is ILLEGAL */
-	if (smmu->features & ARM_SMMU_FEAT_STALL_FORCE)
-		val |= CTXDESC_CD_0_S;
-
-	cfg->cdptr[0] = cpu_to_le64(val);
-
-	val = cfg->cd.ttbr & CTXDESC_CD_1_TTB0_MASK;
-	cfg->cdptr[1] = cpu_to_le64(val);
-
-	cfg->cdptr[3] = cpu_to_le64(cfg->cd.mair);
-}
-
 /* Stream table manipulation functions */
 static void
 arm_smmu_write_strtab_l1_desc(__le64 *dst, struct arm_smmu_strtab_l1_desc *desc)
@@ -1155,7 +1062,7 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 		   !(smmu->features & ARM_SMMU_FEAT_STALL_FORCE))
 			dst[1] |= cpu_to_le64(STRTAB_STE_1_S1STALLD);
 
-		val |= (ste->s1_cfg->cdptr_dma & STRTAB_STE_0_S1CTXPTR_MASK) |
+		val |= (ste->s1_cfg->tables.base & STRTAB_STE_0_S1CTXPTR_MASK) |
 			FIELD_PREP(STRTAB_STE_0_CFG, STRTAB_STE_0_CFG_S1_TRANS);
 	}
 
@@ -1396,8 +1303,10 @@ static void arm_smmu_tlb_inv_context(void *cookie)
 	struct arm_smmu_cmdq_ent cmd;
 
 	if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
+		if (unlikely(!smmu_domain->s1_cfg.cd0))
+			return;
 		cmd.opcode	= CMDQ_OP_TLBI_NH_ASID;
-		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd.asid;
+		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd0->tag;
 		cmd.tlbi.vmid	= 0;
 	} else {
 		cmd.opcode	= CMDQ_OP_TLBI_S12_VMALL;
@@ -1421,8 +1330,10 @@ static void arm_smmu_tlb_inv_range_nosync(unsigned long iova, size_t size,
 	};
 
 	if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
+		if (unlikely(!smmu_domain->s1_cfg.cd0))
+			return;
 		cmd.opcode	= CMDQ_OP_TLBI_NH_VA;
-		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd.asid;
+		cmd.tlbi.asid	= smmu_domain->s1_cfg.cd0->tag;
 	} else {
 		cmd.opcode	= CMDQ_OP_TLBI_S2_IPA;
 		cmd.tlbi.vmid	= smmu_domain->s2_cfg.vmid;
@@ -1440,6 +1351,26 @@ static const struct iommu_gather_ops arm_smmu_gather_ops = {
 	.tlb_sync	= arm_smmu_tlb_sync,
 };
 
+/* PASID TABLE API */
+static void arm_smmu_sync_cd(void *cookie, int ssid, bool leaf)
+{
+}
+
+static void arm_smmu_sync_cd_all(void *cookie)
+{
+}
+
+static void arm_smmu_tlb_inv_ssid(void *cookie, int ssid,
+				  struct iommu_pasid_entry *entry)
+{
+}
+
+static struct iommu_pasid_sync_ops arm_smmu_ctx_sync = {
+	.cfg_flush	= arm_smmu_sync_cd,
+	.cfg_flush_all	= arm_smmu_sync_cd_all,
+	.tlb_flush	= arm_smmu_tlb_inv_ssid,
+};
+
 /* IOMMU API */
 static bool arm_smmu_capable(enum iommu_cap cap)
 {
@@ -1512,15 +1443,11 @@ static void arm_smmu_domain_free(struct iommu_domain *domain)
 
 	/* Free the CD and ASID, if we allocated them */
 	if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
-		struct arm_smmu_s1_cfg *cfg = &smmu_domain->s1_cfg;
+		struct iommu_pasid_table_ops *ops = smmu_domain->s1_cfg.ops;
 
-		if (cfg->cdptr) {
-			dmam_free_coherent(smmu_domain->smmu->dev,
-					   CTXDESC_CD_DWORDS << 3,
-					   cfg->cdptr,
-					   cfg->cdptr_dma);
-
-			arm_smmu_bitmap_free(smmu->asid_map, cfg->cd.asid);
+		if (ops) {
+			iommu_free_pasid_entry(smmu_domain->s1_cfg.cd0);
+			iommu_free_pasid_ops(ops);
 		}
 	} else {
 		struct arm_smmu_s2_cfg *cfg = &smmu_domain->s2_cfg;
@@ -1535,31 +1462,42 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 				       struct io_pgtable_cfg *pgtbl_cfg)
 {
 	int ret;
-	int asid;
+	struct iommu_pasid_entry *entry;
+	struct iommu_pasid_table_ops *ops;
 	struct arm_smmu_device *smmu = smmu_domain->smmu;
 	struct arm_smmu_s1_cfg *cfg = &smmu_domain->s1_cfg;
+	struct iommu_pasid_table_cfg pasid_cfg = {
+		.iommu_dev		= smmu->dev,
+		.sync			= &arm_smmu_ctx_sync,
+		.arm_smmu = {
+			.stall		= !!(smmu->features & ARM_SMMU_FEAT_STALL_FORCE),
+			.asid_bits	= smmu->asid_bits,
+		},
+	};
+
+	ops = iommu_alloc_pasid_ops(PASID_TABLE_ARM_SMMU_V3, &pasid_cfg,
+				    smmu_domain);
+	if (!ops)
+		return -ENOMEM;
 
-	asid = arm_smmu_bitmap_alloc(smmu->asid_map, smmu->asid_bits);
-	if (asid < 0)
-		return asid;
+	/* Create default entry */
+	entry = ops->alloc_priv_entry(ops, ARM_64_LPAE_S1, pgtbl_cfg);
+	if (IS_ERR(entry)) {
+		iommu_free_pasid_ops(ops);
+		return PTR_ERR(entry);
+	}
 
-	cfg->cdptr = dmam_alloc_coherent(smmu->dev, CTXDESC_CD_DWORDS << 3,
-					 &cfg->cdptr_dma,
-					 GFP_KERNEL | __GFP_ZERO);
-	if (!cfg->cdptr) {
-		dev_warn(smmu->dev, "failed to allocate context descriptor\n");
-		ret = -ENOMEM;
-		goto out_free_asid;
+	ret = ops->set_entry(ops, 0, entry);
+	if (ret) {
+		iommu_free_pasid_entry(entry);
+		iommu_free_pasid_ops(ops);
+		return ret;
 	}
 
-	cfg->cd.asid	= (u16)asid;
-	cfg->cd.ttbr	= pgtbl_cfg->arm_lpae_s1_cfg.ttbr[0];
-	cfg->cd.tcr	= pgtbl_cfg->arm_lpae_s1_cfg.tcr;
-	cfg->cd.mair	= pgtbl_cfg->arm_lpae_s1_cfg.mair[0];
-	return 0;
+	cfg->tables	= pasid_cfg;
+	cfg->ops	= ops;
+	cfg->cd0	= entry;
 
-out_free_asid:
-	arm_smmu_bitmap_free(smmu->asid_map, asid);
 	return ret;
 }
 
@@ -1763,7 +1701,6 @@ static int arm_smmu_attach_dev(struct iommu_domain *domain, struct device *dev)
 	} else if (smmu_domain->stage == ARM_SMMU_DOMAIN_S1) {
 		ste->s1_cfg = &smmu_domain->s1_cfg;
 		ste->s2_cfg = NULL;
-		arm_smmu_write_ctx_desc(smmu, ste->s1_cfg);
 	} else {
 		ste->s1_cfg = NULL;
 		ste->s2_cfg = &smmu_domain->s2_cfg;
diff --git a/drivers/iommu/iommu-pasid-table.c b/drivers/iommu/iommu-pasid-table.c
index ed62591dcc26..2b6a8a585771 100644
--- a/drivers/iommu/iommu-pasid-table.c
+++ b/drivers/iommu/iommu-pasid-table.c
@@ -11,6 +11,7 @@
 
 static const struct iommu_pasid_init_fns *
 pasid_table_init_fns[PASID_TABLE_NUM_FMTS] = {
+	[PASID_TABLE_ARM_SMMU_V3] = &arm_smmu_v3_pasid_init_fns,
 };
 
 struct iommu_pasid_table_ops *
diff --git a/drivers/iommu/iommu-pasid-table.h b/drivers/iommu/iommu-pasid-table.h
index d5bd098fef19..f52a15f60e81 100644
--- a/drivers/iommu/iommu-pasid-table.h
+++ b/drivers/iommu/iommu-pasid-table.h
@@ -14,6 +14,7 @@
 struct mm_struct;
 
 enum iommu_pasid_table_fmt {
+	PASID_TABLE_ARM_SMMU_V3,
 	PASID_TABLE_NUM_FMTS,
 };
 
@@ -71,6 +72,18 @@ struct iommu_pasid_sync_ops {
 			  struct iommu_pasid_entry *entry);
 };
 
+/**
+ * arm_smmu_context_cfg - PASID table configuration for ARM SMMU v3
+ *
+ * SMMU properties:
+ * @stall: devices attached to the domain are allowed to stall.
+ * @asid_bits: number of ASID bits supported by the SMMU
+ */
+struct arm_smmu_context_cfg {
+	u8				stall:1;
+	u8				asid_bits;
+};
+
 /**
  * struct iommu_pasid_table_cfg - Configuration data for a set of PASID tables.
  *
@@ -85,6 +98,11 @@ struct iommu_pasid_table_cfg {
 	size_t					order;
 	const struct iommu_pasid_sync_ops	*sync;
 	dma_addr_t				base;
+
+	/* Low-level data specific to the IOMMU */
+	union {
+		struct arm_smmu_context_cfg	arm_smmu;
+	};
 };
 
 struct iommu_pasid_table_ops *
@@ -143,4 +161,6 @@ static inline void iommu_pasid_flush_tlbs(struct iommu_pasid_table *table,
 	table->cfg.sync->tlb_flush(table->cookie, pasid, entry);
 }
 
+extern struct iommu_pasid_init_fns arm_smmu_v3_pasid_init_fns;
+
 #endif /* __IOMMU_PASID_TABLE_H */
-- 
2.17.0
