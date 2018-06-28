Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4672A6B026B
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:29:22 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f8-v6so4476332qth.9
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:29:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l10-v6si758515qvk.121.2018.06.27.23.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:29:21 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v6 3/5] mm/sparse: Add a new parameter 'data_unit_size' for alloc_usemap_and_memmap
Date: Thu, 28 Jun 2018 14:28:55 +0800
Message-Id: <20180628062857.29658-4-bhe@redhat.com>
In-Reply-To: <20180628062857.29658-1-bhe@redhat.com>
References: <20180628062857.29658-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

alloc_usemap_and_memmap() is passing in a "void *" that points to
usemap_map or memmap_map. In next patch we will change both of the
map allocation from taking 'NR_MEM_SECTIONS' as the length to taking
'nr_present_sections' as the length. After that, the passed in 'void*'
needs to update as things get consumed. But, it knows only the
quantity of objects consumed and not the type.  This effectively
tells it enough about the type to let it update the pointer as
objects are consumed.

Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6a706093307d..4458a23e5293 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -486,10 +486,12 @@ void __weak __meminit vmemmap_populate_print_last(void)
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
  *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
+ *  @unit_size: size of map unit
  */
 static void __init alloc_usemap_and_memmap(void (*alloc_func)
 					(void *, unsigned long, unsigned long,
-					unsigned long, int), void *data)
+					unsigned long, int), void *data,
+					int data_unit_size)
 {
 	unsigned long pnum;
 	unsigned long map_count;
@@ -566,7 +568,8 @@ void __init sparse_init(void)
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-							(void *)usemap_map);
+				(void *)usemap_map,
+				sizeof(usemap_map[0]));
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
@@ -574,7 +577,8 @@ void __init sparse_init(void)
 	if (!map_map)
 		panic("can not allocate map_map\n");
 	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
-							(void *)map_map);
+				(void *)map_map,
+				sizeof(map_map[0]));
 #endif
 
 	for_each_present_section_nr(0, pnum) {
-- 
2.13.6
