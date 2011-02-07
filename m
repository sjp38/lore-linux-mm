Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 516A18D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 10:30:26 -0500 (EST)
Received: by yia25 with SMTP id 25so1929531yia.14
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 07:30:21 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [RFC] Split up mm/bootmem.c
Date: Tue,  8 Feb 2011 00:30:14 +0900
Message-Id: <1297092614-1906-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

The bootmem code contained many #ifdefs in it so that it could be
splitted into two files for the readability. The split was quite
mechanical and only function need to be shared was free_bootmem_late.

Tested on x86-64 and um which use nobootmem and bootmem respectively.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/Makefile    |    8 +-
 mm/bootmem.c   |  164 +--------------------
 mm/nobootmem.c |  445 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 454 insertions(+), 163 deletions(-)
 create mode 100644 mm/nobootmem.c

diff --git a/mm/Makefile b/mm/Makefile
index 2b1b575ae712..e9a074dbad15 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -7,7 +7,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
-obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
+obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
@@ -15,6 +15,12 @@ obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   $(mmu-y)
 obj-y += init-mm.o
 
+ifeq ($(CONFIG_NO_BOOTMEM),y)
+obj-y += nobootmem.o
+else
+obj-y += bootmem.o
+endif
+
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 13b0caa9793c..209be265ad94 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -35,7 +35,6 @@ unsigned long max_pfn;
 unsigned long saved_max_pfn;
 #endif
 
-#ifndef CONFIG_NO_BOOTMEM
 bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
 
 static struct list_head bdata_list __initdata = LIST_HEAD_INIT(bdata_list);
@@ -146,8 +145,8 @@ unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 	min_low_pfn = start;
 	return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
 }
-#endif
-/*
+
+/**
  * free_bootmem_late - free bootmem pages directly to page allocator
  * @addr: starting address of the range
  * @size: size of the range in bytes
@@ -171,53 +170,6 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 	}
 }
 
-#ifdef CONFIG_NO_BOOTMEM
-static void __init __free_pages_memory(unsigned long start, unsigned long end)
-{
-	int i;
-	unsigned long start_aligned, end_aligned;
-	int order = ilog2(BITS_PER_LONG);
-
-	start_aligned = (start + (BITS_PER_LONG - 1)) & ~(BITS_PER_LONG - 1);
-	end_aligned = end & ~(BITS_PER_LONG - 1);
-
-	if (end_aligned <= start_aligned) {
-		for (i = start; i < end; i++)
-			__free_pages_bootmem(pfn_to_page(i), 0);
-
-		return;
-	}
-
-	for (i = start; i < start_aligned; i++)
-		__free_pages_bootmem(pfn_to_page(i), 0);
-
-	for (i = start_aligned; i < end_aligned; i += BITS_PER_LONG)
-		__free_pages_bootmem(pfn_to_page(i), order);
-
-	for (i = end_aligned; i < end; i++)
-		__free_pages_bootmem(pfn_to_page(i), 0);
-}
-
-unsigned long __init free_all_memory_core_early(int nodeid)
-{
-	int i;
-	u64 start, end;
-	unsigned long count = 0;
-	struct range *range = NULL;
-	int nr_range;
-
-	nr_range = get_free_all_memory_range(&range, nodeid);
-
-	for (i = 0; i < nr_range; i++) {
-		start = range[i].start;
-		end = range[i].end;
-		count += end - start;
-		__free_pages_memory(start, end);
-	}
-
-	return count;
-}
-#else
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
 	int aligned;
@@ -278,7 +230,6 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 
 	return count;
 }
-#endif
 
 /**
  * free_all_bootmem_node - release a node's free pages to the buddy allocator
@@ -289,12 +240,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
-#ifdef CONFIG_NO_BOOTMEM
-	/* free_all_memory_core_early(MAX_NUMNODES) will be called later */
-	return 0;
-#else
 	return free_all_bootmem_core(pgdat->bdata);
-#endif
 }
 
 /**
@@ -304,16 +250,6 @@ unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
  */
 unsigned long __init free_all_bootmem(void)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	/*
-	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
-	 *  because in some case like Node0 doesnt have RAM installed
-	 *  low ram will be on Node1
-	 * Use MAX_NUMNODES will make sure all ranges in early_node_map[]
-	 *  will be used instead of only Node0 related
-	 */
-	return free_all_memory_core_early(MAX_NUMNODES);
-#else
 	unsigned long total_pages = 0;
 	bootmem_data_t *bdata;
 
@@ -321,10 +257,8 @@ unsigned long __init free_all_bootmem(void)
 		total_pages += free_all_bootmem_core(bdata);
 
 	return total_pages;
-#endif
 }
 
-#ifndef CONFIG_NO_BOOTMEM
 static void __init __free(bootmem_data_t *bdata,
 			unsigned long sidx, unsigned long eidx)
 {
@@ -419,7 +353,6 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
 	}
 	BUG();
 }
-#endif
 
 /**
  * free_bootmem_node - mark a page range as usable
@@ -434,10 +367,6 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
 void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	kmemleak_free_part(__va(physaddr), size);
-	memblock_x86_free_range(physaddr, physaddr + size);
-#else
 	unsigned long start, end;
 
 	kmemleak_free_part(__va(physaddr), size);
@@ -446,7 +375,6 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 	end = PFN_DOWN(physaddr + size);
 
 	mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
-#endif
 }
 
 /**
@@ -460,10 +388,6 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
  */
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	kmemleak_free_part(__va(addr), size);
-	memblock_x86_free_range(addr, addr + size);
-#else
 	unsigned long start, end;
 
 	kmemleak_free_part(__va(addr), size);
@@ -472,7 +396,6 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
 	end = PFN_DOWN(addr + size);
 
 	mark_bootmem(start, end, 0, 0);
-#endif
 }
 
 /**
@@ -489,17 +412,12 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
 int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 				 unsigned long size, int flags)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	panic("no bootmem");
-	return 0;
-#else
 	unsigned long start, end;
 
 	start = PFN_DOWN(physaddr);
 	end = PFN_UP(physaddr + size);
 
 	return mark_bootmem_node(pgdat->bdata, start, end, 1, flags);
-#endif
 }
 
 /**
@@ -515,20 +433,14 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 int __init reserve_bootmem(unsigned long addr, unsigned long size,
 			    int flags)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	panic("no bootmem");
-	return 0;
-#else
 	unsigned long start, end;
 
 	start = PFN_DOWN(addr);
 	end = PFN_UP(addr + size);
 
 	return mark_bootmem(start, end, 1, flags);
-#endif
 }
 
-#ifndef CONFIG_NO_BOOTMEM
 int __weak __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
 				   int flags)
 {
@@ -685,33 +597,12 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 #endif
 	return NULL;
 }
-#endif
 
 static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 					unsigned long align,
 					unsigned long goal,
 					unsigned long limit)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	void *ptr;
-
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc(size, GFP_NOWAIT);
-
-restart:
-
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, limit);
-
-	if (ptr)
-		return ptr;
-
-	if (goal != 0) {
-		goal = 0;
-		goto restart;
-	}
-
-	return NULL;
-#else
 	bootmem_data_t *bdata;
 	void *region;
 
@@ -737,7 +628,6 @@ restart:
 	}
 
 	return NULL;
-#endif
 }
 
 /**
@@ -758,10 +648,6 @@ void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 {
 	unsigned long limit = 0;
 
-#ifdef CONFIG_NO_BOOTMEM
-	limit = -1UL;
-#endif
-
 	return ___alloc_bootmem_nopanic(size, align, goal, limit);
 }
 
@@ -798,14 +684,9 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 {
 	unsigned long limit = 0;
 
-#ifdef CONFIG_NO_BOOTMEM
-	limit = -1UL;
-#endif
-
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
-#ifndef CONFIG_NO_BOOTMEM
 static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
 				unsigned long size, unsigned long align,
 				unsigned long goal, unsigned long limit)
@@ -822,7 +703,6 @@ static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
 
 	return ___alloc_bootmem(size, align, goal, limit);
 }
-#endif
 
 /**
  * __alloc_bootmem_node - allocate boot memory from a specific node
@@ -847,17 +727,7 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-#ifdef CONFIG_NO_BOOTMEM
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-					 goal, -1ULL);
-	if (ptr)
-		return ptr;
-
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					 goal, -1ULL);
-#else
 	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
-#endif
 
 	return ptr;
 }
@@ -880,13 +750,8 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 		unsigned long new_goal;
 
 		new_goal = MAX_DMA32_PFN << PAGE_SHIFT;
-#ifdef CONFIG_NO_BOOTMEM
-		ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
-						 new_goal, -1ULL);
-#else
 		ptr = alloc_bootmem_core(pgdat->bdata, size, align,
 						 new_goal, 0);
-#endif
 		if (ptr)
 			return ptr;
 	}
@@ -907,16 +772,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 void * __init alloc_bootmem_section(unsigned long size,
 				    unsigned long section_nr)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	unsigned long pfn, goal, limit;
-
-	pfn = section_nr_to_pfn(section_nr);
-	goal = pfn << PAGE_SHIFT;
-	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
-
-	return __alloc_memory_core_early(early_pfn_to_nid(pfn), size,
-					 SMP_CACHE_BYTES, goal, limit);
-#else
 	bootmem_data_t *bdata;
 	unsigned long pfn, goal, limit;
 
@@ -926,7 +781,6 @@ void * __init alloc_bootmem_section(unsigned long size,
 	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
 
 	return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, goal, limit);
-#endif
 }
 #endif
 
@@ -938,16 +792,11 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-#ifdef CONFIG_NO_BOOTMEM
-	ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
-						 goal, -1ULL);
-#else
 	ptr = alloc_arch_preferred_bootmem(pgdat->bdata, size, align, goal, 0);
 	if (ptr)
 		return ptr;
 
 	ptr = alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
-#endif
 	if (ptr)
 		return ptr;
 
@@ -1000,16 +849,7 @@ void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-#ifdef CONFIG_NO_BOOTMEM
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
-	if (ptr)
-		return ptr;
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
-#else
 	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align,
 				goal, ARCH_LOW_ADDRESS_LIMIT);
-#endif
 	return ptr;
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
new file mode 100644
index 000000000000..e93c3475011b
--- /dev/null
+++ b/mm/nobootmem.c
@@ -0,0 +1,445 @@
+/*
+ *  nobootmem - A boot-time physical memory allocator and configurator
+ *
+ *  Copyright (C) 1999 Ingo Molnar
+ *                1999 Kanoj Sarcar, SGI
+ *                2008 Johannes Weiner
+ *
+ *  Split out of bootmem.c by Namhyung Kim <namhyung@gmail.com>
+ *
+ * Access to this subsystem has to be serialized externally (which is true
+ * for the boot process anyway).
+ */
+#include <linux/init.h>
+#include <linux/pfn.h>
+#include <linux/slab.h>
+#include <linux/bootmem.h>
+#include <linux/module.h>
+#include <linux/kmemleak.h>
+#include <linux/range.h>
+#include <linux/memblock.h>
+
+#include <asm/bug.h>
+#include <asm/io.h>
+#include <asm/processor.h>
+
+#include "internal.h"
+
+unsigned long max_low_pfn;
+unsigned long min_low_pfn;
+unsigned long max_pfn;
+
+#ifdef CONFIG_CRASH_DUMP
+/*
+ * If we have booted due to a crash, max_pfn will be a very low value. We need
+ * to know the amount of memory that the previous kernel used.
+ */
+unsigned long saved_max_pfn;
+#endif
+
+/**
+ * free_bootmem_late - free bootmem pages directly to page allocator
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * This is only useful when the bootmem allocator has already been torn
+ * down, but we are still initializing the system.  Pages are given directly
+ * to the page allocator, no bootmem metadata is updated because it is gone.
+ */
+void __init free_bootmem_late(unsigned long addr, unsigned long size)
+{
+	unsigned long cursor, end;
+
+	kmemleak_free_part(__va(addr), size);
+
+	cursor = PFN_UP(addr);
+	end = PFN_DOWN(addr + size);
+
+	for (; cursor < end; cursor++) {
+		__free_pages_bootmem(pfn_to_page(cursor), 0);
+		totalram_pages++;
+	}
+}
+
+static void __init __free_pages_memory(unsigned long start, unsigned long end)
+{
+	int i;
+	unsigned long start_aligned, end_aligned;
+	int order = ilog2(BITS_PER_LONG);
+
+	start_aligned = (start + (BITS_PER_LONG - 1)) & ~(BITS_PER_LONG - 1);
+	end_aligned = end & ~(BITS_PER_LONG - 1);
+
+	if (end_aligned <= start_aligned) {
+		for (i = start; i < end; i++)
+			__free_pages_bootmem(pfn_to_page(i), 0);
+
+		return;
+	}
+
+	for (i = start; i < start_aligned; i++)
+		__free_pages_bootmem(pfn_to_page(i), 0);
+
+	for (i = start_aligned; i < end_aligned; i += BITS_PER_LONG)
+		__free_pages_bootmem(pfn_to_page(i), order);
+
+	for (i = end_aligned; i < end; i++)
+		__free_pages_bootmem(pfn_to_page(i), 0);
+}
+
+unsigned long __init free_all_memory_core_early(int nodeid)
+{
+	int i;
+	u64 start, end;
+	unsigned long count = 0;
+	struct range *range = NULL;
+	int nr_range;
+
+	nr_range = get_free_all_memory_range(&range, nodeid);
+
+	for (i = 0; i < nr_range; i++) {
+		start = range[i].start;
+		end = range[i].end;
+		count += end - start;
+		__free_pages_memory(start, end);
+	}
+
+	return count;
+}
+
+/**
+ * free_all_bootmem_node - release a node's free pages to the buddy allocator
+ * @pgdat: node to be released
+ *
+ * Returns the number of pages actually released.
+ */
+unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
+{
+	register_page_bootmem_info_node(pgdat);
+
+	/* free_all_memory_core_early(MAX_NUMNODES) will be called later */
+	return 0;
+}
+
+/**
+ * free_all_bootmem - release free pages to the buddy allocator
+ *
+ * Returns the number of pages actually released.
+ */
+unsigned long __init free_all_bootmem(void)
+{
+	/*
+	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
+	 *  because in some case like Node0 doesnt have RAM installed
+	 *  low ram will be on Node1
+	 * Use MAX_NUMNODES will make sure all ranges in early_node_map[]
+	 *  will be used instead of only Node0 related
+	 */
+	return free_all_memory_core_early(MAX_NUMNODES);
+}
+
+/**
+ * free_bootmem_node - mark a page range as usable
+ * @pgdat: node the range resides on
+ * @physaddr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be considered reserved and left as they are.
+ *
+ * The range must reside completely on the specified node.
+ */
+void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+			      unsigned long size)
+{
+	kmemleak_free_part(__va(physaddr), size);
+	memblock_x86_free_range(physaddr, physaddr + size);
+}
+
+/**
+ * free_bootmem - mark a page range as usable
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * Partial pages will be considered reserved and left as they are.
+ *
+ * The range must be contiguous but may span node boundaries.
+ */
+void __init free_bootmem(unsigned long addr, unsigned long size)
+{
+	kmemleak_free_part(__va(addr), size);
+	memblock_x86_free_range(addr, addr + size);
+}
+
+/**
+ * reserve_bootmem_node - mark a page range as reserved
+ * @pgdat: node the range resides on
+ * @physaddr: starting address of the range
+ * @size: size of the range in bytes
+ * @flags: reservation flags (see linux/bootmem.h)
+ *
+ * Partial pages will be reserved.
+ *
+ * The range must reside completely on the specified node.
+ */
+int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+				 unsigned long size, int flags)
+{
+	panic("no bootmem");
+	return 0;
+}
+
+/**
+ * reserve_bootmem - mark a page range as usable
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ * @flags: reservation flags (see linux/bootmem.h)
+ *
+ * Partial pages will be reserved.
+ *
+ * The range must be contiguous but may span node boundaries.
+ */
+int __init reserve_bootmem(unsigned long addr, unsigned long size,
+			    int flags)
+{
+	panic("no bootmem");
+	return 0;
+}
+
+static void * __init ___alloc_bootmem_nopanic(unsigned long size,
+					unsigned long align,
+					unsigned long goal,
+					unsigned long limit)
+{
+	void *ptr;
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc(size, GFP_NOWAIT);
+
+restart:
+
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, limit);
+
+	if (ptr)
+		return ptr;
+
+	if (goal != 0) {
+		goal = 0;
+		goto restart;
+	}
+
+	return NULL;
+}
+
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
+void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
+					unsigned long goal)
+{
+	unsigned long limit = -1UL;
+
+	return ___alloc_bootmem_nopanic(size, align, goal, limit);
+}
+
+static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
+					unsigned long goal, unsigned long limit)
+{
+	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
+
+	if (mem)
+		return mem;
+	/*
+	 * Whoops, we cannot satisfy the allocation request.
+	 */
+	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of memory");
+	return NULL;
+}
+
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
+void * __init __alloc_bootmem(unsigned long size, unsigned long align,
+			      unsigned long goal)
+{
+	unsigned long limit = -1UL;
+
+	return ___alloc_bootmem(size, align, goal, limit);
+}
+
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
+void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	void *ptr;
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
+					 goal, -1ULL);
+	if (ptr)
+		return ptr;
+
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+					 goal, -1ULL);
+
+	return ptr;
+}
+
+void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+#ifdef MAX_DMA32_PFN
+	unsigned long end_pfn;
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	/* update goal according ...MAX_DMA32_PFN */
+	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+
+	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
+	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
+		void *ptr;
+		unsigned long new_goal;
+
+		new_goal = MAX_DMA32_PFN << PAGE_SHIFT;
+		ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
+						 new_goal, -1ULL);
+		if (ptr)
+			return ptr;
+	}
+#endif
+
+	return __alloc_bootmem_node(pgdat, size, align, goal);
+
+}
+
+#ifdef CONFIG_SPARSEMEM
+/**
+ * alloc_bootmem_section - allocate boot memory from a specific section
+ * @size: size of the request in bytes
+ * @section_nr: sparse map section to allocate from
+ *
+ * Return NULL on failure.
+ */
+void * __init alloc_bootmem_section(unsigned long size,
+				    unsigned long section_nr)
+{
+	unsigned long pfn, goal, limit;
+
+	pfn = section_nr_to_pfn(section_nr);
+	goal = pfn << PAGE_SHIFT;
+	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
+
+	return __alloc_memory_core_early(early_pfn_to_nid(pfn), size,
+					 SMP_CACHE_BYTES, goal, limit);
+}
+#endif
+
+void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	void *ptr;
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
+						 goal, -1ULL);
+	if (ptr)
+		return ptr;
+
+	return __alloc_bootmem_nopanic(size, align, goal);
+}
+
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
+#endif
+
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
+void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
+				  unsigned long goal)
+{
+	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
+}
+
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
+void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
+				       unsigned long align, unsigned long goal)
+{
+	void *ptr;
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
+				goal, ARCH_LOW_ADDRESS_LIMIT);
+	if (ptr)
+		return ptr;
+
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+				goal, ARCH_LOW_ADDRESS_LIMIT);
+	return ptr;
+}
-- 
1.7.3.4.600.g982838b0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
