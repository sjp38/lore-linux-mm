Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 784ED6B0266
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:42:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j64so27429762pfj.6
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:42:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r7si199383pgf.713.2017.10.06.15.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:42:20 -0700 (PDT)
Subject: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:35:54 -0700
Message-ID: <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

Add a helper to determine if the dma mappings set up for a given device
are backed by an iommu. In particular, this lets code paths know that a
dma_unmap operation will revoke access to memory if the device can not
otherwise be quiesced. The need for this knowledge is driven by a need
to make RDMA transfers to DAX mappings safe. If the DAX file's block map
changes we need to be to reliably stop accesses to blocks that have been
freed or re-assigned to a new file.

Since PMEM+DAX is currently only enabled for x86, we only update the x86
iommu drivers.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Ashok Raj <ashok.raj@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/base/dma-mapping.c  |   10 ++++++++++
 drivers/iommu/amd_iommu.c   |    6 ++++++
 drivers/iommu/intel-iommu.c |    6 ++++++
 include/linux/dma-mapping.h |    3 +++
 4 files changed, 25 insertions(+)

diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index e584eddef0a7..e1b5f103d90e 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -369,3 +369,13 @@ void dma_deconfigure(struct device *dev)
 	of_dma_deconfigure(dev);
 	acpi_dma_deconfigure(dev);
 }
+
+bool dma_has_iommu(struct device *dev)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (ops && ops->has_iommu)
+		return ops->has_iommu(dev);
+	return false;
+}
+EXPORT_SYMBOL(dma_has_iommu);
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 51f8215877f5..873f899fcf57 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2271,6 +2271,11 @@ static struct protection_domain *get_domain(struct device *dev)
 	return domain;
 }
 
+static bool amd_dma_has_iommu(struct device *dev)
+{
+	return !IS_ERR(get_domain(dev));
+}
+
 static void update_device_table(struct protection_domain *domain)
 {
 	struct iommu_dev_data *dev_data;
@@ -2689,6 +2694,7 @@ static const struct dma_map_ops amd_iommu_dma_ops = {
 	.unmap_sg	= unmap_sg,
 	.dma_supported	= amd_iommu_dma_supported,
 	.mapping_error	= amd_iommu_mapping_error,
+	.has_iommu	= amd_dma_has_iommu,
 };
 
 static int init_reserved_iova_ranges(void)
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 6784a05dd6b2..243ef42fdad4 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3578,6 +3578,11 @@ static int iommu_no_mapping(struct device *dev)
 	return 0;
 }
 
+static bool intel_dma_has_iommu(struct device *dev)
+{
+	return !iommu_no_mapping(dev);
+}
+
 static dma_addr_t __intel_map_single(struct device *dev, phys_addr_t paddr,
 				     size_t size, int dir, u64 dma_mask)
 {
@@ -3872,6 +3877,7 @@ const struct dma_map_ops intel_dma_ops = {
 	.map_page = intel_map_page,
 	.unmap_page = intel_unmap_page,
 	.mapping_error = intel_mapping_error,
+	.has_iommu = intel_dma_has_iommu,
 #ifdef CONFIG_X86
 	.dma_supported = x86_dma_supported,
 #endif
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 29ce9815da87..659f122c18f5 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -128,6 +128,7 @@ struct dma_map_ops {
 				   enum dma_data_direction dir);
 	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
 	int (*dma_supported)(struct device *dev, u64 mask);
+	bool (*has_iommu)(struct device *dev);
 #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
 	u64 (*get_required_mask)(struct device *dev);
 #endif
@@ -221,6 +222,8 @@ static inline const struct dma_map_ops *get_dma_ops(struct device *dev)
 }
 #endif
 
+extern bool dma_has_iommu(struct device *dev);
+
 static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
 					      size_t size,
 					      enum dma_data_direction dir,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
