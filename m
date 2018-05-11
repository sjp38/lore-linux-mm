Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 878666B06A9
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:30 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 106-v6so4267262otg.22
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 64-v6si1243065oik.450.2018.05.11.12.09.28
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:28 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 21/40] iommu/arm-smmu-v3: Add support for Substream IDs
Date: Fri, 11 May 2018 20:06:22 +0100
Message-Id: <20180511190641.23008-22-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

At the moment, the SMMUv3 driver offers only one stage-1 or stage-2
address space to each device. SMMUv3 allows to associate multiple address
spaces per device. In addition to the Stream ID (SID), that identifies a
device, we can now have Substream IDs (SSID) identifying an address space.
In PCIe lingo, SID is called Requester ID (RID) and SSID is called Process
Address-Space ID (PASID).

Prepare the driver for SSID support, by adding context descriptor tables
in STEs (previously a single static context descriptor). A complete
stage-1 walk is now performed like this by the SMMU:

      Stream tables          Ctx. tables          Page tables
        +--------+   ,------->+-------+   ,------->+-------+
        :        :   |        :       :   |        :       :
        +--------+   |        +-------+   |        +-------+
   SID->|  STE   |---'  SSID->|  CD   |---'  IOVA->|  PTE  |--> IPA
        +--------+            +-------+            +-------+
        :        :            :       :            :       :
        +--------+            +-------+            +-------+

We only implement one level of context descriptor table for now, but as
with stream and page tables, an SSID can be split to target multiple
levels of tables.

In all stream table entries, we set S1DSS=SSID0 mode, making translations
without an ssid use context descriptor 0.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: use GENMASK throughout SMMU patches
---
 drivers/iommu/arm-smmu-v3-context.c | 141 +++++++++++++++++++++-------
 drivers/iommu/arm-smmu-v3.c         |  82 +++++++++++++++-
 drivers/iommu/iommu-pasid-table.h   |   7 ++
 3 files changed, 190 insertions(+), 40 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3-context.c b/drivers/iommu/arm-smmu-v3-context.c
index 15d3d02c59b2..0969a3626110 100644
--- a/drivers/iommu/arm-smmu-v3-context.c
+++ b/drivers/iommu/arm-smmu-v3-context.c
@@ -62,11 +62,14 @@ struct arm_smmu_cd {
 #define pasid_entry_to_cd(entry) \
 	container_of((entry), struct arm_smmu_cd, entry)
 
+struct arm_smmu_cd_table {
+	__le64				*ptr;
+	dma_addr_t			ptr_dma;
+};
+
 struct arm_smmu_cd_tables {
 	struct iommu_pasid_table	pasid;
-
-	void				*ptr;
-	dma_addr_t			ptr_dma;
+	struct arm_smmu_cd_table	table;
 };
 
 #define pasid_to_cd_tables(pasid_table) \
@@ -77,6 +80,36 @@ struct arm_smmu_cd_tables {
 
 static DEFINE_IDA(asid_ida);
 
+static int arm_smmu_alloc_cd_leaf_table(struct device *dev,
+					struct arm_smmu_cd_table *desc,
+					size_t num_entries)
+{
+	size_t size = num_entries * (CTXDESC_CD_DWORDS << 3);
+
+	desc->ptr = dmam_alloc_coherent(dev, size, &desc->ptr_dma,
+					GFP_ATOMIC | __GFP_ZERO);
+	if (!desc->ptr) {
+		dev_warn(dev, "failed to allocate context descriptor table\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void arm_smmu_free_cd_leaf_table(struct device *dev,
+					struct arm_smmu_cd_table *desc,
+					size_t num_entries)
+{
+	size_t size = num_entries * (CTXDESC_CD_DWORDS << 3);
+
+	dmam_free_coherent(dev, size, desc->ptr, desc->ptr_dma);
+}
+
+static __le64 *arm_smmu_get_cd_ptr(struct arm_smmu_cd_tables *tbl, u32 ssid)
+{
+	return tbl->table.ptr + ssid * CTXDESC_CD_DWORDS;
+}
+
 static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
 {
 	u64 val = 0;
@@ -95,34 +128,74 @@ static u64 arm_smmu_cpu_tcr_to_cd(u64 tcr)
 	return val;
 }
 
-static void arm_smmu_write_ctx_desc(struct arm_smmu_cd_tables *tbl,
-				    struct arm_smmu_cd *cd)
+static int arm_smmu_write_ctx_desc(struct arm_smmu_cd_tables *tbl, int ssid,
+				   struct arm_smmu_cd *cd)
 {
 	u64 val;
-	__u64 *cdptr = tbl->ptr;
+	bool cd_live;
+	__le64 *cdptr = arm_smmu_get_cd_ptr(tbl, ssid);
 	struct arm_smmu_context_cfg *cfg = &tbl->pasid.cfg.arm_smmu;
 
 	/*
-	 * We don't need to issue any invalidation here, as we'll invalidate
-	 * the STE when installing the new entry anyway.
+	 * This function handles the following cases:
+	 *
+	 * (1) Install primary CD, for normal DMA traffic (SSID = 0).
+	 * (2) Install a secondary CD, for SID+SSID traffic, followed by an
+	 *     invalidation.
+	 * (3) Update ASID of primary CD. This is allowed by atomically writing
+	 *     the first 64 bits of the CD, followed by invalidation of the old
+	 *     entry and mappings.
+	 * (4) Remove a secondary CD and invalidate it.
 	 */
-	val = arm_smmu_cpu_tcr_to_cd(cd->tcr) |
+
+	if (!cdptr)
+		return -ENOMEM;
+
+	val = le64_to_cpu(cdptr[0]);
+	cd_live = !!(val & CTXDESC_CD_0_V);
+
+	if (!cd) { /* (4) */
+		cdptr[0] = 0;
+	} else if (cd_live) { /* (3) */
+		val &= ~CTXDESC_CD_0_ASID;
+		val |= FIELD_PREP(CTXDESC_CD_0_ASID, cd->entry.tag);
+
+		cdptr[0] = cpu_to_le64(val);
+		/*
+		 * Until CD+TLB invalidation, both ASIDs may be used for tagging
+		 * this substream's traffic
+		 */
+	} else { /* (1) and (2) */
+		cdptr[1] = cpu_to_le64(cd->ttbr & CTXDESC_CD_1_TTB0_MASK);
+		cdptr[2] = 0;
+		cdptr[3] = cpu_to_le64(cd->mair);
+
+		/*
+		 * STE is live, and the SMMU might fetch this CD at any
+		 * time. Ensure it observes the rest of the CD before we
+		 * enable it.
+		 */
+		iommu_pasid_flush(&tbl->pasid, ssid, true);
+
+
+		val = arm_smmu_cpu_tcr_to_cd(cd->tcr) |
 #ifdef __BIG_ENDIAN
-	      CTXDESC_CD_0_ENDI |
+		      CTXDESC_CD_0_ENDI |
 #endif
-	      CTXDESC_CD_0_R | CTXDESC_CD_0_A | CTXDESC_CD_0_ASET |
-	      CTXDESC_CD_0_AA64 | FIELD_PREP(CTXDESC_CD_0_ASID, cd->entry.tag) |
-	      CTXDESC_CD_0_V;
+		      CTXDESC_CD_0_R | CTXDESC_CD_0_A | CTXDESC_CD_0_ASET |
+		      CTXDESC_CD_0_AA64 |
+		      FIELD_PREP(CTXDESC_CD_0_ASID, cd->entry.tag) |
+		      CTXDESC_CD_0_V;
 
-	if (cfg->stall)
-		val |= CTXDESC_CD_0_S;
+		if (cfg->stall)
+			val |= CTXDESC_CD_0_S;
 
-	cdptr[0] = cpu_to_le64(val);
+		cdptr[0] = cpu_to_le64(val);
+	}
 
-	val = cd->ttbr & CTXDESC_CD_1_TTB0_MASK;
-	cdptr[1] = cpu_to_le64(val);
+	iommu_pasid_flush(&tbl->pasid, ssid, true);
 
-	cdptr[3] = cpu_to_le64(cd->mair);
+	return 0;
 }
 
 static void arm_smmu_free_cd(struct iommu_pasid_entry *entry)
@@ -190,8 +263,10 @@ static int arm_smmu_set_cd(struct iommu_pasid_table_ops *ops, int pasid,
 	struct arm_smmu_cd_tables *tbl = pasid_ops_to_tables(ops);
 	struct arm_smmu_cd *cd = pasid_entry_to_cd(entry);
 
-	arm_smmu_write_ctx_desc(tbl, cd);
-	return 0;
+	if (WARN_ON(pasid > (1 << tbl->pasid.cfg.order)))
+		return -EINVAL;
+
+	return arm_smmu_write_ctx_desc(tbl, pasid, cd);
 }
 
 static void arm_smmu_clear_cd(struct iommu_pasid_table_ops *ops, int pasid,
@@ -199,30 +274,26 @@ static void arm_smmu_clear_cd(struct iommu_pasid_table_ops *ops, int pasid,
 {
 	struct arm_smmu_cd_tables *tbl = pasid_ops_to_tables(ops);
 
-	arm_smmu_write_ctx_desc(tbl, NULL);
+	if (WARN_ON(pasid > (1 << tbl->pasid.cfg.order)))
+		return;
+
+	arm_smmu_write_ctx_desc(tbl, pasid, NULL);
 }
 
 static struct iommu_pasid_table *
 arm_smmu_alloc_cd_tables(struct iommu_pasid_table_cfg *cfg, void *cookie)
 {
+	int ret;
 	struct arm_smmu_cd_tables *tbl;
 	struct device *dev = cfg->iommu_dev;
 
-	if (cfg->order) {
-		/* TODO: support SSID */
-		return NULL;
-	}
-
 	tbl = devm_kzalloc(dev, sizeof(*tbl), GFP_KERNEL);
 	if (!tbl)
 		return NULL;
 
-	tbl->ptr = dmam_alloc_coherent(dev, CTXDESC_CD_DWORDS << 3,
-				       &tbl->ptr_dma, GFP_KERNEL | __GFP_ZERO);
-	if (!tbl->ptr) {
-		dev_warn(dev, "failed to allocate context descriptor\n");
+	ret = arm_smmu_alloc_cd_leaf_table(dev, &tbl->table, 1 << cfg->order);
+	if (ret)
 		goto err_free_tbl;
-	}
 
 	tbl->pasid.ops = (struct iommu_pasid_table_ops) {
 		.alloc_priv_entry	= arm_smmu_alloc_priv_cd,
@@ -230,7 +301,8 @@ arm_smmu_alloc_cd_tables(struct iommu_pasid_table_cfg *cfg, void *cookie)
 		.set_entry		= arm_smmu_set_cd,
 		.clear_entry		= arm_smmu_clear_cd,
 	};
-	cfg->base = tbl->ptr_dma;
+	cfg->base			= tbl->table.ptr_dma;
+	cfg->arm_smmu.s1fmt		= ARM_SMMU_S1FMT_LINEAR;
 
 	return &tbl->pasid;
 
@@ -246,8 +318,7 @@ static void arm_smmu_free_cd_tables(struct iommu_pasid_table *pasid_table)
 	struct device *dev = cfg->iommu_dev;
 	struct arm_smmu_cd_tables *tbl = pasid_to_cd_tables(pasid_table);
 
-	dmam_free_coherent(dev, CTXDESC_CD_DWORDS << 3,
-			   tbl->ptr, tbl->ptr_dma);
+	arm_smmu_free_cd_leaf_table(dev, &tbl->table, 1 << cfg->order);
 	devm_kfree(dev, tbl);
 }
 
diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 68764a200e44..16b08f2fb8ac 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -224,10 +224,14 @@
 #define STRTAB_STE_0_CFG_S2_TRANS	6
 
 #define STRTAB_STE_0_S1FMT		GENMASK_ULL(5, 4)
-#define STRTAB_STE_0_S1FMT_LINEAR	0
 #define STRTAB_STE_0_S1CTXPTR_MASK	GENMASK_ULL(51, 6)
 #define STRTAB_STE_0_S1CDMAX		GENMASK_ULL(63, 59)
 
+#define STRTAB_STE_1_S1DSS		GENMASK_ULL(1, 0)
+#define STRTAB_STE_1_S1DSS_TERMINATE	0x0
+#define STRTAB_STE_1_S1DSS_BYPASS	0x1
+#define STRTAB_STE_1_S1DSS_SSID0	0x2
+
 #define STRTAB_STE_1_S1C_CACHE_NC	0UL
 #define STRTAB_STE_1_S1C_CACHE_WBRA	1UL
 #define STRTAB_STE_1_S1C_CACHE_WT	2UL
@@ -275,6 +279,7 @@
 #define CMDQ_PREFETCH_1_SIZE		GENMASK_ULL(4, 0)
 #define CMDQ_PREFETCH_1_ADDR_MASK	GENMASK_ULL(63, 12)
 
+#define CMDQ_CFGI_0_SSID		GENMASK_ULL(31, 12)
 #define CMDQ_CFGI_0_SID			GENMASK_ULL(63, 32)
 #define CMDQ_CFGI_1_LEAF		(1UL << 0)
 #define CMDQ_CFGI_1_RANGE		GENMASK_ULL(4, 0)
@@ -381,8 +386,11 @@ struct arm_smmu_cmdq_ent {
 
 		#define CMDQ_OP_CFGI_STE	0x3
 		#define CMDQ_OP_CFGI_ALL	0x4
+		#define CMDQ_OP_CFGI_CD		0x5
+		#define CMDQ_OP_CFGI_CD_ALL	0x6
 		struct {
 			u32			sid;
+			u32			ssid;
 			union {
 				bool		leaf;
 				u8		span;
@@ -555,6 +563,7 @@ struct arm_smmu_master_data {
 	struct list_head		list; /* domain->devices */
 
 	struct device			*dev;
+	size_t				ssid_bits;
 };
 
 /* SMMU private data for an IOMMU domain */
@@ -753,10 +762,16 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd, struct arm_smmu_cmdq_ent *ent)
 		cmd[1] |= FIELD_PREP(CMDQ_PREFETCH_1_SIZE, ent->prefetch.size);
 		cmd[1] |= ent->prefetch.addr & CMDQ_PREFETCH_1_ADDR_MASK;
 		break;
+	case CMDQ_OP_CFGI_CD:
+		cmd[0] |= FIELD_PREP(CMDQ_CFGI_0_SSID, ent->cfgi.ssid);
+		/* Fallthrough */
 	case CMDQ_OP_CFGI_STE:
 		cmd[0] |= FIELD_PREP(CMDQ_CFGI_0_SID, ent->cfgi.sid);
 		cmd[1] |= FIELD_PREP(CMDQ_CFGI_1_LEAF, ent->cfgi.leaf);
 		break;
+	case CMDQ_OP_CFGI_CD_ALL:
+		cmd[0] |= FIELD_PREP(CMDQ_CFGI_0_SID, ent->cfgi.sid);
+		break;
 	case CMDQ_OP_CFGI_ALL:
 		/* Cover the entire SID range */
 		cmd[1] |= FIELD_PREP(CMDQ_CFGI_1_RANGE, 31);
@@ -1048,8 +1063,11 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 	}
 
 	if (ste->s1_cfg) {
+		struct iommu_pasid_table_cfg *cfg = &ste->s1_cfg->tables;
+
 		BUG_ON(ste_live);
 		dst[1] = cpu_to_le64(
+			 FIELD_PREP(STRTAB_STE_1_S1DSS, STRTAB_STE_1_S1DSS_SSID0) |
 			 FIELD_PREP(STRTAB_STE_1_S1CIR, STRTAB_STE_1_S1C_CACHE_WBRA) |
 			 FIELD_PREP(STRTAB_STE_1_S1COR, STRTAB_STE_1_S1C_CACHE_WBRA) |
 			 FIELD_PREP(STRTAB_STE_1_S1CSH, ARM_SMMU_SH_ISH) |
@@ -1063,7 +1081,9 @@ static void arm_smmu_write_strtab_ent(struct arm_smmu_device *smmu, u32 sid,
 			dst[1] |= cpu_to_le64(STRTAB_STE_1_S1STALLD);
 
 		val |= (ste->s1_cfg->tables.base & STRTAB_STE_0_S1CTXPTR_MASK) |
-			FIELD_PREP(STRTAB_STE_0_CFG, STRTAB_STE_0_CFG_S1_TRANS);
+			FIELD_PREP(STRTAB_STE_0_CFG, STRTAB_STE_0_CFG_S1_TRANS) |
+			FIELD_PREP(STRTAB_STE_0_S1CDMAX, cfg->order) |
+			FIELD_PREP(STRTAB_STE_0_S1FMT, cfg->arm_smmu.s1fmt);
 	}
 
 	if (ste->s2_cfg) {
@@ -1352,17 +1372,62 @@ static const struct iommu_gather_ops arm_smmu_gather_ops = {
 };
 
 /* PASID TABLE API */
+static void __arm_smmu_sync_cd(struct arm_smmu_domain *smmu_domain,
+			       struct arm_smmu_cmdq_ent *cmd)
+{
+	size_t i;
+	unsigned long flags;
+	struct arm_smmu_master_data *master;
+	struct arm_smmu_device *smmu = smmu_domain->smmu;
+
+	spin_lock_irqsave(&smmu_domain->devices_lock, flags);
+	list_for_each_entry(master, &smmu_domain->devices, list) {
+		struct iommu_fwspec *fwspec = master->dev->iommu_fwspec;
+
+		for (i = 0; i < fwspec->num_ids; i++) {
+			cmd->cfgi.sid = fwspec->ids[i];
+			arm_smmu_cmdq_issue_cmd(smmu, cmd);
+		}
+	}
+	spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
+
+	__arm_smmu_tlb_sync(smmu);
+}
+
 static void arm_smmu_sync_cd(void *cookie, int ssid, bool leaf)
 {
+	struct arm_smmu_cmdq_ent cmd = {
+		.opcode	= CMDQ_OP_CFGI_CD_ALL,
+		.cfgi	= {
+			.ssid	= ssid,
+			.leaf	= leaf,
+		},
+	};
+
+	__arm_smmu_sync_cd(cookie, &cmd);
 }
 
 static void arm_smmu_sync_cd_all(void *cookie)
 {
+	struct arm_smmu_cmdq_ent cmd = {
+		.opcode	= CMDQ_OP_CFGI_CD_ALL,
+	};
+
+	__arm_smmu_sync_cd(cookie, &cmd);
 }
 
 static void arm_smmu_tlb_inv_ssid(void *cookie, int ssid,
 				  struct iommu_pasid_entry *entry)
 {
+	struct arm_smmu_domain *smmu_domain = cookie;
+	struct arm_smmu_device *smmu = smmu_domain->smmu;
+	struct arm_smmu_cmdq_ent cmd = {
+		.opcode		= CMDQ_OP_TLBI_NH_ASID,
+		.tlbi.asid	= entry->tag,
+	};
+
+	arm_smmu_cmdq_issue_cmd(smmu, &cmd);
+	__arm_smmu_tlb_sync(smmu);
 }
 
 static struct iommu_pasid_sync_ops arm_smmu_ctx_sync = {
@@ -1459,6 +1524,7 @@ static void arm_smmu_domain_free(struct iommu_domain *domain)
 }
 
 static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
+				       struct arm_smmu_master_data *master,
 				       struct io_pgtable_cfg *pgtbl_cfg)
 {
 	int ret;
@@ -1468,6 +1534,7 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 	struct arm_smmu_s1_cfg *cfg = &smmu_domain->s1_cfg;
 	struct iommu_pasid_table_cfg pasid_cfg = {
 		.iommu_dev		= smmu->dev,
+		.order			= master->ssid_bits,
 		.sync			= &arm_smmu_ctx_sync,
 		.arm_smmu = {
 			.stall		= !!(smmu->features & ARM_SMMU_FEAT_STALL_FORCE),
@@ -1502,6 +1569,7 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 }
 
 static int arm_smmu_domain_finalise_s2(struct arm_smmu_domain *smmu_domain,
+				       struct arm_smmu_master_data *master,
 				       struct io_pgtable_cfg *pgtbl_cfg)
 {
 	int vmid;
@@ -1518,7 +1586,8 @@ static int arm_smmu_domain_finalise_s2(struct arm_smmu_domain *smmu_domain,
 	return 0;
 }
 
-static int arm_smmu_domain_finalise(struct iommu_domain *domain)
+static int arm_smmu_domain_finalise(struct iommu_domain *domain,
+				    struct arm_smmu_master_data *master)
 {
 	int ret;
 	unsigned long ias, oas;
@@ -1526,6 +1595,7 @@ static int arm_smmu_domain_finalise(struct iommu_domain *domain)
 	struct io_pgtable_cfg pgtbl_cfg;
 	struct io_pgtable_ops *pgtbl_ops;
 	int (*finalise_stage_fn)(struct arm_smmu_domain *,
+				 struct arm_smmu_master_data *,
 				 struct io_pgtable_cfg *);
 	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
 	struct arm_smmu_device *smmu = smmu_domain->smmu;
@@ -1579,7 +1649,7 @@ static int arm_smmu_domain_finalise(struct iommu_domain *domain)
 	domain->geometry.aperture_end = (1UL << pgtbl_cfg.ias) - 1;
 	domain->geometry.force_aperture = true;
 
-	ret = finalise_stage_fn(smmu_domain, &pgtbl_cfg);
+	ret = finalise_stage_fn(smmu_domain, master, &pgtbl_cfg);
 	if (ret < 0) {
 		free_io_pgtable_ops(pgtbl_ops);
 		return ret;
@@ -1674,7 +1744,7 @@ static int arm_smmu_attach_dev(struct iommu_domain *domain, struct device *dev)
 
 	if (!smmu_domain->smmu) {
 		smmu_domain->smmu = smmu;
-		ret = arm_smmu_domain_finalise(domain);
+		ret = arm_smmu_domain_finalise(domain, master);
 		if (ret) {
 			smmu_domain->smmu = NULL;
 			goto out_unlock;
@@ -1830,6 +1900,8 @@ static int arm_smmu_add_device(struct device *dev)
 		}
 	}
 
+	master->ssid_bits = min(smmu->ssid_bits, fwspec->num_pasid_bits);
+
 	group = iommu_group_get_for_dev(dev);
 	if (!IS_ERR(group)) {
 		iommu_group_put(group);
diff --git a/drivers/iommu/iommu-pasid-table.h b/drivers/iommu/iommu-pasid-table.h
index f52a15f60e81..b84709e297bc 100644
--- a/drivers/iommu/iommu-pasid-table.h
+++ b/drivers/iommu/iommu-pasid-table.h
@@ -78,10 +78,17 @@ struct iommu_pasid_sync_ops {
  * SMMU properties:
  * @stall: devices attached to the domain are allowed to stall.
  * @asid_bits: number of ASID bits supported by the SMMU
+ *
+ * @s1fmt: PASID table format, chosen by the allocator.
  */
 struct arm_smmu_context_cfg {
 	u8				stall:1;
 	u8				asid_bits;
+
+#define ARM_SMMU_S1FMT_LINEAR		0x0
+#define ARM_SMMU_S1FMT_4K_L2		0x1
+#define ARM_SMMU_S1FMT_64K_L2		0x2
+	u8				s1fmt;
 };
 
 /**
-- 
2.17.0
