Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C95486B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:45:08 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l8-v6so14039436ita.4
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:45:08 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f44-v6si12602134jak.86.2018.07.16.10.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:45:07 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v6 1/5] mm/sparse: abstract sparse buffer allocations
Date: Mon, 16 Jul 2018 13:44:43 -0400
Message-Id: <20180716174447.14529-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180716174447.14529-1-pasha.tatashin@oracle.com>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

When struct pages are allocated for sparse-vmemmap VA layout, we first try
to allocate one large buffer, and than if that fails allocate struct pages
for each section as we go.

The code that allocates buffer is uses global variables and is spread
across several call sites.

Cleanup the code by introducing three functions to handle the global
buffer:

sparse_buffer_init()	initialize the buffer
sparse_buffer_fini()	free the remaining part of the buffer
sparse_buffer_alloc()	alloc from the buffer, and if buffer is empty
return NULL

Define these functions in sparse.c instead of sparse-vmemmap.c because
later we will use them for non-vmemmap sparse allocations as well.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 include/linux/mm.h  |  4 ++++
 mm/sparse-vmemmap.c | 40 ++++++----------------------------------
 mm/sparse.c         | 45 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 54 insertions(+), 35 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 577e578eb640..a83d3e0e66d4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2655,6 +2655,10 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
+unsigned long __init section_map_size(void);
+void sparse_buffer_init(unsigned long size, int nid);
+void sparse_buffer_fini(void);
+void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 95e2c7638a5c..b05c7663c640 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -43,12 +43,9 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long goal)
 {
 	return memblock_virt_alloc_try_nid_raw(size, align, goal,
-					    BOOTMEM_ALLOC_ACCESSIBLE, node);
+					       BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
-static void *vmemmap_buf;
-static void *vmemmap_buf_end;
-
 void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 {
 	/* If the main allocator is up use that, fallback to bootmem. */
@@ -76,18 +73,10 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 /* need to make sure size is all the same during early stage */
 void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 {
-	void *ptr;
-
-	if (!vmemmap_buf)
-		return vmemmap_alloc_block(size, node);
-
-	/* take the from buf */
-	ptr = (void *)ALIGN((unsigned long)vmemmap_buf, size);
-	if (ptr + size > vmemmap_buf_end)
-		return vmemmap_alloc_block(size, node);
-
-	vmemmap_buf = ptr + size;
+	void *ptr = sparse_buffer_alloc(size);
 
+	if (!ptr)
+		ptr = vmemmap_alloc_block(size, node);
 	return ptr;
 }
 
@@ -279,19 +268,9 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 					  unsigned long map_count, int nodeid)
 {
 	unsigned long pnum;
-	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
-	void *vmemmap_buf_start;
 	int nr_consumed_maps = 0;
 
-	size = ALIGN(size, PMD_SIZE);
-	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
-			 PMD_SIZE, __pa(MAX_DMA_ADDRESS));
-
-	if (vmemmap_buf_start) {
-		vmemmap_buf = vmemmap_buf_start;
-		vmemmap_buf_end = vmemmap_buf_start + size * map_count;
-	}
-
+	sparse_buffer_init(section_map_size() * map_count, nodeid);
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
@@ -303,12 +282,5 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 	}
-
-	if (vmemmap_buf_start) {
-		/* need to free left buf */
-		memblock_free_early(__pa(vmemmap_buf),
-				    vmemmap_buf_end - vmemmap_buf);
-		vmemmap_buf = NULL;
-		vmemmap_buf_end = NULL;
-	}
+	sparse_buffer_fini();
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 2ea8b3dbd0df..9a0a5f598469 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -400,7 +400,14 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 	}
 }
 
-#ifndef CONFIG_SPARSEMEM_VMEMMAP
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+unsigned long __init section_map_size(void)
+
+{
+	return ALIGN(sizeof(struct page) * PAGES_PER_SECTION, PMD_SIZE);
+}
+
+#else
 struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
@@ -457,6 +464,42 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
+static void *sparsemap_buf __meminitdata;
+static void *sparsemap_buf_end __meminitdata;
+
+void __init sparse_buffer_init(unsigned long size, int nid)
+{
+	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
+	sparsemap_buf =
+		memblock_virt_alloc_try_nid_raw(size, PAGE_SIZE,
+						__pa(MAX_DMA_ADDRESS),
+						BOOTMEM_ALLOC_ACCESSIBLE, nid);
+	sparsemap_buf_end = sparsemap_buf + size;
+}
+
+void __init sparse_buffer_fini(void)
+{
+	unsigned long size = sparsemap_buf_end - sparsemap_buf;
+
+	if (sparsemap_buf && size > 0)
+		memblock_free_early(__pa(sparsemap_buf), size);
+	sparsemap_buf = NULL;
+}
+
+void * __meminit sparse_buffer_alloc(unsigned long size)
+{
+	void *ptr = NULL;
+
+	if (sparsemap_buf) {
+		ptr = PTR_ALIGN(sparsemap_buf, size);
+		if (ptr + size > sparsemap_buf_end)
+			ptr = NULL;
+		else
+			sparsemap_buf = ptr + size;
+	}
+	return ptr;
+}
+
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 static void __init sparse_early_mem_maps_alloc_node(void *data,
 				 unsigned long pnum_begin,
-- 
2.18.0
