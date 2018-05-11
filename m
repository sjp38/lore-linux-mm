Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C73E76B06C2
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:41 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 5-v6so3426421oiq.6
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:41 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v20-v6si1368917ote.289.2018.05.11.12.10.40
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:40 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 34/40] ACPI/IORT: Check ATS capability in root complex nodes
Date: Fri, 11 May 2018 20:06:35 +0100
Message-Id: <20180511190641.23008-35-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, sudeep.holla@arm.com

Root complex node in IORT has a bit telling whether it supports ATS or
not. Store this bit in the IOMMU fwspec when setting up a device, so it
can be accessed later by an IOMMU driver.

Use the negative version (NO_ATS) at the moment because it's not clear
if/how the bit needs to be integrated in other firmware descriptions. The
SMMU has a feature bit telling if it supports ATS, which might be
sufficient in most systems for deciding whether or not we should enable
the ATS capability in endpoints.

Cc: lorenzo.pieralisi@arm.com
Cc: hanjun.guo@linaro.org
Cc: sudeep.holla@arm.com
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/acpi/arm64/iort.c | 11 +++++++++++
 include/linux/iommu.h     |  4 ++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/acpi/arm64/iort.c b/drivers/acpi/arm64/iort.c
index 7a3a541046ed..4f4907e58cc8 100644
--- a/drivers/acpi/arm64/iort.c
+++ b/drivers/acpi/arm64/iort.c
@@ -1004,6 +1004,14 @@ void iort_dma_setup(struct device *dev, u64 *dma_addr, u64 *dma_size)
 	dev_dbg(dev, "dma_pfn_offset(%#08llx)\n", offset);
 }
 
+static bool iort_pci_rc_supports_ats(struct acpi_iort_node *node)
+{
+	struct acpi_iort_root_complex *pci_rc;
+
+	pci_rc = (struct acpi_iort_root_complex *)node->node_data;
+	return pci_rc->ats_attribute & ACPI_IORT_ATS_SUPPORTED;
+}
+
 /**
  * iort_iommu_configure - Set-up IOMMU configuration for a device.
  *
@@ -1039,6 +1047,9 @@ const struct iommu_ops *iort_iommu_configure(struct device *dev)
 		info.node = node;
 		err = pci_for_each_dma_alias(to_pci_dev(dev),
 					     iort_pci_iommu_init, &info);
+
+		if (!err && !iort_pci_rc_supports_ats(node))
+			dev->iommu_fwspec->flags |= IOMMU_FWSPEC_PCI_NO_ATS;
 	} else {
 		int i = 0;
 
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index bcce44455117..d7e2f54086e4 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -655,12 +655,16 @@ struct iommu_fwspec {
 	const struct iommu_ops	*ops;
 	struct fwnode_handle	*iommu_fwnode;
 	void			*iommu_priv;
+	u32			flags;
 	unsigned int		num_ids;
 	unsigned int		num_pasid_bits;
 	bool			can_stall;
 	u32			ids[1];
 };
 
+/* Firmware disabled ATS in the root complex */
+#define IOMMU_FWSPEC_PCI_NO_ATS			(1 << 0)
+
 int iommu_fwspec_init(struct device *dev, struct fwnode_handle *iommu_fwnode,
 		      const struct iommu_ops *ops);
 void iommu_fwspec_free(struct device *dev);
-- 
2.17.0
