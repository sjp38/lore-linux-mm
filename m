Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9891F6B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:19:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so75503047pfb.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:19:42 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e3si3312953pfg.187.2017.02.10.18.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 18:19:41 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 204so4317957pge.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:19:41 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init() to reduce some iteration cycle
Date: Sat, 11 Feb 2017 10:18:29 +0800
Message-Id: <20170211021829.9646-2-richard.weiyang@gmail.com>
In-Reply-To: <20170211021829.9646-1-richard.weiyang@gmail.com>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

During the sparse_init(), it iterate on each possible section. On x86_64,
it would always be (2^19) even there is not much memory. For example, on a
typical 4G machine, it has only (2^5) to (2^6) present sections. This
benefits more on a system with smaller memory.

This patch calculates the last section number from the highest pfn and use
this as the boundary of iteration.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 1e168bf2779a..d72f390d9e61 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -468,18 +468,20 @@ void __weak __meminit vmemmap_populate_print_last(void)
 
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
- *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
+ *  @data: usemap_map for pageblock flags or mmap_map for vmemmap
  */
 static void __init alloc_usemap_and_memmap(void (*alloc_func)
 					(void *, unsigned long, unsigned long,
-					unsigned long, int), void *data)
+					unsigned long, int),
+					void *data,
+					unsigned long last_section_nr)
 {
 	unsigned long pnum;
 	unsigned long map_count;
 	int nodeid_begin = 0;
 	unsigned long pnum_begin = 0;
 
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+	for (pnum = 0; pnum <= last_section_nr; pnum++) {
 		struct mem_section *ms;
 
 		if (!present_section_nr(pnum))
@@ -490,7 +492,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
 		break;
 	}
 	map_count = 1;
-	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
+	for (pnum = pnum_begin + 1; pnum <= last_section_nr; pnum++) {
 		struct mem_section *ms;
 		int nodeid;
 
@@ -503,16 +505,14 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
 			continue;
 		}
 		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		alloc_func(data, pnum_begin, pnum,
-						map_count, nodeid_begin);
+		alloc_func(data, pnum_begin, pnum, map_count, nodeid_begin);
 		/* new start, update count etc*/
 		nodeid_begin = nodeid;
 		pnum_begin = pnum;
 		map_count = 1;
 	}
 	/* ok, last chunk */
-	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
-						map_count, nodeid_begin);
+	alloc_func(data, pnum_begin, pnum, map_count, nodeid_begin);
 }
 
 /*
@@ -526,6 +526,9 @@ void __init sparse_init(void)
 	unsigned long *usemap;
 	unsigned long **usemap_map;
 	int size;
+	unsigned long last_section_nr;
+	int i;
+	unsigned long last_pfn = 0;
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	int size2;
 	struct page **map_map;
@@ -537,6 +540,11 @@ void __init sparse_init(void)
 	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
 	set_pageblock_order();
 
+	for_each_mem_pfn_range_rev(i, NUMA_NO_NODE, NULL,
+				&last_pfn, NULL)
+		break;
+	last_section_nr = pfn_to_section_nr(last_pfn);
+
 	/*
 	 * map is using big page (aka 2M in x86 64 bit)
 	 * usemap is less one page (aka 24 bytes)
@@ -553,7 +561,8 @@ void __init sparse_init(void)
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-							(void *)usemap_map);
+				(void *)usemap_map,
+				last_section_nr);
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
@@ -561,10 +570,11 @@ void __init sparse_init(void)
 	if (!map_map)
 		panic("can not allocate map_map\n");
 	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
-							(void *)map_map);
+				(void *)map_map,
+				last_section_nr);
 #endif
 
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+	for (pnum = 0; pnum <= last_section_nr; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
