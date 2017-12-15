Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B82C96B0260
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:10:22 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j3so7913207pfh.16
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:10:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b29si4631866pgn.655.2017.12.15.06.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:10:21 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/17] mm: pass the vmem_altmap to vmemmap_populate
Date: Fri, 15 Dec 2017 15:09:35 +0100
Message-Id: <20171215140947.26075-6-hch@lst.de>
In-Reply-To: <20171215140947.26075-1-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We can just pass this on instead of having to do a radix tree lookup
without proper locking a few levels into the callchain.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/mmu.c            |  6 ++++--
 arch/ia64/mm/discontig.c       |  3 ++-
 arch/powerpc/mm/init_64.c      |  7 ++-----
 arch/s390/mm/vmem.c            |  3 ++-
 arch/sparc/mm/init_64.c        |  2 +-
 arch/x86/mm/init_64.c          |  4 ++--
 include/linux/memory_hotplug.h |  3 ++-
 include/linux/mm.h             |  6 ++++--
 mm/memory_hotplug.c            |  7 ++++---
 mm/sparse-vmemmap.c            |  7 ++++---
 mm/sparse.c                    | 20 ++++++++++++--------
 11 files changed, 39 insertions(+), 29 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 267d2b79d52d..ec8952ff13be 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -654,12 +654,14 @@ int kern_addr_valid(unsigned long addr)
 }
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	return vmemmap_populate_basepages(start, end, node);
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long addr = start;
 	unsigned long next;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 9b2d994cddf6..1555aecaaf85 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -754,7 +754,8 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	return vmemmap_populate_basepages(start, end, node);
 }
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a07722531b32..779b74a96b8f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -183,7 +183,8 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
 	vmemmap_list = vmem_back;
 }
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
 
@@ -193,16 +194,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	pr_debug("vmemmap_populate %lx..%lx, node %d\n", start, end, node);
 
 	for (; start < end; start += page_size) {
-		struct vmem_altmap *altmap;
 		void *p;
 		int rc;
 
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		/* altmap lookups only work at section boundaries */
-		altmap = to_vmem_altmap(SECTION_ALIGN_DOWN(start));
-
 		p =  __vmemmap_alloc_block_buf(page_size, node, altmap);
 		if (!p)
 			return -ENOMEM;
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 3316d463fc29..c44ef0e7c466 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -211,7 +211,8 @@ static void vmem_remove_range(unsigned long start, unsigned long size)
 /*
  * Add a backed mem_map array to the virtual mem_map array.
  */
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long pgt_prot, sgt_prot;
 	unsigned long address = start;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 55ba62957e64..42d27a1a042a 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2628,7 +2628,7 @@ EXPORT_SYMBOL(_PAGE_CACHE);
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
-			       int node)
+			       int node, struct vmem_altmap *altmap)
 {
 	unsigned long pte_base;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e26ade50ae18..0c898098feaf 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1411,9 +1411,9 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 	return 0;
 }
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(start);
 	int err;
 
 	if (boot_cpu_has(X86_FEATURE_PSE))
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index db276afbefcc..cbdd6d52e877 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -327,7 +327,8 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn);
+extern int sparse_add_one_section(struct pglist_data *pgdat,
+		unsigned long start_pfn, struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..2f3a7ebecbe2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2538,7 +2538,8 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
-struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
+struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
@@ -2556,7 +2557,8 @@ static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
-int vmemmap_populate(unsigned long start, unsigned long end, int node);
+int vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap);
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(unsigned long start, unsigned long end);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index fc0485dcece1..b36f1822c432 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		bool want_memblock)
+		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
 	int i;
@@ -258,7 +258,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn);
+	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
 	if (ret < 0)
 		return ret;
 
@@ -317,7 +317,8 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
+		err = __add_section(nid, section_nr_to_pfn(i), altmap,
+				want_memblock);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 17acf01791fa..376dcf05a39c 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -278,7 +278,8 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 	return 0;
 }
 
-struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start;
 	unsigned long end;
@@ -288,7 +289,7 @@ struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
 	start = (unsigned long)map;
 	end = (unsigned long)(map + PAGES_PER_SECTION);
 
-	if (vmemmap_populate(start, end, nid))
+	if (vmemmap_populate(start, end, nid, altmap))
 		return NULL;
 
 	return map;
@@ -318,7 +319,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (!present_section_nr(pnum))
 			continue;
 
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
+		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
diff --git a/mm/sparse.c b/mm/sparse.c
index 7a5dacaa06e3..5f4a0dac7836 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -417,7 +417,8 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
-struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
+struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	struct page *map;
 	unsigned long size;
@@ -472,7 +473,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 		if (!present_section_nr(pnum))
 			continue;
-		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
+		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
@@ -500,7 +501,7 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
-	map = sparse_mem_map_populate(pnum, nid);
+	map = sparse_mem_map_populate(pnum, nid, NULL);
 	if (map)
 		return map;
 
@@ -678,10 +679,11 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
-	return sparse_mem_map_populate(pnum, nid);
+	return sparse_mem_map_populate(pnum, nid, altmap);
 }
 static void __kfree_section_memmap(struct page *memmap)
 {
@@ -721,7 +723,8 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	return __kmalloc_section_memmap();
 }
@@ -773,7 +776,8 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn)
+int __meminit sparse_add_one_section(struct pglist_data *pgdat,
+		unsigned long start_pfn, struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct mem_section *ms;
@@ -789,7 +793,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
+	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
