Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7C25E9003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:51 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so51367890pab.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:51 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rv7si35737730pbb.39.2015.08.25.18.33.50
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:50 -0700 (PDT)
Subject: [PATCH v2 8/9] libnvdimm, pmem: direct map legacy pmem by default
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:28:07 -0400
Message-ID: <20150826012807.8851.43035.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

The expectation is that the legacy / non-standard pmem discovery method
(e820 type-12) will only ever be used to describe small quantities of
persistent memory.  Larger capacities will be described via the ACPI
NFIT.  When "allocate struct page from pmem" support is added this default
policy can be overridden by assigning a legacy pmem namespace to a pfn
device, however this would be only be necessary if a platform used the
legacy mechanism to define a very large range.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/e820.c           |    1 +
 drivers/nvdimm/namespace_devs.c |   28 ++++++++++++++++++++++++++--
 drivers/nvdimm/nd.h             |    2 ++
 drivers/nvdimm/pmem.c           |   13 ++++++++++---
 drivers/nvdimm/region_devs.c    |    1 +
 include/linux/libnvdimm.h       |    4 ++++
 6 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/nvdimm/e820.c b/drivers/nvdimm/e820.c
index 1b5743ad92db..8282db2ef99e 100644
--- a/drivers/nvdimm/e820.c
+++ b/drivers/nvdimm/e820.c
@@ -49,6 +49,7 @@ static int e820_pmem_probe(struct platform_device *pdev)
 		ndr_desc.res = p;
 		ndr_desc.attr_groups = e820_pmem_region_attribute_groups;
 		ndr_desc.numa_node = NUMA_NO_NODE;
+		set_bit(ND_REGION_PAGEMAP, &ndr_desc.flags);
 		if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
 			goto err;
 	}
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index 9303ca29be9b..500bfb2825b3 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/slab.h>
+#include <linux/pmem.h>
 #include <linux/nd.h>
 #include "nd-core.h"
 #include "nd.h"
@@ -76,6 +77,27 @@ static bool is_namespace_io(struct device *dev)
 	return dev ? dev->type == &namespace_io_device_type : false;
 }
 
+bool pmem_should_map_pages(struct device *dev)
+{
+	struct nd_region *nd_region = to_nd_region(dev->parent);
+
+	if (!IS_ENABLED(CONFIG_ZONE_DEVICE))
+		return false;
+
+	if (!test_bit(ND_REGION_PAGEMAP, &nd_region->flags))
+		return false;
+
+	if (is_nd_pfn(dev) || is_nd_btt(dev))
+		return false;
+
+#ifdef ARCH_MEMREMAP_PMEM
+	return ARCH_MEMREMAP_PMEM == MEMREMAP_WB;
+#else
+	return false;
+#endif
+}
+EXPORT_SYMBOL(pmem_should_map_pages);
+
 const char *nvdimm_namespace_disk_name(struct nd_namespace_common *ndns,
 		char *name)
 {
@@ -93,9 +115,11 @@ const char *nvdimm_namespace_disk_name(struct nd_namespace_common *ndns,
 					dev_name(ndns->claim));
 	}
 
-	if (is_namespace_pmem(&ndns->dev) || is_namespace_io(&ndns->dev))
+	if (is_namespace_pmem(&ndns->dev) || is_namespace_io(&ndns->dev)) {
+		if (pmem_should_map_pages(&ndns->dev))
+			suffix = "m";
 		sprintf(name, "pmem%d%s", nd_region->id, suffix);
-	else if (is_namespace_blk(&ndns->dev)) {
+	} else if (is_namespace_blk(&ndns->dev)) {
 		struct nd_namespace_blk *nsblk;
 
 		nsblk = to_nd_namespace_blk(&ndns->dev);
diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index 0fe939c42ce5..182eb64f6081 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -95,6 +95,7 @@ struct nd_region {
 	struct ida ns_ida;
 	struct ida btt_ida;
 	struct ida pfn_ida;
+	unsigned long flags;
 	struct device *ns_seed;
 	struct device *btt_seed;
 	struct device *pfn_seed;
@@ -271,4 +272,5 @@ static inline bool nd_iostat_start(struct bio *bio, unsigned long *start)
 void nd_iostat_end(struct bio *bio, unsigned long start);
 resource_size_t nd_namespace_blk_validate(struct nd_namespace_blk *nsblk);
 const u8 *nd_dev_to_uuid(struct device *dev);
+bool pmem_should_map_pages(struct device *dev);
 #endif /* __ND_H__ */
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 13cee46a7b8b..6ea2ead35fb2 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -148,9 +148,16 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
-	pmem->virt_addr = memremap_pmem(dev, pmem->phys_addr, pmem->size);
-	if (!pmem->virt_addr)
-		return ERR_PTR(-ENXIO);
+	if (pmem_should_map_pages(dev)) {
+		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res);
+		if (IS_ERR(pmem->virt_addr))
+			return pmem->virt_addr;
+	} else {
+		pmem->virt_addr = memremap_pmem(dev, pmem->phys_addr,
+				pmem->size);
+		if (!pmem->virt_addr)
+			return ERR_PTR(-ENXIO);
+	}
 
 	return pmem;
 }
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index da4338154ad2..529f3f02e7b2 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -758,6 +758,7 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 	nd_region->provider_data = ndr_desc->provider_data;
 	nd_region->nd_set = ndr_desc->nd_set;
 	nd_region->num_lanes = ndr_desc->num_lanes;
+	nd_region->flags = ndr_desc->flags;
 	nd_region->ro = ro;
 	nd_region->numa_node = ndr_desc->numa_node;
 	ida_init(&nd_region->ns_ida);
diff --git a/include/linux/libnvdimm.h b/include/linux/libnvdimm.h
index 75e3af01ee32..3f021dc5da8c 100644
--- a/include/linux/libnvdimm.h
+++ b/include/linux/libnvdimm.h
@@ -31,6 +31,9 @@ enum {
 	ND_CMD_ARS_STATUS_MAX = SZ_4K,
 	ND_MAX_MAPPINGS = 32,
 
+	/* region flag indicating to direct-map persistent memory by default */
+	ND_REGION_PAGEMAP = 0,
+
 	/* mark newly adjusted resources as requiring a label update */
 	DPA_RESOURCE_ADJUSTED = 1 << 0,
 };
@@ -91,6 +94,7 @@ struct nd_region_desc {
 	void *provider_data;
 	int num_lanes;
 	int numa_node;
+	unsigned long flags;
 };
 
 struct nvdimm_bus;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
