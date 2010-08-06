Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B5BB46200EA
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:42 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FZ0f013806
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZ0p942248
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FZ7G017146
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 42/43] memblock: Option for the architecture to put memblock into the .init section
Date: Fri,  6 Aug 2010 15:15:23 +1000
Message-Id: <1281071724-28740-43-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

From: Yinghai Lu <yinghai@kernel.org>

Arch code can define ARCH_DISCARD_MEMBLOCK in asm/memblock.h,
which in turns causes memblock code and data to go respectively
into the .init and .initdata sections. This will be used by the
x86 architecture.

If ARCH_DISCARD_MEMBLOCK is defined, the debugfs files to inspect
the memblock arrays after boot are not created.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    8 +++++++
 mm/memblock.c            |   48 +++++++++++++++++++++++-----------------------
 2 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c24b278..3978e6a 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -149,6 +149,14 @@ static inline unsigned long memblock_region_pages(const struct memblock_region *
 	     region++)
 
 
+#ifdef ARCH_DISCARD_MEMBLOCK
+#define __init_memblock __init
+#define __initdata_memblock __initdata
+#else
+#define __init_memblock
+#define __initdata_memblock
+#endif
+
 #endif /* CONFIG_HAVE_MEMBLOCK */
 
 #endif /* __KERNEL__ */
diff --git a/mm/memblock.c b/mm/memblock.c
index cb520df..a17faea 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,12 +20,12 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
-struct memblock memblock;
+struct memblock memblock __initdata_memblock;
 
-int memblock_debug;
-int memblock_can_resize;
-static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS + 1];
-static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS + 1];
+int memblock_debug __initdata_memblock;
+int memblock_can_resize __initdata_memblock;
+static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS + 1] __initdata_memblock;
+static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS + 1] __initdata_memblock;
 
 /* inline so we don't get a warning when pr_debug is compiled out */
 static inline const char *memblock_type_name(struct memblock_type *type)
@@ -42,23 +42,23 @@ static inline const char *memblock_type_name(struct memblock_type *type)
  * Address comparison utilities
  */
 
-static phys_addr_t memblock_align_down(phys_addr_t addr, phys_addr_t size)
+static phys_addr_t __init_memblock memblock_align_down(phys_addr_t addr, phys_addr_t size)
 {
 	return addr & ~(size - 1);
 }
 
-static phys_addr_t memblock_align_up(phys_addr_t addr, phys_addr_t size)
+static phys_addr_t __init_memblock memblock_align_up(phys_addr_t addr, phys_addr_t size)
 {
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static unsigned long memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
+static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
 				       phys_addr_t base2, phys_addr_t size2)
 {
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-static long memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
+static long __init_memblock memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
 			       phys_addr_t base2, phys_addr_t size2)
 {
 	if (base2 == base1 + size1)
@@ -69,7 +69,7 @@ static long memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
 	return 0;
 }
 
-static long memblock_regions_adjacent(struct memblock_type *type,
+static long __init_memblock memblock_regions_adjacent(struct memblock_type *type,
 				 unsigned long r1, unsigned long r2)
 {
 	phys_addr_t base1 = type->regions[r1].base;
@@ -80,7 +80,7 @@ static long memblock_regions_adjacent(struct memblock_type *type,
 	return memblock_addrs_adjacent(base1, size1, base2, size2);
 }
 
-long memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+long __init_memblock memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 
@@ -162,7 +162,7 @@ static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align
 	return MEMBLOCK_ERROR;
 }
 
-static void memblock_remove_region(struct memblock_type *type, unsigned long r)
+static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
 {
 	unsigned long i;
 
@@ -174,7 +174,7 @@ static void memblock_remove_region(struct memblock_type *type, unsigned long r)
 }
 
 /* Assumption: base addr of region 1 < base addr of region 2 */
-static void memblock_coalesce_regions(struct memblock_type *type,
+static void __init_memblock memblock_coalesce_regions(struct memblock_type *type,
 		unsigned long r1, unsigned long r2)
 {
 	type->regions[r1].size += type->regions[r2].size;
@@ -184,7 +184,7 @@ static void memblock_coalesce_regions(struct memblock_type *type,
 /* Defined below but needed now */
 static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size);
 
-static int memblock_double_array(struct memblock_type *type)
+static int __init_memblock memblock_double_array(struct memblock_type *type)
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_size, new_size, addr;
@@ -255,13 +255,13 @@ static int memblock_double_array(struct memblock_type *type)
 	return 0;
 }
 
-extern int __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+extern int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
 					  phys_addr_t addr2, phys_addr_t size2)
 {
 	return 1;
 }
 
-static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
 	long adjacent, i;
@@ -348,13 +348,13 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 	return 0;
 }
 
-long memblock_add(phys_addr_t base, phys_addr_t size)
+long __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	return memblock_add_region(&memblock.memory, base, size);
 
 }
 
-static long __memblock_remove(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock __memblock_remove(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t rgnbegin, rgnend;
 	phys_addr_t end = base + size;
@@ -402,7 +402,7 @@ static long __memblock_remove(struct memblock_type *type, phys_addr_t base, phys
 	return memblock_add_region(type, end, rgnend - end);
 }
 
-long memblock_remove(phys_addr_t base, phys_addr_t size)
+long __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 {
 	return __memblock_remove(&memblock.memory, base, size);
 }
@@ -568,7 +568,7 @@ phys_addr_t __init memblock_phys_mem_size(void)
 	return memblock.memory_size;
 }
 
-phys_addr_t memblock_end_of_DRAM(void)
+phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 {
 	int idx = memblock.memory.cnt - 1;
 
@@ -655,7 +655,7 @@ int memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
 		 memblock.reserved.regions[idx].size) >= (base + size);
 }
 
-int memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
+int __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
 {
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
@@ -666,7 +666,7 @@ void __init memblock_set_current_limit(phys_addr_t limit)
 	memblock.current_limit = limit;
 }
 
-static void memblock_dump(struct memblock_type *region, char *name)
+static void __init_memblock memblock_dump(struct memblock_type *region, char *name)
 {
 	unsigned long long base, size;
 	int i;
@@ -682,7 +682,7 @@ static void memblock_dump(struct memblock_type *region, char *name)
 	}
 }
 
-void memblock_dump_all(void)
+void __init_memblock memblock_dump_all(void)
 {
 	if (!memblock_debug)
 		return;
@@ -748,7 +748,7 @@ static int __init early_memblock(char *p)
 }
 early_param("memblock", early_memblock);
 
-#ifdef CONFIG_DEBUG_FS
+#if defined(CONFIG_DEBUG_FS) && !defined(ARCH_DISCARD_MEMBLOCK)
 
 static int memblock_debug_show(struct seq_file *m, void *private)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
