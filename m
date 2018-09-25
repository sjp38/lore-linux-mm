Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2B5D8E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:27:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s15-v6so3014371pgv.9
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 23:27:10 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s7-v6si1485627pgj.480.2018.09.24.23.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 23:27:09 -0700 (PDT)
Subject: [PATCH v6 5/7] mm, hmm: Use devm semantics for hmm_devmem_{add,
 remove}
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Sep 2018 23:15:21 -0700
Message-ID: <153785612119.283091.17043843780612326673.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153785609460.283091.17422092801700439095.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153785609460.283091.17422092801700439095.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>=?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

devm semantics arrange for resources to be torn down when
device-driver-probe fails or when device-driver-release completes.
Similar to devm_memremap_pages() there is no need to support an explicit
remove operation when the users properly adhere to devm semantics.

Note that devm_kzalloc() automatically handles allocating node-local
memory.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hmm.h |    4 --
 mm/hmm.c            |  127 ++++++++++-----------------------------------------
 2 files changed, 25 insertions(+), 106 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4c92e3ba3e16..5ec8635f602c 100644
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
index c968e49f7a0c..ec1d9eccf176 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -939,7 +939,6 @@ static void hmm_devmem_ref_exit(void *data)
 
 	devmem = container_of(ref, struct hmm_devmem, ref);
 	percpu_ref_exit(ref);
-	devm_remove_action(devmem->device, &hmm_devmem_ref_exit, data);
 }
 
 static void hmm_devmem_ref_kill(void *data)
@@ -950,7 +949,6 @@ static void hmm_devmem_ref_kill(void *data)
 	devmem = container_of(ref, struct hmm_devmem, ref);
 	percpu_ref_kill(ref);
 	wait_for_completion(&devmem->completion);
-	devm_remove_action(devmem->device, &hmm_devmem_ref_kill, data);
 }
 
 static int hmm_devmem_fault(struct vm_area_struct *vma,
@@ -988,7 +986,7 @@ static void hmm_devmem_radix_release(struct resource *resource)
 	mutex_unlock(&hmm_devmem_lock);
 }
 
-static void hmm_devmem_release(struct device *dev, void *data)
+static void hmm_devmem_release(void *data)
 {
 	struct hmm_devmem *devmem = data;
 	struct resource *resource = devmem->resource;
@@ -996,11 +994,6 @@ static void hmm_devmem_release(struct device *dev, void *data)
 	struct zone *zone;
 	struct page *page;
 
-	if (percpu_ref_tryget_live(&devmem->ref)) {
-		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
-		percpu_ref_put(&devmem->ref);
-	}
-
 	/* pages are dead and unused, undo the arch mapping */
 	start_pfn = (resource->start & ~(PA_SECTION_SIZE - 1)) >> PAGE_SHIFT;
 	npages = ALIGN(resource_size(resource), PA_SECTION_SIZE) >> PAGE_SHIFT;
@@ -1124,19 +1117,6 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
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
@@ -1164,8 +1144,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	dev_pagemap_get_ops();
 
-	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
-				   GFP_KERNEL, dev_to_node(device));
+	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
 
@@ -1179,11 +1158,11 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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
@@ -1203,16 +1182,12 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
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
@@ -1221,28 +1196,13 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	ret = hmm_devmem_pages_create(devmem);
 	if (ret)
-		goto error_pages;
-
-	devres_add(device, devmem);
+		return ERR_PTR(ret);
 
-	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
-	if (ret) {
-		hmm_devmem_remove(devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
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
 
@@ -1258,8 +1218,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 
 	dev_pagemap_get_ops();
 
-	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
-				   GFP_KERNEL, dev_to_node(device));
+	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
 
@@ -1273,12 +1232,12 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
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
@@ -1286,59 +1245,21 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 
 	ret = hmm_devmem_pages_create(devmem);
 	if (ret)
-		goto error_devm_add_action;
+		return ERR_PTR(ret);
 
-	devres_add(device, devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
+	if (ret)
+		return ERR_PTR(ret);
 
-	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
-	if (ret) {
-		hmm_devmem_remove(devmem);
+	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill,
+			&devmem->ref);
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
 
-/*
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
 /*
  * A device driver that wants to handle multiple devices memory through a
  * single fake device can use hmm_device to do so. This is purely a helper
