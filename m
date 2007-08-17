Date: Fri, 17 Aug 2007 16:08:35 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch](memory hotplug) Hot-add with sparsemem-vmemmap
Message-Id: <20070817155908.7D91.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello.

This patch is to avoid panic when memory hot-add is executed with
sparsemem-vmemmap. Current vmemmap-sparsemem code doesn't support
memory hot-add. Vmemmap must be populated when hot-add.
This is for 2.6.23-rc2-mm2.

Todo: # Even if this patch is applied, the message "[xxxx-xxxx] potential
        offnode page_structs" is displayed. To allocate memmap on its node,
        memmap (and pgdat) must be initialized itself like chicken and
        egg relationship.

      # vmemmap_unpopulate will be necessary for followings.
         - For cancel hot-add due to error.
         - For unplug.

Please comment.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 include/linux/mm.h  |    2 +-
 mm/sparse-vmemmap.c |    2 +-
 mm/sparse.c         |   24 +++++++++++++++++++++---
 3 files changed, 23 insertions(+), 5 deletions(-)

Index: vmemmap/mm/sparse-vmemmap.c
===================================================================
--- vmemmap.orig/mm/sparse-vmemmap.c	2007-08-10 20:17:19.000000000 +0900
+++ vmemmap/mm/sparse-vmemmap.c	2007-08-10 21:12:54.000000000 +0900
@@ -170,7 +170,7 @@ int __meminit vmemmap_populate(struct pa
 }
 #endif /* !CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
 
-struct page __init *sparse_early_mem_map_populate(unsigned long pnum, int nid)
+struct page *sparse_mem_map_populate(unsigned long pnum, int nid)
 {
 	struct page *map = pfn_to_page(pnum * PAGES_PER_SECTION);
 	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
Index: vmemmap/include/linux/mm.h
===================================================================
--- vmemmap.orig/include/linux/mm.h	2007-08-10 20:17:19.000000000 +0900
+++ vmemmap/include/linux/mm.h	2007-08-10 21:06:34.000000000 +0900
@@ -1146,7 +1146,7 @@ extern int randomize_va_space;
 
 const char * arch_vma_name(struct vm_area_struct *vma);
 
-struct page *sparse_early_mem_map_populate(unsigned long pnum, int nid);
+struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 int vmemmap_populate_pmd(pud_t *, unsigned long, unsigned long, int);
 void *vmemmap_alloc_block(unsigned long size, int node);
Index: vmemmap/mm/sparse.c
===================================================================
--- vmemmap.orig/mm/sparse.c	2007-08-10 20:17:19.000000000 +0900
+++ vmemmap/mm/sparse.c	2007-08-10 21:21:01.000000000 +0900
@@ -259,7 +259,7 @@ static unsigned long *sparse_early_usema
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
-struct page __init *sparse_early_mem_map_populate(unsigned long pnum, int nid)
+struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
 {
 	struct page *map;
 
@@ -284,7 +284,7 @@ struct page __init *sparse_early_mem_map
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
-	map = sparse_early_mem_map_populate(pnum, nid);
+	map = sparse_mem_map_populate(pnum, nid);
 	if (map)
 		return map;
 
@@ -322,6 +322,17 @@ void __init sparse_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+						 unsigned long nr_pages)
+{
+	return sparse_mem_map_populate(pnum, nid);
+}
+static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
+{
+	return; /* XXX: Not implemented yet */
+}
+#else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
 	struct page *page, *ret;
@@ -344,6 +355,12 @@ got_map_ptr:
 	return ret;
 }
 
+static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+						  unsigned long nr_pages)
+{
+	return __kmalloc_section_memmap(nr_pages);
+}
+
 static int vaddr_in_vmalloc_area(void *addr)
 {
 	if (addr >= (void *)VMALLOC_START &&
@@ -360,6 +377,7 @@ static void __kfree_section_memmap(struc
 		free_pages((unsigned long)memmap,
 			   get_order(sizeof(struct page) * nr_pages));
 }
+#endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 /*
  * returns the number of sections whose mem_maps were properly
@@ -382,7 +400,7 @@ int sparse_add_one_section(struct zone *
 	 * plus, it does a kmalloc
 	 */
 	sparse_index_init(section_nr, pgdat->node_id);
-	memmap = __kmalloc_section_memmap(nr_pages);
+	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, nr_pages);
 	usemap = __kmalloc_section_usemap();
 
 	pgdat_resize_lock(pgdat, &flags);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
