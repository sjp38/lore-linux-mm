Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 022B46B031B
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:53:32 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id o62-v6so6893198vko.1
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:53:31 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w84-v6si5069351vkw.27.2018.07.09.10.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 10:53:30 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v4 3/3] mm/sparse: refactor sparse vmemmap buffer allocations
Date: Mon,  9 Jul 2018 13:53:12 -0400
Message-Id: <20180709175312.11155-4-pasha.tatashin@oracle.com>
In-Reply-To: <20180709175312.11155-1-pasha.tatashin@oracle.com>
References: <20180709175312.11155-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com

When struct pages are allocated for sparse-vmemmap VA layout, we first
try to allocate one large buffer, and than if that fails allocate struct
pages for each section as we go.

The code that allocates buffer is uses global variables and is spread
across several call sites.

Cleanup the code by introducing three functions to handle the global
buffer:
vmemmap_buffer_init()	initialize the buffer
vmemmap_buffer_fini()	free the remaining part of the buffer
vmemmap_buffer_alloc()	alloc from the buffer, and if buffer is empty
return NULL

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse-vmemmap.c | 72 ++++++++++++++++++++++++++-------------------
 1 file changed, 41 insertions(+), 31 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 87ba7cf8c75b..4e7f51aebabf 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -46,8 +46,42 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 					    BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
-static void *vmemmap_buf;
-static void *vmemmap_buf_end;
+static void *vmemmap_buf __meminitdata;
+static void *vmemmap_buf_end __meminitdata;
+
+static void __init vmemmap_buffer_init(int nid, unsigned long map_count)
+{
+	unsigned long sec_size = sizeof(struct page) * PAGES_PER_SECTION;
+	unsigned long alloc_size = ALIGN(sec_size, PMD_SIZE) * map_count;
+
+	BUG_ON(vmemmap_buf);
+	vmemmap_buf = __earlyonly_bootmem_alloc(nid, alloc_size, 0,
+						__pa(MAX_DMA_ADDRESS));
+	vmemmap_buf_end = vmemmap_buf + alloc_size;
+}
+
+static void __init vmemmap_buffer_fini(void)
+{
+	unsigned long size = vmemmap_buf_end - vmemmap_buf;
+
+	if (vmemmap_buf && size > 0)
+		memblock_free_early(__pa(vmemmap_buf), size);
+	vmemmap_buf = NULL;
+}
+
+static void * __meminit vmemmap_buffer_alloc(unsigned long size)
+{
+	void *ptr = NULL;
+
+	if (vmemmap_buf) {
+		ptr = (void *)ALIGN((unsigned long)vmemmap_buf, size);
+		if (ptr + size > vmemmap_buf_end)
+			ptr = NULL;
+		else
+			vmemmap_buf = ptr + size;
+	}
+	return ptr;
+}
 
 void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 {
@@ -76,18 +110,10 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
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
+	void *ptr = vmemmap_buffer_alloc(size);
 
+	if (!ptr)
+		ptr = vmemmap_alloc_block(size, node);
 	return ptr;
 }
 
@@ -282,19 +308,9 @@ struct page * __init sparse_populate_node(unsigned long pnum_begin,
 					  unsigned long map_count,
 					  int nid)
 {
-	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
 	unsigned long pnum, map_index = 0;
-	void *vmemmap_buf_start;
-
-	size = ALIGN(size, PMD_SIZE) * map_count;
-	vmemmap_buf_start = __earlyonly_bootmem_alloc(nid, size,
-						      PMD_SIZE,
-						      __pa(MAX_DMA_ADDRESS));
-	if (vmemmap_buf_start) {
-		vmemmap_buf = vmemmap_buf_start;
-		vmemmap_buf_end = vmemmap_buf_start + size;
-	}
 
+	vmemmap_buffer_init(nid, map_count);
 	for (pnum = pnum_begin; map_index < map_count; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
@@ -303,14 +319,8 @@ struct page * __init sparse_populate_node(unsigned long pnum_begin,
 		map_index++;
 		BUG_ON(pnum >= pnum_end);
 	}
+	vmemmap_buffer_fini();
 
-	if (vmemmap_buf_start) {
-		/* need to free left buf */
-		memblock_free_early(__pa(vmemmap_buf),
-				    vmemmap_buf_end - vmemmap_buf);
-		vmemmap_buf = NULL;
-		vmemmap_buf_end = NULL;
-	}
 	return pfn_to_page(section_nr_to_pfn(pnum_begin));
 }
 
-- 
2.18.0
