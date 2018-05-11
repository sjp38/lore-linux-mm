Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC8E6B06AA
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:35 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l95-v6so4287591otl.17
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k10-v6si1325561otj.329.2018.05.11.12.09.34
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:34 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 22/40] iommu/arm-smmu-v3: Add second level of context descriptor table
Date: Fri, 11 May 2018 20:06:23 +0100
Message-Id: <20180511190641.23008-23-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

The SMMU can support up to 20 bits of SSID. Add a second level of page
tables to accommodate this. Devices that support more than 1024 SSIDs now
have a table of 1024 L1 entries (8kB), pointing to tables of 1024 context
descriptors (64kB), allocated on demand.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3-context.c | 137 ++++++++++++++++++++++++++--
 1 file changed, 130 insertions(+), 7 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3-context.c b/drivers/iommu/arm-smmu-v3-context.c
index 0969a3626110..d68da99aa472 100644
--- a/drivers/iommu/arm-smmu-v3-context.c
+++ b/drivers/iommu/arm-smmu-v3-context.c
@@ -14,6 +14,18 @@
 
 #include "iommu-pasid-table.h"
 
+/*
+ * Linear: when less than 1024 SSIDs are supported
+ * 2lvl: at most 1024 L1 entrie,
+ *	 1024 lazy entries per table.
+ */
+#define CTXDESC_SPLIT			10
+#define CTXDESC_NUM_L2_ENTRIES		(1 << CTXDESC_SPLIT)
+
+#define CTXDESC_L1_DESC_DWORD		1
+#define CTXDESC_L1_DESC_VALID		1
+#define CTXDESC_L1_DESC_L2PTR_MASK	GENMASK_ULL(51, 12)
+
 #define CTXDESC_CD_DWORDS		8
 #define CTXDESC_CD_0_TCR_T0SZ		GENMASK_ULL(5, 0)
 #define ARM64_TCR_T0SZ			GENMASK_ULL(5, 0)
@@ -69,7 +81,17 @@ struct arm_smmu_cd_table {
 
 struct arm_smmu_cd_tables {
 	struct iommu_pasid_table	pasid;
-	struct arm_smmu_cd_table	table;
+	bool				linear;
+	union {
+		struct arm_smmu_cd_table table;
+		struct {
+			__le64		*ptr;
+			dma_addr_t	ptr_dma;
+			size_t		num_entries;
+
+			struct arm_smmu_cd_table *tables;
+		} l1;
+	};
 };
 
 #define pasid_to_cd_tables(pasid_table) \
@@ -105,9 +127,44 @@ static void arm_smmu_free_cd_leaf_table(struct device *dev,
 	dmam_free_coherent(dev, size, desc->ptr, desc->ptr_dma);
 }
 
+static void arm_smmu_write_cd_l1_desc(__le64 *dst,
+				      struct arm_smmu_cd_table *desc)
+{
+	u64 val = (desc->ptr_dma & CTXDESC_L1_DESC_L2PTR_MASK) |
+		CTXDESC_L1_DESC_VALID;
+
+	*dst = cpu_to_le64(val);
+}
+
 static __le64 *arm_smmu_get_cd_ptr(struct arm_smmu_cd_tables *tbl, u32 ssid)
 {
-	return tbl->table.ptr + ssid * CTXDESC_CD_DWORDS;
+	unsigned long idx;
+	struct arm_smmu_cd_table *l1_desc;
+	struct iommu_pasid_table_cfg *cfg = &tbl->pasid.cfg;
+
+	if (tbl->linear)
+		return tbl->table.ptr + ssid * CTXDESC_CD_DWORDS;
+
+	idx = ssid >> CTXDESC_SPLIT;
+	if (idx >= tbl->l1.num_entries)
+		return NULL;
+
+	l1_desc = &tbl->l1.tables[idx];
+	if (!l1_desc->ptr) {
+		__le64 *l1ptr = tbl->l1.ptr + idx * CTXDESC_L1_DESC_DWORD;
+
+		if (arm_smmu_alloc_cd_leaf_table(cfg->iommu_dev, l1_desc,
+						 CTXDESC_NUM_L2_ENTRIES))
+			return NULL;
+
+		arm_smmu_write_cd_l1_desc(l1ptr, l1_desc);
+		/* An invalid L1 entry is allowed to be cached */
+		iommu_pasid_flush(&tbl->pasid, idx << CTXDESC_SPLIT, false);
+	}
+
+	idx = ssid & (CTXDESC_NUM_L2_ENTRIES - 1);
+
+	return l1_desc->ptr + idx * CTXDESC_CD_DWORDS;
 }
 
 static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
@@ -284,16 +341,51 @@ static struct iommu_pasid_table *
 arm_smmu_alloc_cd_tables(struct iommu_pasid_table_cfg *cfg, void *cookie)
 {
 	int ret;
+	size_t size = 0;
 	struct arm_smmu_cd_tables *tbl;
 	struct device *dev = cfg->iommu_dev;
+	struct arm_smmu_cd_table *leaf_table;
+	size_t num_contexts, num_leaf_entries;
 
 	tbl = devm_kzalloc(dev, sizeof(*tbl), GFP_KERNEL);
 	if (!tbl)
 		return NULL;
 
-	ret = arm_smmu_alloc_cd_leaf_table(dev, &tbl->table, 1 << cfg->order);
+	num_contexts = 1 << cfg->order;
+	if (num_contexts <= CTXDESC_NUM_L2_ENTRIES) {
+		/* Fits in a single table */
+		tbl->linear = true;
+		num_leaf_entries = num_contexts;
+		leaf_table = &tbl->table;
+	} else {
+		/*
+		 * SSID[S1CDmax-1:10] indexes 1st-level table, SSID[9:0] indexes
+		 * 2nd-level
+		 */
+		tbl->l1.num_entries = num_contexts / CTXDESC_NUM_L2_ENTRIES;
+
+		tbl->l1.tables = devm_kzalloc(dev,
+					      sizeof(struct arm_smmu_cd_table) *
+					      tbl->l1.num_entries, GFP_KERNEL);
+		if (!tbl->l1.tables)
+			goto err_free_tbl;
+
+		size = tbl->l1.num_entries * (CTXDESC_L1_DESC_DWORD << 3);
+		tbl->l1.ptr = dmam_alloc_coherent(dev, size, &tbl->l1.ptr_dma,
+						  GFP_KERNEL | __GFP_ZERO);
+		if (!tbl->l1.ptr) {
+			dev_warn(dev, "failed to allocate L1 context table\n");
+			devm_kfree(dev, tbl->l1.tables);
+			goto err_free_tbl;
+		}
+
+		num_leaf_entries = CTXDESC_NUM_L2_ENTRIES;
+		leaf_table = tbl->l1.tables;
+	}
+
+	ret = arm_smmu_alloc_cd_leaf_table(dev, leaf_table, num_leaf_entries);
 	if (ret)
-		goto err_free_tbl;
+		goto err_free_l1;
 
 	tbl->pasid.ops = (struct iommu_pasid_table_ops) {
 		.alloc_priv_entry	= arm_smmu_alloc_priv_cd,
@@ -301,11 +393,23 @@ arm_smmu_alloc_cd_tables(struct iommu_pasid_table_cfg *cfg, void *cookie)
 		.set_entry		= arm_smmu_set_cd,
 		.clear_entry		= arm_smmu_clear_cd,
 	};
-	cfg->base			= tbl->table.ptr_dma;
-	cfg->arm_smmu.s1fmt		= ARM_SMMU_S1FMT_LINEAR;
+
+	if (tbl->linear) {
+		cfg->base		= leaf_table->ptr_dma;
+		cfg->arm_smmu.s1fmt	= ARM_SMMU_S1FMT_LINEAR;
+	} else {
+		cfg->base		= tbl->l1.ptr_dma;
+		cfg->arm_smmu.s1fmt	= ARM_SMMU_S1FMT_64K_L2;
+		arm_smmu_write_cd_l1_desc(tbl->l1.ptr, leaf_table);
+	}
 
 	return &tbl->pasid;
 
+err_free_l1:
+	if (!tbl->linear) {
+		dmam_free_coherent(dev, size, tbl->l1.ptr, tbl->l1.ptr_dma);
+		devm_kfree(dev, tbl->l1.tables);
+	}
 err_free_tbl:
 	devm_kfree(dev, tbl);
 
@@ -318,7 +422,26 @@ static void arm_smmu_free_cd_tables(struct iommu_pasid_table *pasid_table)
 	struct device *dev = cfg->iommu_dev;
 	struct arm_smmu_cd_tables *tbl = pasid_to_cd_tables(pasid_table);
 
-	arm_smmu_free_cd_leaf_table(dev, &tbl->table, 1 << cfg->order);
+	if (tbl->linear) {
+		arm_smmu_free_cd_leaf_table(dev, &tbl->table, 1 << cfg->order);
+	} else {
+		size_t i, size;
+
+		for (i = 0; i < tbl->l1.num_entries; i++) {
+			struct arm_smmu_cd_table *table = &tbl->l1.tables[i];
+
+			if (!table->ptr)
+				continue;
+
+			arm_smmu_free_cd_leaf_table(dev, table,
+						    CTXDESC_NUM_L2_ENTRIES);
+		}
+
+		size = tbl->l1.num_entries * (CTXDESC_L1_DESC_DWORD << 3);
+		dmam_free_coherent(dev, size, tbl->l1.ptr, tbl->l1.ptr_dma);
+		devm_kfree(dev, tbl->l1.tables);
+	}
+
 	devm_kfree(dev, tbl);
 }
 
-- 
2.17.0
