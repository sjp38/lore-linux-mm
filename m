Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC7786B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:37:57 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id z26-v6so9172503uao.20
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:37:57 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b82-v6si1318471vkb.51.2018.07.12.13.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 13:37:56 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v5 2/5] mm/sparse: use the new sparse buffer functions in non-vmemmap
Date: Thu, 12 Jul 2018 16:37:27 -0400
Message-Id: <20180712203730.8703-3-pasha.tatashin@oracle.com>
In-Reply-To: <20180712203730.8703-1-pasha.tatashin@oracle.com>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

non-vmemmap sparse also allocated large contiguous chunk of memory, and if
fails falls back to smaller allocations. Use the same functions to allocate
buffer as the vmemmap-sparse

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse.c | 41 ++++++++++++++---------------------------
 1 file changed, 14 insertions(+), 27 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index ac57bae476f4..976854a3af8b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -408,13 +408,20 @@ unsigned long __init section_map_size(void)
 }
 
 #else
+unsigned long __init section_map_size(void)
+{
+	return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
+}
+
 struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
-	struct page *map;
-	unsigned long size;
+	unsigned long size = section_map_size();
+	struct page *map = sparse_buffer_alloc(size);
+
+	if (map)
+		return map;
 
-	size = PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
 	map = memblock_virt_alloc_try_nid(size,
 					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 					  BOOTMEM_ALLOC_ACCESSIBLE, nid);
@@ -425,42 +432,22 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 					  unsigned long pnum_end,
 					  unsigned long map_count, int nodeid)
 {
-	void *map;
 	unsigned long pnum;
-	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
-	int nr_consumed_maps;
-
-	size = PAGE_ALIGN(size);
-	map = memblock_virt_alloc_try_nid_raw(size * map_count,
-					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
-					      BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
-	if (map) {
-		nr_consumed_maps = 0;
-		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-			if (!present_section_nr(pnum))
-				continue;
-			map_map[nr_consumed_maps] = map;
-			map += size;
-			nr_consumed_maps++;
-		}
-		return;
-	}
+	unsigned long size = section_map_size();
+	int nr_consumed_maps = 0;
 
-	/* fallback */
-	nr_consumed_maps = 0;
+	sparse_buffer_init(size * map_count, nodeid);
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		struct mem_section *ms;
-
 		if (!present_section_nr(pnum))
 			continue;
 		map_map[nr_consumed_maps] =
 				sparse_mem_map_populate(pnum, nodeid, NULL);
 		if (map_map[nr_consumed_maps++])
 			continue;
-		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 	}
+	sparse_buffer_fini();
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
-- 
2.18.0
