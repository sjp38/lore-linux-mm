Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 79D776B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 23:30:22 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1809563pdj.26
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 20:30:22 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so1804426pbc.39
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 20:30:19 -0700 (PDT)
Message-ID: <524CE4C1.8060508@gmail.com>
Date: Thu, 03 Oct 2013 11:30:09 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm/sparsemem: Use PAGES_PER_SECTION to remove redundant
 nr_pages parameter
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

For below functions,
- sparse_add_one_section()
- kmalloc_section_memmap()
- __kmalloc_section_memmap()
- __kfree_section_memmap()
they are always invoked to operate on one memory section, so it is
redundant to always pass a nr_pages parameter, which is the page
numbers in one section. So we can directly use predefined marco
PAGES_PER_SECTION instead of passing the parameter.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memory_hotplug.h |    3 +--
 mm/memory_hotplug.c            |    3 +--
 mm/sparse.c                    |   33 +++++++++++++++------------------
 3 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index dd38e62..57ac2a9 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -262,8 +262,7 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
-								int nr_pages);
+extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ed85fe3..d457bf8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -402,13 +402,12 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 static int __meminit __add_section(int nid, struct zone *zone,
 					unsigned long phys_start_pfn)
 {
-	int nr_pages = PAGES_PER_SECTION;
 	int ret;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(zone, phys_start_pfn, nr_pages);
+	ret = sparse_add_one_section(zone, phys_start_pfn);
 
 	if (ret < 0)
 		return ret;
diff --git a/mm/sparse.c b/mm/sparse.c
index 4ac1d7e..fbb9dbc 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -590,16 +590,15 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
-						 unsigned long nr_pages)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
 {
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid);
 }
-static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
+static void __kfree_section_memmap(struct page *memmap)
 {
 	unsigned long start = (unsigned long)memmap;
-	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
 	vmemmap_free(start, end);
 }
@@ -613,10 +612,10 @@ static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
+static struct page *__kmalloc_section_memmap(void)
 {
 	struct page *page, *ret;
-	unsigned long memmap_size = sizeof(struct page) * nr_pages;
+	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
 
 	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
 	if (page)
@@ -634,19 +633,18 @@ got_map_ptr:
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
-						  unsigned long nr_pages)
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
 {
-	return __kmalloc_section_memmap(nr_pages);
+	return __kmalloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
+static void __kfree_section_memmap(struct page *memmap)
 {
 	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
 	else
 		free_pages((unsigned long)memmap,
-			   get_order(sizeof(struct page) * nr_pages));
+			   get_order(sizeof(struct page) * PAGES_PER_SECTION));
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -684,8 +682,7 @@ static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
-			   int nr_pages)
+int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct pglist_data *pgdat = zone->zone_pgdat;
@@ -702,12 +699,12 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, nr_pages);
+	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap, nr_pages);
+		__kfree_section_memmap(memmap);
 		return -ENOMEM;
 	}
 
@@ -719,7 +716,7 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 		goto out;
 	}
 
-	memset(memmap, 0, sizeof(struct page) * nr_pages);
+	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
 
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
@@ -729,7 +726,7 @@ out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, nr_pages);
+		__kfree_section_memmap(memmap);
 	}
 	return ret;
 }
@@ -771,7 +768,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
+			__kfree_section_memmap(memmap);
 		return;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
