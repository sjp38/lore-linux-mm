Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60B516B033D
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:24:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h9-v6so10564779pgs.11
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:24:55 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 102-v6si9347637plf.65.2018.10.30.20.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:24:53 -0700 (PDT)
Subject: [PATCH 3/8] device-dax: Remove multi-resource infrastructure
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:13:05 -0700
Message-ID: <154095558513.3271337.6460925877189898414.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

The multi-resource implementation anticipated discontiguous sub-division
support. That has not yet materialized, delete the infrastructure and
related code.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax-private.h      |    4 ---
 drivers/dax/device-dax.h       |    3 +-
 drivers/dax/device.c           |   49 +++++++---------------------------------
 drivers/dax/pmem.c             |    3 +-
 tools/testing/nvdimm/dax-dev.c |   16 ++-----------
 5 files changed, 13 insertions(+), 62 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index 9b393c218fe4..dbd077653b5c 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -39,14 +39,10 @@ struct dax_region {
  * @region - parent region
  * @dax_dev - core dax functionality
  * @dev - device core
- * @num_resources - number of physical address extents in this device
- * @res - array of physical address ranges
  */
 struct dev_dax {
 	struct dax_region *region;
 	struct dax_device *dax_dev;
 	struct device dev;
-	int num_resources;
-	struct resource res[0];
 };
 #endif
diff --git a/drivers/dax/device-dax.h b/drivers/dax/device-dax.h
index 4f1c69e1b3a2..e9be99584b92 100644
--- a/drivers/dax/device-dax.h
+++ b/drivers/dax/device-dax.h
@@ -19,6 +19,5 @@ struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 		struct resource *res, unsigned int align, unsigned long flags);
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
-		int id, struct resource *res, int count);
+struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id);
 #endif /* __DEVICE_DAX_H__ */
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 811c1015194c..db12e24b8005 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -151,11 +151,7 @@ static ssize_t size_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
-	unsigned long long size = 0;
-	int i;
-
-	for (i = 0; i < dev_dax->num_resources; i++)
-		size += resource_size(&dev_dax->res[i]);
+	unsigned long long size = resource_size(&dev_dax->region->res);
 
 	return sprintf(buf, "%llu\n", size);
 }
@@ -224,21 +220,11 @@ static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
 __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 		unsigned long size)
 {
-	struct resource *res;
-	/* gcc-4.6.3-nolibc for i386 complains that this is uninitialized */
-	phys_addr_t uninitialized_var(phys);
-	int i;
-
-	for (i = 0; i < dev_dax->num_resources; i++) {
-		res = &dev_dax->res[i];
-		phys = pgoff * PAGE_SIZE + res->start;
-		if (phys >= res->start && phys <= res->end)
-			break;
-		pgoff -= PHYS_PFN(resource_size(res));
-	}
+	struct resource *res = &dev_dax->region->res;
+	phys_addr_t phys;
 
-	if (i < dev_dax->num_resources) {
-		res = &dev_dax->res[i];
+	phys = pgoff * PAGE_SIZE + res->start;
+	if (phys >= res->start && phys <= res->end) {
 		if (phys + size - 1 <= res->end)
 			return phys;
 	}
@@ -608,8 +594,7 @@ static void unregister_dev_dax(void *dev)
 	put_device(dev);
 }
 
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
-		int id, struct resource *res, int count)
+struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id)
 {
 	struct device *parent = dax_region->dev;
 	struct dax_device *dax_dev;
@@ -617,29 +602,12 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	struct inode *inode;
 	struct device *dev;
 	struct cdev *cdev;
-	int rc, i;
+	int rc;
 
-	if (!count)
-		return ERR_PTR(-EINVAL);
-
-	dev_dax = kzalloc(struct_size(dev_dax, res, count), GFP_KERNEL);
+	dev_dax = kzalloc(sizeof(*dev_dax), GFP_KERNEL);
 	if (!dev_dax)
 		return ERR_PTR(-ENOMEM);
 
-	for (i = 0; i < count; i++) {
-		if (!IS_ALIGNED(res[i].start, dax_region->align)
-				|| !IS_ALIGNED(resource_size(&res[i]),
-					dax_region->align)) {
-			rc = -EINVAL;
-			break;
-		}
-		dev_dax->res[i].start = res[i].start;
-		dev_dax->res[i].end = res[i].end;
-	}
-
-	if (i < count)
-		goto err;
-
 	/*
 	 * No 'host' or dax_operations since there is no access to this
 	 * device outside of mmap of the resulting character device.
@@ -659,7 +627,6 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	cdev_init(cdev, &dax_fops);
 	cdev->owner = parent->driver->owner;
 
-	dev_dax->num_resources = count;
 	dev_dax->dax_dev = dax_dev;
 	dev_dax->region = dax_region;
 	kref_get(&dax_region->kref);
diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 3afae503fc42..23bc8ed40e84 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -137,8 +137,7 @@ static int dax_pmem_probe(struct device *dev)
 	if (!dax_region)
 		return -ENOMEM;
 
-	/* TODO: support for subdividing a dax region... */
-	dev_dax = devm_create_dev_dax(dax_region, id, &res, 1);
+	dev_dax = devm_create_dev_dax(dax_region, id);
 
 	/* child dev_dax instances now own the lifetime of the dax_region */
 	dax_region_put(dax_region);
diff --git a/tools/testing/nvdimm/dax-dev.c b/tools/testing/nvdimm/dax-dev.c
index 36ee3d8797c3..f36e708265b8 100644
--- a/tools/testing/nvdimm/dax-dev.c
+++ b/tools/testing/nvdimm/dax-dev.c
@@ -17,20 +17,11 @@
 phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 		unsigned long size)
 {
-	struct resource *res;
+	struct resource *res = &dev_dax->region->res;
 	phys_addr_t addr;
-	int i;
 
-	for (i = 0; i < dev_dax->num_resources; i++) {
-		res = &dev_dax->res[i];
-		addr = pgoff * PAGE_SIZE + res->start;
-		if (addr >= res->start && addr <= res->end)
-			break;
-		pgoff -= PHYS_PFN(resource_size(res));
-	}
-
-	if (i < dev_dax->num_resources) {
-		res = &dev_dax->res[i];
+	addr = pgoff * PAGE_SIZE + res->start;
+	if (addr >= res->start && addr <= res->end) {
 		if (addr + size - 1 <= res->end) {
 			if (get_nfit_res(addr)) {
 				struct page *page;
@@ -44,6 +35,5 @@ phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 				return addr;
 		}
 	}
-
 	return -1;
 }
