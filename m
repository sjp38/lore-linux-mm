Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06B696B08EF
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:13:18 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a24-v6so18426616pfn.12
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:13:17 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id v9si397107pfl.45.2018.11.16.02.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 02:13:16 -0800 (PST)
From: Oscar Salvador <osalvador@suse.com>
Subject: [RFC PATCH 3/4] mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
Date: Fri, 16 Nov 2018 11:12:21 +0100
Message-Id: <20181116101222.16581-4-osalvador@suse.com>
In-Reply-To: <20181116101222.16581-1-osalvador@suse.com>
References: <20181116101222.16581-1-osalvador@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Physical memory hotadd has to allocate a memmap (struct page array) for
the newly added memory section. Currently, kmalloc is used for those
allocations.

This has some disadvantages:
 a) an existing memory is consumed for that purpose (~2MB per 128MB memory section)
 b) if the whole node is movable then we have off-node struct pages
    which has performance drawbacks.

a) has turned out to be a problem for memory hotplug based ballooning
because the userspace might not react in time to online memory while
the memory consumed during physical hotadd consumes enough memory to push
system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
policy for the newly added memory") has been added to workaround that
problem.

We can do much better when CONFIG_SPARSEMEM_VMEMMAP=y because vmemap
page tables can map arbitrary memory. That means that we can simply
use the beginning of each memory section and map struct pages there.
struct pages which back the allocated space then just need to be treated
carefully.

Add {_Set,_Clear}PageVmemmap helpers to distinguish those pages in pfn
walkers. We do not have any spare page flag for this purpose so use the
combination of PageReserved bit which already tells that the page should
be ignored by the core mm code and store VMEMMAP_PAGE (which sets all
bits but PAGE_MAPPING_FLAGS) into page->mapping.

On the memory hotplug front add a new MHP_MEMMAP_FROM_RANGE restriction
flag. User is supposed to set the flag if the memmap should be allocated
from the hotadded range. Please note that this is just a hint and
architecture code can veto this if this cannot be supported. E.g. s390
cannot support this currently beause the physical memory range is made
accessible only during memory online.

Implementation wise we reuse vmem_altmap infrastructure to override
the default allocator used by __vmemap_populate. Once the memmap is
allocated we need a way to mark altmap pfns used for the allocation
and this is done by a new vmem_altmap::flush_alloc_pfns callback.
mark_vmemmap_pages implementation then simply __SetPageVmemmap all
struct pages backing those pfns.
The callback is called from sparse_add_one_section.

mark_vmemmap_pages will take care of marking the pages as PageVmemmap,
and to increase the refcount of the first Vmemmap page.
This is done to know how much do we have to defer the call to vmemmap_free().

We also have to be careful about those pages during online and offline
operations. They are simply skipped now so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

When hot-remove the range, since sections are removed sequantially
starting from the first one and moving on, __kfree_section_memmap will
catch the first Vmemmap page and will get its reference count.
In this way, __kfree_section_memmap knows how much does it have to defer
the call to vmemmap_free().

in case we are hot-removing a range that used altmap, the call to
vmemmap_free must be done backwards, because the beginning of memory
is used for the pagetables.
Doing it this way, we ensure that by the time we remove the pagetables,
those pages will not have to be referenced anymore.

Please note that only the memory hotplug is currently using this
allocation scheme. The boot time memmap allocation could use the same
trick as well but this is not done yet.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c            |  5 ++-
 arch/powerpc/mm/init_64.c      |  2 ++
 arch/s390/mm/init.c            |  6 ++++
 arch/x86/mm/init_64.c          |  7 ++++
 include/linux/memory_hotplug.h |  8 ++++-
 include/linux/memremap.h       | 65 +++++++++++++++++++++++++++++++--
 include/linux/page-flags.h     | 18 ++++++++++
 kernel/memremap.c              |  6 ----
 mm/compaction.c                |  3 ++
 mm/hmm.c                       |  6 ++--
 mm/memory_hotplug.c            | 81 +++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c                | 22 ++++++++++--
 mm/page_isolation.c            | 13 ++++++-
 mm/sparse.c                    | 46 ++++++++++++++++++++++++
 14 files changed, 268 insertions(+), 20 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 394b8d554def..8fa6e2ade5be 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -733,7 +733,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		if (pmd_none(READ_ONCE(*pmdp))) {
 			void *p = NULL;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			if (altmap)
+				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (!p)
 				return -ENOMEM;
 
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 7a9886f98b0c..03f014abd4eb 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -278,6 +278,8 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 			continue;
 
 		page = pfn_to_page(addr >> PAGE_SHIFT);
+		if (PageVmemmap(page))
+			continue;
 		section_base = pfn_to_page(vmemmap_section_start(start));
 		nr_pages = 1 << page_order;
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 4139affd6157..bc1523bcb09d 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -231,6 +231,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunatelly.
+	 */
+	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index fd06bcbd9535..d5234ca5c483 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -815,6 +815,13 @@ static void __meminit free_pagetable(struct page *page, int order)
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
+	/*
+	 * runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page))
+		return;
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 7249dab00ac9..244e0e2c030c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -118,9 +118,15 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
  * and offline memory explicitly. Lack of this bit means that the caller has to
  * call move_pfn_range_to_zone to finish the initialization.
  */
-
 #define MHP_MEMBLOCK_API               1<<0
 
+/*
+ * Do we want memmap (struct page array) allocated from the hotadded range.
+ * Please note that only SPARSE_VMEMMAP implements this feauture and some
+ * architectures might not support it even for that memory model (e.g. s390)
+ */
+#define MHP_MEMMAP_FROM_RANGE          1<<1
+
 /* Restrictions for the memory hotplug */
 struct mhp_restrictions {
 	unsigned long flags;    /* MHP_ flags */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 0ac69ddf5fc4..863f339224e6 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -5,6 +5,8 @@
 #include <linux/percpu-refcount.h>
 
 #include <asm/pgtable.h>
+#include <linux/page-flags.h>
+#include <linux/page_ref.h>
 
 struct resource;
 struct device;
@@ -16,13 +18,18 @@ struct device;
  * @free: free pages set aside in the mapping for memmap storage
  * @align: pages reserved to meet allocation alignments
  * @alloc: track pages consumed, private to vmemmap_populate()
+ * @flush_alloc_pfns: callback to be called on the allocated range after it
+ * @nr_sects: nr of sects filled with memmap allocations
+ * is mapped to the vmemmap - see mark_vmemmap_pages
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
 	unsigned long alloc;
+	int nr_sects;
+	void (*flush_alloc_pfns)(struct vmem_altmap *self);
 };
 
 /*
@@ -133,8 +140,62 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
+static inline unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
+{
+	/* number of pfns from base where pfn_to_page() is valid */
+	return altmap->reserve + altmap->free;
+}
+
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
+
+static inline void mark_vmemmap_pages(struct vmem_altmap *self)
+{
+	unsigned long pfn = self->base_pfn + self->reserve;
+	unsigned long nr_pages = self->alloc;
+	unsigned long align = PAGES_PER_SECTION * sizeof(struct page);
+	struct page *head;
+	unsigned long i;
+
+	pr_debug("%s: marking %px - %px as Vmemmap\n", __func__,
+						pfn_to_page(pfn),
+						pfn_to_page(pfn + nr_pages - 1));
+	/*
+	 * We keep track of the sections using this altmap by means
+	 * of a refcount, so we know how much do we have to defer
+	 * the call to vmemmap_free for this memory range.
+	 * The refcount is kept in the first vmemmap page.
+	 * For example:
+	 * We add 10GB: (ffffea0004000000 - ffffea000427ffc0)
+	 * ffffea0004000000 will have a refcount of 80.
+	 */
+	head = (struct page *)ALIGN_DOWN((unsigned long)pfn_to_page(pfn), align);
+	head = (struct page *)((unsigned long)head - (align * self->nr_sects));
+	page_ref_inc(head);
+
+	/*
+	 * We have used a/another section only with memmap allocations.
+	 * We need to keep track of it in order to get the first head page
+	 * to increase its refcount.
+	 * This makes it easier to compute.
+	 */
+	if (!((page_ref_count(head) * PAGES_PER_SECTION) % align))
+		self->nr_sects++;
+
+	/*
+	 * All allocations for the memory hotplug are the same sized so align
+	 * should be 0
+	 */
+	WARN_ON(self->align);
+        for (i = 0; i < nr_pages; i++, pfn++) {
+                struct page *page = pfn_to_page(pfn);
+                __SetPageVmemmap(page);
+		init_page_count(page);
+        }
+
+	self->alloc = 0;
+	self->base_pfn += nr_pages + self->reserve;
+	self->free -= nr_pages;
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct dev_pagemap *pgmap)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 50ce1bddaf56..e79054fcc96e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -437,6 +437,24 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+#define VMEMMAP_PAGE ~PAGE_MAPPING_FLAGS
+static __always_inline int PageVmemmap(struct page *page)
+{
+	return PageReserved(page) && (unsigned long)page->mapping == VMEMMAP_PAGE;
+}
+
+static __always_inline void __ClearPageVmemmap(struct page *page)
+{
+	ClearPageReserved(page);
+	page->mapping = NULL;
+}
+
+static __always_inline void __SetPageVmemmap(struct page *page)
+{
+	SetPageReserved(page);
+	page->mapping = (void *)VMEMMAP_PAGE;
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 248082bfea5c..10f5bd912780 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -239,12 +239,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 }
 EXPORT_SYMBOL(devm_memremap_pages);
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
-{
-	/* number of pfns from base where pfn_to_page() is valid */
-	return altmap->reserve + altmap->free;
-}
-
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns)
 {
 	altmap->alloc -= nr_pfns;
diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..c94a480e01b5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -768,6 +768,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		page = pfn_to_page(low_pfn);
 
+		if (PageVmemmap(page))
+			goto isolate_fail;
+
 		if (!valid_page)
 			valid_page = page;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 90c34f3d1243..ec1e8d97a3ce 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1072,6 +1072,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	resource_size_t key, align_start, align_size, align_end;
 	struct device *device = devmem->device;
 	int ret, nid, is_ram;
+	struct mhp_restrictions restrictions = {};
 
 	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
 	align_size = ALIGN(devmem->resource->start +
@@ -1142,11 +1143,10 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	 * want the linear mapping and thus use arch_add_memory().
 	 */
 	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
-		ret = arch_add_memory(nid, align_start, align_size, NULL,
-				false);
+		ret = arch_add_memory(nid, align_start, align_size, &restrictions);
 	else
 		ret = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
+				align_size >> PAGE_SHIFT, &restrictions);
 	if (ret) {
 		mem_hotplug_done();
 		goto error_add_memory;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8a97bda770c1..5a53d29b4101 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -276,11 +276,22 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	int err = 0;
 	int start_sec, end_sec;
 	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap __memblk_altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
+	if(!altmap && (restrictions->flags & MHP_MEMMAP_FROM_RANGE)) {
+		__memblk_altmap.base_pfn = phys_start_pfn;
+		__memblk_altmap.alloc = 0;
+		__memblk_altmap.align = 0;
+		__memblk_altmap.free = nr_pages;
+		__memblk_altmap.nr_sects = 0;
+		__memblk_altmap.flush_alloc_pfns = mark_vmemmap_pages;
+		altmap = &__memblk_altmap;
+	}
+
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -685,13 +696,72 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	return onlined_pages;
 }
 
+static int __online_pages_range(unsigned long start_pfn, unsigned long nr_pages)
+{
+	if (PageReserved(pfn_to_page(start_pfn)))
+		return online_pages_blocks(start_pfn, nr_pages);
+
+	return 0;
+}
+
+
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
-			void *arg)
+								void *arg)
 {
 	unsigned long onlined_pages = *(unsigned long *)arg;
+	unsigned long pfn = start_pfn;
+	unsigned long end_pfn = start_pfn + nr_pages;
+	bool vmemmap_page = false;
 
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
+	for (; pfn < end_pfn; pfn++) {
+		struct page *p = pfn_to_page(pfn);
+
+		/*
+		 * Let us check if we got vmemmap pages.
+		 */
+		if (PageVmemmap(p)) {
+			vmemmap_page = true;
+			break;
+		}
+	}
+
+	if (!vmemmap_page) {
+		/*
+		 * We can send the whole range to __online_pages_range,
+		 * as we know for sure that there are not vmemmap pages.
+		 */
+		onlined_pages += __online_pages_range(start_pfn, nr_pages);
+	} else {
+		/*
+		 * We need to strip the vmemmap pages here,
+		 * as we do not want to send them to the buddy allocator.
+		 */
+		unsigned long sections = nr_pages / PAGES_PER_SECTION;
+		unsigned long sect_nr = 0;
+
+		for (; sect_nr < sections; sect_nr++) {
+			unsigned pfn_end_section;
+			unsigned long memmap_pages = 0;
+
+			pfn = start_pfn + (PAGES_PER_SECTION * sect_nr);
+			pfn_end_section = pfn + PAGES_PER_SECTION;
+
+			while (pfn < pfn_end_section) {
+				struct page *p = pfn_to_page(pfn);
+
+				if (PageVmemmap(p))
+					memmap_pages++;
+				pfn++;
+			}
+			pfn = start_pfn + (PAGES_PER_SECTION * sect_nr);
+			if (!memmap_pages) {
+				onlined_pages += __online_pages_range(pfn, PAGES_PER_SECTION);
+			} else if (memmap_pages && memmap_pages < PAGES_PER_SECTION) {
+				pfn += memmap_pages;
+				onlined_pages += __online_pages_range(pfn, PAGES_PER_SECTION - memmap_pages);
+			}
+		}
+       }
 
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
@@ -1125,7 +1195,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	new_node = ret;
 
 	/* call arch's memory hotadd */
-	restrictions.flags = MHP_MEMBLOCK_API;
+	restrictions.flags = MHP_MEMBLOCK_API|MHP_MEMMAP_FROM_RANGE;
 	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
 		goto error;
@@ -1374,6 +1444,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		page = pfn_to_page(pfn);
 
+		if (PageVmemmap(page))
+			continue;
+
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
 			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d417c724551..2b236f4ab0fe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -926,6 +926,9 @@ static void free_pages_check_bad(struct page *page)
 
 static inline int free_pages_check(struct page *page)
 {
+	if(PageVmemmap(page))
+		return 0;
+
 	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE)))
 		return 0;
 
@@ -1178,9 +1181,11 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	mm_zero_struct_page(page);
+	if (!PageVmemmap(page))
+		mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
-	init_page_count(page);
+	if (!PageVmemmap(page))
+		init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
 
@@ -7781,6 +7786,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		if(PageVmemmap(page))
+			continue;
+
 		if (PageReserved(page))
 			goto unmovable;
 
@@ -8138,6 +8146,16 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
+		/*
+		 * vmemmap pages are residing inside the memory section so
+		 * they do not have to be freed anywhere.
+		 */
+		if (PageVmemmap(page)) {
+			pfn++;
+			continue;
+		}
+
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e085608846..0991548b7ab5 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -259,6 +259,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (PageVmemmap(page)) {
+			pfn++;
+			continue;
+		}
+
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
@@ -289,10 +294,16 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	 * are not aligned to pageblock_nr_pages.
 	 * Then we just check migratetype first.
 	 */
-	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+	for (pfn = start_pfn; pfn < end_pfn;) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (PageVmemmap(page)) {
+			pfn++;
+			continue;
+		}
+
 		if (page && !is_migrate_isolate_page(page))
 			break;
+		pfn += pageblock_nr_pages;
 	}
 	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
 	if ((pfn < end_pfn) || !page)
diff --git a/mm/sparse.c b/mm/sparse.c
index 33307fc05c4d..29cbaa0e46c3 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -563,6 +563,32 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+
+static struct page *current_vmemmap_page = NULL;
+static bool vmemmap_dec_and_test(void)
+{
+	bool ret = false;
+
+	if (page_ref_dec_and_test(current_vmemmap_page))
+			ret = true;
+	return ret;
+}
+
+static void free_vmemmap_range(unsigned long limit, unsigned long start, unsigned long end)
+{
+	unsigned long range_start;
+	unsigned long range_end;
+	unsigned long align = sizeof(struct page) * PAGES_PER_SECTION;
+
+	range_end = end;
+	range_start = end - align;
+	while (range_start >= limit) {
+		vmemmap_free(range_start, range_end, NULL);
+		range_end = range_start;
+		range_start -= align;
+	}
+}
+
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
@@ -575,6 +601,18 @@ static void __kfree_section_memmap(struct page *memmap,
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
+	if (PageVmemmap(memmap) && !current_vmemmap_page)
+		current_vmemmap_page = memmap;
+
+	if (current_vmemmap_page) {
+		if (vmemmap_dec_and_test()) {
+			unsigned long start_vmemmap = (unsigned long)current_vmemmap_page;
+			free_vmemmap_range(start_vmemmap, start, end);
+			current_vmemmap_page = NULL;
+		}
+		return;
+	}
+
 	vmemmap_free(start, end, altmap);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -703,6 +741,14 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	 */
 	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
 
+	/*
+	 * now that we have a valid vmemmap mapping we can use
+	 * pfn_to_page and flush struct pages which back the
+	 * memmap
+	 */
+       if (altmap && altmap->flush_alloc_pfns)
+               altmap->flush_alloc_pfns(altmap);
+
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
-- 
2.13.6
