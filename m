Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26FF36B0267
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 10:39:32 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id h201so347762886qke.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 07:39:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u63si17566272qkb.79.2016.12.08.07.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 07:39:31 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v14 04/16] mm/ZONE_DEVICE/free-page: callback when page is freed
Date: Thu,  8 Dec 2016 11:39:32 -0500
Message-Id: <1481215184-18551-5-git-send-email-jglisse@redhat.com>
In-Reply-To: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
is holding a reference on it (only device to which the memory belong do).
Add a callback and call it when that happen so device driver can implement
their own free page management.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/dax/pmem.c                |  3 ++-
 drivers/nvdimm/pmem.c             |  5 +++--
 include/linux/memremap.h          | 17 ++++++++++++++---
 kernel/memremap.c                 | 14 +++++++++++++-
 tools/testing/nvdimm/test/iomap.c |  2 +-
 5 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 1f01e98..52ff674 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -107,7 +107,8 @@ static int dax_pmem_probe(struct device *dev)
 	if (rc)
 		return rc;
 
-	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap);
+	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref,
+				   altmap, NULL, NULL);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
 
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 571a6c7..c261d12 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -260,7 +260,7 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	if (is_nd_pfn(dev)) {
 		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
-				altmap);
+					   altmap, NULL, NULL);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
 		pmem->pfn_pad = resource_size(res) - resource_size(&pfn_res);
@@ -269,7 +269,8 @@ static int pmem_attach_disk(struct device *dev,
 		res->start += pmem->data_offset;
 	} else if (pmem_should_map_pages(dev)) {
 		addr = devm_memremap_pages(dev, &nsio->res,
-				&q->q_usage_counter, NULL);
+					   &q->q_usage_counter,
+					   NULL, NULL, NULL);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		addr = devm_memremap(dev, pmem->phys_addr,
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 32314d2..7845f2e 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -35,23 +35,31 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
+typedef void (*dev_page_free_t)(struct page *page, void *data);
+
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @page_free: free page callback when page refcount reach 1
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
+ * @data: privata data pointer for page_free
  */
 struct dev_pagemap {
+	dev_page_free_t page_free;
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
+	void *data;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap);
+			  struct percpu_ref *ref, struct vmem_altmap *altmap,
+			  dev_page_free_t page_free,
+			  void *data);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *pgmap);
 
@@ -62,8 +70,11 @@ static inline bool dev_page_allow_migrate(const struct page *page)
 }
 #else
 static inline void *devm_memremap_pages(struct device *dev,
-		struct resource *res, struct percpu_ref *ref,
-		struct vmem_altmap *altmap)
+					struct resource *res,
+					struct percpu_ref *ref,
+					struct vmem_altmap *altmap,
+					dev_page_free_t page_free,
+					void *data)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 250ef25..bc1e400 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
 
 void put_zone_device_page(struct page *page)
 {
+	/*
+	 * If refcount is 1 then page is freed and refcount is stable as nobody
+	 * holds a reference on the page.
+	 */
+	if (page->pgmap->page_free && page_count(page) == 1)
+		page->pgmap->page_free(page, page->pgmap->data);
 	put_dev_pagemap(page->pgmap);
 }
 EXPORT_SYMBOL(put_zone_device_page);
@@ -270,6 +276,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  * @res: "host memory" address range
  * @ref: a live per-cpu reference count
  * @altmap: optional descriptor for allocating the memmap from @res
+ * @page_free: callback call when page refcount reach 1 ie it is free
+ * @data: privata data pointer for page_free
  *
  * Notes:
  * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
@@ -280,7 +288,9 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  *    this is not enforced.
  */
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap)
+			  struct percpu_ref *ref, struct vmem_altmap *altmap,
+			  dev_page_free_t page_free,
+			  void *data)
 {
 	resource_size_t key, align_start, align_size, align_end;
 	pgprot_t pgprot = PAGE_KERNEL;
@@ -322,6 +332,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
+	pgmap->page_free = page_free;
+	pgmap->data = data;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index c29f8dc..6505a87 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -108,7 +108,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
 
 	if (nfit_res)
 		return nfit_res->buf + offset - nfit_res->res->start;
-	return devm_memremap_pages(dev, res, ref, altmap);
+	return devm_memremap_pages(dev, res, ref, altmap, NULL, NULL);
 }
 EXPORT_SYMBOL(__wrap_devm_memremap_pages);
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
