Message-Id: <20080509152245.833400010@saeurebad.de>
References: <20080509151713.939253437@saeurebad.de>
Date: Fri, 09 May 2008 17:17:15 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH 2/3] mm: bootmem2
Content-Disposition: inline; filename=bootmem2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

A boot time allocator that fundamentally uses a contiguous
memory-block model instead of nodes to fit the reality that nodes are
no contiguous memory providers anymore.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 include/linux/bootmem.h  |    6 
 include/linux/bootmem2.h |  174 ++++++++++++++
 mm/Kconfig               |    3 
 mm/Makefile              |    7 
 mm/bootmem2.c            |  575 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c          |    4 
 6 files changed, 767 insertions(+), 2 deletions(-)

--- /dev/null
+++ b/mm/bootmem2.c
@@ -0,0 +1,575 @@
+/*
+ * bootmem2
+ *
+ * A memory block-oriented boot-time allocator.
+ *
+ * Copyright (C) 2008 Johannes Weiner
+ * Based on the original bootmem allocator, Copyright (C) 1999 Ingo Molnar
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
+unsigned long min_low_pfn, max_low_pfn, max_pfn;
+#ifdef CONFIG_CRASH_DUMP
+unsigned long saved_max_pfn;
+#endif
+
+/*
+ * Nodes hold zero or more contiguous memory blocks.
+ * Two memory blocks on one node must not be subsequent.
+ * Two memory blocks on two nodes might be subsequent.
+ */
+
+struct block {
+	void *map;
+	unsigned long start;
+	unsigned long end;
+	unsigned long last_off;
+	struct list_head list;
+};
+
+static struct block blocks[NR_NODE_MEMBLKS] __initdata;
+
+static struct list_head block_list __initdata = LIST_HEAD_INIT(block_list);
+
+/*
+ * bootmem_bootmap_pages - Calculate bits needed to represent a page range
+ * @pages: number of pages in the range
+ */
+unsigned long __init bootmem_bootmap_pages(unsigned long pages)
+{
+	unsigned long bytes = PAGE_ALIGN((pages + 7) / 8);
+
+	return bytes / PAGE_SIZE;
+}
+
+static unsigned long __init block_map_bytes(struct block *block)
+{
+	unsigned long bytes;
+
+	bytes = (block->end - block->start + 7) / 8;
+	return ALIGN(bytes, sizeof(long));
+}
+
+static void __init link_block(struct block *block)
+{
+	struct list_head *iter;
+
+	list_for_each(iter, &block_list) {
+		struct block *entry = list_entry(iter, struct block, list);
+
+		if (block->start < entry->start)
+			break;
+	}
+
+	list_add_tail(&block->list, iter);
+}
+
+/*
+ * init_bootmem_block - Set up a memory block for use with bootmem
+ * @nid: node the block belongs to
+ * @bnr: block number relative to the node
+ * @mapstart: pfn where the bitmap will be placed at
+ * @start: start of the page range this block holds
+ * @end: end of the page range
+ *
+ * Returns the number of bytes needed for the bitmap of the block.
+ */
+unsigned long __init init_bootmem_block(int nid, int bnr,
+					unsigned long mapstart,
+					unsigned long start, unsigned long end)
+{
+	unsigned long bytes;
+	struct block *block;
+	int bid = nid * NR_MEMBLKS_PER_NODE + bnr;
+
+	block = &blocks[bid];
+	block->map = phys_to_virt(PFN_PHYS(mapstart));
+	block->start = start;
+	block->end = end;
+
+	bytes = block_map_bytes(block);
+	memset(block->map, 0xff, bytes);
+	link_block(block);
+
+	return bytes;
+}
+
+static unsigned long __init free_all_bootmem_block(struct block *block)
+{
+	int aligned;
+	struct page *page;
+	unsigned long start, end, pages, count = 0;
+
+	if (!block->map)
+		return 0;
+
+	start = block->start;
+	end = block->end;
+
+	aligned = !(start & (BITS_PER_LONG - 1));
+
+	while (start < end) {
+		unsigned long *map = block->map;
+		unsigned long vec = ~map[(start - block->start) / BITS_PER_LONG];
+
+		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
+			int order = ilog2(BITS_PER_LONG);
+
+			__free_pages_bootmem(pfn_to_page(start), order);
+			count += BITS_PER_LONG;
+		} else {
+			unsigned long off = 0;
+
+			while (vec && off < BITS_PER_LONG) {
+				if (vec & 1) {
+					page = pfn_to_page(start + off);
+					__free_pages_bootmem(page, 0);
+					count++;
+				}
+				vec >>= 1;
+				off++;
+			}
+		}
+		start += BITS_PER_LONG;
+	}
+
+	page = virt_to_page(block->map);
+	pages = bootmem_bootmap_pages(block->end - block->start);
+	count += pages;
+	while (pages--)
+		__free_pages_bootmem(page++, 0);
+
+	return count;
+}
+
+/*
+ * free_all_bootmem_node - Release node pages to the buddy allocator
+ * @pgdat: node to be released
+ */
+unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
+{
+	int off;
+	unsigned long count = 0;
+	int bid = pgdat->node_id * NR_MEMBLKS_PER_NODE;
+
+	register_page_bootmem_info_node(pgdat);
+
+	for (off = 0; off < NR_MEMBLKS_PER_NODE; off++)
+		count += free_all_bootmem_block(&blocks[bid + off]);
+	return count;
+}
+
+static struct block * __init find_block(unsigned long start, unsigned long end)
+{
+	struct block *block, *first = NULL;
+
+	list_for_each_entry(block, &block_list, list) {
+		if (start >= block->start && start < block->end) {
+			/*
+			 * Extra paranoia:  If this triggers, we have
+			 * overlapping blocks.
+			 */
+			BUG_ON(first && start != block->start);
+
+			if (!first)
+				first = block;
+
+			if (end <= block->end)
+				return first;
+
+			start = block->end;
+		} else {
+			/*
+			 * We found the starting block, but the contiguous
+			 * area starting there is not long enough.
+			 */
+			if (first)
+				break;
+		}
+	}
+
+	return NULL;
+}
+
+static struct block * __init find_node_block(int nid, unsigned long start,
+					unsigned long end)
+{
+	int off;
+
+	for (off = 0; off < NR_MEMBLKS_PER_NODE; off++) {
+		struct block *block;
+		int bid = nid * NR_MEMBLKS_PER_NODE + off;
+
+		block = &blocks[bid];
+		if (start >= block->start && end < block->end)
+			return block;
+	}
+
+	return NULL;
+}
+
+static void __init __free(void *map, unsigned long start, unsigned long end)
+{
+	unsigned long idx;
+
+	for (idx = start; idx < end; idx++)
+		if (!test_and_clear_bit(idx, map))
+			BUG();
+}
+
+static int __init __reserve(void *map, unsigned long start,
+			unsigned long end, int flags)
+{
+	unsigned long idx;
+	int exclusive = flags; /* XXX */
+
+	for (idx = start; idx < end; idx++)
+		if (test_and_set_bit(idx, map)) {
+			if (exclusive) {
+				__free(map, start, idx);
+				return -EBUSY;
+			}
+		}
+	return 0;
+}
+
+static void __init free_range(struct block *block, unsigned long start,
+			unsigned long end)
+{
+	__free(block->map, start - block->start, end - block->start);
+}
+
+static int __init reserve_range(struct block *block, unsigned long start,
+			unsigned long end, int flags)
+{
+	return __reserve(block->map, start - block->start,
+			end - block->start, flags);
+}
+
+static int __init mark_bootmem(int nid, unsigned long start,
+			unsigned long end, int reserve, int flags)
+{
+	struct block *block;
+	unsigned long pos = start;
+
+	if (nid == -1)
+		block = find_block(start, end);
+	else
+		block = find_node_block(nid, start, end);
+
+	BUG_ON(!block);
+
+	list_for_each_entry_from(block, &block_list, list) {
+		unsigned long max = min_t(unsigned long, end, block->end);
+
+		if (reserve) {
+			int ret = reserve_range(block, pos, max, flags);
+
+			if (ret < 0) {
+				mark_bootmem(nid, start, pos, 0, 0);
+				return ret;
+			}
+		} else
+			free_range(block, pos, max);
+
+		if (max == end)
+			break;
+
+		pos = block->end;
+	}
+
+	return 0;
+}
+
+static void __init __free_bootmem_node(int nid, unsigned long addr,
+			unsigned long size)
+{
+	unsigned long start = PFN_UP(addr);
+	unsigned long end = PFN_DOWN(addr + size);
+
+	mark_bootmem(nid, start, end, 0, 0);
+}
+
+/*
+ * free_bootmem_node - free a page range
+ * @pgdat: node the pages reside on
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ */
+void __init free_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+			unsigned long size)
+{
+	__free_bootmem_node(pgdat->node_id, addr, size);
+}
+
+/*
+ * free_bootmem - free a page range
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ */
+void __init free_bootmem(unsigned long addr, unsigned long size)
+{
+	__free_bootmem_node(-1, addr, size);
+}
+
+static int __init __reserve_bootmem_node(int nid, unsigned long addr,
+					unsigned long size, int flags)
+{
+	unsigned long start = PFN_DOWN(addr);
+	unsigned long end = PFN_UP(addr + size);
+
+	return mark_bootmem(nid, start, end, 1, flags);
+}
+
+/*
+ * reserve_bootmem_node - reserve a page range
+ * @pgdat: node the pages reside on
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ * @flags: reservation behaviour
+ *
+ * The reservation will fail and return -EBUSY if flags & BOOTMEM_EXCLUSIVE
+ * and pages of the range are already reserved.
+ */
+int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+				unsigned long size, int flags)
+{
+	return __reserve_bootmem_node(pgdat->node_id, addr, size, flags);
+}
+
+/*
+ * reserve_bootmem_node - reserve a page range
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ * @flags: reservation behaviour
+ *
+ * The reservation will fail and return -EBUSY if flags & BOOTMEM_EXCLUSIVE
+ * and pages of the range are already reserved.
+ */
+int __init __reserve_bootmem(unsigned long addr, unsigned long size, int flags)
+{
+	return __reserve_bootmem_node(-1, addr, size, flags);
+}
+
+static void * __init ___alloc_bootmem_block(struct block *block,
+				unsigned long align, unsigned long start,
+				unsigned long bytes)
+{
+	int merge;
+	void *region;
+	unsigned long new_start, new_end;
+
+	if (block->last_off && PFN_DOWN(block->last_off) + 1 == start)
+		new_start = ALIGN(block->last_off, align);
+	else
+		new_start = PFN_PHYS(start);
+
+	merge = PFN_DOWN(new_start) < start;
+
+	new_end = new_start + bytes;
+	block->last_off = new_end;
+
+	if (__reserve(block->map, PFN_DOWN(new_start) + merge,
+			PFN_UP(new_end), 1))
+		BUG();
+
+	region = phys_to_virt(PFN_PHYS(block->start) + new_start);
+	memset(region, 0, bytes);
+	return region;
+}
+
+static void * __init __alloc_bootmem_block(struct block *block,
+				unsigned long size, unsigned long align,
+				unsigned long goal, unsigned long limit)
+{
+	unsigned long min, max, start, step;
+
+	BUG_ON(!block->map);
+
+	min = block->start;
+	max = block->end;
+
+	BUG_ON(align & (align - 1));
+	BUG_ON(limit && goal + size > limit);
+
+	goal >>= PAGE_SHIFT;
+	limit >>= PAGE_SHIFT;
+
+	if (limit && max > limit)
+		max = limit;
+
+	if (!(max - min))
+		return NULL;
+
+	step = max_t(unsigned long, align >> PAGE_SHIFT, 1);
+
+	if (goal && goal < max)
+		start = ALIGN(goal, step);
+	else
+		start = ALIGN(min, step);
+
+	min -= block->start;
+	max -= block->start;
+	start -= block->start;
+
+	while (1) {
+		unsigned long end, i;
+
+		start = find_next_zero_bit(block->map, max, start);
+		start = ALIGN(start, step);
+		end = start + PFN_UP(size);
+
+		if (start > max || end > max)
+			break;
+
+		for (i = start; i < end; i++)
+			if (test_bit(i, block->map)) {
+				start = ALIGN(i, step);
+				if (start == i)
+					start += step;
+				continue;
+			}
+
+		return ___alloc_bootmem_block(block, align, start, size);
+	}
+
+	return NULL;
+}
+
+static void * __init alloc_bootmem_blocks(int start_bid, int nr_blocks,
+				unsigned long size, unsigned long align,
+				unsigned long goal, unsigned long limit)
+{
+	int off;
+	unsigned long pref = PFN_DOWN(goal);
+
+	for (off = 0; off < nr_blocks; off++) {
+		struct block *block;
+		int bid = start_bid + off;
+
+		block = &blocks[bid];
+		if (!block->map)
+			continue;
+
+		if (!goal || (pref >= block->start && pref < block->end)) {
+			void *region = __alloc_bootmem_block(block, size,
+							align, goal, limit);
+
+			if (region)
+				return region;
+
+			if (goal) {
+				goal = 0;
+				off = -1;
+			}
+		}
+	}
+
+	return NULL;
+}
+
+static void * __init ___alloc_bootmem_node(int nid, unsigned long size,
+				unsigned long align, unsigned long goal,
+				unsigned long limit)
+{
+	int nr_blocks = NR_MEMBLKS_PER_NODE;
+	int start_bid = nid * NR_MEMBLKS_PER_NODE;
+
+	return alloc_bootmem_blocks(start_bid, nr_blocks,
+				size, align, goal, limit);
+}
+
+/*
+ * __alloc_bootmem_node - allocate boot memory
+ * @pgdat: node to allocate from
+ * @size: size of the region
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ */
+void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				unsigned long align, unsigned long goal)
+{
+	return ___alloc_bootmem_node(pgdat->node_id, size, align, goal, 0);
+}
+
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT 0xffffffffUL
+#endif
+
+/*
+ * __alloc_bootmem_low_node - allocate low boot memory
+ * @pgdat: node to allocate from
+ * @size: size of the region
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ */
+void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
+				unsigned long align, unsigned long goal)
+{
+	return ___alloc_bootmem_node(pgdat->node_id, size,
+				align, goal, ARCH_LOW_ADDRESS_LIMIT);
+}
+
+/*
+ * __alloc_bootmem - allocate boot memory
+ * @size: size of the region
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ */
+void * __init __alloc_bootmem(unsigned long size, unsigned long align,
+			unsigned long goal)
+{
+	return alloc_bootmem_blocks(0, NR_NODE_MEMBLKS, size, align, goal, 0);
+}
+
+/*
+ * __alloc_bootmem_low - allocate low boot memory
+ * @size: size of the region
+ * @align: alignment of the region
+ * @goal: preferred starting address of the region
+ */
+void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
+				unsigned long goal)
+{
+	return alloc_bootmem_blocks(0, NR_NODE_MEMBLKS, size,
+				align, goal, ARCH_LOW_ADDRESS_LIMIT);
+}
+
+#ifdef CONFIG_SPARSEMEM
+void * __init alloc_bootmem_section(unsigned long size,
+				unsigned long section_nr)
+{
+	void *region;
+	unsigned long goal, limit, start, end;
+
+	start = section_nr_to_pfn(section_nr);
+	goal = PFN_PHYS(start);
+	limit = PFN_PHYS(section_nr_to_pfn(section_nr + 1));
+	nid = early_pfn_to_nid(start);
+
+	region = ___alloc_bootmem_node(nid, size, SMP_CACHE_BYTES,
+				goal, limit);
+	if (!region)
+		return NULL;
+
+	start = pfn_to_section_nr(PFN_DOWN(__pa(region)));
+	end = pfn_to_section_nr(PFN_DOWN(__pa(region) + size));
+	if (start != section_nr || end != section_nr) {
+		printk(KERN_WARNING "alloc_bootmem failed on section %ld.\n",
+			section_nr);
+		__free_bootmem_node(nid, __pa(region), size);
+		region = NULL;
+	}
+
+	return region;
+}
+#endif
--- /dev/null
+++ b/include/linux/bootmem2.h
@@ -0,0 +1,174 @@
+#ifndef _LINUX_BOOTMEM2_H
+#define _LINUX_BOOTMEM2_H
+
+#include <linux/mmzone.h>
+#include <asm/dma.h>
+
+extern unsigned long min_low_pfn;
+extern unsigned long max_low_pfn;
+
+extern unsigned long max_pfn;
+
+#ifdef CONFIG_CRASH_DUMP
+extern unsigned long saved_max_pfn;
+#endif
+
+/* Reservation flags */
+#define BOOTMEM_DEFAULT		0
+#define BOOTMEM_EXCLUSIVE	1
+
+extern unsigned long bootmem_bootmap_pages(unsigned long pages);
+
+/*
+ * Block interface
+ */
+
+extern unsigned long init_bootmem_block(int nid, int bnr,
+					unsigned long mapstart,
+					unsigned long start, unsigned long end);
+
+/*
+ * Node interface
+ */
+
+/*
+ * init_bootmem_node - Set up a memory node for use with bootmem
+ * @pgdat: node to register
+ * @mapstart: pfn where the bitmap will be placed at
+ * @start: start of the page range this node holds
+ * @end: end of the page range
+ *
+ * Note: This interface does only work on configurations with one
+ * block per node!
+ */
+static inline unsigned long init_bootmem_node(pg_data_t *pgdat,
+					unsigned long mapstart,
+					unsigned long start, unsigned long end)
+{
+#if NR_MEMBLKS_PER_NODE > 1
+	extern void ___multiple_blocks_per_node(void);
+	___multiple_blocks_per_node();
+#endif
+	return init_bootmem_block(pgdat->node_id, 0, mapstart, start, end);
+}
+
+extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
+
+extern void free_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+			unsigned long size);
+
+extern int reserve_bootmem_node(pg_data_t *pgdat, unsigned long addr,
+			unsigned long size, int flags);
+
+extern void *__alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				unsigned long align, unsigned long goal);
+
+extern void *__alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
+				unsigned long align, unsigned long goal);
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+#define alloc_bootmem_node(pgdat, size)				\
+	__alloc_bootmem_node(pgdat, size, SMP_CACHE_BYTES,	\
+			__pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_pages_node(pgdat, size)			\
+	__alloc_bootmem_node(pgdat, size, PAGE_SIZE,		\
+			__pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages_node(pgdat, size)		\
+	__alloc_bootmem_low_node(pgdat, size, PAGE_SIZE, 0)
+#endif
+
+/*
+ * Single-node systems only
+ */
+
+/*
+ * init_bootmem - Initialize bootmem on a single-node system
+ * @start: first usable pfn in the system
+ * @pages: number of pages available
+ */
+static inline unsigned long init_bootmem(unsigned long start,
+					unsigned long pages)
+{
+	min_low_pfn = start;
+	max_low_pfn = pages;
+	return init_bootmem_node(NODE_DATA(0), start, 0, pages);
+}
+
+/*
+ * free_all_bootmem - Release all memory to the buddy allocator
+ */
+static inline unsigned long free_all_bootmem(void)
+{
+	return free_all_bootmem_node(NODE_DATA(0));
+}
+
+/*
+ * Node agnostic
+ */
+
+extern void free_bootmem(unsigned long addr, unsigned long size);
+
+extern int __reserve_bootmem(unsigned long addr, unsigned long size,
+			int flags);
+
+extern void *__alloc_bootmem(unsigned long size, unsigned long align,
+			unsigned long goal);
+
+extern void *__alloc_bootmem_low(unsigned long size, unsigned long align,
+				unsigned long goal);
+
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+#define reserve_bootmem __reserve_bootmem
+#define alloc_bootmem(size)						\
+	__alloc_bootmem(size, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_pages(size)					\
+	__alloc_bootmem(size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low(size)						\
+	__alloc_bootmem_low(size, SMP_CACHE_BYTES, 0)
+#define alloc_bootmem_low_pages(size)					\
+	__alloc_bootmem_low(size, PAGE_SIZE, 0)
+#endif
+
+#ifdef CONFIG_SPARSEMEM
+extern void *alloc_bootmem_section(unsigned long size,
+				unsigned long section_nr);
+#endif
+
+/*
+ * XXX: Does this really belong here?
+ */
+
+#ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
+extern void *alloc_remap(int nid, unsigned long size);
+#else
+static inline void *alloc_remap(int nid, unsigned long size)
+{
+        return NULL;
+}
+#endif /* CONFIG_HAVE_ARCH_ALLOC_REMAP */
+
+extern unsigned long __meminitdata nr_kernel_pages;
+extern unsigned long __meminitdata nr_all_pages;
+
+extern void *alloc_large_system_hash(const char *tablename,
+				     unsigned long bucketsize,
+				     unsigned long numentries,
+				     int scale,
+				     int flags,
+				     unsigned int *_hash_shift,
+				     unsigned int *_hash_mask,
+				     unsigned long limit);
+
+#define HASH_EARLY	0x00000001	/* Allocating during early boot? */
+
+/* Only NUMA needs hash distribution.
+ * IA64 and x86_64 have sufficient vmalloc space.
+ */
+#if defined(CONFIG_NUMA) && (defined(CONFIG_IA64) || defined(CONFIG_X86_64))
+#define HASHDIST_DEFAULT 1
+#else
+#define HASHDIST_DEFAULT 0
+#endif
+extern int hashdist;		/* Distribute hashes across NUMA nodes? */
+
+#endif /* _LINUX_BOOTMEM2_H */
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
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
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -143,6 +143,9 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config HAVE_BOOTMEM2
+	def_bool n
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.
--- a/mm/Makefile
+++ b/mm/Makefile
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
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
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
