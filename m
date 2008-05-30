Message-Id: <20080530194737.756122438@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:23 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 03/14] bootmem: add documentation to API functions
Content-Disposition: inline; filename=bootmem-document-api.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---

 mm/bootmem.c |  147 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 146 insertions(+), 1 deletion(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -47,7 +47,10 @@ static unsigned long __init get_mapsize(
 	return ALIGN(mapsize, sizeof(long));
 }
 
-/* return the number of _pages_ that will be allocated for the boot bitmap */
+/**
+ * bootmem_bootmap_pages - calculate bitmap size in pages
+ * @pages: number of pages the bitmap has to represent
+ */
 unsigned long __init bootmem_bootmap_pages(unsigned long pages)
 {
 	unsigned long mapsize;
@@ -104,12 +107,28 @@ static unsigned long __init init_bootmem
 	return mapsize;
 }
 
+/**
+ * init_bootmem_node - register a node as boot memory
+ * @pgdat: node to register
+ * @freepfn: pfn where the bitmap for this node is to be placed
+ * @startpfn: first pfn on the node
+ * @endpfn: first pfn after the node
+ *
+ * Returns the number of bytes needed to hold the bitmap for this node.
+ */
 unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
 				unsigned long startpfn, unsigned long endpfn)
 {
 	return init_bootmem_core(pgdat->bdata, freepfn, startpfn, endpfn);
 }
 
+/**
+ * init_bootmem - register boot memory
+ * @start: pfn where the bitmap is to be placed
+ * @pages: number of available physical pages
+ *
+ * Returns the number of bytes needed to hold the bitmap.
+ */
 unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 {
 	max_low_pfn = pages;
@@ -182,12 +201,23 @@ static unsigned long __init free_all_boo
 	return count;
 }
 
+/**
+ * free_all_bootmem_node - release a node's free pages to the buddy allocator
+ * @pgdat: node to be released
+ *
+ * Returns the number of pages actually released.
+ */
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
 	return free_all_bootmem_core(pgdat->bdata);
 }
 
+/**
+ * free_all_bootmem - release free pages to the buddy allocator
+ *
+ * Returns the number of pages actually released.
+ */
 unsigned long __init free_all_bootmem(void)
 {
 	return free_all_bootmem_core(NODE_DATA(0)->bdata);
@@ -231,12 +261,32 @@ static void __init free_bootmem_core(boo
 	}
 }
 
+/**
+ * free_bootmem_node - mark a page range as usable
+ * @pgdat: node the range resides on
+ * @physaddr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be considered reserved and left as they are.
+ *
+ * Only physical pages that actually reside on @pgdat are marked.
+ */
 void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
 	free_bootmem_core(pgdat->bdata, physaddr, size);
 }
 
+/**
+ * free_bootmem - mark a page range as usable
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be considered reserved and left as they are.
+ *
+ * All physical pages within the range are marked, no matter what
+ * node they reside on.
+ */
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
 	bootmem_data_t *bdata;
@@ -319,6 +369,15 @@ static void __init reserve_bootmem_core(
 	}
 }
 
+/**
+ * reserve_bootmem_node - mark a page range as reserved
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be reserved.
+ *
+ * Only physical pages that actually reside on @pgdat are marked.
+ */
 void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 				 unsigned long size, int flags)
 {
@@ -331,6 +390,16 @@ void __init reserve_bootmem_node(pg_data
 }
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+/**
+ * reserve_bootmem - mark a page range as usable
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be reserved.
+ *
+ * All physical pages within the range are marked, no matter what
+ * node they reside on.
+ */
 int __init reserve_bootmem(unsigned long addr, unsigned long size,
 			    int flags)
 {
@@ -499,6 +568,19 @@ found:
 	return ret;
 }
 
+/**
+ * __alloc_bootmem_nopanic - allocate boot memory without panicking
+ * @size: size of the request in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ *
+ * The goal is dropped if it can not be satisfied and the allocation will
+ * fall back to memory below @goal.
+ *
+ * Allocation may happen on any node in the system.
+ *
+ * Returns NULL on failure.
+ */
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 				      unsigned long goal)
 {
@@ -513,6 +595,19 @@ void * __init __alloc_bootmem_nopanic(un
 	return NULL;
 }
 
+/**
+ * __alloc_bootmem - allocate boot memory
+ * @size: size of the request in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ *
+ * The goal is dropped if it can not be satisfied and the allocation will
+ * fall back to memory below @goal.
+ *
+ * Allocation may happen on any node in the system.
+ *
+ * The function panics if the request can not be satisfied.
+ */
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
@@ -532,6 +627,19 @@ void * __init __alloc_bootmem(unsigned l
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
 
+/**
+ * __alloc_bootmem_low - allocate low boot memory
+ * @size: size of the request in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ *
+ * The goal is dropped if it can not be satisfied and the allocation will
+ * fall back to memory below @goal.
+ *
+ * Allocation may happen on any node in the system.
+ *
+ * The function panics if the request can not be satisfied.
+ */
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
@@ -553,6 +661,21 @@ void * __init __alloc_bootmem_low(unsign
 	return NULL;
 }
 
+/**
+ * __alloc_bootmem_node - allocate boot memory from a specific node
+ * @pgdat: node to allocate from
+ * @size: size of the request in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ *
+ * The goal is dropped if it can not be satisfied and the allocation will
+ * fall back to memory below @goal.
+ *
+ * Allocation may fall back to any node in the system if the specified node
+ * can not hold the requested memory.
+ *
+ * The function panics if the request can not be satisfied.
+ */
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
@@ -565,6 +688,21 @@ void * __init __alloc_bootmem_node(pg_da
 	return __alloc_bootmem(size, align, goal);
 }
 
+/**
+ * __alloc_bootmem_low_node - allocate low boot memory from a specific node
+ * @pgdat: node to allocate from
+ * @size: size of the request in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ *
+ * The goal is dropped if it can not be satisfied and the allocation will
+ * fall back to memory below @goal.
+ *
+ * Allocation may fall back to any node in the system if the specified node
+ * can not hold the requested memory.
+ *
+ * The function panics if the request can not be satisfied.
+ */
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 				       unsigned long align, unsigned long goal)
 {
@@ -573,6 +711,13 @@ void * __init __alloc_bootmem_low_node(p
 }
 
 #ifdef CONFIG_SPARSEMEM
+/**
+ * alloc_bootmem_section - allocate boot memory from a specific section
+ * @size: size of the request in bytes
+ * @section_nr: sparse map section to allocate from
+ *
+ * Return NULL on failure.
+ */
 void * __init alloc_bootmem_section(unsigned long size,
 				    unsigned long section_nr)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
