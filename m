Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 510586B000A
	for <linux-mm@kvack.org>; Mon, 21 May 2018 06:16:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o97-v6so3849517qkh.14
        for <linux-mm@kvack.org>; Mon, 21 May 2018 03:16:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t2-v6si4752208qvk.130.2018.05.21.03.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 03:16:17 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size' for alloc_usemap_and_memmap
Date: Mon, 21 May 2018 18:15:54 +0800
Message-Id: <20180521101555.25610-4-bhe@redhat.com>
In-Reply-To: <20180521101555.25610-1-bhe@redhat.com>
References: <20180521101555.25610-1-bhe@redhat.com>
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
index 3d697292be08..4a58f8809542 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -491,10 +491,12 @@ void __weak __meminit vmemmap_populate_print_last(void)
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
@@ -571,7 +573,8 @@ void __init sparse_init(void)
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-							(void *)usemap_map);
+				(void *)usemap_map,
+				sizeof(usemap_map[0]));
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
@@ -579,7 +582,8 @@ void __init sparse_init(void)
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
