Date: Fri, 14 Mar 2008 23:38:46 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH 1/3 (RFC)](memory hotplug) remember section_nr and node id for removing
In-Reply-To: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
References: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080314233638.20D9.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is to register information to be able to remove section's or node's
structures.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/memory_hotplug.h |   10 ++++
 include/linux/mmzone.h         |    1 
 mm/bootmem.c                   |    1 
 mm/memory_hotplug.c            |   97 ++++++++++++++++++++++++++++++++++++++++-
 mm/sparse.c                    |    3 -
 5 files changed, 109 insertions(+), 3 deletions(-)

Index: current/mm/bootmem.c
===================================================================
--- current.orig/mm/bootmem.c	2008-03-10 16:42:54.000000000 +0900
+++ current/mm/bootmem.c	2008-03-10 22:24:46.000000000 +0900
@@ -401,6 +401,7 @@
 
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
+	register_page_bootmem_info_node(pgdat);
 	return free_all_bootmem_core(pgdat);
 }
 
Index: current/include/linux/memory_hotplug.h
===================================================================
--- current.orig/include/linux/memory_hotplug.h	2008-03-10 16:42:54.000000000 +0900
+++ current/include/linux/memory_hotplug.h	2008-03-10 16:42:57.000000000 +0900
@@ -11,6 +11,11 @@
 struct mem_section;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+
+#define SECTION_MAGIC		0xfffffffe
+#define NODE_INFO_MAGIC		0xfffffffd
+#define SECTION_INFO		0
+#define NODE_INFO 		1
 /*
  * pgdat resizing functions
  */
@@ -145,6 +150,9 @@
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
+extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
+extern void clear_page_bootmem_info(struct page *page);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -192,5 +200,7 @@
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
+					  unsigned long pnum);
 
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
Index: current/include/linux/mmzone.h
===================================================================
--- current.orig/include/linux/mmzone.h	2008-03-10 16:42:54.000000000 +0900
+++ current/include/linux/mmzone.h	2008-03-10 16:42:57.000000000 +0900
@@ -938,6 +938,7 @@
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
 }
 extern int __section_nr(struct mem_section* ms);
+extern unsigned long usemap_size(void);
 
 /*
  * We use the lower bits of the mem_map pointer to store
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2008-03-10 16:42:54.000000000 +0900
+++ current/mm/memory_hotplug.c	2008-03-10 22:22:25.000000000 +0900
@@ -59,8 +59,103 @@
 	return;
 }
 
-
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+static void set_page_bootmem_info(unsigned long info,  struct page *page,
+				  unsigned long flag)
+{
+
+	if (flag == SECTION_INFO)
+		atomic_set(&page->_mapcount, SECTION_MAGIC);
+	else
+		atomic_set(&page->_mapcount, NODE_INFO_MAGIC);
+
+	SetPagePrivate(page);
+	set_page_private(page, info);
+
+}
+
+void clear_page_bootmem_info(struct page *page)
+{
+	int magic;
+
+	magic = atomic_read(&page->_mapcount);
+	if (magic != SECTION_MAGIC && magic != NODE_INFO_MAGIC)
+		BUG();
+
+	ClearPagePrivate(page);
+	set_page_private(page, 0);
+	reset_page_mapcount(page);
+}
+
+void register_page_bootmem_info_section(unsigned long start_pfn)
+{
+	unsigned long *usemap, mapsize, section_nr, i;
+	struct page *page, *memmap;
+
+	if (!pfn_valid(start_pfn))
+		return;
+
+	section_nr = pfn_to_section_nr(start_pfn);
+
+	memmap = pfn_to_page(start_pfn); /* memmap for the section */
+
+	/*
+	 * Get page for the memmap's phys address
+	 * XXX: need more consideration for sparse_vmemmap...
+	 */
+	page = virt_to_page(memmap);
+	mapsize = sizeof(struct page) * PAGES_PER_SECTION;
+	mapsize = PAGE_ALIGN(mapsize) >> PAGE_SHIFT;
+
+	/* remember memmap's page */
+	for (i = 0; i < mapsize; i++, page++)
+		set_page_bootmem_info(section_nr, page, SECTION_INFO);
+
+	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	page = virt_to_page(usemap);
+
+	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+
+	for (i = 0; i < mapsize; i++, page++)
+		set_page_bootmem_info(section_nr, page, SECTION_INFO);
+
+}
+
+void register_page_bootmem_info_node(struct pglist_data *pgdat)
+{
+	unsigned long i, pfn, end_pfn, nr_pages;
+	int node = pgdat->node_id;
+	struct page *page;
+	struct zone *zone;
+
+	nr_pages = PAGE_ALIGN(sizeof(struct pglist_data)) >> PAGE_SHIFT;
+	page = virt_to_page(pgdat);
+
+	for (i = 0; i < nr_pages; i++, page++)
+		set_page_bootmem_info(node, page, NODE_INFO);
+
+	zone = &pgdat->node_zones[0];
+	for (; zone < pgdat->node_zones + MAX_NR_ZONES - 1; zone++) {
+		if (zone->wait_table) {
+			nr_pages = zone->wait_table_hash_nr_entries
+				* sizeof(wait_queue_head_t);
+			nr_pages = PAGE_ALIGN(nr_pages) >> PAGE_SHIFT;
+			page = virt_to_page(zone->wait_table);
+
+			for (i = 0; i < nr_pages; i++, page++)
+				set_page_bootmem_info(node, page, NODE_INFO);
+		}
+	}
+
+	pfn = pgdat->node_start_pfn;
+	end_pfn = pfn + pgdat->node_spanned_pages;
+
+	/* register_section info */
+	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
+		register_page_bootmem_info_section(pfn);
+
+}
+
 static int __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-03-10 16:42:54.000000000 +0900
+++ current/mm/sparse.c	2008-03-10 22:24:46.000000000 +0900
@@ -200,7 +200,6 @@
 /*
  * Decode mem_map from the coded memmap
  */
-static
 struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pnum)
 {
 	/* mask off the extra low bits of information */
@@ -223,7 +222,7 @@
 	return 1;
 }
 
-static unsigned long usemap_size(void)
+unsigned long usemap_size(void)
 {
 	unsigned long size_bytes;
 	size_bytes = roundup(SECTION_BLOCKFLAGS_BITS, 8) / 8;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
