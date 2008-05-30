Message-Id: <20080530194737.336401616@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:21 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 01/14] bootmem: reorder code to match new bootmem structure
Content-Disposition: inline; filename=bootmem-reorder-code.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This only reorders functions so that further patches will be easier to
read.  No code changed.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 include/linux/bootmem.h |   79 ++++-----
 mm/bootmem.c            |  413 +++++++++++++++++++++++-------------------------
 2 files changed, 246 insertions(+), 246 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -38,6 +38,19 @@ unsigned long saved_max_pfn;
 
 bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
 
+/*
+ * Given an initialised bdata, it returns the size of the boot bitmap
+ */
+static unsigned long __init get_mapsize(bootmem_data_t *bdata)
+{
+	unsigned long mapsize;
+	unsigned long start = PFN_DOWN(bdata->node_boot_start);
+	unsigned long end = bdata->node_low_pfn;
+
+	mapsize = ((end - start) + 7) / 8;
+	return ALIGN(mapsize, sizeof(long));
+}
+
 /* return the number of _pages_ that will be allocated for the boot bitmap */
 unsigned long __init bootmem_bootmap_pages(unsigned long pages)
 {
@@ -72,19 +85,6 @@ static void __init link_bootmem(bootmem_
 }
 
 /*
- * Given an initialised bdata, it returns the size of the boot bitmap
- */
-static unsigned long __init get_mapsize(bootmem_data_t *bdata)
-{
-	unsigned long mapsize;
-	unsigned long start = PFN_DOWN(bdata->node_boot_start);
-	unsigned long end = bdata->node_low_pfn;
-
-	mapsize = ((end - start) + 7) / 8;
-	return ALIGN(mapsize, sizeof(long));
-}
-
-/*
  * Called once to set up the allocator itself.
  */
 static unsigned long __init init_bootmem_core(bootmem_data_t *bdata,
@@ -108,6 +108,146 @@ static unsigned long __init init_bootmem
 	return mapsize;
 }
 
+unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
+				unsigned long startpfn, unsigned long endpfn)
+{
+	return init_bootmem_core(pgdat->bdata, freepfn, startpfn, endpfn);
+}
+
+unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
+{
+	max_low_pfn = pages;
+	min_low_pfn = start;
+	return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
+}
+
+static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
+{
+	struct page *page;
+	unsigned long pfn;
+	unsigned long i, count;
+	unsigned long idx;
+	unsigned long *map;
+	int gofast = 0;
+
+	BUG_ON(!bdata->node_bootmem_map);
+
+	count = 0;
+	/* first extant page of the node */
+	pfn = PFN_DOWN(bdata->node_boot_start);
+	idx = bdata->node_low_pfn - pfn;
+	map = bdata->node_bootmem_map;
+	/*
+	 * Check if we are aligned to BITS_PER_LONG pages.  If so, we might
+	 * be able to free page orders of that size at once.
+	 */
+	if (!(pfn & (BITS_PER_LONG-1)))
+		gofast = 1;
+
+	for (i = 0; i < idx; ) {
+		unsigned long v = ~map[i / BITS_PER_LONG];
+
+		if (gofast && v == ~0UL) {
+			int order;
+
+			page = pfn_to_page(pfn);
+			count += BITS_PER_LONG;
+			order = ffs(BITS_PER_LONG) - 1;
+			__free_pages_bootmem(page, order);
+			i += BITS_PER_LONG;
+			page += BITS_PER_LONG;
+		} else if (v) {
+			unsigned long m;
+
+			page = pfn_to_page(pfn);
+			for (m = 1; m && i < idx; m<<=1, page++, i++) {
+				if (v & m) {
+					count++;
+					__free_pages_bootmem(page, 0);
+				}
+			}
+		} else {
+			i += BITS_PER_LONG;
+		}
+		pfn += BITS_PER_LONG;
+	}
+
+	/*
+	 * Now free the allocator bitmap itself, it's not
+	 * needed anymore:
+	 */
+	page = virt_to_page(bdata->node_bootmem_map);
+	idx = (get_mapsize(bdata) + PAGE_SIZE-1) >> PAGE_SHIFT;
+	for (i = 0; i < idx; i++, page++)
+		__free_pages_bootmem(page, 0);
+	count += i;
+	bdata->node_bootmem_map = NULL;
+
+	return count;
+}
+
+unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
+{
+	register_page_bootmem_info_node(pgdat);
+	return free_all_bootmem_core(pgdat->bdata);
+}
+
+unsigned long __init free_all_bootmem(void)
+{
+	return free_all_bootmem_core(NODE_DATA(0)->bdata);
+}
+
+static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr,
+				     unsigned long size)
+{
+	unsigned long sidx, eidx;
+	unsigned long i;
+
+	BUG_ON(!size);
+
+	/* out range */
+	if (addr + size < bdata->node_boot_start ||
+		PFN_DOWN(addr) > bdata->node_low_pfn)
+		return;
+	/*
+	 * round down end of usable mem, partially free pages are
+	 * considered reserved.
+	 */
+
+	if (addr >= bdata->node_boot_start && addr < bdata->last_success)
+		bdata->last_success = addr;
+
+	/*
+	 * Round up to index to the range.
+	 */
+	if (PFN_UP(addr) > PFN_DOWN(bdata->node_boot_start))
+		sidx = PFN_UP(addr) - PFN_DOWN(bdata->node_boot_start);
+	else
+		sidx = 0;
+
+	eidx = PFN_DOWN(addr + size - bdata->node_boot_start);
+	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
+		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
+
+	for (i = sidx; i < eidx; i++) {
+		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
+			BUG();
+	}
+}
+
+void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+			      unsigned long size)
+{
+	free_bootmem_core(pgdat->bdata, physaddr, size);
+}
+
+void __init free_bootmem(unsigned long addr, unsigned long size)
+{
+	bootmem_data_t *bdata;
+	list_for_each_entry(bdata, &bdata_list, list)
+		free_bootmem_core(bdata, addr, size);
+}
+
 /*
  * Marks a particular physical memory range as unallocatable. Usable RAM
  * might be used for boot-time allocations - or it might get added
@@ -183,43 +323,35 @@ static void __init reserve_bootmem_core(
 	}
 }
 
-static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr,
-				     unsigned long size)
+void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+				 unsigned long size, int flags)
 {
-	unsigned long sidx, eidx;
-	unsigned long i;
-
-	BUG_ON(!size);
+	int ret;
 
-	/* out range */
-	if (addr + size < bdata->node_boot_start ||
-		PFN_DOWN(addr) > bdata->node_low_pfn)
+	ret = can_reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
+	if (ret < 0)
 		return;
-	/*
-	 * round down end of usable mem, partially free pages are
-	 * considered reserved.
-	 */
-
-	if (addr >= bdata->node_boot_start && addr < bdata->last_success)
-		bdata->last_success = addr;
-
-	/*
-	 * Round up to index to the range.
-	 */
-	if (PFN_UP(addr) > PFN_DOWN(bdata->node_boot_start))
-		sidx = PFN_UP(addr) - PFN_DOWN(bdata->node_boot_start);
-	else
-		sidx = 0;
+	reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
+}
 
-	eidx = PFN_DOWN(addr + size - bdata->node_boot_start);
-	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
-		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+int __init reserve_bootmem(unsigned long addr, unsigned long size,
+			    int flags)
+{
+	bootmem_data_t *bdata;
+	int ret;
 
-	for (i = sidx; i < eidx; i++) {
-		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
-			BUG();
+	list_for_each_entry(bdata, &bdata_list, list) {
+		ret = can_reserve_bootmem_core(bdata, addr, size, flags);
+		if (ret < 0)
+			return ret;
 	}
+	list_for_each_entry(bdata, &bdata_list, list)
+		reserve_bootmem_core(bdata, addr, size, flags);
+
+	return 0;
 }
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
 /*
  * We 'merge' subsequent allocations to save space. We might 'lose'
@@ -371,138 +503,6 @@ found:
 	return ret;
 }
 
-static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
-{
-	struct page *page;
-	unsigned long pfn;
-	unsigned long i, count;
-	unsigned long idx;
-	unsigned long *map; 
-	int gofast = 0;
-
-	BUG_ON(!bdata->node_bootmem_map);
-
-	count = 0;
-	/* first extant page of the node */
-	pfn = PFN_DOWN(bdata->node_boot_start);
-	idx = bdata->node_low_pfn - pfn;
-	map = bdata->node_bootmem_map;
-	/*
-	 * Check if we are aligned to BITS_PER_LONG pages.  If so, we might
-	 * be able to free page orders of that size at once.
-	 */
-	if (!(pfn & (BITS_PER_LONG-1)))
-		gofast = 1;
-
-	for (i = 0; i < idx; ) {
-		unsigned long v = ~map[i / BITS_PER_LONG];
-
-		if (gofast && v == ~0UL) {
-			int order;
-
-			page = pfn_to_page(pfn);
-			count += BITS_PER_LONG;
-			order = ffs(BITS_PER_LONG) - 1;
-			__free_pages_bootmem(page, order);
-			i += BITS_PER_LONG;
-			page += BITS_PER_LONG;
-		} else if (v) {
-			unsigned long m;
-
-			page = pfn_to_page(pfn);
-			for (m = 1; m && i < idx; m<<=1, page++, i++) {
-				if (v & m) {
-					count++;
-					__free_pages_bootmem(page, 0);
-				}
-			}
-		} else {
-			i += BITS_PER_LONG;
-		}
-		pfn += BITS_PER_LONG;
-	}
-
-	/*
-	 * Now free the allocator bitmap itself, it's not
-	 * needed anymore:
-	 */
-	page = virt_to_page(bdata->node_bootmem_map);
-	idx = (get_mapsize(bdata) + PAGE_SIZE-1) >> PAGE_SHIFT;
-	for (i = 0; i < idx; i++, page++)
-		__free_pages_bootmem(page, 0);
-	count += i;
-	bdata->node_bootmem_map = NULL;
-
-	return count;
-}
-
-unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
-				unsigned long startpfn, unsigned long endpfn)
-{
-	return init_bootmem_core(pgdat->bdata, freepfn, startpfn, endpfn);
-}
-
-void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
-				 unsigned long size, int flags)
-{
-	int ret;
-
-	ret = can_reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
-	if (ret < 0)
-		return;
-	reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
-}
-
-void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
-			      unsigned long size)
-{
-	free_bootmem_core(pgdat->bdata, physaddr, size);
-}
-
-unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
-{
-	register_page_bootmem_info_node(pgdat);
-	return free_all_bootmem_core(pgdat->bdata);
-}
-
-unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
-{
-	max_low_pfn = pages;
-	min_low_pfn = start;
-	return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
-}
-
-#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
-int __init reserve_bootmem(unsigned long addr, unsigned long size,
-			    int flags)
-{
-	bootmem_data_t *bdata;
-	int ret;
-
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ret = can_reserve_bootmem_core(bdata, addr, size, flags);
-		if (ret < 0)
-			return ret;
-	}
-	list_for_each_entry(bdata, &bdata_list, list)
-		reserve_bootmem_core(bdata, addr, size, flags);
-
-	return 0;
-}
-#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
-
-void __init free_bootmem(unsigned long addr, unsigned long size)
-{
-	bootmem_data_t *bdata;
-	list_for_each_entry(bdata, &bdata_list, list)
-		free_bootmem_core(bdata, addr, size);
-}
-
-unsigned long __init free_all_bootmem(void)
-{
-	return free_all_bootmem_core(NODE_DATA(0)->bdata);
-}
-
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 				      unsigned long goal)
 {
@@ -532,6 +532,30 @@ void * __init __alloc_bootmem(unsigned l
 	return NULL;
 }
 
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
+#endif
+
+void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
+				  unsigned long goal)
+{
+	bootmem_data_t *bdata;
+	void *ptr;
+
+	list_for_each_entry(bdata, &bdata_list, list) {
+		ptr = alloc_bootmem_core(bdata, size, align, goal,
+					ARCH_LOW_ADDRESS_LIMIT);
+		if (ptr)
+			return ptr;
+	}
+
+	/*
+	 * Whoops, we cannot satisfy the allocation request.
+	 */
+	printk(KERN_ALERT "low bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of low memory");
+	return NULL;
+}
 
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
@@ -545,6 +569,13 @@ void * __init __alloc_bootmem_node(pg_da
 	return __alloc_bootmem(size, align, goal);
 }
 
+void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
+				       unsigned long align, unsigned long goal)
+{
+	return alloc_bootmem_core(pgdat->bdata, size, align, goal,
+				ARCH_LOW_ADDRESS_LIMIT);
+}
+
 #ifdef CONFIG_SPARSEMEM
 void * __init alloc_bootmem_section(unsigned long size,
 				    unsigned long section_nr)
@@ -575,35 +606,3 @@ void * __init alloc_bootmem_section(unsi
 	return ptr;
 }
 #endif
-
-#ifndef ARCH_LOW_ADDRESS_LIMIT
-#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
-#endif
-
-void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
-				  unsigned long goal)
-{
-	bootmem_data_t *bdata;
-	void *ptr;
-
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = alloc_bootmem_core(bdata, size, align, goal,
-					ARCH_LOW_ADDRESS_LIMIT);
-		if (ptr)
-			return ptr;
-	}
-
-	/*
-	 * Whoops, we cannot satisfy the allocation request.
-	 */
-	printk(KERN_ALERT "low bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of low memory");
-	return NULL;
-}
-
-void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
-				       unsigned long align, unsigned long goal)
-{
-	return alloc_bootmem_core(pgdat->bdata, size, align, goal,
-				ARCH_LOW_ADDRESS_LIMIT);
-}
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -41,36 +41,58 @@ typedef struct bootmem_data {
 extern bootmem_data_t bootmem_node_data[];
 
 extern unsigned long bootmem_bootmap_pages(unsigned long);
+
+extern unsigned long init_bootmem_node(pg_data_t *pgdat,
+				       unsigned long freepfn,
+				       unsigned long startpfn,
+				       unsigned long endpfn);
 extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
+
+extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
+extern unsigned long free_all_bootmem(void);
+
+extern void free_bootmem_node(pg_data_t *pgdat,
+			      unsigned long addr,
+			      unsigned long size);
 extern void free_bootmem(unsigned long addr, unsigned long size);
-extern void *__alloc_bootmem(unsigned long size,
+
+/*
+ * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
+ * the architecture-specific code should honor this).
+ *
+ * If flags is 0, then the return value is always 0 (success). If
+ * flags contains BOOTMEM_EXCLUSIVE, then -EBUSY is returned if the
+ * memory already was reserved.
+ */
+#define BOOTMEM_DEFAULT		0
+#define BOOTMEM_EXCLUSIVE	(1<<0)
+
+extern void reserve_bootmem_node(pg_data_t *pgdat,
+				 unsigned long physaddr,
+				 unsigned long size,
+				 int flags);
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+extern int reserve_bootmem(unsigned long addr, unsigned long size, int flags);
+#endif
+
+extern void *__alloc_bootmem_nopanic(unsigned long size,
 			     unsigned long align,
 			     unsigned long goal);
-extern void *__alloc_bootmem_nopanic(unsigned long size,
+extern void *__alloc_bootmem(unsigned long size,
 				     unsigned long align,
 				     unsigned long goal);
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
 				 unsigned long goal);
+extern void *__alloc_bootmem_node(pg_data_t *pgdat,
+				  unsigned long size,
+				  unsigned long align,
+				  unsigned long goal);
 extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 				      unsigned long size,
 				      unsigned long align,
 				      unsigned long goal);
-
-/*
- * flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
- * the architecture-specific code should honor this)
- */
-#define BOOTMEM_DEFAULT		0
-#define BOOTMEM_EXCLUSIVE	(1<<0)
-
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
-/*
- * If flags is 0, then the return value is always 0 (success). If
- * flags contains BOOTMEM_EXCLUSIVE, then -EBUSY is returned if the
- * memory already was reserved.
- */
-extern int reserve_bootmem(unsigned long addr, unsigned long size, int flags);
 #define alloc_bootmem(x) \
 	__alloc_bootmem(x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low(x) \
@@ -79,29 +101,6 @@ extern int reserve_bootmem(unsigned long
 	__alloc_bootmem(x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages(x) \
 	__alloc_bootmem_low(x, PAGE_SIZE, 0)
-#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
-
-extern unsigned long free_all_bootmem(void);
-extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
-extern void *__alloc_bootmem_node(pg_data_t *pgdat,
-				  unsigned long size,
-				  unsigned long align,
-				  unsigned long goal);
-extern unsigned long init_bootmem_node(pg_data_t *pgdat,
-				       unsigned long freepfn,
-				       unsigned long startpfn,
-				       unsigned long endpfn);
-extern void reserve_bootmem_node(pg_data_t *pgdat,
-				 unsigned long physaddr,
-				 unsigned long size,
-				 int flags);
-extern void free_bootmem_node(pg_data_t *pgdat,
-			      unsigned long addr,
-			      unsigned long size);
-extern void *alloc_bootmem_section(unsigned long size,
-				   unsigned long section_nr);
-
-#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
 	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_pages_node(pgdat, x) \
@@ -109,6 +108,8 @@ extern void *alloc_bootmem_section(unsig
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
+extern void *alloc_bootmem_section(unsigned long size,
+				   unsigned long section_nr);
 
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
