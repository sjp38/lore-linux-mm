Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F0EE66B000E
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:45:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k204-v6so641270ite.1
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:45:11 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x197-v6si5128498iod.49.2018.07.16.10.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:45:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v6 3/5] mm/sparse: move buffer init/fini to the common place
Date: Mon, 16 Jul 2018 13:44:45 -0400
Message-Id: <20180716174447.14529-4-pasha.tatashin@oracle.com>
In-Reply-To: <20180716174447.14529-1-pasha.tatashin@oracle.com>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

Now, that both variants of sparse memory use the same buffers to populate
memory map, we can move sparse_buffer_init()/sparse_buffer_fini() to the
common place.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 include/linux/mm.h  |  3 ---
 mm/sparse-vmemmap.c |  2 --
 mm/sparse.c         | 14 +++++++-------
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a83d3e0e66d4..99d8c50adef6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2655,9 +2655,6 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
-unsigned long __init section_map_size(void);
-void sparse_buffer_init(unsigned long size, int nid);
-void sparse_buffer_fini(void);
 void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index b05c7663c640..cd15f3d252c3 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -270,7 +270,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	unsigned long pnum;
 	int nr_consumed_maps = 0;
 
-	sparse_buffer_init(section_map_size() * map_count, nodeid);
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
@@ -282,5 +281,4 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 	}
-	sparse_buffer_fini();
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index db4867b62fff..20ca292d8f11 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -401,14 +401,14 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 }
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-unsigned long __init section_map_size(void)
+static unsigned long __init section_map_size(void)
 
 {
 	return ALIGN(sizeof(struct page) * PAGES_PER_SECTION, PMD_SIZE);
 }
 
 #else
-unsigned long __init section_map_size(void)
+static unsigned long __init section_map_size(void)
 {
 	return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
 }
@@ -433,10 +433,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 					  unsigned long map_count, int nodeid)
 {
 	unsigned long pnum;
-	unsigned long size = section_map_size();
 	int nr_consumed_maps = 0;
 
-	sparse_buffer_init(size * map_count, nodeid);
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
@@ -447,14 +445,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 	}
-	sparse_buffer_fini();
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 static void *sparsemap_buf __meminitdata;
 static void *sparsemap_buf_end __meminitdata;
 
-void __init sparse_buffer_init(unsigned long size, int nid)
+static void __init sparse_buffer_init(unsigned long size, int nid)
 {
 	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
 	sparsemap_buf =
@@ -464,7 +461,7 @@ void __init sparse_buffer_init(unsigned long size, int nid)
 	sparsemap_buf_end = sparsemap_buf + size;
 }
 
-void __init sparse_buffer_fini(void)
+static void __init sparse_buffer_fini(void)
 {
 	unsigned long size = sparsemap_buf_end - sparsemap_buf;
 
@@ -494,8 +491,11 @@ static void __init sparse_early_mem_maps_alloc_node(void *data,
 				 unsigned long map_count, int nodeid)
 {
 	struct page **map_map = (struct page **)data;
+
+	sparse_buffer_init(section_map_size() * map_count, nodeid);
 	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
 					 map_count, nodeid);
+	sparse_buffer_fini();
 }
 #else
 static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
-- 
2.18.0
