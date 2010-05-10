Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECC56B0250
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:41:24 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 07/25] lmb: Introduce default allocation limit and use it to replace explicit ones
Date: Mon, 10 May 2010 19:38:41 +1000
Message-Id: <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This introduce lmb.current_limit which is used to limit allocations
from lmb_alloc() or lmb_alloc_base(..., LMB_ALLOC_ACCESSIBLE). The
old LMB_ALLOC_ANYWHERE changes value from 0 to ~(u64)0 and can still
be used to alloc really anywhere. It is -no-longer- cropped to
LMB_REAL_LIMIT which disappears.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/microblaze/include/asm/lmb.h |    3 ---
 arch/powerpc/include/asm/lmb.h    |    7 -------
 arch/powerpc/kernel/prom.c        |   20 +++++++++++++++++++-
 arch/powerpc/kernel/setup_32.c    |    2 +-
 arch/powerpc/mm/40x_mmu.c         |    5 +++--
 arch/powerpc/mm/fsl_booke_mmu.c   |    3 ++-
 arch/powerpc/mm/hash_utils_64.c   |    3 ++-
 arch/powerpc/mm/init_32.c         |   29 +++++++----------------------
 arch/powerpc/mm/ppc_mmu_32.c      |    3 +--
 arch/powerpc/mm/tlb_nohash.c      |    2 ++
 arch/sh/include/asm/lmb.h         |    2 --
 arch/sparc/include/asm/lmb.h      |    2 --
 include/linux/lmb.h               |   16 +++++++++++++++-
 lib/lmb.c                         |   19 +++++++++++--------
 14 files changed, 63 insertions(+), 53 deletions(-)

diff --git a/arch/microblaze/include/asm/lmb.h b/arch/microblaze/include/asm/lmb.h
index a0a0a92..fb4803f 100644
--- a/arch/microblaze/include/asm/lmb.h
+++ b/arch/microblaze/include/asm/lmb.h
@@ -9,9 +9,6 @@
 #ifndef _ASM_MICROBLAZE_LMB_H
 #define _ASM_MICROBLAZE_LMB_H
 
-/* LMB limit is OFF */
-#define LMB_REAL_LIMIT	0xFFFFFFFF
-
 #endif /* _ASM_MICROBLAZE_LMB_H */
 
 
diff --git a/arch/powerpc/include/asm/lmb.h b/arch/powerpc/include/asm/lmb.h
index 6f5fdf0..c2d51c9 100644
--- a/arch/powerpc/include/asm/lmb.h
+++ b/arch/powerpc/include/asm/lmb.h
@@ -5,11 +5,4 @@
 
 #define LMB_DBG(fmt...) udbg_printf(fmt)
 
-#ifdef CONFIG_PPC32
-extern phys_addr_t lowmem_end_addr;
-#define LMB_REAL_LIMIT	lowmem_end_addr
-#else
-#define LMB_REAL_LIMIT	0
-#endif
-
 #endif /* _ASM_POWERPC_LMB_H */
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index 05131d6..b8428d3 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -98,7 +98,7 @@ static void __init move_device_tree(void)
 
 	if ((memory_limit && (start + size) > memory_limit) ||
 			overlaps_crashkernel(start, size)) {
-		p = __va(lmb_alloc_base(size, PAGE_SIZE, lmb.rmo_size));
+		p = __va(lmb_alloc(size, PAGE_SIZE));
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
+		lmb_set_current_limit(0x01000000);
+	/* 8xx can only access 8MB at the moment */
+	else if (PVR_VER(mfspr(SPRN_PVR)) == 0x50)
+		lmb_set_current_limit(0x00800000);
+	else
+		lmb_set_current_limit(0x10000000);
+#else
+	lmb_set_current_limit(lmb.rmo_size);
+#endif
+}
 
 void __init early_init_devtree(void *params)
 {
@@ -683,6 +698,7 @@ void __init early_init_devtree(void *params)
 
 	/* Scan memory nodes and rebuild LMBs */
 	lmb_init();
+
 	of_scan_flat_dt(early_init_dt_scan_root, NULL);
 	of_scan_flat_dt(early_init_dt_scan_memory_ppc, NULL);
 
@@ -718,6 +734,8 @@ void __init early_init_devtree(void *params)
 
 	DBG("Phys. mem: %llx\n", lmb_phys_mem_size());
 
+	set_boot_memory_limit();
+
 	/* We may need to relocate the flat tree, do it now.
 	 * FIXME .. and the initrd too? */
 	move_device_tree();
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 8f58986..fd3339c 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -247,7 +247,7 @@ static void __init irqstack_early_init(void)
 	unsigned int i;
 
 	/* interrupt stacks must be in lowmem, we get that for free on ppc32
-	 * as the lmb is limited to lowmem by LMB_REAL_LIMIT */
+	 * as the lmb is limited to lowmem by default */
 	for_each_possible_cpu(i) {
 		softirq_ctx[i] = (struct thread_info *)
 			__va(lmb_alloc(THREAD_SIZE, THREAD_SIZE));
diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
index 65abfcf..809f655 100644
--- a/arch/powerpc/mm/40x_mmu.c
+++ b/arch/powerpc/mm/40x_mmu.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/highmem.h>
+#include <linux/lmb.h>
 
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
+	lmb_set_current_limit(memstart_addr + mapped);
 
 	return mapped;
 }
diff --git a/arch/powerpc/mm/fsl_booke_mmu.c b/arch/powerpc/mm/fsl_booke_mmu.c
index 1ed6b52..038cb29 100644
--- a/arch/powerpc/mm/fsl_booke_mmu.c
+++ b/arch/powerpc/mm/fsl_booke_mmu.c
@@ -40,6 +40,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/highmem.h>
+#include <linux/lmb.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
@@ -231,5 +232,5 @@ void __init adjust_total_lowmem(void)
 	pr_cont("%lu Mb, residual: %dMb\n", tlbcam_sz(tlbcam_index - 1) >> 20,
 	        (unsigned int)((total_lowmem - __max_low_memory) >> 20));
 
-	__initial_memory_limit_addr = memstart_addr + __max_low_memory;
+	lmb_set_current_limit(memstart_addr + __max_low_memory);
 }
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 28838e3..ae7a8f1 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -696,7 +696,8 @@ static void __init htab_initialize(void)
 #endif /* CONFIG_U3_DART */
 		BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
 				prot, mmu_linear_psize, mmu_kernel_ssize));
-       }
+	}
+	lmb_set_current_limit(LMB_ALLOC_ANYWHERE);
 
 	/*
 	 * If we have a memory_limit and we've allocated TCEs then we need to
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 7673330..62d2242 100644
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
+	lmb_set_current_limit(lowmem_end_addr);
 }
 
 /* This is only called until mem_init is done. */
 void __init *early_get_page(void)
 {
-	void *p;
-
-	if (init_bootmem_done) {
-		p = alloc_bootmem_pages(PAGE_SIZE);
-	} else {
-		p = __va(lmb_alloc_base(PAGE_SIZE, PAGE_SIZE,
-					__initial_memory_limit_addr));
-	}
-	return p;
+	if (init_bootmem_done)
+		return alloc_bootmem_pages(PAGE_SIZE);
+	else
+		return __va(lmb_alloc(PAGE_SIZE, PAGE_SIZE));
 }
 
 /* Free up now-unused memory */
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index f11c2cd..fe6af92 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -223,8 +223,7 @@ void __init MMU_init_hw(void)
 	 * Find some memory for the hash table.
 	 */
 	if ( ppc_md.progress ) ppc_md.progress("hash:find piece", 0x322);
-	Hash = __va(lmb_alloc_base(Hash_size, Hash_size,
-				   __initial_memory_limit_addr));
+	Hash = __va(lmb_alloc(Hash_size, Hash_size));
 	cacheable_memzero(Hash, Hash_size);
 	_SDR1 = __pa(Hash) | SDR1_LOW_BITS;
 
diff --git a/arch/powerpc/mm/tlb_nohash.c b/arch/powerpc/mm/tlb_nohash.c
index e81d5d6..4a09475 100644
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -432,6 +432,8 @@ static void __early_init_mmu(int boot_cpu)
 	 * the MMU configuration
 	 */
 	mb();
+
+	lmb_set_current_limit(linear_map_top);
 }
 
 void __init early_init_mmu(void)
diff --git a/arch/sh/include/asm/lmb.h b/arch/sh/include/asm/lmb.h
index 9b437f6..8477be2 100644
--- a/arch/sh/include/asm/lmb.h
+++ b/arch/sh/include/asm/lmb.h
@@ -1,6 +1,4 @@
 #ifndef __ASM_SH_LMB_H
 #define __ASM_SH_LMB_H
 
-#define LMB_REAL_LIMIT	0
-
 #endif /* __ASM_SH_LMB_H */
diff --git a/arch/sparc/include/asm/lmb.h b/arch/sparc/include/asm/lmb.h
index 6a352cb..2275165 100644
--- a/arch/sparc/include/asm/lmb.h
+++ b/arch/sparc/include/asm/lmb.h
@@ -5,6 +5,4 @@
 
 #define LMB_DBG(fmt...) prom_printf(fmt)
 
-#define LMB_REAL_LIMIT	0
-
 #endif /* !(_SPARC64_LMB_H) */
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index f0d2cab..3b950c3 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -34,6 +34,7 @@ struct lmb_type {
 struct lmb {
 	unsigned long debug;
 	u64 rmo_size;
+	u64 current_limit;
 	struct lmb_type memory;
 	struct lmb_type reserved;
 };
@@ -46,11 +47,16 @@ extern long lmb_add(u64 base, u64 size);
 extern long lmb_remove(u64 base, u64 size);
 extern long __init lmb_free(u64 base, u64 size);
 extern long __init lmb_reserve(u64 base, u64 size);
+
 extern u64 __init lmb_alloc_nid(u64 size, u64 align, int nid);
 extern u64 __init lmb_alloc(u64 size, u64 align);
+
+/* Flags for lmb_alloc_base() amd __lmb_alloc_base() */
+#define LMB_ALLOC_ANYWHERE	(~(u64)0)
+#define LMB_ALLOC_ACCESSIBLE	0
+
 extern u64 __init lmb_alloc_base(u64 size,
 		u64, u64 max_addr);
-#define LMB_ALLOC_ANYWHERE	0
 extern u64 __init __lmb_alloc_base(u64 size,
 		u64 align, u64 max_addr);
 extern u64 __init lmb_phys_mem_size(void);
@@ -64,6 +70,14 @@ extern void lmb_dump_all(void);
 /* Provided by the architecture */
 extern u64 lmb_nid_range(u64 start, u64 end, int *nid);
 
+/**
+ * lmb_set_current_limit - Set the current allocation limit to allow
+ *                         limiting allocations to what is currently
+ *                         accessible during boot
+ * @limit: New limit value (physical address)
+ */
+extern void lmb_set_current_limit(u64 limit);
+
 
 /*
  * pfn conversion functions
diff --git a/lib/lmb.c b/lib/lmb.c
index bd81266..34a558c 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -115,6 +115,8 @@ void __init lmb_init(void)
 	lmb.reserved.regions[0].base = 0;
 	lmb.reserved.regions[0].size = 0;
 	lmb.reserved.cnt = 1;
+
+	lmb.current_limit = LMB_ALLOC_ANYWHERE;
 }
 
 void __init lmb_analyze(void)
@@ -373,7 +375,7 @@ u64 __init lmb_alloc_nid(u64 size, u64 align, int nid)
 
 u64 __init lmb_alloc(u64 size, u64 align)
 {
-	return lmb_alloc_base(size, align, LMB_ALLOC_ANYWHERE);
+	return lmb_alloc_base(size, align, LMB_ALLOC_ACCESSIBLE);
 }
 
 u64 __init lmb_alloc_base(u64 size, u64 align, u64 max_addr)
@@ -399,14 +401,9 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 
 	size = lmb_align_up(size, align);
 
-	/* On some platforms, make sure we allocate lowmem */
-	/* Note that LMB_REAL_LIMIT may be LMB_ALLOC_ANYWHERE */
-	if (max_addr == LMB_ALLOC_ANYWHERE)
-		max_addr = LMB_REAL_LIMIT;
-
 	/* Pump up max_addr */
-	if (max_addr == LMB_ALLOC_ANYWHERE)
-		max_addr = ~(u64)0;
+	if (max_addr == LMB_ALLOC_ACCESSIBLE)
+		max_addr = lmb.current_limit;
 	
 	/* We do a top-down search, this tends to limit memory
 	 * fragmentation by keeping early boot allocs near the
@@ -501,3 +498,9 @@ int lmb_is_region_reserved(u64 base, u64 size)
 	return lmb_overlaps_region(&lmb.reserved, base, size);
 }
 
+
+void __init lmb_set_current_limit(u64 limit)
+{
+	lmb.current_limit = limit;
+}
+
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
