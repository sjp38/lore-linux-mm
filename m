Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 333E56B02B2
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:37 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FROL029525
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:27 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FXdZ1523720
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:33 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FX3s026017
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:33 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 29/43] memblock: Move functions around into a more sensible order
Date: Fri,  6 Aug 2010 15:15:10 +1000
Message-Id: <1281071724-28740-30-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Some shuffling is needed for doing array resize so we may as well
put some sense into the ordering of the functions in the whole memblock.c
file. No code change. Added some comments.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |  301 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 159 insertions(+), 142 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b775fca..e5f3f9b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -24,40 +24,18 @@ static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIO
 
 #define MEMBLOCK_ERROR	(~(phys_addr_t)0)
 
-static int __init early_memblock(char *p)
-{
-	if (p && strstr(p, "debug"))
-		memblock_debug = 1;
-	return 0;
-}
-early_param("memblock", early_memblock);
+/*
+ * Address comparison utilities
+ */
 
-static void memblock_dump(struct memblock_type *region, char *name)
+static phys_addr_t memblock_align_down(phys_addr_t addr, phys_addr_t size)
 {
-	unsigned long long base, size;
-	int i;
-
-	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
-
-	for (i = 0; i < region->cnt; i++) {
-		base = region->regions[i].base;
-		size = region->regions[i].size;
-
-		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
-		    name, i, base, base + size - 1, size);
-	}
+	return addr & ~(size - 1);
 }
 
-void memblock_dump_all(void)
+static phys_addr_t memblock_align_up(phys_addr_t addr, phys_addr_t size)
 {
-	if (!memblock_debug)
-		return;
-
-	pr_info("MEMBLOCK configuration:\n");
-	pr_info(" memory size = 0x%llx\n", (unsigned long long)memblock.memory_size);
-
-	memblock_dump(&memblock.memory, "memory");
-	memblock_dump(&memblock.reserved, "reserved");
+	return (addr + (size - 1)) & ~(size - 1);
 }
 
 static unsigned long memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
@@ -88,6 +66,77 @@ static long memblock_regions_adjacent(struct memblock_type *type,
 	return memblock_addrs_adjacent(base1, size1, base2, size2);
 }
 
+long memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+{
+	unsigned long i;
+
+	for (i = 0; i < type->cnt; i++) {
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
+		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
+			break;
+	}
+
+	return (i < type->cnt) ? i : -1;
+}
+
+/*
+ * Find, allocate, deallocate or reserve unreserved regions. All allocations
+ * are top-down.
+ */
+
+static phys_addr_t __init memblock_find_region(phys_addr_t start, phys_addr_t end,
+					  phys_addr_t size, phys_addr_t align)
+{
+	phys_addr_t base, res_base;
+	long j;
+
+	base = memblock_align_down((end - size), align);
+	while (start <= base) {
+		j = memblock_overlaps_region(&memblock.reserved, base, size);
+		if (j < 0)
+			return base;
+		res_base = memblock.reserved.regions[j].base;
+		if (res_base < size)
+			break;
+		base = memblock_align_down(res_base - size, align);
+	}
+
+	return MEMBLOCK_ERROR;
+}
+
+static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{
+	long i;
+	phys_addr_t base = 0;
+	phys_addr_t res_base;
+
+	BUG_ON(0 == size);
+
+	size = memblock_align_up(size, align);
+
+	/* Pump up max_addr */
+	if (max_addr == MEMBLOCK_ALLOC_ACCESSIBLE)
+		max_addr = memblock.current_limit;
+
+	/* We do a top-down search, this tends to limit memory
+	 * fragmentation by keeping early boot allocs near the
+	 * top of memory
+	 */
+	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
+		phys_addr_t memblockbase = memblock.memory.regions[i].base;
+		phys_addr_t memblocksize = memblock.memory.regions[i].size;
+
+		if (memblocksize < size)
+			continue;
+		base = min(memblockbase + memblocksize, max_addr);
+		res_base = memblock_find_region(memblockbase, base, size, align);
+		if (res_base != MEMBLOCK_ERROR)
+			return res_base;
+	}
+	return MEMBLOCK_ERROR;
+}
+
 static void memblock_remove_region(struct memblock_type *type, unsigned long r)
 {
 	unsigned long i;
@@ -107,22 +156,6 @@ static void memblock_coalesce_regions(struct memblock_type *type,
 	memblock_remove_region(type, r2);
 }
 
-void __init memblock_analyze(void)
-{
-	int i;
-
-	/* Check marker in the unused last array entry */
-	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
-	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
-
-	memblock.memory_size = 0;
-
-	for (i = 0; i < memblock.memory.cnt; i++)
-		memblock.memory_size += memblock.memory.regions[i].size;
-}
-
 static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -260,49 +293,47 @@ long __init memblock_reserve(phys_addr_t base, phys_addr_t size)
 	return memblock_add_region(_rgn, base, size);
 }
 
-long memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	unsigned long i;
+	phys_addr_t found;
 
-	for (i = 0; i < type->cnt; i++) {
-		phys_addr_t rgnbase = type->regions[i].base;
-		phys_addr_t rgnsize = type->regions[i].size;
-		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
-			break;
-	}
+	/* We align the size to limit fragmentation. Without this, a lot of
+	 * small allocs quickly eat up the whole reserve array on sparc
+	 */
+	size = memblock_align_up(size, align);
 
-	return (i < type->cnt) ? i : -1;
-}
+	found = memblock_find_base(size, align, max_addr);
+	if (found != MEMBLOCK_ERROR &&
+	    memblock_add_region(&memblock.reserved, found, size) >= 0)
+		return found;
 
-static phys_addr_t memblock_align_down(phys_addr_t addr, phys_addr_t size)
-{
-	return addr & ~(size - 1);
+	return 0;
 }
 
-static phys_addr_t memblock_align_up(phys_addr_t addr, phys_addr_t size)
+phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return (addr + (size - 1)) & ~(size - 1);
+	phys_addr_t alloc;
+
+	alloc = __memblock_alloc_base(size, align, max_addr);
+
+	if (alloc == 0)
+		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
+		      (unsigned long long) size, (unsigned long long) max_addr);
+
+	return alloc;
 }
 
-static phys_addr_t __init memblock_find_region(phys_addr_t start, phys_addr_t end,
-					  phys_addr_t size, phys_addr_t align)
+phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
-	phys_addr_t base, res_base;
-	long j;
+	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
+}
 
-	base = memblock_align_down((end - size), align);
-	while (start <= base) {
-		j = memblock_overlaps_region(&memblock.reserved, base, size);
-		if (j < 0)
-			return base;
-		res_base = memblock.reserved.regions[j].base;
-		if (res_base < size)
-			break;
-		base = memblock_align_down(res_base - size, align);
-	}
 
-	return MEMBLOCK_ERROR;
-}
+/*
+ * Additional node-local allocators. Search for node memory is bottom up
+ * and walks memblock regions within that node bottom-up as well, but allocation
+ * within an memblock region is top-down.
+ */
 
 phys_addr_t __weak __init memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
@@ -364,72 +395,6 @@ phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int n
 	return memblock_alloc(size, align);
 }
 
-phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
-{
-	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
-}
-
-static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	long i;
-	phys_addr_t base = 0;
-	phys_addr_t res_base;
-
-	BUG_ON(0 == size);
-
-	/* Pump up max_addr */
-	if (max_addr == MEMBLOCK_ALLOC_ACCESSIBLE)
-		max_addr = memblock.current_limit;
-
-	/* We do a top-down search, this tends to limit memory
-	 * fragmentation by keeping early boot allocs near the
-	 * top of memory
-	 */
-	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
-		phys_addr_t memblockbase = memblock.memory.regions[i].base;
-		phys_addr_t memblocksize = memblock.memory.regions[i].size;
-
-		if (memblocksize < size)
-			continue;
-		base = min(memblockbase + memblocksize, max_addr);
-		res_base = memblock_find_region(memblockbase, base, size, align);
-		if (res_base != MEMBLOCK_ERROR)
-			return res_base;
-	}
-	return MEMBLOCK_ERROR;
-}
-
-phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{	
-	phys_addr_t found;
-
-	/* We align the size to limit fragmentation. Without this, a lot of
-	 * small allocs quickly eat up the whole reserve array on sparc
-	 */
-	size = memblock_align_up(size, align);
-
-	found = memblock_find_base(size, align, max_addr);
-	if (found != MEMBLOCK_ERROR &&
-	    memblock_add_region(&memblock.reserved, found, size) >= 0)
-		return found;
-
-	return 0;
-}
-
-phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	phys_addr_t alloc;
-
-	alloc = __memblock_alloc_base(size, align, max_addr);
-
-	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
-
-	return alloc;
-}
-
-
 /* You must call memblock_analyze() before this. */
 phys_addr_t __init memblock_phys_mem_size(void)
 {
@@ -534,6 +499,50 @@ void __init memblock_set_current_limit(phys_addr_t limit)
 	memblock.current_limit = limit;
 }
 
+static void memblock_dump(struct memblock_type *region, char *name)
+{
+	unsigned long long base, size;
+	int i;
+
+	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
+
+	for (i = 0; i < region->cnt; i++) {
+		base = region->regions[i].base;
+		size = region->regions[i].size;
+
+		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
+		    name, i, base, base + size - 1, size);
+	}
+}
+
+void memblock_dump_all(void)
+{
+	if (!memblock_debug)
+		return;
+
+	pr_info("MEMBLOCK configuration:\n");
+	pr_info(" memory size = 0x%llx\n", (unsigned long long)memblock.memory_size);
+
+	memblock_dump(&memblock.memory, "memory");
+	memblock_dump(&memblock.reserved, "reserved");
+}
+
+void __init memblock_analyze(void)
+{
+	int i;
+
+	/* Check marker in the unused last array entry */
+	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+
+	memblock.memory_size = 0;
+
+	for (i = 0; i < memblock.memory.cnt; i++)
+		memblock.memory_size += memblock.memory.regions[i].size;
+}
+
 void __init memblock_init(void)
 {
 	/* Hookup the initial arrays */
@@ -561,3 +570,11 @@ void __init memblock_init(void)
 	memblock.current_limit = MEMBLOCK_ALLOC_ANYWHERE;
 }
 
+static int __init early_memblock(char *p)
+{
+	if (p && strstr(p, "debug"))
+		memblock_debug = 1;
+	return 0;
+}
+early_param("memblock", early_memblock);
+
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
