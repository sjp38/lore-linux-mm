Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54B7D82F64
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 17:34:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so372363166pfy.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:34:46 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z1si1866699pfi.275.2016.12.01.14.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 14:34:45 -0800 (PST)
Subject: [PATCH 09/11] mm: support section-unaligned ZONE_DEVICE memory
 ranges
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Dec 2016 14:30:35 -0800
Message-ID: <148063143537.37496.10587439764315811298.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: toshi.kani@hpe.com, linux-nvdimm@lists.01.org, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Logan Gunthorpe <logang@deltatee.com>, Vlastimil Babka <vbabka@suse.cz>

The initial motivation for this change is persistent memory platforms
that, unfortunately, align the pmem range on a boundary less than a full
section (64M vs 128M), and may change the alignment from one boot to the
next. A secondary motivation is the arrival of prospective ZONE_DEVICE
users that want devm_memremap_pages() to map PCI-E device memory ranges
to enable peer-to-peer DMA.

Currently the nvdimm core injects padding when 'pfn' (struct page
mapping configuration) instances are created. However, not all users of
devm_memremap_pages() have the opportunity to inject such padding. Users
of the memmap=ss!nn kernel command line option can trigger the following
failure with unaligned parameters like "memmap=0xfc000000!8G":

 WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
 devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
 [..]
 Call Trace:
  [<ffffffff814c0393>] dump_stack+0x86/0xc3
  [<ffffffff810b173b>] __warn+0xcb/0xf0
  [<ffffffff810b17bf>] warn_slowpath_fmt+0x5f/0x80
  [<ffffffff811eb105>] devm_memremap_pages+0x3b5/0x4c0
  [<ffffffffa006f308>] __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
  [<ffffffffa00e231a>] pmem_attach_disk+0x19a/0x440 [nd_pmem]

Without this change a user could inadvertently lose access to nvdimm
namespaces by adding/removing other DIMMs in the platform leading to the
BIOS changing the base alignment of the namespace in an incompatible
fashion. With this support we can accommodate a BIOS changing the
namespace to any alignment provided it is >= SECTION_ACTIVE_SIZE.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/sparse.c |  272 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 204 insertions(+), 68 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a8358d15a90d..d8c4bc9ccc1a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -24,6 +24,7 @@
 #ifdef CONFIG_SPARSEMEM_EXTREME
 struct mem_section *mem_section[NR_SECTION_ROOTS]
 	____cacheline_internodealigned_in_smp;
+static DEFINE_SPINLOCK(mem_section_lock); /* atomically instantiate new entries */
 #else
 struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
 	____cacheline_internodealigned_in_smp;
@@ -89,7 +90,22 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	if (!section)
 		return -ENOMEM;
 
-	mem_section[root] = section;
+	spin_lock(&mem_section_lock);
+	if (mem_section[root] == NULL) {
+		mem_section[root] = section;
+		section = NULL;
+	}
+	spin_unlock(&mem_section_lock);
+
+	/*
+	 * The only time we expect adding a section may race is during
+	 * post-meminit hotplug. So, there is no expectation that 'section'
+	 * leaks in the !slab_is_available() case.
+	 */
+	if (section && slab_is_available()) {
+		kfree(section);
+		return -EEXIST;
+	}
 
 	return 0;
 }
@@ -288,6 +304,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
 		struct mem_section_usage *usage)
 {
+	/*
+	 * Given that SPARSEMEM_VMEMMAP=y supports sub-section hotplug,
+	 * ->section_mem_map can not be guaranteed to point to a full
+	 *  section's worth of memory.  The field is only valid / used
+	 *  in the SPARSEMEM_VMEMMAP=n case.
+	 */
+	if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
+		mem_map = NULL;
+
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 		SECTION_HAS_MEM_MAP;
@@ -753,12 +778,176 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
+static bool is_early_section(struct mem_section *ms)
+{
+	struct page *usemap_page;
+
+	usemap_page = virt_to_page(ms->usage->pageblock_flags);
+	if (PageSlab(usemap_page) || PageCompound(usemap_page))
+		return false;
+	else
+		return true;
+
+}
+
+#ifndef CONFIG_MEMORY_HOTREMOVE
+static void free_map_bootmem(struct page *memmap)
+{
+}
+#endif
+
+static void section_deactivate(struct pglist_data *pgdat, unsigned long pfn,
+                unsigned long nr_pages)
+{
+	bool early_section;
+	struct page *memmap = NULL;
+	struct mem_section_usage *usage = NULL;
+	int section_nr = pfn_to_section_nr(pfn);
+	struct mem_section *ms = __nr_to_section(section_nr);
+	unsigned long mask = section_active_mask(pfn, nr_pages), flags;
+
+	pgdat_resize_lock(pgdat, &flags);
+	if (!ms->usage) {
+		mask = 0;
+	} else if ((ms->usage->map_active & mask) != mask) {
+		WARN(1, "section already deactivated active: %#lx mask: %#lx\n",
+				ms->usage->map_active, mask);
+		mask = 0;
+	} else {
+		early_section = is_early_section(ms);
+		ms->usage->map_active ^= mask;
+		if (ms->usage->map_active == 0) {
+			usage = ms->usage;
+			ms->usage = NULL;
+			memmap = sparse_decode_mem_map(ms->section_mem_map,
+					section_nr);
+			ms->section_mem_map = 0;
+		}
+	}
+	pgdat_resize_unlock(pgdat, &flags);
+
+	/*
+	 * There are 3 cases to handle across two configurations
+	 * (SPARSEMEM_VMEMMAP={y,n}):
+	 *
+	 * 1/ deactivation of a partial hot-added section (only possible
+	 * in the SPARSEMEM_VMEMMAP=y case).
+	 *    a/ section was present at memory init
+	 *    b/ section was hot-added post memory init
+	 * 2/ deactivation of a complete hot-added section
+	 * 3/ deactivation of a complete section from memory init
+	 *
+	 * For 1/, when map_active does not go to zero we will not be
+	 * freeing the usage map, but still need to free the vmemmap
+	 * range.
+	 *
+	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
+	 */
+	if (!mask)
+		return;
+	if (nr_pages < PAGES_PER_SECTION) {
+		if (!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)) {
+			WARN(1, "partial memory section removal not supported\n");
+			return;
+		}
+		if (!early_section)
+			depopulate_section_memmap(pfn, nr_pages);
+		memmap = 0;
+	}
+
+	if (usage) {
+		if (!early_section) {
+			/*
+			 * 'memmap' may be zero in the SPARSEMEM_VMEMMAP=y case
+			 * (see sparse_init_one_section()), so we can't rely on
+			 * it to determine if we need to depopulate the memmap.
+			 * Instead, we uncoditionally depopulate due to 'usage'
+			 * being valid.
+			 */
+			if (memmap || (nr_pages >= PAGES_PER_SECTION
+					&& IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)))
+				depopulate_section_memmap(pfn, nr_pages);
+			kfree(usage);
+			return;
+		}
+	}
+
+	/*
+	 * The usemap came from bootmem. This is packed with other usemaps
+	 * on the section which has pgdat at boot time. Just keep it as is now.
+	 */
+	if (memmap)
+		free_map_bootmem(memmap);
+}
+
+static struct page *section_activate(struct pglist_data *pgdat,
+		unsigned long pfn, unsigned nr_pages)
+{
+	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
+	unsigned long mask = section_active_mask(pfn, nr_pages), flags;
+	struct mem_section_usage *usage;
+	bool early_section = false;
+	struct page *memmap;
+	int rc = 0;
+
+	usage = __alloc_section_usage();
+	if (!usage)
+		return ERR_PTR(-ENOMEM);
+
+	pgdat_resize_lock(pgdat, &flags);
+	if (!ms->usage) {
+		ms->usage = usage;
+		usage = NULL;
+	} else
+		early_section = is_early_section(ms);
+
+	if (!mask)
+		rc = -EINVAL;
+	else if (mask & ms->usage->map_active)
+		rc = -EBUSY;
+	else
+		ms->usage->map_active |= mask;
+	pgdat_resize_unlock(pgdat, &flags);
+
+	kfree(usage);
+
+	if (rc)
+		return ERR_PTR(rc);
+
+
+	/*
+	 * The early init code does not consider partially populated
+	 * initial sections, it simply assumes that memory will never be
+	 * referenced.  If we hot-add memory into such a section then we
+	 * do not need to populate the memmap and can simply reuse what
+	 * is already there.
+	 */
+	if (nr_pages < PAGES_PER_SECTION && early_section)
+		return pfn_to_page(pfn);
+
+	memmap = populate_section_memmap(pfn, nr_pages, pgdat->node_id);
+	if (!memmap) {
+		section_deactivate(pgdat, pfn, nr_pages);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	return memmap;
+}
+
+/**
+ * sparse_add_section() - create a new memmap section, or populate an
+ * existing one
+ * @zone: host zone for the new memory mapping
+ * @start_pfn: first pfn to add (section aligned if zone != ZONE_DEVICE)
+ * @nr_pages: number of new pages to add
+ *
+ * Returns 0 on success.
+ */
 int __meminit sparse_add_section(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct pglist_data *pgdat = zone->zone_pgdat;
-	static struct mem_section_usage *usage;
 	struct mem_section *ms;
 	struct page *memmap;
 	unsigned long flags;
@@ -771,37 +960,27 @@ int __meminit sparse_add_section(struct zone *zone, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = populate_section_memmap(start_pfn, PAGES_PER_SECTION,
-			pgdat->node_id);
-	if (!memmap)
-		return -ENOMEM;
-	usage = __alloc_section_usage();
-	if (!usage) {
-		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION);
-		return -ENOMEM;
-	}
 
-	pgdat_resize_lock(pgdat, &flags);
+	memmap = section_activate(pgdat, start_pfn, nr_pages);
+	if (IS_ERR(memmap))
+		return PTR_ERR(memmap);
 
+	pgdat_resize_lock(pgdat, &flags);
 	ms = __pfn_to_section(start_pfn);
-	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
+	if (nr_pages == PAGES_PER_SECTION && (ms->section_mem_map
+				& SECTION_MARKED_PRESENT)) {
 		ret = -EBUSY;
 		goto out;
 	}
-
-	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
-
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
-
-	sparse_init_one_section(ms, section_nr, memmap, usage);
-
+	sparse_init_one_section(ms, section_nr, memmap, ms->usage);
 out:
 	pgdat_resize_unlock(pgdat, &flags);
-	if (ret < 0 && ret != -EEXIST) {
-		kfree(usage);
-		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION);
+	if (nr_pages == PAGES_PER_SECTION && ret < 0 && ret != -EEXIST) {
+		section_deactivate(pgdat, start_pfn, nr_pages);
 		return ret;
 	}
+	memset(memmap, 0, sizeof(struct page) * nr_pages);
 	return 0;
 }
 
@@ -827,58 +1006,15 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usage(struct page *memmap,
-		struct mem_section_usage *usage, unsigned long pfn,
-		unsigned long nr_pages)
-{
-	struct page *usemap_page;
-
-	if (!usage)
-		return;
-
-	usemap_page = virt_to_page(usage->pageblock_flags);
-	/*
-	 * Check to see if allocation came from hot-plug-add
-	 */
-	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
-		kfree(usage);
-		if (memmap)
-			depopulate_section_memmap(pfn, nr_pages);
-		return;
-	}
-
-	/*
-	 * The usemap came from bootmem. This is packed with other usemaps
-	 * on the section which has pgdat at boot time. Just keep it as is now.
-	 */
-
-	if (memmap)
-		free_map_bootmem(memmap);
-}
-
 void sparse_remove_section(struct zone *zone, struct mem_section *ms,
 		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset)
 {
-	unsigned long flags;
-	struct page *memmap = NULL;
-	struct mem_section_usage *usage = NULL;
 	struct pglist_data *pgdat = zone->zone_pgdat;
 
-	pgdat_resize_lock(pgdat, &flags);
-	if (ms->section_mem_map) {
-		usage = ms->usage;
-		memmap = sparse_decode_mem_map(ms->section_mem_map,
-						__section_nr(ms));
-		ms->section_mem_map = 0;
-		ms->usage = NULL;
-	}
-	pgdat_resize_unlock(pgdat, &flags);
-
-	clear_hwpoisoned_pages(memmap + map_offset,
-			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage, section_nr_to_pfn(__section_nr(ms)),
-			PAGES_PER_SECTION);
+	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
+			nr_pages - map_offset);
+	section_deactivate(pgdat, pfn, nr_pages);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
