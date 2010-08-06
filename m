Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A46646B02A5
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FST0025327
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FVK61220680
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVhd026903
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 11/43] memblock/powerpc: Use new accessors
Date: Fri,  6 Aug 2010 15:14:52 +1000
Message-Id: <1281071724-28740-12-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/mm/hash_utils_64.c |    8 ++--
 arch/powerpc/mm/mem.c           |   92 ++++++++++++++-------------------------
 arch/powerpc/mm/numa.c          |   17 ++++---
 3 files changed, 46 insertions(+), 71 deletions(-)

diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index b1a3784..4072b87 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -588,7 +588,7 @@ static void __init htab_initialize(void)
 	unsigned long pteg_count;
 	unsigned long prot;
 	unsigned long base = 0, size = 0, limit;
-	int i;
+	struct memblock_region *reg;
 
 	DBG(" -> htab_initialize()\n");
 
@@ -659,9 +659,9 @@ static void __init htab_initialize(void)
 	 */
 
 	/* create bolted the linear mapping in the hash table */
-	for (i=0; i < memblock.memory.cnt; i++) {
-		base = (unsigned long)__va(memblock.memory.regions[i].base);
-		size = memblock.memory.region[i].size;
+	for_each_memblock(memory, reg) {
+		base = (unsigned long)__va(reg->base);
+		size = reg->size;
 
 		DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
 		    base, size, prot);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index a33f5c1..52df542 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -82,18 +82,11 @@ int page_is_ram(unsigned long pfn)
 	return pfn < max_pfn;
 #else
 	unsigned long paddr = (pfn << PAGE_SHIFT);
-	int i;
-	for (i=0; i < memblock.memory.cnt; i++) {
-		unsigned long base;
+	struct memblock_region *reg;
 
-		base = memblock.memory.regions[i].base;
-
-		if ((paddr >= base) &&
-			(paddr < (base + memblock.memory.regions[i].size))) {
+	for_each_memblock(memory, reg)
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
-	struct memblock_region res;
-	unsigned long pfn, len;
-	u64 end;
+	struct memblock_region *reg;
+	unsigned long end_pfn = start_pfn + nr_pages;
+	unsigned long tstart, tend;
 	int ret = -1;
 
-	res.base = (u64) start_pfn << PAGE_SHIFT;
-	res.size = (u64) nr_pages << PAGE_SHIFT;
-
-	end = res.base + res.size - 1;
-	while ((res.base < end) && (memblock_find(&res) >= 0)) {
-		pfn = (unsigned long)(res.base >> PAGE_SHIFT);
-		len = (unsigned long)(res.size >> PAGE_SHIFT);
-		ret = (*func)(pfn, len, arg);
+	for_each_memblock(memory, reg) {
+		tstart = max(start_pfn, memblock_region_base_pfn(reg));
+		tend = min(end_pfn, memblock_region_end_pfn(reg));
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
+	struct memblock_region *reg;
 	int boot_mapsize;
 
 	max_low_pfn = max_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
@@ -204,10 +193,10 @@ void __init do_init_bootmem(void)
 	boot_mapsize = init_bootmem_node(NODE_DATA(0), start >> PAGE_SHIFT, min_low_pfn, max_low_pfn);
 
 	/* Add active regions with valid PFNs */
-	for (i = 0; i < memblock.memory.cnt; i++) {
+	for_each_memblock(memory, reg) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = memblock.memory.regions[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+		start_pfn = memblock_region_base_pfn(reg);
+		end_pfn = memblock_region_end_pfn(reg);
 		add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -218,29 +207,21 @@ void __init do_init_bootmem(void)
 	free_bootmem_with_active_regions(0, lowmem_end_addr >> PAGE_SHIFT);
 
 	/* reserve the sections we're already using */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long addr = memblock.reserved.regions[i].base +
-				     memblock_size_bytes(&memblock.reserved, i) - 1;
-		if (addr < lowmem_end_addr)
-			reserve_bootmem(memblock.reserved.regions[i].base,
-					memblock_size_bytes(&memblock.reserved, i),
-					BOOTMEM_DEFAULT);
-		else if (memblock.reserved.regions[i].base < lowmem_end_addr) {
-			unsigned long adjusted_size = lowmem_end_addr -
-				      memblock.reserved.regions[i].base;
-			reserve_bootmem(memblock.reserved.regions[i].base,
-					adjusted_size, BOOTMEM_DEFAULT);
+	for_each_memblock(reserved, reg) {
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
-	for (i = 0; i < memblock.reserved.cnt; i++)
-		reserve_bootmem(memblock.reserved.regions[i].base,
-				memblock_size_bytes(&memblock.reserved, i),
-				BOOTMEM_DEFAULT);
-
+	for_each_memblock(reserved, reg)
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 #endif
 	/* XXX need to clip this if using highmem? */
 	sparse_memory_present_with_active_regions(0);
@@ -251,22 +232,15 @@ void __init do_init_bootmem(void)
 /* mark pages that don't exist as nosave */
 static int __init mark_nonram_nosave(void)
 {
-	unsigned long memblock_next_region_start_pfn,
-		      memblock_region_max_pfn;
-	int i;
-
-	for (i = 0; i < memblock.memory.cnt - 1; i++) {
-		memblock_region_max_pfn =
-			(memblock.memory.regions[i].base >> PAGE_SHIFT) +
-			(memblock.memory.regions[i].size >> PAGE_SHIFT);
-		memblock_next_region_start_pfn =
-			memblock.memory.regions[i+1].base >> PAGE_SHIFT;
-
-		if (memblock_region_max_pfn < memblock_next_region_start_pfn)
-			register_nosave_region(memblock_region_max_pfn,
-					       memblock_next_region_start_pfn);
+	struct memblock_region *reg, *prev = NULL;
+
+	for_each_memblock(memory, reg) {
+		if (prev &&
+		    memblock_region_end_pfn(prev) < memblock_region_base_pfn(reg))
+			register_nosave_region(memblock_region_end_pfn(prev),
+					       memblock_region_base_pfn(reg));
+		prev = reg;
 	}
-
 	return 0;
 }
 
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index aa731af..9ba9ba1 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -746,16 +746,17 @@ static void __init setup_nonnuma(void)
 	unsigned long top_of_ram = memblock_end_of_DRAM();
 	unsigned long total_ram = memblock_phys_mem_size();
 	unsigned long start_pfn, end_pfn;
-	unsigned int i, nid = 0;
+	unsigned int nid = 0;
+	struct memblock_region *reg;
 
 	printk(KERN_DEBUG "Top of RAM: 0x%lx, Total RAM: 0x%lx\n",
 	       top_of_ram, total_ram);
 	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
 	       (top_of_ram - total_ram) >> 20);
 
-	for (i = 0; i < memblock.memory.cnt; ++i) {
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+	for_each_memblock(memory, reg) {
+		start_pfn = memblock_region_base_pfn(reg);
+		end_pfn = memblock_region_end_pfn(reg);
 
 		fake_numa_create_new_node(end_pfn, &nid);
 		add_active_range(nid, start_pfn, end_pfn);
@@ -891,11 +892,11 @@ static struct notifier_block __cpuinitdata ppc64_numa_nb = {
 static void mark_reserved_regions_for_nid(int nid)
 {
 	struct pglist_data *node = NODE_DATA(nid);
-	int i;
+	struct memblock_region *reg;
 
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long physbase = memblock.reserved.region[i].base;
-		unsigned long size = memblock.reserved.region[i].size;
+	for_each_memblock(reserved, reg) {
+		unsigned long physbase = reg->base;
+		unsigned long size = reg->size;
 		unsigned long start_pfn = physbase >> PAGE_SHIFT;
 		unsigned long end_pfn = PFN_UP(physbase + size);
 		struct node_active_region node_ar;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
