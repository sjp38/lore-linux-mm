Message-Id: <20080503152800.870750856@symbol.fehenstaub.lan>
References: <20080503152502.191599824@symbol.fehenstaub.lan>
Date: Sat, 03 May 2008 17:25:03 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 1/2] mm: rootmem boot-time memory allocator
Content-Disposition: inline; filename=rootmem.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

A boot time allocator that uses a bitmap for all pages in the system,
merges subsequent partial-page allocations, and transparently handles
reservations and freeings across memory node boundaries on NUMA
systems.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

Index: linux-2.6/include/linux/rootmem.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/rootmem.h
@@ -0,0 +1,128 @@
+#ifndef _LINUX_ROOTMEM_H
+#define _LINUX_ROOTMEM_H
+
+#include <linux/mmzone.h>
+#include <asm/dma.h>
+
+extern void rootmem_register_node(int nid, unsigned long start,
+				unsigned long end);
+
+extern unsigned long rootmem_map_pages(void);
+
+extern void rootmem_setup(unsigned long mapstart);
+
+extern unsigned long rootmem_release_node(int nid);
+
+extern void rootmem_free(unsigned long addr, unsigned long size);
+extern int rootmem_reserve(unsigned long addr, unsigned long size,
+			int exclusive);
+
+extern void *__rootmem_alloc_node(int nid, unsigned long size,
+			unsigned long align, unsigned long goal,
+			unsigned long limit);
+
+#define rootmem_register(nid, start, end)		\
+	rootmem_register_node(0, (start), (end))
+
+#define rootmem_release() rootmem_release_node(0)
+
+#define __rootmem_alloc(size, align, goal, limit)	\
+	__rootmem_alloc_node(-1, (size), (align), (goal), (limit))
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+#define rootmem_alloc(x)			\
+	__rootmem_alloc(x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS), 0)
+#define rootmem_alloc_low(x)			\
+	__rootmem_alloc(x, SMP_CACHE_BYTES, 0, 0)
+#define rootmem_alloc_pages(x)			\
+	__rootmem_alloc(x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS), 0)
+#define rootmem_alloc_low_pages(x)		\
+	__rootmem_alloc(x, PAGE_SIZE, 0, 0)
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
+
+/*
+ * bootmem legacy
+ */
+
+/* XXX: Can this go somewhere else? */
+extern unsigned long min_low_pfn, max_low_pfn, max_pfn;
+#ifdef CONFIG_CRASH_DUMP
+extern unsigned long saved_max_pfn;
+#endif
+/* Catch those... */
+typedef void *bootmem_data_t;
+/* !XXX */
+
+#define BOOTMEM_DEFAULT		0
+#define BOOTMEM_EXCLUSIVE	1
+
+static inline void free_bootmem(unsigned long addr, unsigned long size)
+{
+	rootmem_free(addr, size);
+}
+static inline void free_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+				unsigned long size)
+{
+	rootmem_free(addr, size);
+}
+static inline int reserve_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+				unsigned long size, int flags)
+{
+	return rootmem_reserve(addr, size, flags & BOOTMEM_EXCLUSIVE);
+}
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+static inline int reserve_bootmem(unsigned long addr, unsigned long size,
+				int flags)
+{
+	return rootmem_reserve(addr, size, flags & BOOTMEM_EXCLUSIVE);
+}
+static inline void *alloc_bootmem(unsigned long size)
+{
+	return rootmem_alloc(size);
+}
+static inline void *alloc_bootmem_low(unsigned long size)
+{
+	return rootmem_alloc_low(size);
+}
+static inline void *alloc_bootmem_pages(unsigned long nr)
+{
+	return rootmem_alloc_pages(nr);
+}
+static inline void *alloc_bootmem_low_pages(unsigned long nr)
+{
+	return rootmem_alloc_low_pages(nr);
+}
+
+#define alloc_bootmem_node(n, x)		alloc_bootmem(x)
+#define alloc_bootmem_pages_node(n, x)		alloc_bootmem_pages(x)
+#define alloc_bootmem_low_pages_node(n, x)	alloc_bootmem_low_pages(x)
+
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
+
+/*
+ * XXX: Can this go somewhere else?
+ */
+#ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
+extern void *alloc_remap(int nid, unsigned long size);
+#else
+static inline void *alloc_remap(int n, unsigned long s) { return NULL; }
+#endif
+extern unsigned long __meminitdata nr_kernel_pages;
+extern unsigned long __meminitdata nr_all_pages;
+extern void *alloc_large_system_hash(const char *tablename,
+				unsigned long bucketsize,
+				unsigned long numentries,
+				int scale, int flags,
+				unsigned int *_hash_shift,
+				unsigned int *_hash_mask,
+				unsigned long limit);
+#define HASH_EARLY 0x00000001
+#if defined(CONFIGU_NUMA) && (defined(CONFIG_IA64) || defined(CONFIG_X86_64))
+#define HASHDIST_DEFAULT 1
+#else
+#define HASHDIST_DEFAULT 0
+#endif
+extern int hashdist;
+
+#endif /* _LINUX_ROOTMEM_H */
Index: linux-2.6/mm/rootmem.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/rootmem.c
@@ -0,0 +1,405 @@
+/*
+ * rootmem
+ *
+ * Copyright (c) 1999 Ingo Molnar
+ * Copyright (c) 2008 Johannes Weiner
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/pfn.h>
+#include <linux/io.h>
+
+#include "internal.h"
+#include <linux/rootmem.h>
+
+/******** bootmem legacy */
+unsigned long min_low_pfn, max_low_pfn, max_pfn;
+#ifdef CONFIG_CRASH_DUMP
+unsigned long saved_max_pfn;
+#endif
+/******** !bootmem legacy */
+
+/* Global memory state */
+static void *rootmem_map __initdata;
+static unsigned long rootmem_min_pfn __initdata = ~0UL;
+static unsigned long rootmem_max_pfn __initdata;
+
+/* Allocator state */
+static int rootmem_functional __initdata;
+
+/* Registered nodes */
+static int rootmem_nr_nodes __initdata;
+
+/* Node sizes */
+static unsigned long rootmem_node_pages[MAX_NUMNODES] __initdata;
+
+/* Node offsets within rootmem_map */
+static unsigned long rootmem_node_offsets[MAX_NUMNODES] __initdata;
+
+/* Last allocation ending address on each node */
+static unsigned long rootmem_node_last[MAX_NUMNODES] __initdata;
+
+/*
+ * rootmem_register_node - register a node to rootmem
+ * @nid: node id
+ * @start: first pfn on the node
+ * @end: first pfn after the node
+ *
+ * This function must not be called anymore if the allocator
+ * is already up and running (rootmem_setup() has been called).
+ */
+void __init rootmem_register_node(int nid, unsigned long start,
+			unsigned long end)
+{
+	BUG_ON(rootmem_functional);
+
+	if (start < rootmem_min_pfn)
+		rootmem_min_pfn = start;
+	if (end > rootmem_max_pfn)
+		rootmem_max_pfn = end;
+
+	rootmem_node_pages[nid] = end - start;
+	rootmem_node_offsets[nid] = start;
+	rootmem_nr_nodes++;
+}
+
+static unsigned long __init rootmem_map_bytes(void)
+{
+	unsigned long bytes;
+
+	bytes = (rootmem_max_pfn - rootmem_min_pfn + 7) / 8;
+
+	/*
+	 * The alignment is needed to operate on
+	 * full wordsize vectors in rootmem_release_node().
+	 */
+	return ALIGN(bytes, sizeof(long));
+}
+
+/*
+ * rootmem_map_pages - pages needed to hold the bitmap
+ */
+unsigned long __init rootmem_map_pages(void)
+{
+	unsigned long bytes;
+
+	bytes = ALIGN(rootmem_map_bytes(), PAGE_SIZE);
+	return bytes / PAGE_SIZE;
+}
+
+/*
+ * rootmem_setup - activate the rootmem allocator
+ * @map: address of the bitmap to use
+ *
+ * @map must be at least rootmem_map_pages() big.
+ *
+ * After a call to this function, the rootmem allocator
+ * is enabled and no further nodes must be registered.
+ */
+void __init rootmem_setup(unsigned long mapstart)
+{
+	rootmem_map = phys_to_virt(PFN_PHYS(mapstart));
+	memset(rootmem_map, 0xff, rootmem_map_bytes());
+	rootmem_functional = 1;
+
+	printk(KERN_INFO "rootmem: %lu pages on %d node(s) - map @ pfn %lx\n",
+		rootmem_max_pfn - rootmem_min_pfn, rootmem_nr_nodes,
+		mapstart);
+
+	/* XXX: bootmem legacy */
+	min_low_pfn = mapstart;
+	max_low_pfn = rootmem_max_pfn;
+}
+
+/*
+ * rootmem_release_node - release a node from the allocator
+ * @nid: node id of the node to be released
+ *
+ * All unreserved memory of the node @nid will be released
+ * to the buddy allocator.  If it was the last node registered
+ * to rootmem, the bitmap will be released too.
+ *
+ * After a call to this function, the rootmem allocator is
+ * disabled.
+ *
+ * The number of released pages is returned.
+ *
+ */
+unsigned long __init rootmem_release_node(int nid)
+{
+	int aligned;
+	unsigned long start, end, count = 0;
+
+	register_page_bootmem_info_node(NODE_DATA(nid));
+
+	rootmem_functional = 0;
+	BUG_ON(!rootmem_nr_nodes);
+
+	start = rootmem_node_offsets[nid];
+	end = start + rootmem_node_pages[nid];
+
+	/*
+	 * If the starting pfn is aligned to the machines
+	 * wordsize, we might be able to release pages in
+	 * blocks of that size.
+	 */
+	aligned = !(start & (BITS_PER_LONG - 1));
+
+	while (start < end) {
+		unsigned long pfn = start;
+		unsigned long *map = rootmem_map;
+		unsigned long vec = ~map[start / BITS_PER_LONG];
+
+		/*
+		 * Release wordsize pages at once to the buddy allocator
+		 * if we are properly aligned, the full vector is
+		 * unreserved and the block would not go beyond the end
+		 * of this node's memory.
+		 */
+		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
+			int order = ilog2(BITS_PER_LONG);
+
+			__free_pages_bootmem(pfn_to_page(pfn), order);
+			count += BITS_PER_LONG;
+		/*
+		 * Bad luck. If there are still unreserved pages in the
+		 * vector, free them one by one.
+		 */
+		} else {
+			while (vec && pfn < end) {
+				if (vec & 1) {
+					struct page *page = pfn_to_page(pfn);
+
+					__free_pages_bootmem(page, 0);
+					count++;
+				}
+				pfn++;
+				vec >>= 1;
+			}
+		}
+		start += BITS_PER_LONG;
+	}
+
+	/* This was the last node, drop the bitmap too */
+	if (!--rootmem_nr_nodes) {
+		unsigned long pages = rootmem_map_pages();
+		struct page *page = virt_to_page(rootmem_map);
+
+		count += pages;
+		while (pages--)
+			__free_pages_bootmem(page++, 0);
+	}
+
+	printk(KERN_INFO "rootmem: %lu pages released on node %i\n",
+		count, nid);
+
+	return count;
+}
+
+static void __init check_rootmem_parms(unsigned long start, unsigned long end)
+{
+	BUG_ON(!rootmem_functional);
+
+	if (start < rootmem_min_pfn || end > rootmem_max_pfn) {
+		printk(KERN_ERR "rootmem request out of range: %lx-%lx, usable: %lx-%lx\n",
+			start, end, rootmem_min_pfn, rootmem_max_pfn);
+		BUG();
+	}
+}
+
+static void __init __rootmem_free(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+
+	check_rootmem_parms(start, end);
+	for (pfn = start; pfn < end; pfn++)
+		if (!test_and_clear_bit(pfn, rootmem_map)) {
+			printk(KERN_ERR "rootmem: double free of pfn %lx\n",
+				pfn);
+			BUG();
+		}
+}
+
+static int __init __rootmem_reserve(unsigned long start, unsigned long end,
+				int exclusive)
+{
+	unsigned long pfn;
+
+	check_rootmem_parms(start, end);
+	for (pfn = start; pfn < end; pfn++)
+		if (test_and_set_bit(pfn, rootmem_map))
+			if (exclusive) {
+				__rootmem_free(start, pfn);
+				return -EBUSY;
+			}
+
+	return 0;
+}
+
+/*
+ * rootmem_free - mark a memory region as free
+ * @addr: starting address
+ * @size: size of region in bytes
+ *
+ * Only pages completely within the bounds of the region
+ * are marked free.
+ */
+void __init rootmem_free(unsigned long addr, unsigned long size)
+{
+	unsigned long start, end;
+
+	start = PFN_UP(addr);
+	end = PFN_DOWN(addr + size);
+	__rootmem_free(start, end);
+}
+
+/*
+ * rootmem_reserve - mark a memory region as reserved
+ * @addr: starting address
+ * @size: size of region in bytes
+ * @exclusive: reserve region exclusively
+ *
+ * All pages (even incomplete ones) within the bounds of the region
+ * are marked reserved.
+ *
+ * If @exclusive is !0, this function returns -EBUSY if the
+ * region or parts of it are already reserved.
+ */
+int __init rootmem_reserve(unsigned long addr, unsigned long size,
+			int exclusive)
+{
+	unsigned long start, end;
+
+	start = PFN_DOWN(addr);
+	end = PFN_UP(addr + size);
+	return __rootmem_reserve(start, end, exclusive);
+}
+
+static void * __init ___rootmem_alloc_node(int nid, int align,
+				unsigned long start_pfn, unsigned long bytes)
+{
+	void *region;
+	int merge = 0;
+	unsigned long last_end, last_pfn, new_start, new_end;
+
+	/* XXX: Find a more appropriate slot */
+	if (nid == -1)
+		nid = 0;
+
+	/*
+	 * If the allocation is subsequent to a prior allocation that did not
+	 * use all of its last page, the new block might use it or even fit
+	 * completely into it.
+	 */
+	last_end = rootmem_node_last[nid];
+	last_pfn = PFN_DOWN(last_end);
+
+	if (last_pfn + 1 == start_pfn)
+		new_start = ALIGN(last_end, align);
+	else
+		new_start = PFN_PHYS(start_pfn);
+
+	merge = PFN_DOWN(new_start) < start_pfn;
+
+	new_end = new_start + bytes;
+	rootmem_node_last[nid] = new_end;
+
+	/*
+	 * Since we checked the area in advance, a failed reservation
+	 * is clearly a BUG.
+	 */
+	if (__rootmem_reserve(PFN_DOWN(new_start) + merge, PFN_UP(new_end), 1))
+		BUG();
+
+	region = phys_to_virt(new_start);
+	memset(region, 0, bytes);
+	return region;
+}
+
+/*
+ * __rootmem_alloc_node - allocate a memory region
+ * @nid: node to allocate memory from
+ * @size: size of the region in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ * @limit: first address after the region
+ */
+void * __init __rootmem_alloc_node(int nid, unsigned long size,
+			unsigned long align, unsigned long goal,
+			unsigned long limit)
+{
+	unsigned long min_idx, max_idx, sidx, step;
+
+	/*
+	 * If a node was specified, crossing its boundaries is
+	 * not allowed.  Otherwise we are agnostic to node
+	 * sizes and work with the whole range of pages available.
+	 */
+	if (nid == -1) {
+		min_idx = rootmem_min_pfn;
+		max_idx = rootmem_max_pfn;
+	} else {
+		min_idx = rootmem_node_offsets[nid];
+		max_idx = min_idx + rootmem_node_pages[nid];
+	}
+
+	BUG_ON(align & (align - 1));
+	BUG_ON(limit && goal + size > limit);
+
+	goal >>= PAGE_SHIFT;
+	limit >>= PAGE_SHIFT;
+
+	/*
+	 * We walk in page steps anyway, so align does only have an
+	 * impact for the block searching if it's bigger than the
+	 * page size.  It must be preserved, however, for the block
+	 * merging at a finer granularity than whole pages.
+	 */
+	step = max_t(unsigned long, align >> PAGE_SHIFT, 1);
+
+	if (goal && goal < max_idx)
+		sidx = ALIGN(goal, step);
+	else
+		sidx = ALIGN(min_idx, step);
+
+	if (limit && max_idx > limit)
+		max_idx = limit;
+
+restart:
+	while (1) {
+		unsigned long eidx, idx;
+
+		sidx = find_next_zero_bit(rootmem_map, max_idx, sidx);
+		sidx = ALIGN(sidx, step);
+		eidx = sidx + PFN_UP(size);
+
+		if (sidx > max_idx)
+			break;
+		if (eidx > max_idx)
+			break;
+
+		/*
+		 * XXX: The last page may be dropped due to merging
+		 * but it is required to be free!
+		 */
+		for (idx = sidx; idx < eidx; idx++)
+			if (test_bit(idx, rootmem_map)) {
+				sidx = ALIGN(idx, step);
+				if (sidx == idx)
+					sidx += step;
+				continue;
+			}
+
+		return ___rootmem_alloc_node(nid, align, sidx, size);
+	}
+
+	if (goal) {
+		sidx = ALIGN(min_idx, step);
+		goal = 0;
+		goto restart;
+	}
+
+	return NULL;
+}
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -205,3 +205,6 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config HAVE_ROOTMEM
+	def_bool n
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -7,7 +7,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o 
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o
 
-obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
+obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
@@ -34,3 +34,8 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 
+ifeq ($(CONFIG_HAVE_ROOTMEM),y)
+obj-y += rootmem.o
+else
+obj-y += bootmem.o
+endif
Index: linux-2.6/include/linux/bootmem.h
===================================================================
--- linux-2.6.orig/include/linux/bootmem.h
+++ linux-2.6/include/linux/bootmem.h
@@ -4,6 +4,10 @@
 #ifndef _LINUX_BOOTMEM_H
 #define _LINUX_BOOTMEM_H
 
+#ifdef CONFIG_HAVE_ROOTMEM
+#include <linux/rootmem.h>
+#else
+
 #include <linux/mmzone.h>
 #include <asm/dma.h>
 
@@ -146,5 +150,5 @@ extern void *alloc_large_system_hash(con
 #endif
 extern int hashdist;		/* Distribute hashes across NUMA nodes? */
 
-
+#endif /* !CONFIG_HAVE_ROOTMEM */
 #endif /* _LINUX_BOOTMEM_H */
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -3993,8 +3993,12 @@ void __init set_dma_reserve(unsigned lon
 }
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
+#ifndef CONFIG_HAVE_ROOTMEM
 static bootmem_data_t contig_bootmem_data;
 struct pglist_data contig_page_data = { .bdata = &contig_bootmem_data };
+#else
+struct pglist_data contig_page_data;
+#endif
 
 EXPORT_SYMBOL(contig_page_data);
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
