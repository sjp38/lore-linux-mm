Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A076600804
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:40 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765Bt1q013202
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:55 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765Fb3Q606294
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:37 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FbPO026183
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:37 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 19/43] memblock: Remove rmo_size, burry it in arch/powerpc where it belongs
Date: Fri,  6 Aug 2010 15:15:00 +1000
Message-Id: <1281071724-28740-20-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

The RMA (RMO is a misnomer) is a concept specific to ppc64 (in fact
server ppc64 though I hijack it on embedded ppc64 for similar purposes)
and represents the area of memory that can be accessed in real mode
(aka with MMU off), or on embedded, from the exception vectors (which
is bolted in the TLB) which pretty much boils down to the same thing.

We take that out of the generic MEMBLOCK data structure and move it into
arch/powerpc where it belongs, renaming it to "RMA" while at it.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/include/asm/mmu.h  |   12 ++++++++++++
 arch/powerpc/kernel/head_40x.S  |    6 +-----
 arch/powerpc/kernel/paca.c      |    2 +-
 arch/powerpc/kernel/prom.c      |   29 ++++++++---------------------
 arch/powerpc/kernel/rtas.c      |    2 +-
 arch/powerpc/kernel/setup_64.c  |    2 +-
 arch/powerpc/mm/40x_mmu.c       |   14 +++++++++++++-
 arch/powerpc/mm/44x_mmu.c       |   14 ++++++++++++++
 arch/powerpc/mm/fsl_booke_mmu.c |    9 +++++++++
 arch/powerpc/mm/hash_utils_64.c |   22 +++++++++++++++++++++-
 arch/powerpc/mm/init_32.c       |   14 ++++++++++++++
 arch/powerpc/mm/init_64.c       |    1 +
 arch/powerpc/mm/ppc_mmu_32.c    |   15 +++++++++++++++
 arch/powerpc/mm/tlb_nohash.c    |   14 ++++++++++++++
 include/linux/memblock.h        |    1 -
 mm/memblock.c                   |    8 --------
 16 files changed, 125 insertions(+), 40 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu.h b/arch/powerpc/include/asm/mmu.h
index 7ebf42e..bb40a06 100644
--- a/arch/powerpc/include/asm/mmu.h
+++ b/arch/powerpc/include/asm/mmu.h
@@ -2,6 +2,8 @@
 #define _ASM_POWERPC_MMU_H_
 #ifdef __KERNEL__
 
+#include <linux/types.h>
+
 #include <asm/asm-compat.h>
 #include <asm/feature-fixups.h>
 
@@ -82,6 +84,16 @@ extern unsigned int __start___mmu_ftr_fixup, __stop___mmu_ftr_fixup;
 extern void early_init_mmu(void);
 extern void early_init_mmu_secondary(void);
 
+extern void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				       phys_addr_t first_memblock_size);
+
+#ifdef CONFIG_PPC64
+/* This is our real memory area size on ppc64 server, on embedded, we
+ * make it match the size our of bolted TLB area
+ */
+extern u64 ppc64_rma_size;
+#endif /* CONFIG_PPC64 */
+
 #endif /* !__ASSEMBLY__ */
 
 /* The kernel use the constants below to index in the page sizes array.
diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
index a90625f..8278e8b 100644
--- a/arch/powerpc/kernel/head_40x.S
+++ b/arch/powerpc/kernel/head_40x.S
@@ -923,11 +923,7 @@ initial_mmu:
 	mtspr	SPRN_PID,r0
 	sync
 
-	/* Configure and load two entries into TLB slots 62 and 63.
-	 * In case we are pinning TLBs, these are reserved in by the
-	 * other TLB functions.  If not reserving, then it doesn't
-	 * matter where they are loaded.
-	 */
+	/* Configure and load one entry into TLB slots 63 */
 	clrrwi	r4,r4,10		/* Mask off the real page number */
 	ori	r4,r4,(TLB_WR | TLB_EX)	/* Set the write and execute bits */
 
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 139a773..b9ffd7d 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -117,7 +117,7 @@ void __init allocate_pacas(void)
 	 * the first segment. On iSeries they must be within the area mapped
 	 * by the HV, which is HvPagesToMap * HVPAGESIZE bytes.
 	 */
-	limit = min(0x10000000ULL, memblock.rmo_size);
+	limit = min(0x10000000ULL, ppc64_rma_size);
 	if (firmware_has_feature(FW_FEATURE_ISERIES))
 		limit = min(limit, HvPagesToMap * HVPAGESIZE);
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index 3aec0b9..c3c6a88 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -66,6 +66,7 @@
 int __initdata iommu_is_off;
 int __initdata iommu_force_on;
 unsigned long tce_alloc_start, tce_alloc_end;
+u64 ppc64_rma_size;
 #endif
 
 static int __init early_parse_mem(char *p)
@@ -492,7 +493,7 @@ static int __init early_init_dt_scan_memory_ppc(unsigned long node,
 
 void __init early_init_dt_add_memory_arch(u64 base, u64 size)
 {
-#if defined(CONFIG_PPC64)
+#ifdef CONFIG_PPC64
 	if (iommu_is_off) {
 		if (base >= 0x80000000ul)
 			return;
@@ -501,9 +502,13 @@ void __init early_init_dt_add_memory_arch(u64 base, u64 size)
 	}
 #endif
 
-	memblock_add(base, size);
-
+	/* First MEMBLOCK added, do some special initializations */
+	if (memstart_addr == ~(phys_addr_t)0)
+		setup_initial_memory_limit(base, size);
 	memstart_addr = min((u64)memstart_addr, base);
+
+	/* Add the chunk to the MEMBLOCK list */
+	memblock_add(base, size);
 }
 
 u64 __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
@@ -655,22 +660,6 @@ static void __init phyp_dump_reserve_mem(void)
 static inline void __init phyp_dump_reserve_mem(void) {}
 #endif /* CONFIG_PHYP_DUMP  && CONFIG_PPC_RTAS */
 
-static void set_boot_memory_limit(void)
-{
-#ifdef CONFIG_PPC32
-	/* 601 can only access 16MB at the moment */
-	if (PVR_VER(mfspr(SPRN_PVR)) == 1)
-		memblock_set_current_limit(0x01000000);
-	/* 8xx can only access 8MB at the moment */
-	else if (PVR_VER(mfspr(SPRN_PVR)) == 0x50)
-		memblock_set_current_limit(0x00800000);
-	else
-		memblock_set_current_limit(0x10000000);
-#else
-	memblock_set_current_limit(memblock.rmo_size);
-#endif
-}
-
 void __init early_init_devtree(void *params)
 {
 	phys_addr_t limit;
@@ -734,8 +723,6 @@ void __init early_init_devtree(void *params)
 
 	DBG("Phys. mem: %llx\n", memblock_phys_mem_size());
 
-	set_boot_memory_limit();
-
 	/* We may need to relocate the flat tree, do it now.
 	 * FIXME .. and the initrd too? */
 	move_device_tree();
diff --git a/arch/powerpc/kernel/rtas.c b/arch/powerpc/kernel/rtas.c
index d0516db..1662777 100644
--- a/arch/powerpc/kernel/rtas.c
+++ b/arch/powerpc/kernel/rtas.c
@@ -934,7 +934,7 @@ void __init rtas_initialize(void)
 	 */
 #ifdef CONFIG_PPC64
 	if (machine_is(pseries) && firmware_has_feature(FW_FEATURE_LPAR)) {
-		rtas_region = min(memblock.rmo_size, RTAS_INSTANTIATE_MAX);
+		rtas_region = min(ppc64_rma_size, RTAS_INSTANTIATE_MAX);
 		ibm_suspend_me_token = rtas_token("ibm,suspend-me");
 	}
 #endif
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index d135f93..4360944 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -487,7 +487,7 @@ static void __init emergency_stack_init(void)
 	 * bringup, we need to get at them in real mode. This means they
 	 * must also be within the RMO region.
 	 */
-	limit = min(slb0_limit(), memblock.rmo_size);
+	limit = min(slb0_limit(), ppc64_rma_size);
 
 	for_each_possible_cpu(i) {
 		unsigned long sp;
diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
index 58969b5..5810967 100644
--- a/arch/powerpc/mm/40x_mmu.c
+++ b/arch/powerpc/mm/40x_mmu.c
@@ -141,7 +141,19 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
 	 * coverage with normal-sized pages (or other reasons) do not
 	 * attempt to allocate outside the allowed range.
 	 */
-	memblock_set_current_limit(memstart_addr + mapped);
+	memblock_set_current_limit(mapped);
 
 	return mapped;
 }
+
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* We don't currently support the first MEMBLOCK not mapping 0
+	 * physical on those processors
+	 */
+	BUG_ON(first_memblock_base != 0);
+
+	/* 40x can only access 16MB at the moment (see head_40x.S) */
+	memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
+}
diff --git a/arch/powerpc/mm/44x_mmu.c b/arch/powerpc/mm/44x_mmu.c
index d8c6efb..024acab 100644
--- a/arch/powerpc/mm/44x_mmu.c
+++ b/arch/powerpc/mm/44x_mmu.c
@@ -24,6 +24,8 @@
  */
 
 #include <linux/init.h>
+#include <linux/memblock.h>
+
 #include <asm/mmu.h>
 #include <asm/system.h>
 #include <asm/page.h>
@@ -213,6 +215,18 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
 	return total_lowmem;
 }
 
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* We don't currently support the first MEMBLOCK not mapping 0
+	 * physical on those processors
+	 */
+	BUG_ON(first_memblock_base != 0);
+
+	/* 44x has a 256M TLB entry pinned at boot */
+	memblock_set_current_limit(min_t(u64, first_memblock_size, PPC_PIN_SIZE));
+}
+
 #ifdef CONFIG_SMP
 void __cpuinit mmu_init_secondary(int cpu)
 {
diff --git a/arch/powerpc/mm/fsl_booke_mmu.c b/arch/powerpc/mm/fsl_booke_mmu.c
index e525f86..0be8fe2 100644
--- a/arch/powerpc/mm/fsl_booke_mmu.c
+++ b/arch/powerpc/mm/fsl_booke_mmu.c
@@ -215,3 +215,12 @@ void __init adjust_total_lowmem(void)
 
 	memblock_set_current_limit(memstart_addr + __max_low_memory);
 }
+
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	phys_addr_t limit = first_memblock_base + first_memblock_size;
+
+	/* 64M mapped initially according to head_fsl_booke.S */
+	memblock_set_current_limit(min_t(u64, limit, 0x04000000));
+}
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index b05890e..83f534d 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -649,7 +649,7 @@ static void __init htab_initialize(void)
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	linear_map_hash_count = memblock_end_of_DRAM() >> PAGE_SHIFT;
 	linear_map_hash_slots = __va(memblock_alloc_base(linear_map_hash_count,
-						    1, memblock.rmo_size));
+						    1, ppc64_rma_size));
 	memset(linear_map_hash_slots, 0, linear_map_hash_count);
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
@@ -1248,3 +1248,23 @@ void kernel_map_pages(struct page *page, int numpages, int enable)
 	local_irq_restore(flags);
 }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
+
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* We don't currently support the first MEMBLOCK not mapping 0
+	 * physical on those processors
+	 */
+	BUG_ON(first_memblock_base != 0);
+
+	/* On LPAR systems, the first entry is our RMA region,
+	 * non-LPAR 64-bit hash MMU systems don't have a limitation
+	 * on real mode access, but using the first entry works well
+	 * enough. We also clamp it to 1G to avoid some funky things
+	 * such as RTAS bugs etc...
+	 */
+	ppc64_rma_size = min_t(u64, first_memblock_size, 0x40000000);
+
+	/* Finally limit subsequent allocations */
+	memblock_set_current_limit(ppc64_rma_size);
+}
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 59b208b..742da43 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -237,3 +237,17 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
+
+#ifdef CONFIG_8xx /* No 8xx specific .c file to put that in ... */
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* We don't currently support the first MEMBLOCK not mapping 0
+	 * physical on those processors
+	 */
+	BUG_ON(first_memblock_base != 0);
+
+	/* 8xx can only access 8MB at the moment */
+	memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
+}
+#endif /* CONFIG_8xx */
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 71f1415..9e081ff 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -328,3 +328,4 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
+
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 7d34e17..11571e1 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -271,3 +271,18 @@ void __init MMU_init_hw(void)
 
 	if ( ppc_md.progress ) ppc_md.progress("hash:done", 0x205);
 }
+
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* We don't currently support the first MEMBLOCK not mapping 0
+	 * physical on those processors
+	 */
+	BUG_ON(first_memblock_base != 0);
+
+	/* 601 can only access 16MB at the moment */
+	if (PVR_VER(mfspr(SPRN_PVR)) == 1)
+		memblock_set_current_limit(min_t(u64, first_memblock_size, 0x01000000));
+	else /* Anything else has 256M mapped */
+		memblock_set_current_limit(min_t(u64, first_memblock_size, 0x10000000));
+}
diff --git a/arch/powerpc/mm/tlb_nohash.c b/arch/powerpc/mm/tlb_nohash.c
index 7ba32e7..a086ed5 100644
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -446,4 +446,18 @@ void __cpuinit early_init_mmu_secondary(void)
 	__early_init_mmu(0);
 }
 
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	/* On Embedded 64-bit, we adjust the RMA size to match
+	 * the bolted TLB entry. We know for now that only 1G
+	 * entries are supported though that may eventually
+	 * change. We crop it to the size of the first MEMBLOCK to
+	 * avoid going over total available memory just in case...
+	 */
+	ppc64_rma_size = min_t(u64, first_memblock_size, 0x40000000);
+
+	/* Finally limit subsequent allocations */
+	memblock_set_current_limit(ppc64_memblock_base + ppc64_rma_size);
+}
 #endif /* CONFIG_PPC64 */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c4f6e53..71b8edc 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -33,7 +33,6 @@ struct memblock_type {
 
 struct memblock {
 	unsigned long debug;
-	u64 rmo_size;
 	u64 current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
diff --git a/mm/memblock.c b/mm/memblock.c
index 770c5bf..73d903e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -49,7 +49,6 @@ void memblock_dump_all(void)
 		return;
 
 	pr_info("MEMBLOCK configuration:\n");
-	pr_info(" rmo_size    = 0x%llx\n", (unsigned long long)memblock.rmo_size);
 	pr_info(" memory.size = 0x%llx\n", (unsigned long long)memblock.memory.size);
 
 	memblock_dump(&memblock.memory, "memory");
@@ -195,10 +194,6 @@ static long memblock_add_region(struct memblock_type *type, u64 base, u64 size)
 
 long memblock_add(u64 base, u64 size)
 {
-	/* On pSeries LPAR systems, the first MEMBLOCK is our RMO region. */
-	if (base == 0)
-		memblock.rmo_size = size;
-
 	return memblock_add_region(&memblock.memory, base, size);
 
 }
@@ -459,9 +454,6 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 		break;
 	}
 
-	if (memblock.memory.regions[0].size < memblock.rmo_size)
-		memblock.rmo_size = memblock.memory.regions[0].size;
-
 	memory_limit = memblock_end_of_DRAM();
 
 	/* And truncate any reserves above the limit also. */
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
