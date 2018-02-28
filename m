Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AACC46B002D
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:27:26 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id g127so970527qkc.14
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:27:26 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u43si833144qtu.379.2018.02.27.19.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:27:25 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 4/4] mm/sparse: Optimize memmap allocation during sparse_init()
Date: Wed, 28 Feb 2018 11:26:57 +0800
Message-Id: <20180228032657.32385-5-bhe@redhat.com>
In-Reply-To: <20180228032657.32385-1-bhe@redhat.com>
References: <20180228032657.32385-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

In sparse_init(), two temporary pointer arrays, usemap_map and map_map
are allocated with the size of NR_MEM_SECTIONS. They are used to store
each memory section's usemap and mem map if marked as present. With
the help of these two arrays, continuous memory chunk is allocated for
usemap and memmap for memory sections on one node. This avoids too many
memory fragmentations. Like below diagram, '1' indicates the present
memory section, '0' means absent one. The number 'n' which means the
number of present sections could be much smaller than NR_MEM_SECTIONS
on most of systems.

|1|1|1|1|0|0|0|0|1|1|0|0|...|1|0||1|0|...|1||0|1|...|0|
-------------------------------------------------------
 0 1 2 3         4 5         i   i+1     n-1   n

If fail to populate the page tables to map one section's memmap, its
->section_mem_map will be cleared finally to indicate that it's not present.
After use, these two arrays will be released at the end of sparse_init().

In 4-level paging mode, each array costs 4M which can be ignorable. While
in 5-level paging, they costs 256M each, 512M altogether. Kdump kernel
Usually only reserves very few memory, e.g 256M. So, even thouth they are
temporarily allocated, still not acceptable.

In fact, there's no need to allocate them with the size of NR_MEM_SECTIONS.
Since the ->section_mem_map clearing has been deferred to the last, the
number of present memory sections are kept the same during sparse_init()
until we finally clear out the memory section's ->section_mem_map if its
usemap or memmap is not correctly handled. Thus in the middle whenever
for_each_present_section_nr() loop is taken, the i-th present memory
section is always the same one.

Here only allocate usemap_map and map_map with the size of
'nr_present_sections'. For the i-th present memory section, install its
usemap and memmap to usemap_map[i] and mam_map[i] during allocation. Then
in the last for_each_present_section_nr() loop which clears the failed
memory section's ->section_mem_map, fetch usemap and memmap from
usemap_map[] and map_map[] array and set them into mem_section[]
accordingly.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse-vmemmap.c |  5 +++--
 mm/sparse.c         | 33 +++++++++++++++++++++++----------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 640e68f8324b..ca72203d5b49 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -281,6 +281,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	unsigned long pnum;
 	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
 	void *vmemmap_buf_start;
+	int idx_present = 0;
 
 	size = ALIGN(size, PMD_SIZE);
 	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
@@ -297,8 +298,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (!present_section_nr(pnum))
 			continue;
 
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
-		if (map_map[pnum])
+		map_map[idx_present] = sparse_mem_map_populate(pnum, nodeid, NULL);
+		if (map_map[idx_present++])
 			continue;
 		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
diff --git a/mm/sparse.c b/mm/sparse.c
index e1aa2f44530d..34a28c0c7376 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -410,6 +410,7 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 	unsigned long pnum;
 	unsigned long **usemap_map = (unsigned long **)data;
 	int size = usemap_size();
+	int idx_present = 0;
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
 							  size * usemap_count);
@@ -421,9 +422,10 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
-		usemap_map[pnum] = usemap;
+		usemap_map[idx_present] = usemap;
 		usemap += size;
-		check_usemap_section_nr(nodeid, usemap_map[pnum]);
+		check_usemap_section_nr(nodeid, usemap_map[idx_present]);
+		idx_present++;
 	}
 }
 
@@ -452,14 +454,17 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	void *map;
 	unsigned long pnum;
 	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
+	int idx_present;
 
 	map = alloc_remap(nodeid, size * map_count);
 	if (map) {
+		idx_present = 0;
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
 				continue;
-			map_map[pnum] = map;
+			map_map[idx_present] = map;
 			map += size;
+			idx_present++;
 		}
 		return;
 	}
@@ -469,23 +474,26 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 					      BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
 	if (map) {
+		idx_present = 0;
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
 				continue;
-			map_map[pnum] = map;
+			map_map[idx_present] = map;
 			map += size;
+			idx_present++;
 		}
 		return;
 	}
 
 	/* fallback */
+	idx_present = 0;
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		struct mem_section *ms;
 
 		if (!present_section_nr(pnum))
 			continue;
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
-		if (map_map[pnum])
+		map_map[idx_present] = sparse_mem_map_populate(pnum, nodeid, NULL);
+		if (map_map[idx_present++])
 			continue;
 		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
@@ -565,6 +573,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
 		/* new start, update count etc*/
 		nodeid_begin = nodeid;
 		pnum_begin = pnum;
+		data += map_count * data_unit_size;
 		map_count = 1;
 	}
 	/* ok, last chunk */
@@ -583,6 +592,7 @@ void __init sparse_init(void)
 	unsigned long *usemap;
 	unsigned long **usemap_map;
 	int size;
+	int idx_present = 0;
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	int size2;
 	struct page **map_map;
@@ -605,7 +615,7 @@ void __init sparse_init(void)
 	 * powerpc need to call sparse_init_one_section right after each
 	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
 	 */
-	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
+	size = sizeof(unsigned long *) * nr_present_sections;
 	usemap_map = memblock_virt_alloc(size, 0);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
@@ -614,7 +624,7 @@ void __init sparse_init(void)
 				sizeof(usemap_map[0]));
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
+	size2 = sizeof(struct page *) * nr_present_sections;
 	map_map = memblock_virt_alloc(size2, 0);
 	if (!map_map)
 		panic("can not allocate map_map\n");
@@ -626,24 +636,27 @@ void __init sparse_init(void)
 	for_each_present_section_nr(0, pnum) {
 		struct mem_section *ms;
 		ms = __nr_to_section(pnum);
-		usemap = usemap_map[pnum];
+		usemap = usemap_map[idx_present];
 		if (!usemap) {
 			ms->section_mem_map = 0;
+			idx_present++;
 			continue;
 		}
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-		map = map_map[pnum];
+		map = map_map[idx_present];
 #else
 		map = sparse_early_mem_map_alloc(pnum);
 #endif
 		if (!map) {
 			ms->section_mem_map = 0;
+			idx_present++;
 			continue;
 		}
 
 		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
 								usemap);
+		idx_present++;
 	}
 
 	vmemmap_populate_print_last();
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
