Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDA46200C2
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:39:39 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 01/25] lmb: Rename lmb_region to lmb_type and lmb_property to lmb_region
Date: Mon, 10 May 2010 19:38:35 +1000
Message-Id: <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/microblaze/mm/init.c                |    4 +-
 arch/powerpc/mm/hash_utils_64.c          |    2 +-
 arch/powerpc/mm/mem.c                    |   26 +++---
 arch/powerpc/platforms/embedded6xx/wii.c |    2 +-
 arch/sparc/mm/init_64.c                  |    6 +-
 include/linux/lmb.h                      |   24 ++--
 lib/lmb.c                                |  168 +++++++++++++++---------------
 7 files changed, 115 insertions(+), 117 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index f42c2dd..9d58797 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -76,8 +76,8 @@ void __init setup_memory(void)
 
 	/* Find main memory where is the kernel */
 	for (i = 0; i < lmb.memory.cnt; i++) {
-		memory_start = (u32) lmb.memory.region[i].base;
-		memory_end = (u32) lmb.memory.region[i].base
+		memory_start = (u32) lmb.memory.regions[i].base;
+		memory_end = (u32) lmb.memory.regions[i].base
 				+ (u32) lmb.memory.region[i].size;
 		if ((memory_start <= (u32)_text) &&
 					((u32)_text <= memory_end)) {
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 3ecdcec..0a232f5 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -660,7 +660,7 @@ static void __init htab_initialize(void)
 
 	/* create bolted the linear mapping in the hash table */
 	for (i=0; i < lmb.memory.cnt; i++) {
-		base = (unsigned long)__va(lmb.memory.region[i].base);
+		base = (unsigned long)__va(lmb.memory.regions[i].base);
 		size = lmb.memory.region[i].size;
 
 		DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 0f594d7..65acb49 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -86,10 +86,10 @@ int page_is_ram(unsigned long pfn)
 	for (i=0; i < lmb.memory.cnt; i++) {
 		unsigned long base;
 
-		base = lmb.memory.region[i].base;
+		base = lmb.memory.regions[i].base;
 
 		if ((paddr >= base) &&
-			(paddr < (base + lmb.memory.region[i].size))) {
+			(paddr < (base + lmb.memory.regions[i].size))) {
 			return 1;
 		}
 	}
@@ -149,7 +149,7 @@ int
 walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 		void *arg, int (*func)(unsigned long, unsigned long, void *))
 {
-	struct lmb_property res;
+	struct lmb_region res;
 	unsigned long pfn, len;
 	u64 end;
 	int ret = -1;
@@ -206,7 +206,7 @@ void __init do_init_bootmem(void)
 	/* Add active regions with valid PFNs */
 	for (i = 0; i < lmb.memory.cnt; i++) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = lmb.memory.region[i].base >> PAGE_SHIFT;
+		start_pfn = lmb.memory.regions[i].base >> PAGE_SHIFT;
 		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
 		add_active_range(0, start_pfn, end_pfn);
 	}
@@ -219,16 +219,16 @@ void __init do_init_bootmem(void)
 
 	/* reserve the sections we're already using */
 	for (i = 0; i < lmb.reserved.cnt; i++) {
-		unsigned long addr = lmb.reserved.region[i].base +
+		unsigned long addr = lmb.reserved.regions[i].base +
 				     lmb_size_bytes(&lmb.reserved, i) - 1;
 		if (addr < lowmem_end_addr)
-			reserve_bootmem(lmb.reserved.region[i].base,
+			reserve_bootmem(lmb.reserved.regions[i].base,
 					lmb_size_bytes(&lmb.reserved, i),
 					BOOTMEM_DEFAULT);
-		else if (lmb.reserved.region[i].base < lowmem_end_addr) {
+		else if (lmb.reserved.regions[i].base < lowmem_end_addr) {
 			unsigned long adjusted_size = lowmem_end_addr -
-				      lmb.reserved.region[i].base;
-			reserve_bootmem(lmb.reserved.region[i].base,
+				      lmb.reserved.regions[i].base;
+			reserve_bootmem(lmb.reserved.regions[i].base,
 					adjusted_size, BOOTMEM_DEFAULT);
 		}
 	}
@@ -237,7 +237,7 @@ void __init do_init_bootmem(void)
 
 	/* reserve the sections we're already using */
 	for (i = 0; i < lmb.reserved.cnt; i++)
-		reserve_bootmem(lmb.reserved.region[i].base,
+		reserve_bootmem(lmb.reserved.regions[i].base,
 				lmb_size_bytes(&lmb.reserved, i),
 				BOOTMEM_DEFAULT);
 
@@ -257,10 +257,10 @@ static int __init mark_nonram_nosave(void)
 
 	for (i = 0; i < lmb.memory.cnt - 1; i++) {
 		lmb_region_max_pfn =
-			(lmb.memory.region[i].base >> PAGE_SHIFT) +
-			(lmb.memory.region[i].size >> PAGE_SHIFT);
+			(lmb.memory.regions[i].base >> PAGE_SHIFT) +
+			(lmb.memory.regions[i].size >> PAGE_SHIFT);
 		lmb_next_region_start_pfn =
-			lmb.memory.region[i+1].base >> PAGE_SHIFT;
+			lmb.memory.regions[i+1].base >> PAGE_SHIFT;
 
 		if (lmb_region_max_pfn < lmb_next_region_start_pfn)
 			register_nosave_region(lmb_region_max_pfn,
diff --git a/arch/powerpc/platforms/embedded6xx/wii.c b/arch/powerpc/platforms/embedded6xx/wii.c
index 57e5b60..42f346c 100644
--- a/arch/powerpc/platforms/embedded6xx/wii.c
+++ b/arch/powerpc/platforms/embedded6xx/wii.c
@@ -65,7 +65,7 @@ static int __init page_aligned(unsigned long x)
 
 void __init wii_memory_fixups(void)
 {
-	struct lmb_property *p = lmb.memory.region;
+	struct lmb_region *p = lmb.memory.region;
 
 	/*
 	 * This is part of a workaround to allow the use of two
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index b2831dc..33628b4 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -978,7 +978,7 @@ static void __init add_node_ranges(void)
 		unsigned long size = lmb_size_bytes(&lmb.memory, i);
 		unsigned long start, end;
 
-		start = lmb.memory.region[i].base;
+		start = lmb.memory.regions[i].base;
 		end = start + size;
 		while (start < end) {
 			unsigned long this_end;
@@ -1299,7 +1299,7 @@ static void __init bootmem_init_nonnuma(void)
 		if (!size)
 			continue;
 
-		start_pfn = lmb.memory.region[i].base >> PAGE_SHIFT;
+		start_pfn = lmb.memory.regions[i].base >> PAGE_SHIFT;
 		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
 		add_active_range(0, start_pfn, end_pfn);
 	}
@@ -1339,7 +1339,7 @@ static void __init trim_reserved_in_node(int nid)
 	numadbg("  trim_reserved_in_node(%d)\n", nid);
 
 	for (i = 0; i < lmb.reserved.cnt; i++) {
-		unsigned long start = lmb.reserved.region[i].base;
+		unsigned long start = lmb.reserved.regions[i].base;
 		unsigned long size = lmb_size_bytes(&lmb.reserved, i);
 		unsigned long end = start + size;
 
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index f3d1433..d225d78 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -18,22 +18,22 @@
 
 #define MAX_LMB_REGIONS 128
 
-struct lmb_property {
+struct lmb_region {
 	u64 base;
 	u64 size;
 };
 
-struct lmb_region {
+struct lmb_type {
 	unsigned long cnt;
 	u64 size;
-	struct lmb_property region[MAX_LMB_REGIONS+1];
+	struct lmb_region regions[MAX_LMB_REGIONS+1];
 };
 
 struct lmb {
 	unsigned long debug;
 	u64 rmo_size;
-	struct lmb_region memory;
-	struct lmb_region reserved;
+	struct lmb_type memory;
+	struct lmb_type reserved;
 };
 
 extern struct lmb lmb;
@@ -56,27 +56,27 @@ extern u64 lmb_end_of_DRAM(void);
 extern void __init lmb_enforce_memory_limit(u64 memory_limit);
 extern int __init lmb_is_reserved(u64 addr);
 extern int lmb_is_region_reserved(u64 base, u64 size);
-extern int lmb_find(struct lmb_property *res);
+extern int lmb_find(struct lmb_region *res);
 
 extern void lmb_dump_all(void);
 
 static inline u64
-lmb_size_bytes(struct lmb_region *type, unsigned long region_nr)
+lmb_size_bytes(struct lmb_type *type, unsigned long region_nr)
 {
-	return type->region[region_nr].size;
+	return type->regions[region_nr].size;
 }
 static inline u64
-lmb_size_pages(struct lmb_region *type, unsigned long region_nr)
+lmb_size_pages(struct lmb_type *type, unsigned long region_nr)
 {
 	return lmb_size_bytes(type, region_nr) >> PAGE_SHIFT;
 }
 static inline u64
-lmb_start_pfn(struct lmb_region *type, unsigned long region_nr)
+lmb_start_pfn(struct lmb_type *type, unsigned long region_nr)
 {
-	return type->region[region_nr].base >> PAGE_SHIFT;
+	return type->regions[region_nr].base >> PAGE_SHIFT;
 }
 static inline u64
-lmb_end_pfn(struct lmb_region *type, unsigned long region_nr)
+lmb_end_pfn(struct lmb_type *type, unsigned long region_nr)
 {
 	return lmb_start_pfn(type, region_nr) +
 	       lmb_size_pages(type, region_nr);
diff --git a/lib/lmb.c b/lib/lmb.c
index b1fc526..f07337e 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -29,7 +29,7 @@ static int __init early_lmb(char *p)
 }
 early_param("lmb", early_lmb);
 
-static void lmb_dump(struct lmb_region *region, char *name)
+static void lmb_dump(struct lmb_type *region, char *name)
 {
 	unsigned long long base, size;
 	int i;
@@ -37,8 +37,8 @@ static void lmb_dump(struct lmb_region *region, char *name)
 	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
 
 	for (i = 0; i < region->cnt; i++) {
-		base = region->region[i].base;
-		size = region->region[i].size;
+		base = region->regions[i].base;
+		size = region->regions[i].size;
 
 		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
 		    name, i, base, base + size - 1, size);
@@ -74,34 +74,34 @@ static long lmb_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
 	return 0;
 }
 
-static long lmb_regions_adjacent(struct lmb_region *rgn,
+static long lmb_regions_adjacent(struct lmb_type *type,
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
 
 	return lmb_addrs_adjacent(base1, size1, base2, size2);
 }
 
-static void lmb_remove_region(struct lmb_region *rgn, unsigned long r)
+static void lmb_remove_region(struct lmb_type *type, unsigned long r)
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
-static void lmb_coalesce_regions(struct lmb_region *rgn,
+static void lmb_coalesce_regions(struct lmb_type *type,
 		unsigned long r1, unsigned long r2)
 {
-	rgn->region[r1].size += rgn->region[r2].size;
-	lmb_remove_region(rgn, r2);
+	type->regions[r1].size += type->regions[r2].size;
+	lmb_remove_region(type, r2);
 }
 
 void __init lmb_init(void)
@@ -109,13 +109,13 @@ void __init lmb_init(void)
 	/* Create a dummy zero size LMB which will get coalesced away later.
 	 * This simplifies the lmb_add() code below...
 	 */
-	lmb.memory.region[0].base = 0;
-	lmb.memory.region[0].size = 0;
+	lmb.memory.regions[0].base = 0;
+	lmb.memory.regions[0].size = 0;
 	lmb.memory.cnt = 1;
 
 	/* Ditto. */
-	lmb.reserved.region[0].base = 0;
-	lmb.reserved.region[0].size = 0;
+	lmb.reserved.regions[0].base = 0;
+	lmb.reserved.regions[0].size = 0;
 	lmb.reserved.cnt = 1;
 }
 
@@ -126,24 +126,24 @@ void __init lmb_analyze(void)
 	lmb.memory.size = 0;
 
 	for (i = 0; i < lmb.memory.cnt; i++)
-		lmb.memory.size += lmb.memory.region[i].size;
+		lmb.memory.size += lmb.memory.regions[i].size;
 }
 
-static long lmb_add_region(struct lmb_region *rgn, u64 base, u64 size)
+static long lmb_add_region(struct lmb_type *type, u64 base, u64 size)
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
 
 	/* First try and coalesce this LMB with another. */
-	for (i = 0; i < rgn->cnt; i++) {
-		u64 rgnbase = rgn->region[i].base;
-		u64 rgnsize = rgn->region[i].size;
+	for (i = 0; i < type->cnt; i++) {
+		u64 rgnbase = type->regions[i].base;
+		u64 rgnsize = type->regions[i].size;
 
 		if ((rgnbase == base) && (rgnsize == size))
 			/* Already have this region, so we're done */
@@ -151,61 +151,59 @@ static long lmb_add_region(struct lmb_region *rgn, u64 base, u64 size)
 
 		adjacent = lmb_addrs_adjacent(base, size, rgnbase, rgnsize);
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
 
-	if ((i < rgn->cnt - 1) && lmb_regions_adjacent(rgn, i, i+1)) {
-		lmb_coalesce_regions(rgn, i, i+1);
+	if ((i < type->cnt - 1) && lmb_regions_adjacent(type, i, i+1)) {
+		lmb_coalesce_regions(type, i, i+1);
 		coalesced++;
 	}
 
 	if (coalesced)
 		return coalesced;
-	if (rgn->cnt >= MAX_LMB_REGIONS)
+	if (type->cnt >= MAX_LMB_REGIONS)
 		return -1;
 
 	/* Couldn't coalesce the LMB, so add it to the sorted table. */
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
 
 long lmb_add(u64 base, u64 size)
 {
-	struct lmb_region *_rgn = &lmb.memory;
-
 	/* On pSeries LPAR systems, the first LMB is our RMO region. */
 	if (base == 0)
 		lmb.rmo_size = size;
 
-	return lmb_add_region(_rgn, base, size);
+	return lmb_add_region(&lmb.memory, base, size);
 
 }
 
-static long __lmb_remove(struct lmb_region *rgn, u64 base, u64 size)
+static long __lmb_remove(struct lmb_type *type, u64 base, u64 size)
 {
 	u64 rgnbegin, rgnend;
 	u64 end = base + size;
@@ -214,34 +212,34 @@ static long __lmb_remove(struct lmb_region *rgn, u64 base, u64 size)
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
-		lmb_remove_region(rgn, i);
+		lmb_remove_region(type, i);
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
 
@@ -249,8 +247,8 @@ static long __lmb_remove(struct lmb_region *rgn, u64 base, u64 size)
 	 * We need to split the entry -  adjust the current one to the
 	 * beginging of the hole and add the region after hole.
 	 */
-	rgn->region[i].size = base - rgn->region[i].base;
-	return lmb_add_region(rgn, end, rgnend - end);
+	type->regions[i].size = base - type->regions[i].base;
+	return lmb_add_region(type, end, rgnend - end);
 }
 
 long lmb_remove(u64 base, u64 size)
@@ -265,25 +263,25 @@ long __init lmb_free(u64 base, u64 size)
 
 long __init lmb_reserve(u64 base, u64 size)
 {
-	struct lmb_region *_rgn = &lmb.reserved;
+	struct lmb_type *_rgn = &lmb.reserved;
 
 	BUG_ON(0 == size);
 
 	return lmb_add_region(_rgn, base, size);
 }
 
-long lmb_overlaps_region(struct lmb_region *rgn, u64 base, u64 size)
+long lmb_overlaps_region(struct lmb_type *type, u64 base, u64 size)
 {
 	unsigned long i;
 
-	for (i = 0; i < rgn->cnt; i++) {
-		u64 rgnbase = rgn->region[i].base;
-		u64 rgnsize = rgn->region[i].size;
+	for (i = 0; i < type->cnt; i++) {
+		u64 rgnbase = type->regions[i].base;
+		u64 rgnsize = type->regions[i].size;
 		if (lmb_addrs_overlap(base, size, rgnbase, rgnsize))
 			break;
 	}
 
-	return (i < rgn->cnt) ? i : -1;
+	return (i < type->cnt) ? i : -1;
 }
 
 static u64 lmb_align_down(u64 addr, u64 size)
@@ -311,7 +309,7 @@ static u64 __init lmb_alloc_nid_unreserved(u64 start, u64 end,
 				base = ~(u64)0;
 			return base;
 		}
-		res_base = lmb.reserved.region[j].base;
+		res_base = lmb.reserved.regions[j].base;
 		if (res_base < size)
 			break;
 		base = lmb_align_down(res_base - size, align);
@@ -320,7 +318,7 @@ static u64 __init lmb_alloc_nid_unreserved(u64 start, u64 end,
 	return ~(u64)0;
 }
 
-static u64 __init lmb_alloc_nid_region(struct lmb_property *mp,
+static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
 				       u64 (*nid_range)(u64, u64, int *),
 				       u64 size, u64 align, int nid)
 {
@@ -350,7 +348,7 @@ static u64 __init lmb_alloc_nid_region(struct lmb_property *mp,
 u64 __init lmb_alloc_nid(u64 size, u64 align, int nid,
 			 u64 (*nid_range)(u64 start, u64 end, int *nid))
 {
-	struct lmb_region *mem = &lmb.memory;
+	struct lmb_type *mem = &lmb.memory;
 	int i;
 
 	BUG_ON(0 == size);
@@ -358,7 +356,7 @@ u64 __init lmb_alloc_nid(u64 size, u64 align, int nid,
 	size = lmb_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
-		u64 ret = lmb_alloc_nid_region(&mem->region[i],
+		u64 ret = lmb_alloc_nid_region(&mem->regions[i],
 					       nid_range,
 					       size, align, nid);
 		if (ret != ~(u64)0)
@@ -402,8 +400,8 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 		max_addr = LMB_REAL_LIMIT;
 
 	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
-		u64 lmbbase = lmb.memory.region[i].base;
-		u64 lmbsize = lmb.memory.region[i].size;
+		u64 lmbbase = lmb.memory.regions[i].base;
+		u64 lmbsize = lmb.memory.regions[i].size;
 
 		if (lmbsize < size)
 			continue;
@@ -423,7 +421,7 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 					return 0;
 				return base;
 			}
-			res_base = lmb.reserved.region[j].base;
+			res_base = lmb.reserved.regions[j].base;
 			if (res_base < size)
 				break;
 			base = lmb_align_down(res_base - size, align);
@@ -442,7 +440,7 @@ u64 lmb_end_of_DRAM(void)
 {
 	int idx = lmb.memory.cnt - 1;
 
-	return (lmb.memory.region[idx].base + lmb.memory.region[idx].size);
+	return (lmb.memory.regions[idx].base + lmb.memory.regions[idx].size);
 }
 
 /* You must call lmb_analyze() after this. */
@@ -450,7 +448,7 @@ void __init lmb_enforce_memory_limit(u64 memory_limit)
 {
 	unsigned long i;
 	u64 limit;
-	struct lmb_property *p;
+	struct lmb_region *p;
 
 	if (!memory_limit)
 		return;
@@ -458,24 +456,24 @@ void __init lmb_enforce_memory_limit(u64 memory_limit)
 	/* Truncate the lmb regions to satisfy the memory limit. */
 	limit = memory_limit;
 	for (i = 0; i < lmb.memory.cnt; i++) {
-		if (limit > lmb.memory.region[i].size) {
-			limit -= lmb.memory.region[i].size;
+		if (limit > lmb.memory.regions[i].size) {
+			limit -= lmb.memory.regions[i].size;
 			continue;
 		}
 
-		lmb.memory.region[i].size = limit;
+		lmb.memory.regions[i].size = limit;
 		lmb.memory.cnt = i + 1;
 		break;
 	}
 
-	if (lmb.memory.region[0].size < lmb.rmo_size)
-		lmb.rmo_size = lmb.memory.region[0].size;
+	if (lmb.memory.regions[0].size < lmb.rmo_size)
+		lmb.rmo_size = lmb.memory.regions[0].size;
 
 	memory_limit = lmb_end_of_DRAM();
 
 	/* And truncate any reserves above the limit also. */
 	for (i = 0; i < lmb.reserved.cnt; i++) {
-		p = &lmb.reserved.region[i];
+		p = &lmb.reserved.regions[i];
 
 		if (p->base > memory_limit)
 			p->size = 0;
@@ -494,9 +492,9 @@ int __init lmb_is_reserved(u64 addr)
 	int i;
 
 	for (i = 0; i < lmb.reserved.cnt; i++) {
-		u64 upper = lmb.reserved.region[i].base +
-			lmb.reserved.region[i].size - 1;
-		if ((addr >= lmb.reserved.region[i].base) && (addr <= upper))
+		u64 upper = lmb.reserved.regions[i].base +
+			lmb.reserved.regions[i].size - 1;
+		if ((addr >= lmb.reserved.regions[i].base) && (addr <= upper))
 			return 1;
 	}
 	return 0;
@@ -511,7 +509,7 @@ int lmb_is_region_reserved(u64 base, u64 size)
  * Given a <base, len>, find which memory regions belong to this range.
  * Adjust the request and return a contiguous chunk.
  */
-int lmb_find(struct lmb_property *res)
+int lmb_find(struct lmb_region *res)
 {
 	int i;
 	u64 rstart, rend;
@@ -520,8 +518,8 @@ int lmb_find(struct lmb_property *res)
 	rend = rstart + res->size - 1;
 
 	for (i = 0; i < lmb.memory.cnt; i++) {
-		u64 start = lmb.memory.region[i].base;
-		u64 end = start + lmb.memory.region[i].size - 1;
+		u64 start = lmb.memory.regions[i].base;
+		u64 end = start + lmb.memory.regions[i].size - 1;
 
 		if (start > rend)
 			return -1;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
