Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE246B027B
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:00:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so1419687plp.21
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:00:07 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d30-v6si5134907pla.64.2018.07.05.00.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 00:00:05 -0700 (PDT)
Subject: [PATCH 12/13] device-dax: Initialize the memmap in the background
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:50:07 -0700
Message-ID: <153077340620.40830.18398670365019815228.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given that the nd_dax shares device data with nd_pfn devices, arrange
for the nd_pfn memmap_async_state instance to be registered by the
devm_memremap_pages() call in the dax-pmem driver. Then, provide the
generic dev_pagemap instance to the device-dax driver so that it can
utilize memmap_sync() before dax-mapping pfns.

Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax-private.h |    2 ++
 drivers/dax/device-dax.h  |    2 +-
 drivers/dax/device.c      |   16 +++++++++++++++-
 drivers/dax/pmem.c        |    5 ++++-
 4 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index b6fc4f04636d..35bda544b334 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -25,6 +25,7 @@
  * @align: allocation and mapping alignment for child dax devices
  * @res: physical address range of the region
  * @pfn_flags: identify whether the pfns are paged back or not
+ * @pgmap: backing page map for the device address range
  */
 struct dax_region {
 	int id;
@@ -35,6 +36,7 @@ struct dax_region {
 	unsigned int align;
 	struct resource res;
 	unsigned long pfn_flags;
+	struct dev_pagemap *pgmap;
 };
 
 /**
diff --git a/drivers/dax/device-dax.h b/drivers/dax/device-dax.h
index 688b051750bd..1a2da8072a6e 100644
--- a/drivers/dax/device-dax.h
+++ b/drivers/dax/device-dax.h
@@ -19,7 +19,7 @@ struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent,
 		int region_id, struct resource *res, unsigned int align,
-		void *addr, unsigned long flags);
+		void *addr, struct dev_pagemap *pgmap, unsigned long flags);
 struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 		int id, struct resource *res, int count);
 #endif /* __DEVICE_DAX_H__ */
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index de2f8297a210..2802d21a6e26 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -10,6 +10,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/memmap_async.h>
 #include <linux/pagemap.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -101,7 +102,7 @@ static void dax_region_unregister(void *region)
 
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 		struct resource *res, unsigned int align, void *addr,
-		unsigned long pfn_flags)
+		struct dev_pagemap *pgmap, unsigned long pfn_flags)
 {
 	struct dax_region *dax_region;
 
@@ -130,6 +131,7 @@ struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 	dax_region->id = region_id;
 	ida_init(&dax_region->ida);
 	dax_region->align = align;
+	dax_region->pgmap = pgmap;
 	dax_region->dev = parent;
 	dax_region->base = addr;
 	if (sysfs_create_groups(&parent->kobj, dax_region_attribute_groups)) {
@@ -244,6 +246,15 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 	return -1;
 }
 
+static void dax_pfn_sync(struct dax_region *dax_region, pfn_t pfn,
+		unsigned long size)
+{
+	struct dev_pagemap *pgmap = dax_region->pgmap;
+	struct memmap_async_state *async = pgmap->async;
+
+	memmap_sync(pfn, PHYS_PFN(size), async);
+}
+
 static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 {
 	struct device *dev = &dev_dax->dev;
@@ -273,6 +284,7 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 	}
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	dax_pfn_sync(dax_region, pfn, PAGE_SIZE);
 
 	rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
 
@@ -328,6 +340,7 @@ static int __dev_dax_pmd_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 	}
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	dax_pfn_sync(dax_region, pfn, PMD_SIZE);
 
 	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd, pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
@@ -379,6 +392,7 @@ static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 	}
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	dax_pfn_sync(dax_region, pfn, PUD_SIZE);
 
 	return vmf_insert_pfn_pud(vmf->vma, vmf->address, vmf->pud, pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 54cba20c8ba6..a05be7a03d02 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -11,6 +11,7 @@
  * General Public License for more details.
  */
 #include <linux/percpu-refcount.h>
+#include <linux/memmap_async.h>
 #include <linux/memremap.h>
 #include <linux/module.h>
 #include <linux/pfn_t.h>
@@ -110,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
 		return rc;
 
 	dax_pmem->pgmap.ref = &dax_pmem->ref;
+	dax_pmem->pgmap.async = &nd_pfn->async;
 	addr = devm_memremap_pages(dev, &dax_pmem->pgmap, dax_pmem_percpu_kill);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
@@ -123,7 +125,8 @@ static int dax_pmem_probe(struct device *dev)
 		return -EINVAL;
 
 	dax_region = alloc_dax_region(dev, region_id, &res,
-			le32_to_cpu(pfn_sb->align), addr, PFN_DEV|PFN_MAP);
+			le32_to_cpu(pfn_sb->align), addr, &dax_pmem->pgmap,
+			PFN_DEV|PFN_MAP);
 	if (!dax_region)
 		return -ENOMEM;
 
