Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 445836B026C
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:57:23 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 03/25] lmb: Introduce for_each_lmb() and new accessors, and use it
Date: Mon, 10 May 2010 19:38:37 +1000
Message-Id: <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Walk lmb's using for_each_lmb() and use lmb_region_base/end_pfn() for
getting to PFNs. Update sparc, powerpc, microblaze and sh.

Note: This is -almost- a direct conversion. It doesn't fix some existing
crap when/if lmb's aren't page aligned in the first place. This will be
sorted out separately.

This removes lmb_find() as well, which isn't used anymore

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/microblaze/mm/init.c       |   18 +++----
 arch/powerpc/mm/hash_utils_64.c |    8 ++--
 arch/powerpc/mm/mem.c           |   92 ++++++++++++++-------------------------
 arch/powerpc/mm/numa.c          |   17 ++++---
 arch/sh/kernel/setup.c          |   14 +++---
 arch/sparc/mm/init_64.c         |   30 +++++--------
 include/linux/lmb.h             |   56 ++++++++++++++++++------
 lib/lmb.c                       |   32 -------------
 8 files changed, 114 insertions(+), 153 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 9d58797..11048b8 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -69,16 +69,16 @@ static void __init paging_init(void)
 
 void __init setup_memory(void)
 {
-	int i;
 	unsigned long map_size;
+	struct lmb_region *reg;
+
 #ifndef CONFIG_MMU
 	u32 kernel_align_start, kernel_align_size;
 
 	/* Find main memory where is the kernel */
-	for (i = 0; i < lmb.memory.cnt; i++) {
-		memory_start = (u32) lmb.memory.regions[i].base;
-		memory_end = (u32) lmb.memory.regions[i].base
-				+ (u32) lmb.memory.region[i].size;
+	for_each_lmb(memory, reg) {
+		memory_start = (u32)reg->base;
+		memory_end = (u32) reg->base + reg->size;
 		if ((memory_start <= (u32)_text) &&
 					((u32)_text <= memory_end)) {
 			memory_size = memory_end - memory_start;
@@ -146,12 +146,10 @@ void __init setup_memory(void)
 	free_bootmem(memory_start, memory_size);
 
 	/* reserve allocate blocks */
-	for (i = 0; i < lmb.reserved.cnt; i++) {
+	for_each_lmb(reserved, reg) {
 		pr_debug("reserved %d - 0x%08x-0x%08x\n", i,
-			(u32) lmb.reserved.region[i].base,
-			(u32) lmb_size_bytes(&lmb.reserved, i));
-		reserve_bootmem(lmb.reserved.region[i].base,
-			lmb_size_bytes(&lmb.reserved, i) - 1, BOOTMEM_DEFAULT);
+			 (u32) reg->base, (u32) reg->size);
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 	}
 #ifdef CONFIG_MMU
 	init_bootmem_done = 1;
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 0a232f5..2fdeedf 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -588,7 +588,7 @@ static void __init htab_initialize(void)
 	unsigned long pteg_count;
 	unsigned long prot;
 	unsigned long base = 0, size = 0, limit;
-	int i;
+	struct lmb_region *reg;
 
 	DBG(" -> htab_initialize()\n");
 
@@ -659,9 +659,9 @@ static void __init htab_initialize(void)
 	 */
 
 	/* create bolted the linear mapping in the hash table */
-	for (i=0; i < lmb.memory.cnt; i++) {
-		base = (unsigned long)__va(lmb.memory.regions[i].base);
-		size = lmb.memory.region[i].size;
+	for_each_lmb(memory, reg) {
+		base = (unsigned long)__va(reg->base);
+		size = reg->size;
 
 		DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
 		    base, size, prot);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 65acb49..17a8027 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -82,18 +82,11 @@ int page_is_ram(unsigned long pfn)
 	return pfn < max_pfn;
 #else
 	unsigned long paddr = (pfn << PAGE_SHIFT);
-	int i;
-	for (i=0; i < lmb.memory.cnt; i++) {
-		unsigned long base;
+	struct lmb_region *reg;
 
-		base = lmb.memory.regions[i].base;
-
-		if ((paddr >= base) &&
-			(paddr < (base + lmb.memory.regions[i].size))) {
+	for_each_lmb(memory, reg)
+		if (paddr >= reg->base && paddr < (reg->base + reg->size))
 			return 1;
-		}
-	}
-
 	return 0;
 #endif
 }
@@ -149,23 +142,19 @@ int
 walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 		void *arg, int (*func)(unsigned long, unsigned long, void *))
 {
-	struct lmb_region res;
-	unsigned long pfn, len;
-	u64 end;
+	struct lmb_region *reg;
+	unsigned long end_pfn = start_pfn + nr_pages;
+	unsigned long tstart, tend;
 	int ret = -1;
 
-	res.base = (u64) start_pfn << PAGE_SHIFT;
-	res.size = (u64) nr_pages << PAGE_SHIFT;
-
-	end = res.base + res.size - 1;
-	while ((res.base < end) && (lmb_find(&res) >= 0)) {
-		pfn = (unsigned long)(res.base >> PAGE_SHIFT);
-		len = (unsigned long)(res.size >> PAGE_SHIFT);
-		ret = (*func)(pfn, len, arg);
+	for_each_lmb(memory, reg) {
+		tstart = max(start_pfn, lmb_region_base_pfn(reg));
+		tend = min(end_pfn, lmb_region_end_pfn(reg));
+		if (tstart >= tend)
+			continue;
+		ret = (*func)(tstart, tend - tstart, arg);
 		if (ret)
 			break;
-		res.base += (res.size + 1);
-		res.size = (end - res.base + 1);
 	}
 	return ret;
 }
@@ -179,9 +168,9 @@ EXPORT_SYMBOL_GPL(walk_system_ram_range);
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 void __init do_init_bootmem(void)
 {
-	unsigned long i;
 	unsigned long start, bootmap_pages;
 	unsigned long total_pages;
+	struct lmb_region *reg;
 	int boot_mapsize;
 
 	max_low_pfn = max_pfn = lmb_end_of_DRAM() >> PAGE_SHIFT;
@@ -204,10 +193,10 @@ void __init do_init_bootmem(void)
 	boot_mapsize = init_bootmem_node(NODE_DATA(0), start >> PAGE_SHIFT, min_low_pfn, max_low_pfn);
 
 	/* Add active regions with valid PFNs */
-	for (i = 0; i < lmb.memory.cnt; i++) {
+	for_each_lmb(memory, reg) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = lmb.memory.regions[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
+		start_pfn = lmb_region_base_pfn(reg);
+		end_pfn = lmb_region_end_pfn(reg);
 		add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -218,29 +207,21 @@ void __init do_init_bootmem(void)
 	free_bootmem_with_active_regions(0, lowmem_end_addr >> PAGE_SHIFT);
 
 	/* reserve the sections we're already using */
-	for (i = 0; i < lmb.reserved.cnt; i++) {
-		unsigned long addr = lmb.reserved.regions[i].base +
-				     lmb_size_bytes(&lmb.reserved, i) - 1;
-		if (addr < lowmem_end_addr)
-			reserve_bootmem(lmb.reserved.regions[i].base,
-					lmb_size_bytes(&lmb.reserved, i),
-					BOOTMEM_DEFAULT);
-		else if (lmb.reserved.regions[i].base < lowmem_end_addr) {
-			unsigned long adjusted_size = lowmem_end_addr -
-				      lmb.reserved.regions[i].base;
-			reserve_bootmem(lmb.reserved.regions[i].base,
-					adjusted_size, BOOTMEM_DEFAULT);
+	for_each_lmb(reserved, reg) {
+		unsigned long top = reg->base + reg->size - 1;
+		if (top < lowmem_end_addr)
+			reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
+		else if (reg->base < lowmem_end_addr) {
+			unsigned long trunc_size = lowmem_end_addr - reg->base;
+			reserve_bootmem(reg->base, trunc_size, BOOTMEM_DEFAULT);
 		}
 	}
 #else
 	free_bootmem_with_active_regions(0, max_pfn);
 
 	/* reserve the sections we're already using */
-	for (i = 0; i < lmb.reserved.cnt; i++)
-		reserve_bootmem(lmb.reserved.regions[i].base,
-				lmb_size_bytes(&lmb.reserved, i),
-				BOOTMEM_DEFAULT);
-
+	for_each_lmb(reserved, reg)
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 #endif
 	/* XXX need to clip this if using highmem? */
 	sparse_memory_present_with_active_regions(0);
@@ -251,22 +232,15 @@ void __init do_init_bootmem(void)
 /* mark pages that don't exist as nosave */
 static int __init mark_nonram_nosave(void)
 {
-	unsigned long lmb_next_region_start_pfn,
-		      lmb_region_max_pfn;
-	int i;
-
-	for (i = 0; i < lmb.memory.cnt - 1; i++) {
-		lmb_region_max_pfn =
-			(lmb.memory.regions[i].base >> PAGE_SHIFT) +
-			(lmb.memory.regions[i].size >> PAGE_SHIFT);
-		lmb_next_region_start_pfn =
-			lmb.memory.regions[i+1].base >> PAGE_SHIFT;
-
-		if (lmb_region_max_pfn < lmb_next_region_start_pfn)
-			register_nosave_region(lmb_region_max_pfn,
-					       lmb_next_region_start_pfn);
+	struct lmb_region *reg, *prev = NULL;
+
+	for_each_lmb(memory, reg) {
+		if (prev &&
+		    lmb_region_end_pfn(prev) < lmb_region_base_pfn(reg))
+			register_nosave_region(lmb_region_end_pfn(prev),
+					       lmb_region_base_pfn(reg));
+		prev = reg;
 	}
-
 	return 0;
 }
 
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index aace5e5..821d4ef 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -742,16 +742,17 @@ static void __init setup_nonnuma(void)
 	unsigned long top_of_ram = lmb_end_of_DRAM();
 	unsigned long total_ram = lmb_phys_mem_size();
 	unsigned long start_pfn, end_pfn;
-	unsigned int i, nid = 0;
+	unsigned int nid = 0;
+	struct lmb_region *reg;
 
 	printk(KERN_DEBUG "Top of RAM: 0x%lx, Total RAM: 0x%lx\n",
 	       top_of_ram, total_ram);
 	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
 	       (top_of_ram - total_ram) >> 20);
 
-	for (i = 0; i < lmb.memory.cnt; ++i) {
-		start_pfn = lmb.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
+	for_each_lmb(memory, reg) {
+		start_pfn = lmb_region_base_pfn(reg);
+		end_pfn = lmb_region_end_pfn(reg);
 
 		fake_numa_create_new_node(end_pfn, &nid);
 		add_active_range(nid, start_pfn, end_pfn);
@@ -887,11 +888,11 @@ static struct notifier_block __cpuinitdata ppc64_numa_nb = {
 static void mark_reserved_regions_for_nid(int nid)
 {
 	struct pglist_data *node = NODE_DATA(nid);
-	int i;
+	struct lmb_region *reg;
 
-	for (i = 0; i < lmb.reserved.cnt; i++) {
-		unsigned long physbase = lmb.reserved.region[i].base;
-		unsigned long size = lmb.reserved.region[i].size;
+	for_each_lmb(reserved, reg) {
+		unsigned long physbase = reg->base;
+		unsigned long size = reg->size;
 		unsigned long start_pfn = physbase >> PAGE_SHIFT;
 		unsigned long end_pfn = PFN_UP(physbase + size);
 		struct node_active_region node_ar;
diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
index 8870d6b..52f62f7 100644
--- a/arch/sh/kernel/setup.c
+++ b/arch/sh/kernel/setup.c
@@ -237,7 +237,7 @@ void __init setup_bootmem_allocator(unsigned long free_pfn)
 	unsigned long bootmap_size;
 	unsigned long bootmap_pages, bootmem_paddr;
 	u64 total_pages = (lmb_end_of_DRAM() - __MEMORY_START) >> PAGE_SHIFT;
-	int i;
+	struct lmb_region *reg;
 
 	bootmap_pages = bootmem_bootmap_pages(total_pages);
 
@@ -253,10 +253,10 @@ void __init setup_bootmem_allocator(unsigned long free_pfn)
 					 min_low_pfn, max_low_pfn);
 
 	/* Add active regions with valid PFNs. */
-	for (i = 0; i < lmb.memory.cnt; i++) {
+	for_each_lmb(memory, reg) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = lmb.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
+		start_pfn = lmb_region_base_pfn(reg);
+		end_pfn = lmb_region_end_pfn(reg);
 		__add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -267,10 +267,8 @@ void __init setup_bootmem_allocator(unsigned long free_pfn)
 	register_bootmem_low_pages();
 
 	/* Reserve the sections we're already using. */
-	for (i = 0; i < lmb.reserved.cnt; i++)
-		reserve_bootmem(lmb.reserved.region[i].base,
-				lmb_size_bytes(&lmb.reserved, i),
-				BOOTMEM_DEFAULT);
+	for_each_lmb(reserved, reg)
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 
 	node_set_online(0);
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 33628b4..04590c9 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -972,13 +972,13 @@ int of_node_to_nid(struct device_node *dp)
 
 static void __init add_node_ranges(void)
 {
-	int i;
+	struct lmb_region *reg;
 
-	for (i = 0; i < lmb.memory.cnt; i++) {
-		unsigned long size = lmb_size_bytes(&lmb.memory, i);
+	for_each_lmb(memory, reg) {
+		unsigned long size = reg->size;
 		unsigned long start, end;
 
-		start = lmb.memory.regions[i].base;
+		start = reg->base;
 		end = start + size;
 		while (start < end) {
 			unsigned long this_end;
@@ -1281,7 +1281,7 @@ static void __init bootmem_init_nonnuma(void)
 {
 	unsigned long top_of_ram = lmb_end_of_DRAM();
 	unsigned long total_ram = lmb_phys_mem_size();
-	unsigned int i;
+	struct lmb_region *reg;
 
 	numadbg("bootmem_init_nonnuma()\n");
 
@@ -1292,15 +1292,14 @@ static void __init bootmem_init_nonnuma(void)
 
 	init_node_masks_nonnuma();
 
-	for (i = 0; i < lmb.memory.cnt; i++) {
-		unsigned long size = lmb_size_bytes(&lmb.memory, i);
+	for_each_lmb(memory, reg) {
 		unsigned long start_pfn, end_pfn;
 
-		if (!size)
+		if (!reg->size)
 			continue;
 
-		start_pfn = lmb.memory.regions[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + lmb_size_pages(&lmb.memory, i);
+		start_pfn = lmb_region_base_pfn(reg);
+		end_pfn = lmb_region_end_pfn(reg);
 		add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -1334,17 +1333,12 @@ static void __init reserve_range_in_node(int nid, unsigned long start,
 
 static void __init trim_reserved_in_node(int nid)
 {
-	int i;
+	struct lmb_region *reg;
 
 	numadbg("  trim_reserved_in_node(%d)\n", nid);
 
-	for (i = 0; i < lmb.reserved.cnt; i++) {
-		unsigned long start = lmb.reserved.regions[i].base;
-		unsigned long size = lmb_size_bytes(&lmb.reserved, i);
-		unsigned long end = start + size;
-
-		reserve_range_in_node(nid, start, end);
-	}
+	for_each_lmb(reserved, reg)
+		reserve_range_in_node(nid, reg->base, reg->base + reg->size);
 }
 
 static void __init bootmem_init_one_node(int nid)
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index de8031f..c2410fe 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -58,32 +58,60 @@ extern u64 lmb_end_of_DRAM(void);
 extern void __init lmb_enforce_memory_limit(u64 memory_limit);
 extern int __init lmb_is_reserved(u64 addr);
 extern int lmb_is_region_reserved(u64 base, u64 size);
-extern int lmb_find(struct lmb_region *res);
 
 extern void lmb_dump_all(void);
 
-static inline u64
-lmb_size_bytes(struct lmb_type *type, unsigned long region_nr)
+/*
+ * pfn conversion functions
+ *
+ * While the memory LMBs should always be page aligned, the reserved
+ * LMBs may not be. This accessor attempt to provide a very clear
+ * idea of what they return for such non aligned LMBs.
+ */
+
+/**
+ * lmb_region_base_pfn - Return the lowest pfn intersecting with the region
+ * @reg: lmb_region structure
+ */
+static inline unsigned long lmb_region_base_pfn(const struct lmb_region *reg)
 {
-	return type->regions[region_nr].size;
+	return reg->base >> PAGE_SHIFT;
 }
-static inline u64
-lmb_size_pages(struct lmb_type *type, unsigned long region_nr)
+
+/**
+ * lmb_region_last_pfn - Return the highest pfn intersecting with the region
+ * @reg: lmb_region structure
+ */
+static inline unsigned long lmb_region_last_pfn(const struct lmb_region *reg)
 {
-	return lmb_size_bytes(type, region_nr) >> PAGE_SHIFT;
+	return (reg->base + reg->size - 1) >> PAGE_SHIFT;
 }
-static inline u64
-lmb_start_pfn(struct lmb_type *type, unsigned long region_nr)
+
+/**
+ * lmb_region_end_pfn - Return the pfn of the first page following the region
+ *                      but not intersecting it
+ * @reg: lmb_region structure
+ */
+static inline unsigned long lmb_region_end_pfn(const struct lmb_region *reg)
 {
-	return type->regions[region_nr].base >> PAGE_SHIFT;
+	return lmb_region_last_pfn(reg) + 1;
 }
-static inline u64
-lmb_end_pfn(struct lmb_type *type, unsigned long region_nr)
+
+/**
+ * lmb_region_pages - Return the number of pages covering a region
+ * @reg: lmb_region structure
+ */
+static inline unsigned long lmb_region_pages(const struct lmb_region *reg)
 {
-	return lmb_start_pfn(type, region_nr) +
-	       lmb_size_pages(type, region_nr);
+	return lmb_region_end_pfn(reg) - lmb_region_end_pfn(reg);
 }
 
+#define for_each_lmb(lmb_type, region)					\
+	for (reg = lmb.lmb_type.regions;				\
+	     region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);	\
+	     region++)
+
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_LMB_H */
diff --git a/lib/lmb.c b/lib/lmb.c
index f07337e..5f21033 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -505,35 +505,3 @@ int lmb_is_region_reserved(u64 base, u64 size)
 	return lmb_overlaps_region(&lmb.reserved, base, size);
 }
 
-/*
- * Given a <base, len>, find which memory regions belong to this range.
- * Adjust the request and return a contiguous chunk.
- */
-int lmb_find(struct lmb_region *res)
-{
-	int i;
-	u64 rstart, rend;
-
-	rstart = res->base;
-	rend = rstart + res->size - 1;
-
-	for (i = 0; i < lmb.memory.cnt; i++) {
-		u64 start = lmb.memory.regions[i].base;
-		u64 end = start + lmb.memory.regions[i].size - 1;
-
-		if (start > rend)
-			return -1;
-
-		if ((end >= rstart) && (start < rend)) {
-			/* adjust the request */
-			if (rstart < start)
-				rstart = start;
-			if (rend > end)
-				rend = end;
-			res->base = rstart;
-			res->size = rend - rstart + 1;
-			return 0;
-		}
-	}
-	return -1;
-}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
