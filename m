Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0556B0492
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m194so25247376qke.7
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o62si1838252qkd.232.2017.08.16.17.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:27 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory region v3
Date: Wed, 16 Aug 2017 20:05:48 -0400
Message-Id: <20170817000548.32038-20-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Unlike unaddressable memory, coherent device memory has a real
resource associated with it on the system (as CPU can address
it). Add a new helper to hotplug such memory within the HMM
framework.

Changed since v2:
  - s/host/public
Changed since v1:
  - s/public/host

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Balbir Singh <bsingharora@gmail.com>
---
 include/linux/hmm.h |  3 ++
 mm/hmm.c            | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 86 insertions(+), 5 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 79e63178fd87..5866f3194c26 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -443,6 +443,9 @@ struct hmm_devmem {
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
 				  unsigned long size);
+struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
+					   struct device *device,
+					   struct resource *res);
 void hmm_devmem_remove(struct hmm_devmem *devmem);
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 1a1e79d390c1..3faa4d40295e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -854,7 +854,11 @@ static void hmm_devmem_release(struct device *dev, void *data)
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
@@ -890,7 +894,11 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
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
@@ -935,9 +943,15 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	 * over the device memory is un-accessible thus we do not want to
 	 * create a linear mapping for the memory like arch_add_memory()
 	 * would do.
+	 *
+	 * For device public memory, which is accesible by the CPU, we do
+	 * want the linear mapping and thus use arch_add_memory().
 	 */
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
@@ -1084,6 +1098,67 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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
@@ -1097,6 +1172,7 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
 {
 	resource_size_t start, size;
 	struct device *device;
+	bool cdm = false;
 
 	if (!devmem)
 		return;
@@ -1105,11 +1181,13 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
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
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
