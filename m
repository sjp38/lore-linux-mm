Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5F26B02A6
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FORI029464
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:24 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FVkG1339476
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FU0Z026868
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 02/43] memblock: Rename memblock_region to memblock_type and memblock_property to memblock_region
Date: Fri,  6 Aug 2010 15:14:43 +1000
Message-Id: <1281071724-28740-3-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/mm/init.c                       |    2 +-
 arch/arm/plat-omap/fb.c                  |    2 +-
 arch/microblaze/mm/init.c                |    4 +-
 arch/powerpc/mm/hash_utils_64.c          |    2 +-
 arch/powerpc/mm/mem.c                    |   26 +++---
 arch/powerpc/platforms/embedded6xx/wii.c |    2 +-
 arch/sparc/mm/init_64.c                  |    6 +-
 drivers/video/omap2/vram.c               |    2 +-
 include/linux/memblock.h                 |   24 ++--
 mm/memblock.c                            |  168 +++++++++++++++---------------
 10 files changed, 118 insertions(+), 120 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 7185b00..d1496e6 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -237,7 +237,7 @@ static void __init arm_bootmem_free(struct meminfo *mi, unsigned long min,
 #ifndef CONFIG_SPARSEMEM
 int pfn_valid(unsigned long pfn)
 {
-	struct memblock_region *mem = &memblock.memory;
+	struct memblock_type *mem = &memblock.memory;
 	unsigned int left = 0, right = mem->cnt;
 
 	do {
diff --git a/arch/arm/plat-omap/fb.c b/arch/arm/plat-omap/fb.c
index 0054b95..05bf228 100644
--- a/arch/arm/plat-omap/fb.c
+++ b/arch/arm/plat-omap/fb.c
@@ -173,7 +173,7 @@ static int check_fbmem_region(int region_idx, struct omapfb_mem_region *rg,
 
 static int valid_sdram(unsigned long addr, unsigned long size)
 {
-	struct memblock_property res;
+	struct memblock_region res;
 
 	res.base = addr;
 	res.size = size;
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index db59349..afd6494 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -77,8 +77,8 @@ void __init setup_memory(void)
 
 	/* Find main memory where is the kernel */
 	for (i = 0; i < memblock.memory.cnt; i++) {
-		memory_start = (u32) memblock.memory.region[i].base;
-		memory_end = (u32) memblock.memory.region[i].base
+		memory_start = (u32) memblock.memory.regions[i].base;
+		memory_end = (u32) memblock.memory.regions[i].base
 				+ (u32) memblock.memory.region[i].size;
 		if ((memory_start <= (u32)_text) &&
 					((u32)_text <= memory_end)) {
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 09dffe6..b1a3784 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -660,7 +660,7 @@ static void __init htab_initialize(void)
 
 	/* create bolted the linear mapping in the hash table */
 	for (i=0; i < memblock.memory.cnt; i++) {
-		base = (unsigned long)__va(memblock.memory.region[i].base);
+		base = (unsigned long)__va(memblock.memory.regions[i].base);
 		size = memblock.memory.region[i].size;
 
 		DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 1a84a8d..a33f5c1 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -86,10 +86,10 @@ int page_is_ram(unsigned long pfn)
 	for (i=0; i < memblock.memory.cnt; i++) {
 		unsigned long base;
 
-		base = memblock.memory.region[i].base;
+		base = memblock.memory.regions[i].base;
 
 		if ((paddr >= base) &&
-			(paddr < (base + memblock.memory.region[i].size))) {
+			(paddr < (base + memblock.memory.regions[i].size))) {
 			return 1;
 		}
 	}
@@ -149,7 +149,7 @@ int
 walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 		void *arg, int (*func)(unsigned long, unsigned long, void *))
 {
-	struct memblock_property res;
+	struct memblock_region res;
 	unsigned long pfn, len;
 	u64 end;
 	int ret = -1;
@@ -206,7 +206,7 @@ void __init do_init_bootmem(void)
 	/* Add active regions with valid PFNs */
 	for (i = 0; i < memblock.memory.cnt; i++) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
+		start_pfn = memblock.memory.regions[i].base >> PAGE_SHIFT;
 		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
 		add_active_range(0, start_pfn, end_pfn);
 	}
@@ -219,16 +219,16 @@ void __init do_init_bootmem(void)
 
 	/* reserve the sections we're already using */
 	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long addr = memblock.reserved.region[i].base +
+		unsigned long addr = memblock.reserved.regions[i].base +
 				     memblock_size_bytes(&memblock.reserved, i) - 1;
 		if (addr < lowmem_end_addr)
-			reserve_bootmem(memblock.reserved.region[i].base,
+			reserve_bootmem(memblock.reserved.regions[i].base,
 					memblock_size_bytes(&memblock.reserved, i),
 					BOOTMEM_DEFAULT);
-		else if (memblock.reserved.region[i].base < lowmem_end_addr) {
+		else if (memblock.reserved.regions[i].base < lowmem_end_addr) {
 			unsigned long adjusted_size = lowmem_end_addr -
-				      memblock.reserved.region[i].base;
-			reserve_bootmem(memblock.reserved.region[i].base,
+				      memblock.reserved.regions[i].base;
+			reserve_bootmem(memblock.reserved.regions[i].base,
 					adjusted_size, BOOTMEM_DEFAULT);
 		}
 	}
@@ -237,7 +237,7 @@ void __init do_init_bootmem(void)
 
 	/* reserve the sections we're already using */
 	for (i = 0; i < memblock.reserved.cnt; i++)
-		reserve_bootmem(memblock.reserved.region[i].base,
+		reserve_bootmem(memblock.reserved.regions[i].base,
 				memblock_size_bytes(&memblock.reserved, i),
 				BOOTMEM_DEFAULT);
 
@@ -257,10 +257,10 @@ static int __init mark_nonram_nosave(void)
 
 	for (i = 0; i < memblock.memory.cnt - 1; i++) {
 		memblock_region_max_pfn =
-			(memblock.memory.region[i].base >> PAGE_SHIFT) +
-			(memblock.memory.region[i].size >> PAGE_SHIFT);
+			(memblock.memory.regions[i].base >> PAGE_SHIFT) +
+			(memblock.memory.regions[i].size >> PAGE_SHIFT);
 		memblock_next_region_start_pfn =
-			memblock.memory.region[i+1].base >> PAGE_SHIFT;
+			memblock.memory.regions[i+1].base >> PAGE_SHIFT;
 
 		if (memblock_region_max_pfn < memblock_next_region_start_pfn)
 			register_nosave_region(memblock_region_max_pfn,
diff --git a/arch/powerpc/platforms/embedded6xx/wii.c b/arch/powerpc/platforms/embedded6xx/wii.c
index 5cdcc7c..8450c29 100644
--- a/arch/powerpc/platforms/embedded6xx/wii.c
+++ b/arch/powerpc/platforms/embedded6xx/wii.c
@@ -65,7 +65,7 @@ static int __init page_aligned(unsigned long x)
 
 void __init wii_memory_fixups(void)
 {
-	struct memblock_property *p = memblock.memory.region;
+	struct memblock_region *p = memblock.memory.region;
 
 	/*
 	 * This is part of a workaround to allow the use of two
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index f043451..16d8bee 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -978,7 +978,7 @@ static void __init add_node_ranges(void)
 		unsigned long size = memblock_size_bytes(&memblock.memory, i);
 		unsigned long start, end;
 
-		start = memblock.memory.region[i].base;
+		start = memblock.memory.regions[i].base;
 		end = start + size;
 		while (start < end) {
 			unsigned long this_end;
@@ -1299,7 +1299,7 @@ static void __init bootmem_init_nonnuma(void)
 		if (!size)
 			continue;
 
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
+		start_pfn = memblock.memory.regions[i].base >> PAGE_SHIFT;
 		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
 		add_active_range(0, start_pfn, end_pfn);
 	}
@@ -1339,7 +1339,7 @@ static void __init trim_reserved_in_node(int nid)
 	numadbg("  trim_reserved_in_node(%d)\n", nid);
 
 	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long start = memblock.reserved.region[i].base;
+		unsigned long start = memblock.reserved.regions[i].base;
 		unsigned long size = memblock_size_bytes(&memblock.reserved, i);
 		unsigned long end = start + size;
 
diff --git a/drivers/video/omap2/vram.c b/drivers/video/omap2/vram.c
index f6fdc20..0f2532b 100644
--- a/drivers/video/omap2/vram.c
+++ b/drivers/video/omap2/vram.c
@@ -554,7 +554,7 @@ void __init omap_vram_reserve_sdram_memblock(void)
 	size = PAGE_ALIGN(size);
 
 	if (paddr) {
-		struct memblock_property res;
+		struct memblock_region res;
 
 		res.base = paddr;
 		res.size = size;
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index a59faf2..86e7daf 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -18,22 +18,22 @@
 
 #define MAX_MEMBLOCK_REGIONS 128
 
-struct memblock_property {
+struct memblock_region {
 	u64 base;
 	u64 size;
 };
 
-struct memblock_region {
+struct memblock_type {
 	unsigned long cnt;
 	u64 size;
-	struct memblock_property region[MAX_MEMBLOCK_REGIONS+1];
+	struct memblock_region regions[MAX_MEMBLOCK_REGIONS+1];
 };
 
 struct memblock {
 	unsigned long debug;
 	u64 rmo_size;
-	struct memblock_region memory;
-	struct memblock_region reserved;
+	struct memblock_type memory;
+	struct memblock_type reserved;
 };
 
 extern struct memblock memblock;
@@ -56,27 +56,27 @@ extern u64 memblock_end_of_DRAM(void);
 extern void __init memblock_enforce_memory_limit(u64 memory_limit);
 extern int __init memblock_is_reserved(u64 addr);
 extern int memblock_is_region_reserved(u64 base, u64 size);
-extern int memblock_find(struct memblock_property *res);
+extern int memblock_find(struct memblock_region *res);
 
 extern void memblock_dump_all(void);
 
 static inline u64
-memblock_size_bytes(struct memblock_region *type, unsigned long region_nr)
+memblock_size_bytes(struct memblock_type *type, unsigned long region_nr)
 {
-	return type->region[region_nr].size;
+	return type->regions[region_nr].size;
 }
 static inline u64
-memblock_size_pages(struct memblock_region *type, unsigned long region_nr)
+memblock_size_pages(struct memblock_type *type, unsigned long region_nr)
 {
 	return memblock_size_bytes(type, region_nr) >> PAGE_SHIFT;
 }
 static inline u64
-memblock_start_pfn(struct memblock_region *type, unsigned long region_nr)
+memblock_start_pfn(struct memblock_type *type, unsigned long region_nr)
 {
-	return type->region[region_nr].base >> PAGE_SHIFT;
+	return type->regions[region_nr].base >> PAGE_SHIFT;
 }
 static inline u64
-memblock_end_pfn(struct memblock_region *type, unsigned long region_nr)
+memblock_end_pfn(struct memblock_type *type, unsigned long region_nr)
 {
 	return memblock_start_pfn(type, region_nr) +
 	       memblock_size_pages(type, region_nr);
diff --git a/mm/memblock.c b/mm/memblock.c
index 43840b3..6f407cc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -29,7 +29,7 @@ static int __init early_memblock(char *p)
 }
 early_param("memblock", early_memblock);
 
-static void memblock_dump(struct memblock_region *region, char *name)
+static void memblock_dump(struct memblock_type *region, char *name)
 {
 	unsigned long long base, size;
 	int i;
@@ -37,8 +37,8 @@ static void memblock_dump(struct memblock_region *region, char *name)
 	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
 
 	for (i = 0; i < region->cnt; i++) {
-		base = region->region[i].base;
-		size = region->region[i].size;
+		base = region->regions[i].base;
+		size = region->regions[i].size;
 
 		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
 		    name, i, base, base + size - 1, size);
@@ -74,34 +74,34 @@ static long memblock_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
 	return 0;
 }
 
-static long memblock_regions_adjacent(struct memblock_region *rgn,
+static long memblock_regions_adjacent(struct memblock_type *type,
 		unsigned long r1, unsigned long r2)
 {
-	u64 base1 = rgn->region[r1].base;
-	u64 size1 = rgn->region[r1].size;
-	u64 base2 = rgn->region[r2].base;
-	u64 size2 = rgn->region[r2].size;
+	u64 base1 = type->regions[r1].base;
+	u64 size1 = type->regions[r1].size;
+	u64 base2 = type->regions[r2].base;
+	u64 size2 = type->regions[r2].size;
 
 	return memblock_addrs_adjacent(base1, size1, base2, size2);
 }
 
-static void memblock_remove_region(struct memblock_region *rgn, unsigned long r)
+static void memblock_remove_region(struct memblock_type *type, unsigned long r)
 {
 	unsigned long i;
 
-	for (i = r; i < rgn->cnt - 1; i++) {
-		rgn->region[i].base = rgn->region[i + 1].base;
-		rgn->region[i].size = rgn->region[i + 1].size;
+	for (i = r; i < type->cnt - 1; i++) {
+		type->regions[i].base = type->regions[i + 1].base;
+		type->regions[i].size = type->regions[i + 1].size;
 	}
-	rgn->cnt--;
+	type->cnt--;
 }
 
 /* Assumption: base addr of region 1 < base addr of region 2 */
-static void memblock_coalesce_regions(struct memblock_region *rgn,
+static void memblock_coalesce_regions(struct memblock_type *type,
 		unsigned long r1, unsigned long r2)
 {
-	rgn->region[r1].size += rgn->region[r2].size;
-	memblock_remove_region(rgn, r2);
+	type->regions[r1].size += type->regions[r2].size;
+	memblock_remove_region(type, r2);
 }
 
 void __init memblock_init(void)
@@ -109,13 +109,13 @@ void __init memblock_init(void)
 	/* Create a dummy zero size MEMBLOCK which will get coalesced away later.
 	 * This simplifies the memblock_add() code below...
 	 */
-	memblock.memory.region[0].base = 0;
-	memblock.memory.region[0].size = 0;
+	memblock.memory.regions[0].base = 0;
+	memblock.memory.regions[0].size = 0;
 	memblock.memory.cnt = 1;
 
 	/* Ditto. */
-	memblock.reserved.region[0].base = 0;
-	memblock.reserved.region[0].size = 0;
+	memblock.reserved.regions[0].base = 0;
+	memblock.reserved.regions[0].size = 0;
 	memblock.reserved.cnt = 1;
 }
 
@@ -126,24 +126,24 @@ void __init memblock_analyze(void)
 	memblock.memory.size = 0;
 
 	for (i = 0; i < memblock.memory.cnt; i++)
-		memblock.memory.size += memblock.memory.region[i].size;
+		memblock.memory.size += memblock.memory.regions[i].size;
 }
 
-static long memblock_add_region(struct memblock_region *rgn, u64 base, u64 size)
+static long memblock_add_region(struct memblock_type *type, u64 base, u64 size)
 {
 	unsigned long coalesced = 0;
 	long adjacent, i;
 
-	if ((rgn->cnt == 1) && (rgn->region[0].size == 0)) {
-		rgn->region[0].base = base;
-		rgn->region[0].size = size;
+	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
+		type->regions[0].base = base;
+		type->regions[0].size = size;
 		return 0;
 	}
 
 	/* First try and coalesce this MEMBLOCK with another. */
-	for (i = 0; i < rgn->cnt; i++) {
-		u64 rgnbase = rgn->region[i].base;
-		u64 rgnsize = rgn->region[i].size;
+	for (i = 0; i < type->cnt; i++) {
+		u64 rgnbase = type->regions[i].base;
+		u64 rgnsize = type->regions[i].size;
 
 		if ((rgnbase == base) && (rgnsize == size))
 			/* Already have this region, so we're done */
@@ -151,61 +151,59 @@ static long memblock_add_region(struct memblock_region *rgn, u64 base, u64 size)
 
 		adjacent = memblock_addrs_adjacent(base, size, rgnbase, rgnsize);
 		if (adjacent > 0) {
-			rgn->region[i].base -= size;
-			rgn->region[i].size += size;
+			type->regions[i].base -= size;
+			type->regions[i].size += size;
 			coalesced++;
 			break;
 		} else if (adjacent < 0) {
-			rgn->region[i].size += size;
+			type->regions[i].size += size;
 			coalesced++;
 			break;
 		}
 	}
 
-	if ((i < rgn->cnt - 1) && memblock_regions_adjacent(rgn, i, i+1)) {
-		memblock_coalesce_regions(rgn, i, i+1);
+	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1)) {
+		memblock_coalesce_regions(type, i, i+1);
 		coalesced++;
 	}
 
 	if (coalesced)
 		return coalesced;
-	if (rgn->cnt >= MAX_MEMBLOCK_REGIONS)
+	if (type->cnt >= MAX_MEMBLOCK_REGIONS)
 		return -1;
 
 	/* Couldn't coalesce the MEMBLOCK, so add it to the sorted table. */
-	for (i = rgn->cnt - 1; i >= 0; i--) {
-		if (base < rgn->region[i].base) {
-			rgn->region[i+1].base = rgn->region[i].base;
-			rgn->region[i+1].size = rgn->region[i].size;
+	for (i = type->cnt - 1; i >= 0; i--) {
+		if (base < type->regions[i].base) {
+			type->regions[i+1].base = type->regions[i].base;
+			type->regions[i+1].size = type->regions[i].size;
 		} else {
-			rgn->region[i+1].base = base;
-			rgn->region[i+1].size = size;
+			type->regions[i+1].base = base;
+			type->regions[i+1].size = size;
 			break;
 		}
 	}
 
-	if (base < rgn->region[0].base) {
-		rgn->region[0].base = base;
-		rgn->region[0].size = size;
+	if (base < type->regions[0].base) {
+		type->regions[0].base = base;
+		type->regions[0].size = size;
 	}
-	rgn->cnt++;
+	type->cnt++;
 
 	return 0;
 }
 
 long memblock_add(u64 base, u64 size)
 {
-	struct memblock_region *_rgn = &memblock.memory;
-
 	/* On pSeries LPAR systems, the first MEMBLOCK is our RMO region. */
 	if (base == 0)
 		memblock.rmo_size = size;
 
-	return memblock_add_region(_rgn, base, size);
+	return memblock_add_region(&memblock.memory, base, size);
 
 }
 
-static long __memblock_remove(struct memblock_region *rgn, u64 base, u64 size)
+static long __memblock_remove(struct memblock_type *type, u64 base, u64 size)
 {
 	u64 rgnbegin, rgnend;
 	u64 end = base + size;
@@ -214,34 +212,34 @@ static long __memblock_remove(struct memblock_region *rgn, u64 base, u64 size)
 	rgnbegin = rgnend = 0; /* supress gcc warnings */
 
 	/* Find the region where (base, size) belongs to */
-	for (i=0; i < rgn->cnt; i++) {
-		rgnbegin = rgn->region[i].base;
-		rgnend = rgnbegin + rgn->region[i].size;
+	for (i=0; i < type->cnt; i++) {
+		rgnbegin = type->regions[i].base;
+		rgnend = rgnbegin + type->regions[i].size;
 
 		if ((rgnbegin <= base) && (end <= rgnend))
 			break;
 	}
 
 	/* Didn't find the region */
-	if (i == rgn->cnt)
+	if (i == type->cnt)
 		return -1;
 
 	/* Check to see if we are removing entire region */
 	if ((rgnbegin == base) && (rgnend == end)) {
-		memblock_remove_region(rgn, i);
+		memblock_remove_region(type, i);
 		return 0;
 	}
 
 	/* Check to see if region is matching at the front */
 	if (rgnbegin == base) {
-		rgn->region[i].base = end;
-		rgn->region[i].size -= size;
+		type->regions[i].base = end;
+		type->regions[i].size -= size;
 		return 0;
 	}
 
 	/* Check to see if the region is matching at the end */
 	if (rgnend == end) {
-		rgn->region[i].size -= size;
+		type->regions[i].size -= size;
 		return 0;
 	}
 
@@ -249,8 +247,8 @@ static long __memblock_remove(struct memblock_region *rgn, u64 base, u64 size)
 	 * We need to split the entry -  adjust the current one to the
 	 * beginging of the hole and add the region after hole.
 	 */
-	rgn->region[i].size = base - rgn->region[i].base;
-	return memblock_add_region(rgn, end, rgnend - end);
+	type->regions[i].size = base - type->regions[i].base;
+	return memblock_add_region(type, end, rgnend - end);
 }
 
 long memblock_remove(u64 base, u64 size)
@@ -265,25 +263,25 @@ long __init memblock_free(u64 base, u64 size)
 
 long __init memblock_reserve(u64 base, u64 size)
 {
-	struct memblock_region *_rgn = &memblock.reserved;
+	struct memblock_type *_rgn = &memblock.reserved;
 
 	BUG_ON(0 == size);
 
 	return memblock_add_region(_rgn, base, size);
 }
 
-long memblock_overlaps_region(struct memblock_region *rgn, u64 base, u64 size)
+long memblock_overlaps_region(struct memblock_type *type, u64 base, u64 size)
 {
 	unsigned long i;
 
-	for (i = 0; i < rgn->cnt; i++) {
-		u64 rgnbase = rgn->region[i].base;
-		u64 rgnsize = rgn->region[i].size;
+	for (i = 0; i < type->cnt; i++) {
+		u64 rgnbase = type->regions[i].base;
+		u64 rgnsize = type->regions[i].size;
 		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
 			break;
 	}
 
-	return (i < rgn->cnt) ? i : -1;
+	return (i < type->cnt) ? i : -1;
 }
 
 static u64 memblock_align_down(u64 addr, u64 size)
@@ -311,7 +309,7 @@ static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
 				base = ~(u64)0;
 			return base;
 		}
-		res_base = memblock.reserved.region[j].base;
+		res_base = memblock.reserved.regions[j].base;
 		if (res_base < size)
 			break;
 		base = memblock_align_down(res_base - size, align);
@@ -320,7 +318,7 @@ static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
 	return ~(u64)0;
 }
 
-static u64 __init memblock_alloc_nid_region(struct memblock_property *mp,
+static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
 				       u64 (*nid_range)(u64, u64, int *),
 				       u64 size, u64 align, int nid)
 {
@@ -350,7 +348,7 @@ static u64 __init memblock_alloc_nid_region(struct memblock_property *mp,
 u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
 			 u64 (*nid_range)(u64 start, u64 end, int *nid))
 {
-	struct memblock_region *mem = &memblock.memory;
+	struct memblock_type *mem = &memblock.memory;
 	int i;
 
 	BUG_ON(0 == size);
@@ -358,7 +356,7 @@ u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
 	size = memblock_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
-		u64 ret = memblock_alloc_nid_region(&mem->region[i],
+		u64 ret = memblock_alloc_nid_region(&mem->regions[i],
 					       nid_range,
 					       size, align, nid);
 		if (ret != ~(u64)0)
@@ -402,8 +400,8 @@ u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 		max_addr = MEMBLOCK_REAL_LIMIT;
 
 	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
-		u64 memblockbase = memblock.memory.region[i].base;
-		u64 memblocksize = memblock.memory.region[i].size;
+		u64 memblockbase = memblock.memory.regions[i].base;
+		u64 memblocksize = memblock.memory.regions[i].size;
 
 		if (memblocksize < size)
 			continue;
@@ -423,7 +421,7 @@ u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 					return 0;
 				return base;
 			}
-			res_base = memblock.reserved.region[j].base;
+			res_base = memblock.reserved.regions[j].base;
 			if (res_base < size)
 				break;
 			base = memblock_align_down(res_base - size, align);
@@ -442,7 +440,7 @@ u64 memblock_end_of_DRAM(void)
 {
 	int idx = memblock.memory.cnt - 1;
 
-	return (memblock.memory.region[idx].base + memblock.memory.region[idx].size);
+	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
 }
 
 /* You must call memblock_analyze() after this. */
@@ -450,7 +448,7 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 {
 	unsigned long i;
 	u64 limit;
-	struct memblock_property *p;
+	struct memblock_region *p;
 
 	if (!memory_limit)
 		return;
@@ -458,24 +456,24 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 	/* Truncate the memblock regions to satisfy the memory limit. */
 	limit = memory_limit;
 	for (i = 0; i < memblock.memory.cnt; i++) {
-		if (limit > memblock.memory.region[i].size) {
-			limit -= memblock.memory.region[i].size;
+		if (limit > memblock.memory.regions[i].size) {
+			limit -= memblock.memory.regions[i].size;
 			continue;
 		}
 
-		memblock.memory.region[i].size = limit;
+		memblock.memory.regions[i].size = limit;
 		memblock.memory.cnt = i + 1;
 		break;
 	}
 
-	if (memblock.memory.region[0].size < memblock.rmo_size)
-		memblock.rmo_size = memblock.memory.region[0].size;
+	if (memblock.memory.regions[0].size < memblock.rmo_size)
+		memblock.rmo_size = memblock.memory.regions[0].size;
 
 	memory_limit = memblock_end_of_DRAM();
 
 	/* And truncate any reserves above the limit also. */
 	for (i = 0; i < memblock.reserved.cnt; i++) {
-		p = &memblock.reserved.region[i];
+		p = &memblock.reserved.regions[i];
 
 		if (p->base > memory_limit)
 			p->size = 0;
@@ -494,9 +492,9 @@ int __init memblock_is_reserved(u64 addr)
 	int i;
 
 	for (i = 0; i < memblock.reserved.cnt; i++) {
-		u64 upper = memblock.reserved.region[i].base +
-			memblock.reserved.region[i].size - 1;
-		if ((addr >= memblock.reserved.region[i].base) && (addr <= upper))
+		u64 upper = memblock.reserved.regions[i].base +
+			memblock.reserved.regions[i].size - 1;
+		if ((addr >= memblock.reserved.regions[i].base) && (addr <= upper))
 			return 1;
 	}
 	return 0;
@@ -511,7 +509,7 @@ int memblock_is_region_reserved(u64 base, u64 size)
  * Given a <base, len>, find which memory regions belong to this range.
  * Adjust the request and return a contiguous chunk.
  */
-int memblock_find(struct memblock_property *res)
+int memblock_find(struct memblock_region *res)
 {
 	int i;
 	u64 rstart, rend;
@@ -520,8 +518,8 @@ int memblock_find(struct memblock_property *res)
 	rend = rstart + res->size - 1;
 
 	for (i = 0; i < memblock.memory.cnt; i++) {
-		u64 start = memblock.memory.region[i].base;
-		u64 end = start + memblock.memory.region[i].size - 1;
+		u64 start = memblock.memory.regions[i].base;
+		u64 end = start + memblock.memory.regions[i].size - 1;
 
 		if (start > rend)
 			return -1;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
