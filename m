Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 181B16B0351
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:25:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s23-v6so143680plq.7
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:25:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 14-v6si25976552pgl.157.2018.10.30.20.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:25:09 -0700 (PDT)
Subject: [PATCH 6/8] device-dax: Move resource pinning+mapping into the
 common driver
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:13:20 -0700
Message-ID: <154095560048.3271337.5958710475937860522.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

Move the responsibility of calling devm_request_resource() and
devm_memremap_pages() into the common device-dax driver. This is another
preparatory step to allowing an alternate personality driver for a
device-dax range.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/bus.c         |    6 ++-
 drivers/dax/bus.h         |    3 +
 drivers/dax/dax-private.h |    9 ++++
 drivers/dax/device.c      |   65 ++++++++++++++++++++++++++++++
 drivers/dax/pmem.c        |   98 ++++++---------------------------------------
 5 files changed, 94 insertions(+), 87 deletions(-)

diff --git a/drivers/dax/bus.c b/drivers/dax/bus.c
index 0cff32102c4c..69aae2cbd45f 100644
--- a/drivers/dax/bus.c
+++ b/drivers/dax/bus.c
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 /* Copyright(c) 2017-2018 Intel Corporation. All rights reserved. */
+#include <linux/memremap.h>
 #include <linux/device.h>
 #include <linux/slab.h>
 #include <linux/dax.h>
@@ -206,7 +207,8 @@ static void unregister_dev_dax(void *dev)
 	put_device(dev);
 }
 
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id)
+struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
+		struct dev_pagemap *pgmap)
 {
 	struct device *parent = dax_region->dev;
 	struct dax_device *dax_dev;
@@ -222,6 +224,8 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id)
 	if (!dev_dax)
 		return ERR_PTR(-ENOMEM);
 
+	memcpy(&dev_dax->pgmap, pgmap, sizeof(*pgmap));
+
 	/*
 	 * No 'host' or dax_operations since there is no access to this
 	 * device outside of mmap of the resulting character device.
diff --git a/drivers/dax/bus.h b/drivers/dax/bus.h
index ea509504df3a..e08e0c394983 100644
--- a/drivers/dax/bus.h
+++ b/drivers/dax/bus.h
@@ -10,7 +10,8 @@ struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 		struct resource *res, unsigned int align, unsigned long flags);
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id);
+struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
+		struct dev_pagemap *pgmap);
 int __dax_driver_register(struct device_driver *drv,
 		struct module *module, const char *mod_name);
 #define dax_driver_register(driver) \
diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index c3a121700837..a82ce48f5884 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -42,15 +42,22 @@ struct dax_region {
 };
 
 /**
- * struct dev_dax - instance data for a subdivision of a dax region
+ * struct dev_dax - instance data for a subdivision of a dax region, and
+ * data while the device is activated in the driver.
  * @region - parent region
  * @dax_dev - core dax functionality
  * @dev - device core
+ * @pgmap - pgmap for memmap setup / lifetime (driver owned)
+ * @ref: pgmap reference count (driver owned)
+ * @cmp: @ref final put completion (driver owned)
  */
 struct dev_dax {
 	struct dax_region *region;
 	struct dax_device *dax_dev;
 	struct device dev;
+	struct dev_pagemap pgmap;
+	struct percpu_ref ref;
+	struct completion cmp;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index f55829404a24..967bab097013 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 /* Copyright(c) 2016-2018 Intel Corporation. All rights reserved. */
+#include <linux/memremap.h>
 #include <linux/pagemap.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -13,6 +14,38 @@
 #include "dax-private.h"
 #include "bus.h"
 
+static struct dev_dax *ref_to_dev_dax(struct percpu_ref *ref)
+{
+	return container_of(ref, struct dev_dax, ref);
+}
+
+static void dev_dax_percpu_release(struct percpu_ref *ref)
+{
+	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+
+	dev_dbg(&dev_dax->dev, "%s\n", __func__);
+	complete(&dev_dax->cmp);
+}
+
+static void dev_dax_percpu_exit(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+
+	dev_dbg(&dev_dax->dev, "%s\n", __func__);
+	wait_for_completion(&dev_dax->cmp);
+	percpu_ref_exit(ref);
+}
+
+static void dev_dax_percpu_kill(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+
+	dev_dbg(&dev_dax->dev, "%s\n", __func__);
+	percpu_ref_kill(ref);
+}
+
 static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
 		const char *func)
 {
@@ -416,10 +449,42 @@ static int dev_dax_probe(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
 	struct dax_device *dax_dev = dev_dax->dax_dev;
+	struct resource *res = &dev_dax->region->res;
 	struct inode *inode;
 	struct cdev *cdev;
+	void *addr;
 	int rc;
 
+	/* 1:1 map region resource range to device-dax instance range */
+	if (!devm_request_mem_region(dev, res->start, resource_size(res),
+				dev_name(dev))) {
+		dev_warn(dev, "could not reserve region %pR\n", res);
+		return -EBUSY;
+	}
+
+	init_completion(&dev_dax->cmp);
+	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
+			GFP_KERNEL);
+	if (rc)
+		return rc;
+
+	rc = devm_add_action_or_reset(dev, dev_dax_percpu_exit, &dev_dax->ref);
+	if (rc)
+		return rc;
+
+	dev_dax->pgmap.ref = &dev_dax->ref;
+	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
+	if (IS_ERR(addr)) {
+		devm_remove_action(dev, dev_dax_percpu_exit, &dev_dax->ref);
+		percpu_ref_exit(&dev_dax->ref);
+		return PTR_ERR(addr);
+	}
+
+	rc = devm_add_action_or_reset(dev, dev_dax_percpu_kill,
+			&dev_dax->ref);
+	if (rc)
+		return rc;
+
 	inode = dax_inode(dax_dev);
 	cdev = inode->i_cdev;
 	cdev_init(cdev, &dax_fops);
diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index c94f17e662bd..d3cefa7868ac 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -18,55 +18,16 @@
 #include "../nvdimm/nd.h"
 #include "bus.h"
 
-struct dax_pmem {
-	struct device *dev;
-	struct percpu_ref ref;
-	struct dev_pagemap pgmap;
-	struct completion cmp;
-};
-
-static struct dax_pmem *to_dax_pmem(struct percpu_ref *ref)
-{
-	return container_of(ref, struct dax_pmem, ref);
-}
-
-static void dax_pmem_percpu_release(struct percpu_ref *ref)
-{
-	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
-
-	dev_dbg(dax_pmem->dev, "trace\n");
-	complete(&dax_pmem->cmp);
-}
-
-static void dax_pmem_percpu_exit(void *data)
-{
-	struct percpu_ref *ref = data;
-	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
-
-	dev_dbg(dax_pmem->dev, "trace\n");
-	wait_for_completion(&dax_pmem->cmp);
-	percpu_ref_exit(ref);
-}
-
-static void dax_pmem_percpu_kill(void *data)
-{
-	struct percpu_ref *ref = data;
-	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
-
-	dev_dbg(dax_pmem->dev, "trace\n");
-	percpu_ref_kill(ref);
-}
-
 static int dax_pmem_probe(struct device *dev)
 {
-	void *addr;
 	struct resource res;
 	int rc, id, region_id;
+	resource_size_t offset;
 	struct nd_pfn_sb *pfn_sb;
 	struct dev_dax *dev_dax;
-	struct dax_pmem *dax_pmem;
 	struct nd_namespace_io *nsio;
 	struct dax_region *dax_region;
+	struct dev_pagemap pgmap = { 0 };
 	struct nd_namespace_common *ndns;
 	struct nd_dax *nd_dax = to_nd_dax(dev);
 	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
@@ -76,68 +37,37 @@ static int dax_pmem_probe(struct device *dev)
 		return PTR_ERR(ndns);
 	nsio = to_nd_namespace_io(&ndns->dev);
 
-	dax_pmem = devm_kzalloc(dev, sizeof(*dax_pmem), GFP_KERNEL);
-	if (!dax_pmem)
-		return -ENOMEM;
-
 	/* parse the 'pfn' info block via ->rw_bytes */
 	rc = devm_nsio_enable(dev, nsio);
 	if (rc)
 		return rc;
-	rc = nvdimm_setup_pfn(nd_pfn, &dax_pmem->pgmap);
+	rc = nvdimm_setup_pfn(nd_pfn, &pgmap);
 	if (rc)
 		return rc;
 	devm_nsio_disable(dev, nsio);
 
-	pfn_sb = nd_pfn->pfn_sb;
-
-	if (!devm_request_mem_region(dev, nsio->res.start,
-				resource_size(&nsio->res),
+	/* reserve the metadata area, device-dax will reserve the data */
+        pfn_sb = nd_pfn->pfn_sb;
+	offset = le64_to_cpu(pfn_sb->dataoff);
+	if (!devm_request_mem_region(dev, nsio->res.start, offset,
 				dev_name(&ndns->dev))) {
-		dev_warn(dev, "could not reserve region %pR\n", &nsio->res);
-		return -EBUSY;
-	}
-
-	dax_pmem->dev = dev;
-	init_completion(&dax_pmem->cmp);
-	rc = percpu_ref_init(&dax_pmem->ref, dax_pmem_percpu_release, 0,
-			GFP_KERNEL);
-	if (rc)
-		return rc;
-
-	rc = devm_add_action(dev, dax_pmem_percpu_exit, &dax_pmem->ref);
-	if (rc) {
-		percpu_ref_exit(&dax_pmem->ref);
-		return rc;
-	}
-
-	dax_pmem->pgmap.ref = &dax_pmem->ref;
-	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
-	if (IS_ERR(addr)) {
-		devm_remove_action(dev, dax_pmem_percpu_exit, &dax_pmem->ref);
-		percpu_ref_exit(&dax_pmem->ref);
-		return PTR_ERR(addr);
-	}
-
-	rc = devm_add_action_or_reset(dev, dax_pmem_percpu_kill,
-							&dax_pmem->ref);
-	if (rc)
-		return rc;
-
-	/* adjust the dax_region resource to the start of data */
-	memcpy(&res, &dax_pmem->pgmap.res, sizeof(res));
-	res.start += le64_to_cpu(pfn_sb->dataoff);
+                dev_warn(dev, "could not reserve metadata\n");
+                return -EBUSY;
+        }
 
 	rc = sscanf(dev_name(&ndns->dev), "namespace%d.%d", &region_id, &id);
 	if (rc != 2)
 		return -EINVAL;
 
+	/* adjust the dax_region resource to the start of data */
+	memcpy(&res, &pgmap.res, sizeof(res));
+	res.start += offset;
 	dax_region = alloc_dax_region(dev, region_id, &res,
 			le32_to_cpu(pfn_sb->align), PFN_DEV|PFN_MAP);
 	if (!dax_region)
 		return -ENOMEM;
 
-	dev_dax = devm_create_dev_dax(dax_region, id);
+	dev_dax = devm_create_dev_dax(dax_region, id, &pgmap);
 
 	/* child dev_dax instances now own the lifetime of the dax_region */
 	dax_region_put(dax_region);
