Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7786B032F
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:24:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b24-v6so10618922pgh.5
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:24:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w20-v6si24205618plp.260.2018.10.30.20.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:24:44 -0700 (PDT)
Subject: [PATCH 1/8] device-dax: Kill dax_region ida
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:12:54 -0700
Message-ID: <154095557491.3271337.10354816564776020500.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

Commit bbb3be170ac2 "device-dax: fix sysfs duplicate warnings" arranged
for passing a dax instance-id to devm_create_dax_dev(), rather than
generating one internally. Remove the dax_region ida and related code.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax-private.h |    3 ---
 drivers/dax/device.c      |   24 +++---------------------
 2 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index b6fc4f04636d..d1b36a42132f 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -28,7 +28,6 @@
  */
 struct dax_region {
 	int id;
-	struct ida ida;
 	void *base;
 	struct kref kref;
 	struct device *dev;
@@ -42,7 +41,6 @@ struct dax_region {
  * @region - parent region
  * @dax_dev - core dax functionality
  * @dev - device core
- * @id - child id in the region
  * @num_resources - number of physical address extents in this device
  * @res - array of physical address ranges
  */
@@ -50,7 +48,6 @@ struct dev_dax {
 	struct dax_region *region;
 	struct dax_device *dax_dev;
 	struct device dev;
-	int id;
 	int num_resources;
 	struct resource res[0];
 };
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 948806e57cee..a5a670c1cd58 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -128,7 +128,6 @@ struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 	dax_region->pfn_flags = pfn_flags;
 	kref_init(&dax_region->kref);
 	dax_region->id = region_id;
-	ida_init(&dax_region->ida);
 	dax_region->align = align;
 	dax_region->dev = parent;
 	dax_region->base = addr;
@@ -582,8 +581,6 @@ static void dev_dax_release(struct device *dev)
 	struct dax_region *dax_region = dev_dax->region;
 	struct dax_device *dax_dev = dev_dax->dax_dev;
 
-	if (dev_dax->id >= 0)
-		ida_simple_remove(&dax_region->ida, dev_dax->id);
 	dax_region_put(dax_region);
 	put_dax(dax_dev);
 	kfree(dev_dax);
@@ -642,19 +639,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	}
 
 	if (i < count)
-		goto err_id;
-
-	if (id < 0) {
-		id = ida_simple_get(&dax_region->ida, 0, 0, GFP_KERNEL);
-		dev_dax->id = id;
-		if (id < 0) {
-			rc = id;
-			goto err_id;
-		}
-	} else {
-		/* region provider owns @id lifetime */
-		dev_dax->id = -1;
-	}
+		goto err;
 
 	/*
 	 * No 'host' or dax_operations since there is no access to this
@@ -663,7 +648,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	dax_dev = alloc_dax(dev_dax, NULL, NULL);
 	if (!dax_dev) {
 		rc = -ENOMEM;
-		goto err_dax;
+		goto err;
 	}
 
 	/* from here on we're committed to teardown via dax_dev_release() */
@@ -700,10 +685,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 
 	return dev_dax;
 
- err_dax:
-	if (dev_dax->id >= 0)
-		ida_simple_remove(&dax_region->ida, dev_dax->id);
- err_id:
+ err:
 	kfree(dev_dax);
 
 	return ERR_PTR(rc);
