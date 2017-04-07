Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABE656B03A0
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 16:29:13 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l16so24598921qtc.14
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 13:29:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 65si4531621qkb.289.2017.04.07.13.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 13:29:12 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC HMM CDM 2/3] mm/hmm: add new helper to hotplug CDM memory region
Date: Fri,  7 Apr 2017 16:28:52 -0400
Message-Id: <1491596933-21669-3-git-send-email-jglisse@redhat.com>
In-Reply-To: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
References: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <balbir@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Unlike unaddressable memory, coherent device memory has a real
resource associated with it on the system (as CPU can address
it). Add a new helper to hotplug such memory within the HMM
framework.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h |  3 +++
 mm/hmm.c            | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 374e5fd..e4fda18 100644
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
 
 int hmm_devmem_fault_range(struct hmm_devmem *devmem,
diff --git a/mm/hmm.c b/mm/hmm.c
index ff8ec59..28c7fcb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1038,6 +1038,63 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 }
 EXPORT_SYMBOL(hmm_devmem_add);
 
+struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
+					   struct device *device,
+					   struct resource *res)
+{
+	struct hmm_devmem *devmem;
+	int ret;
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
+	devmem->resource->desc = MEMORY_DEVICE_CACHE_COHERENT;
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
@@ -1051,6 +1108,7 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
 {
 	resource_size_t start, size;
 	struct device *device;
+	bool cdm = false;
 
 	if (!devmem)
 		return;
@@ -1059,11 +1117,13 @@ void hmm_devmem_remove(struct hmm_devmem *devmem)
 	start = devmem->resource->start;
 	size = resource_size(devmem->resource);
 
+	cdm = devmem->resource->desc == MEMORY_DEVICE_CACHE_COHERENT;
 	hmm_devmem_ref_kill(&devmem->ref);
 	hmm_devmem_ref_exit(&devmem->ref);
 	hmm_devmem_pages_remove(devmem);
 
-	devm_release_mem_region(device, start, size);
+	if (!cdm)
+		devm_release_mem_region(device, start, size);
 }
 EXPORT_SYMBOL(hmm_devmem_remove);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
