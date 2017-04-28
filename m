Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17E8E6B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 04:14:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p2so10732204pge.7
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:14:49 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b2si6579pfk.153.2017.04.28.01.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 01:14:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, zone_device: Replace {get, put}_zone_device_page() with a single reference
Date: Fri, 28 Apr 2017 11:14:23 +0300
Message-Id: <20170428081423.88760-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170428063913.iz6xjcxblecofjlq@gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, akpm@linux-foundation.org
Cc: Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Dan Williams <dan.j.williams@intel.com>

Kirill points out that the calls to {get,put}_dev_pagemap() can be
removed from the mm fast path if we take a single get_dev_pagemap()
reference to signify that the page is alive and use the final put of the
page to drop that reference.

This does require some care to make sure that any waits for the
percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
since it now maintains its own elevated reference.

Cc Ingo Molnar <mingo@redhat.com>
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
[kirill.shutemov@linux.intel.com: rebased to -tip]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/dax/pmem.c    |  2 +-
 drivers/nvdimm/pmem.c | 13 +++++++++++--
 include/linux/mm.h    | 14 --------------
 kernel/memremap.c     | 22 +++++++++-------------
 mm/swap.c             | 10 ++++++++++
 5 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 033f49b31fdc..cb0d742fa23f 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -43,6 +43,7 @@ static void dax_pmem_percpu_exit(void *data)
 	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
 
 	dev_dbg(dax_pmem->dev, "%s\n", __func__);
+	wait_for_completion(&dax_pmem->cmp);
 	percpu_ref_exit(ref);
 }
 
@@ -53,7 +54,6 @@ static void dax_pmem_percpu_kill(void *data)
 
 	dev_dbg(dax_pmem->dev, "%s\n", __func__);
 	percpu_ref_kill(ref);
-	wait_for_completion(&dax_pmem->cmp);
 }
 
 static int dax_pmem_probe(struct device *dev)
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 5b536be5a12e..fb7bbc79ac26 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -25,6 +25,7 @@
 #include <linux/badblocks.h>
 #include <linux/memremap.h>
 #include <linux/vmalloc.h>
+#include <linux/blk-mq.h>
 #include <linux/pfn_t.h>
 #include <linux/slab.h>
 #include <linux/pmem.h>
@@ -231,6 +232,11 @@ static void pmem_release_queue(void *q)
 	blk_cleanup_queue(q);
 }
 
+static void pmem_freeze_queue(void *q)
+{
+	blk_mq_freeze_queue_start(q);
+}
+
 static void pmem_release_disk(void *disk)
 {
 	del_gendisk(disk);
@@ -284,6 +290,9 @@ static int pmem_attach_disk(struct device *dev,
 	if (!q)
 		return -ENOMEM;
 
+	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
+		return -ENOMEM;
+
 	pmem->pfn_flags = PFN_DEV;
 	if (is_nd_pfn(dev)) {
 		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
@@ -303,10 +312,10 @@ static int pmem_attach_disk(struct device *dev,
 				pmem->size, ARCH_MEMREMAP_PMEM);
 
 	/*
-	 * At release time the queue must be dead before
+	 * At release time the queue must be frozen before
 	 * devm_memremap_pages is unwound
 	 */
-	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
+	if (devm_add_action_or_reset(dev, pmem_freeze_queue, q))
 		return -ENOMEM;
 
 	if (IS_ERR(addr))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a835edd2db34..695da2a19b4c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -762,19 +762,11 @@ static inline enum zone_type page_zonenum(const struct page *page)
 }
 
 #ifdef CONFIG_ZONE_DEVICE
-void get_zone_device_page(struct page *page);
-void put_zone_device_page(struct page *page);
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return page_zonenum(page) == ZONE_DEVICE;
 }
 #else
-static inline void get_zone_device_page(struct page *page)
-{
-}
-static inline void put_zone_device_page(struct page *page)
-{
-}
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return false;
@@ -790,9 +782,6 @@ static inline void get_page(struct page *page)
 	 */
 	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
 	page_ref_inc(page);
-
-	if (unlikely(is_zone_device_page(page)))
-		get_zone_device_page(page);
 }
 
 static inline void put_page(struct page *page)
@@ -801,9 +790,6 @@ static inline void put_page(struct page *page)
 
 	if (put_page_testzero(page))
 		__put_page(page);
-
-	if (unlikely(is_zone_device_page(page)))
-		put_zone_device_page(page);
 }
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07e85e5229da..5316efdde083 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -182,18 +182,6 @@ struct page_map {
 	struct vmem_altmap altmap;
 };
 
-void get_zone_device_page(struct page *page)
-{
-	percpu_ref_get(page->pgmap->ref);
-}
-EXPORT_SYMBOL(get_zone_device_page);
-
-void put_zone_device_page(struct page *page)
-{
-	put_dev_pagemap(page->pgmap);
-}
-EXPORT_SYMBOL(put_zone_device_page);
-
 static void pgmap_radix_release(struct resource *res)
 {
 	resource_size_t key, align_start, align_size, align_end;
@@ -237,6 +225,10 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	struct resource *res = &page_map->res;
 	resource_size_t align_start, align_size;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
+	unsigned long pfn;
+
+	for_each_device_pfn(pfn, page_map)
+		put_page(pfn_to_page(pfn));
 
 	if (percpu_ref_tryget_live(pgmap->ref)) {
 		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
@@ -277,7 +269,10 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  *
  * Notes:
  * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
- *    (or devm release event).
+ *    (or devm release event). The expected order of events is that @ref has
+ *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
+ *    wait for the completion of kill and percpu_ref_exit() must occur after
+ *    devm_memremap_pages_release().
  *
  * 2/ @res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
@@ -379,6 +374,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		 */
 		list_del(&page->lru);
 		page->pgmap = pgmap;
+		percpu_ref_get(ref);
 	}
 	devres_add(dev, page_map);
 	return __va(res->start);
diff --git a/mm/swap.c b/mm/swap.c
index 5dabf444d724..01267dda6668 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -97,6 +97,16 @@ static void __put_compound_page(struct page *page)
 
 void __put_page(struct page *page)
 {
+	if (is_zone_device_page(page)) {
+		put_dev_pagemap(page->pgmap);
+
+		/*
+		 * The page belong to device, do not return it to
+		 * page allocator.
+		 */
+		return;
+	}
+
 	if (unlikely(PageCompound(page)))
 		__put_compound_page(page);
 	else
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
