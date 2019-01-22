Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 683198E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:37:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so8958759edm.18
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:37:49 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id h9si2900673edr.174.2019.01.22.02.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:37:46 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH v2 3/4] mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
Date: Tue, 22 Jan 2019 11:37:07 +0100
Message-Id: <20190122103708.11043-4-osalvador@suse.de>
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Oscar Salvador <osalvador@suse.de>

Physical memory hotadd has to allocate a memmap (struct page array) for
the newly added memory section. Currently, alloc_pages_node() is used
for those allocations.

This has some disadvantages:
 a) an existing memory is consumed for that purpose
    (~2MB per 128MB memory section on x86_64)
 b) if the whole node is movable then we have off-node struct pages
    which has performance drawbacks.

a) has turned out to be a problem for memory hotplug based ballooning
because the userspace might not react in time to online memory while
the memory consumed during physical hotadd consumes enough memory to push
system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
policy for the newly added memory") has been added to workaround that
problem.

I have also seen hot-add operations failing on powerpc due to the fact
that we try to use order-8 pages. If the base page size is 64KB, this
gives us 16MB, and if we run out of those, we simply fail.
One could arge that we can fall back to basepages as we do in x86_64.

But We can do much better when CONFIG_SPARSEMEM_VMEMMAP=y because vmemap
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
allocated we need a way to mark altmap pfns used for the allocation.
For this, we define a init() and a constructor() callback
in mhp_restrictions structure.

Init() points now to init_altmap_memmap(), and constructor() to
mark_vmemmap_pages().

init_altmap_memmap() takes care of checking the flags, and inits the
vmemap_altmap structure with the required fields.
mark_vmemmap_pages() takes care of marking the pages as Vmemmap, and inits
some fields we need.

The current layout of the Vmemmap pages are:

- There is a head Vmemmap (first page), which has the following fields set:
  * page->_refcount: number of sections that used this altmap
  * page->private: total number of vmemmap pages
- The remaining vmemmap pages have:
  * page->freelist: pointer to the head vmemmap page

This is done to easy the computation we need in some places.

So, let us say we hot-add 9GB on x86_64:

head->_refcount = 72 sections
head->private = 36864 vmemmap pages
tail's->freelist = head

We keep a _refcount of the used sections to know how much do we have to defer
the call to vmemmap_free().
The thing is that the first pages of the hot-added range are used to create
the memmap mapping, so we cannot remove those first, otherwise we would blow up.

What we do is that since when we hot-remove a memory-range, sections are being
removed sequentially, we wait until we hit the last section, and then we free
the hole range to vmemmap_free backwards.
We know that it is the last section because in every pass we
decrease head->_refcount, and when it reaches 0, we got our last section.

We also have to be careful about those pages during online and offline
operations. They are simply skipped now so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

Please note that only the memory hotplug is currently using this
allocation scheme. The boot time memmap allocation could use the same
trick as well but this is not done yet.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c            |   5 +-
 arch/powerpc/mm/init_64.c      |   7 +++
 arch/s390/mm/init.c            |   6 ++
 arch/x86/mm/init_64.c          |  10 ++++
 drivers/hv/hv_balloon.c        |   1 +
 drivers/xen/balloon.c          |   1 +
 include/linux/memory_hotplug.h |  23 +++++--
 include/linux/memremap.h       |   2 +-
 include/linux/page-flags.h     |  23 +++++++
 mm/compaction.c                |   8 +++
 mm/memory_hotplug.c            | 133 ++++++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c                |  36 ++++++++++-
 mm/page_isolation.c            |  13 ++++
 mm/sparse.c                    | 108 +++++++++++++++++++++++++++++++++
 mm/util.c                      |   2 +
 15 files changed, 354 insertions(+), 24 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 3926969f9187..c4eb6d96d088 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -749,7 +749,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
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
index a5091c034747..d8b487a6f019 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -296,6 +296,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 
 		if (base_pfn >= alt_start && base_pfn < alt_end) {
 			vmem_altmap_free(altmap, nr_pages);
+		} else if (PageVmemmap(page)) {
+			/*
+			 * runtime vmemmap pages are residing inside the memory
+			 * section so they do not have to be freed anywhere.
+			 */
+			while (PageVmemmap(page))
+				__ClearPageVmemmap(page++);
 		} else if (PageReserved(page)) {
 			/* allocated from bootmem */
 			if (page_size < PAGE_SIZE) {
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 9ae71a82e9e1..75e96860a9ac 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -231,6 +231,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunately.
+	 */
+	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index db42c11b48fb..2e40c9e637b9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -809,6 +809,16 @@ static void __meminit free_pagetable(struct page *page, int order)
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
+	/*
+	 * runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page)) {
+		while (nr_pages--)
+			__ClearPageVmemmap(page++);
+		return;
+	}
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b32036cbb7a4..582d6e8c734d 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -1585,6 +1585,7 @@ static int balloon_probe(struct hv_device *dev,
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 	do_hot_add = hot_add;
+	hotplug_vmemmap_enabled = false;
 #else
 	do_hot_add = false;
 #endif
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 3ff8f91b1fea..678e835718cf 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -715,6 +715,7 @@ static int __init balloon_init(void)
 	set_online_page_callback(&xen_online_pages);
 	register_memory_notifier(&xen_memory_nb);
 	register_sysctl_table(xen_root);
+	hotplug_vmemmap_enabled = false;
 #endif
 
 #ifdef CONFIG_XEN_PV
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4e0d75b17715..89317ef50a61 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -118,13 +118,27 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
  * and offline memory explicitly. Lack of this bit means that the caller has to
  * call move_pfn_range_to_zone to finish the initialization.
  */
-
 #define MHP_MEMBLOCK_API               1<<0
 
-/* Restrictions for the memory hotplug */
+/*
+ * Do we want memmap (struct page array) allocated from the hotadded range.
+ * Please note that only SPARSE_VMEMMAP implements this feature and some
+ * architectures might not support it even for that memory model (e.g. s390)
+ */
+#define MHP_MEMMAP_FROM_RANGE          1<<1
+
+/* Restrictions for the memory hotplug
+ * flags: MHP_ flags
+ * altmap: use this alternative allocator for memmaps
+ * init: callback to be called before we add this memory
+ * constructor: callback to be called once the more has been added
+ */
 struct mhp_restrictions {
-	unsigned long flags;    /* MHP_ flags */
-	struct vmem_altmap *altmap; /* use this alternative allocator for memmaps */
+	unsigned long flags;
+	struct vmem_altmap *altmap;
+	void (*init)(unsigned long, unsigned long, struct vmem_altmap *,
+						struct mhp_restrictions *);
+	void (*constructor)(struct vmem_altmap *, struct mhp_restrictions *);
 };
 
 /* reasonably generic interface to expand the physical pages */
@@ -345,6 +359,7 @@ extern int arch_add_memory(int nid, u64 start, u64 size,
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
+extern void mark_vmemmap_pages(struct vmem_altmap *self, struct mhp_restrictions *r);
 extern int sparse_add_one_section(int nid, unsigned long start_pfn,
 				  struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f0628660d541..cfde1c1febb7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -16,7 +16,7 @@ struct device;
  * @alloc: track pages consumed, private to vmemmap_populate()
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 808b4183e30d..2483fcbe8ed6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -437,6 +437,29 @@ static __always_inline int __PageMovable(struct page *page)
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
+	__ClearPageReserved(page);
+	page->mapping = NULL;
+}
+
+static __always_inline void __SetPageVmemmap(struct page *page)
+{
+	__SetPageReserved(page);
+	page->mapping = (void *)VMEMMAP_PAGE;
+}
+
+static __always_inline struct page *vmemmap_get_head(struct page *page)
+{
+	return (struct page *)page->freelist;
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
diff --git a/mm/compaction.c b/mm/compaction.c
index 9830f81cd27f..8bf59eaed204 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -852,6 +852,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		page = pfn_to_page(low_pfn);
 
 		/*
+		 * Vmemmap pages are pages that are used for creating the memmap
+		 * array mapping, and they reside in their hot-added memory range.
+		 * Therefore, we cannot migrate them.
+		 */
+		if (PageVmemmap(page))
+			goto isolate_fail;
+
+		/*
 		 * Check if the pageblock has already been marked skipped.
 		 * Only the aligned PFN is checked as the caller isolates
 		 * COMPACT_CLUSTER_MAX at a time so the second call must
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8313279136ff..3c9eb3b82b34 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -73,6 +73,12 @@ bool memhp_auto_online = true;
 #endif
 EXPORT_SYMBOL_GPL(memhp_auto_online);
 
+/*
+ * Do we want to allocate the memmap array from the
+ * hot-added range?
+ */
+bool hotplug_vmemmap_enabled = true;
+
 static int __init setup_memhp_default_state(char *str)
 {
 	if (!strcmp(str, "online"))
@@ -264,6 +270,18 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
 }
 
+static void init_altmap_memmap(unsigned long pfn, unsigned long nr_pages,
+						struct vmem_altmap *altmap,
+						struct mhp_restrictions *r)
+{
+	if (!(r->flags & MHP_MEMMAP_FROM_RANGE))
+		return;
+
+	altmap->base_pfn = pfn;
+	altmap->free = nr_pages;
+	r->altmap = altmap;
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -276,12 +294,18 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
-	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap *altmap;
+	struct vmem_altmap __memblk_altmap = {};
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
+	if (restrictions->init)
+		restrictions->init(phys_start_pfn, nr_pages, &__memblk_altmap,
+								restrictions);
+
+	altmap = restrictions->altmap;
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -310,6 +334,12 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
+
+	/*
+	 * Check if we have a constructor
+	 */
+	if (restrictions->constructor)
+		restrictions->constructor(altmap, restrictions);
 out:
 	return err;
 }
@@ -694,17 +724,48 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	return onlined_pages;
 }
 
+static unsigned long check_nr_vmemmap_pages(struct page *page)
+{
+	if (PageVmemmap(page)) {
+		struct page *head = vmemmap_get_head(page);
+		unsigned long vmemmap_pages = page_private(head);
+
+		return vmemmap_pages - (page - head);
+	}
+
+	return 0;
+}
+
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
 	unsigned long onlined_pages = *(unsigned long *)arg;
+	unsigned long pfn = start_pfn;
+	unsigned long skip_pages = 0;
+
+	if (PageVmemmap(pfn_to_page(pfn))) {
+		/*
+		 * We do not want to send vmemmap pages to __free_pages_core,
+		 * as we will have to populate that with checks to make sure
+		 * vmemmap pages preserve their state.
+		 * Skipping them here saves us some complexity, and has the
+		 * side effect of not accounting vmemmap pages as managed_pages.
+		 */
+		skip_pages = check_nr_vmemmap_pages(pfn_to_page(pfn));
+		skip_pages = min_t(unsigned long, skip_pages, nr_pages);
+		pfn += skip_pages;
+	}
 
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
+	if ((nr_pages > skip_pages) && PageReserved(pfn_to_page(pfn)))
+		onlined_pages = online_pages_blocks(pfn, nr_pages - skip_pages);
 
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-	*(unsigned long *)arg += onlined_pages;
+	/*
+	 * We do want to account vmemmap pages to present_pages, so
+	 * make sure to add it up.
+	 */
+	*(unsigned long *)arg += onlined_pages + skip_pages;
 	return 0;
 }
 
@@ -1134,6 +1195,12 @@ int __ref add_memory_resource(int nid, struct resource *res)
 
 	/* call arch's memory hotadd */
 	restrictions.flags = MHP_MEMBLOCK_API;
+	if (hotplug_vmemmap_enabled) {
+		restrictions.flags |= MHP_MEMMAP_FROM_RANGE;
+		restrictions.init = init_altmap_memmap;
+		restrictions.constructor = mark_vmemmap_pages;
+	}
+
 	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
 		goto error;
@@ -1547,8 +1614,7 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 		node_clear_state(node, N_MEMORY);
 }
 
-static int __ref __offline_pages(unsigned long start_pfn,
-		  unsigned long end_pfn)
+static int __ref __offline_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn, nr_pages;
 	unsigned long offlined_pages = 0;
@@ -1558,14 +1624,30 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	struct zone *zone;
 	struct memory_notify arg;
 	char *reason;
+	unsigned long nr_vmemmap_pages = 0;
+	bool skip_migration = false;
 
 	mem_hotplug_begin();
 
+	if (PageVmemmap(pfn_to_page(start_pfn))) {
+		nr_vmemmap_pages = check_nr_vmemmap_pages(pfn_to_page(start_pfn));
+		if (start_pfn + nr_vmemmap_pages >= end_pfn) {
+			/*
+			 * It can be that depending on how large is the
+			 * hot-added range, an entire memblock only contains
+			 * vmemmap pages.
+			 * Should be that the case, there is no reason in trying
+			 * to isolate and migrate this range.
+			 */
+			nr_vmemmap_pages = end_pfn - start_pfn;
+			skip_migration = true;
+		}
+	}
+
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
 				  &valid_end)) {
-		mem_hotplug_done();
 		ret = -EINVAL;
 		reason = "multizone range";
 		goto failed_removal;
@@ -1575,14 +1657,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
-	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE,
-				       SKIP_HWPOISON | REPORT_FAILURE);
-	if (ret) {
-		mem_hotplug_done();
-		reason = "failure to isolate range";
-		goto failed_removal;
+	if (!skip_migration) {
+		/* set above range as isolated */
+		ret = start_isolate_page_range(start_pfn, end_pfn,
+					       MIGRATE_MOVABLE,
+					       SKIP_HWPOISON | REPORT_FAILURE);
+		if (ret) {
+			reason = "failure to isolate range";
+			goto failed_removal;
+		}
 	}
 
 	arg.start_pfn = start_pfn;
@@ -1596,6 +1679,13 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal_isolated;
 	}
 
+	if (skip_migration)
+		/*
+		 * If the entire memblock is populated with vmemmap pages,
+		 * there is nothing we can migrate, so skip it.
+		 */
+		goto no_migration;
+
 	do {
 		for (pfn = start_pfn; pfn;) {
 			if (signal_pending(current)) {
@@ -1634,14 +1724,25 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
+no_migration:
 	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
 						offline_isolated_pages_cb);
 
 	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	if (!skip_migration)
+		undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
+
+	/*
+	 * Vmemmap pages are not being accounted to managed_pages but to
+	 * present_pages.
+	 * We need to add them up to the already offlined pages to get
+	 * the accounting right.
+	 */
+	offlined_pages += nr_vmemmap_pages;
+
 	zone->present_pages -= offlined_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cad7468a0f20..05492cc95d74 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1257,14 +1257,19 @@ static void __meminit __init_struct_page_nolru(struct page *page,
 					       unsigned long zone, int nid,
 					       bool is_reserved)
 {
-	mm_zero_struct_page(page);
+	if (!PageVmemmap(page)) {
+		/*
+		 * Vmemmap pages need to preserve their state.
+		 */
+		mm_zero_struct_page(page);
+		init_page_count(page);
+	}
 
 	/*
 	 * We can use a non-atomic operation for setting the
 	 * PG_reserved flag as we are still initializing the pages.
 	 */
 	set_page_links(page, zone, nid, pfn, is_reserved);
-	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
 	page_kasan_tag_reset(page);
@@ -8138,6 +8143,19 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		/*
+		 * Vmemmap pages are marked as reserved, so skip them here,
+		 * otherwise the check below will drive us to a bad conclusion.
+		 */
+		if (PageVmemmap(page)) {
+			struct page *head = vmemmap_get_head(page);
+			unsigned int skip_pages;
+
+			skip_pages = page_private(head) - (page - head);
+			iter += skip_pages - 1;
+			continue;
+		}
+
 		if (PageReserved(page))
 			goto unmovable;
 
@@ -8506,6 +8524,20 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
+		/*
+		 * Vmemmap pages are self-hosted in the hot-added range,
+		 * we do not need to free them, so skip them.
+		 */
+		if (PageVmemmap(page)) {
+			struct page *head = vmemmap_get_head(page);
+			unsigned long skip_pages;
+
+			skip_pages = page_private(head) - (page - head);
+			pfn += skip_pages;
+			continue;
+		}
+
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index ce323e56b34d..e29b378f39ae 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -155,6 +155,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 		page = pfn_to_online_page(pfn + i);
 		if (!page)
 			continue;
+		if (PageVmemmap(page))
+			continue;
 		return page;
 	}
 	return NULL;
@@ -257,6 +259,17 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (PageVmemmap(page)) {
+			/*
+			 * Vmemmap pages are not isolated. Skip them.
+			 */
+			struct page *head = vmemmap_get_head(page);
+			unsigned long skip_pages;
+
+			skip_pages = page_private(head) - (page - head);
+			pfn += skip_pages;
+			continue;
+		}
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
diff --git a/mm/sparse.c b/mm/sparse.c
index 7ea5dc6c6b19..dd30468dc8f5 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -579,6 +579,103 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+void mark_vmemmap_pages(struct vmem_altmap *self, struct mhp_restrictions *r)
+{
+	unsigned long pfn = self->base_pfn + self->reserve;
+	unsigned long nr_pages = self->alloc;
+	unsigned long nr_sects = self->free / PAGES_PER_SECTION;
+	unsigned long i;
+	struct page *head;
+
+	if (!(r->flags & MHP_MEMMAP_FROM_RANGE) || !nr_pages)
+		return;
+
+	/*
+	 * All allocations for the memory hotplug are the same sized so align
+	 * should be 0.
+	 */
+	WARN_ON(self->align);
+
+	/*
+	 * Mark these pages as Vmemmap pages.
+	 * We keep track of the sections used by this altmap by means
+	 * of a refcount, so we know how much do we have to defer the call
+	 * to vmemmap_free for this memory range.
+	 * This refcount is kept in the first vmemmap page (head).
+	 * For example:
+	 * We add 10GB: (ffffea0004000000 - ffffea000427ffc0)
+	 * ffffea0004000000 will have a refcount of 80.
+	 * To easily get the head of any vmemmap page, we keep a pointer of it
+	 * in page->freelist.
+	 * We also keep the total nr of pages used by this altmap in the head
+	 * page.
+	 * So, we have this picture:
+	 *
+	 * Head page:
+	 *  page->_refcount: nr of sections
+	 *  page->private: nr of vmemmap pages
+	 * Tail page:
+	 *  page->freelist: pointer to the head page
+	 */
+
+	/*
+	 * Head, first vmemmap page.
+	 */
+	head = pfn_to_page(pfn);
+
+	for (i = 0; i < nr_pages; i++, pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		mm_zero_struct_page(page);
+		__SetPageVmemmap(page);
+		page->freelist = head;
+		init_page_count(page);
+	}
+	set_page_count(head, (int)nr_sects);
+	set_page_private(head, nr_pages);
+}
+
+/*
+ * If the range we are trying to remove was hot-added with vmemmap pages,
+ * we need to keep track of it to know how much do we have do defer the
+ * the free up.
+ * Since sections are removed sequentally in __remove_pages()->__remove_section(),
+ * we just wait until we hit the last section.
+ * Once that happens, we can trigger free_deferred_vmemmap_range to actually
+ * free the whole memory-range.
+ * This is done because we actually have to free the memory-range backwards.
+ * The reason is that the first pages of that memory are used for the pagetables
+ * in order to create the memmap mapping.
+ * If we removed those pages first, we would blow up, so the vmemmap pages have
+ * to be freed the last.
+ * Since hot-add/hot-remove operations are serialized by the hotplug lock, we know
+ * that once we start a hot-remove operation, we will go all the way down until it
+ * is done, so we do not need any locking for these two variables.
+ */
+static struct page *head_vmemmap_page;
+static bool in_vmemmap_range;
+
+static inline bool vmemmap_dec_and_test(void)
+{
+	return page_ref_dec_and_test(head_vmemmap_page);
+}
+
+static void free_deferred_vmemmap_range(unsigned long start,
+					unsigned long end)
+{
+	unsigned long nr_pages = end - start;
+	unsigned long first_section = (unsigned long)head_vmemmap_page;
+
+	while (start >= first_section) {
+		pr_info("vmemmap_free: %lx - %lx\n", start, end);
+		vmemmap_free(start, end, NULL);
+		end = start;
+		start -= nr_pages;
+	}
+	head_vmemmap_page = NULL;
+	in_vmemmap_range = false;
+}
+
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
@@ -591,6 +688,17 @@ static void __kfree_section_memmap(struct page *memmap,
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
+	if (PageVmemmap(memmap) && !in_vmemmap_range) {
+		in_vmemmap_range = true;
+		head_vmemmap_page = memmap;
+	}
+
+	if (in_vmemmap_range) {
+		if (vmemmap_dec_and_test())
+			free_deferred_vmemmap_range(start, end);
+		return;
+	}
+
 	vmemmap_free(start, end, altmap);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/util.c b/mm/util.c
index 1ea055138043..e0ac8712a392 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -517,6 +517,8 @@ struct address_space *page_mapping(struct page *page)
 	mapping = page->mapping;
 	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;
+	if ((unsigned long)mapping == VMEMMAP_PAGE)
+		return NULL;
 
 	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
 }
-- 
2.13.7
