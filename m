Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92FD36B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 13:29:31 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v1so16168634pgv.8
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 10:29:31 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q81si6707466pfd.218.2017.04.28.10.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 10:29:30 -0700 (PDT)
Subject: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Apr 2017 10:23:37 -0700
Message-ID: <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20170428063913.iz6xjcxblecofjlq@gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

Kirill points out that the calls to {get,put}_dev_pagemap() can be
removed from the mm fast path if we take a single get_dev_pagemap()
reference to signify that the page is alive and use the final put of the
page to drop that reference.

This does require some care to make sure that any waits for the
percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
since it now maintains its own elevated reference.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Changes in v2:
* Rebased to tip/master
* Clarified comment in __put_page
* Clarified devm_memremap_pages() kernel doc about ordering of
  devm_memremap_pages_release() vs percpu_ref_kill() vs wait for
  percpu_ref to drop to zero.

Ingo, I retested this with a revert of commit 6dd29b3df975 "Revert
'x86/mm/gup: Switch GUP to the generic get_user_page_fast()
implementation'". It should be good to go through x86/mm.

 drivers/dax/pmem.c    |    2 +-
 drivers/nvdimm/pmem.c |   13 +++++++++++--
 include/linux/mm.h    |   14 --------------
 kernel/memremap.c     |   22 +++++++++-------------
 mm/swap.c             |   10 ++++++++++
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
index 07e85e5229da..23a6483c3666 100644
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
+ *    wait for the completion of all references being dropped and
+ *    percpu_ref_exit() must occur after devm_memremap_pages_release().
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
index 5dabf444d724..d8d9ee9e311a 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -97,6 +97,16 @@ static void __put_compound_page(struct page *page)
 
 void __put_page(struct page *page)
 {
+	if (is_zone_device_page(page)) {
+		put_dev_pagemap(page->pgmap);
+
+		/*
+		 * The page belongs to the device that created pgmap. Do
+		 * not return it to page allocator.
+		 */
+		return;
+	}
+
 	if (unlikely(PageCompound(page)))
 		__put_compound_page(page);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
