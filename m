Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137hDcj017770 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:43:13 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137h9HC032276 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:43:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 78488F90B6
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:43:09 +0900 (JST)
Received: from fjm502.ms.jp.fujitsu.com (fjm502.ms.jp.fujitsu.com [10.56.99.74])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id B20E1F8C7E
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:43:08 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm502.ms.jp.fujitsu.com with ESMTP id k137h6e3002259
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:43:07 +0900
Message-ID: <43E309C5.6070507@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:44:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pearing off zone from physical memory layout [4/10] add memory
 layout subsystem
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Some codes needs information memory layout per zones.
This memory_map list will support them.
This structure is rarely used.

ARCH_HAS_REGISTE_MEMORY_ZONE is defined for some archs which have
sparse zone, holes in a zone.
Now, code for such arch is not available
(I'll do one by one. please notify if there is such arch other than ia64.).

For managing  memory_map_list, I used a simple list,
without sorting, coalescing  etc..



Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>

==
Index: hogehoge/include/linux/memorymap.h
===================================================================
--- /dev/null
+++ hogehoge/include/linux/memorymap.h
@@ -0,0 +1,43 @@
+#ifndef __LINUX_MEMORYMAP_H
+#define __LINUX_MEMORYMAP_H
+/* included from mm.h */
+/*
+ * managing information of memory map.
+ * showing the range [start_pfn, end_pfn)
+ */
+struct memory_map {
+	struct list_head list;
+	unsigned long start_pfn;
+	unsigned long end_pfn;
+	struct zone *zone;
+};
+
+extern struct list_head memory_map_list;
+
+extern void setup_memory_map(void) __init;
+extern void register_memory_zone(struct zone *zone,
+		                unsigned long start_pfn,
+				unsigned long nr_pages);
+extern void unregister_memory(unsigned long start_pfn, unsigned long nr_pages);
+
+#ifdef ARCH_HAS_REGISTER_MEMOEY_ZONE /* for archs which have memory holes in zone */
+extern void arch_register_memory_zone(struct zone *zone,
+				      unsigned long start_pfn, unsigned long nr_pages);
+#else
+static inline void arch_register_memory_zone(struct zone *zone,
+					unsigned long start_pfn, unsigned long nr_pages)
+{
+	return register_memory_zone(zone, start_pfn, nr_pages);
+}
+#endif
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+extern void memory_resize_lock(void);
+extern void memory_resize_unlock(void);
+#else
+static inline void memory_resize_lock(void) {}
+static inline void memory_resize_unlock(void) {}
+#endif
+
+
+#endif
Index: hogehoge/mm/memory_map.c
===================================================================
--- /dev/null
+++ hogehoge/mm/memory_map.c
@@ -0,0 +1,100 @@
+#include <linux/config.h>
+#include <linux/stddef.h>
+#include <linux/mm.h>
+#include <linux/memorymap.h>
+
+#define NR_MEMORYMAP	(MAX_NR_ZONES * MAX_NUMNODES)
+struct memory_map memory_map_pool[NR_MEMORYMAP];
+LIST_HEAD(memory_map_list);
+LIST_HEAD(memory_map_freelist);
+spinlock_t __memory_resize_lock;
+
+void memory_resize_lock(void) {
+	spin_lock(&__memory_resize_lock);
+}
+
+void memory_resize_unlock(void) {
+	spin_unlock(&__memory_resize_lock);
+}
+
+
+static struct memory_map *memory_map_alloc(void)
+{
+	struct memory_map *map = NULL;
+	if (!list_empty(&memory_map_freelist)) {
+		map = list_entry(memory_map_freelist.next, struct memory_map, list);
+		list_del_init(&map->list);
+	} else {
+#ifdef CONFIG_MEMORY_HOTPLUG
+		map = kmalloc(sizeof(struct memory_map), GFP_KERNEL);
+#else
+		BUG();
+#endif
+	}
+	return map;
+}
+
+static void memory_map_free(struct memory_map *map)
+{
+	list_add(&map->list,&memory_map_freelist);
+}
+
+
+void __init setup_memory_map(void)
+{
+	int i;
+	for (i = 0; i < NR_MEMORYMAP; i++)
+		list_add(&memory_map_pool[i].list, &memory_map_freelist);
+	spin_lock_init(&__memory_resize_lock);
+}
+
+extern void register_memory_zone(struct zone *zone,
+				 unsigned long start_pfn,
+				 unsigned long nr_pages)
+{
+	struct memory_map *map = memory_map_alloc();
+	BUG_ON(!map);
+	map->start_pfn = start_pfn;
+	map->end_pfn = start_pfn + nr_pages;
+	map->zone = zone;
+	list_add(&map->list, &memory_map_list);
+}
+
+extern void unregister_memory(unsigned long start_pfn, unsigned long nr_pages)
+{
+	struct memory_map *map, *n;
+	unsigned long end_pfn = start_pfn + nr_pages;
+
+	list_for_each_entry_safe(map, n, &memory_map_list, list) {
+		if ((map->start_pfn >= end_pfn) || (map->end_pfn <= start_pfn))
+			continue;
+		/* start_pfn (....) end_pfn */
+		if ((start_pfn <= map->start_pfn) && (end_pfn   >= map->end_pfn)) {
+			list_del_init(&map->list);
+			memory_map_free(map);
+			continue;
+		}
+		/* start_pfn (....end_pfn ....) */
+		if ((start_pfn <= map->start_pfn) && (end_pfn < map->end_pfn)) {
+			map->start_pfn = end_pfn;
+			continue;
+		}
+		/* (.....start_pfn....) end_pfn */
+		if ((map->start_pfn < start_pfn) && (end_pfn > map->end_pfn)) {
+			map->end_pfn = start_pfn;
+			continue;
+		}
+		/* devide into 2 maps */
+		if ((map->start_pfn < start_pfn) && (end_pfn < map->end_pfn)) {
+			struct memory_map *newmap;
+			newmap = memory_map_alloc();
+			BUG_ON(!newmap);
+			newmap->start_pfn = end_pfn;
+			newmap->end_pfn = map->end_pfn;
+			newmap->zone = map->zone;
+			map->end_pfn = start_pfn;
+			list_add(&newmap->list, &map->list);
+
+		}
+	}
+}
Index: hogehoge/mm/Makefile
===================================================================
--- hogehoge.orig/mm/Makefile
+++ hogehoge/mm/Makefile
@@ -10,7 +10,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o
  obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
  			   page_alloc.o page-writeback.o pdflush.o \
  			   readahead.o swap.o truncate.o vmscan.o \
-			   prio_tree.o util.o $(mmu-y)
+			   prio_tree.o util.o memory_map.o $(mmu-y)

  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
