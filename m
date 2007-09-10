From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112111.3097.85750.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/13] Fix corruption of memmap on ia64-sparsemem when mem_section is not a power of 2
Date: Mon, 10 Sep 2007 12:21:11 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Fix corruption of memmap on ia64-sparsemem when mem_section is not a power of 2
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There are problems in the use of SPARSEMEM and pageblock flags that causes
problems on ia64.

The first part of the problem is that units are incorrect in
SECTION_BLOCKFLAGS_BITS computation.  This results in a map_section's
section_mem_map being treated as part of a bitmap which isn't good.  This
was evident with an invalid virtual address when mem_init attempted to free
bootmem pages while relinquishing control from the bootmem allocator.

The second part of the problem occurs because the pageblock flags bitmap is
be located with the mem_section.  The SECTIONS_PER_ROOT computation using
sizeof (mem_section) may not be a power of 2 depending on the size of the
bitmap.  This renders masks and other such things not power of 2 base.
This issue was seen with SPARSEMEM_EXTREME on ia64.  This patch moves the
bitmap outside of mem_section and uses a pointer instead in the
mem_section.  The bitmaps are allocated when the section is being
initialised.

Note that sparse_early_usemap_alloc() does not use alloc_remap() like
sparse_early_mem_map_alloc().  The allocation required for the bitmap on
x86, the only architecture that uses alloc_remap is typically smaller than
a cache line.  alloc_remap() pads out allocations to the cache size which
would be a needless waste.

Credit to Bob Picco for identifying the original problem and effecting a
fix for the SECTION_BLOCKFLAGS_BITS calculation.  Credit to Andy Whitcroft
for devising the best way of allocating the bitmaps only when required for
the section.

From: Bob Picco <bob.picco@hp.com>
[wli@holomorphy.com: warning fix]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: William Irwin <bill.irwin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |    4 ++-
 mm/sparse.c            |   54 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 54 insertions(+), 4 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/mmzone.h linux-2.6.23-rc5-003-fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2/include/linux/mmzone.h
--- linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/mmzone.h	2007-09-02 16:19:05.000000000 +0100
+++ linux-2.6.23-rc5-003-fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2/include/linux/mmzone.h	2007-09-02 16:19:16.000000000 +0100
@@ -739,7 +739,9 @@ struct mem_section {
 	 * before using it wrong.
 	 */
 	unsigned long section_mem_map;
-	DECLARE_BITMAP(pageblock_flags, SECTION_BLOCKFLAGS_BITS);
+
+	/* See declaration of similar field in struct zone */
+	unsigned long *pageblock_flags;
 };
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/mm/sparse.c linux-2.6.23-rc5-003-fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2/mm/sparse.c
--- linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/mm/sparse.c	2007-09-02 16:18:56.000000000 +0100
+++ linux-2.6.23-rc5-003-fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2/mm/sparse.c	2007-09-02 16:19:16.000000000 +0100
@@ -204,14 +204,16 @@ struct page *sparse_decode_mem_map(unsig
 }
 
 static int __meminit sparse_init_one_section(struct mem_section *ms,
-		unsigned long pnum, struct page *mem_map)
+		unsigned long pnum, struct page *mem_map,
+		unsigned long *pageblock_bitmap)
 {
 	if (!present_section(ms))
 		return -EINVAL;
 
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
							SECTION_HAS_MEM_MAP;
+ 	ms->pageblock_flags = pageblock_bitmap;
 
 	return 1;
 }
@@ -221,6 +223,38 @@ void *alloc_bootmem_high_node(pg_data_t 
 	return NULL;
 }
 
+static unsigned long usemap_size(void)
+{
+	unsigned long size_bytes;
+	size_bytes = roundup(SECTION_BLOCKFLAGS_BITS, 8) / 8;
+	size_bytes = roundup(size_bytes, sizeof(unsigned long));
+	return size_bytes;
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static unsigned long *__kmalloc_section_usemap(void)
+{
+	return kmalloc(usemap_size(), GFP_KERNEL);
+}
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
+static unsigned long *sparse_early_usemap_alloc(unsigned long pnum)
+{
+	unsigned long *usemap;
+	struct mem_section *ms = __nr_to_section(pnum);
+	int nid = sparse_early_nid(ms);
+
+	usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
+	if (usemap)
+		return usemap;
+
+	/* Stupid: suppress gcc warning for SPARSEMEM && !NUMA */
+	nid = 0;
+
+	printk(KERN_WARNING "%s: allocation failed\n", __FUNCTION__);
+	return NULL;
+}
+
 struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -254,6 +288,7 @@ void __init sparse_init(void)
 {
 	unsigned long pnum;
 	struct page *map;
+	unsigned long *usemap;
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		if (!valid_section_nr(pnum))
@@ -262,7 +297,13 @@ void __init sparse_init(void)
 		map = sparse_early_mem_map_alloc(pnum);
 		if (!map)
 			continue;
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
+
+		usemap = sparse_early_usemap_alloc(pnum);
+		if (!usemap)
+			continue;
+
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
+								usemap);
 	}
 }
 
@@ -318,6 +359,7 @@ int sparse_add_one_section(struct zone *
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	struct mem_section *ms;
 	struct page *memmap;
+	unsigned long *usemap;
 	unsigned long flags;
 	int ret;
 
@@ -327,6 +369,7 @@ int sparse_add_one_section(struct zone *
 	 */
 	sparse_index_init(section_nr, pgdat->node_id);
 	memmap = __kmalloc_section_memmap(nr_pages);
+	usemap = __kmalloc_section_usemap();
 
 	pgdat_resize_lock(pgdat, &flags);
 
@@ -335,9 +378,14 @@ int sparse_add_one_section(struct zone *
 		ret = -EEXIST;
 		goto out;
 	}
+
+	if (!usemap) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap);
+	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
