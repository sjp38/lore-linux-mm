Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44B396B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:45:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s3-v6so10037369pfh.0
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:45:28 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o24-v6si11348838pgv.80.2018.05.21.15.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:45:27 -0700 (PDT)
Subject: [PATCH 3/5] mm, hmm: use devm semantics for hmm_devmem_{add, remove}
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 15:35:29 -0700
Message-ID: <152694212973.5484.9009059511258430529.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

devm semantics arrange for resources to be torn down when
device-driver-probe fails or when device-driver-release completes.
Similar to devm_memremap_pages() there is no need to support an explicit
remove operation when the users properly adhere to devm semantics.

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/vm/hmm.txt |    1 
 include/linux/hmm.h      |    4 -
 mm/hmm.c                 |  127 +++++++++++-----------------------------------
 3 files changed, 32 insertions(+), 100 deletions(-)

diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
index 2d1d6f69e91b..b2f944b87c5e 100644
--- a/Documentation/vm/hmm.txt
+++ b/Documentation/vm/hmm.txt
@@ -285,7 +285,6 @@ region needing a struct page. This is offered through a very simple API:
  struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
                                    struct device *device,
                                    unsigned long size);
- void hmm_devmem_remove(struct hmm_devmem *devmem);
 
 The hmm_devmem_ops is where most of the important things are:
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 39988924de3a..880f6bb9485c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -499,8 +499,7 @@ struct hmm_devmem {
  * enough and allocate struct page for it.
  *
  * The device driver can wrap the hmm_devmem struct inside a private device
- * driver struct. The device driver must call hmm_devmem_remove() before the
- * device goes away and before freeing the hmm_devmem struct memory.
+ * driver struct.
  */
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
@@ -508,7 +507,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct device *device,
 					   struct resource *res);
-void hmm_devmem_remove(struct hmm_devmem *devmem);
 
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
diff --git a/mm/hmm.c b/mm/hmm.c
index 486dc394a5a3..8aa9d9fbb87b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -993,15 +993,17 @@ static void hmm_devmem_radix_release(struct resource *resource)
 	mutex_unlock(&hmm_devmem_lock);
 }
 
-static void hmm_devmem_release(struct device *dev, void *data)
+static void hmm_devmem_release(void *data)
 {
 	struct hmm_devmem *devmem = data;
+	struct device *dev = devmem->device;
 	struct resource *resource = devmem->resource;
+	struct dev_pagemap *pgmap = &devmem->pagemap;
 	unsigned long start_pfn, npages;
 	struct zone *zone;
 	struct page *page;
 
-	if (percpu_ref_tryget_live(&devmem->ref)) {
+	if (pgmap->registered && percpu_ref_tryget_live(&devmem->ref)) {
 		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
 		percpu_ref_put(&devmem->ref);
 	}
@@ -1129,19 +1131,6 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	return ret;
 }
 
-static int hmm_devmem_match(struct device *dev, void *data, void *match_data)
-{
-	struct hmm_devmem *devmem = data;
-
-	return devmem->resource == match_data;
-}
-
-static void hmm_devmem_pages_remove(struct hmm_devmem *devmem)
-{
-	devres_release(devmem->device, &hmm_devmem_release,
-		       &hmm_devmem_match, devmem->resource);
-}
-
 /*
  * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
  *
@@ -1169,8 +1158,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	static_branch_enable(&device_private_key);
 
-	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
-				   GFP_KERNEL, dev_to_node(device));
+	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
 
@@ -1184,11 +1172,11 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
 			      0, GFP_KERNEL);
 	if (ret)
-		goto error_percpu_ref;
+		return ERR_PTR(ret);
 
-	ret = devm_add_action(device, hmm_devmem_ref_exit, &devmem->ref);
+	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit, &devmem->ref);
 	if (ret)
-		goto error_devm_add_action;
+		return ERR_PTR(ret);
 
 	size = ALIGN(size, PA_SECTION_SIZE);
 	addr = min((unsigned long)iomem_resource.end,
@@ -1208,16 +1196,12 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 		devmem->resource = devm_request_mem_region(device, addr, size,
 							   dev_name(device));
-		if (!devmem->resource) {
-			ret = -ENOMEM;
-			goto error_no_resource;
-		}
+		if (!devmem->resource)
+			return ERR_PTR(-ENOMEM);
 		break;
 	}
-	if (!devmem->resource) {
-		ret = -ERANGE;
-		goto error_no_resource;
-	}
+	if (!devmem->resource)
+		return ERR_PTR(-ERANGE);
 
 	devmem->resource->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
@@ -1226,28 +1210,18 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	ret = hmm_devmem_pages_create(devmem);
 	if (ret)
-		goto error_pages;
+		return ERR_PTR(ret);
 
-	devres_add(device, devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
+	if (ret)
+		return ERR_PTR(ret);
+	devmem->pagemap.registered = true;
 
-	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
-	if (ret) {
-		hmm_devmem_remove(devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill, &devmem->ref);
+	if (ret)
 		return ERR_PTR(ret);
-	}
 
 	return devmem;
-
-error_pages:
-	devm_release_mem_region(device, devmem->resource->start,
-				resource_size(devmem->resource));
-error_no_resource:
-error_devm_add_action:
-	hmm_devmem_ref_kill(&devmem->ref);
-	hmm_devmem_ref_exit(&devmem->ref);
-error_percpu_ref:
-	devres_free(devmem);
-	return ERR_PTR(ret);
 }
 EXPORT_SYMBOL(hmm_devmem_add);
 
@@ -1263,8 +1237,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 
 	static_branch_enable(&device_private_key);
 
-	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
-				   GFP_KERNEL, dev_to_node(device));
+	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
 
@@ -1278,12 +1251,12 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
 			      0, GFP_KERNEL);
 	if (ret)
-		goto error_percpu_ref;
+		return ERR_PTR(ret);
 
-	ret = devm_add_action(device, hmm_devmem_ref_exit, &devmem->ref);
+	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit,
+			&devmem->ref);
 	if (ret)
-		goto error_devm_add_action;
-
+		return ERR_PTR(ret);
 
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
@@ -1291,60 +1264,22 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 
 	ret = hmm_devmem_pages_create(devmem);
 	if (ret)
-		goto error_devm_add_action;
+		return ERR_PTR(ret);
 
-	devres_add(device, devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
+	if (ret)
+		return ERR_PTR(ret);
+	devmem->pagemap.registered = true;
 
-	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
-	if (ret) {
-		hmm_devmem_remove(devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill, &devmem->ref);
+	if (ret)
 		return ERR_PTR(ret);
-	}
 
 	return devmem;
-
-error_devm_add_action:
-	hmm_devmem_ref_kill(&devmem->ref);
-	hmm_devmem_ref_exit(&devmem->ref);
-error_percpu_ref:
-	devres_free(devmem);
-	return ERR_PTR(ret);
 }
 EXPORT_SYMBOL(hmm_devmem_add_resource);
 
 /*
- * hmm_devmem_remove() - remove device memory (kill and free ZONE_DEVICE)
- *
- * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
- *
- * This will hot-unplug memory that was hotplugged by hmm_devmem_add on behalf
- * of the device driver. It will free struct page and remove the resource that
- * reserved the physical address range for this device memory.
- */
-void hmm_devmem_remove(struct hmm_devmem *devmem)
-{
-	resource_size_t start, size;
-	struct device *device;
-	bool cdm = false;
-
-	if (!devmem)
-		return;
-
-	device = devmem->device;
-	start = devmem->resource->start;
-	size = resource_size(devmem->resource);
-
-	cdm = devmem->resource->desc == IORES_DESC_DEVICE_PUBLIC_MEMORY;
-	hmm_devmem_ref_kill(&devmem->ref);
-	hmm_devmem_ref_exit(&devmem->ref);
-	hmm_devmem_pages_remove(devmem);
-
-	if (!cdm)
-		devm_release_mem_region(device, start, size);
-}
-EXPORT_SYMBOL(hmm_devmem_remove);
-
-/*
  * A device driver that wants to handle multiple devices memory through a
  * single fake device can use hmm_device to do so. This is purely a helper
  * and it is not needed to make use of any HMM functionality.
