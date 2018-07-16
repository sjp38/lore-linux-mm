Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB6F46B026A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:45:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10-v6so5288251itc.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:45:16 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q77-v6si23112244iod.253.2018.07.16.10.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:45:15 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v6 5/5] mm/sparse: delete old sparse_init and enable new one
Date: Mon, 16 Jul 2018 13:44:47 -0400
Message-Id: <20180716174447.14529-6-pasha.tatashin@oracle.com>
In-Reply-To: <20180716174447.14529-1-pasha.tatashin@oracle.com>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

Rename new_sparse_init() to sparse_init() which enables it.  Delete old
sparse_init() and all the code that became obsolete with.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Tested-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
---
 include/linux/mm.h  |   6 --
 mm/Kconfig          |   4 -
 mm/sparse-vmemmap.c |  21 ----
 mm/sparse.c         | 237 +-------------------------------------------
 4 files changed, 1 insertion(+), 267 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 99d8c50adef6..726e71475144 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2649,12 +2649,6 @@ extern int randomize_va_space;
 const char * arch_vma_name(struct vm_area_struct *vma);
 void print_vma_addr(char *prefix, unsigned long rip);
 
-void sparse_mem_maps_populate_node(struct page **map_map,
-				   unsigned long pnum_begin,
-				   unsigned long pnum_end,
-				   unsigned long map_count,
-				   int nodeid);
-
 void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap);
diff --git a/mm/Kconfig b/mm/Kconfig
index 28fcf54946ea..b78e7cd4e9fe 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -115,10 +115,6 @@ config SPARSEMEM_EXTREME
 config SPARSEMEM_VMEMMAP_ENABLE
 	bool
 
-config SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	def_bool y
-	depends on SPARSEMEM && X86_64
-
 config SPARSEMEM_VMEMMAP
 	bool "Sparse Memory virtual memmap"
 	depends on SPARSEMEM && SPARSEMEM_VMEMMAP_ENABLE
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index cd15f3d252c3..8301293331a2 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -261,24 +261,3 @@ struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid,
 
 	return map;
 }
-
-void __init sparse_mem_maps_populate_node(struct page **map_map,
-					  unsigned long pnum_begin,
-					  unsigned long pnum_end,
-					  unsigned long map_count, int nodeid)
-{
-	unsigned long pnum;
-	int nr_consumed_maps = 0;
-
-	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		if (!present_section_nr(pnum))
-			continue;
-
-		map_map[nr_consumed_maps] =
-				sparse_mem_map_populate(pnum, nodeid, NULL);
-		if (map_map[nr_consumed_maps++])
-			continue;
-		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
-		       __func__);
-	}
-}
diff --git a/mm/sparse.c b/mm/sparse.c
index 248d5d7bbf55..10b07eea9a6e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -205,12 +205,6 @@ static inline unsigned long first_present_section_nr(void)
 	return next_present_section_nr(-1);
 }
 
-/*
- * Record how many memory sections are marked as present
- * during system bootup.
- */
-static int __initdata nr_present_sections;
-
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
@@ -240,7 +234,6 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 			ms->section_mem_map = sparse_encode_early_nid(nid) |
 							SECTION_IS_ONLINE;
 			section_mark_present(ms);
-			nr_present_sections++;
 		}
 	}
 }
@@ -377,37 +370,8 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-static void __init sparse_early_usemaps_alloc_node(void *data,
-				 unsigned long pnum_begin,
-				 unsigned long pnum_end,
-				 unsigned long usemap_count, int nodeid)
-{
-	void *usemap;
-	unsigned long pnum;
-	unsigned long **usemap_map = (unsigned long **)data;
-	int size = usemap_size();
-	int nr_consumed_maps = 0;
-
-	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
-							  size * usemap_count);
-	if (!usemap) {
-		pr_warn("%s: allocation failed\n", __func__);
-		return;
-	}
-
-	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		if (!present_section_nr(pnum))
-			continue;
-		usemap_map[nr_consumed_maps] = usemap;
-		usemap += size;
-		check_usemap_section_nr(nodeid, usemap_map[nr_consumed_maps]);
-		nr_consumed_maps++;
-	}
-}
-
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static unsigned long __init section_map_size(void)
-
 {
 	return ALIGN(sizeof(struct page) * PAGES_PER_SECTION, PMD_SIZE);
 }
@@ -432,25 +396,6 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 					  BOOTMEM_ALLOC_ACCESSIBLE, nid);
 	return map;
 }
-void __init sparse_mem_maps_populate_node(struct page **map_map,
-					  unsigned long pnum_begin,
-					  unsigned long pnum_end,
-					  unsigned long map_count, int nodeid)
-{
-	unsigned long pnum;
-	int nr_consumed_maps = 0;
-
-	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		if (!present_section_nr(pnum))
-			continue;
-		map_map[nr_consumed_maps] =
-				sparse_mem_map_populate(pnum, nodeid, NULL);
-		if (map_map[nr_consumed_maps++])
-			continue;
-		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
-		       __func__);
-	}
-}
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 static void *sparsemap_buf __meminitdata;
@@ -489,190 +434,10 @@ void * __meminit sparse_buffer_alloc(unsigned long size)
 	return ptr;
 }
 
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-static void __init sparse_early_mem_maps_alloc_node(void *data,
-				 unsigned long pnum_begin,
-				 unsigned long pnum_end,
-				 unsigned long map_count, int nodeid)
-{
-	struct page **map_map = (struct page **)data;
-
-	sparse_buffer_init(section_map_size() * map_count, nodeid);
-	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
-					 map_count, nodeid);
-	sparse_buffer_fini();
-}
-#else
-static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
-{
-	struct page *map;
-	struct mem_section *ms = __nr_to_section(pnum);
-	int nid = sparse_early_nid(ms);
-
-	map = sparse_mem_map_populate(pnum, nid, NULL);
-	if (map)
-		return map;
-
-	pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
-	       __func__);
-	return NULL;
-}
-#endif
-
 void __weak __meminit vmemmap_populate_print_last(void)
 {
 }
 
-/**
- *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
- *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
- *  @unit_size: size of map unit
- */
-static void __init alloc_usemap_and_memmap(void (*alloc_func)
-					(void *, unsigned long, unsigned long,
-					unsigned long, int), void *data,
-					int data_unit_size)
-{
-	unsigned long pnum;
-	unsigned long map_count;
-	int nodeid_begin = 0;
-	unsigned long pnum_begin = 0;
-
-	for_each_present_section_nr(0, pnum) {
-		struct mem_section *ms;
-
-		ms = __nr_to_section(pnum);
-		nodeid_begin = sparse_early_nid(ms);
-		pnum_begin = pnum;
-		break;
-	}
-	map_count = 1;
-	for_each_present_section_nr(pnum_begin + 1, pnum) {
-		struct mem_section *ms;
-		int nodeid;
-
-		ms = __nr_to_section(pnum);
-		nodeid = sparse_early_nid(ms);
-		if (nodeid == nodeid_begin) {
-			map_count++;
-			continue;
-		}
-		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		alloc_func(data, pnum_begin, pnum,
-						map_count, nodeid_begin);
-		/* new start, update count etc*/
-		nodeid_begin = nodeid;
-		pnum_begin = pnum;
-		data += map_count * data_unit_size;
-		map_count = 1;
-	}
-	/* ok, last chunk */
-	alloc_func(data, pnum_begin, __highest_present_section_nr+1,
-						map_count, nodeid_begin);
-}
-
-/*
- * Allocate the accumulated non-linear sections, allocate a mem_map
- * for each and record the physical to section mapping.
- */
-void __init sparse_init(void)
-{
-	unsigned long pnum;
-	struct page *map;
-	unsigned long *usemap;
-	unsigned long **usemap_map;
-	int size;
-	int nr_consumed_maps = 0;
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	int size2;
-	struct page **map_map;
-#endif
-
-	/* see include/linux/mmzone.h 'struct mem_section' definition */
-	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
-
-	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
-	set_pageblock_order();
-
-	/*
-	 * map is using big page (aka 2M in x86 64 bit)
-	 * usemap is less one page (aka 24 bytes)
-	 * so alloc 2M (with 2M align) and 24 bytes in turn will
-	 * make next 2M slip to one more 2M later.
-	 * then in big system, the memory will have a lot of holes...
-	 * here try to allocate 2M pages continuously.
-	 *
-	 * powerpc need to call sparse_init_one_section right after each
-	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
-	 */
-	size = sizeof(unsigned long *) * nr_present_sections;
-	usemap_map = memblock_virt_alloc(size, 0);
-	if (!usemap_map)
-		panic("can not allocate usemap_map\n");
-	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-				(void *)usemap_map,
-				sizeof(usemap_map[0]));
-
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	size2 = sizeof(struct page *) * nr_present_sections;
-	map_map = memblock_virt_alloc(size2, 0);
-	if (!map_map)
-		panic("can not allocate map_map\n");
-	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
-				(void *)map_map,
-				sizeof(map_map[0]));
-#endif
-
-	/*
-	 * The number of present sections stored in nr_present_sections
-	 * are kept the same since mem sections are marked as present in
-	 * memory_present(). In this for loop, we need check which sections
-	 * failed to allocate memmap or usemap, then clear its
-	 * ->section_mem_map accordingly. During this process, we need
-	 * increase 'nr_consumed_maps' whether its allocation of memmap
-	 * or usemap failed or not, so that after we handle the i-th
-	 * memory section, can get memmap and usemap of (i+1)-th section
-	 * correctly.
-	 */
-	for_each_present_section_nr(0, pnum) {
-		struct mem_section *ms;
-
-		if (nr_consumed_maps >= nr_present_sections) {
-			pr_err("nr_consumed_maps goes beyond nr_present_sections\n");
-			break;
-		}
-		ms = __nr_to_section(pnum);
-		usemap = usemap_map[nr_consumed_maps];
-		if (!usemap) {
-			ms->section_mem_map = 0;
-			nr_consumed_maps++;
-			continue;
-		}
-
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-		map = map_map[nr_consumed_maps];
-#else
-		map = sparse_early_mem_map_alloc(pnum);
-#endif
-		if (!map) {
-			ms->section_mem_map = 0;
-			nr_consumed_maps++;
-			continue;
-		}
-
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
-								usemap);
-		nr_consumed_maps++;
-	}
-
-	vmemmap_populate_print_last();
-
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	memblock_free_early(__pa(map_map), size2);
-#endif
-	memblock_free_early(__pa(usemap_map), size);
-}
-
 /*
  * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
  * And number of present sections in this node is map_count.
@@ -726,7 +491,7 @@ static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
  * Allocate the accumulated non-linear sections, allocate a mem_map
  * for each and record the physical to section mapping.
  */
-void __init new_sparse_init(void)
+void __init sparse_init(void)
 {
 	unsigned long pnum_begin = first_present_section_nr();
 	int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
-- 
2.18.0
