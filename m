Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id B408A6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 02:55:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 20 Aug 2013 12:18:48 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id F3D2CE0057
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:25:39 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7K6uggi39059582
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:26:43 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7K6t9MS009773
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:25:10 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Date: Tue, 20 Aug 2013 14:54:54 +0800
Message-Id: <1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
 * add comments to describe alloc_usemap_and_memmap 

After commit 9bdac91424075("sparsemem: Put mem map for one node together."),
vmemmap for one node will be allocated together, its logic is similar as
memory allocation for pageblock flags. This patch introduce alloc_usemap_and_memmap
to extract the same logic of memory alloction for pageblock flags and vmemmap.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/sparse.c | 140 ++++++++++++++++++++++++++++--------------------------------
 1 file changed, 66 insertions(+), 74 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 308d503..d27db9b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -439,6 +439,14 @@ static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
 					 map_count, nodeid);
 }
 #else
+
+static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
+				unsigned long pnum_begin,
+				unsigned long pnum_end,
+				unsigned long map_count, int nodeid)
+{
+}
+
 static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -460,6 +468,62 @@ void __attribute__((weak)) __meminit vmemmap_populate_print_last(void)
 {
 }
 
+/**
+ *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
+ *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
+ *  @use_map: true if memory allocated for pageblock flags, otherwise false
+ */
+static void alloc_usemap_and_memmap(unsigned long **map, bool use_map)
+{
+	unsigned long pnum;
+	unsigned long map_count;
+	int nodeid_begin = 0;
+	unsigned long pnum_begin = 0;
+
+	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+		struct mem_section *ms;
+
+		if (!present_section_nr(pnum))
+			continue;
+		ms = __nr_to_section(pnum);
+		nodeid_begin = sparse_early_nid(ms);
+		pnum_begin = pnum;
+		break;
+	}
+	map_count = 1;
+	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
+		struct mem_section *ms;
+		int nodeid;
+
+		if (!present_section_nr(pnum))
+			continue;
+		ms = __nr_to_section(pnum);
+		nodeid = sparse_early_nid(ms);
+		if (nodeid == nodeid_begin) {
+			map_count++;
+			continue;
+		}
+		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
+		if (use_map)
+			sparse_early_usemaps_alloc_node(map, pnum_begin, pnum,
+						 map_count, nodeid_begin);
+		else
+			sparse_early_mem_maps_alloc_node((struct page **)map,
+				pnum_begin, pnum, map_count, nodeid_begin);
+		/* new start, update count etc*/
+		nodeid_begin = nodeid;
+		pnum_begin = pnum;
+		map_count = 1;
+	}
+	/* ok, last chunk */
+	if (use_map)
+		sparse_early_usemaps_alloc_node(map, pnum_begin,
+				NR_MEM_SECTIONS, map_count, nodeid_begin);
+	else
+		sparse_early_mem_maps_alloc_node((struct page **)map,
+			pnum_begin, NR_MEM_SECTIONS, map_count, nodeid_begin);
+}
+
 /*
  * Allocate the accumulated non-linear sections, allocate a mem_map
  * for each and record the physical to section mapping.
@@ -471,11 +535,7 @@ void __init sparse_init(void)
 	unsigned long *usemap;
 	unsigned long **usemap_map;
 	int size;
-	int nodeid_begin = 0;
-	unsigned long pnum_begin = 0;
-	unsigned long usemap_count;
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	unsigned long map_count;
 	int size2;
 	struct page **map_map;
 #endif
@@ -501,82 +561,14 @@ void __init sparse_init(void)
 	usemap_map = alloc_bootmem(size);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
-
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-		struct mem_section *ms;
-
-		if (!present_section_nr(pnum))
-			continue;
-		ms = __nr_to_section(pnum);
-		nodeid_begin = sparse_early_nid(ms);
-		pnum_begin = pnum;
-		break;
-	}
-	usemap_count = 1;
-	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
-		struct mem_section *ms;
-		int nodeid;
-
-		if (!present_section_nr(pnum))
-			continue;
-		ms = __nr_to_section(pnum);
-		nodeid = sparse_early_nid(ms);
-		if (nodeid == nodeid_begin) {
-			usemap_count++;
-			continue;
-		}
-		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, pnum,
-						 usemap_count, nodeid_begin);
-		/* new start, update count etc*/
-		nodeid_begin = nodeid;
-		pnum_begin = pnum;
-		usemap_count = 1;
-	}
-	/* ok, last chunk */
-	sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
-					 usemap_count, nodeid_begin);
+	alloc_usemap_and_memmap(usemap_map, true);
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
 	map_map = alloc_bootmem(size2);
 	if (!map_map)
 		panic("can not allocate map_map\n");
-
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-		struct mem_section *ms;
-
-		if (!present_section_nr(pnum))
-			continue;
-		ms = __nr_to_section(pnum);
-		nodeid_begin = sparse_early_nid(ms);
-		pnum_begin = pnum;
-		break;
-	}
-	map_count = 1;
-	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
-		struct mem_section *ms;
-		int nodeid;
-
-		if (!present_section_nr(pnum))
-			continue;
-		ms = __nr_to_section(pnum);
-		nodeid = sparse_early_nid(ms);
-		if (nodeid == nodeid_begin) {
-			map_count++;
-			continue;
-		}
-		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		sparse_early_mem_maps_alloc_node(map_map, pnum_begin, pnum,
-						 map_count, nodeid_begin);
-		/* new start, update count etc*/
-		nodeid_begin = nodeid;
-		pnum_begin = pnum;
-		map_count = 1;
-	}
-	/* ok, last chunk */
-	sparse_early_mem_maps_alloc_node(map_map, pnum_begin, NR_MEM_SECTIONS,
-					 map_count, nodeid_begin);
+	alloc_usemap_and_memmap((unsigned long **)map_map, false);
 #endif
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
