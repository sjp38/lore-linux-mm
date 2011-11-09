Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2B2C6B006C
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 06:37:31 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id e16so2402838iaa.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 03:37:30 -0800 (PST)
Message-ID: <4EBA65F5.5080903@gmail.com>
Date: Wed, 09 Nov 2011 19:37:25 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/3][RESEND] cleanup: convert the int cnt to unsigned long
 in mm/memblock.c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have the following definition in memblock.h:
struct memblock_type {
    unsigned long cnt;  /* number of regions */
    unsigned long max;  /* size of the allocated array */
    struct memblock_region *regions;
};

But in memblock.c, some cnt/max vars are typed to int
instead of unsigned long.
This patch does the code cleanup.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/memblock.c |   40 ++++++++++++++++++++++------------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4d4d5ee..09ff05b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -52,13 +52,14 @@ static phys_addr_t __init_memblock memblock_align_up(phys_addr_t addr, phys_addr
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
-				       phys_addr_t base2, phys_addr_t size2)
+static int __init_memblock memblock_addrs_overlap(phys_addr_t base1,
+		phys_addr_t size1, phys_addr_t base2, phys_addr_t size2)
 {
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-long __init_memblock memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+long __init_memblock memblock_overlaps_region(struct memblock_type *type,
+				       phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 
@@ -111,7 +112,7 @@ static phys_addr_t __init_memblock memblock_find_region(phys_addr_t start, phys_
 static phys_addr_t __init_memblock memblock_find_base(phys_addr_t size,
 			phys_addr_t align, phys_addr_t start, phys_addr_t end)
 {
-	long i;
+	unsigned long i;
 
 	BUG_ON(0 == size);
 
@@ -199,7 +200,8 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 static int __init_memblock memblock_double_array(struct memblock_type *type)
 {
 	struct memblock_region *new_array, *old_array;
-	phys_addr_t old_size, new_size, addr;
+	phys_addr_t addr;
+	unsigned long old_size, new_size;
 	int use_slab = slab_is_available();
 
 	/* We don't allow resizing until we know about the reserved regions
@@ -277,7 +279,8 @@ static long __init_memblock memblock_add_region(struct memblock_type *type,
 						phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size;
-	int i, slot = -1;
+	long slot = -1;
+	unsigned long i;
 
 	/* First try and coalesce this MEMBLOCK with others */
 	for (i = 0; i < type->cnt; i++) {
@@ -413,7 +416,7 @@ static long __init_memblock __memblock_remove(struct memblock_type *type,
 					      phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size;
-	int i;
+	unsigned long i;
 
 	/* Walk through the array for collisions */
 	for (i = 0; i < type->cnt; i++) {
@@ -583,7 +586,7 @@ static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
 phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	struct memblock_type *mem = &memblock.memory;
-	int i;
+	unsigned long i;
 
 	BUG_ON(0 == size);
 
@@ -628,7 +631,7 @@ phys_addr_t __init memblock_phys_mem_size(void)
 
 phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 {
-	int idx = memblock.memory.cnt - 1;
+	unsigned long idx = memblock.memory.cnt - 1;
 
 	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
 }
@@ -674,12 +677,13 @@ void __init memblock_enforce_memory_limit(phys_addr_t memory_limit)
 	}
 }
 
-static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
+static long __init_memblock memblock_search(struct memblock_type *type,
+					    phys_addr_t addr)
 {
-	unsigned int left = 0, right = type->cnt;
+	unsigned long left = 0, right = type->cnt;
 
 	do {
-		unsigned int mid = (right + left) / 2;
+		unsigned long mid = (right + left) / 2;
 
 		if (addr < type->regions[mid].base)
 			right = mid;
@@ -704,7 +708,7 @@ int __init_memblock memblock_is_memory(phys_addr_t addr)
 
 int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
 {
-	int idx = memblock_search(&memblock.memory, base);
+	long idx = memblock_search(&memblock.memory, base);
 
 	if (idx == -1)
 		return 0;
@@ -727,7 +731,7 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 static void __init_memblock memblock_dump(struct memblock_type *region, char *name)
 {
 	unsigned long long base, size;
-	int i;
+	unsigned long i;
 
 	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
 
@@ -735,7 +739,7 @@ static void __init_memblock memblock_dump(struct memblock_type *region, char *na
 		base = region->regions[i].base;
 		size = region->regions[i].size;
 
-		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes\n",
+		pr_info(" %s[%#lx]\t[%#016llx-%#016llx], %#llx bytes\n",
 		    name, i, base, base + size - 1, size);
 	}
 }
@@ -754,7 +758,7 @@ void __init_memblock memblock_dump_all(void)
 
 void __init memblock_analyze(void)
 {
-	int i;
+	unsigned long i;
 
 	/* Check marker in the unused last array entry */
 	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
@@ -818,11 +822,11 @@ static int memblock_debug_show(struct seq_file *m, void *private)
 {
 	struct memblock_type *type = m->private;
 	struct memblock_region *reg;
-	int i;
+	unsigned long i;
 
 	for (i = 0; i < type->cnt; i++) {
 		reg = &type->regions[i];
-		seq_printf(m, "%4d: ", i);
+		seq_printf(m, "%4ld: ", i);
 		if (sizeof(phys_addr_t) == 4)
 			seq_printf(m, "0x%08lx..0x%08lx\n",
 				   (unsigned long)reg->base,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
