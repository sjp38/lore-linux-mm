Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2H0SDVf023523
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:13 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2H0SDwE227286
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2H0SDPr012284
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:13 -0500
Subject: [RFC][PATCH 2/6] sparsemem: hotplug support
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 16 Mar 2005 16:28:11 -0800
Message-Id: <E1DBis0-0000Sx-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Make sparse's initalization be accessible at runtime.  This
allows sparse mappings to be created after boot in a hotplug
situation.

This patch is separated from the previous one just to give an
indication how much of the sparse infrastructure is *just* for
hotplug memory.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/include/linux/mmzone.h |    2 
 memhotplug-dave/mm/sparse.c            |   72 ++++++++++++++++++++++++---------
 2 files changed, 56 insertions(+), 18 deletions(-)

diff -puN mm/sparse.c~B-sparse-152-sparse-hotplug mm/sparse.c
--- memhotplug/mm/sparse.c~B-sparse-152-sparse-hotplug	2005-03-16 15:46:39.000000000 -0800
+++ memhotplug-dave/mm/sparse.c	2005-03-16 15:46:39.000000000 -0800
@@ -52,6 +52,40 @@ unsigned long __init node_memmap_size_by
 	return nr_pages * sizeof(struct page);
 }
 
+static int sparse_init_one_section(struct mem_section *ms, int pnum, struct page *mem_map)
+{
+	if (ms->section_mem_map &&
+	    (ms->section_mem_map != SECTION_MARKED_PRESENT))
+		return -EEXIST;
+	/*
+	 * Subtle, we encode the real pfn into the mem_map such that
+	 * the identity pfn - section_mem_map will return the actual
+	 * physical page frame number.
+	 */
+	ms->section_mem_map = mem_map - (pnum << PFN_SECTION_SHIFT);
+
+	return 1;
+}
+
+static struct page *sparse_early_mem_map_alloc(int pnum)
+{
+	struct page *map;
+	int nid = early_pfn_to_nid(pnum << PFN_SECTION_SHIFT);
+
+	map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
+	if (map)
+		return map;
+
+	map = alloc_bootmem_node(NODE_DATA(nid),
+			sizeof(struct page) * PAGES_PER_SECTION);
+	if (map)
+		return map;
+
+	printk(KERN_WARNING "%s: allocation failed\n", __FUNCTION__);
+	mem_section[pnum].section_mem_map = 0;
+	return NULL;
+}
+
 /*
  * Allocate the accumulated non-linear sections, allocate a mem_map
  * for each and record the physical to section mapping.
@@ -60,28 +94,30 @@ void sparse_init(void)
 {
 	int pnum;
 	struct page *map;
-	int nid;
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		if (!mem_section[pnum].section_mem_map)
 			continue;
 
-		nid = early_pfn_to_nid(pnum << PFN_SECTION_SHIFT);
-		map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
-		if (!map)
-			map = alloc_bootmem_node(NODE_DATA(nid),
-				sizeof(struct page) * PAGES_PER_SECTION);
-		if (!map) {
-			mem_section[pnum].section_mem_map = 0;
-			continue;
-		}
-
-		/*
-		 * Subtle, we encode the real pfn into the mem_map such that
-		 * the identity pfn - section_mem_map will return the actual
-		 * physical page frame number.
-		 */
-		mem_section[pnum].section_mem_map = map -
-			(pnum << PFN_SECTION_SHIFT);
+		map = sparse_early_mem_map_alloc(pnum);
+		if (map)
+			sparse_init_one_section(&mem_section[pnum], pnum, map);
 	}
 }
+
+/*
+ * returns the number of sections whose mem_maps were properly
+ * set.  If this is <=0, then that means that the passed-in
+ * map was not consumed and must be freed.
+ */
+int sparse_add_one_section(int start_pfn, int nr_pages, struct page *map)
+{
+	struct mem_section *ms = __pfn_to_section(start_pfn);
+
+	if (ms->section_mem_map & SECTION_MARKED_PRESENT)
+		return -EEXIST;
+
+	ms->section_mem_map |= SECTION_MARKED_PRESENT;
+
+	return sparse_init_one_section(ms, start_pfn >> PFN_SECTION_SHIFT, map);
+}
diff -puN include/linux/mmzone.h~B-sparse-152-sparse-hotplug include/linux/mmzone.h
--- memhotplug/include/linux/mmzone.h~B-sparse-152-sparse-hotplug	2005-03-16 15:46:39.000000000 -0800
+++ memhotplug-dave/include/linux/mmzone.h	2005-03-16 15:46:39.000000000 -0800
@@ -445,6 +445,8 @@ struct mem_section {
 
 extern struct mem_section mem_section[NR_MEM_SECTIONS];
 
+#define	SECTION_MARKED_PRESENT	((void *)-1)
+
 /*
  * Given a kernel address, find the home node of the underlying memory.
  */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
