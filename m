From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910191833.LAA20518@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm19-2.3.22 generic numa-aware pagelists
Date: Tue, 19 Oct 1999 11:33:46 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: ralf@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

As per our discussions before you left on vacation in September, 
I have integrated the numa patch with the bigmem stuff. This 
patch is the generic code that will distribute the page free lists
on a per "node" basis. Ralf will probably be using this stuff in
the Origin o200/o2000 port.

Let me know if this looks okay, or if you want me to rework the
patch.

Thanks.

Kanoj

--- include/linux/memacc.h	Tue Oct 19 10:09:48 1999
+++ include/linux/memacc.h	Mon Oct 18 16:49:13 1999
@@ -0,0 +1,92 @@
+/*
+ * Written by Kanoj Sarcar (kanoj@sgi.com) Aug 99
+ */
+#ifndef _LINUX_MEMACC_H
+#define _LINUX_MEMACC_H
+
+#ifdef __KERNEL__
+#ifndef __ASSEMBLY__
+
+#include <linux/config.h>
+#include <linux/spinlock.h>
+
+#if CONFIG_AP1000
+/* the AP+ needs to allocate 8MB contiguous, aligned chunks of ram
+   for the ring buffers */
+#define NR_MEM_LISTS 12
+#else
+#define NR_MEM_LISTS 10
+#endif
+
+#ifdef CONFIG_BIGMEM
+#define NR_FREE_LISTS	(NR_MEM_LISTS*2)
+#else /* CONFIG_BIGMEM */
+#define NR_FREE_LISTS	NR_MEM_LISTS
+#endif
+
+/* The start of this MUST match the start of "struct page" */
+struct free_area_struct {
+	struct page *next;
+	struct page *prev;
+	unsigned int * map;
+};
+
+#ifndef CONFIG_NUMA
+
+#define LOCAL_BASE_ADDR(kaddr)	PAGE_OFFSET
+#define FREE_AREA_PAGE(page)	free_area
+#define LOCAL_MAP_BASE(page)	mem_map
+#define ADDR_TO_MAPBASE(kaddr)	mem_map
+#define FREE_AREA_NODE(nid)	free_area
+#define NODE_MEM_MAP(nid)	mem_map
+#define NODE_BASE_ADDR(nid)	PAGE_OFFSET
+#define FREELIST_LOCK_PAGE(page) (&page_alloc_lock)
+#define FREELIST_LOCK_NODE(nid)	(&page_alloc_lock)
+#define LOCK_FPAGES()
+#define UNLOCK_FPAGES()
+#define DECLARE_NON_NUMA_FREE_AREA \
+			static struct free_area_struct free_area[NR_FREE_LISTS]
+
+#else /* !CONFIG_NUMA */
+
+#define LOCK_FPAGES()		{ unsigned long fl; \
+				  spin_lock_irqsave(&page_alloc_lock, fl);
+#define UNLOCK_FPAGES()		spin_unlock_irqrestore(&page_alloc_lock, fl); }
+#define DECLARE_NON_NUMA_FREE_AREA
+
+typedef struct pglist_data {
+	struct free_area_struct free_area[NR_FREE_LISTS];
+	spinlock_t node_page_lock;
+	struct page *node_mem_map;
+	unsigned long node_map_size;
+	unsigned long *valid_addr_bitmap;
+} pg_data_t;
+
+extern int numnodes;
+
+#include <asm/memacc.h>
+
+#define MAP_ALIGN(x)	((((x) % sizeof(mem_map_t)) == 0) ? (x) : ((x) + \
+		sizeof(mem_map_t) - ((x) % sizeof(mem_map_t))))
+
+#endif /* !CONFIG_NUMA */
+
+#define LOCAL_MAP_NR(kvaddr) \
+	(((unsigned long)(kvaddr)-LOCAL_BASE_ADDR((kvaddr))) \
+							>> PAGE_SHIFT)
+
+#ifdef CONFIG_NUMA
+
+#define MAP_NR(kaddr)		(LOCAL_MAP_NR((kaddr)) + \
+		(((unsigned long)ADDR_TO_MAPBASE((kaddr)) - PAGE_OFFSET) / \
+		sizeof(mem_map_t)))
+#define kern_addr_valid(addr)	((KVADDR_TO_NID((unsigned long)addr) >= \
+	numnodes) ? 0 : (test_bit(LOCAL_MAP_NR((addr)), \
+	NODE_DATA(KVADDR_TO_NID((unsigned long)addr))->valid_addr_bitmap)))
+
+#endif /* CONFIG_NUMA */
+
+#endif /* !__ASSEMBLY__ */
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_MEMACC_H */
--- /usr/tmp/p_rdiff_a005L5/mm.h	Tue Oct 19 11:14:46 1999
+++ include/linux/mm.h	Mon Oct 18 16:49:13 1999
@@ -283,7 +283,10 @@
  */
 #define __get_free_page(gfp_mask) __get_free_pages((gfp_mask),0)
 #define __get_dma_pages(gfp_mask, order) __get_free_pages((gfp_mask) | GFP_DMA,(order))
+#define __get_free_page_node(gfp_mask, node) __get_free_pages_node((gfp_mask),0,node)
+#define __get_dma_pages_node(gfp_mask, order, node) __get_free_pages_node((gfp_mask) | GFP_DMA,(order),node)
 extern unsigned long FASTCALL(__get_free_pages(int gfp_mask, unsigned long gfp_order));
+extern unsigned long FASTCALL(__get_free_pages_node(int gfp_mask, unsigned long gfp_order, int));
 
 extern inline unsigned long get_free_page(int gfp_mask)
 {
@@ -302,6 +305,7 @@
 extern int FASTCALL(__free_page(struct page *));
 
 extern void show_free_areas(void);
+extern void show_free_areas_node(int);
 extern unsigned long put_dirty_page(struct task_struct * tsk,unsigned long page,
 	unsigned long address);
 
--- /usr/tmp/p_rdiff_a005LF/pagemap.h	Tue Oct 19 11:15:02 1999
+++ include/linux/pagemap.h	Mon Oct 18 16:49:13 1999
@@ -11,10 +11,13 @@
 
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/memacc.h>
 
 static inline unsigned long page_address(struct page * page)
 {
-	return PAGE_OFFSET + ((page - mem_map) << PAGE_SHIFT);
+	return LOCAL_BASE_ADDR(page) + PAGE_SIZE * \
+		(((unsigned long)page - (unsigned long)LOCAL_MAP_BASE(page)) \
+			/ sizeof(struct page));
 }
 
 /*
--- /usr/tmp/p_rdiff_a005Lk/Makefile	Tue Oct 19 11:16:23 1999
+++ kernel/Makefile	Mon Oct 18 12:07:02 1999
@@ -13,7 +13,7 @@
 O_TARGET := kernel.o
 O_OBJS    = sched.o dma.o fork.o exec_domain.o panic.o printk.o sys.o \
 	    module.o exit.o itimer.o info.o time.o softirq.o resource.o \
-	    sysctl.o acct.o capability.o ptrace.o
+	    sysctl.o acct.o capability.o ptrace.o numa.o
 
 OX_OBJS  += signal.o
 
--- /usr/tmp/p_rdiff_a005M5/ksyms.c	Tue Oct 19 11:17:02 1999
+++ kernel/ksyms.c	Mon Oct 18 14:56:09 1999
@@ -91,6 +91,7 @@
 
 /* internal kernel memory management */
 EXPORT_SYMBOL(__get_free_pages);
+EXPORT_SYMBOL(__get_free_pages_node);
 EXPORT_SYMBOL(free_pages);
 EXPORT_SYMBOL(__free_page);
 EXPORT_SYMBOL(kmem_find_general_cachep);
--- kernel/numa.c	Tue Oct 19 10:09:48 1999
+++ kernel/numa.c	Mon Oct 18 15:45:05 1999
@@ -0,0 +1,106 @@
+/*
+ * Written by Kanoj Sarcar (kanoj@sgi.com) Aug 99
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/memacc.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+
+#ifdef CONFIG_NUMA
+
+#define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
+
+int numnodes = 0;
+spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
+
+extern void show_free_areas_core(int);
+extern unsigned long __init free_area_init_core(unsigned long, unsigned long, 
+		mem_map_t **, struct free_area_struct *);
+
+void show_free_areas_node(int nid)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&node_lock, flags);
+	printk("Memory information for node %d:\n", nid);
+	show_free_areas_core(nid);
+	spin_unlock_irqrestore(&node_lock, flags);
+}
+
+/*
+ * Nodes can be initialized parallely, in no particular order.
+ * start_mem exists on node nid, (end_mem - 1) is the highest
+ * memory on node nid.
+ */
+unsigned long __init free_area_init_node(unsigned long start_mem, 
+		unsigned long end_mem, int nid, pg_data_t *pgdat)
+{
+	unsigned long ret, tend;
+
+	pgdat->node_page_lock = SPIN_LOCK_UNLOCKED;
+	tend = (end_mem &= PAGE_MASK);
+
+	if (mem_map == (mem_map_t *)NULL)
+		mem_map = (mem_map_t *)PAGE_OFFSET;
+
+	/*
+	 * Since the conceptual mem map array starts from PAGE_OFFSET,
+	 * we need to align the actual array onto a mem map boundary,
+	 * so that MAP_NR works. Note that mem map alignment also 
+	 * provides long alignment, which the core routine tries to do.
+	 */
+	start_mem = PAGE_OFFSET + MAP_ALIGN(start_mem - PAGE_OFFSET);
+	pgdat->node_map_size = ((end_mem - LOCAL_BASE_ADDR(start_mem)) >> 
+							PAGE_SHIFT);
+
+	ret = free_area_init_core(start_mem, tend, &pgdat->node_mem_map, 
+						pgdat->free_area);
+
+	ret = LONG_ALIGN(ret);
+	/*
+	 * Get space for the valid bitmap.
+	 */
+	pgdat->valid_addr_bitmap = (unsigned long *)ret;
+	ret = (unsigned long)(pgdat->valid_addr_bitmap +
+				(pgdat->node_map_size / BITS_PER_LONG));
+	memset(pgdat->valid_addr_bitmap, 0, 
+		(pgdat->node_map_size * sizeof(long))/
+			(BITS_PER_LONG * sizeof(size_t)));
+
+	ret = LONG_ALIGN(ret);
+	return(ret);
+}
+
+/*
+ * This can be refined. Currently, tries to do round robin, instead
+ * should do concentratic circle search, starting from current node.
+ */
+unsigned long __get_free_pages(int gfp_mask, unsigned long order)
+{
+	unsigned long ret = 0;
+	unsigned long flags;
+	int startnode, tnode;
+	static int nextnid = 0;
+
+	spin_lock_irqsave(&node_lock, flags);
+	tnode = nextnid;
+	nextnid++;
+	if (nextnid == numnodes)
+		nextnid = 0;
+	spin_unlock_irqrestore(&node_lock, flags);
+	startnode = tnode;
+	while (tnode < numnodes) {
+		if ((ret = __get_free_pages_node(gfp_mask, order, tnode++)))
+			return(ret);
+	}
+	tnode = 0;
+	while (tnode != startnode) {
+		if ((ret = __get_free_pages_node(gfp_mask, order, tnode++)))
+			return(ret);
+	}
+	return(0);
+}
+
+#endif /* CONFIG_NUMA */
--- /usr/tmp/p_rdiff_a005Mb/page_alloc.c	Tue Oct 19 11:19:05 1999
+++ mm/page_alloc.c	Mon Oct 18 15:39:28 1999
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/bigmem.h> /* export bigmem vars */
+#include <linux/memacc.h>
 
 #include <asm/dma.h>
 #include <asm/uaccess.h> /* for copy_to/from_user */
@@ -32,29 +33,11 @@
  * of different sizes
  */
 
-#if CONFIG_AP1000
-/* the AP+ needs to allocate 8MB contiguous, aligned chunks of ram
-   for the ring buffers */
-#define NR_MEM_LISTS 12
-#else
-#define NR_MEM_LISTS 10
-#endif
-
-/* The start of this MUST match the start of "struct page" */
-struct free_area_struct {
-	struct page *next;
-	struct page *prev;
-	unsigned int * map;
-};
-
 #define memory_head(x) ((struct page *)(x))
 
-#ifdef CONFIG_BIGMEM
 #define BIGMEM_LISTS_OFFSET	NR_MEM_LISTS
-static struct free_area_struct free_area[NR_MEM_LISTS*2];
-#else
-static struct free_area_struct free_area[NR_MEM_LISTS];
-#endif
+spinlock_t page_alloc_lock = SPIN_LOCK_UNLOCKED;
+DECLARE_NON_NUMA_FREE_AREA;
 
 static inline void init_mem_queue(struct free_area_struct * head)
 {
@@ -97,27 +80,31 @@
  *
  * Hint: -mask = 1+~mask
  */
-spinlock_t page_alloc_lock = SPIN_LOCK_UNLOCKED;
 
-static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
+static inline void free_pages_ok(struct page *page, unsigned long map_nr, 
+					unsigned long order)
 {
-	struct free_area_struct *area = free_area + order;
+	struct free_area_struct *area = FREE_AREA_PAGE(page) + order;
 	unsigned long index = map_nr >> (1 + order);
 	unsigned long mask = (~0UL) << order;
 	unsigned long flags;
 
-	spin_lock_irqsave(&page_alloc_lock, flags);
+	spin_lock_irqsave(FREELIST_LOCK_PAGE(page), flags);
 
-#define list(x) (mem_map+(x))
+#define list(x) (LOCAL_MAP_BASE(page)+(x))
 
 #ifdef CONFIG_BIGMEM
 	if (map_nr >= bigmem_mapnr) {
 		area += BIGMEM_LISTS_OFFSET;
+		LOCK_FPAGES();
 		nr_free_bigpages -= mask;
+		UNLOCK_FPAGES();
 	}
 #endif
 	map_nr &= mask;
+	LOCK_FPAGES();
 	nr_free_pages -= mask;
+	UNLOCK_FPAGES();
 	while (mask + (1 << (NR_MEM_LISTS-1))) {
 		if (!test_and_change_bit(index, area->map))
 			break;
@@ -131,7 +118,7 @@
 
 #undef list
 
-	spin_unlock_irqrestore(&page_alloc_lock, flags);
+	spin_unlock_irqrestore(FREELIST_LOCK_PAGE(page), flags);
 }
 
 int __free_page(struct page *page)
@@ -142,7 +129,7 @@
 		if (PageLocked(page))
 			PAGE_BUG(page);
 
-		free_pages_ok(page - mem_map, 0);
+		free_pages_ok(page, page - LOCAL_MAP_BASE(page), 0);
 		return 1;
 	}
 	return 0;
@@ -150,16 +137,20 @@
 
 int free_pages(unsigned long addr, unsigned long order)
 {
-	unsigned long map_nr = MAP_NR(addr);
+	unsigned long map_nr = LOCAL_MAP_NR(addr);
 
+#ifdef CONFIG_NUMA
+	if (addr < PAGE_OFFSET)
+		return 0;
+#endif
 	if (map_nr < max_mapnr) {
-		mem_map_t * map = mem_map + map_nr;
+		mem_map_t * map = ADDR_TO_MAPBASE(addr) + map_nr;
 		if (!PageReserved(map) && put_page_testzero(map)) {
 			if (PageSwapCache(map))
 				PAGE_BUG(map);
 			if (PageLocked(map))
 				PAGE_BUG(map);
-			free_pages_ok(map_nr, order);
+			free_pages_ok(map, map_nr, order);
 			return 1;
 		}
 	}
@@ -172,24 +163,27 @@
 #define MARK_USED(index, order, area) \
 	change_bit((index) >> (1+(order)), (area)->map)
 #define CAN_DMA(x) (PageDMA(x))
-#define ADDRESS(x) (PAGE_OFFSET + ((x) << PAGE_SHIFT))
+#define ADDRESS(nid, x) (NODE_BASE_ADDR(nid) + ((x) << PAGE_SHIFT))
 
 #ifdef CONFIG_BIGMEM
-#define RMQUEUEBIG(order, gfp_mask) \
+#define RMQUEUEBIG(nid, order, gfp_mask) \
 if (gfp_mask & __GFP_BIGMEM) { \
-	struct free_area_struct * area = free_area+order+BIGMEM_LISTS_OFFSET; \
+	struct free_area_struct * area = FREE_AREA_NODE(nid)+order+ \
+						BIGMEM_LISTS_OFFSET; \
 	unsigned long new_order = order; \
 	do { struct page *prev = memory_head(area), *ret = prev->next; \
 		if (memory_head(area) != ret) { \
 			unsigned long map_nr; \
 			(prev->next = ret->next)->prev = prev; \
-			map_nr = ret - mem_map; \
+			map_nr = ret - NODE_MEM_MAP(nid); \
 			MARK_USED(map_nr, new_order, area); \
+			LOCK_FPAGES(); \
 			nr_free_pages -= 1 << order; \
 			nr_free_bigpages -= 1 << order; \
+			UNLOCK_FPAGES(); \
 			EXPAND(ret, map_nr, order, new_order, area); \
-			spin_unlock_irqrestore(&page_alloc_lock, flags); \
-			return ADDRESS(map_nr); \
+			spin_unlock_irqrestore(FREELIST_LOCK_NODE(nid), flags);\
+			return ADDRESS(nid, map_nr); \
 		} \
 		new_order++; area++; \
 	} while (new_order < NR_MEM_LISTS); \
@@ -196,8 +190,8 @@
 }
 #endif
 
-#define RMQUEUE(order, gfp_mask) \
-do { struct free_area_struct * area = free_area+order; \
+#define RMQUEUE(nid, order, gfp_mask) \
+do { struct free_area_struct * area = FREE_AREA_NODE(nid)+order; \
      unsigned long new_order = order; \
 	do { struct page *prev = memory_head(area), *ret = prev->next; \
 		while (memory_head(area) != ret) { \
@@ -204,12 +198,14 @@
 			if (!(gfp_mask & __GFP_DMA) || CAN_DMA(ret)) { \
 				unsigned long map_nr; \
 				(prev->next = ret->next)->prev = prev; \
-				map_nr = ret - mem_map; \
+				map_nr = ret - NODE_MEM_MAP(nid); \
 				MARK_USED(map_nr, new_order, area); \
+				LOCK_FPAGES(); \
 				nr_free_pages -= 1 << order; \
+				UNLOCK_FPAGES(); \
 				EXPAND(ret, map_nr, order, new_order, area); \
-				spin_unlock_irqrestore(&page_alloc_lock,flags);\
-				return ADDRESS(map_nr); \
+				spin_unlock_irqrestore(FREELIST_LOCK_NODE(nid),flags);\
+				return ADDRESS(nid, map_nr); \
 			} \
 			prev = ret; \
 			ret = ret->next; \
@@ -230,7 +226,8 @@
 	set_page_count(map, 1); \
 } while (0)
 
-unsigned long __get_free_pages(int gfp_mask, unsigned long order)
+static inline unsigned long __get_free_pages_core(int gfp_mask, 
+				unsigned long order, int nid)
 {
 	unsigned long flags;
 
@@ -302,12 +299,12 @@
 			goto nopage;
 	}
 ok_to_allocate:
-	spin_lock_irqsave(&page_alloc_lock, flags);
+	spin_lock_irqsave(FREELIST_LOCK_NODE(nid), flags);
 #ifdef CONFIG_BIGMEM
-	RMQUEUEBIG(order, gfp_mask);
+	RMQUEUEBIG(nid, order, gfp_mask);
 #endif
-	RMQUEUE(order, gfp_mask);
-	spin_unlock_irqrestore(&page_alloc_lock, flags);
+	RMQUEUE(nid, order, gfp_mask);
+	spin_unlock_irqrestore(FREELIST_LOCK_NODE(nid), flags);
 
 	/*
 	 * If we can schedule, do so, and make sure to yield.
@@ -323,12 +320,25 @@
 	return 0;
 }
 
+#ifndef CONFIG_NUMA
+unsigned long __get_free_pages(int gfp_mask, unsigned long order)
+{
+	return(__get_free_pages_core(gfp_mask, order, -1));
+}
+#endif /* !CONFIG_NUMA */
+
+unsigned long __get_free_pages_node(int gfp_mask, unsigned long order,
+					int nid)
+{
+	return(__get_free_pages_core(gfp_mask, order, nid));
+}
+
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
  * memory on each free list with the exception of the first item on the list.
  */
-void show_free_areas(void)
+void show_free_areas_core(int nid)
 {
  	unsigned long order, flags;
  	unsigned long total = 0;
@@ -342,16 +352,17 @@
 		freepages.min,
 		freepages.low,
 		freepages.high);
-	spin_lock_irqsave(&page_alloc_lock, flags);
+	spin_lock_irqsave(FREELIST_LOCK_NODE(nid), flags);
  	for (order=0 ; order < NR_MEM_LISTS; order++) {
 		struct page * tmp;
 		unsigned long nr = 0;
-		for (tmp = free_area[order].next ; tmp != memory_head(free_area+order) ; tmp = tmp->next) {
+		for (tmp = FREE_AREA_NODE(nid)[order].next ; tmp != memory_head(FREE_AREA_NODE(nid)+order) ; tmp = tmp->next) {
 			nr ++;
 		}
 #ifdef CONFIG_BIGMEM
-		for (tmp = free_area[BIGMEM_LISTS_OFFSET+order].next;
-		     tmp != memory_head(free_area+BIGMEM_LISTS_OFFSET+order);
+		for (tmp = FREE_AREA_NODE(nid)[BIGMEM_LISTS_OFFSET+order].next;
+		     tmp != memory_head(FREE_AREA_NODE(nid)+BIGMEM_LISTS_OFFSET
+								+order);
 		     tmp = tmp->next) {
 			nr ++;
 		}
@@ -359,7 +370,7 @@
 		total += nr * ((PAGE_SIZE>>10) << order);
 		printk("%lu*%lukB ", nr, (unsigned long)((PAGE_SIZE>>10) << order));
 	}
-	spin_unlock_irqrestore(&page_alloc_lock, flags);
+	spin_unlock_irqrestore(FREELIST_LOCK_NODE(nid), flags);
 	printk("= %lukB)\n", total);
 #ifdef SWAP_CACHE_INFO
 	show_swap_cache_info();
@@ -366,6 +377,11 @@
 #endif	
 }
 
+void show_free_areas(void)
+{
+	show_free_areas_core(-1);
+}
+
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
 /*
@@ -374,9 +390,10 @@
  *   - mark all memory queues empty
  *   - clear the memory bitmaps
  */
-unsigned long __init free_area_init(unsigned long start_mem, unsigned long end_mem)
+unsigned long __init free_area_init_core(unsigned long start_mem, unsigned 
+ long end_mem, mem_map_t **lmap, struct free_area_struct *free_area)
 {
-	mem_map_t * p;
+	mem_map_t *p, *mem_map;
 	unsigned long mask = PAGE_MASK;
 	unsigned long i;
 
@@ -387,16 +404,17 @@
 	 * This is fairly arbitrary, but based on some behaviour
 	 * analysis.
 	 */
-	i = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT+7);
+	i = (end_mem - LOCAL_BASE_ADDR(start_mem)) >> (PAGE_SHIFT+7);
 	if (i < 10)
 		i = 10;
 	if (i > 256)
 		i = 256;
-	freepages.min = i;
-	freepages.low = i * 2;
-	freepages.high = i * 3;
-	mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
-	p = mem_map + MAP_NR(end_mem);
+	freepages.min += i;
+	freepages.low += i * 2;
+	freepages.high += i * 3;
+	*lmap = mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
+	p = mem_map + LOCAL_MAP_NR(end_mem - 1);
+	p++;	/* We did LOCAL_MAP_NR on end_mem - 1 */
 	start_mem = LONG_ALIGN((unsigned long) p);
 	memset(mem_map, 0, start_mem - (unsigned long) mem_map);
 	do {
@@ -414,7 +432,8 @@
 #endif
 		mask += mask;
 		end_mem = (end_mem + ~mask) & mask;
-		bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i);
+		bitmap_size = (end_mem - LOCAL_BASE_ADDR(start_mem)) >> 
+							(PAGE_SHIFT + i);
 		bitmap_size = (bitmap_size + 7) >> 3;
 		bitmap_size = LONG_ALIGN(bitmap_size);
 		free_area[i].map = (unsigned int *) start_mem;
@@ -428,3 +447,11 @@
 	}
 	return start_mem;
 }
+
+#ifndef CONFIG_NUMA
+unsigned long __init free_area_init(unsigned long start_mem, unsigned long end_mem)
+{
+	return(free_area_init_core(start_mem, end_mem, 
+					&mem_map, free_area));
+}
+#endif /* !CONFIG_NUMA */
--- /usr/tmp/p_rdiff_a005Mw/swap.c	Tue Oct 19 11:19:59 1999
+++ mm/swap.c	Mon Oct 18 12:07:02 1999
@@ -30,13 +30,13 @@
  * start background swapping if we fall below freepages.high free
  * pages, and we begin intensive swapping below freepages.low.
  *
- * These values are there to keep GCC from complaining. Actual
- * initialization is done in mm/page_alloc.c or arch/sparc(64)/mm/init.c.
+ * Actual initialization is done in mm/page_alloc.c or 
+ * arch/sparc(64)/mm/init.c.
  */
 freepages_t freepages = {
-	48,	/* freepages.min */
-	96,	/* freepages.low */
-	144	/* freepages.high */
+	0,	/* freepages.min */
+	0,	/* freepages.low */
+	0	/* freepages.high */
 };
 
 /* How many pages do we try to swap or page in/out together? */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
