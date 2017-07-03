Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A698E6B02F4
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 17:14:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q38so46471866qtq.4
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 14:14:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 23si8820510qtt.185.2017.07.03.14.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 14:14:27 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 3/5] mm/hmm: add new helper to hotplug CDM memory region
Date: Mon,  3 Jul 2017 17:14:13 -0400
Message-Id: <20170703211415.11283-4-jglisse@redhat.com>
In-Reply-To: <20170703211415.11283-1-jglisse@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Unlike unaddressable memory, coherent device memory has a real
resource associated with it on the system (as CPU can address
it). Add a new helper to hotplug such memory within the HMM
framework.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Balbir Singh <bsingharora@gmail.com>
---
 include/linux/hmm.h |  3 ++
 mm/hmm.c            | 85 +++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 83 insertions(+), 5 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index a40288309fd2..e44cb8edb137 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -392,6 +392,9 @@ struct hmm_devmem {
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
 				  unsigned long size);
+struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
+					   struct device *device,
+					   struct resource *res);
 void hmm_devmem_remove(struct hmm_devmem *devmem);
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index eadf70829c34..28e54e3b4e1d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -849,7 +849,11 @@ static void hmm_devmem_release(struct device *dev, void *data)
 	zone = page_zone(page);
 
 	mem_hotplug_begin();
-	__remove_pages(zone, start_pfn, npages);
+	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
+		__remove_pages(zone, start_pfn, npages);
+	else
+		arch_remove_memory(start_pfn << PAGE_SHIFT,
+				   npages << PAGE_SHIFT);
 	mem_hotplug_done();
 
 	hmm_devmem_radix_release(resource);
@@ -885,7 +889,11 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	if (is_ram == REGION_INTERSECTS)
 		return -ENXIO;
 
-	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+	if (devmem->resource->desc == IORES_DESC_DEVICE_PUBLIC_MEMORY)
+		devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
+	else
+		devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+
 	devmem->pagemap.res = devmem->resource;
 	devmem->pagemap.page_fault = hmm_devmem_fault;
 	devmem->pagemap.page_free = hmm_devmem_free;
@@ -924,8 +932,11 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 		nid = numa_mem_id();
 
 	mem_hotplug_begin();
-	ret = add_pages(nid, align_start >> PAGE_SHIFT,
-			align_size >> PAGE_SHIFT, false);
+	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
+		ret = arch_add_memory(nid, align_start, align_size, false);
+	else
+		ret = add_pages(nid, align_start >> PAGE_SHIFT,
+				align_size >> PAGE_SHIFT, false);
 	if (ret) {
 		mem_hotplug_done();
 		goto error_add_memory;
@@ -1075,6 +1086,67 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 }
 EXPORT_SYMBOL(hmm_devmem_add);
 
+struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
+					   struct device *device,
+					   struct resource *res)
+{
+	struct hmm_devmem *devmem;
+	int ret;
+
+	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
+		return ERR_PTR(-EINVAL);
+
+	static_branch_enable(&device_private_key);
+
+	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
+				   GFP_KERNEL, dev_to_node(device));
+	if (!devmem)
+		return ERR_PTR(-ENOMEM);
+
+	init_completion(&devmem->completion);
+	devmem->pfn_first = -1UL;
+	devmem->pfn_last = -1UL;
+	devmem->resource = res;
+	devmem->device = device;
+	devmem->ops = ops;
+
+	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
+			      0, GFP_KERNEL);
+	if (ret)
+		goto error_percpu_ref;
+
+	ret = devm_add_action(device, hmm_devmem_ref_exit, &devmem->ref);
+	if (ret)
+		goto error_devm_add_action;
+
+
+	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
+	devmem->pfn_last = devmem->pfn_first +
+			   (resource_size(devmem->resource) >> PAGE_SHIFT);
+
+	ret = hmm_devmem_pages_create(devmem);
+	if (ret)
+		goto error_devm_add_action;
+
+	devres_add(device, devmem);
+
+	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
+	if (ret) {
+		hmm_devmem_remove(devmem);
+		return ERR_PTR(ret);
+	}
+
+	return devmem;
+
+error_devm_add_action:
+	hmm_devmem_ref_kill(&devmem->ref);
+	hmm_devmem_ref_exit(&devmem->ref);
+error_percpu_ref:
+	devres_free(devmem);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(hmm_devmem_add_resource);
+
 /*
  * hmm_devmem_remove() - remove device memory (kill and free ZONE_DEVICE)
  *
@@ -1088,6 +1160,7 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
 {
 	resource_size_t start, size;
 	struct device *device;
+	bool cdm = false;
 
 	if (!devmem)
 		return;
@@ -1096,11 +1169,13 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
 	start = devmem->resource->start;
 	size = resource_size(devmem->resource);
 
+	cdm = devmem->resource->desc == IORES_DESC_DEVICE_PUBLIC_MEMORY;
 	hmm_devmem_ref_kill(&devmem->ref);
 	hmm_devmem_ref_exit(&devmem->ref);
 	hmm_devmem_pages_remove(devmem);
 
-	devm_release_mem_region(device, start, size);
+	if (!cdm)
+		devm_release_mem_region(device, start, size);
 }
 EXPORT_SYMBOL(hmm_devmem_remove);
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
