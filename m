Message-Id: <20080505100846.526196633@symbol.fehenstaub.lan>
References: <20080505095938.326928514@symbol.fehenstaub.lan>
Date: Mon, 05 May 2008 11:59:40 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [rfc][patch 2/3] mm: bootmem2 - memory block oriented boot time allocator
Content-Disposition: inline; filename=bootmem2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

A boot time allocator that uses a bitmap for all pages in the system,
merges subsequent partial-page allocations, and uses a memory block
model instead of nodes to fit the reality that nodes are no contiguous
memory holders anymore.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

Index: linux-2.6/include/linux/bootmem2.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/bootmem2.h
@@ -0,0 +1,207 @@
+#ifndef _LINUX_BOOTMEM2_H
+#define _LINUX_BOOTMEM2_H
+
+#include <linux/mmzone.h>
+#include <asm/dma.h>
+
+extern void bootmem_register_block(int bid, unsigned long start,
+				unsigned long end);
+
+extern unsigned long bootmem_map_pages(void);
+
+extern void bootmem_setup(unsigned long mapstart);
+
+extern unsigned long bootmem_release_block(int bid);
+
+extern void bootmem_free(unsigned long addr, unsigned long size);
+extern int bootmem_reserve(unsigned long addr, unsigned long size,
+			int exclusive);
+
+extern void *bootmem_alloc_block(int bid, unsigned long size,
+				unsigned long align, unsigned long goal,
+				unsigned long limit);
+
+/*
+ * Multiple nodes
+ */
+
+static inline int bootmem_node_block(int nid)
+{
+	if (nid == -1)
+		return nid;
+	return nid * NR_MEMBLKS_PER_NODE;
+}
+
+static inline int bootmem_block_node(int bid)
+{
+	return bid / NR_MEMBLKS_PER_NODE;
+}
+
+static inline void bootmem_register_node(int nid, unsigned long start,
+					unsigned long end)
+{
+#if NR_MEMBLKS_PER_NODE > 1
+	extern void __multiple_memblocks_per_node(void);
+	__multiple_memblocks_per_node();
+#endif
+	return bootmem_register_block(nid, start, end);
+}
+
+extern unsigned long bootmem_release_node(int nid);
+
+extern void *bootmem_alloc_node(int nid, unsigned long size,
+				unsigned long align, unsigned long goal,
+				unsigned long limit);
+
+extern void *bootmem_alloc_low_node(int nid, unsigned long size,
+				unsigned long align, unsigned long goal);
+
+
+#ifdef CONFIG_SPARSEMEM
+extern void *bootmem_alloc_section(unsigned long size, unsigned long sec_nr);
+#endif
+
+/*
+ * Single node
+ */
+
+static inline void bootmem_register(unsigned long start, unsigned long end)
+{
+	bootmem_register_node(0, start, end);
+}
+static inline unsigned long bootmem_release(void)
+{
+	return bootmem_release_node(0);
+}
+
+/*
+ * Node agnostic
+ */
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+static inline void *bootmem_alloc(unsigned long size)
+{
+	return bootmem_alloc_node(-1, size, SMP_CACHE_BYTES,
+				__pa(MAX_DMA_ADDRESS), 0);
+}
+static inline void *bootmem_alloc_low(unsigned long size)
+{
+	return bootmem_alloc_low_node(-1, size, SMP_CACHE_BYTES, 0);
+}
+static inline void *bootmem_alloc_pages(unsigned long size)
+{
+	return bootmem_alloc_node(-1, size, PAGE_SIZE,
+				__pa(MAX_DMA_ADDRESS), 0);
+}
+static inline void *bootmem_alloc_low_pages(unsigned long size)
+{
+	return bootmem_alloc_low_node(-1, size, PAGE_SIZE, 0);
+}
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
+static inline unsigned long bootmem_bootmap_pages(unsigned long pages)
+{
+	return bootmem_map_pages();
+}
+static inline void free_bootmem(unsigned long addr, unsigned long size)
+{
+	bootmem_free(addr, size);
+}
+static inline void free_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+				unsigned long size)
+{
+	bootmem_free(addr, size);
+}
+static inline int reserve_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+				unsigned long size, int flags)
+{
+	return bootmem_reserve(addr, size, flags & BOOTMEM_EXCLUSIVE);
+}
+static inline void *__alloc_bootmem_low(unsigned long size, unsigned long align,
+					unsigned long goal)
+{
+	return bootmem_alloc_low_node(-1, size, align, goal);
+}
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+static inline int reserve_bootmem(unsigned long addr, unsigned long size,
+				int flags)
+{
+	return bootmem_reserve(addr, size, flags & BOOTMEM_EXCLUSIVE);
+}
+static inline void *alloc_bootmem(unsigned long size)
+{
+	return bootmem_alloc(size);
+}
+static inline void *alloc_bootmem_low(unsigned long size)
+{
+	return bootmem_alloc_low(size);
+}
+static inline void *alloc_bootmem_pages(unsigned long nr)
+{
+	return bootmem_alloc_pages(nr);
+}
+static inline void *alloc_bootmem_low_pages(unsigned long nr)
+{
+	return bootmem_alloc_low_pages(nr);
+}
+static inline void *alloc_bootmem_node(pg_data_t *pgdat, unsigned long size)
+{
+	return bootmem_alloc_node(pgdat->node_id, size, SMP_CACHE_BYTES,
+				__pa(MAX_DMA_ADDRESS), 0);
+}
+static inline void *alloc_bootmem_pages_node(pg_data_t *pgdat,
+						unsigned long size)
+{
+	return bootmem_alloc_node(pgdat->node_id, size, PAGE_SIZE,
+				__pa(MAX_DMA_ADDRESS), 0);
+}
+static inline void *alloc_bootmem_low_pages_node(pg_data_t *pgdat,
+						unsigned long size)
+{
+	return bootmem_alloc_low_node(pgdat->node_id, size, PAGE_SIZE, 0);
+}
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
+#endif /* _LINUX_BOOTMEM2_H */
Index: linux-2.6/mm/bootmem2.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/bootmem2.c
@@ -0,0 +1,539 @@
+/*
+ * bootmem2
+ *
+ * A memory block oriented boot-time allocator.
+ *
+ * Copyright (C) 2008 Johannes Weiner
+ * Based on the original bootmem allocator, (C) 1999 Ingo Molnar
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/pfn.h>
+#include <linux/io.h>
+
+#include <linux/bootmem2.h>
+
+#include "internal.h"
+
+/******** bootmem legacy */
+unsigned long min_low_pfn, max_low_pfn, max_pfn;
+#ifdef CONFIG_CRASH_DUMP
+unsigned long saved_max_pfn;
+#endif
+/******** !bootmem legacy */
+
+/* Global memory state */
+static void *bootmem_map __initdata;
+static unsigned long bootmem_min_pfn __initdata = ~0UL;
+static unsigned long bootmem_max_pfn __initdata;
+
+/* Allocator state */
+static int bootmem_functional __initdata;
+
+/* Registered memory blocks */
+static int bootmem_nr_blocks __initdata;
+
+/* Block sizes */
+static unsigned long bootmem_block_pages[NR_NODE_MEMBLKS] __initdata;
+
+/* Block offsets within bootmem_map */
+static unsigned long bootmem_block_offsets[NR_NODE_MEMBLKS] __initdata;
+
+/* Last allocation ending address on each block */
+static unsigned long bootmem_block_last[NR_NODE_MEMBLKS] __initdata;
+
+/*
+ * bootmem_register_block - register a memory block to bootmem
+ * @nid: id of the memory block
+ * @start: first pfn on the block
+ * @end: first pfn after the block
+ *
+ * This function must not be called anymore if the allocator
+ * is already up and running (bootmem_setup() has been called).
+ */
+void __init bootmem_register_block(int bid, unsigned long start,
+				unsigned long end)
+{
+	BUG_ON(bootmem_functional);
+
+	if (start < bootmem_min_pfn)
+		bootmem_min_pfn = start;
+	if (end > bootmem_max_pfn)
+		bootmem_max_pfn = end;
+
+	bootmem_block_offsets[bid] = start;
+	bootmem_block_pages[bid] = end - start;
+	bootmem_nr_blocks++;
+}
+
+static unsigned long __init bootmem_map_bytes(void)
+{
+	unsigned long bytes;
+
+	bytes = (bootmem_max_pfn - bootmem_min_pfn + 7) / 8;
+
+	/*
+	 * The alignment is needed to operate on
+	 * full wordsize vectors in bootmem_release_block().
+	 */
+	return ALIGN(bytes, sizeof(long));
+}
+
+/*
+ * bootmem_map_pages - pages needed to hold the bitmap
+ */
+unsigned long __init bootmem_map_pages(void)
+{
+	unsigned long bytes;
+
+	bytes = PAGE_ALIGN(bootmem_map_bytes());
+	return bytes / PAGE_SIZE;
+}
+
+/*
+ * bootmem_setup - activate the bootmem allocator
+ * @map: pfn where bitmap should be placed
+ *
+ * The bitmap must be at least bootmem_map_pages() big.
+ *
+ * After a call to this function, the bootmem allocator
+ * is enabled and no further blocks must be registered.
+ */
+void __init bootmem_setup(unsigned long mapstart)
+{
+	bootmem_map = phys_to_virt(PFN_PHYS(mapstart));
+	memset(bootmem_map, 0xff, bootmem_map_bytes());
+	bootmem_functional = 1;
+
+	printk(KERN_INFO "bootmem: %lu pages on %d block(s) - map @ pfn %lx\n",
+		bootmem_max_pfn - bootmem_min_pfn, bootmem_nr_blocks,
+		mapstart);
+
+	/* XXX: bootmem legacy */
+	min_low_pfn = mapstart;
+	max_low_pfn = bootmem_max_pfn;
+}
+
+/*
+ * bootmem_release_block - release a memory block from the allocator
+ * @bid: id of the block to be released
+ *
+ * All unreserved memory of the block @bid will be released
+ * to the buddy allocator.  If it was the last block registered
+ * to bootmem, the bitmap will be released too.
+ *
+ * After a call to this function, the bootmem allocator is
+ * disabled.
+ *
+ * The number of released pages is returned.
+ *
+ */
+unsigned long __init bootmem_release_block(int bid)
+{
+	int aligned;
+	unsigned long start, end, count = 0;
+
+	/* XXX */
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+#ifndef CONFIG_SPARSEMEM_VMEMMAP
+	/* register_page_bootmem_info_node() */
+#error beat me
+#endif
+#endif
+
+	bootmem_functional = 0;
+	BUG_ON(!bootmem_nr_blocks);
+
+	start = bootmem_block_offsets[bid];
+	end = start + bootmem_block_pages[bid];
+
+	/*
+	 * If the starting pfn is aligned to the machines
+	 * wordsize, we might be able to release pages in
+	 * orders of that size.
+	 */
+	aligned = !(start & (BITS_PER_LONG - 1));
+
+	while (start < end) {
+		unsigned long pfn = start;
+		unsigned long *map = bootmem_map;
+		unsigned long vec = ~map[start / BITS_PER_LONG];
+
+		/*
+		 * Release wordsize pages at once to the buddy allocator
+		 * if we are properly aligned, the full vector is
+		 * unreserved and the block would not go beyond the end
+		 * of this block's memory.
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
+	/* This was the last block, drop the bitmap too */
+	if (!--bootmem_nr_blocks) {
+		unsigned long pages = bootmem_map_pages();
+		struct page *page = virt_to_page(bootmem_map);
+
+		count += pages;
+		while (pages--)
+			__free_pages_bootmem(page++, 0);
+	}
+
+	printk(KERN_INFO "bootmem: %lu pages released on block %i\n",
+		count, bid);
+
+	return count;
+}
+
+/*
+ * bootmem_release_node - release a node from the allocator
+ * @nid: id of the node to be released
+ *
+ * All unreserved memory of the node @nid will be released
+ * to the buddy allocator.  If it was the last node registered
+ * to bootmem, the bitmap will be released too.
+ *
+ * After a call to this function, the bootmem allocator is
+ * disabled.
+ *
+ * The number of released pages is returned.
+ */
+unsigned long __init bootmem_release_node(int nid)
+{
+	int i;
+	unsigned long count = 0;
+
+	for (i = 0; i < NR_MEMBLKS_PER_NODE; i++) {
+		int bid = bootmem_node_block(nid) + i;
+
+		count += bootmem_release_block(bid);
+	}
+
+	return count;
+}
+
+static void __init check_bootmem_parms(unsigned long start, unsigned long end)
+{
+	BUG_ON(!bootmem_functional);
+
+	if (start < bootmem_min_pfn || end > bootmem_max_pfn) {
+		printk(KERN_ERR "bootmem request out of range: %lx-%lx, "
+			"usable: %lx-%lx\n", start, end, bootmem_min_pfn,
+			bootmem_max_pfn);
+		BUG();
+	}
+}
+
+static void __init __bootmem_free(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+
+	check_bootmem_parms(start, end);
+	for (pfn = start; pfn < end; pfn++)
+		if (!test_and_clear_bit(pfn, bootmem_map)) {
+			printk(KERN_ERR "bootmem: double free of pfn %lx\n",
+				pfn);
+			BUG();
+		}
+}
+
+static int __init __bootmem_reserve(unsigned long start, unsigned long end,
+				int exclusive)
+{
+	unsigned long pfn;
+
+	check_bootmem_parms(start, end);
+	for (pfn = start; pfn < end; pfn++)
+		if (test_and_set_bit(pfn, bootmem_map))
+			if (exclusive) {
+				__bootmem_free(start, pfn);
+				return -EBUSY;
+			}
+
+	return 0;
+}
+
+/*
+ * bootmem_free - mark a memory region as free
+ * @addr: starting address
+ * @size: size of region in bytes
+ *
+ * Only pages completely within the bounds of the region
+ * are marked free.
+ */
+void __init bootmem_free(unsigned long addr, unsigned long size)
+{
+	unsigned long start, end;
+
+	start = PFN_UP(addr);
+	end = PFN_DOWN(addr + size);
+	__bootmem_free(start, end);
+}
+
+/*
+ * bootmem_reserve - mark a memory region as reserved
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
+int __init bootmem_reserve(unsigned long addr, unsigned long size,
+			int exclusive)
+{
+	unsigned long start, end;
+
+	start = PFN_DOWN(addr);
+	end = PFN_UP(addr + size);
+	return __bootmem_reserve(start, end, exclusive);
+}
+
+static void * __init __bootmem_alloc_block(int bid, int align,
+				unsigned long start_pfn, unsigned long bytes)
+{
+	void *region;
+	int merge = 0;
+	unsigned long last_end, last_pfn, new_start, new_end;
+
+	/* XXX: Find a more appropriate slot */
+	if (bid == -1)
+		bid = 0;
+
+	/*
+	 * If the allocation is subsequent to a prior allocation that did not
+	 * use all of its last page, the new block might use it or even fit
+	 * completely into it.
+	 */
+	last_end = bootmem_block_last[bid];
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
+	bootmem_block_last[bid] = new_end;
+
+	/*
+	 * Since we checked the area in advance, a failed reservation
+	 * is clearly a BUG.
+	 */
+	if (__bootmem_reserve(PFN_DOWN(new_start) + merge, PFN_UP(new_end), 1))
+		BUG();
+
+	region = phys_to_virt(new_start);
+	memset(region, 0, bytes);
+	return region;
+}
+
+/*
+ * bootmem_alloc_block - allocate a memory region
+ * @bid: memory block to allocate from
+ * @size: size of the region in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ * @limit: first address after the region
+ */
+void * __init bootmem_alloc_block(int bid, unsigned long size,
+				unsigned long align, unsigned long goal,
+				unsigned long limit)
+{
+	unsigned long min_idx, max_idx, sidx, step;
+
+	/*
+	 * If a block was specified, crossing its boundaries is
+	 * not allowed.  Otherwise we are agnostic to block
+	 * sizes and work with the whole range of pages available.
+	 */
+	if (bid == -1) {
+		min_idx = bootmem_min_pfn;
+		max_idx = bootmem_max_pfn;
+	} else {
+		min_idx = bootmem_block_offsets[bid];
+		max_idx = min_idx + bootmem_block_pages[bid];
+	}
+
+	BUG_ON(align & (align - 1));
+	BUG_ON(limit && goal + size > limit);
+
+	if (limit && max_idx > limit)
+		max_idx = limit;
+
+	if (!(max_idx - min_idx))
+		return NULL;
+
+	goal >>= PAGE_SHIFT;
+	limit >>= PAGE_SHIFT;
+
+	/*
+	 * We walk the bitmap in page steps, so align does only have an
+	 * impact for the block searching if it's bigger than the
+	 * page size.  It must be preserved, however, for the allocation
+	 * merging at a finer granularity than whole pages.
+	 */
+	step = max_t(unsigned long, align >> PAGE_SHIFT, 1);
+
+	if (goal && goal < max_idx)
+		sidx = ALIGN(goal, step);
+	else
+		sidx = ALIGN(min_idx, step);
+
+restart:
+	while (1) {
+		unsigned long eidx, idx;
+
+		sidx = find_next_zero_bit(bootmem_map, max_idx, sidx);
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
+			if (test_bit(idx, bootmem_map)) {
+				sidx = ALIGN(idx, step);
+				if (sidx == idx)
+					sidx += step;
+				continue;
+			}
+
+		return __bootmem_alloc_block(bid, align, sidx, size);
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
+
+/*
+ * bootmem_alloc_node - allocate a memory region
+ * @nid: id of the node to allocate from
+ * @size: size of the region in bytes
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ * @limit: first address after the region
+ */
+void * __init bootmem_alloc_node(int nid, unsigned long size,
+				unsigned long align, unsigned long goal,
+				unsigned long limit)
+{
+	int i, goal_block;
+	unsigned long goal_pfn;
+
+	if (nid == -1)
+		return bootmem_alloc_block(nid, size, align, goal, limit);
+
+	/*
+	 * Find a block on the requested node that is able to
+	 * satisfy the goal.  Fall back if it's impossible.
+	 */
+	goal_block = -1;
+	goal_pfn = PFN_DOWN(goal);
+
+	for (i = 0; i < NR_MEMBLKS_PER_NODE; i++) {
+		int bid = bootmem_node_block(nid) + i;
+		unsigned long start = bootmem_block_offsets[bid];
+		unsigned long end = start + bootmem_block_pages[bid];
+
+		if (!(end - start))
+			continue;
+
+		if (goal_pfn >= start && goal_pfn < end) {
+			goal_block = i;
+			break;
+		}
+	}
+
+	if (goal_block == -1)
+		goal = goal_block = 0;
+
+	for (i = goal_block; i < NR_MEMBLKS_PER_NODE; i++) {
+		void *region;
+		int bid = bootmem_node_block(nid) + i;
+
+		region = bootmem_alloc_block(bid, size, align, goal, limit);
+		if (region)
+			return region;
+	}
+
+	return NULL;
+}
+
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
+#endif
+
+void * __init bootmem_alloc_low_node(int nid, unsigned long size,
+				unsigned long align, unsigned long goal)
+{
+	return bootmem_alloc_node(nid, size, align, goal,
+				ARCH_LOW_ADDRESS_LIMIT);
+}
+
+#ifdef CONFIG_SPARSEMEM
+void * __init bootmem_alloc_section(unsigned long size, unsigned long sec_nr)
+{
+	int nid;
+	void *region;
+	unsigned long goal, limit, start, end;
+
+	start = section_nr_to_pfn(sec_nr);
+	goal = PFN_PHYS(start);
+	limit = PFN_PHYS(section_nr_to_pfn(sec_nr + 1));
+	nid = early_pfn_to_nid(start);
+
+	region = bootmem_alloc_node(nid, size, SMP_CACHE_BYTES, goal, limit);
+	if (!region)
+		return NULL;
+
+	start = pfn_to_section_nr(PFN_DOWN(__pa(region)));
+	end = pfn_to_section_nr(PFN_DOWN(__pa(region) + size));
+	if (start != sec_nr || end != sec_nr) {
+		printk(KERN_WARNING "bootmem_alloc_section(%lu, %lu)\n",
+			section_nr);
+		bootmem_free(__pa(region), size);
+		region = NULL;
+	}
+
+	return region;
+}
+#endif
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -205,3 +205,6 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config HAVE_BOOTMEM2
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
 
+ifeq ($(CONFIG_HAVE_BOOTMEM2),y)
+obj-y += bootmem2.o
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
 
+#ifdef CONFIG_HAVE_BOOTMEM2
+#include <linux/bootmem2.h>
+#else
+
 #include <linux/mmzone.h>
 #include <asm/dma.h>
 
@@ -146,5 +150,5 @@ extern void *alloc_large_system_hash(con
 #endif
 extern int hashdist;		/* Distribute hashes across NUMA nodes? */
 
-
+#endif /* !CONFIG_HAVE_BOOTMEM2 */
 #endif /* _LINUX_BOOTMEM_H */
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -3993,8 +3993,12 @@ void __init set_dma_reserve(unsigned lon
 }
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
+#ifndef CONFIG_HAVE_BOOTMEM2
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
