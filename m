Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF8C16B6DDB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:57:21 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h11so13458797pfj.13
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:57:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor20572187pga.35.2018.12.04.00.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 00:57:20 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v4 2/2] mm, sparse: pass nid instead of pgdat to sparse_add_one_section()
Date: Tue,  4 Dec 2018 16:56:57 +0800
Message-Id: <20181204085657.20472-2-richard.weiyang@gmail.com>
In-Reply-To: <20181204085657.20472-1-richard.weiyang@gmail.com>
References: <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181204085657.20472-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, david@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Since the information needed in sparse_add_one_section() is node id to
allocate proper memory, it is not necessary to pass its pgdat.

This patch changes the prototype of sparse_add_one_section() to pass
node id directly. This is intended to reduce misleading that
sparse_add_one_section() would touch pgdat.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>

---
* adjust parameter alignment
---
 include/linux/memory_hotplug.h | 4 ++--
 mm/memory_hotplug.c            | 2 +-
 mm/sparse.c                    | 8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 45a5affcab8a..b81cc29482d8 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -333,8 +333,8 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern int sparse_add_one_section(struct pglist_data *pgdat,
-		unsigned long start_pfn, struct vmem_altmap *altmap);
+extern int sparse_add_one_section(int nid, unsigned long start_pfn,
+				  struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f626e7e5f57b..5b3a3d7b4466 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -253,7 +253,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
+	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
 	if (ret < 0)
 		return ret;
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 5825f276485f..a4fdbcb21514 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -662,8 +662,8 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct pglist_data *pgdat,
-		unsigned long start_pfn, struct vmem_altmap *altmap)
+int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
+				     struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct mem_section *ms;
@@ -675,11 +675,11 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	 * no locking for this, because it does its own
 	 * plus, it does a kmalloc
 	 */
-	ret = sparse_index_init(section_nr, pgdat->node_id);
+	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
 	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
+	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
-- 
2.15.1
