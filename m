Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAB66B06B4
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k186-v6so3443430oib.7
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p18-v6si1190908oic.290.2018.05.11.12.10.07
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:07 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 28/40] iommu/arm-smmu-v3: Implement mm operations
Date: Fri, 11 May 2018 20:06:29 +0100
Message-Id: <20180511190641.23008-29-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Hook mm operations to support PASID and page table sharing with the
SMMUv3:

* mm_alloc allocates a context descriptor.
* mm_free releases the context descriptor.
* mm_attach checks device capabilities and writes the context descriptor.
* mm_detach clears the context descriptor and sends required
  invalidations.
* mm_invalidate sends required invalidations.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/Kconfig       |   1 +
 drivers/iommu/arm-smmu-v3.c | 126 ++++++++++++++++++++++++++++++++++++
 2 files changed, 127 insertions(+)

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 11c8492b3763..70900670a9fa 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -343,6 +343,7 @@ config ARM_SMMU_V3
 	bool "ARM Ltd. System MMU Version 3 (SMMUv3) Support"
 	depends on ARM64
 	select IOMMU_API
+	select IOMMU_SVA
 	select IOMMU_IO_PGTABLE_LPAE
 	select ARM_SMMU_V3_CONTEXT
 	select GENERIC_MSI_IRQ_DOMAIN
diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 2716e4a4d3f7..c2c96025ac3b 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -31,6 +31,7 @@
 #include <linux/interrupt.h>
 #include <linux/iommu.h>
 #include <linux/iopoll.h>
+#include <linux/mmu_context.h>
 #include <linux/module.h>
 #include <linux/msi.h>
 #include <linux/of.h>
@@ -39,6 +40,7 @@
 #include <linux/of_platform.h>
 #include <linux/pci.h>
 #include <linux/platform_device.h>
+#include <linux/sched/mm.h>
 
 #include <linux/amba/bus.h>
 
@@ -599,6 +601,11 @@ struct arm_smmu_domain {
 	spinlock_t			devices_lock;
 };
 
+struct arm_smmu_mm {
+	struct io_mm			io_mm;
+	struct iommu_pasid_entry	*cd;
+};
+
 struct arm_smmu_option_prop {
 	u32 opt;
 	const char *prop;
@@ -625,6 +632,11 @@ static struct arm_smmu_domain *to_smmu_domain(struct iommu_domain *dom)
 	return container_of(dom, struct arm_smmu_domain, domain);
 }
 
+static struct arm_smmu_mm *to_smmu_mm(struct io_mm *io_mm)
+{
+	return container_of(io_mm, struct arm_smmu_mm, io_mm);
+}
+
 static void parse_driver_options(struct arm_smmu_device *smmu)
 {
 	int i = 0;
@@ -1725,6 +1737,8 @@ static void arm_smmu_detach_dev(struct device *dev)
 	struct arm_smmu_domain *smmu_domain = master->domain;
 
 	if (smmu_domain) {
+		__iommu_sva_unbind_dev_all(dev);
+
 		spin_lock_irqsave(&smmu_domain->devices_lock, flags);
 		list_del(&master->list);
 		spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
@@ -1842,6 +1856,111 @@ arm_smmu_iova_to_phys(struct iommu_domain *domain, dma_addr_t iova)
 	return ops->iova_to_phys(ops, iova);
 }
 
+static int arm_smmu_sva_init(struct device *dev, struct iommu_sva_param *param)
+{
+	struct arm_smmu_master_data *master = dev->iommu_fwspec->iommu_priv;
+
+	/* SSID support is mandatory for the moment */
+	if (!master->ssid_bits)
+		return -EINVAL;
+
+	if (param->features)
+		return -EINVAL;
+
+	if (!param->max_pasid)
+		param->max_pasid = 0xfffffU;
+
+	/* SSID support in the SMMU requires at least one SSID bit */
+	param->min_pasid = max(param->min_pasid, 1U);
+	param->max_pasid = min(param->max_pasid, (1U << master->ssid_bits) - 1);
+
+	return 0;
+}
+
+static void arm_smmu_sva_shutdown(struct device *dev,
+				  struct iommu_sva_param *param)
+{
+}
+
+static struct io_mm *arm_smmu_mm_alloc(struct iommu_domain *domain,
+				       struct mm_struct *mm,
+				       unsigned long flags)
+{
+	struct arm_smmu_mm *smmu_mm;
+	struct iommu_pasid_entry *cd;
+	struct iommu_pasid_table_ops *ops;
+	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
+
+	if (smmu_domain->stage != ARM_SMMU_DOMAIN_S1)
+		return NULL;
+
+	smmu_mm = kzalloc(sizeof(*smmu_mm), GFP_KERNEL);
+	if (!smmu_mm)
+		return NULL;
+
+	ops = smmu_domain->s1_cfg.ops;
+	cd = ops->alloc_shared_entry(ops, mm);
+	if (IS_ERR(cd)) {
+		kfree(smmu_mm);
+		return ERR_CAST(cd);
+	}
+
+	smmu_mm->cd = cd;
+	return &smmu_mm->io_mm;
+}
+
+static void arm_smmu_mm_free(struct io_mm *io_mm)
+{
+	struct arm_smmu_mm *smmu_mm = to_smmu_mm(io_mm);
+
+	iommu_free_pasid_entry(smmu_mm->cd);
+	kfree(smmu_mm);
+}
+
+static int arm_smmu_mm_attach(struct iommu_domain *domain, struct device *dev,
+			      struct io_mm *io_mm, bool attach_domain)
+{
+	struct arm_smmu_mm *smmu_mm = to_smmu_mm(io_mm);
+	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
+	struct iommu_pasid_table_ops *ops = smmu_domain->s1_cfg.ops;
+	struct arm_smmu_master_data *master = dev->iommu_fwspec->iommu_priv;
+
+	if (smmu_domain->stage != ARM_SMMU_DOMAIN_S1)
+		return -EINVAL;
+
+	if (!(master->smmu->features & ARM_SMMU_FEAT_SVA))
+		return -ENODEV;
+
+	if (!attach_domain)
+		return 0;
+
+	return ops->set_entry(ops, io_mm->pasid, smmu_mm->cd);
+}
+
+static void arm_smmu_mm_detach(struct iommu_domain *domain, struct device *dev,
+			       struct io_mm *io_mm, bool detach_domain)
+{
+	struct arm_smmu_mm *smmu_mm = to_smmu_mm(io_mm);
+	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
+	struct iommu_pasid_table_ops *ops = smmu_domain->s1_cfg.ops;
+
+	if (detach_domain)
+		ops->clear_entry(ops, io_mm->pasid, smmu_mm->cd);
+
+	/* TODO: Invalidate ATC. */
+	/* TODO: Invalidate all mappings if last and not DVM. */
+}
+
+static void arm_smmu_mm_invalidate(struct iommu_domain *domain,
+				   struct device *dev, struct io_mm *io_mm,
+				   unsigned long iova, size_t size)
+{
+	/*
+	 * TODO: Invalidate ATC.
+	 * TODO: Invalidate mapping if not DVM
+	 */
+}
+
 static struct platform_driver arm_smmu_driver;
 
 static int arm_smmu_match_node(struct device *dev, void *data)
@@ -2048,6 +2167,13 @@ static struct iommu_ops arm_smmu_ops = {
 	.domain_alloc		= arm_smmu_domain_alloc,
 	.domain_free		= arm_smmu_domain_free,
 	.attach_dev		= arm_smmu_attach_dev,
+	.sva_device_init	= arm_smmu_sva_init,
+	.sva_device_shutdown	= arm_smmu_sva_shutdown,
+	.mm_alloc		= arm_smmu_mm_alloc,
+	.mm_free		= arm_smmu_mm_free,
+	.mm_attach		= arm_smmu_mm_attach,
+	.mm_detach		= arm_smmu_mm_detach,
+	.mm_invalidate		= arm_smmu_mm_invalidate,
 	.map			= arm_smmu_map,
 	.unmap			= arm_smmu_unmap,
 	.map_sg			= default_iommu_map_sg,
-- 
2.17.0
