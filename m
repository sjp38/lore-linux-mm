From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 001/005](memory hotplug) register sectin/node id to free
Date: Thu, 03 Apr 2008 14:39:01 +0900
Message-ID: <20080403143744.D1F6.E1E9C6FF@jp.fujitsu.com>
References: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759776AbYDCFp3@vger.kernel.org>
In-Reply-To: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Yinghai Lu <yhlu.kernel@gmail.com>, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org



This is to register information which is node or section's id.
Kernel can distinguish which node/section uses the pages
allcated by bootmem. This is basis for hot-remove sections or nodes.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/memory_hotplug.h |   18 +++++++
 include/linux/mmzone.h         |    1 
 mm/bootmem.c                   |    1 
 mm/memory_hotplug.c            |   97 ++++++++++++++++++++++++++++++++++++++++-
 mm/sparse.c                    |    3 -
 5 files changed, 117 insertions(+), 3 deletions(-)

Index: current/mm/bootmem.c
===================================================================
--- current.orig/mm/bootmem.c	2008-03-28 20:04:34.000000000 +0900
+++ current/mm/bootmem.c	2008-04-01 20:02:01.000000000 +0900
@@ -458,6 +458,7 @@
 
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
+	register_page_bootmem_info_node(pgdat);
 	return free_all_bootmem_core(pgdat);
 }
 
Index: current/include/linux/memory_hotplug.h
===================================================================
--- current.orig/include/linux/memory_hotplug.h	2008-03-28 20:04:34.000000000 +0900
+++ current/include/linux/memory_hotplug.h	2008-03-28 20:04:37.000000000 +0900
@@ -11,6 +11,15 @@
 struct mem_section;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+
+/*
+ * Magic number for free bootmem.
+ * The normal smallest mapcount is -1. Here is smaller value than it.
+ */
+#define SECTION_INFO		0xfffffffe
+#define MIX_INFO		0xfffffffd
+#define NODE_INFO		0xfffffffc
+
 /*
  * pgdat resizing functions
  */
@@ -145,6 +154,9 @@
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
+extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
+extern void put_page_bootmem(struct page *page);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -172,6 +184,10 @@
 	return -ENOSYS;
 }
 
+static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
+{
+}
+
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -192,5 +208,7 @@
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
+					  unsigned long pnum);
 
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
Index: current/include/linux/mmzone.h
===================================================================
--- current.orig/include/linux/mmzone.h	2008-03-28 20:04:34.000000000 +0900
+++ current/include/linux/mmzone.h	2008-03-28 20:04:37.000000000 +0900
@@ -938,6 +938,7 @@
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
 }
 extern int __section_nr(struct mem_section* ms);
+extern unsigned long usemap_size(void);
 
 /*
  * We use the lower bits of the mem_map pointer to store
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2008-03-28 20:04:34.000000000 +0900
+++ current/mm/memory_hotplug.c	2008-04-01 18:03:02.000000000 +0900
@@ -59,8 +59,103 @@
 	return;
 }
 
-
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+static void get_page_bootmem(unsigned long info,  struct page *page, int magic)
+{
+	atomic_set(&page->_mapcount, magic);
+	SetPagePrivate(page);
+	set_page_private(page, info);
+	atomic_inc(&page->_count);
+}
+
+void put_page_bootmem(struct page *page)
+{
+	int magic;
+
+	magic = atomic_read(&page->_mapcount);
+	BUG_ON(magic >= -1);
+
+	if (atomic_dec_return(&page->_count) == 1) {
+		ClearPagePrivate(page);
+		set_page_private(page, 0);
+		reset_page_mapcount(page);
+		__free_pages_bootmem(page, 0);
+	}
+
+}
+
+void register_page_bootmem_info_section(unsigned long start_pfn)
+{
+	unsigned long *usemap, mapsize, section_nr, i;
+	struct mem_section *ms;
+	struct page *page, *memmap;
+
+	if (!pfn_valid(start_pfn))
+		return;
+
+	section_nr = pfn_to_section_nr(start_pfn);
+	ms = __nr_to_section(section_nr);
+
+	/* Get section's memmap address */
+	memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
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
+		get_page_bootmem(section_nr, page, SECTION_INFO);
+
+	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	page = virt_to_page(usemap);
+
+	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+
+	for (i = 0; i < mapsize; i++, page++)
+		get_page_bootmem(section_nr, page, MIX_INFO);
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
+		get_page_bootmem(node, page, NODE_INFO);
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
+				get_page_bootmem(node, page, NODE_INFO);
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
--- current.orig/mm/sparse.c	2008-03-28 20:04:34.000000000 +0900
+++ current/mm/sparse.c	2008-04-01 20:02:05.000000000 +0900
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
