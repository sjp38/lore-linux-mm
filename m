Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D57276B026B
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:43 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so11230637pgc.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:43 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 123si31298904pgh.10.2016.12.08.18.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:42 -0800 (PST)
Subject: [PATCH v2 07/11] mm: convert kmalloc_section_memmap() to
 populate_section_memmap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:41:31 -0800
Message-ID: <148125129174.13512.7047794914768073323.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: toshi.kani@hpe.com, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Logan Gunthorpe <logang@deltatee.com>, Vlastimil Babka <vbabka@suse.cz>

Allow sub-section sized ranges to be added to the memmap.
populate_section_memmap() takes an explict pfn range rather than
assuming a full section, and those parameters are plumbed all the way
through to vmmemap_populate(). There should be no sub-section in
current code. New warnings are added to clarify which memmap allocation
paths are sub-section capable.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c |    4 ++-
 include/linux/mm.h    |    3 ++
 mm/sparse-vmemmap.c   |   24 ++++++++++++++------
 mm/sparse.c           |   60 ++++++++++++++++++++++++++++++++-----------------
 4 files changed, 61 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 14b9dd71d9e8..e3fb2b1be060 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1230,7 +1230,9 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	struct vmem_altmap *altmap = to_vmem_altmap(start);
 	int err;
 
-	if (boot_cpu_has(X86_FEATURE_PSE))
+	if (end - start < PAGES_PER_SECTION * sizeof(struct page))
+		err = vmemmap_populate_basepages(start, end, node);
+	else if (boot_cpu_has(X86_FEATURE_PSE))
 		err = vmemmap_populate_hugepages(start, end, node, altmap);
 	else if (altmap) {
 		pr_err_once("%s: no cpu support for altmap allocations\n",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d73aeaf..7d6fb52b1f31 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2321,7 +2321,8 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
-struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
+struct page *__populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 574c67b663fe..8679d4a81b98 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -248,20 +248,28 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 	return 0;
 }
 
-struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+struct page * __meminit __populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid)
 {
 	unsigned long start;
 	unsigned long end;
-	struct page *map;
 
-	map = pfn_to_page(pnum * PAGES_PER_SECTION);
-	start = (unsigned long)map;
-	end = (unsigned long)(map + PAGES_PER_SECTION);
+	/*
+	 * The minimum granularity of memmap extensions is
+	 * SECTION_ACTIVE_SIZE as allocations are tracked in the
+	 * 'map_active' bitmap of the section.
+	 */
+	end = ALIGN(pfn + nr_pages, PHYS_PFN(SECTION_ACTIVE_SIZE));
+	pfn &= PHYS_PFN(SECTION_ACTIVE_MASK);
+	nr_pages = end - pfn;
+
+	start = (unsigned long) pfn_to_page(pfn);
+	end = start + nr_pages * sizeof(struct page);
 
 	if (vmemmap_populate(start, end, nid))
 		return NULL;
 
-	return map;
+	return pfn_to_page(pfn);
 }
 
 void __init sparse_mem_maps_populate_node(struct page **map_map,
@@ -284,11 +292,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		struct mem_section *ms;
+		unsigned long pfn = section_nr_to_pfn(pnum);
 
 		if (!present_section_nr(pnum))
 			continue;
 
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
+		map_map[pnum] = __populate_section_memmap(pfn,
+				PAGES_PER_SECTION, nodeid);
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
diff --git a/mm/sparse.c b/mm/sparse.c
index 00fdb5d04680..97f91770e3d0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -423,7 +423,8 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
-struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
+struct page __init *__populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid)
 {
 	struct page *map;
 	unsigned long size;
@@ -475,10 +476,12 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	/* fallback */
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		struct mem_section *ms;
+		unsigned long pfn = section_nr_to_pfn(pnum);
 
 		if (!present_section_nr(pnum))
 			continue;
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
+		map_map[pnum] = __populate_section_memmap(pfn,
+				PAGES_PER_SECTION, nodeid);
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
@@ -506,7 +509,8 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
-	map = sparse_mem_map_populate(pnum, nid);
+	map = __populate_section_memmap(section_nr_to_pfn(pnum),
+			PAGES_PER_SECTION, nid);
 	if (map)
 		return map;
 
@@ -648,15 +652,16 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static struct page *populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid)
 {
-	/* This will make the necessary allocations eventually. */
-	return sparse_mem_map_populate(pnum, nid);
+	return __populate_section_memmap(pfn, nr_pages, nid);
 }
-static void __kfree_section_memmap(struct page *memmap)
+
+static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages)
 {
-	unsigned long start = (unsigned long)memmap;
-	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
+	unsigned long start = (unsigned long) pfn_to_page(pfn);
+	unsigned long end = start + nr_pages * sizeof(struct page);
 
 	vmemmap_free(start, end);
 }
@@ -670,11 +675,18 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(void)
+struct page *populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid)
 {
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
 
+	if ((pfn & ~PAGE_SECTION_MASK) || nr_pages != PAGES_PER_SECTION) {
+		WARN(1, "%s: called with section unaligned parameters\n",
+				__func__);
+		return NULL;
+	}
+
 	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
 	if (page)
 		goto got_map_page;
@@ -691,13 +703,16 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages)
 {
-	return __kmalloc_section_memmap();
-}
+	struct page *memmap = pfn_to_page(pfn);
+
+	if ((pfn & ~PAGE_SECTION_MASK) || nr_pages != PAGES_PER_SECTION) {
+		WARN(1, "%s: called with section unaligned parameters\n",
+				__func__);
+		return;
+	}
 
-static void __kfree_section_memmap(struct page *memmap)
-{
 	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
 	else
@@ -755,12 +770,13 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
+	memmap = populate_section_memmap(start_pfn, PAGES_PER_SECTION,
+			pgdat->node_id);
 	if (!memmap)
 		return -ENOMEM;
 	usage = __alloc_section_usage();
 	if (!usage) {
-		__kfree_section_memmap(memmap);
+		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION);
 		return -ENOMEM;
 	}
 
@@ -782,7 +798,7 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret < 0 && ret != -EEXIST) {
 		kfree(usage);
-		__kfree_section_memmap(memmap);
+		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION);
 		return ret;
 	}
 	return 0;
@@ -811,7 +827,8 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 #endif
 
 static void free_section_usage(struct page *memmap,
-		struct mem_section_usage *usage)
+		struct mem_section_usage *usage, unsigned long pfn,
+		unsigned long nr_pages)
 {
 	struct page *usemap_page;
 
@@ -825,7 +842,7 @@ static void free_section_usage(struct page *memmap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usage);
 		if (memmap)
-			__kfree_section_memmap(memmap);
+			depopulate_section_memmap(pfn, nr_pages);
 		return;
 	}
 
@@ -858,7 +875,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage);
+	free_section_usage(memmap, usage, section_nr_to_pfn(__section_nr(ms)),
+			PAGES_PER_SECTION);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
