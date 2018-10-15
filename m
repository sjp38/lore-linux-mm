Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E25C6B000A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:30:56 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e11-v6so16555819wrr.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:30:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 52-v6sor6075658wra.30.2018.10.15.08.30.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:30:54 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory functions
Date: Mon, 15 Oct 2018 17:30:31 +0200
Message-Id: <20181015153034.32203-3-osalvador@techadventures.net>
In-Reply-To: <20181015153034.32203-1-osalvador@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

HMM/devm have a particular handling of memory-hotplug.
They do not go through the common path, and so, they do not
call either offline_pages() or online_pages().

The operations they perform are the following ones:

1) Create the linear mapping in case the memory is not private
2) Initialize the pages and add the sections
3) Move the pages to ZONE_DEVICE

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

The reason behind step b) from add_device_memory() and step a)
from del_device_memory is that now find_smallest/biggest_section_pfn
will have to check for online sections, and not for valid sections as
they used to do, because we call offline_mem_sections() in
offline_pages().

In order to split up better the patches and ease the review,
this patch will only make a) case work for add_device_memory(),
and case c) for del_device_memory.

The other cases will be added in the next patch.

These two functions have to be called from devm/HMM code:

dd_device_memory:
        - devm_memremap_pages()
        - hmm_devmem_pages_create()

del_device_memory:
        - hmm_devmem_release
        - devm_memremap_pages_release

One thing I do not know is whether we can move kasan calls out of the
hotplug lock or not.
If we can, we could move the hotplug lock within add/del_device_memory().

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/memory_hotplug.h | 11 +++++++++++
 kernel/memremap.c              | 11 ++++-------
 mm/hmm.c                       | 33 +++++++++++++++++----------------
 mm/memory_hotplug.c            | 41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 73 insertions(+), 23 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 786cdfc9a974..cf014d5edbb2 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -111,8 +111,19 @@ extern int arch_remove_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
+
+#ifdef CONFIG_ZONE_DEVICE
+extern int del_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem);
+#endif
+
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+#ifdef CONFIG_ZONE_DEVICE
+extern int add_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool private_mem);
+#endif
+
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		struct vmem_altmap *altmap, bool want_memblock);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index c95df6ed2d4a..b86bba8713b9 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -86,6 +86,8 @@ static void devm_memremap_pages_release(void *data)
 	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
+	struct vmem_altmap *altmap = pgmap->altmap_valid ?
+					&pgmap->altmap : NULL;
 	unsigned long pfn;
 	int nid;
 
@@ -104,8 +106,7 @@ static void devm_memremap_pages_release(void *data)
 	nid = dev_to_node(dev);
 
 	mem_hotplug_begin();
-	arch_remove_memory(nid, align_start, align_size, pgmap->altmap_valid ?
-			&pgmap->altmap : NULL);
+	del_device_memory(nid, align_start, align_size, altmap, true);
 	kasan_remove_zero_shadow(__va(align_start), align_size);
 	mem_hotplug_done();
 
@@ -204,11 +205,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_kasan;
 	}
 
-	error = arch_add_memory(nid, align_start, align_size, altmap, false);
-	if (!error)
-		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-					align_start >> PAGE_SHIFT,
-					align_size >> PAGE_SHIFT, altmap);
+	error = add_device_memory(nid, align_start, align_size, altmap, true);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
diff --git a/mm/hmm.c b/mm/hmm.c
index 42d79bcc8aab..d3e52ae71bd9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -996,6 +996,7 @@ static void hmm_devmem_release(struct device *dev, void *data)
 	struct zone *zone;
 	struct page *page;
 	int nid;
+	bool mapping;
 
 	if (percpu_ref_tryget_live(&devmem->ref)) {
 		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
@@ -1010,12 +1011,15 @@ static void hmm_devmem_release(struct device *dev, void *data)
 	zone = page_zone(page);
 	nid = zone->zone_pgdat->node_id;
 
-	mem_hotplug_begin();
 	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
-		__remove_pages(zone, start_pfn, npages, NULL);
+		mapping = false;
 	else
-		arch_remove_memory(nid, start_pfn << PAGE_SHIFT,
-				   npages << PAGE_SHIFT, NULL);
+		mapping = true;
+
+	mem_hotplug_begin();
+	del_device_memory(nid, start_pfn << PAGE_SHIFT, npages << PAGE_SHIFT,
+								NULL,
+								mapping);
 	mem_hotplug_done();
 
 	hmm_devmem_radix_release(resource);
@@ -1026,6 +1030,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	resource_size_t key, align_start, align_size, align_end;
 	struct device *device = devmem->device;
 	int ret, nid, is_ram;
+	bool mapping;
 
 	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
 	align_size = ALIGN(devmem->resource->start +
@@ -1084,7 +1089,6 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	mem_hotplug_begin();
 	/*
 	 * For device private memory we call add_pages() as we only need to
 	 * allocate and initialize struct page for the device memory. More-
@@ -1096,20 +1100,17 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	 * want the linear mapping and thus use arch_add_memory().
 	 */
 	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
-		ret = arch_add_memory(nid, align_start, align_size, NULL,
-				false);
+		mapping = true;
 	else
-		ret = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
-	if (ret) {
-		mem_hotplug_done();
-		goto error_add_memory;
-	}
-	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL);
+		mapping = false;
+
+	mem_hotplug_begin();
+	ret = add_device_memory(nid, align_start, align_size, NULL, mapping);
 	mem_hotplug_done();
 
+	if (ret)
+		goto error_add_memory;
+
 	/*
 	 * Initialization of the pages has been deferred until now in order
 	 * to allow us to do the work while not holding the hotplug lock.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 33d448314b3f..5874aceb81ac 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1889,4 +1889,45 @@ void remove_memory(int nid, u64 start, u64 size)
 	unlock_device_hotplug();
 }
 EXPORT_SYMBOL_GPL(remove_memory);
+
+#ifdef CONFIG_ZONE_DEVICE
+int del_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool mapping)
+{
+	int ret;
+	unsigned long start_pfn = PHYS_PFN(start);
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone = page_zone(pfn_to_page(pfn));
+
+	if (mapping)
+		ret = arch_remove_memory(nid, start, size, altmap);
+	else
+		ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTREMOVE */
+
+#ifdef CONFIG_ZONE_DEVICE
+int add_device_memory(int nid, unsigned long start, unsigned long size,
+				struct vmem_altmap *altmap, bool mapping)
+{
+	int ret;
+	unsigned long start_pfn = PHYS_PFN(start);
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	if (mapping)
+		ret = arch_add_memory(nid, start, size, altmap, false);
+	else
+		ret = add_pages(nid, start_pfn, nr_pages, altmap, false);
+
+	if (!ret) {
+		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+
+		move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
+	}
+
+	return ret;
+}
+#endif
-- 
2.13.6
