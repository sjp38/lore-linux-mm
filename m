Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5E46B002C
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:27:22 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id y9so964430qti.3
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:27:22 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 36si842602qky.256.2018.02.27.19.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:27:21 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 3/4] mm/sparse: Add a new parameter 'data_unit_size' for alloc_usemap_and_memmap
Date: Wed, 28 Feb 2018 11:26:56 +0800
Message-Id: <20180228032657.32385-4-bhe@redhat.com>
In-Reply-To: <20180228032657.32385-1-bhe@redhat.com>
References: <20180228032657.32385-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

It's used to pass the size of map data unit into alloc_usemap_and_memmap,
and is preparation for next patch.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 5769a0a79dc1..e1aa2f44530d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -528,10 +528,12 @@ void __weak __meminit vmemmap_populate_print_last(void)
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
@@ -608,7 +610,8 @@ void __init sparse_init(void)
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-							(void *)usemap_map);
+				(void *)usemap_map,
+				sizeof(usemap_map[0]));
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
@@ -616,7 +619,8 @@ void __init sparse_init(void)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
