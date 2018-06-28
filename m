Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B16C6B0270
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:29:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v14-v6so4491266qto.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:29:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l63-v6si5571904qkd.301.2018.06.27.23.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:29:32 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v6 5/5] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
Date: Thu, 28 Jun 2018 14:28:57 +0800
Message-Id: <20180628062857.29658-6-bhe@redhat.com>
In-Reply-To: <20180628062857.29658-1-bhe@redhat.com>
References: <20180628062857.29658-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

Pavel pointed out that the behaviour of allocating memmap together
for one node should be defaulted for all ARCH-es. It won't break
anything because it will drop to the fallback action to allocate
imemmap for each section at one time if failed on large chunk of
memory.

So remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER and clean up the
related codes.

Signed-off-by: Baoquan He <bhe@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/Kconfig  |  4 ----
 mm/sparse.c | 32 ++------------------------------
 2 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index ce95491abd6a..75a196bf83e6 100644
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
diff --git a/mm/sparse.c b/mm/sparse.c
index e1767d9fe4f3..d18e2697a781 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -458,7 +458,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 static void __init sparse_early_mem_maps_alloc_node(void *data,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
@@ -468,22 +467,6 @@ static void __init sparse_early_mem_maps_alloc_node(void *data,
 	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
 					 map_count, nodeid);
 }
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
 
 void __weak __meminit vmemmap_populate_print_last(void)
 {
@@ -545,14 +528,11 @@ void __init sparse_init(void)
 {
 	unsigned long pnum;
 	struct page *map;
+	struct page **map_map;
 	unsigned long *usemap;
 	unsigned long **usemap_map;
-	int size;
+	int size, size2;
 	int nr_consumed_maps = 0;
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	int size2;
-	struct page **map_map;
-#endif
 
 	/* see include/linux/mmzone.h 'struct mem_section' definition */
 	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
@@ -579,7 +559,6 @@ void __init sparse_init(void)
 				(void *)usemap_map,
 				sizeof(usemap_map[0]));
 
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * nr_present_sections;
 	map_map = memblock_virt_alloc(size2, 0);
 	if (!map_map)
@@ -587,7 +566,6 @@ void __init sparse_init(void)
 	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
 				(void *)map_map,
 				sizeof(map_map[0]));
-#endif
 
 	/* The numner of present sections stored in nr_present_sections
 	 * are kept the same since mem sections are marked as present in
@@ -613,11 +591,7 @@ void __init sparse_init(void)
 			continue;
 		}
 
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 		map = map_map[nr_consumed_maps];
-#else
-		map = sparse_early_mem_map_alloc(pnum);
-#endif
 		if (!map) {
 			ms->section_mem_map = 0;
 			nr_consumed_maps++;
@@ -631,9 +605,7 @@ void __init sparse_init(void)
 
 	vmemmap_populate_print_last();
 
-#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	memblock_free_early(__pa(map_map), size2);
-#endif
 	memblock_free_early(__pa(usemap_map), size);
 }
 
-- 
2.13.6
