Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09C546B0335
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:24:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t10-v6so11351735plh.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:24:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v184si10838756pgd.295.2018.10.30.20.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:24:48 -0700 (PDT)
Subject: [PATCH 2/8] device-dax: Kill dax_region base
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:13:00 -0700
Message-ID: <154095558001.3271337.4593586036083228319.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

Nothing consumes this attribute of a region and devres otherwise
remembers the value for de-allocation purposes.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax-private.h |    2 --
 drivers/dax/device-dax.h  |    5 ++---
 drivers/dax/device.c      |    3 +--
 drivers/dax/pmem.c        |    2 +-
 4 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index d1b36a42132f..9b393c218fe4 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -19,7 +19,6 @@
 /**
  * struct dax_region - mapping infrastructure for dax devices
  * @id: kernel-wide unique region for a memory range
- * @base: linear address corresponding to @res
  * @kref: to pin while other agents have a need to do lookups
  * @dev: parent device backing this region
  * @align: allocation and mapping alignment for child dax devices
@@ -28,7 +27,6 @@
  */
 struct dax_region {
 	int id;
-	void *base;
 	struct kref kref;
 	struct device *dev;
 	unsigned int align;
diff --git a/drivers/dax/device-dax.h b/drivers/dax/device-dax.h
index 688b051750bd..4f1c69e1b3a2 100644
--- a/drivers/dax/device-dax.h
+++ b/drivers/dax/device-dax.h
@@ -17,9 +17,8 @@ struct dev_dax;
 struct resource;
 struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
-struct dax_region *alloc_dax_region(struct device *parent,
-		int region_id, struct resource *res, unsigned int align,
-		void *addr, unsigned long flags);
+struct dax_region *alloc_dax_region(struct device *parent, int region_id,
+		struct resource *res, unsigned int align, unsigned long flags);
 struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 		int id, struct resource *res, int count);
 #endif /* __DEVICE_DAX_H__ */
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index a5a670c1cd58..811c1015194c 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -100,7 +100,7 @@ static void dax_region_unregister(void *region)
 }
 
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
-		struct resource *res, unsigned int align, void *addr,
+		struct resource *res, unsigned int align,
 		unsigned long pfn_flags)
 {
 	struct dax_region *dax_region;
@@ -130,7 +130,6 @@ struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 	dax_region->id = region_id;
 	dax_region->align = align;
 	dax_region->dev = parent;
-	dax_region->base = addr;
 	if (sysfs_create_groups(&parent->kobj, dax_region_attribute_groups)) {
 		kfree(dax_region);
 		return NULL;
diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 99e2aace8078..3afae503fc42 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -133,7 +133,7 @@ static int dax_pmem_probe(struct device *dev)
 		return -EINVAL;
 
 	dax_region = alloc_dax_region(dev, region_id, &res,
-			le32_to_cpu(pfn_sb->align), addr, PFN_DEV|PFN_MAP);
+			le32_to_cpu(pfn_sb->align), PFN_DEV|PFN_MAP);
 	if (!dax_region)
 		return -ENOMEM;
 
