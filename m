Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E86996B02B0
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BoCf013125
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWR91294364
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FWgF016652
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 18/43] memblock: Introduce default allocation limit and use it to replace explicit ones
Date: Fri,  6 Aug 2010 15:14:59 +1000
Message-Id: <1281071724-28740-19-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This introduce memblock.current_limit which is used to limit allocations
from memblock_alloc() or memblock_alloc_base(..., MEMBLOCK_ALLOC_ACCESSIBLE).

The old MEMBLOCK_ALLOC_ANYWHERE changes value from 0 to ~(u64)0 and can still
be used with memblock_alloc_base() to allocate really anywhere.

It is -no-longer- cropped to MEMBLOCK_REAL_LIMIT which disappears.

Note to archs: I'm leaving the default limit to MEMBLOCK_ALLOC_ANYWHERE. I
strongly recommend that you ensure that you set an appropriate limit
during boot in order to guarantee that an memblock_alloc() at any time
results in something that is accessible with a simple __va().

The reason is that a subsequent patch will introduce the ability for
the array to resize itself by reallocating itself. The MEMBLOCK core will
honor the current limit when performing those allocations.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/microblaze/include/asm/memblock.h |    3 ---
 arch/powerpc/include/asm/memblock.h    |    7 -------
 arch/powerpc/kernel/prom.c             |   20 +++++++++++++++++++-
 arch/powerpc/kernel/setup_32.c         |    2 +-
 arch/powerpc/mm/40x_mmu.c              |    5 +++--
 arch/powerpc/mm/fsl_booke_mmu.c        |    3 ++-
 arch/powerpc/mm/hash_utils_64.c        |    3 ++-
 arch/powerpc/mm/init_32.c              |   29 +++++++----------------------
 arch/powerpc/mm/ppc_mmu_32.c           |    3 +--
 arch/powerpc/mm/tlb_nohash.c           |    2 ++
 arch/sh/include/asm/memblock.h         |    2 --
 arch/sparc/include/asm/memblock.h      |    2 --
 include/linux/memblock.h               |   16 +++++++++++++++-
 mm/memblock.c                          |   19 +++++++++++--------
 14 files changed, 63 insertions(+), 53 deletions(-)

diff --git a/arch/microblaze/include/asm/memblock.h b/arch/microblaze/include/asm/memblock.h
index f9c2fa3..20a8e25 100644
--- a/arch/microblaze/include/asm/memblock.h
+++ b/arch/microblaze/include/asm/memblock.h
@@ -9,9 +9,6 @@
 #ifndef _ASM_MICROBLAZE_MEMBLOCK_H
 #define _ASM_MICROBLAZE_MEMBLOCK_H
 
-/* MEMBLOCK limit is OFF */
-#define MEMBLOCK_REAL_LIMIT	0xFFFFFFFF
-
 #endif /* _ASM_MICROBLAZE_MEMBLOCK_H */
 
 
diff --git a/arch/powerpc/include/asm/memblock.h b/arch/powerpc/include/asm/memblock.h
index 3c29728..43efc34 100644
--- a/arch/powerpc/include/asm/memblock.h
+++ b/arch/powerpc/include/asm/memblock.h
@@ -5,11 +5,4 @@
 
 #define MEMBLOCK_DBG(fmt...) udbg_printf(fmt)
 
-#ifdef CONFIG_PPC32
-extern phys_addr_t lowmem_end_addr;
-#define MEMBLOCK_REAL_LIMIT	lowmem_end_addr
-#else
-#define MEMBLOCK_REAL_LIMIT	0
-#endif
-
 #endif /* _ASM_POWERPC_MEMBLOCK_H */
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index fed9bf6..3aec0b9 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -98,7 +98,7 @@ static void __init move_device_tree(void)
 
 	if ((memory_limit && (start + size) > memory_limit) ||
 			overlaps_crashkernel(start, size)) {
-		p = __va(memblock_alloc_base(size, PAGE_SIZE, memblock.rmo_size));
+		p = __va(memblock_alloc(size, PAGE_SIZE));
 		memcpy(p, initial_boot_params, size);
 		initial_boot_params = (struct boot_param_header *)p;
 		DBG("Moved device tree to 0x%p\n", p);
@@ -655,6 +655,21 @@ static void __init phyp_dump_reserve_mem(void)
 static inline void __init phyp_dump_reserve_mem(void) {}
 #endif /* CONFIG_PHYP_DUMP  && CONFIG_PPC_RTAS */
 
+static void set_boot_memory_limit(void)
+{
+#ifdef CONFIG_PPC32
+	/* 601 can only access 16MB at the moment */
+	if (PVR_VER(mfspr(SPRN_PVR)) == 1)
+		memblock_set_current_limit(0x01000000);
+	/* 8xx can only access 8MB at the moment */
+	else if (PVR_VER(mfspr(SPRN_PVR)) == 0x50)
+		memblock_set_current_limit(0x00800000);
+	else
+		memblock_set_current_limit(0x10000000);
+#else
+	memblock_set_current_limit(memblock.rmo_size);
+#endif
+}
 
 void __init early_init_devtree(void *params)
 {
@@ -683,6 +698,7 @@ void __init early_init_devtree(void *params)
 
 	/* Scan memory nodes and rebuild MEMBLOCKs */
 	memblock_init();
+
 	of_scan_flat_dt(early_init_dt_scan_root, NULL);
 	of_scan_flat_dt(early_init_dt_scan_memory_ppc, NULL);
 
@@ -718,6 +734,8 @@ void __init early_init_devtree(void *params)
 
 	DBG("Phys. mem: %llx\n", memblock_phys_mem_size());
 
+	set_boot_memory_limit();
+
 	/* We may need to relocate the flat tree, do it now.
 	 * FIXME .. and the initrd too? */
 	move_device_tree();
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index a10ffc8..b7eb1de 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -246,7 +246,7 @@ static void __init irqstack_early_init(void)
 	unsigned int i;
 
 	/* interrupt stacks must be in lowmem, we get that for free on ppc32
-	 * as the memblock is limited to lowmem by MEMBLOCK_REAL_LIMIT */
+	 * as the memblock is limited to lowmem by default */
 	for_each_possible_cpu(i) {
 		softirq_ctx[i] = (struct thread_info *)
 			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
index 1dc2fa5..58969b5 100644
--- a/arch/powerpc/mm/40x_mmu.c
+++ b/arch/powerpc/mm/40x_mmu.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/highmem.h>
+#include <linux/memblock.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
@@ -47,6 +48,7 @@
 #include <asm/bootx.h>
 #include <asm/machdep.h>
 #include <asm/setup.h>
+
 #include "mmu_decl.h"
 
 extern int __map_without_ltlbs;
@@ -139,8 +141,7 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
 	 * coverage with normal-sized pages (or other reasons) do not
 	 * attempt to allocate outside the allowed range.
 	 */
-
-	__initial_memory_limit_addr = memstart_addr + mapped;
+	memblock_set_current_limit(memstart_addr + mapped);
 
 	return mapped;
 }
diff --git a/arch/powerpc/mm/fsl_booke_mmu.c b/arch/powerpc/mm/fsl_booke_mmu.c
index cdc7526..e525f86 100644
--- a/arch/powerpc/mm/fsl_booke_mmu.c
+++ b/arch/powerpc/mm/fsl_booke_mmu.c
@@ -40,6 +40,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/highmem.h>
+#include <linux/memblock.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
@@ -212,5 +213,5 @@ void __init adjust_total_lowmem(void)
 	pr_cont("%lu Mb, residual: %dMb\n", tlbcam_sz(tlbcam_index - 1) >> 20,
 	        (unsigned int)((total_lowmem - __max_low_memory) >> 20));
 
-	__initial_memory_limit_addr = memstart_addr + __max_low_memory;
+	memblock_set_current_limit(memstart_addr + __max_low_memory);
 }
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index a542ff5..b05890e 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -696,7 +696,8 @@ static void __init htab_initialize(void)
 #endif /* CONFIG_U3_DART */
 		BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
 				prot, mmu_linear_psize, mmu_kernel_ssize));
-       }
+	}
+	memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
 
 	/*
 	 * If we have a memory_limit and we've allocated TCEs then we need to
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 6a6975d..59b208b 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -92,12 +92,6 @@ int __allow_ioremap_reserved;
 unsigned long __max_low_memory = MAX_LOW_MEM;
 
 /*
- * address of the limit of what is accessible with initial MMU setup -
- * 256MB usually, but only 16MB on 601.
- */
-phys_addr_t __initial_memory_limit_addr = (phys_addr_t)0x10000000;
-
-/*
  * Check for command-line options that affect what MMU_init will do.
  */
 void MMU_setup(void)
@@ -126,13 +120,6 @@ void __init MMU_init(void)
 	if (ppc_md.progress)
 		ppc_md.progress("MMU:enter", 0x111);
 
-	/* 601 can only access 16MB at the moment */
-	if (PVR_VER(mfspr(SPRN_PVR)) == 1)
-		__initial_memory_limit_addr = 0x01000000;
-	/* 8xx can only access 8MB at the moment */
-	if (PVR_VER(mfspr(SPRN_PVR)) == 0x50)
-		__initial_memory_limit_addr = 0x00800000;
-
 	/* parse args from command line */
 	MMU_setup();
 
@@ -190,20 +177,18 @@ void __init MMU_init(void)
 #ifdef CONFIG_BOOTX_TEXT
 	btext_unmap();
 #endif
+
+	/* Shortly after that, the entire linear mapping will be available */
+	memblock_set_current_limit(lowmem_end_addr);
 }
 
 /* This is only called until mem_init is done. */
 void __init *early_get_page(void)
 {
-	void *p;
-
-	if (init_bootmem_done) {
-		p = alloc_bootmem_pages(PAGE_SIZE);
-	} else {
-		p = __va(memblock_alloc_base(PAGE_SIZE, PAGE_SIZE,
-					__initial_memory_limit_addr));
-	}
-	return p;
+	if (init_bootmem_done)
+		return alloc_bootmem_pages(PAGE_SIZE);
+	else
+		return __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
 }
 
 /* Free up now-unused memory */
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index f8a0182..7d34e17 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -223,8 +223,7 @@ void __init MMU_init_hw(void)
 	 * Find some memory for the hash table.
 	 */
 	if ( ppc_md.progress ) ppc_md.progress("hash:find piece", 0x322);
-	Hash = __va(memblock_alloc_base(Hash_size, Hash_size,
-				   __initial_memory_limit_addr));
+	Hash = __va(memblock_alloc(Hash_size, Hash_size));
 	cacheable_memzero(Hash, Hash_size);
 	_SDR1 = __pa(Hash) | SDR1_LOW_BITS;
 
diff --git a/arch/powerpc/mm/tlb_nohash.c b/arch/powerpc/mm/tlb_nohash.c
index d8695b0..7ba32e7 100644
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -432,6 +432,8 @@ static void __early_init_mmu(int boot_cpu)
 	 * the MMU configuration
 	 */
 	mb();
+
+	memblock_set_current_limit(linear_map_top);
 }
 
 void __init early_init_mmu(void)
diff --git a/arch/sh/include/asm/memblock.h b/arch/sh/include/asm/memblock.h
index dfe683b..e87063f 100644
--- a/arch/sh/include/asm/memblock.h
+++ b/arch/sh/include/asm/memblock.h
@@ -1,6 +1,4 @@
 #ifndef __ASM_SH_MEMBLOCK_H
 #define __ASM_SH_MEMBLOCK_H
 
-#define MEMBLOCK_REAL_LIMIT	0
-
 #endif /* __ASM_SH_MEMBLOCK_H */
diff --git a/arch/sparc/include/asm/memblock.h b/arch/sparc/include/asm/memblock.h
index f12af88..c67b047 100644
--- a/arch/sparc/include/asm/memblock.h
+++ b/arch/sparc/include/asm/memblock.h
@@ -5,6 +5,4 @@
 
 #define MEMBLOCK_DBG(fmt...) prom_printf(fmt)
 
-#define MEMBLOCK_REAL_LIMIT	0
-
 #endif /* !(_SPARC64_MEMBLOCK_H) */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 3cf3304..c4f6e53 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -34,6 +34,7 @@ struct memblock_type {
 struct memblock {
 	unsigned long debug;
 	u64 rmo_size;
+	u64 current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
 };
@@ -46,11 +47,16 @@ extern long memblock_add(u64 base, u64 size);
 extern long memblock_remove(u64 base, u64 size);
 extern long __init memblock_free(u64 base, u64 size);
 extern long __init memblock_reserve(u64 base, u64 size);
+
 extern u64 __init memblock_alloc_nid(u64 size, u64 align, int nid);
 extern u64 __init memblock_alloc(u64 size, u64 align);
+
+/* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
+#define MEMBLOCK_ALLOC_ANYWHERE	(~(u64)0)
+#define MEMBLOCK_ALLOC_ACCESSIBLE	0
+
 extern u64 __init memblock_alloc_base(u64 size,
 		u64, u64 max_addr);
-#define MEMBLOCK_ALLOC_ANYWHERE	0
 extern u64 __init __memblock_alloc_base(u64 size,
 		u64 align, u64 max_addr);
 extern u64 __init memblock_phys_mem_size(void);
@@ -66,6 +72,14 @@ extern void memblock_dump_all(void);
 /* Provided by the architecture */
 extern u64 memblock_nid_range(u64 start, u64 end, int *nid);
 
+/**
+ * memblock_set_current_limit - Set the current allocation limit to allow
+ *                         limiting allocations to what is currently
+ *                         accessible during boot
+ * @limit: New limit value (physical address)
+ */
+extern void memblock_set_current_limit(u64 limit);
+
 
 /*
  * pfn conversion functions
diff --git a/mm/memblock.c b/mm/memblock.c
index 0131684..770c5bf 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -115,6 +115,8 @@ void __init memblock_init(void)
 	memblock.reserved.regions[0].base = 0;
 	memblock.reserved.regions[0].size = 0;
 	memblock.reserved.cnt = 1;
+
+	memblock.current_limit = MEMBLOCK_ALLOC_ANYWHERE;
 }
 
 void __init memblock_analyze(void)
@@ -373,7 +375,7 @@ u64 __init memblock_alloc_nid(u64 size, u64 align, int nid)
 
 u64 __init memblock_alloc(u64 size, u64 align)
 {
-	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ANYWHERE);
+	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
 u64 __init memblock_alloc_base(u64 size, u64 align, u64 max_addr)
@@ -399,14 +401,9 @@ u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 
 	size = memblock_align_up(size, align);
 
-	/* On some platforms, make sure we allocate lowmem */
-	/* Note that MEMBLOCK_REAL_LIMIT may be MEMBLOCK_ALLOC_ANYWHERE */
-	if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
-		max_addr = MEMBLOCK_REAL_LIMIT;
-
 	/* Pump up max_addr */
-	if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
-		max_addr = ~(u64)0;
+	if (max_addr == MEMBLOCK_ALLOC_ACCESSIBLE)
+		max_addr = memblock.current_limit;
 
 	/* We do a top-down search, this tends to limit memory
 	 * fragmentation by keeping early boot allocs near the
@@ -527,3 +524,9 @@ int memblock_is_region_reserved(u64 base, u64 size)
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
+
+void __init memblock_set_current_limit(u64 limit)
+{
+	memblock.current_limit = limit;
+}
+
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
