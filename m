Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36AC86B000E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:00:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k44-v6so1771610wre.18
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:00:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n198-v6sor8940953wmd.1.2018.10.02.08.00.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 08:00:49 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH v3 2/5] mm/memory_hotplug: Create add/del_device_memory functions
Date: Tue,  2 Oct 2018 17:00:26 +0200
Message-Id: <20181002150029.23461-3-osalvador@techadventures.net>
In-Reply-To: <20181002150029.23461-1-osalvador@techadventures.net>
References: <20181002150029.23461-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

HMM/devm have a particular handling of memory-hotplug.
They do not go through the common path, and so, they do not
call either offline_pages() or online_pages().

The operations they perform are the following ones:

1) Create the linear mapping in case the memory is not private
2) Initialize the pages and add the sections
3) Move the pages to ZONE_DEVICE in case the memory is not private.

Due to this particular handling of hot-add/remove memory from HMM/devm,
I think it would be nice to provide a helper function in order to
make this cleaner, and not populate other regions with code
that should belong to memory-hotplug.

The helpers are named:

del_device_memory
add_device_memory

The idea is that add_device_memory will be in charge of:

a) call either arch_add_memory() or add_pages(), depending on whether
   we want a linear mapping
b) online the memory sections that correspond to the pfn range
c) call move_pfn_range_to_zone() being zone ZONE_DEVICE to
   expand zone/pgdat spanned pages and initialize its pages

del_device_memory, on the other hand, will be in charge of:

a) offline the memory sections that correspond to the pfn range
b) call shrink_zone_pgdat_pages(), which shrinks node/zone spanned pages.
c) call either arch_remove_memory() or __remove_pages(), depending on
   whether we need to tear down the linear mapping or not

In order to split up better the patches and ease the review,
this patch will only make a) case work for add_device_memory(),
and case c) for del_device_memory.

The other cases will be added in the next patch.

Since [1], hmm is using devm_memremap_pages and devm_memremap_pages_release
instead of its own functions, so these two functions have to only be called
from devm code.

add_device_memory:
        - devm_memremap_pages()

del_device_memory:
        - devm_memremap_pages_release()

Another thing that this patch does is to move init_currently_empty_zone to be
protected by the span_lock lock.

Zone locking rules states the following:

 * Locking rules:
 *
 * zone_start_pfn and spanned_pages are protected by span_seqlock.
 * It is a seqlock because it has to be read outside of zone->lock,
 * and it is done in the main allocator path.  But, it is written
 * quite infrequently.
 *

Since init_currently_empty_zone changes zone_start_pfn,
it makes sense to have it envolved by its lock.

[1] https://patchwork.kernel.org/patch/10598657/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/memory_hotplug.h |  7 ++++++
 kernel/memremap.c              | 48 ++++++++++++++------------------------
 mm/memory_hotplug.c            | 53 +++++++++++++++++++++++++++++++++++++++---
 3 files changed, 74 insertions(+), 34 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f9fc35819e65..2f7b8eb4cddb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -117,6 +117,13 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		struct vmem_altmap *altmap, bool want_memblock);
 
+#ifdef CONFIG_ZONE_DEVICE
+extern int del_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem);
+extern int add_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem);
+#endif
+
 #ifndef CONFIG_ARCH_HAS_ADD_PAGES
 static inline int add_pages(int nid, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap,
diff --git a/kernel/memremap.c b/kernel/memremap.c
index fe54bba2d7e2..0f168a75c5b0 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -120,8 +120,11 @@ static void devm_memremap_pages_release(void *data)
 	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
+	struct vmem_altmap *altmap = pgmap->altmap_valid ?
+					&pgmap->altmap : NULL;
 	unsigned long pfn;
 	int nid;
+	bool private_mem;
 
 	pgmap->kill(pgmap->ref);
 	for_each_device_pfn(pfn, pgmap)
@@ -133,17 +136,14 @@ static void devm_memremap_pages_release(void *data)
 		- align_start;
 	nid = dev_to_node(dev);
 
-	mem_hotplug_begin();
-	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		pfn = align_start >> PAGE_SHIFT;
-		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
-				align_size >> PAGE_SHIFT, NULL);
-	} else {
-		arch_remove_memory(nid, align_start, align_size,
-				pgmap->altmap_valid ? &pgmap->altmap : NULL);
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE)
+		private_mem = true;
+	else
+		private_mem = false;
+
+	del_device_memory(nid, align_start, align_size, altmap, private_mem);
+	if (!private_mem)
 		kasan_remove_zero_shadow(__va(align_start), align_size);
-	}
-	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res, -1);
@@ -180,6 +180,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
 	struct dev_pagemap *conflict_pgmap;
+	bool private_mem;
 
 	if (!pgmap->ref || !pgmap->kill)
 		return ERR_PTR(-EINVAL);
@@ -239,8 +240,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (error)
 		goto err_pfn_remap;
 
-	mem_hotplug_begin();
-
 	/*
 	 * For device private memory we call add_pages() as we only need to
 	 * allocate and initialize struct page for the device memory. More-
@@ -252,29 +251,16 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * the CPU, we do want the linear mapping and thus use
 	 * arch_add_memory().
 	 */
-	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		error = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
-	} else {
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE)
+		private_mem = true;
+	else {
 		error = kasan_add_zero_shadow(__va(align_start), align_size);
-		if (error) {
-			mem_hotplug_done();
+		if (error)
 			goto err_kasan;
-		}
-
-		error = arch_add_memory(nid, align_start, align_size, altmap,
-				false);
-	}
-
-	if (!error) {
-		struct zone *zone;
-
-		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
-		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, altmap);
+		private_mem = false;
 	}
 
-	mem_hotplug_done();
+	error = add_device_memory(nid, align_start, align_size, altmap, private_mem);
 	if (error)
 		goto err_add_memory;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 11b7dcf83323..72928808c5e9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -764,14 +764,13 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 	int nid = pgdat->node_id;
 	unsigned long flags;
 
-	if (zone_is_empty(zone))
-		init_currently_empty_zone(zone, start_pfn, nr_pages);
-
 	clear_zone_contiguous(zone);
 
 	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
 	pgdat_resize_lock(pgdat, &flags);
 	zone_span_writelock(zone);
+	if (zone_is_empty(zone))
+		init_currently_empty_zone(zone, start_pfn, nr_pages);
 	resize_zone_range(zone, start_pfn, nr_pages);
 	zone_span_writeunlock(zone);
 	resize_pgdat_range(pgdat, start_pfn, nr_pages);
@@ -1904,4 +1903,52 @@ void remove_memory(int nid, u64 start, u64 size)
 	unlock_device_hotplug();
 }
 EXPORT_SYMBOL_GPL(remove_memory);
+
+#ifdef CONFIG_ZONE_DEVICE
+int del_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem)
+{
+	int ret;
+	unsigned long start_pfn = PHYS_PFN(start);
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone = page_zone(pfn_to_page(pfn));
+
+	mem_hotplug_begin();
+
+	if (private_mem)
+		ret = __remove_pages(zone, start_pfn, nr_pages, NULL);
+	else
+		ret = arch_remove_memory(nid, start, size, altmap);
+
+	mem_hotplug_done();
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTREMOVE */
+
+#ifdef CONFIG_ZONE_DEVICE
+int add_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem)
+{
+	int ret;
+	unsigned long start_pfn = PHYS_PFN(start);
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	mem_hotplug_begin();
+
+	if (private_mem)
+		ret = add_pages(nid, start_pfn, nr_pages, NULL, false);
+	else
+		ret = arch_add_memory(nid, start, size, altmap, false);
+
+	mem_hotplug_done();
+
+	if (!ret) {
+		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+		move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
+	}
+
+	return ret;
+}
+#endif
-- 
2.13.6
