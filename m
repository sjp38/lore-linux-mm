Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDA06B0544
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:47 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 77so15248047itj.4
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:47 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id 6si16387452iow.66.2017.08.01.05.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:46 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id c74so1439834iod.4
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:46 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
Date: Tue,  1 Aug 2017 14:41:09 +0200
Message-Id: <20170801124111.28881-5-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

From: Michal Hocko <mhocko@suse.com>

Physical memory hotadd has to allocate a memmap (struct page array) for
the newly added memory section. kmalloc is currantly used for those
allocations.

This has some disadvantages a) an existing memory is consumed for
that purpose (~2MB per 128MB memory section) and b) if the whole node
is movable then we have off-node struct pages which has performance
drawbacks.

a) has turned out to be a problem for memory hotplug based ballooning
because the userspace might not react in time to online memory while
to memory consumed during physical hotadd consumes enough memory to push
system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
policy for the newly added memory") has been added to workaround that
problem.

We can do much better when CONFIG_SPARSEMEM_VMEMMAP=y because vmemap
page tables can map arbitrary memory. That means that we can simply
use the beginning of each memory block and map struct pages there.
struct pages which back the allocated space then just need to be treated
carefully so that we know they are not usable.

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
struct pages backing those pfns. The callback is called from
sparse_add_one_section after the memmap has been initialized to 0.

We also have to be careful about those pages during online and offline
operations. They are simply skipped now so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

Finally __ClearPageVmemmap is called when the vmemmap page tables are
torn down.

Please note that only the memory hotplug is currently using this
allocation scheme. The boot time memmap allocation could use the same
trick as well but this is not done yet.

Changes since RFC
- rewind base pfn of the vmem_altmap when flushing one section
  (mark_vmemmap_pages) because we do not want to flush the same range
  all over again when memblock has more than one section
- Allow memory hotplug users to explicitly opt-in for this feature by
  using MHP_MEMMAP_FROM_RANGE flag.
- s390 disables MHP_MEMMAP_FROM_RANGE unconditionally because allocating
  from the added memory will blow up as the memory range is still not
  accessible that early.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: <x86@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/powerpc/mm/init_64.c      |  5 +++++
 arch/s390/mm/init.c            |  6 ++++++
 arch/x86/mm/init_64.c          |  9 +++++++++
 include/linux/memory_hotplug.h | 12 +++++++++++-
 include/linux/memremap.h       | 30 ++++++++++++++++++++++++++++--
 include/linux/mm.h             |  6 ++----
 include/linux/page-flags.h     | 18 ++++++++++++++++++
 kernel/memremap.c              |  6 ------
 mm/compaction.c                |  3 +++
 mm/memory_hotplug.c            | 27 +++++++++++++++++++++++----
 mm/page_alloc.c                | 14 ++++++++++++++
 mm/page_isolation.c            | 11 ++++++++++-
 mm/sparse-vmemmap.c            | 11 +++++++++--
 mm/sparse.c                    | 26 +++++++++++++++++++++-----
 14 files changed, 159 insertions(+), 25 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 5ea5e870a589..b14f2239a152 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -264,6 +264,11 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 				goto unmap;
 			}
 
+			if (PageVmemmap(page)) {
+				__ClearPageVmemmap(page);
+				goto unmap;
+			}
+
 			if (PageReserved(page)) {
 				/* allocated from bootmem */
 				if (page_size < PAGE_SIZE) {
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index e3db0079ebfc..85dacb95cfa4 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -169,6 +169,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunatelly
+	 */
+	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index da57a9c9c218..66951bf03629 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -804,6 +804,15 @@ static void __meminit free_pagetable(struct page *page, int order)
 		return;
 	}
 
+	/*
+	 * runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page)) {
+		__ClearPageVmemmap(page);
+		return;
+	}
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 76e5bfde8050..6fe47d1c9c74 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -136,6 +136,13 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
  */
 #define MHP_MEMBLOCK_API		1<<0
 
+/*
+ * Do we want memmap (struct page array) allocated from the hotadded range.
+ * Please note that only SPARSE_VMEMMAP implements this feauture and some
+ * architectures might not support it even for that memory model (e.g. s390)
+ */
+#define MHP_MEMMAP_FROM_RANGE		1<<1
+
 /* Restrictions for the memory hotplug */
 struct mhp_restrictions {
 	unsigned long flags;	/* MHP_ flags */
@@ -326,7 +333,10 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn);
+
+struct vmem_altmap;
+extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn,
+		struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 6f8f65d8ebdd..55f82c652d51 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -14,18 +14,44 @@ struct device;
  * @free: free pages set aside in the mapping for memmap storage
  * @align: pages reserved to meet allocation alignments
  * @alloc: track pages consumed, private to __vmemmap_populate()
+ * @flush_alloc_pfns: callback to be called on the allocated range after it
+ *  is mapped to the vmemmap - see mark_vmemmap_pages
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
 	unsigned long alloc;
+	void (*flush_alloc_pfns)(struct vmem_altmap *self);
 };
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
+static inline unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
+{
+	/* number of pfns from base where pfn_to_page() is valid */
+	return altmap->reserve + altmap->free;
+}
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
 
+static inline void mark_vmemmap_pages(struct vmem_altmap *self)
+{
+	unsigned long pfn = self->base_pfn + self->reserve;
+	unsigned long nr_pages = self->alloc;
+	unsigned long i;
+
+	/*
+	 * All allocations for the memory hotplug are the same sized so align
+	 * should be 0
+	 */
+	WARN_ON(self->align);
+	for (i = 0; i < nr_pages; i++, pfn++) {
+		struct page *page = pfn_to_page(pfn);
+		__SetPageVmemmap(page);
+	}
+
+	self->alloc = 0;
+	self->base_pfn += nr_pages + self->reserve;
+}
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 957d4658977d..3ce673570fb8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2426,6 +2426,8 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
+struct page *__sparse_mem_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
@@ -2436,10 +2438,6 @@ void *vmemmap_alloc_block(unsigned long size, int node);
 struct vmem_altmap;
 void *__vmemmap_alloc_block_buf(unsigned long size, int node,
 		struct vmem_altmap *altmap);
-static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
-{
-	return __vmemmap_alloc_block_buf(size, node, NULL);
-}
 
 #ifdef CONFIG_ZONE_DEVICE
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index ba2d470d2d0a..dcc7706eed8e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -412,6 +412,24 @@ static __always_inline int __PageMovable(struct page *page)
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
index 02029a993329..844f5ba93383 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -397,12 +397,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
index fb548e4c7bd4..1ba5ad029258 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -741,6 +741,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		page = pfn_to_page(low_pfn);
 
+		if (PageVmemmap(page))
+			goto isolate_fail;
+
 		if (!valid_page)
 			valid_page = page;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d28883aea475..08545a567de6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -35,6 +35,7 @@
 #include <linux/memblock.h>
 #include <linux/bootmem.h>
 #include <linux/compaction.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -244,7 +245,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		bool want_memblock)
+		bool want_memblock, struct vmem_altmap *altmap)
 {
 	int ret;
 	int i;
@@ -252,7 +253,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn);
+	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
 	if (ret < 0)
 		return ret;
 
@@ -293,11 +294,23 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	int err = 0;
 	int start_sec, end_sec;
 	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap __memblk_altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
+	/*
+	 * Check device specific altmap and fallback to allocating from the
+	 * begining of the memblock if requested
+	 */
+	if (!altmap && (restrictions->flags & MHP_MEMMAP_FROM_RANGE)) {
+		__memblk_altmap.base_pfn = phys_start_pfn;
+		__memblk_altmap.free = nr_pages;
+		__memblk_altmap.flush_alloc_pfns = mark_vmemmap_pages;
+		altmap = &__memblk_altmap;
+	}
+
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -313,7 +326,8 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, section_nr_to_pfn(i),
-				restrictions->flags & MHP_MEMBLOCK_API);
+				restrictions->flags & MHP_MEMBLOCK_API,
+				altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -690,6 +704,8 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			if (PageVmemmap(page))
+				continue;
 			if (PageHWPoison(page)) {
 				ClearPageReserved(page);
 				continue;
@@ -1147,7 +1163,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 			goto error;
 	}
 
-	restrictions.flags = MHP_MEMBLOCK_API;
+	restrictions.flags = MHP_MEMBLOCK_API | MHP_MEMMAP_FROM_RANGE;
 
 	/* call arch's memory hotadd */
 	ret = arch_add_memory(nid, start, size, &restrictions);
@@ -1378,6 +1394,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		page = pfn_to_page(pfn);
 
+		if (PageVmemmap(page))
+			continue;
+
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
 			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f4e5db85ebfc..145187d5656b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1168,6 +1168,10 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+	/*
+	 * Please note that the page already has some state which has to be
+	 * preserved (e.g. PageVmemmap)
+	 */
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
@@ -7639,6 +7643,16 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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
index 757410d9f758..6e976aa94dee 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -242,6 +242,10 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (PageVmemmap(page)) {
+			pfn++;
+			continue;
+		}
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
@@ -272,10 +276,15 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	 * are not aligned to pageblock_nr_pages.
 	 * Then we just check migratetype first.
 	 */
-	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+	for (pfn = start_pfn; pfn < end_pfn; ) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (PageVmemmap(page)) {
+			pfn++;
+			continue;
+		}
 		if (page && !is_migrate_isolate_page(page))
 			break;
+		pfn += pageblock_nr_pages;
 	}
 	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
 	if ((pfn < end_pfn) || !page)
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 48c44eda3254..0af022afc951 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -259,7 +259,8 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 	return 0;
 }
 
-struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+struct page * __meminit __sparse_mem_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start;
 	unsigned long end;
@@ -269,12 +270,18 @@ struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
 	start = (unsigned long)map;
 	end = (unsigned long)(map + PAGES_PER_SECTION);
 
-	if (vmemmap_populate(start, end, nid))
+	if (__vmemmap_populate(start, end, nid, altmap))
 		return NULL;
 
 	return map;
 }
 
+struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+{
+	WARN_ON(to_vmem_altmap(pnum));
+	return __sparse_mem_map_populate(pnum, nid, NULL);
+}
+
 void __init sparse_mem_maps_populate_node(struct page **map_map,
 					  unsigned long pnum_begin,
 					  unsigned long pnum_end,
diff --git a/mm/sparse.c b/mm/sparse.c
index a9783acf2bb9..19b9aa60f48a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -10,6 +10,7 @@
 #include <linux/export.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include <linux/memremap.h>
 
 #include "internal.h"
 #include <asm/dma.h>
@@ -662,10 +663,11 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
-	return sparse_mem_map_populate(pnum, nid);
+	return __sparse_mem_map_populate(pnum, nid, altmap);
 }
 static void __kfree_section_memmap(struct page *memmap)
 {
@@ -705,7 +707,8 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	return __kmalloc_section_memmap();
 }
@@ -757,7 +760,8 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn)
+int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn,
+		struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct mem_section *ms;
@@ -773,7 +777,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
+	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
@@ -790,8 +794,20 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 		goto out;
 	}
 
+	/*
+	 * TODO get rid of this somehow - we want to postpone the full
+	 * initialization until memmap_init_zone.
+	 */
 	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
 
+	/*
+	 * now that we have a valid vmemmap mapping we can use
+	 * pfn_to_page and flush struct pages which back the
+	 * memmap
+	 */
+	if (altmap && altmap->flush_alloc_pfns)
+		altmap->flush_alloc_pfns(altmap);
+
 	section_mark_present(ms);
 
 	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
