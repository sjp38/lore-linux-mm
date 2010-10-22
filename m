Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C65F65F0043
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 20:52:05 -0400 (EDT)
Date: Fri, 22 Oct 2010 00:50:42 GMT
Message-Id: <201010220050.o9M0ognt032167@hera.kernel.org>
From: "H. Peter Anvin" <hpa@linux.intel.com>
Subject: [GIT PULL] memblock for 2.6.37
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, CAI Qian <caiqian@redhat.com>, "David S. Miller" <davem@davemloft.net>, Felipe Balbi <balbi@ti.com>, "H. Peter Anvin" <hpa@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Kevin Hilman <khilman@deeprootsystems.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <michael@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Russell King <rmk@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner <tglx@linutronix.de>, Tomi Valkeinen <tomi.valkeinen@nokia.com>, Vivek Goyal <vgoyal@redhat.com>, Yinghai Lu <yinghai@kernel.org>, ext Grazvydas Ignotas <notasas@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

This is the culmination of Benjamin Herrenschmidt and Yinghai Lu's
memblock (formerly lmb) work: this generalizes the code and uses it
for x86.

We have tested it to the best of our abilities, mainly on x86 of
course, but I obviously can't promise it will be regression-free: it's
a large chunk of work and touches many tricky things, we did get some
bug reports later than I really would have liked, and even if it is
correct it might smoke out bugs elsewhere in the system.

One of the risks for the latter is that it does is it changes the
default memory allocation policy on x86 from bottom-up to top-down;
top-down really is the preferred option both from a bug-discovery
perspective and preserving a potentially precious resource in the
presence of broken DMA devices or the like, but it might also catch
things that just "happen to work".

Additionally, there was an issue with an ARM build failure that was
not caught until fairly late.  rmk asked for the series to be rebased
as late as last week to avoid a bisection hole on ARM, but my
understanding is that your policy is that you do not want the history
to be destroyed in that manner.  Please let me know if you would
prefer it to be done differently.

There will be two conflicts if you pull this based on the below commit:

	5fe8321b8886d814e65952d74b207fe59e1096ea:
	Merge branch 'x86-x2apic-for-linus' ... (2010-10-21 13:54:05 -0700)

(which is your current head at the time I write this), both of them
are trivial to resolve -- in one case two functions have been added in
the same place; you need both functions; the other is a simple
Makefile merge.  I have also pushed a premerged branch for your convenience.

The unmerged branch is at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core-memblock-for-linus

The premerged branch is at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core-memblock-for-linus-merged

	-hpa


Benjamin Herrenschmidt (37):
      memblock: Fix memblock_is_region_reserved() to return a boolean
      memblock: Rename memblock_region to memblock_type and memblock_property to memblock_region
      memblock: No reason to include asm/memblock.h late
      memblock: Implement memblock_is_memory and memblock_is_region_memory
      memblock/arm: pfn_valid uses memblock_is_memory()
      memblock/arm: Use memblock_region_is_memory() for omap fb
      memblock: Introduce for_each_memblock() and new accessors
      memblock/microblaze: Use new accessors
      memblock/sh: Use new accessors
      memblock/sparc: Use new accessors
      memblock/powerpc: Use new accessors
      memblock/arm: Use new accessors
      memblock: Remove obsolete accessors
      memblock: Remove memblock_find()
      memblock: Remove nid_range argument, arch provides memblock_nid_range() instead
      memblock: Factor the lowest level alloc function
      memblock: Expose MEMBLOCK_ALLOC_ANYWHERE
      memblock: Introduce default allocation limit and use it to replace explicit ones
      memblock: Remove rmo_size, burry it in arch/powerpc where it belongs
      memblock: Change u64 to phys_addr_t
      memblock: Remove unused memblock.debug struct member
      memblock: Remove memblock_type.size and add memblock.memory_size instead
      memblock: Move memblock arrays to static storage in memblock.c and make their size a variable
      memblock: Add debug markers at the end of the array
      memblock: Make memblock_find_region() out of memblock_alloc_region()
      memblock: Define MEMBLOCK_ERROR internally instead of using ~(phys_addr_t)0
      memblock: Move memblock_init() to the bottom of the file
      memblock: split memblock_find_base() out of __memblock_alloc_base()
      memblock: Move functions around into a more sensible order
      memblock: Add array resizing support
      memblock: Add arch function to control coalescing of memblock memory regions
      memblock: Add "start" argument to memblock_find_base()
      memblock: NUMA allocate can now use early_pfn_map
      memblock: Separate memblock_alloc_nid() and memblock_alloc_try_nid()
      memblock: Make memblock_alloc_try_nid() fallback to MEMBLOCK_ALLOC_ANYWHERE
      memblock: Add debugfs files to dump the arrays content
      memblock: Make MEMBLOCK_ERROR be 0

H. Peter Anvin (1):
      Merge branch 'x86/urgent' into core/memblock

Ingo Molnar (2):
      Merge commit 'v2.6.36-rc3' into x86/memblock
      Merge commit 'v2.6.36-rc7' into core/memblock

Jeremy Fitzhardinge (3):
      memblock: Allow memblock_init to be called early
      xen: Cope with unmapped pages when initializing kernel pagetable
      x86-64: Only set max_pfn_mapped to 512 MiB if we enter via head_64.S

Michal Simek (1):
      memblock, microblaze: Fix memblock API change fallout

Yinghai Lu (33):
      memblock: Expose some memblock bits for use by x86
      memblock: Improve debug output when resizing the reserve array
      memblock: Export MEMBLOCK_ERROR
      memblock: Protect memblock.h with CONFIG_HAVE_MEMBLOCK
      memblock: Option for the architecture to put memblock into the .init section
      memblock: Add memblock_find_in_range()
      memblock: Add memblock_free/reserve_reserved_regions()
      x86, memblock: Add memblock_x86_find_in_range_size()
      bootmem, x86: Add weak version of reserve_bootmem_generic
      x86, memblock: Add memblock_x86_to_bootmem()
      x86, memblock: Add memblock_x86_reserve_range/memblock_x86_free_range
      x86, memblock: Add get_free_all_memory_range()
      x86, memblock: Add memblock_x86_register_active_regions() and memblock_x86_hole_size()
      memblock: Add find_memory_core_early()
      x86, memblock: Add memblock_x86_find_in_range_node()
      x86, memblock: Add memblock_x86_free_memory_in_range()
      x86, memblock: Add memblock_x86_memory_in_range()
      x86, memblock: Use memblock_debug to control debug message print out
      x86: Use memblock to replace early_res
      x86, memblock: Replace e820_/_early string with memblock_
      x86: Remove not used early_res code
      x86, memblock: Use memblock_memory_size()/memblock_free_memory_size() to get correct dma_reserve
      x86: Remove old bootmem code
      powerpc, memblock: Fix memblock API change fallout
      memblock: Fix section mismatch warnings
      arm, memblock: Fix the sparsemem build
      x86, memblock: Fix crashkernel allocation
      x86-32, memblock: Make add_highpages honor early reserved ranges
      memblock: Fix wraparound in find_region()
      x86, memblock: Remove __memblock_x86_find_in_range_size()
      memblock/arm: Fix memblock_region_is_memory() typo
      memblock: Annotate memblock functions with __init_memblock
      memblock, bootmem: Round pfn properly for memory and reserved regions

 arch/arm/mm/init.c                       |   37 +-
 arch/arm/plat-omap/fb.c                  |    6 +-
 arch/microblaze/include/asm/memblock.h   |    3 -
 arch/microblaze/mm/init.c                |   30 +-
 arch/powerpc/include/asm/memblock.h      |    7 -
 arch/powerpc/include/asm/mmu.h           |   12 +
 arch/powerpc/kernel/head_40x.S           |    6 +-
 arch/powerpc/kernel/paca.c               |    2 +-
 arch/powerpc/kernel/prom.c               |   15 +-
 arch/powerpc/kernel/rtas.c               |    2 +-
 arch/powerpc/kernel/setup_32.c           |    2 +-
 arch/powerpc/kernel/setup_64.c           |    2 +-
 arch/powerpc/mm/40x_mmu.c                |   17 +-
 arch/powerpc/mm/44x_mmu.c                |   14 +
 arch/powerpc/mm/fsl_booke_mmu.c          |   12 +-
 arch/powerpc/mm/hash_utils_64.c          |   35 +-
 arch/powerpc/mm/init_32.c                |   43 +-
 arch/powerpc/mm/init_64.c                |    1 +
 arch/powerpc/mm/mem.c                    |   94 ++---
 arch/powerpc/mm/numa.c                   |   17 +-
 arch/powerpc/mm/ppc_mmu_32.c             |   18 +-
 arch/powerpc/mm/tlb_nohash.c             |   16 +
 arch/powerpc/platforms/embedded6xx/wii.c |    2 +-
 arch/sh/include/asm/memblock.h           |    2 -
 arch/sh/mm/init.c                        |   17 +-
 arch/sparc/include/asm/memblock.h        |    2 -
 arch/sparc/mm/init_64.c                  |   46 +-
 arch/x86/Kconfig                         |   15 +-
 arch/x86/include/asm/e820.h              |   20 +-
 arch/x86/include/asm/efi.h               |    2 +-
 arch/x86/include/asm/io.h                |    1 +
 arch/x86/include/asm/memblock.h          |   23 +
 arch/x86/kernel/acpi/sleep.c             |    9 +-
 arch/x86/kernel/apic/numaq_32.c          |    3 +-
 arch/x86/kernel/check.c                  |   16 +-
 arch/x86/kernel/e820.c                   |  191 ++-----
 arch/x86/kernel/efi.c                    |    5 +-
 arch/x86/kernel/head.c                   |    3 +-
 arch/x86/kernel/head32.c                 |   10 +-
 arch/x86/kernel/head64.c                 |    9 +-
 arch/x86/kernel/mpparse.c                |    5 +-
 arch/x86/kernel/setup.c                  |   88 ++--
 arch/x86/kernel/setup_percpu.c           |    6 -
 arch/x86/kernel/trampoline.c             |   10 +-
 arch/x86/mm/Makefile                     |    2 +
 arch/x86/mm/init.c                       |   10 +-
 arch/x86/mm/init_32.c                    |  119 +----
 arch/x86/mm/init_64.c                    |   67 +---
 arch/x86/mm/ioremap.c                    |    5 +
 arch/x86/mm/k8topology_64.c              |    4 +-
 arch/x86/mm/memblock.c                   |  348 +++++++++++++
 arch/x86/mm/memtest.c                    |    7 +-
 arch/x86/mm/numa_32.c                    |   30 +-
 arch/x86/mm/numa_64.c                    |   84 +---
 arch/x86/mm/srat_32.c                    |    3 +-
 arch/x86/mm/srat_64.c                    |   11 +-
 arch/x86/xen/enlighten.c                 |    3 +
 arch/x86/xen/mmu.c                       |   31 +-
 arch/x86/xen/setup.c                     |    3 +-
 drivers/video/omap2/vram.c               |    8 +-
 include/linux/early_res.h                |   23 -
 include/linux/memblock.h                 |  168 +++++--
 include/linux/mm.h                       |    2 +
 kernel/Makefile                          |    1 -
 kernel/early_res.c                       |  590 ---------------------
 mm/bootmem.c                             |   13 +-
 mm/memblock.c                            |  837 ++++++++++++++++++++----------
 mm/page_alloc.c                          |   86 ++--
 mm/sparse-vmemmap.c                      |   11 -
 69 files changed, 1639 insertions(+), 1703 deletions(-)
 create mode 100644 arch/x86/include/asm/memblock.h
 create mode 100644 arch/x86/mm/memblock.c
 delete mode 100644 include/linux/early_res.h
 delete mode 100644 kernel/early_res.c

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 7185b00..63f4417 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -150,6 +150,7 @@ static void __init find_limits(struct meminfo *mi,
 static void __init arm_bootmem_init(struct meminfo *mi,
 	unsigned long start_pfn, unsigned long end_pfn)
 {
+	struct memblock_region *reg;
 	unsigned int boot_pages;
 	phys_addr_t bitmap;
 	pg_data_t *pgdat;
@@ -180,13 +181,13 @@ static void __init arm_bootmem_init(struct meminfo *mi,
 	/*
 	 * Reserve the memblock reserved regions in bootmem.
 	 */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		phys_addr_t start = memblock_start_pfn(&memblock.reserved, i);
-		if (start >= start_pfn &&
-		    memblock_end_pfn(&memblock.reserved, i) <= end_pfn)
+	for_each_memblock(reserved, reg) {
+		phys_addr_t start = memblock_region_reserved_base_pfn(reg);
+		phys_addr_t end = memblock_region_reserved_end_pfn(reg);
+		if (start >= start_pfn && end <= end_pfn)
 			reserve_bootmem_node(pgdat, __pfn_to_phys(start),
-				memblock_size_bytes(&memblock.reserved, i),
-				BOOTMEM_DEFAULT);
+					     (end - start) << PAGE_SHIFT,
+					     BOOTMEM_DEFAULT);
 	}
 }
 
@@ -237,20 +238,7 @@ static void __init arm_bootmem_free(struct meminfo *mi, unsigned long min,
 #ifndef CONFIG_SPARSEMEM
 int pfn_valid(unsigned long pfn)
 {
-	struct memblock_region *mem = &memblock.memory;
-	unsigned int left = 0, right = mem->cnt;
-
-	do {
-		unsigned int mid = (right + left) / 2;
-
-		if (pfn < memblock_start_pfn(mem, mid))
-			right = mid;
-		else if (pfn >= memblock_end_pfn(mem, mid))
-			left = mid + 1;
-		else
-			return 1;
-	} while (left < right);
-	return 0;
+	return memblock_is_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
 
@@ -260,10 +248,11 @@ static void arm_memory_present(void)
 #else
 static void arm_memory_present(void)
 {
-	int i;
-	for (i = 0; i < memblock.memory.cnt; i++)
-		memory_present(0, memblock_start_pfn(&memblock.memory, i),
-				  memblock_end_pfn(&memblock.memory, i));
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg)
+		memory_present(0, memblock_region_memory_base_pfn(reg),
+			       memblock_region_memory_end_pfn(reg));
 }
 #endif
 
diff --git a/arch/arm/plat-omap/fb.c b/arch/arm/plat-omap/fb.c
index 0054b95..7193481 100644
--- a/arch/arm/plat-omap/fb.c
+++ b/arch/arm/plat-omap/fb.c
@@ -173,11 +173,7 @@ static int check_fbmem_region(int region_idx, struct omapfb_mem_region *rg,
 
 static int valid_sdram(unsigned long addr, unsigned long size)
 {
-	struct memblock_property res;
-
-	res.base = addr;
-	res.size = size;
-	return !memblock_find(&res) && res.base == addr && res.size == size;
+	return memblock_is_region_memory(addr, size);
 }
 
 static int reserve_sdram(unsigned long addr, unsigned long size)
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
 
 
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 65eb004..c843786 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -70,16 +70,16 @@ static void __init paging_init(void)
 
 void __init setup_memory(void)
 {
-	int i;
 	unsigned long map_size;
+	struct memblock_region *reg;
+
 #ifndef CONFIG_MMU
 	u32 kernel_align_start, kernel_align_size;
 
 	/* Find main memory where is the kernel */
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		memory_start = (u32) memblock.memory.region[i].base;
-		memory_end = (u32) memblock.memory.region[i].base
-				+ (u32) memblock.memory.region[i].size;
+	for_each_memblock(memory, reg) {
+		memory_start = (u32)reg->base;
+		memory_end = (u32) reg->base + reg->size;
 		if ((memory_start <= (u32)_text) &&
 					((u32)_text <= memory_end)) {
 			memory_size = memory_end - memory_start;
@@ -142,12 +142,10 @@ void __init setup_memory(void)
 	free_bootmem(memory_start, memory_size);
 
 	/* reserve allocate blocks */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		pr_debug("reserved %d - 0x%08x-0x%08x\n", i,
-			(u32) memblock.reserved.region[i].base,
-			(u32) memblock_size_bytes(&memblock.reserved, i));
-		reserve_bootmem(memblock.reserved.region[i].base,
-			memblock_size_bytes(&memblock.reserved, i) - 1, BOOTMEM_DEFAULT);
+	for_each_memblock(reserved, reg) {
+		pr_debug("reserved - 0x%08x-0x%08x\n",
+			 (u32) reg->base, (u32) reg->size);
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 	}
 #ifdef CONFIG_MMU
 	init_bootmem_done = 1;
@@ -230,7 +228,7 @@ static void mm_cmdline_setup(void)
 		if (maxmem && memory_size > maxmem) {
 			memory_size = maxmem;
 			memory_end = memory_start + memory_size;
-			memblock.memory.region[0].size = memory_size;
+			memblock.memory.regions[0].size = memory_size;
 		}
 	}
 }
@@ -273,14 +271,14 @@ asmlinkage void __init mmu_init(void)
 		machine_restart(NULL);
 	}
 
-	if ((u32) memblock.memory.region[0].size < 0x1000000) {
+	if ((u32) memblock.memory.regions[0].size < 0x1000000) {
 		printk(KERN_EMERG "Memory must be greater than 16MB\n");
 		machine_restart(NULL);
 	}
 	/* Find main memory where the kernel is */
-	memory_start = (u32) memblock.memory.region[0].base;
-	memory_end = (u32) memblock.memory.region[0].base +
-				(u32) memblock.memory.region[0].size;
+	memory_start = (u32) memblock.memory.regions[0].base;
+	memory_end = (u32) memblock.memory.regions[0].base +
+				(u32) memblock.memory.regions[0].size;
 	memory_size = memory_end - memory_start;
 
 	mm_cmdline_setup(); /* FIXME parse args from command line - not used */
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
index d0a26f1..a4e7215 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -127,7 +127,7 @@ void __init allocate_pacas(void)
 	 * the first segment. On iSeries they must be within the area mapped
 	 * by the HV, which is HvPagesToMap * HVPAGESIZE bytes.
 	 */
-	limit = min(0x10000000ULL, memblock.rmo_size);
+	limit = min(0x10000000ULL, ppc64_rma_size);
 	if (firmware_has_feature(FW_FEATURE_ISERIES))
 		limit = min(limit, HvPagesToMap * HVPAGESIZE);
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index fed9bf6..c3c6a88 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -66,6 +66,7 @@
 int __initdata iommu_is_off;
 int __initdata iommu_force_on;
 unsigned long tce_alloc_start, tce_alloc_end;
+u64 ppc64_rma_size;
 #endif
 
 static int __init early_parse_mem(char *p)
@@ -98,7 +99,7 @@ static void __init move_device_tree(void)
 
 	if ((memory_limit && (start + size) > memory_limit) ||
 			overlaps_crashkernel(start, size)) {
-		p = __va(memblock_alloc_base(size, PAGE_SIZE, memblock.rmo_size));
+		p = __va(memblock_alloc(size, PAGE_SIZE));
 		memcpy(p, initial_boot_params, size);
 		initial_boot_params = (struct boot_param_header *)p;
 		DBG("Moved device tree to 0x%p\n", p);
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
@@ -655,7 +660,6 @@ static void __init phyp_dump_reserve_mem(void)
 static inline void __init phyp_dump_reserve_mem(void) {}
 #endif /* CONFIG_PHYP_DUMP  && CONFIG_PPC_RTAS */
 
-
 void __init early_init_devtree(void *params)
 {
 	phys_addr_t limit;
@@ -683,6 +687,7 @@ void __init early_init_devtree(void *params)
 
 	/* Scan memory nodes and rebuild MEMBLOCKs */
 	memblock_init();
+
 	of_scan_flat_dt(early_init_dt_scan_root, NULL);
 	of_scan_flat_dt(early_init_dt_scan_memory_ppc, NULL);
 
diff --git a/arch/powerpc/kernel/rtas.c b/arch/powerpc/kernel/rtas.c
index 41048de..7333fdb 100644
--- a/arch/powerpc/kernel/rtas.c
+++ b/arch/powerpc/kernel/rtas.c
@@ -969,7 +969,7 @@ void __init rtas_initialize(void)
 	 */
 #ifdef CONFIG_PPC64
 	if (machine_is(pseries) && firmware_has_feature(FW_FEATURE_LPAR)) {
-		rtas_region = min(memblock.rmo_size, RTAS_INSTANTIATE_MAX);
+		rtas_region = min(ppc64_rma_size, RTAS_INSTANTIATE_MAX);
 		ibm_suspend_me_token = rtas_token("ibm,suspend-me");
 	}
 #endif
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 93666f9..b86111f 100644
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
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index e72690e..2a178b0 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -486,7 +486,7 @@ static void __init emergency_stack_init(void)
 	 * bringup, we need to get at them in real mode. This means they
 	 * must also be within the RMO region.
 	 */
-	limit = min(slb0_limit(), memblock.rmo_size);
+	limit = min(slb0_limit(), ppc64_rma_size);
 
 	for_each_possible_cpu(i) {
 		unsigned long sp;
diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
index 1dc2fa5..5810967 100644
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
@@ -139,8 +141,19 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
 	 * coverage with normal-sized pages (or other reasons) do not
 	 * attempt to allocate outside the allowed range.
 	 */
-
-	__initial_memory_limit_addr = memstart_addr + mapped;
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
index 4b66a1e..cde2708 100644
--- a/arch/powerpc/mm/fsl_booke_mmu.c
+++ b/arch/powerpc/mm/fsl_booke_mmu.c
@@ -40,6 +40,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/highmem.h>
+#include <linux/memblock.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
@@ -213,5 +214,14 @@ void __init adjust_total_lowmem(void)
 	pr_cont("%lu Mb, residual: %dMb\n", tlbcam_sz(tlbcam_index - 1) >> 20,
 	        (unsigned int)((total_lowmem - __max_low_memory) >> 20));
 
-	__initial_memory_limit_addr = memstart_addr + __max_low_memory;
+	memblock_set_current_limit(memstart_addr + __max_low_memory);
+}
+
+void setup_initial_memory_limit(phys_addr_t first_memblock_base,
+				phys_addr_t first_memblock_size)
+{
+	phys_addr_t limit = first_memblock_base + first_memblock_size;
+
+	/* 64M mapped initially according to head_fsl_booke.S */
+	memblock_set_current_limit(min_t(u64, limit, 0x04000000));
 }
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 09dffe6..83f534d 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -588,7 +588,7 @@ static void __init htab_initialize(void)
 	unsigned long pteg_count;
 	unsigned long prot;
 	unsigned long base = 0, size = 0, limit;
-	int i;
+	struct memblock_region *reg;
 
 	DBG(" -> htab_initialize()\n");
 
@@ -625,7 +625,7 @@ static void __init htab_initialize(void)
 		if (machine_is(cell))
 			limit = 0x80000000;
 		else
-			limit = 0;
+			limit = MEMBLOCK_ALLOC_ANYWHERE;
 
 		table = memblock_alloc_base(htab_size_bytes, htab_size_bytes, limit);
 
@@ -649,7 +649,7 @@ static void __init htab_initialize(void)
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	linear_map_hash_count = memblock_end_of_DRAM() >> PAGE_SHIFT;
 	linear_map_hash_slots = __va(memblock_alloc_base(linear_map_hash_count,
-						    1, memblock.rmo_size));
+						    1, ppc64_rma_size));
 	memset(linear_map_hash_slots, 0, linear_map_hash_count);
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
@@ -659,9 +659,9 @@ static void __init htab_initialize(void)
 	 */
 
 	/* create bolted the linear mapping in the hash table */
-	for (i=0; i < memblock.memory.cnt; i++) {
-		base = (unsigned long)__va(memblock.memory.region[i].base);
-		size = memblock.memory.region[i].size;
+	for_each_memblock(memory, reg) {
+		base = (unsigned long)__va(reg->base);
+		size = reg->size;
 
 		DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
 		    base, size, prot);
@@ -696,7 +696,8 @@ static void __init htab_initialize(void)
 #endif /* CONFIG_U3_DART */
 		BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
 				prot, mmu_linear_psize, mmu_kernel_ssize));
-       }
+	}
+	memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
 
 	/*
 	 * If we have a memory_limit and we've allocated TCEs then we need to
@@ -1247,3 +1248,23 @@ void kernel_map_pages(struct page *page, int numpages, int enable)
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
index 6a6975d..742da43 100644
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
@@ -252,3 +237,17 @@ void free_initrd_mem(unsigned long start, unsigned long end)
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
index ace85fa..6374b21 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -330,3 +330,4 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
+
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 1a84a8d..a664996 100644
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
 
-		base = memblock.memory.region[i].base;
-
-		if ((paddr >= base) &&
-			(paddr < (base + memblock.memory.region[i].size))) {
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
-	struct memblock_property res;
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
+		tstart = max(start_pfn, memblock_region_memory_base_pfn(reg));
+		tend = min(end_pfn, memblock_region_memory_end_pfn(reg));
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
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+		start_pfn = memblock_region_memory_base_pfn(reg);
+		end_pfn = memblock_region_memory_end_pfn(reg);
 		add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -218,29 +207,21 @@ void __init do_init_bootmem(void)
 	free_bootmem_with_active_regions(0, lowmem_end_addr >> PAGE_SHIFT);
 
 	/* reserve the sections we're already using */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long addr = memblock.reserved.region[i].base +
-				     memblock_size_bytes(&memblock.reserved, i) - 1;
-		if (addr < lowmem_end_addr)
-			reserve_bootmem(memblock.reserved.region[i].base,
-					memblock_size_bytes(&memblock.reserved, i),
-					BOOTMEM_DEFAULT);
-		else if (memblock.reserved.region[i].base < lowmem_end_addr) {
-			unsigned long adjusted_size = lowmem_end_addr -
-				      memblock.reserved.region[i].base;
-			reserve_bootmem(memblock.reserved.region[i].base,
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
-		reserve_bootmem(memblock.reserved.region[i].base,
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
-			(memblock.memory.region[i].base >> PAGE_SHIFT) +
-			(memblock.memory.region[i].size >> PAGE_SHIFT);
-		memblock_next_region_start_pfn =
-			memblock.memory.region[i+1].base >> PAGE_SHIFT;
-
-		if (memblock_region_max_pfn < memblock_next_region_start_pfn)
-			register_nosave_region(memblock_region_max_pfn,
-					       memblock_next_region_start_pfn);
+	struct memblock_region *reg, *prev = NULL;
+
+	for_each_memblock(memory, reg) {
+		if (prev &&
+		    memblock_region_memory_end_pfn(prev) < memblock_region_memory_base_pfn(reg))
+			register_nosave_region(memblock_region_memory_end_pfn(prev),
+					       memblock_region_memory_base_pfn(reg));
+		prev = reg;
 	}
-
 	return 0;
 }
 
@@ -327,7 +301,7 @@ void __init mem_init(void)
 		swiotlb_init(1);
 #endif
 
-	num_physpages = memblock.memory.size >> PAGE_SHIFT;
+	num_physpages = memblock_phys_mem_size() >> PAGE_SHIFT;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 002878c..74505b2 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -802,16 +802,17 @@ static void __init setup_nonnuma(void)
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
+		start_pfn = memblock_region_memory_base_pfn(reg);
+		end_pfn = memblock_region_memory_end_pfn(reg);
 
 		fake_numa_create_new_node(end_pfn, &nid);
 		add_active_range(nid, start_pfn, end_pfn);
@@ -947,11 +948,11 @@ static struct notifier_block __cpuinitdata ppc64_numa_nb = {
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
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index f8a0182..11571e1 100644
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
 
@@ -272,3 +271,18 @@ void __init MMU_init_hw(void)
 
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
index fe391e9..6a0f20c 100644
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -509,6 +509,8 @@ static void __early_init_mmu(int boot_cpu)
 	 * the MMU configuration
 	 */
 	mb();
+
+	memblock_set_current_limit(linear_map_top);
 }
 
 void __init early_init_mmu(void)
@@ -521,4 +523,18 @@ void __cpuinit early_init_mmu_secondary(void)
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
diff --git a/arch/powerpc/platforms/embedded6xx/wii.c b/arch/powerpc/platforms/embedded6xx/wii.c
index 5cdcc7c..649473a 100644
--- a/arch/powerpc/platforms/embedded6xx/wii.c
+++ b/arch/powerpc/platforms/embedded6xx/wii.c
@@ -65,7 +65,7 @@ static int __init page_aligned(unsigned long x)
 
 void __init wii_memory_fixups(void)
 {
-	struct memblock_property *p = memblock.memory.region;
+	struct memblock_region *p = memblock.memory.regions;
 
 	/*
 	 * This is part of a workaround to allow the use of two
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
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index d0e2491..552bea5 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -200,7 +200,6 @@ static void __init bootmem_init_one_node(unsigned int nid)
 	unsigned long total_pages, paddr;
 	unsigned long end_pfn;
 	struct pglist_data *p;
-	int i;
 
 	p = NODE_DATA(nid);
 
@@ -226,11 +225,12 @@ static void __init bootmem_init_one_node(unsigned int nid)
 	 * reservations in other nodes.
 	 */
 	if (nid == 0) {
+		struct memblock_region *reg;
+
 		/* Reserve the sections we're already using. */
-		for (i = 0; i < memblock.reserved.cnt; i++)
-			reserve_bootmem(memblock.reserved.region[i].base,
-					memblock_size_bytes(&memblock.reserved, i),
-					BOOTMEM_DEFAULT);
+		for_each_memblock(reserved, reg) {
+			reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
+		}
 	}
 
 	sparse_memory_present_with_active_regions(nid);
@@ -238,13 +238,14 @@ static void __init bootmem_init_one_node(unsigned int nid)
 
 static void __init do_init_bootmem(void)
 {
+	struct memblock_region *reg;
 	int i;
 
 	/* Add active regions with valid PFNs. */
-	for (i = 0; i < memblock.memory.cnt; i++) {
+	for_each_memblock(memory, reg) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+		start_pfn = memblock_region_memory_base_pfn(reg);
+		end_pfn = memblock_region_memory_end_pfn(reg);
 		__add_active_range(0, start_pfn, end_pfn);
 	}
 
diff --git a/arch/sparc/include/asm/memblock.h b/arch/sparc/include/asm/memblock.h
index f12af88..c67b047 100644
--- a/arch/sparc/include/asm/memblock.h
+++ b/arch/sparc/include/asm/memblock.h
@@ -5,6 +5,4 @@
 
 #define MEMBLOCK_DBG(fmt...) prom_printf(fmt)
 
-#define MEMBLOCK_REAL_LIMIT	0
-
 #endif /* !(_SPARC64_MEMBLOCK_H) */
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index f043451..4c25727 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -785,8 +785,7 @@ static int find_node(unsigned long addr)
 	return -1;
 }
 
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 memblock_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = find_node(start);
 	start += PAGE_SIZE;
@@ -804,8 +803,7 @@ static unsigned long long nid_range(unsigned long long start,
 	return start;
 }
 #else
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 memblock_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = 0;
 	return end;
@@ -822,8 +820,7 @@ static void __init allocate_node_data(int nid)
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	paddr = memblock_alloc_nid(sizeof(struct pglist_data),
-			      SMP_CACHE_BYTES, nid, nid_range);
+	paddr = memblock_alloc_try_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -843,8 +840,7 @@ static void __init allocate_node_data(int nid)
 	if (p->node_spanned_pages) {
 		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
 
-		paddr = memblock_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid,
-				      nid_range);
+		paddr = memblock_alloc_try_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
 		if (!paddr) {
 			prom_printf("Cannot allocate bootmap for nid[%d]\n",
 				  nid);
@@ -972,19 +968,19 @@ int of_node_to_nid(struct device_node *dp)
 
 static void __init add_node_ranges(void)
 {
-	int i;
+	struct memblock_region *reg;
 
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		unsigned long size = memblock_size_bytes(&memblock.memory, i);
+	for_each_memblock(memory, reg) {
+		unsigned long size = reg->size;
 		unsigned long start, end;
 
-		start = memblock.memory.region[i].base;
+		start = reg->base;
 		end = start + size;
 		while (start < end) {
 			unsigned long this_end;
 			int nid;
 
-			this_end = nid_range(start, end, &nid);
+			this_end = memblock_nid_range(start, end, &nid);
 
 			numadbg("Adding active range nid[%d] "
 				"start[%lx] end[%lx]\n",
@@ -1281,7 +1277,7 @@ static void __init bootmem_init_nonnuma(void)
 {
 	unsigned long top_of_ram = memblock_end_of_DRAM();
 	unsigned long total_ram = memblock_phys_mem_size();
-	unsigned int i;
+	struct memblock_region *reg;
 
 	numadbg("bootmem_init_nonnuma()\n");
 
@@ -1292,15 +1288,14 @@ static void __init bootmem_init_nonnuma(void)
 
 	init_node_masks_nonnuma();
 
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		unsigned long size = memblock_size_bytes(&memblock.memory, i);
+	for_each_memblock(memory, reg) {
 		unsigned long start_pfn, end_pfn;
 
-		if (!size)
+		if (!reg->size)
 			continue;
 
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+		start_pfn = memblock_region_memory_base_pfn(reg);
+		end_pfn = memblock_region_memory_end_pfn(reg);
 		add_active_range(0, start_pfn, end_pfn);
 	}
 
@@ -1318,7 +1313,7 @@ static void __init reserve_range_in_node(int nid, unsigned long start,
 		unsigned long this_end;
 		int n;
 
-		this_end = nid_range(start, end, &n);
+		this_end = memblock_nid_range(start, end, &n);
 		if (n == nid) {
 			numadbg("      MATCH reserving range [%lx:%lx]\n",
 				start, this_end);
@@ -1334,17 +1329,12 @@ static void __init reserve_range_in_node(int nid, unsigned long start,
 
 static void __init trim_reserved_in_node(int nid)
 {
-	int i;
+	struct memblock_region *reg;
 
 	numadbg("  trim_reserved_in_node(%d)\n", nid);
 
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		unsigned long start = memblock.reserved.region[i].base;
-		unsigned long size = memblock_size_bytes(&memblock.reserved, i);
-		unsigned long end = start + size;
-
-		reserve_range_in_node(nid, start, end);
-	}
+	for_each_memblock(reserved, reg)
+		reserve_range_in_node(nid, reg->base, reg->base + reg->size);
 }
 
 static void __init bootmem_init_one_node(int nid)
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8c9e609..4ce983a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -28,6 +28,7 @@ config X86
 	select HAVE_IRQ_WORK
 	select HAVE_IOREMAP_PROT
 	select HAVE_KPROBES
+	select HAVE_MEMBLOCK
 	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_WANT_FRAME_POINTERS
 	select HAVE_DMA_ATTRS
@@ -197,9 +198,6 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
 config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	def_bool y
 
-config HAVE_EARLY_RES
-	def_bool y
-
 config HAVE_INTEL_TXT
 	def_bool y
 	depends on EXPERIMENTAL && DMAR && ACPI
@@ -575,16 +573,7 @@ config PARAVIRT_DEBUG
 	  a paravirt_op is missing when it is called.
 
 config NO_BOOTMEM
-	default y
-	bool "Disable Bootmem code"
-	---help---
-	  Use early_res directly instead of bootmem before slab is ready.
-		- allocator (buddy) [generic]
-		- early allocator (bootmem) [generic]
-		- very early allocator (reserve_early*()) [x86]
-		- very very early allocator (early brk model) [x86]
-	  So reduce one layer between early allocator to final allocator
-
+	def_bool y
 
 config MEMTEST
 	bool "Memtest"
diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
index ec8a52d..5be1542 100644
--- a/arch/x86/include/asm/e820.h
+++ b/arch/x86/include/asm/e820.h
@@ -112,23 +112,13 @@ static inline void early_memtest(unsigned long start, unsigned long end)
 }
 #endif
 
-extern unsigned long end_user_pfn;
-
-extern u64 find_e820_area(u64 start, u64 end, u64 size, u64 align);
-extern u64 find_e820_area_size(u64 start, u64 *sizep, u64 align);
-extern u64 early_reserve_e820(u64 startt, u64 sizet, u64 align);
-#include <linux/early_res.h>
-
 extern unsigned long e820_end_of_ram_pfn(void);
 extern unsigned long e820_end_of_low_ram_pfn(void);
-extern int e820_find_active_region(const struct e820entry *ei,
-				  unsigned long start_pfn,
-				  unsigned long last_pfn,
-				  unsigned long *ei_startpfn,
-				  unsigned long *ei_endpfn);
-extern void e820_register_active_regions(int nid, unsigned long start_pfn,
-					 unsigned long end_pfn);
-extern u64 e820_hole_size(u64 start, u64 end);
+extern u64 early_reserve_e820(u64 startt, u64 sizet, u64 align);
+
+void memblock_x86_fill(void);
+void memblock_find_dma_reserve(void);
+
 extern void finish_e820_parsing(void);
 extern void e820_reserve_resources(void);
 extern void e820_reserve_resources_late(void);
diff --git a/arch/x86/include/asm/efi.h b/arch/x86/include/asm/efi.h
index 8406ed7..8e4a165 100644
--- a/arch/x86/include/asm/efi.h
+++ b/arch/x86/include/asm/efi.h
@@ -90,7 +90,7 @@ extern void __iomem *efi_ioremap(unsigned long addr, unsigned long size,
 #endif /* CONFIG_X86_32 */
 
 extern int add_efi_memmap;
-extern void efi_reserve_early(void);
+extern void efi_memblock_x86_reserve_range(void);
 extern void efi_call_phys_prelog(void);
 extern void efi_call_phys_epilog(void);
 
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 6a45ec4..f0203f4 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -349,6 +349,7 @@ extern void __iomem *early_memremap(resource_size_t phys_addr,
 				    unsigned long size);
 extern void early_iounmap(void __iomem *addr, unsigned long size);
 extern void fixup_early_ioremap(void);
+extern bool is_early_ioremap_ptep(pte_t *ptep);
 
 #define IO_SPACE_LIMIT 0xffff
 
diff --git a/arch/x86/include/asm/memblock.h b/arch/x86/include/asm/memblock.h
new file mode 100644
index 0000000..19ae14b
--- /dev/null
+++ b/arch/x86/include/asm/memblock.h
@@ -0,0 +1,23 @@
+#ifndef _X86_MEMBLOCK_H
+#define _X86_MEMBLOCK_H
+
+#define ARCH_DISCARD_MEMBLOCK
+
+u64 memblock_x86_find_in_range_size(u64 start, u64 *sizep, u64 align);
+void memblock_x86_to_bootmem(u64 start, u64 end);
+
+void memblock_x86_reserve_range(u64 start, u64 end, char *name);
+void memblock_x86_free_range(u64 start, u64 end);
+struct range;
+int __get_free_all_memory_range(struct range **range, int nodeid,
+			 unsigned long start_pfn, unsigned long end_pfn);
+int get_free_all_memory_range(struct range **rangep, int nodeid);
+
+void memblock_x86_register_active_regions(int nid, unsigned long start_pfn,
+					 unsigned long last_pfn);
+u64 memblock_x86_hole_size(u64 start, u64 end);
+u64 memblock_x86_find_in_range_node(int nid, u64 start, u64 end, u64 size, u64 align);
+u64 memblock_x86_free_memory_in_range(u64 addr, u64 limit);
+u64 memblock_x86_memory_in_range(u64 addr, u64 limit);
+
+#endif
diff --git a/arch/x86/kernel/acpi/sleep.c b/arch/x86/kernel/acpi/sleep.c
index 33cec15..e125207 100644
--- a/arch/x86/kernel/acpi/sleep.c
+++ b/arch/x86/kernel/acpi/sleep.c
@@ -7,6 +7,7 @@
 
 #include <linux/acpi.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dmi.h>
 #include <linux/cpumask.h>
 #include <asm/segment.h>
@@ -125,7 +126,7 @@ void acpi_restore_state_mem(void)
  */
 void __init acpi_reserve_wakeup_memory(void)
 {
-	unsigned long mem;
+	phys_addr_t mem;
 
 	if ((&wakeup_code_end - &wakeup_code_start) > WAKEUP_SIZE) {
 		printk(KERN_ERR
@@ -133,15 +134,15 @@ void __init acpi_reserve_wakeup_memory(void)
 		return;
 	}
 
-	mem = find_e820_area(0, 1<<20, WAKEUP_SIZE, PAGE_SIZE);
+	mem = memblock_find_in_range(0, 1<<20, WAKEUP_SIZE, PAGE_SIZE);
 
-	if (mem == -1L) {
+	if (mem == MEMBLOCK_ERROR) {
 		printk(KERN_ERR "ACPI: Cannot allocate lowmem, S3 disabled.\n");
 		return;
 	}
 	acpi_realmode = (unsigned long) phys_to_virt(mem);
 	acpi_wakeup_address = mem;
-	reserve_early(mem, mem + WAKEUP_SIZE, "ACPI WAKEUP");
+	memblock_x86_reserve_range(mem, mem + WAKEUP_SIZE, "ACPI WAKEUP");
 }
 
 
diff --git a/arch/x86/kernel/apic/numaq_32.c b/arch/x86/kernel/apic/numaq_32.c
index 3e28401..960f26a 100644
--- a/arch/x86/kernel/apic/numaq_32.c
+++ b/arch/x86/kernel/apic/numaq_32.c
@@ -26,6 +26,7 @@
 #include <linux/nodemask.h>
 #include <linux/topology.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
 #include <linux/kernel.h>
@@ -88,7 +89,7 @@ static inline void numaq_register_node(int node, struct sys_cfg_data *scd)
 	node_end_pfn[node] =
 		 MB_TO_PAGES(eq->hi_shrd_mem_start + eq->hi_shrd_mem_size);
 
-	e820_register_active_regions(node, node_start_pfn[node],
+	memblock_x86_register_active_regions(node, node_start_pfn[node],
 						node_end_pfn[node]);
 
 	memory_present(node, node_start_pfn[node], node_end_pfn[node]);
diff --git a/arch/x86/kernel/check.c b/arch/x86/kernel/check.c
index fc999e6..13a3891 100644
--- a/arch/x86/kernel/check.c
+++ b/arch/x86/kernel/check.c
@@ -2,7 +2,8 @@
 #include <linux/sched.h>
 #include <linux/kthread.h>
 #include <linux/workqueue.h>
-#include <asm/e820.h>
+#include <linux/memblock.h>
+
 #include <asm/proto.h>
 
 /*
@@ -18,10 +19,12 @@ static int __read_mostly memory_corruption_check = -1;
 static unsigned __read_mostly corruption_check_size = 64*1024;
 static unsigned __read_mostly corruption_check_period = 60; /* seconds */
 
-static struct e820entry scan_areas[MAX_SCAN_AREAS];
+static struct scan_area {
+	u64 addr;
+	u64 size;
+} scan_areas[MAX_SCAN_AREAS];
 static int num_scan_areas;
 
-
 static __init int set_corruption_check(char *arg)
 {
 	char *end;
@@ -81,9 +84,9 @@ void __init setup_bios_corruption_check(void)
 
 	while (addr < corruption_check_size && num_scan_areas < MAX_SCAN_AREAS) {
 		u64 size;
-		addr = find_e820_area_size(addr, &size, PAGE_SIZE);
+		addr = memblock_x86_find_in_range_size(addr, &size, PAGE_SIZE);
 
-		if (!(addr + 1))
+		if (addr == MEMBLOCK_ERROR)
 			break;
 
 		if (addr >= corruption_check_size)
@@ -92,7 +95,7 @@ void __init setup_bios_corruption_check(void)
 		if ((addr + size) > corruption_check_size)
 			size = corruption_check_size - addr;
 
-		e820_update_range(addr, size, E820_RAM, E820_RESERVED);
+		memblock_x86_reserve_range(addr, addr + size, "SCAN RAM");
 		scan_areas[num_scan_areas].addr = addr;
 		scan_areas[num_scan_areas].size = size;
 		num_scan_areas++;
@@ -105,7 +108,6 @@ void __init setup_bios_corruption_check(void)
 
 	printk(KERN_INFO "Scanning %d areas for low memory corruption\n",
 	       num_scan_areas);
-	update_e820();
 }
 
 
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 0d6fc71..0c2b7ef 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -15,6 +15,7 @@
 #include <linux/pfn.h>
 #include <linux/suspend.h>
 #include <linux/firmware-map.h>
+#include <linux/memblock.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -738,73 +739,7 @@ core_initcall(e820_mark_nvs_memory);
 #endif
 
 /*
- * Find a free area with specified alignment in a specific range.
- */
-u64 __init find_e820_area(u64 start, u64 end, u64 size, u64 align)
-{
-	int i;
-
-	for (i = 0; i < e820.nr_map; i++) {
-		struct e820entry *ei = &e820.map[i];
-		u64 addr;
-		u64 ei_start, ei_last;
-
-		if (ei->type != E820_RAM)
-			continue;
-
-		ei_last = ei->addr + ei->size;
-		ei_start = ei->addr;
-		addr = find_early_area(ei_start, ei_last, start, end,
-					 size, align);
-
-		if (addr != -1ULL)
-			return addr;
-	}
-	return -1ULL;
-}
-
-u64 __init find_fw_memmap_area(u64 start, u64 end, u64 size, u64 align)
-{
-	return find_e820_area(start, end, size, align);
-}
-
-u64 __init get_max_mapped(void)
-{
-	u64 end = max_pfn_mapped;
-
-	end <<= PAGE_SHIFT;
-
-	return end;
-}
-/*
- * Find next free range after *start
- */
-u64 __init find_e820_area_size(u64 start, u64 *sizep, u64 align)
-{
-	int i;
-
-	for (i = 0; i < e820.nr_map; i++) {
-		struct e820entry *ei = &e820.map[i];
-		u64 addr;
-		u64 ei_start, ei_last;
-
-		if (ei->type != E820_RAM)
-			continue;
-
-		ei_last = ei->addr + ei->size;
-		ei_start = ei->addr;
-		addr = find_early_area_size(ei_start, ei_last, start,
-					 sizep, align);
-
-		if (addr != -1ULL)
-			return addr;
-	}
-
-	return -1ULL;
-}
-
-/*
- * pre allocated 4k and reserved it in e820
+ * pre allocated 4k and reserved it in memblock and e820_saved
  */
 u64 __init early_reserve_e820(u64 startt, u64 sizet, u64 align)
 {
@@ -813,8 +748,8 @@ u64 __init early_reserve_e820(u64 startt, u64 sizet, u64 align)
 	u64 start;
 
 	for (start = startt; ; start += size) {
-		start = find_e820_area_size(start, &size, align);
-		if (!(start + 1))
+		start = memblock_x86_find_in_range_size(start, &size, align);
+		if (start == MEMBLOCK_ERROR)
 			return 0;
 		if (size >= sizet)
 			break;
@@ -830,10 +765,9 @@ u64 __init early_reserve_e820(u64 startt, u64 sizet, u64 align)
 	addr = round_down(start + size - sizet, align);
 	if (addr < start)
 		return 0;
-	e820_update_range(addr, sizet, E820_RAM, E820_RESERVED);
+	memblock_x86_reserve_range(addr, addr + sizet, "new next");
 	e820_update_range_saved(addr, sizet, E820_RAM, E820_RESERVED);
-	printk(KERN_INFO "update e820 for early_reserve_e820\n");
-	update_e820();
+	printk(KERN_INFO "update e820_saved for early_reserve_e820\n");
 	update_e820_saved();
 
 	return addr;
@@ -895,74 +829,6 @@ unsigned long __init e820_end_of_low_ram_pfn(void)
 {
 	return e820_end_pfn(1UL<<(32 - PAGE_SHIFT), E820_RAM);
 }
-/*
- * Finds an active region in the address range from start_pfn to last_pfn and
- * returns its range in ei_startpfn and ei_endpfn for the e820 entry.
- */
-int __init e820_find_active_region(const struct e820entry *ei,
-				  unsigned long start_pfn,
-				  unsigned long last_pfn,
-				  unsigned long *ei_startpfn,
-				  unsigned long *ei_endpfn)
-{
-	u64 align = PAGE_SIZE;
-
-	*ei_startpfn = round_up(ei->addr, align) >> PAGE_SHIFT;
-	*ei_endpfn = round_down(ei->addr + ei->size, align) >> PAGE_SHIFT;
-
-	/* Skip map entries smaller than a page */
-	if (*ei_startpfn >= *ei_endpfn)
-		return 0;
-
-	/* Skip if map is outside the node */
-	if (ei->type != E820_RAM || *ei_endpfn <= start_pfn ||
-				    *ei_startpfn >= last_pfn)
-		return 0;
-
-	/* Check for overlaps */
-	if (*ei_startpfn < start_pfn)
-		*ei_startpfn = start_pfn;
-	if (*ei_endpfn > last_pfn)
-		*ei_endpfn = last_pfn;
-
-	return 1;
-}
-
-/* Walk the e820 map and register active regions within a node */
-void __init e820_register_active_regions(int nid, unsigned long start_pfn,
-					 unsigned long last_pfn)
-{
-	unsigned long ei_startpfn;
-	unsigned long ei_endpfn;
-	int i;
-
-	for (i = 0; i < e820.nr_map; i++)
-		if (e820_find_active_region(&e820.map[i],
-					    start_pfn, last_pfn,
-					    &ei_startpfn, &ei_endpfn))
-			add_active_range(nid, ei_startpfn, ei_endpfn);
-}
-
-/*
- * Find the hole size (in bytes) in the memory range.
- * @start: starting address of the memory range to scan
- * @end: ending address of the memory range to scan
- */
-u64 __init e820_hole_size(u64 start, u64 end)
-{
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long last_pfn = end >> PAGE_SHIFT;
-	unsigned long ei_startpfn, ei_endpfn, ram = 0;
-	int i;
-
-	for (i = 0; i < e820.nr_map; i++) {
-		if (e820_find_active_region(&e820.map[i],
-					    start_pfn, last_pfn,
-					    &ei_startpfn, &ei_endpfn))
-			ram += ei_endpfn - ei_startpfn;
-	}
-	return end - start - ((u64)ram << PAGE_SHIFT);
-}
 
 static void early_panic(char *msg)
 {
@@ -1210,3 +1076,48 @@ void __init setup_memory_map(void)
 	printk(KERN_INFO "BIOS-provided physical RAM map:\n");
 	e820_print_map(who);
 }
+
+void __init memblock_x86_fill(void)
+{
+	int i;
+	u64 end;
+
+	/*
+	 * EFI may have more than 128 entries
+	 * We are safe to enable resizing, beause memblock_x86_fill()
+	 * is rather later for x86
+	 */
+	memblock_can_resize = 1;
+
+	for (i = 0; i < e820.nr_map; i++) {
+		struct e820entry *ei = &e820.map[i];
+
+		end = ei->addr + ei->size;
+		if (end != (resource_size_t)end)
+			continue;
+
+		if (ei->type != E820_RAM && ei->type != E820_RESERVED_KERN)
+			continue;
+
+		memblock_add(ei->addr, ei->size);
+	}
+
+	memblock_analyze();
+	memblock_dump_all();
+}
+
+void __init memblock_find_dma_reserve(void)
+{
+#ifdef CONFIG_X86_64
+	u64 free_size_pfn;
+	u64 mem_size_pfn;
+	/*
+	 * need to find out used area below MAX_DMA_PFN
+	 * need to use memblock to get free size in [0, MAX_DMA_PFN]
+	 * at first, and assume boot_mem will not take below MAX_DMA_PFN
+	 */
+	mem_size_pfn = memblock_x86_memory_in_range(0, MAX_DMA_PFN << PAGE_SHIFT) >> PAGE_SHIFT;
+	free_size_pfn = memblock_x86_free_memory_in_range(0, MAX_DMA_PFN << PAGE_SHIFT) >> PAGE_SHIFT;
+	set_dma_reserve(mem_size_pfn - free_size_pfn);
+#endif
+}
diff --git a/arch/x86/kernel/efi.c b/arch/x86/kernel/efi.c
index c2fa9b8..0fe27d7 100644
--- a/arch/x86/kernel/efi.c
+++ b/arch/x86/kernel/efi.c
@@ -30,6 +30,7 @@
 #include <linux/init.h>
 #include <linux/efi.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/spinlock.h>
 #include <linux/uaccess.h>
 #include <linux/time.h>
@@ -275,7 +276,7 @@ static void __init do_add_efi_memmap(void)
 	sanitize_e820_map(e820.map, ARRAY_SIZE(e820.map), &e820.nr_map);
 }
 
-void __init efi_reserve_early(void)
+void __init efi_memblock_x86_reserve_range(void)
 {
 	unsigned long pmap;
 
@@ -290,7 +291,7 @@ void __init efi_reserve_early(void)
 		boot_params.efi_info.efi_memdesc_size;
 	memmap.desc_version = boot_params.efi_info.efi_memdesc_version;
 	memmap.desc_size = boot_params.efi_info.efi_memdesc_size;
-	reserve_early(pmap, pmap + memmap.nr_map * memmap.desc_size,
+	memblock_x86_reserve_range(pmap, pmap + memmap.nr_map * memmap.desc_size,
 		      "EFI memmap");
 }
 
diff --git a/arch/x86/kernel/head.c b/arch/x86/kernel/head.c
index 3e66bd3..af0699b 100644
--- a/arch/x86/kernel/head.c
+++ b/arch/x86/kernel/head.c
@@ -1,5 +1,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/bios_ebda.h>
@@ -51,5 +52,5 @@ void __init reserve_ebda_region(void)
 		lowmem = 0x9f000;
 
 	/* reserve all memory between lowmem and the 1MB mark */
-	reserve_early_overlap_ok(lowmem, 0x100000, "BIOS reserved");
+	memblock_x86_reserve_range(lowmem, 0x100000, "* BIOS reserved");
 }
diff --git a/arch/x86/kernel/head32.c b/arch/x86/kernel/head32.c
index 784360c..9a6ca23 100644
--- a/arch/x86/kernel/head32.c
+++ b/arch/x86/kernel/head32.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/start_kernel.h>
 #include <linux/mm.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/sections.h>
@@ -30,17 +31,18 @@ static void __init i386_default_early_setup(void)
 
 void __init i386_start_kernel(void)
 {
+	memblock_init();
+
 #ifdef CONFIG_X86_TRAMPOLINE
 	/*
 	 * But first pinch a few for the stack/trampoline stuff
 	 * FIXME: Don't need the extra page at 4K, but need to fix
 	 * trampoline before removing it. (see the GDT stuff)
 	 */
-	reserve_early_overlap_ok(PAGE_SIZE, PAGE_SIZE + PAGE_SIZE,
-					 "EX TRAMPOLINE");
+	memblock_x86_reserve_range(PAGE_SIZE, PAGE_SIZE + PAGE_SIZE, "EX TRAMPOLINE");
 #endif
 
-	reserve_early(__pa_symbol(&_text), __pa_symbol(&__bss_stop), "TEXT DATA BSS");
+	memblock_x86_reserve_range(__pa_symbol(&_text), __pa_symbol(&__bss_stop), "TEXT DATA BSS");
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	/* Reserve INITRD */
@@ -49,7 +51,7 @@ void __init i386_start_kernel(void)
 		u64 ramdisk_image = boot_params.hdr.ramdisk_image;
 		u64 ramdisk_size  = boot_params.hdr.ramdisk_size;
 		u64 ramdisk_end   = PAGE_ALIGN(ramdisk_image + ramdisk_size);
-		reserve_early(ramdisk_image, ramdisk_end, "RAMDISK");
+		memblock_x86_reserve_range(ramdisk_image, ramdisk_end, "RAMDISK");
 	}
 #endif
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 7147143..2d2673c 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -12,6 +12,7 @@
 #include <linux/percpu.h>
 #include <linux/start_kernel.h>
 #include <linux/io.h>
+#include <linux/memblock.h>
 
 #include <asm/processor.h>
 #include <asm/proto.h>
@@ -79,6 +80,8 @@ void __init x86_64_start_kernel(char * real_mode_data)
 	/* Cleanup the over mapped high alias */
 	cleanup_highmap();
 
+	max_pfn_mapped = KERNEL_IMAGE_SIZE >> PAGE_SHIFT;
+
 	for (i = 0; i < NUM_EXCEPTION_VECTORS; i++) {
 #ifdef CONFIG_EARLY_PRINTK
 		set_intr_gate(i, &early_idt_handlers[i]);
@@ -98,7 +101,9 @@ void __init x86_64_start_reservations(char *real_mode_data)
 {
 	copy_bootdata(__va(real_mode_data));
 
-	reserve_early(__pa_symbol(&_text), __pa_symbol(&__bss_stop), "TEXT DATA BSS");
+	memblock_init();
+
+	memblock_x86_reserve_range(__pa_symbol(&_text), __pa_symbol(&__bss_stop), "TEXT DATA BSS");
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	/* Reserve INITRD */
@@ -107,7 +112,7 @@ void __init x86_64_start_reservations(char *real_mode_data)
 		unsigned long ramdisk_image = boot_params.hdr.ramdisk_image;
 		unsigned long ramdisk_size  = boot_params.hdr.ramdisk_size;
 		unsigned long ramdisk_end   = PAGE_ALIGN(ramdisk_image + ramdisk_size);
-		reserve_early(ramdisk_image, ramdisk_end, "RAMDISK");
+		memblock_x86_reserve_range(ramdisk_image, ramdisk_end, "RAMDISK");
 	}
 #endif
 
diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index d7b6f7f..9af64d9 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/kernel_stat.h>
 #include <linux/mc146818rtc.h>
 #include <linux/bitops.h>
@@ -657,7 +658,7 @@ static void __init smp_reserve_memory(struct mpf_intel *mpf)
 {
 	unsigned long size = get_mpc_size(mpf->physptr);
 
-	reserve_early_overlap_ok(mpf->physptr, mpf->physptr+size, "MP-table mpc");
+	memblock_x86_reserve_range(mpf->physptr, mpf->physptr+size, "* MP-table mpc");
 }
 
 static int __init smp_scan_config(unsigned long base, unsigned long length)
@@ -686,7 +687,7 @@ static int __init smp_scan_config(unsigned long base, unsigned long length)
 			       mpf, (u64)virt_to_phys(mpf));
 
 			mem = virt_to_phys(mpf);
-			reserve_early_overlap_ok(mem, mem + sizeof(*mpf), "MP-table mpf");
+			memblock_x86_reserve_range(mem, mem + sizeof(*mpf), "* MP-table mpf");
 			if (mpf->physptr)
 				smp_reserve_memory(mpf);
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index a59f6a6..44e208e 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -31,6 +31,7 @@
 #include <linux/apm_bios.h>
 #include <linux/initrd.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/console.h>
 #include <linux/mca.h>
@@ -301,7 +302,7 @@ static inline void init_gbpages(void)
 static void __init reserve_brk(void)
 {
 	if (_brk_end > _brk_start)
-		reserve_early(__pa(_brk_start), __pa(_brk_end), "BRK");
+		memblock_x86_reserve_range(__pa(_brk_start), __pa(_brk_end), "BRK");
 
 	/* Mark brk area as locked down and no longer taking any
 	   new allocations */
@@ -323,17 +324,16 @@ static void __init relocate_initrd(void)
 	char *p, *q;
 
 	/* We need to move the initrd down into lowmem */
-	ramdisk_here = find_e820_area(0, end_of_lowmem, area_size,
+	ramdisk_here = memblock_find_in_range(0, end_of_lowmem, area_size,
 					 PAGE_SIZE);
 
-	if (ramdisk_here == -1ULL)
+	if (ramdisk_here == MEMBLOCK_ERROR)
 		panic("Cannot find place for new RAMDISK of size %lld\n",
 			 ramdisk_size);
 
 	/* Note: this includes all the lowmem currently occupied by
 	   the initrd, we rely on that fact to keep the data intact. */
-	reserve_early(ramdisk_here, ramdisk_here + area_size,
-			 "NEW RAMDISK");
+	memblock_x86_reserve_range(ramdisk_here, ramdisk_here + area_size, "NEW RAMDISK");
 	initrd_start = ramdisk_here + PAGE_OFFSET;
 	initrd_end   = initrd_start + ramdisk_size;
 	printk(KERN_INFO "Allocated new RAMDISK: %08llx - %08llx\n",
@@ -389,7 +389,7 @@ static void __init reserve_initrd(void)
 	initrd_start = 0;
 
 	if (ramdisk_size >= (end_of_lowmem>>1)) {
-		free_early(ramdisk_image, ramdisk_end);
+		memblock_x86_free_range(ramdisk_image, ramdisk_end);
 		printk(KERN_ERR "initrd too large to handle, "
 		       "disabling initrd\n");
 		return;
@@ -412,7 +412,7 @@ static void __init reserve_initrd(void)
 
 	relocate_initrd();
 
-	free_early(ramdisk_image, ramdisk_end);
+	memblock_x86_free_range(ramdisk_image, ramdisk_end);
 }
 #else
 static void __init reserve_initrd(void)
@@ -468,7 +468,7 @@ static void __init e820_reserve_setup_data(void)
 	e820_print_map("reserve setup_data");
 }
 
-static void __init reserve_early_setup_data(void)
+static void __init memblock_x86_reserve_range_setup_data(void)
 {
 	struct setup_data *data;
 	u64 pa_data;
@@ -480,7 +480,7 @@ static void __init reserve_early_setup_data(void)
 	while (pa_data) {
 		data = early_memremap(pa_data, sizeof(*data));
 		sprintf(buf, "setup data %x", data->type);
-		reserve_early(pa_data, pa_data+sizeof(*data)+data->len, buf);
+		memblock_x86_reserve_range(pa_data, pa_data+sizeof(*data)+data->len, buf);
 		pa_data = data->next;
 		early_iounmap(data, sizeof(*data));
 	}
@@ -501,6 +501,7 @@ static inline unsigned long long get_total_mem(void)
 	return total << PAGE_SHIFT;
 }
 
+#define DEFAULT_BZIMAGE_ADDR_MAX 0x37FFFFFF
 static void __init reserve_crashkernel(void)
 {
 	unsigned long long total_mem;
@@ -518,23 +519,27 @@ static void __init reserve_crashkernel(void)
 	if (crash_base <= 0) {
 		const unsigned long long alignment = 16<<20;	/* 16M */
 
-		crash_base = find_e820_area(alignment, ULONG_MAX, crash_size,
-				 alignment);
-		if (crash_base == -1ULL) {
+		/*
+		 *  kexec want bzImage is below DEFAULT_BZIMAGE_ADDR_MAX
+		 */
+		crash_base = memblock_find_in_range(alignment,
+			       DEFAULT_BZIMAGE_ADDR_MAX, crash_size, alignment);
+
+		if (crash_base == MEMBLOCK_ERROR) {
 			pr_info("crashkernel reservation failed - No suitable area found.\n");
 			return;
 		}
 	} else {
 		unsigned long long start;
 
-		start = find_e820_area(crash_base, ULONG_MAX, crash_size,
-				 1<<20);
+		start = memblock_find_in_range(crash_base,
+				 crash_base + crash_size, crash_size, 1<<20);
 		if (start != crash_base) {
 			pr_info("crashkernel reservation failed - memory is in use.\n");
 			return;
 		}
 	}
-	reserve_early(crash_base, crash_base + crash_size, "CRASH KERNEL");
+	memblock_x86_reserve_range(crash_base, crash_base + crash_size, "CRASH KERNEL");
 
 	printk(KERN_INFO "Reserving %ldMB of memory at %ldMB "
 			"for crashkernel (System RAM: %ldMB)\n",
@@ -614,7 +619,7 @@ static __init void reserve_ibft_region(void)
 	addr = find_ibft_region(&size);
 
 	if (size)
-		reserve_early_overlap_ok(addr, addr + size, "ibft");
+		memblock_x86_reserve_range(addr, addr + size, "* ibft");
 }
 
 static unsigned reserve_low = CONFIG_X86_RESERVE_LOW << 10;
@@ -642,6 +647,15 @@ static void __init trim_bios_range(void)
 	sanitize_e820_map(e820.map, ARRAY_SIZE(e820.map), &e820.nr_map);
 }
 
+static u64 __init get_max_mapped(void)
+{
+	u64 end = max_pfn_mapped;
+
+	end <<= PAGE_SHIFT;
+
+	return end;
+}
+
 static int __init parse_reservelow(char *p)
 {
 	unsigned long long size;
@@ -738,7 +752,7 @@ void __init setup_arch(char **cmdline_p)
 #endif
 	 4)) {
 		efi_enabled = 1;
-		efi_reserve_early();
+		efi_memblock_x86_reserve_range();
 	}
 #endif
 
@@ -795,7 +809,7 @@ void __init setup_arch(char **cmdline_p)
 	x86_report_nx();
 
 	/* after early param, so could get panic from serial */
-	reserve_early_setup_data();
+	memblock_x86_reserve_range_setup_data();
 
 	if (acpi_mps_check()) {
 #ifdef CONFIG_X86_LOCAL_APIC
@@ -848,8 +862,6 @@ void __init setup_arch(char **cmdline_p)
 	 */
 	max_pfn = e820_end_of_ram_pfn();
 
-	/* preallocate 4k for mptable mpc */
-	early_reserve_e820_mpc_new();
 	/* update e820 for memory not covered by WB MTRRs */
 	mtrr_bp_init();
 	if (mtrr_trim_uncached_memory(max_pfn))
@@ -871,18 +883,8 @@ void __init setup_arch(char **cmdline_p)
 		max_low_pfn = max_pfn;
 
 	high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
-	max_pfn_mapped = KERNEL_IMAGE_SIZE >> PAGE_SHIFT;
-#endif
-
-#ifdef CONFIG_X86_CHECK_BIOS_CORRUPTION
-	setup_bios_corruption_check();
 #endif
 
-	printk(KERN_DEBUG "initial memory mapped : 0 - %08lx\n",
-			max_pfn_mapped<<PAGE_SHIFT);
-
-	reserve_brk();
-
 	/*
 	 * Find and reserve possible boot-time SMP configuration:
 	 */
@@ -890,6 +892,26 @@ void __init setup_arch(char **cmdline_p)
 
 	reserve_ibft_region();
 
+	/*
+	 * Need to conclude brk, before memblock_x86_fill()
+	 *  it could use memblock_find_in_range, could overlap with
+	 *  brk area.
+	 */
+	reserve_brk();
+
+	memblock.current_limit = get_max_mapped();
+	memblock_x86_fill();
+
+	/* preallocate 4k for mptable mpc */
+	early_reserve_e820_mpc_new();
+
+#ifdef CONFIG_X86_CHECK_BIOS_CORRUPTION
+	setup_bios_corruption_check();
+#endif
+
+	printk(KERN_DEBUG "initial memory mapped : 0 - %08lx\n",
+			max_pfn_mapped<<PAGE_SHIFT);
+
 	reserve_trampoline_memory();
 
 #ifdef CONFIG_ACPI_SLEEP
@@ -913,6 +935,7 @@ void __init setup_arch(char **cmdline_p)
 		max_low_pfn = max_pfn;
 	}
 #endif
+	memblock.current_limit = get_max_mapped();
 
 	/*
 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
@@ -951,10 +974,7 @@ void __init setup_arch(char **cmdline_p)
 #endif
 
 	initmem_init(0, max_pfn, acpi, k8);
-#ifndef CONFIG_NO_BOOTMEM
-	early_res_to_bootmem(0, max_low_pfn<<PAGE_SHIFT);
-#endif
-
+	memblock_find_dma_reserve();
 	dma32_reserve_bootmem();
 
 #ifdef CONFIG_KVM_CLOCK
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index 2335c15..002b796 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -131,13 +131,7 @@ static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_t align)
 
 static void __init pcpu_fc_free(void *ptr, size_t size)
 {
-#ifdef CONFIG_NO_BOOTMEM
-	u64 start = __pa(ptr);
-	u64 end = start + size;
-	free_early_partial(start, end);
-#else
 	free_bootmem(__pa(ptr), size);
-#endif
 }
 
 static int __init pcpu_cpu_distance(unsigned int from, unsigned int to)
diff --git a/arch/x86/kernel/trampoline.c b/arch/x86/kernel/trampoline.c
index e2a5952..4c3da56 100644
--- a/arch/x86/kernel/trampoline.c
+++ b/arch/x86/kernel/trampoline.c
@@ -1,8 +1,8 @@
 #include <linux/io.h>
+#include <linux/memblock.h>
 
 #include <asm/trampoline.h>
 #include <asm/pgtable.h>
-#include <asm/e820.h>
 
 #if defined(CONFIG_X86_64) && defined(CONFIG_ACPI_SLEEP)
 #define __trampinit
@@ -17,15 +17,15 @@ unsigned char *__trampinitdata trampoline_base;
 
 void __init reserve_trampoline_memory(void)
 {
-	unsigned long mem;
+	phys_addr_t mem;
 
 	/* Has to be in very low memory so we can execute real-mode AP code. */
-	mem = find_e820_area(0, 1<<20, TRAMPOLINE_SIZE, PAGE_SIZE);
-	if (mem == -1L)
+	mem = memblock_find_in_range(0, 1<<20, TRAMPOLINE_SIZE, PAGE_SIZE);
+	if (mem == MEMBLOCK_ERROR)
 		panic("Cannot allocate trampoline\n");
 
 	trampoline_base = __va(mem);
-	reserve_early(mem, mem + TRAMPOLINE_SIZE, "TRAMPOLINE");
+	memblock_x86_reserve_range(mem, mem + TRAMPOLINE_SIZE, "TRAMPOLINE");
 }
 
 /*
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index a4c7683..5554339 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -26,4 +26,6 @@ obj-$(CONFIG_NUMA)		+= numa.o numa_$(BITS).o
 obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
+obj-$(CONFIG_HAVE_MEMBLOCK)		+= memblock.o
+
 obj-$(CONFIG_MEMTEST)		+= memtest.o
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index b278535..c0e28a1 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -2,6 +2,7 @@
 #include <linux/initrd.h>
 #include <linux/ioport.h>
 #include <linux/swap.h>
+#include <linux/memblock.h>
 
 #include <asm/cacheflush.h>
 #include <asm/e820.h>
@@ -33,6 +34,7 @@ static void __init find_early_table_space(unsigned long end, int use_pse,
 					  int use_gbpages)
 {
 	unsigned long puds, pmds, ptes, tables, start;
+	phys_addr_t base;
 
 	puds = (end + PUD_SIZE - 1) >> PUD_SHIFT;
 	tables = roundup(puds * sizeof(pud_t), PAGE_SIZE);
@@ -75,12 +77,12 @@ static void __init find_early_table_space(unsigned long end, int use_pse,
 #else
 	start = 0x8000;
 #endif
-	e820_table_start = find_e820_area(start, max_pfn_mapped<<PAGE_SHIFT,
+	base = memblock_find_in_range(start, max_pfn_mapped<<PAGE_SHIFT,
 					tables, PAGE_SIZE);
-	if (e820_table_start == -1UL)
+	if (base == MEMBLOCK_ERROR)
 		panic("Cannot find space for the kernel page tables");
 
-	e820_table_start >>= PAGE_SHIFT;
+	e820_table_start = base >> PAGE_SHIFT;
 	e820_table_end = e820_table_start;
 	e820_table_top = e820_table_start + (tables >> PAGE_SHIFT);
 
@@ -299,7 +301,7 @@ unsigned long __init_refok init_memory_mapping(unsigned long start,
 	__flush_tlb_all();
 
 	if (!after_bootmem && e820_table_end > e820_table_start)
-		reserve_early(e820_table_start << PAGE_SHIFT,
+		memblock_x86_reserve_range(e820_table_start << PAGE_SHIFT,
 				 e820_table_end << PAGE_SHIFT, "PGTABLE");
 
 	if (!after_bootmem)
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 558f2d3..5d0a671 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -25,6 +25,7 @@
 #include <linux/pfn.h>
 #include <linux/poison.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/memory_hotplug.h>
 #include <linux/initrd.h>
@@ -422,49 +423,28 @@ static void __init add_one_highpage_init(struct page *page)
 	totalhigh_pages++;
 }
 
-struct add_highpages_data {
-	unsigned long start_pfn;
-	unsigned long end_pfn;
-};
-
-static int __init add_highpages_work_fn(unsigned long start_pfn,
-					 unsigned long end_pfn, void *datax)
+void __init add_highpages_with_active_regions(int nid,
+			 unsigned long start_pfn, unsigned long end_pfn)
 {
-	int node_pfn;
-	struct page *page;
-	unsigned long final_start_pfn, final_end_pfn;
-	struct add_highpages_data *data;
+	struct range *range;
+	int nr_range;
+	int i;
 
-	data = (struct add_highpages_data *)datax;
+	nr_range = __get_free_all_memory_range(&range, nid, start_pfn, end_pfn);
 
-	final_start_pfn = max(start_pfn, data->start_pfn);
-	final_end_pfn = min(end_pfn, data->end_pfn);
-	if (final_start_pfn >= final_end_pfn)
-		return 0;
+	for (i = 0; i < nr_range; i++) {
+		struct page *page;
+		int node_pfn;
 
-	for (node_pfn = final_start_pfn; node_pfn < final_end_pfn;
-	     node_pfn++) {
-		if (!pfn_valid(node_pfn))
-			continue;
-		page = pfn_to_page(node_pfn);
-		add_one_highpage_init(page);
+		for (node_pfn = range[i].start; node_pfn < range[i].end;
+		     node_pfn++) {
+			if (!pfn_valid(node_pfn))
+				continue;
+			page = pfn_to_page(node_pfn);
+			add_one_highpage_init(page);
+		}
 	}
-
-	return 0;
-
 }
-
-void __init add_highpages_with_active_regions(int nid, unsigned long start_pfn,
-					      unsigned long end_pfn)
-{
-	struct add_highpages_data data;
-
-	data.start_pfn = start_pfn;
-	data.end_pfn = end_pfn;
-
-	work_with_active_regions(nid, add_highpages_work_fn, &data);
-}
-
 #else
 static inline void permanent_kmaps_init(pgd_t *pgd_base)
 {
@@ -712,14 +692,14 @@ void __init initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 	highstart_pfn = highend_pfn = max_pfn;
 	if (max_pfn > max_low_pfn)
 		highstart_pfn = max_low_pfn;
-	e820_register_active_regions(0, 0, highend_pfn);
+	memblock_x86_register_active_regions(0, 0, highend_pfn);
 	sparse_memory_present_with_active_regions(0);
 	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
 		pages_to_mb(highend_pfn - highstart_pfn));
 	num_physpages = highend_pfn;
 	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE - 1) + 1;
 #else
-	e820_register_active_regions(0, 0, max_low_pfn);
+	memblock_x86_register_active_regions(0, 0, max_low_pfn);
 	sparse_memory_present_with_active_regions(0);
 	num_physpages = max_low_pfn;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
@@ -750,68 +730,12 @@ static void __init zone_sizes_init(void)
 	free_area_init_nodes(max_zone_pfns);
 }
 
-#ifndef CONFIG_NO_BOOTMEM
-static unsigned long __init setup_node_bootmem(int nodeid,
-				 unsigned long start_pfn,
-				 unsigned long end_pfn,
-				 unsigned long bootmap)
-{
-	unsigned long bootmap_size;
-
-	/* don't touch min_low_pfn */
-	bootmap_size = init_bootmem_node(NODE_DATA(nodeid),
-					 bootmap >> PAGE_SHIFT,
-					 start_pfn, end_pfn);
-	printk(KERN_INFO "  node %d low ram: %08lx - %08lx\n",
-		nodeid, start_pfn<<PAGE_SHIFT, end_pfn<<PAGE_SHIFT);
-	printk(KERN_INFO "  node %d bootmap %08lx - %08lx\n",
-		 nodeid, bootmap, bootmap + bootmap_size);
-	free_bootmem_with_active_regions(nodeid, end_pfn);
-
-	return bootmap + bootmap_size;
-}
-#endif
-
 void __init setup_bootmem_allocator(void)
 {
-#ifndef CONFIG_NO_BOOTMEM
-	int nodeid;
-	unsigned long bootmap_size, bootmap;
-	/*
-	 * Initialize the boot-time allocator (with low memory only):
-	 */
-	bootmap_size = bootmem_bootmap_pages(max_low_pfn)<<PAGE_SHIFT;
-	bootmap = find_e820_area(0, max_pfn_mapped<<PAGE_SHIFT, bootmap_size,
-				 PAGE_SIZE);
-	if (bootmap == -1L)
-		panic("Cannot find bootmem map of size %ld\n", bootmap_size);
-	reserve_early(bootmap, bootmap + bootmap_size, "BOOTMAP");
-#endif
-
 	printk(KERN_INFO "  mapped low ram: 0 - %08lx\n",
 		 max_pfn_mapped<<PAGE_SHIFT);
 	printk(KERN_INFO "  low ram: 0 - %08lx\n", max_low_pfn<<PAGE_SHIFT);
 
-#ifndef CONFIG_NO_BOOTMEM
-	for_each_online_node(nodeid) {
-		 unsigned long start_pfn, end_pfn;
-
-#ifdef CONFIG_NEED_MULTIPLE_NODES
-		start_pfn = node_start_pfn[nodeid];
-		end_pfn = node_end_pfn[nodeid];
-		if (start_pfn > max_low_pfn)
-			continue;
-		if (end_pfn > max_low_pfn)
-			end_pfn = max_low_pfn;
-#else
-		start_pfn = 0;
-		end_pfn = max_low_pfn;
-#endif
-		bootmap = setup_node_bootmem(nodeid, start_pfn, end_pfn,
-						 bootmap);
-	}
-#endif
-
 	after_bootmem = 1;
 }
 
@@ -1070,8 +994,3 @@ void mark_rodata_ro(void)
 }
 #endif
 
-int __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
-				   int flags)
-{
-	return reserve_bootmem(phys, len, flags);
-}
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index c55f900..8434620 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -21,6 +21,7 @@
 #include <linux/initrd.h>
 #include <linux/pagemap.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/pci.h>
 #include <linux/pfn.h>
@@ -52,8 +53,6 @@
 #include <asm/init.h>
 #include <linux/bootmem.h>
 
-static unsigned long dma_reserve __initdata;
-
 static int __init parse_direct_gbpages_off(char *arg)
 {
 	direct_gbpages = 0;
@@ -617,23 +616,7 @@ kernel_physical_mapping_init(unsigned long start,
 void __init initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 				int acpi, int k8)
 {
-#ifndef CONFIG_NO_BOOTMEM
-	unsigned long bootmap_size, bootmap;
-
-	bootmap_size = bootmem_bootmap_pages(end_pfn)<<PAGE_SHIFT;
-	bootmap = find_e820_area(0, end_pfn<<PAGE_SHIFT, bootmap_size,
-				 PAGE_SIZE);
-	if (bootmap == -1L)
-		panic("Cannot find bootmem map of size %ld\n", bootmap_size);
-	reserve_early(bootmap, bootmap + bootmap_size, "BOOTMAP");
-	/* don't touch min_low_pfn */
-	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap >> PAGE_SHIFT,
-					 0, end_pfn);
-	e820_register_active_regions(0, start_pfn, end_pfn);
-	free_bootmem_with_active_regions(0, end_pfn);
-#else
-	e820_register_active_regions(0, start_pfn, end_pfn);
-#endif
+	memblock_x86_register_active_regions(0, start_pfn, end_pfn);
 }
 #endif
 
@@ -843,52 +826,6 @@ void mark_rodata_ro(void)
 
 #endif
 
-int __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
-				   int flags)
-{
-#ifdef CONFIG_NUMA
-	int nid, next_nid;
-	int ret;
-#endif
-	unsigned long pfn = phys >> PAGE_SHIFT;
-
-	if (pfn >= max_pfn) {
-		/*
-		 * This can happen with kdump kernels when accessing
-		 * firmware tables:
-		 */
-		if (pfn < max_pfn_mapped)
-			return -EFAULT;
-
-		printk(KERN_ERR "reserve_bootmem: illegal reserve %lx %lu\n",
-				phys, len);
-		return -EFAULT;
-	}
-
-	/* Should check here against the e820 map to avoid double free */
-#ifdef CONFIG_NUMA
-	nid = phys_to_nid(phys);
-	next_nid = phys_to_nid(phys + len - 1);
-	if (nid == next_nid)
-		ret = reserve_bootmem_node(NODE_DATA(nid), phys, len, flags);
-	else
-		ret = reserve_bootmem(phys, len, flags);
-
-	if (ret != 0)
-		return ret;
-
-#else
-	reserve_bootmem(phys, len, flags);
-#endif
-
-	if (phys+len <= MAX_DMA_PFN*PAGE_SIZE) {
-		dma_reserve += len / PAGE_SIZE;
-		set_dma_reserve(dma_reserve);
-	}
-
-	return 0;
-}
-
 int kern_addr_valid(unsigned long addr)
 {
 	unsigned long above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 3ba6e06..0369843 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -362,6 +362,11 @@ static inline pte_t * __init early_ioremap_pte(unsigned long addr)
 	return &bm_pte[pte_index(addr)];
 }
 
+bool __init is_early_ioremap_ptep(pte_t *ptep)
+{
+	return ptep >= &bm_pte[0] && ptep < &bm_pte[PAGE_SIZE/sizeof(pte_t)];
+}
+
 static unsigned long slot_virt[FIX_BTMAPS_SLOTS] __initdata;
 
 void __init early_ioremap_init(void)
diff --git a/arch/x86/mm/k8topology_64.c b/arch/x86/mm/k8topology_64.c
index 52d54bf..804a3b6 100644
--- a/arch/x86/mm/k8topology_64.c
+++ b/arch/x86/mm/k8topology_64.c
@@ -11,6 +11,8 @@
 #include <linux/string.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/memblock.h>
+
 #include <asm/io.h>
 #include <linux/pci_ids.h>
 #include <linux/acpi.h>
@@ -222,7 +224,7 @@ int __init k8_scan_nodes(void)
 	for_each_node_mask(i, node_possible_map) {
 		int j;
 
-		e820_register_active_regions(i,
+		memblock_x86_register_active_regions(i,
 				nodes[i].start >> PAGE_SHIFT,
 				nodes[i].end >> PAGE_SHIFT);
 		for (j = apicid_base; j < cores + apicid_base; j++)
diff --git a/arch/x86/mm/memblock.c b/arch/x86/mm/memblock.c
new file mode 100644
index 0000000..aa11693
--- /dev/null
+++ b/arch/x86/mm/memblock.c
@@ -0,0 +1,348 @@
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/bitops.h>
+#include <linux/memblock.h>
+#include <linux/bootmem.h>
+#include <linux/mm.h>
+#include <linux/range.h>
+
+/* Check for already reserved areas */
+static bool __init check_with_memblock_reserved_size(u64 *addrp, u64 *sizep, u64 align)
+{
+	struct memblock_region *r;
+	u64 addr = *addrp, last;
+	u64 size = *sizep;
+	bool changed = false;
+
+again:
+	last = addr + size;
+	for_each_memblock(reserved, r) {
+		if (last > r->base && addr < r->base) {
+			size = r->base - addr;
+			changed = true;
+			goto again;
+		}
+		if (last > (r->base + r->size) && addr < (r->base + r->size)) {
+			addr = round_up(r->base + r->size, align);
+			size = last - addr;
+			changed = true;
+			goto again;
+		}
+		if (last <= (r->base + r->size) && addr >= r->base) {
+			*sizep = 0;
+			return false;
+		}
+	}
+	if (changed) {
+		*addrp = addr;
+		*sizep = size;
+	}
+	return changed;
+}
+
+/*
+ * Find next free range after start, and size is returned in *sizep
+ */
+u64 __init memblock_x86_find_in_range_size(u64 start, u64 *sizep, u64 align)
+{
+	struct memblock_region *r;
+
+	for_each_memblock(memory, r) {
+		u64 ei_start = r->base;
+		u64 ei_last = ei_start + r->size;
+		u64 addr;
+
+		addr = round_up(ei_start, align);
+		if (addr < start)
+			addr = round_up(start, align);
+		if (addr >= ei_last)
+			continue;
+		*sizep = ei_last - addr;
+		while (check_with_memblock_reserved_size(&addr, sizep, align))
+			;
+
+		if (*sizep)
+			return addr;
+	}
+
+	return MEMBLOCK_ERROR;
+}
+
+static __init struct range *find_range_array(int count)
+{
+	u64 end, size, mem;
+	struct range *range;
+
+	size = sizeof(struct range) * count;
+	end = memblock.current_limit;
+
+	mem = memblock_find_in_range(0, end, size, sizeof(struct range));
+	if (mem == MEMBLOCK_ERROR)
+		panic("can not find more space for range array");
+
+	/*
+	 * This range is tempoaray, so don't reserve it, it will not be
+	 * overlapped because We will not alloccate new buffer before
+	 * We discard this one
+	 */
+	range = __va(mem);
+	memset(range, 0, size);
+
+	return range;
+}
+
+static void __init memblock_x86_subtract_reserved(struct range *range, int az)
+{
+	u64 final_start, final_end;
+	struct memblock_region *r;
+
+	/* Take out region array itself at first*/
+	memblock_free_reserved_regions();
+
+	memblock_dbg("Subtract (%ld early reservations)\n", memblock.reserved.cnt);
+
+	for_each_memblock(reserved, r) {
+		memblock_dbg("  [%010llx-%010llx]\n", (u64)r->base, (u64)r->base + r->size - 1);
+		final_start = PFN_DOWN(r->base);
+		final_end = PFN_UP(r->base + r->size);
+		if (final_start >= final_end)
+			continue;
+		subtract_range(range, az, final_start, final_end);
+	}
+
+	/* Put region array back ? */
+	memblock_reserve_reserved_regions();
+}
+
+struct count_data {
+	int nr;
+};
+
+static int __init count_work_fn(unsigned long start_pfn,
+				unsigned long end_pfn, void *datax)
+{
+	struct count_data *data = datax;
+
+	data->nr++;
+
+	return 0;
+}
+
+static int __init count_early_node_map(int nodeid)
+{
+	struct count_data data;
+
+	data.nr = 0;
+	work_with_active_regions(nodeid, count_work_fn, &data);
+
+	return data.nr;
+}
+
+int __init __get_free_all_memory_range(struct range **rangep, int nodeid,
+			 unsigned long start_pfn, unsigned long end_pfn)
+{
+	int count;
+	struct range *range;
+	int nr_range;
+
+	count = (memblock.reserved.cnt + count_early_node_map(nodeid)) * 2;
+
+	range = find_range_array(count);
+	nr_range = 0;
+
+	/*
+	 * Use early_node_map[] and memblock.reserved.region to get range array
+	 * at first
+	 */
+	nr_range = add_from_early_node_map(range, count, nr_range, nodeid);
+	subtract_range(range, count, 0, start_pfn);
+	subtract_range(range, count, end_pfn, -1ULL);
+
+	memblock_x86_subtract_reserved(range, count);
+	nr_range = clean_sort_range(range, count);
+
+	*rangep = range;
+	return nr_range;
+}
+
+int __init get_free_all_memory_range(struct range **rangep, int nodeid)
+{
+	unsigned long end_pfn = -1UL;
+
+#ifdef CONFIG_X86_32
+	end_pfn = max_low_pfn;
+#endif
+	return __get_free_all_memory_range(rangep, nodeid, 0, end_pfn);
+}
+
+static u64 __init __memblock_x86_memory_in_range(u64 addr, u64 limit, bool get_free)
+{
+	int i, count;
+	struct range *range;
+	int nr_range;
+	u64 final_start, final_end;
+	u64 free_size;
+	struct memblock_region *r;
+
+	count = (memblock.reserved.cnt + memblock.memory.cnt) * 2;
+
+	range = find_range_array(count);
+	nr_range = 0;
+
+	addr = PFN_UP(addr);
+	limit = PFN_DOWN(limit);
+
+	for_each_memblock(memory, r) {
+		final_start = PFN_UP(r->base);
+		final_end = PFN_DOWN(r->base + r->size);
+		if (final_start >= final_end)
+			continue;
+		if (final_start >= limit || final_end <= addr)
+			continue;
+
+		nr_range = add_range(range, count, nr_range, final_start, final_end);
+	}
+	subtract_range(range, count, 0, addr);
+	subtract_range(range, count, limit, -1ULL);
+
+	/* Subtract memblock.reserved.region in range ? */
+	if (!get_free)
+		goto sort_and_count_them;
+	for_each_memblock(reserved, r) {
+		final_start = PFN_DOWN(r->base);
+		final_end = PFN_UP(r->base + r->size);
+		if (final_start >= final_end)
+			continue;
+		if (final_start >= limit || final_end <= addr)
+			continue;
+
+		subtract_range(range, count, final_start, final_end);
+	}
+
+sort_and_count_them:
+	nr_range = clean_sort_range(range, count);
+
+	free_size = 0;
+	for (i = 0; i < nr_range; i++)
+		free_size += range[i].end - range[i].start;
+
+	return free_size << PAGE_SHIFT;
+}
+
+u64 __init memblock_x86_free_memory_in_range(u64 addr, u64 limit)
+{
+	return __memblock_x86_memory_in_range(addr, limit, true);
+}
+
+u64 __init memblock_x86_memory_in_range(u64 addr, u64 limit)
+{
+	return __memblock_x86_memory_in_range(addr, limit, false);
+}
+
+void __init memblock_x86_reserve_range(u64 start, u64 end, char *name)
+{
+	if (start == end)
+		return;
+
+	if (WARN_ONCE(start > end, "memblock_x86_reserve_range: wrong range [%#llx, %#llx)\n", start, end))
+		return;
+
+	memblock_dbg("    memblock_x86_reserve_range: [%#010llx-%#010llx] %16s\n", start, end - 1, name);
+
+	memblock_reserve(start, end - start);
+}
+
+void __init memblock_x86_free_range(u64 start, u64 end)
+{
+	if (start == end)
+		return;
+
+	if (WARN_ONCE(start > end, "memblock_x86_free_range: wrong range [%#llx, %#llx)\n", start, end))
+		return;
+
+	memblock_dbg("       memblock_x86_free_range: [%#010llx-%#010llx]\n", start, end - 1);
+
+	memblock_free(start, end - start);
+}
+
+/*
+ * Need to call this function after memblock_x86_register_active_regions,
+ * so early_node_map[] is filled already.
+ */
+u64 __init memblock_x86_find_in_range_node(int nid, u64 start, u64 end, u64 size, u64 align)
+{
+	u64 addr;
+	addr = find_memory_core_early(nid, size, align, start, end);
+	if (addr != MEMBLOCK_ERROR)
+		return addr;
+
+	/* Fallback, should already have start end within node range */
+	return memblock_find_in_range(start, end, size, align);
+}
+
+/*
+ * Finds an active region in the address range from start_pfn to last_pfn and
+ * returns its range in ei_startpfn and ei_endpfn for the memblock entry.
+ */
+static int __init memblock_x86_find_active_region(const struct memblock_region *ei,
+				  unsigned long start_pfn,
+				  unsigned long last_pfn,
+				  unsigned long *ei_startpfn,
+				  unsigned long *ei_endpfn)
+{
+	u64 align = PAGE_SIZE;
+
+	*ei_startpfn = round_up(ei->base, align) >> PAGE_SHIFT;
+	*ei_endpfn = round_down(ei->base + ei->size, align) >> PAGE_SHIFT;
+
+	/* Skip map entries smaller than a page */
+	if (*ei_startpfn >= *ei_endpfn)
+		return 0;
+
+	/* Skip if map is outside the node */
+	if (*ei_endpfn <= start_pfn || *ei_startpfn >= last_pfn)
+		return 0;
+
+	/* Check for overlaps */
+	if (*ei_startpfn < start_pfn)
+		*ei_startpfn = start_pfn;
+	if (*ei_endpfn > last_pfn)
+		*ei_endpfn = last_pfn;
+
+	return 1;
+}
+
+/* Walk the memblock.memory map and register active regions within a node */
+void __init memblock_x86_register_active_regions(int nid, unsigned long start_pfn,
+					 unsigned long last_pfn)
+{
+	unsigned long ei_startpfn;
+	unsigned long ei_endpfn;
+	struct memblock_region *r;
+
+	for_each_memblock(memory, r)
+		if (memblock_x86_find_active_region(r, start_pfn, last_pfn,
+					   &ei_startpfn, &ei_endpfn))
+			add_active_range(nid, ei_startpfn, ei_endpfn);
+}
+
+/*
+ * Find the hole size (in bytes) in the memory range.
+ * @start: starting address of the memory range to scan
+ * @end: ending address of the memory range to scan
+ */
+u64 __init memblock_x86_hole_size(u64 start, u64 end)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long last_pfn = end >> PAGE_SHIFT;
+	unsigned long ei_startpfn, ei_endpfn, ram = 0;
+	struct memblock_region *r;
+
+	for_each_memblock(memory, r)
+		if (memblock_x86_find_active_region(r, start_pfn, last_pfn,
+					   &ei_startpfn, &ei_endpfn))
+			ram += ei_endpfn - ei_startpfn;
+
+	return end - start - ((u64)ram << PAGE_SHIFT);
+}
diff --git a/arch/x86/mm/memtest.c b/arch/x86/mm/memtest.c
index 18d244f..92faf3a 100644
--- a/arch/x86/mm/memtest.c
+++ b/arch/x86/mm/memtest.c
@@ -6,8 +6,7 @@
 #include <linux/smp.h>
 #include <linux/init.h>
 #include <linux/pfn.h>
-
-#include <asm/e820.h>
+#include <linux/memblock.h>
 
 static u64 patterns[] __initdata = {
 	0,
@@ -35,7 +34,7 @@ static void __init reserve_bad_mem(u64 pattern, u64 start_bad, u64 end_bad)
 	       (unsigned long long) pattern,
 	       (unsigned long long) start_bad,
 	       (unsigned long long) end_bad);
-	reserve_early(start_bad, end_bad, "BAD RAM");
+	memblock_x86_reserve_range(start_bad, end_bad, "BAD RAM");
 }
 
 static void __init memtest(u64 pattern, u64 start_phys, u64 size)
@@ -74,7 +73,7 @@ static void __init do_one_pass(u64 pattern, u64 start, u64 end)
 	u64 size = 0;
 
 	while (start < end) {
-		start = find_e820_area_size(start, &size, 1);
+		start = memblock_x86_find_in_range_size(start, &size, 1);
 
 		/* done ? */
 		if (start >= end)
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
index 809baaa..84a3e4c 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -24,6 +24,7 @@
 
 #include <linux/mm.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/highmem.h>
 #include <linux/initrd.h>
@@ -120,7 +121,7 @@ int __init get_memcfg_numa_flat(void)
 
 	node_start_pfn[0] = 0;
 	node_end_pfn[0] = max_pfn;
-	e820_register_active_regions(0, 0, max_pfn);
+	memblock_x86_register_active_regions(0, 0, max_pfn);
 	memory_present(0, 0, max_pfn);
 	node_remap_size[0] = node_memmap_size_bytes(0, 0, max_pfn);
 
@@ -161,14 +162,14 @@ static void __init allocate_pgdat(int nid)
 		NODE_DATA(nid) = (pg_data_t *)node_remap_start_vaddr[nid];
 	else {
 		unsigned long pgdat_phys;
-		pgdat_phys = find_e820_area(min_low_pfn<<PAGE_SHIFT,
+		pgdat_phys = memblock_find_in_range(min_low_pfn<<PAGE_SHIFT,
 				 max_pfn_mapped<<PAGE_SHIFT,
 				 sizeof(pg_data_t),
 				 PAGE_SIZE);
 		NODE_DATA(nid) = (pg_data_t *)(pfn_to_kaddr(pgdat_phys>>PAGE_SHIFT));
 		memset(buf, 0, sizeof(buf));
 		sprintf(buf, "NODE_DATA %d",  nid);
-		reserve_early(pgdat_phys, pgdat_phys + sizeof(pg_data_t), buf);
+		memblock_x86_reserve_range(pgdat_phys, pgdat_phys + sizeof(pg_data_t), buf);
 	}
 	printk(KERN_DEBUG "allocate_pgdat: node %d NODE_DATA %08lx\n",
 		nid, (unsigned long)NODE_DATA(nid));
@@ -291,15 +292,15 @@ static __init unsigned long calculate_numa_remap_pages(void)
 						 PTRS_PER_PTE);
 		node_kva_target <<= PAGE_SHIFT;
 		do {
-			node_kva_final = find_e820_area(node_kva_target,
+			node_kva_final = memblock_find_in_range(node_kva_target,
 					((u64)node_end_pfn[nid])<<PAGE_SHIFT,
 						((u64)size)<<PAGE_SHIFT,
 						LARGE_PAGE_BYTES);
 			node_kva_target -= LARGE_PAGE_BYTES;
-		} while (node_kva_final == -1ULL &&
+		} while (node_kva_final == MEMBLOCK_ERROR &&
 			 (node_kva_target>>PAGE_SHIFT) > (node_start_pfn[nid]));
 
-		if (node_kva_final == -1ULL)
+		if (node_kva_final == MEMBLOCK_ERROR)
 			panic("Can not get kva ram\n");
 
 		node_remap_size[nid] = size;
@@ -318,15 +319,13 @@ static __init unsigned long calculate_numa_remap_pages(void)
 		 *  but we could have some hole in high memory, and it will only
 		 *  check page_is_ram(pfn) && !page_is_reserved_early(pfn) to decide
 		 *  to use it as free.
-		 *  So reserve_early here, hope we don't run out of that array
+		 *  So memblock_x86_reserve_range here, hope we don't run out of that array
 		 */
-		reserve_early(node_kva_final,
+		memblock_x86_reserve_range(node_kva_final,
 			      node_kva_final+(((u64)size)<<PAGE_SHIFT),
 			      "KVA RAM");
 
 		node_remap_start_pfn[nid] = node_kva_final>>PAGE_SHIFT;
-		remove_active_range(nid, node_remap_start_pfn[nid],
-					 node_remap_start_pfn[nid] + size);
 	}
 	printk(KERN_INFO "Reserving total of %lx pages for numa KVA remap\n",
 			reserve_pages);
@@ -367,14 +366,14 @@ void __init initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 
 	kva_target_pfn = round_down(max_low_pfn - kva_pages, PTRS_PER_PTE);
 	do {
-		kva_start_pfn = find_e820_area(kva_target_pfn<<PAGE_SHIFT,
+		kva_start_pfn = memblock_find_in_range(kva_target_pfn<<PAGE_SHIFT,
 					max_low_pfn<<PAGE_SHIFT,
 					kva_pages<<PAGE_SHIFT,
 					PTRS_PER_PTE<<PAGE_SHIFT) >> PAGE_SHIFT;
 		kva_target_pfn -= PTRS_PER_PTE;
-	} while (kva_start_pfn == -1UL && kva_target_pfn > min_low_pfn);
+	} while (kva_start_pfn == MEMBLOCK_ERROR && kva_target_pfn > min_low_pfn);
 
-	if (kva_start_pfn == -1UL)
+	if (kva_start_pfn == MEMBLOCK_ERROR)
 		panic("Can not get kva space\n");
 
 	printk(KERN_INFO "kva_start_pfn ~ %lx max_low_pfn ~ %lx\n",
@@ -382,7 +381,7 @@ void __init initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 	printk(KERN_INFO "max_pfn = %lx\n", max_pfn);
 
 	/* avoid clash with initrd */
-	reserve_early(kva_start_pfn<<PAGE_SHIFT,
+	memblock_x86_reserve_range(kva_start_pfn<<PAGE_SHIFT,
 		      (kva_start_pfn + kva_pages)<<PAGE_SHIFT,
 		     "KVA PG");
 #ifdef CONFIG_HIGHMEM
@@ -419,9 +418,6 @@ void __init initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 	for_each_online_node(nid) {
 		memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
 		NODE_DATA(nid)->node_id = nid;
-#ifndef CONFIG_NO_BOOTMEM
-		NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
-#endif
 	}
 
 	setup_bootmem_allocator();
diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
index 4962f1a..60f4985 100644
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -7,6 +7,7 @@
 #include <linux/string.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/ctype.h>
 #include <linux/module.h>
@@ -86,16 +87,16 @@ static int __init allocate_cachealigned_memnodemap(void)
 
 	addr = 0x8000;
 	nodemap_size = roundup(sizeof(s16) * memnodemapsize, L1_CACHE_BYTES);
-	nodemap_addr = find_e820_area(addr, max_pfn<<PAGE_SHIFT,
+	nodemap_addr = memblock_find_in_range(addr, max_pfn<<PAGE_SHIFT,
 				      nodemap_size, L1_CACHE_BYTES);
-	if (nodemap_addr == -1UL) {
+	if (nodemap_addr == MEMBLOCK_ERROR) {
 		printk(KERN_ERR
 		       "NUMA: Unable to allocate Memory to Node hash map\n");
 		nodemap_addr = nodemap_size = 0;
 		return -1;
 	}
 	memnodemap = phys_to_virt(nodemap_addr);
-	reserve_early(nodemap_addr, nodemap_addr + nodemap_size, "MEMNODEMAP");
+	memblock_x86_reserve_range(nodemap_addr, nodemap_addr + nodemap_size, "MEMNODEMAP");
 
 	printk(KERN_DEBUG "NUMA: Allocated memnodemap from %lx - %lx\n",
 	       nodemap_addr, nodemap_addr + nodemap_size);
@@ -171,8 +172,8 @@ static void * __init early_node_mem(int nodeid, unsigned long start,
 	if (start < (MAX_DMA32_PFN<<PAGE_SHIFT) &&
 	    end > (MAX_DMA32_PFN<<PAGE_SHIFT))
 		start = MAX_DMA32_PFN<<PAGE_SHIFT;
-	mem = find_e820_area(start, end, size, align);
-	if (mem != -1L)
+	mem = memblock_x86_find_in_range_node(nodeid, start, end, size, align);
+	if (mem != MEMBLOCK_ERROR)
 		return __va(mem);
 
 	/* extend the search scope */
@@ -181,8 +182,8 @@ static void * __init early_node_mem(int nodeid, unsigned long start,
 		start = MAX_DMA32_PFN<<PAGE_SHIFT;
 	else
 		start = MAX_DMA_PFN<<PAGE_SHIFT;
-	mem = find_e820_area(start, end, size, align);
-	if (mem != -1L)
+	mem = memblock_x86_find_in_range_node(nodeid, start, end, size, align);
+	if (mem != MEMBLOCK_ERROR)
 		return __va(mem);
 
 	printk(KERN_ERR "Cannot find %lu bytes in node %d\n",
@@ -198,10 +199,6 @@ setup_node_bootmem(int nodeid, unsigned long start, unsigned long end)
 	unsigned long start_pfn, last_pfn, nodedata_phys;
 	const int pgdat_size = roundup(sizeof(pg_data_t), PAGE_SIZE);
 	int nid;
-#ifndef CONFIG_NO_BOOTMEM
-	unsigned long bootmap_start, bootmap_pages, bootmap_size;
-	void *bootmap;
-#endif
 
 	if (!end)
 		return;
@@ -226,7 +223,7 @@ setup_node_bootmem(int nodeid, unsigned long start, unsigned long end)
 	if (node_data[nodeid] == NULL)
 		return;
 	nodedata_phys = __pa(node_data[nodeid]);
-	reserve_early(nodedata_phys, nodedata_phys + pgdat_size, "NODE_DATA");
+	memblock_x86_reserve_range(nodedata_phys, nodedata_phys + pgdat_size, "NODE_DATA");
 	printk(KERN_INFO "  NODE_DATA [%016lx - %016lx]\n", nodedata_phys,
 		nodedata_phys + pgdat_size - 1);
 	nid = phys_to_nid(nodedata_phys);
@@ -238,47 +235,6 @@ setup_node_bootmem(int nodeid, unsigned long start, unsigned long end)
 	NODE_DATA(nodeid)->node_start_pfn = start_pfn;
 	NODE_DATA(nodeid)->node_spanned_pages = last_pfn - start_pfn;
 
-#ifndef CONFIG_NO_BOOTMEM
-	NODE_DATA(nodeid)->bdata = &bootmem_node_data[nodeid];
-
-	/*
-	 * Find a place for the bootmem map
-	 * nodedata_phys could be on other nodes by alloc_bootmem,
-	 * so need to sure bootmap_start not to be small, otherwise
-	 * early_node_mem will get that with find_e820_area instead
-	 * of alloc_bootmem, that could clash with reserved range
-	 */
-	bootmap_pages = bootmem_bootmap_pages(last_pfn - start_pfn);
-	bootmap_start = roundup(nodedata_phys + pgdat_size, PAGE_SIZE);
-	/*
-	 * SMP_CACHE_BYTES could be enough, but init_bootmem_node like
-	 * to use that to align to PAGE_SIZE
-	 */
-	bootmap = early_node_mem(nodeid, bootmap_start, end,
-				 bootmap_pages<<PAGE_SHIFT, PAGE_SIZE);
-	if (bootmap == NULL)  {
-		free_early(nodedata_phys, nodedata_phys + pgdat_size);
-		node_data[nodeid] = NULL;
-		return;
-	}
-	bootmap_start = __pa(bootmap);
-	reserve_early(bootmap_start, bootmap_start+(bootmap_pages<<PAGE_SHIFT),
-			"BOOTMAP");
-
-	bootmap_size = init_bootmem_node(NODE_DATA(nodeid),
-					 bootmap_start >> PAGE_SHIFT,
-					 start_pfn, last_pfn);
-
-	printk(KERN_INFO "  bootmap [%016lx -  %016lx] pages %lx\n",
-		 bootmap_start, bootmap_start + bootmap_size - 1,
-		 bootmap_pages);
-	nid = phys_to_nid(bootmap_start);
-	if (nid != nodeid)
-		printk(KERN_INFO "    bootmap(%d) on node %d\n", nodeid, nid);
-
-	free_bootmem_with_active_regions(nodeid, end);
-#endif
-
 	node_set_online(nodeid);
 }
 
@@ -416,7 +372,7 @@ static int __init split_nodes_interleave(u64 addr, u64 max_addr,
 		nr_nodes = MAX_NUMNODES;
 	}
 
-	size = (max_addr - addr - e820_hole_size(addr, max_addr)) / nr_nodes;
+	size = (max_addr - addr - memblock_x86_hole_size(addr, max_addr)) / nr_nodes;
 	/*
 	 * Calculate the number of big nodes that can be allocated as a result
 	 * of consolidating the remainder.
@@ -452,7 +408,7 @@ static int __init split_nodes_interleave(u64 addr, u64 max_addr,
 			 * non-reserved memory is less than the per-node size.
 			 */
 			while (end - physnodes[i].start -
-				e820_hole_size(physnodes[i].start, end) < size) {
+				memblock_x86_hole_size(physnodes[i].start, end) < size) {
 				end += FAKE_NODE_MIN_SIZE;
 				if (end > physnodes[i].end) {
 					end = physnodes[i].end;
@@ -466,7 +422,7 @@ static int __init split_nodes_interleave(u64 addr, u64 max_addr,
 			 * this one must extend to the boundary.
 			 */
 			if (end < dma32_end && dma32_end - end -
-			    e820_hole_size(end, dma32_end) < FAKE_NODE_MIN_SIZE)
+			    memblock_x86_hole_size(end, dma32_end) < FAKE_NODE_MIN_SIZE)
 				end = dma32_end;
 
 			/*
@@ -475,7 +431,7 @@ static int __init split_nodes_interleave(u64 addr, u64 max_addr,
 			 * physical node.
 			 */
 			if (physnodes[i].end - end -
-			    e820_hole_size(end, physnodes[i].end) < size)
+			    memblock_x86_hole_size(end, physnodes[i].end) < size)
 				end = physnodes[i].end;
 
 			/*
@@ -503,7 +459,7 @@ static u64 __init find_end_of_node(u64 start, u64 max_addr, u64 size)
 {
 	u64 end = start + size;
 
-	while (end - start - e820_hole_size(start, end) < size) {
+	while (end - start - memblock_x86_hole_size(start, end) < size) {
 		end += FAKE_NODE_MIN_SIZE;
 		if (end > max_addr) {
 			end = max_addr;
@@ -532,7 +488,7 @@ static int __init split_nodes_size_interleave(u64 addr, u64 max_addr, u64 size)
 	 * creates a uniform distribution of node sizes across the entire
 	 * machine (but not necessarily over physical nodes).
 	 */
-	min_size = (max_addr - addr - e820_hole_size(addr, max_addr)) /
+	min_size = (max_addr - addr - memblock_x86_hole_size(addr, max_addr)) /
 						MAX_NUMNODES;
 	min_size = max(min_size, FAKE_NODE_MIN_SIZE);
 	if ((min_size & FAKE_NODE_MIN_HASH_MASK) < min_size)
@@ -565,7 +521,7 @@ static int __init split_nodes_size_interleave(u64 addr, u64 max_addr, u64 size)
 			 * this one must extend to the boundary.
 			 */
 			if (end < dma32_end && dma32_end - end -
-			    e820_hole_size(end, dma32_end) < FAKE_NODE_MIN_SIZE)
+			    memblock_x86_hole_size(end, dma32_end) < FAKE_NODE_MIN_SIZE)
 				end = dma32_end;
 
 			/*
@@ -574,7 +530,7 @@ static int __init split_nodes_size_interleave(u64 addr, u64 max_addr, u64 size)
 			 * physical node.
 			 */
 			if (physnodes[i].end - end -
-			    e820_hole_size(end, physnodes[i].end) < size)
+			    memblock_x86_hole_size(end, physnodes[i].end) < size)
 				end = physnodes[i].end;
 
 			/*
@@ -638,7 +594,7 @@ static int __init numa_emulation(unsigned long start_pfn,
 	 */
 	remove_all_active_ranges();
 	for_each_node_mask(i, node_possible_map) {
-		e820_register_active_regions(i, nodes[i].start >> PAGE_SHIFT,
+		memblock_x86_register_active_regions(i, nodes[i].start >> PAGE_SHIFT,
 						nodes[i].end >> PAGE_SHIFT);
 		setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 	}
@@ -691,7 +647,7 @@ void __init initmem_init(unsigned long start_pfn, unsigned long last_pfn,
 	node_set(0, node_possible_map);
 	for (i = 0; i < nr_cpu_ids; i++)
 		numa_set_node(i, 0);
-	e820_register_active_regions(0, start_pfn, last_pfn);
+	memblock_x86_register_active_regions(0, start_pfn, last_pfn);
 	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn << PAGE_SHIFT);
 }
 
@@ -703,9 +659,7 @@ unsigned long __init numa_free_all_bootmem(void)
 	for_each_online_node(i)
 		pages += free_all_bootmem_node(NODE_DATA(i));
 
-#ifdef CONFIG_NO_BOOTMEM
 	pages += free_all_memory_core_early(MAX_NUMNODES);
-#endif
 
 	return pages;
 }
diff --git a/arch/x86/mm/srat_32.c b/arch/x86/mm/srat_32.c
index 9324f13..a17dffd 100644
--- a/arch/x86/mm/srat_32.c
+++ b/arch/x86/mm/srat_32.c
@@ -25,6 +25,7 @@
  */
 #include <linux/mm.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/acpi.h>
 #include <linux/nodemask.h>
@@ -264,7 +265,7 @@ int __init get_memcfg_from_srat(void)
 		if (node_read_chunk(chunk->nid, chunk))
 			continue;
 
-		e820_register_active_regions(chunk->nid, chunk->start_pfn,
+		memblock_x86_register_active_regions(chunk->nid, chunk->start_pfn,
 					     min(chunk->end_pfn, max_pfn));
 	}
 	/* for out of order entries in SRAT */
diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c
index 9c0d0d3..a35cb9d 100644
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>
 #include <linux/topology.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <asm/proto.h>
 #include <asm/numa.h>
@@ -98,15 +99,15 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 	unsigned long phys;
 
 	length = slit->header.length;
-	phys = find_e820_area(0, max_pfn_mapped<<PAGE_SHIFT, length,
+	phys = memblock_find_in_range(0, max_pfn_mapped<<PAGE_SHIFT, length,
 		 PAGE_SIZE);
 
-	if (phys == -1L)
+	if (phys == MEMBLOCK_ERROR)
 		panic(" Can not save slit!\n");
 
 	acpi_slit = __va(phys);
 	memcpy(acpi_slit, slit, length);
-	reserve_early(phys, phys + length, "ACPI SLIT");
+	memblock_x86_reserve_range(phys, phys + length, "ACPI SLIT");
 }
 
 /* Callback for Proximity Domain -> x2APIC mapping */
@@ -324,7 +325,7 @@ static int __init nodes_cover_memory(const struct bootnode *nodes)
 			pxmram = 0;
 	}
 
-	e820ram = max_pfn - (e820_hole_size(0, max_pfn<<PAGE_SHIFT)>>PAGE_SHIFT);
+	e820ram = max_pfn - (memblock_x86_hole_size(0, max_pfn<<PAGE_SHIFT)>>PAGE_SHIFT);
 	/* We seem to lose 3 pages somewhere. Allow 1M of slack. */
 	if ((long)(e820ram - pxmram) >= (1<<(20 - PAGE_SHIFT))) {
 		printk(KERN_ERR
@@ -421,7 +422,7 @@ int __init acpi_scan_nodes(unsigned long start, unsigned long end)
 	}
 
 	for (i = 0; i < num_node_memblks; i++)
-		e820_register_active_regions(memblk_nodeid[i],
+		memblock_x86_register_active_regions(memblk_nodeid[i],
 				node_memblk_range[i].start >> PAGE_SHIFT,
 				node_memblk_range[i].end >> PAGE_SHIFT);
 
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 7d46c84..63b83ce 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -30,6 +30,7 @@
 #include <linux/console.h>
 #include <linux/pci.h>
 #include <linux/gfp.h>
+#include <linux/memblock.h>
 
 #include <xen/xen.h>
 #include <xen/interface/xen.h>
@@ -1183,6 +1184,8 @@ asmlinkage void __init xen_start_kernel(void)
 	local_irq_disable();
 	early_boot_irqs_off();
 
+	memblock_init();
+
 	xen_raw_console_write("mapping kernel into physical memory\n");
 	pgd = xen_setup_kernel_pagetable(pgd, xen_start_info->nr_pages);
 
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index b2363fc..f72d18c 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -45,6 +45,7 @@
 #include <linux/vmalloc.h>
 #include <linux/module.h>
 #include <linux/gfp.h>
+#include <linux/memblock.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -55,6 +56,7 @@
 #include <asm/e820.h>
 #include <asm/linkage.h>
 #include <asm/page.h>
+#include <asm/init.h>
 
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>
@@ -359,7 +361,8 @@ void make_lowmem_page_readonly(void *vaddr)
 	unsigned int level;
 
 	pte = lookup_address(address, &level);
-	BUG_ON(pte == NULL);
+	if (pte == NULL)
+		return;		/* vaddr missing */
 
 	ptev = pte_wrprotect(*pte);
 
@@ -374,7 +377,8 @@ void make_lowmem_page_readwrite(void *vaddr)
 	unsigned int level;
 
 	pte = lookup_address(address, &level);
-	BUG_ON(pte == NULL);
+	if (pte == NULL)
+		return;		/* vaddr missing */
 
 	ptev = pte_mkwrite(*pte);
 
@@ -1508,13 +1512,25 @@ static void xen_pgd_free(struct mm_struct *mm, pgd_t *pgd)
 #endif
 }
 
-#ifdef CONFIG_X86_32
 static __init pte_t mask_rw_pte(pte_t *ptep, pte_t pte)
 {
+	unsigned long pfn = pte_pfn(pte);
+
+#ifdef CONFIG_X86_32
 	/* If there's an existing pte, then don't allow _PAGE_RW to be set */
 	if (pte_val_ma(*ptep) & _PAGE_PRESENT)
 		pte = __pte_ma(((pte_val_ma(*ptep) & _PAGE_RW) | ~_PAGE_RW) &
 			       pte_val_ma(pte));
+#endif
+
+	/*
+	 * If the new pfn is within the range of the newly allocated
+	 * kernel pagetable, and it isn't being mapped into an
+	 * early_ioremap fixmap slot, make sure it is RO.
+	 */
+	if (!is_early_ioremap_ptep(ptep) &&
+	    pfn >= e820_table_start && pfn < e820_table_end)
+		pte = pte_wrprotect(pte);
 
 	return pte;
 }
@@ -1527,7 +1543,6 @@ static __init void xen_set_pte_init(pte_t *ptep, pte_t pte)
 
 	xen_set_pte(ptep, pte);
 }
-#endif
 
 static void pin_pagetable_pfn(unsigned cmd, unsigned long pfn)
 {
@@ -1814,7 +1829,7 @@ __init pgd_t *xen_setup_kernel_pagetable(pgd_t *pgd,
 	__xen_write_cr3(true, __pa(pgd));
 	xen_mc_issue(PARAVIRT_LAZY_CPU);
 
-	reserve_early(__pa(xen_start_info->pt_base),
+	memblock_x86_reserve_range(__pa(xen_start_info->pt_base),
 		      __pa(xen_start_info->pt_base +
 			   xen_start_info->nr_pt_frames * PAGE_SIZE),
 		      "XEN PAGETABLES");
@@ -1852,7 +1867,7 @@ __init pgd_t *xen_setup_kernel_pagetable(pgd_t *pgd,
 
 	pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(__pa(swapper_pg_dir)));
 
-	reserve_early(__pa(xen_start_info->pt_base),
+	memblock_x86_reserve_range(__pa(xen_start_info->pt_base),
 		      __pa(xen_start_info->pt_base +
 			   xen_start_info->nr_pt_frames * PAGE_SIZE),
 		      "XEN PAGETABLES");
@@ -1971,11 +1986,7 @@ static const struct pv_mmu_ops xen_mmu_ops __initdata = {
 	.alloc_pmd = xen_alloc_pmd_init,
 	.release_pmd = xen_release_pmd_init,
 
-#ifdef CONFIG_X86_64
-	.set_pte = xen_set_pte,
-#else
 	.set_pte = xen_set_pte_init,
-#endif
 	.set_pte_at = xen_set_pte_at,
 	.set_pmd = xen_set_pmd_hyper,
 
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 328b003..9729c90 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -8,6 +8,7 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/pm.h>
+#include <linux/memblock.h>
 
 #include <asm/elf.h>
 #include <asm/vdso.h>
@@ -129,7 +130,7 @@ char * __init xen_memory_setup(void)
 	 *  - xen_start_info
 	 * See comment above "struct start_info" in <xen/interface/xen.h>
 	 */
-	reserve_early(__pa(xen_start_info->mfn_list),
+	memblock_x86_reserve_range(__pa(xen_start_info->mfn_list),
 		      __pa(xen_start_info->pt_base),
 			"XEN START INFO");
 
diff --git a/drivers/video/omap2/vram.c b/drivers/video/omap2/vram.c
index f6fdc20..fed2a72 100644
--- a/drivers/video/omap2/vram.c
+++ b/drivers/video/omap2/vram.c
@@ -554,12 +554,8 @@ void __init omap_vram_reserve_sdram_memblock(void)
 	size = PAGE_ALIGN(size);
 
 	if (paddr) {
-		struct memblock_property res;
-
-		res.base = paddr;
-		res.size = size;
-		if ((paddr & ~PAGE_MASK) || memblock_find(&res) ||
-		    res.base != paddr || res.size != size) {
+		if ((paddr & ~PAGE_MASK) ||
+		    !memblock_is_region_memory(paddr, size)) {
 			pr_err("Illegal SDRAM region for VRAM\n");
 			return;
 		}
diff --git a/include/linux/early_res.h b/include/linux/early_res.h
deleted file mode 100644
index 29c09f5..0000000
--- a/include/linux/early_res.h
+++ /dev/null
@@ -1,23 +0,0 @@
-#ifndef _LINUX_EARLY_RES_H
-#define _LINUX_EARLY_RES_H
-#ifdef __KERNEL__
-
-extern void reserve_early(u64 start, u64 end, char *name);
-extern void reserve_early_overlap_ok(u64 start, u64 end, char *name);
-extern void free_early(u64 start, u64 end);
-void free_early_partial(u64 start, u64 end);
-extern void early_res_to_bootmem(u64 start, u64 end);
-
-void reserve_early_without_check(u64 start, u64 end, char *name);
-u64 find_early_area(u64 ei_start, u64 ei_last, u64 start, u64 end,
-			 u64 size, u64 align);
-u64 find_early_area_size(u64 ei_start, u64 ei_last, u64 start,
-			 u64 *sizep, u64 align);
-u64 find_fw_memmap_area(u64 start, u64 end, u64 size, u64 align);
-u64 get_max_mapped(void);
-#include <linux/range.h>
-int get_free_all_memory_range(struct range **rangep, int nodeid);
-
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_EARLY_RES_H */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index a59faf2..62a10c2 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -2,6 +2,7 @@
 #define _LINUX_MEMBLOCK_H
 #ifdef __KERNEL__
 
+#ifdef CONFIG_HAVE_MEMBLOCK
 /*
  * Logical memory blocks.
  *
@@ -16,73 +17,150 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 
-#define MAX_MEMBLOCK_REGIONS 128
+#include <asm/memblock.h>
 
-struct memblock_property {
-	u64 base;
-	u64 size;
-};
+#define INIT_MEMBLOCK_REGIONS	128
+#define MEMBLOCK_ERROR		0
 
 struct memblock_region {
-	unsigned long cnt;
-	u64 size;
-	struct memblock_property region[MAX_MEMBLOCK_REGIONS+1];
+	phys_addr_t base;
+	phys_addr_t size;
+};
+
+struct memblock_type {
+	unsigned long cnt;	/* number of regions */
+	unsigned long max;	/* size of the allocated array */
+	struct memblock_region *regions;
 };
 
 struct memblock {
-	unsigned long debug;
-	u64 rmo_size;
-	struct memblock_region memory;
-	struct memblock_region reserved;
+	phys_addr_t current_limit;
+	phys_addr_t memory_size;	/* Updated by memblock_analyze() */
+	struct memblock_type memory;
+	struct memblock_type reserved;
 };
 
 extern struct memblock memblock;
+extern int memblock_debug;
+extern int memblock_can_resize;
 
-extern void __init memblock_init(void);
-extern void __init memblock_analyze(void);
-extern long memblock_add(u64 base, u64 size);
-extern long memblock_remove(u64 base, u64 size);
-extern long __init memblock_free(u64 base, u64 size);
-extern long __init memblock_reserve(u64 base, u64 size);
-extern u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
-				u64 (*nid_range)(u64, u64, int *));
-extern u64 __init memblock_alloc(u64 size, u64 align);
-extern u64 __init memblock_alloc_base(u64 size,
-		u64, u64 max_addr);
-extern u64 __init __memblock_alloc_base(u64 size,
-		u64 align, u64 max_addr);
-extern u64 __init memblock_phys_mem_size(void);
-extern u64 memblock_end_of_DRAM(void);
-extern void __init memblock_enforce_memory_limit(u64 memory_limit);
-extern int __init memblock_is_reserved(u64 addr);
-extern int memblock_is_region_reserved(u64 base, u64 size);
-extern int memblock_find(struct memblock_property *res);
+#define memblock_dbg(fmt, ...) \
+	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
+
+u64 memblock_find_in_range(u64 start, u64 end, u64 size, u64 align);
+int memblock_free_reserved_regions(void);
+int memblock_reserve_reserved_regions(void);
+
+extern void memblock_init(void);
+extern void memblock_analyze(void);
+extern long memblock_add(phys_addr_t base, phys_addr_t size);
+extern long memblock_remove(phys_addr_t base, phys_addr_t size);
+extern long memblock_free(phys_addr_t base, phys_addr_t size);
+extern long memblock_reserve(phys_addr_t base, phys_addr_t size);
+
+/* The numa aware allocator is only available if
+ * CONFIG_ARCH_POPULATES_NODE_MAP is set
+ */
+extern phys_addr_t memblock_alloc_nid(phys_addr_t size, phys_addr_t align,
+					int nid);
+extern phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+					    int nid);
+
+extern phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
+
+/* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
+#define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
+#define MEMBLOCK_ALLOC_ACCESSIBLE	0
+
+extern phys_addr_t memblock_alloc_base(phys_addr_t size,
+					 phys_addr_t align,
+					 phys_addr_t max_addr);
+extern phys_addr_t __memblock_alloc_base(phys_addr_t size,
+					   phys_addr_t align,
+					   phys_addr_t max_addr);
+extern phys_addr_t memblock_phys_mem_size(void);
+extern phys_addr_t memblock_end_of_DRAM(void);
+extern void memblock_enforce_memory_limit(phys_addr_t memory_limit);
+extern int memblock_is_memory(phys_addr_t addr);
+extern int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
+extern int memblock_is_reserved(phys_addr_t addr);
+extern int memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
 
 extern void memblock_dump_all(void);
 
-static inline u64
-memblock_size_bytes(struct memblock_region *type, unsigned long region_nr)
+/* Provided by the architecture */
+extern phys_addr_t memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid);
+extern int memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+				   phys_addr_t addr2, phys_addr_t size2);
+
+/**
+ * memblock_set_current_limit - Set the current allocation limit to allow
+ *                         limiting allocations to what is currently
+ *                         accessible during boot
+ * @limit: New limit value (physical address)
+ */
+extern void memblock_set_current_limit(phys_addr_t limit);
+
+
+/*
+ * pfn conversion functions
+ *
+ * While the memory MEMBLOCKs should always be page aligned, the reserved
+ * MEMBLOCKs may not be. This accessor attempt to provide a very clear
+ * idea of what they return for such non aligned MEMBLOCKs.
+ */
+
+/**
+ * memblock_region_memory_base_pfn - Return the lowest pfn intersecting with the memory region
+ * @reg: memblock_region structure
+ */
+static inline unsigned long memblock_region_memory_base_pfn(const struct memblock_region *reg)
 {
-	return type->region[region_nr].size;
+	return PFN_UP(reg->base);
 }
-static inline u64
-memblock_size_pages(struct memblock_region *type, unsigned long region_nr)
+
+/**
+ * memblock_region_memory_end_pfn - Return the end_pfn this region
+ * @reg: memblock_region structure
+ */
+static inline unsigned long memblock_region_memory_end_pfn(const struct memblock_region *reg)
 {
-	return memblock_size_bytes(type, region_nr) >> PAGE_SHIFT;
+	return PFN_DOWN(reg->base + reg->size);
 }
-static inline u64
-memblock_start_pfn(struct memblock_region *type, unsigned long region_nr)
+
+/**
+ * memblock_region_reserved_base_pfn - Return the lowest pfn intersecting with the reserved region
+ * @reg: memblock_region structure
+ */
+static inline unsigned long memblock_region_reserved_base_pfn(const struct memblock_region *reg)
 {
-	return type->region[region_nr].base >> PAGE_SHIFT;
+	return PFN_DOWN(reg->base);
 }
-static inline u64
-memblock_end_pfn(struct memblock_region *type, unsigned long region_nr)
+
+/**
+ * memblock_region_reserved_end_pfn - Return the end_pfn this region
+ * @reg: memblock_region structure
+ */
+static inline unsigned long memblock_region_reserved_end_pfn(const struct memblock_region *reg)
 {
-	return memblock_start_pfn(type, region_nr) +
-	       memblock_size_pages(type, region_nr);
+	return PFN_UP(reg->base + reg->size);
 }
 
-#include <asm/memblock.h>
+#define for_each_memblock(memblock_type, region)					\
+	for (region = memblock.memblock_type.regions;				\
+	     region < (memblock.memblock_type.regions + memblock.memblock_type.cnt);	\
+	     region++)
+
+
+#ifdef ARCH_DISCARD_MEMBLOCK
+#define __init_memblock __init
+#define __initdata_memblock __initdata
+#else
+#define __init_memblock
+#define __initdata_memblock
+#endif
+
+#endif /* CONFIG_HAVE_MEMBLOCK */
 
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..7687228 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1175,6 +1175,8 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 int add_from_early_node_map(struct range *range, int az,
 				   int nr_range, int nid);
+u64 __init find_memory_core_early(int nid, u64 size, u64 align,
+					u64 goal, u64 limit);
 void *__alloc_memory_core_early(int nodeid, u64 size, u64 align,
 				 u64 goal, u64 limit);
 typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
diff --git a/kernel/early_res.c b/kernel/early_res.c
deleted file mode 100644
index 7bfae88..0000000
--- a/kernel/early_res.c
+++ /dev/null
@@ -1,590 +0,0 @@
-/*
- * early_res, could be used to replace bootmem
- */
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/init.h>
-#include <linux/bootmem.h>
-#include <linux/mm.h>
-#include <linux/early_res.h>
-#include <linux/slab.h>
-#include <linux/kmemleak.h>
-
-/*
- * Early reserved memory areas.
- */
-/*
- * need to make sure this one is bigger enough before
- * find_fw_memmap_area could be used
- */
-#define MAX_EARLY_RES_X 32
-
-struct early_res {
-	u64 start, end;
-	char name[15];
-	char overlap_ok;
-};
-static struct early_res early_res_x[MAX_EARLY_RES_X] __initdata;
-
-static int max_early_res __initdata = MAX_EARLY_RES_X;
-static struct early_res *early_res __initdata = &early_res_x[0];
-static int early_res_count __initdata;
-
-static int __init find_overlapped_early(u64 start, u64 end)
-{
-	int i;
-	struct early_res *r;
-
-	for (i = 0; i < max_early_res && early_res[i].end; i++) {
-		r = &early_res[i];
-		if (end > r->start && start < r->end)
-			break;
-	}
-
-	return i;
-}
-
-/*
- * Drop the i-th range from the early reservation map,
- * by copying any higher ranges down one over it, and
- * clearing what had been the last slot.
- */
-static void __init drop_range(int i)
-{
-	int j;
-
-	for (j = i + 1; j < max_early_res && early_res[j].end; j++)
-		;
-
-	memmove(&early_res[i], &early_res[i + 1],
-	       (j - 1 - i) * sizeof(struct early_res));
-
-	early_res[j - 1].end = 0;
-	early_res_count--;
-}
-
-static void __init drop_range_partial(int i, u64 start, u64 end)
-{
-	u64 common_start, common_end;
-	u64 old_start, old_end;
-
-	old_start = early_res[i].start;
-	old_end = early_res[i].end;
-	common_start = max(old_start, start);
-	common_end = min(old_end, end);
-
-	/* no overlap ? */
-	if (common_start >= common_end)
-		return;
-
-	if (old_start < common_start) {
-		/* make head segment */
-		early_res[i].end = common_start;
-		if (old_end > common_end) {
-			char name[15];
-
-			/*
-			 * Save a local copy of the name, since the
-			 * early_res array could get resized inside
-			 * reserve_early_without_check() ->
-			 * __check_and_double_early_res(), which would
-			 * make the current name pointer invalid.
-			 */
-			strncpy(name, early_res[i].name,
-					 sizeof(early_res[i].name) - 1);
-			/* add another for left over on tail */
-			reserve_early_without_check(common_end, old_end, name);
-		}
-		return;
-	} else {
-		if (old_end > common_end) {
-			/* reuse the entry for tail left */
-			early_res[i].start = common_end;
-			return;
-		}
-		/* all covered */
-		drop_range(i);
-	}
-}
-
-/*
- * Split any existing ranges that:
- *  1) are marked 'overlap_ok', and
- *  2) overlap with the stated range [start, end)
- * into whatever portion (if any) of the existing range is entirely
- * below or entirely above the stated range.  Drop the portion
- * of the existing range that overlaps with the stated range,
- * which will allow the caller of this routine to then add that
- * stated range without conflicting with any existing range.
- */
-static void __init drop_overlaps_that_are_ok(u64 start, u64 end)
-{
-	int i;
-	struct early_res *r;
-	u64 lower_start, lower_end;
-	u64 upper_start, upper_end;
-	char name[15];
-
-	for (i = 0; i < max_early_res && early_res[i].end; i++) {
-		r = &early_res[i];
-
-		/* Continue past non-overlapping ranges */
-		if (end <= r->start || start >= r->end)
-			continue;
-
-		/*
-		 * Leave non-ok overlaps as is; let caller
-		 * panic "Overlapping early reservations"
-		 * when it hits this overlap.
-		 */
-		if (!r->overlap_ok)
-			return;
-
-		/*
-		 * We have an ok overlap.  We will drop it from the early
-		 * reservation map, and add back in any non-overlapping
-		 * portions (lower or upper) as separate, overlap_ok,
-		 * non-overlapping ranges.
-		 */
-
-		/* 1. Note any non-overlapping (lower or upper) ranges. */
-		strncpy(name, r->name, sizeof(name) - 1);
-
-		lower_start = lower_end = 0;
-		upper_start = upper_end = 0;
-		if (r->start < start) {
-			lower_start = r->start;
-			lower_end = start;
-		}
-		if (r->end > end) {
-			upper_start = end;
-			upper_end = r->end;
-		}
-
-		/* 2. Drop the original ok overlapping range */
-		drop_range(i);
-
-		i--;		/* resume for-loop on copied down entry */
-
-		/* 3. Add back in any non-overlapping ranges. */
-		if (lower_end)
-			reserve_early_overlap_ok(lower_start, lower_end, name);
-		if (upper_end)
-			reserve_early_overlap_ok(upper_start, upper_end, name);
-	}
-}
-
-static void __init __reserve_early(u64 start, u64 end, char *name,
-						int overlap_ok)
-{
-	int i;
-	struct early_res *r;
-
-	i = find_overlapped_early(start, end);
-	if (i >= max_early_res)
-		panic("Too many early reservations");
-	r = &early_res[i];
-	if (r->end)
-		panic("Overlapping early reservations "
-		      "%llx-%llx %s to %llx-%llx %s\n",
-		      start, end - 1, name ? name : "", r->start,
-		      r->end - 1, r->name);
-	r->start = start;
-	r->end = end;
-	r->overlap_ok = overlap_ok;
-	if (name)
-		strncpy(r->name, name, sizeof(r->name) - 1);
-	early_res_count++;
-}
-
-/*
- * A few early reservtations come here.
- *
- * The 'overlap_ok' in the name of this routine does -not- mean it
- * is ok for these reservations to overlap an earlier reservation.
- * Rather it means that it is ok for subsequent reservations to
- * overlap this one.
- *
- * Use this entry point to reserve early ranges when you are doing
- * so out of "Paranoia", reserving perhaps more memory than you need,
- * just in case, and don't mind a subsequent overlapping reservation
- * that is known to be needed.
- *
- * The drop_overlaps_that_are_ok() call here isn't really needed.
- * It would be needed if we had two colliding 'overlap_ok'
- * reservations, so that the second such would not panic on the
- * overlap with the first.  We don't have any such as of this
- * writing, but might as well tolerate such if it happens in
- * the future.
- */
-void __init reserve_early_overlap_ok(u64 start, u64 end, char *name)
-{
-	drop_overlaps_that_are_ok(start, end);
-	__reserve_early(start, end, name, 1);
-}
-
-static void __init __check_and_double_early_res(u64 ex_start, u64 ex_end)
-{
-	u64 start, end, size, mem;
-	struct early_res *new;
-
-	/* do we have enough slots left ? */
-	if ((max_early_res - early_res_count) > max(max_early_res/8, 2))
-		return;
-
-	/* double it */
-	mem = -1ULL;
-	size = sizeof(struct early_res) * max_early_res * 2;
-	if (early_res == early_res_x)
-		start = 0;
-	else
-		start = early_res[0].end;
-	end = ex_start;
-	if (start + size < end)
-		mem = find_fw_memmap_area(start, end, size,
-					 sizeof(struct early_res));
-	if (mem == -1ULL) {
-		start = ex_end;
-		end = get_max_mapped();
-		if (start + size < end)
-			mem = find_fw_memmap_area(start, end, size,
-						 sizeof(struct early_res));
-	}
-	if (mem == -1ULL)
-		panic("can not find more space for early_res array");
-
-	new = __va(mem);
-	/* save the first one for own */
-	new[0].start = mem;
-	new[0].end = mem + size;
-	new[0].overlap_ok = 0;
-	/* copy old to new */
-	if (early_res == early_res_x) {
-		memcpy(&new[1], &early_res[0],
-			 sizeof(struct early_res) * max_early_res);
-		memset(&new[max_early_res+1], 0,
-			 sizeof(struct early_res) * (max_early_res - 1));
-		early_res_count++;
-	} else {
-		memcpy(&new[1], &early_res[1],
-			 sizeof(struct early_res) * (max_early_res - 1));
-		memset(&new[max_early_res], 0,
-			 sizeof(struct early_res) * max_early_res);
-	}
-	memset(&early_res[0], 0, sizeof(struct early_res) * max_early_res);
-	early_res = new;
-	max_early_res *= 2;
-	printk(KERN_DEBUG "early_res array is doubled to %d at [%llx - %llx]\n",
-		max_early_res, mem, mem + size - 1);
-}
-
-/*
- * Most early reservations come here.
- *
- * We first have drop_overlaps_that_are_ok() drop any pre-existing
- * 'overlap_ok' ranges, so that we can then reserve this memory
- * range without risk of panic'ing on an overlapping overlap_ok
- * early reservation.
- */
-void __init reserve_early(u64 start, u64 end, char *name)
-{
-	if (start >= end)
-		return;
-
-	__check_and_double_early_res(start, end);
-
-	drop_overlaps_that_are_ok(start, end);
-	__reserve_early(start, end, name, 0);
-}
-
-void __init reserve_early_without_check(u64 start, u64 end, char *name)
-{
-	struct early_res *r;
-
-	if (start >= end)
-		return;
-
-	__check_and_double_early_res(start, end);
-
-	r = &early_res[early_res_count];
-
-	r->start = start;
-	r->end = end;
-	r->overlap_ok = 0;
-	if (name)
-		strncpy(r->name, name, sizeof(r->name) - 1);
-	early_res_count++;
-}
-
-void __init free_early(u64 start, u64 end)
-{
-	struct early_res *r;
-	int i;
-
-	kmemleak_free_part(__va(start), end - start);
-
-	i = find_overlapped_early(start, end);
-	r = &early_res[i];
-	if (i >= max_early_res || r->end != end || r->start != start)
-		panic("free_early on not reserved area: %llx-%llx!",
-			 start, end - 1);
-
-	drop_range(i);
-}
-
-void __init free_early_partial(u64 start, u64 end)
-{
-	struct early_res *r;
-	int i;
-
-	kmemleak_free_part(__va(start), end - start);
-
-	if (start == end)
-		return;
-
-	if (WARN_ONCE(start > end, "  wrong range [%#llx, %#llx]\n", start, end))
-		return;
-
-try_next:
-	i = find_overlapped_early(start, end);
-	if (i >= max_early_res)
-		return;
-
-	r = &early_res[i];
-	/* hole ? */
-	if (r->end >= end && r->start <= start) {
-		drop_range_partial(i, start, end);
-		return;
-	}
-
-	drop_range_partial(i, start, end);
-	goto try_next;
-}
-
-#ifdef CONFIG_NO_BOOTMEM
-static void __init subtract_early_res(struct range *range, int az)
-{
-	int i, count;
-	u64 final_start, final_end;
-	int idx = 0;
-
-	count  = 0;
-	for (i = 0; i < max_early_res && early_res[i].end; i++)
-		count++;
-
-	/* need to skip first one ?*/
-	if (early_res != early_res_x)
-		idx = 1;
-
-#define DEBUG_PRINT_EARLY_RES 1
-
-#if DEBUG_PRINT_EARLY_RES
-	printk(KERN_INFO "Subtract (%d early reservations)\n", count);
-#endif
-	for (i = idx; i < count; i++) {
-		struct early_res *r = &early_res[i];
-#if DEBUG_PRINT_EARLY_RES
-		printk(KERN_INFO "  #%d [%010llx - %010llx] %15s\n", i,
-			r->start, r->end, r->name);
-#endif
-		final_start = PFN_DOWN(r->start);
-		final_end = PFN_UP(r->end);
-		if (final_start >= final_end)
-			continue;
-		subtract_range(range, az, final_start, final_end);
-	}
-
-}
-
-int __init get_free_all_memory_range(struct range **rangep, int nodeid)
-{
-	int i, count;
-	u64 start = 0, end;
-	u64 size;
-	u64 mem;
-	struct range *range;
-	int nr_range;
-
-	count  = 0;
-	for (i = 0; i < max_early_res && early_res[i].end; i++)
-		count++;
-
-	count *= 2;
-
-	size = sizeof(struct range) * count;
-	end = get_max_mapped();
-#ifdef MAX_DMA32_PFN
-	if (end > (MAX_DMA32_PFN << PAGE_SHIFT))
-		start = MAX_DMA32_PFN << PAGE_SHIFT;
-#endif
-	mem = find_fw_memmap_area(start, end, size, sizeof(struct range));
-	if (mem == -1ULL)
-		panic("can not find more space for range free");
-
-	range = __va(mem);
-	/* use early_node_map[] and early_res to get range array at first */
-	memset(range, 0, size);
-	nr_range = 0;
-
-	/* need to go over early_node_map to find out good range for node */
-	nr_range = add_from_early_node_map(range, count, nr_range, nodeid);
-#ifdef CONFIG_X86_32
-	subtract_range(range, count, max_low_pfn, -1ULL);
-#endif
-	subtract_early_res(range, count);
-	nr_range = clean_sort_range(range, count);
-
-	/* need to clear it ? */
-	if (nodeid == MAX_NUMNODES) {
-		memset(&early_res[0], 0,
-			 sizeof(struct early_res) * max_early_res);
-		early_res = NULL;
-		max_early_res = 0;
-	}
-
-	*rangep = range;
-	return nr_range;
-}
-#else
-void __init early_res_to_bootmem(u64 start, u64 end)
-{
-	int i, count;
-	u64 final_start, final_end;
-	int idx = 0;
-
-	count  = 0;
-	for (i = 0; i < max_early_res && early_res[i].end; i++)
-		count++;
-
-	/* need to skip first one ?*/
-	if (early_res != early_res_x)
-		idx = 1;
-
-	printk(KERN_INFO "(%d/%d early reservations) ==> bootmem [%010llx - %010llx]\n",
-			 count - idx, max_early_res, start, end);
-	for (i = idx; i < count; i++) {
-		struct early_res *r = &early_res[i];
-		printk(KERN_INFO "  #%d [%010llx - %010llx] %16s", i,
-			r->start, r->end, r->name);
-		final_start = max(start, r->start);
-		final_end = min(end, r->end);
-		if (final_start >= final_end) {
-			printk(KERN_CONT "\n");
-			continue;
-		}
-		printk(KERN_CONT " ==> [%010llx - %010llx]\n",
-			final_start, final_end);
-		reserve_bootmem_generic(final_start, final_end - final_start,
-				BOOTMEM_DEFAULT);
-	}
-	/* clear them */
-	memset(&early_res[0], 0, sizeof(struct early_res) * max_early_res);
-	early_res = NULL;
-	max_early_res = 0;
-	early_res_count = 0;
-}
-#endif
-
-/* Check for already reserved areas */
-static inline int __init bad_addr(u64 *addrp, u64 size, u64 align)
-{
-	int i;
-	u64 addr = *addrp;
-	int changed = 0;
-	struct early_res *r;
-again:
-	i = find_overlapped_early(addr, addr + size);
-	r = &early_res[i];
-	if (i < max_early_res && r->end) {
-		*addrp = addr = round_up(r->end, align);
-		changed = 1;
-		goto again;
-	}
-	return changed;
-}
-
-/* Check for already reserved areas */
-static inline int __init bad_addr_size(u64 *addrp, u64 *sizep, u64 align)
-{
-	int i;
-	u64 addr = *addrp, last;
-	u64 size = *sizep;
-	int changed = 0;
-again:
-	last = addr + size;
-	for (i = 0; i < max_early_res && early_res[i].end; i++) {
-		struct early_res *r = &early_res[i];
-		if (last > r->start && addr < r->start) {
-			size = r->start - addr;
-			changed = 1;
-			goto again;
-		}
-		if (last > r->end && addr < r->end) {
-			addr = round_up(r->end, align);
-			size = last - addr;
-			changed = 1;
-			goto again;
-		}
-		if (last <= r->end && addr >= r->start) {
-			(*sizep)++;
-			return 0;
-		}
-	}
-	if (changed) {
-		*addrp = addr;
-		*sizep = size;
-	}
-	return changed;
-}
-
-/*
- * Find a free area with specified alignment in a specific range.
- * only with the area.between start to end is active range from early_node_map
- * so they are good as RAM
- */
-u64 __init find_early_area(u64 ei_start, u64 ei_last, u64 start, u64 end,
-			 u64 size, u64 align)
-{
-	u64 addr, last;
-
-	addr = round_up(ei_start, align);
-	if (addr < start)
-		addr = round_up(start, align);
-	if (addr >= ei_last)
-		goto out;
-	while (bad_addr(&addr, size, align) && addr+size <= ei_last)
-		;
-	last = addr + size;
-	if (last > ei_last)
-		goto out;
-	if (last > end)
-		goto out;
-
-	return addr;
-
-out:
-	return -1ULL;
-}
-
-u64 __init find_early_area_size(u64 ei_start, u64 ei_last, u64 start,
-			 u64 *sizep, u64 align)
-{
-	u64 addr, last;
-
-	addr = round_up(ei_start, align);
-	if (addr < start)
-		addr = round_up(start, align);
-	if (addr >= ei_last)
-		goto out;
-	*sizep = ei_last - addr;
-	while (bad_addr_size(&addr, sizep, align) && addr + *sizep <= ei_last)
-		;
-	last = addr + *sizep;
-	if (last > ei_last)
-		goto out;
-
-	return addr;
-
-out:
-	return -1ULL;
-}
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 142c84a..13b0caa 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/kmemleak.h>
 #include <linux/range.h>
+#include <linux/memblock.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
@@ -434,7 +435,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
 #ifdef CONFIG_NO_BOOTMEM
-	free_early(physaddr, physaddr + size);
+	kmemleak_free_part(__va(physaddr), size);
+	memblock_x86_free_range(physaddr, physaddr + size);
 #else
 	unsigned long start, end;
 
@@ -459,7 +461,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
 #ifdef CONFIG_NO_BOOTMEM
-	free_early(addr, addr + size);
+	kmemleak_free_part(__va(addr), size);
+	memblock_x86_free_range(addr, addr + size);
 #else
 	unsigned long start, end;
 
@@ -526,6 +529,12 @@ int __init reserve_bootmem(unsigned long addr, unsigned long size,
 }
 
 #ifndef CONFIG_NO_BOOTMEM
+int __weak __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
+				   int flags)
+{
+	return reserve_bootmem(phys, len, flags);
+}
+
 static unsigned long __init align_idx(struct bootmem_data *bdata,
 				      unsigned long idx, unsigned long step)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 43840b3..400dc62 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -11,237 +11,423 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
+#include <linux/poison.h>
+#include <linux/pfn.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/memblock.h>
 
-#define MEMBLOCK_ALLOC_ANYWHERE	0
+struct memblock memblock __initdata_memblock;
 
-struct memblock memblock;
+int memblock_debug __initdata_memblock;
+int memblock_can_resize __initdata_memblock;
+static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS + 1] __initdata_memblock;
+static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS + 1] __initdata_memblock;
 
-static int memblock_debug;
+/* inline so we don't get a warning when pr_debug is compiled out */
+static inline const char *memblock_type_name(struct memblock_type *type)
+{
+	if (type == &memblock.memory)
+		return "memory";
+	else if (type == &memblock.reserved)
+		return "reserved";
+	else
+		return "unknown";
+}
 
-static int __init early_memblock(char *p)
+/*
+ * Address comparison utilities
+ */
+
+static phys_addr_t __init_memblock memblock_align_down(phys_addr_t addr, phys_addr_t size)
 {
-	if (p && strstr(p, "debug"))
-		memblock_debug = 1;
+	return addr & ~(size - 1);
+}
+
+static phys_addr_t __init_memblock memblock_align_up(phys_addr_t addr, phys_addr_t size)
+{
+	return (addr + (size - 1)) & ~(size - 1);
+}
+
+static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
+				       phys_addr_t base2, phys_addr_t size2)
+{
+	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
+}
+
+static long __init_memblock memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
+			       phys_addr_t base2, phys_addr_t size2)
+{
+	if (base2 == base1 + size1)
+		return 1;
+	else if (base1 == base2 + size2)
+		return -1;
+
 	return 0;
 }
-early_param("memblock", early_memblock);
 
-static void memblock_dump(struct memblock_region *region, char *name)
+static long __init_memblock memblock_regions_adjacent(struct memblock_type *type,
+				 unsigned long r1, unsigned long r2)
 {
-	unsigned long long base, size;
-	int i;
+	phys_addr_t base1 = type->regions[r1].base;
+	phys_addr_t size1 = type->regions[r1].size;
+	phys_addr_t base2 = type->regions[r2].base;
+	phys_addr_t size2 = type->regions[r2].size;
 
-	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
+	return memblock_addrs_adjacent(base1, size1, base2, size2);
+}
 
-	for (i = 0; i < region->cnt; i++) {
-		base = region->region[i].base;
-		size = region->region[i].size;
+long __init_memblock memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+{
+	unsigned long i;
 
-		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
-		    name, i, base, base + size - 1, size);
+	for (i = 0; i < type->cnt; i++) {
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
+		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
+			break;
 	}
+
+	return (i < type->cnt) ? i : -1;
 }
 
-void memblock_dump_all(void)
+/*
+ * Find, allocate, deallocate or reserve unreserved regions. All allocations
+ * are top-down.
+ */
+
+static phys_addr_t __init_memblock memblock_find_region(phys_addr_t start, phys_addr_t end,
+					  phys_addr_t size, phys_addr_t align)
 {
-	if (!memblock_debug)
-		return;
+	phys_addr_t base, res_base;
+	long j;
 
-	pr_info("MEMBLOCK configuration:\n");
-	pr_info(" rmo_size    = 0x%llx\n", (unsigned long long)memblock.rmo_size);
-	pr_info(" memory.size = 0x%llx\n", (unsigned long long)memblock.memory.size);
+	/* In case, huge size is requested */
+	if (end < size)
+		return MEMBLOCK_ERROR;
 
-	memblock_dump(&memblock.memory, "memory");
-	memblock_dump(&memblock.reserved, "reserved");
+	base = memblock_align_down((end - size), align);
+
+	/* Prevent allocations returning 0 as it's also used to
+	 * indicate an allocation failure
+	 */
+	if (start == 0)
+		start = PAGE_SIZE;
+
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
 }
 
-static unsigned long memblock_addrs_overlap(u64 base1, u64 size1, u64 base2,
-					u64 size2)
+static phys_addr_t __init_memblock memblock_find_base(phys_addr_t size,
+			phys_addr_t align, phys_addr_t start, phys_addr_t end)
 {
-	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
+	long i;
+
+	BUG_ON(0 == size);
+
+	size = memblock_align_up(size, align);
+
+	/* Pump up max_addr */
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
+
+	/* We do a top-down search, this tends to limit memory
+	 * fragmentation by keeping early boot allocs near the
+	 * top of memory
+	 */
+	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
+		phys_addr_t memblockbase = memblock.memory.regions[i].base;
+		phys_addr_t memblocksize = memblock.memory.regions[i].size;
+		phys_addr_t bottom, top, found;
+
+		if (memblocksize < size)
+			continue;
+		if ((memblockbase + memblocksize) <= start)
+			break;
+		bottom = max(memblockbase, start);
+		top = min(memblockbase + memblocksize, end);
+		if (bottom >= top)
+			continue;
+		found = memblock_find_region(bottom, top, size, align);
+		if (found != MEMBLOCK_ERROR)
+			return found;
+	}
+	return MEMBLOCK_ERROR;
 }
 
-static long memblock_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
+/*
+ * Find a free area with specified alignment in a specific range.
+ */
+u64 __init_memblock memblock_find_in_range(u64 start, u64 end, u64 size, u64 align)
 {
-	if (base2 == base1 + size1)
-		return 1;
-	else if (base1 == base2 + size2)
-		return -1;
+	return memblock_find_base(size, align, start, end);
+}
 
-	return 0;
+/*
+ * Free memblock.reserved.regions
+ */
+int __init_memblock memblock_free_reserved_regions(void)
+{
+	if (memblock.reserved.regions == memblock_reserved_init_regions)
+		return 0;
+
+	return memblock_free(__pa(memblock.reserved.regions),
+		 sizeof(struct memblock_region) * memblock.reserved.max);
 }
 
-static long memblock_regions_adjacent(struct memblock_region *rgn,
-		unsigned long r1, unsigned long r2)
+/*
+ * Reserve memblock.reserved.regions
+ */
+int __init_memblock memblock_reserve_reserved_regions(void)
 {
-	u64 base1 = rgn->region[r1].base;
-	u64 size1 = rgn->region[r1].size;
-	u64 base2 = rgn->region[r2].base;
-	u64 size2 = rgn->region[r2].size;
+	if (memblock.reserved.regions == memblock_reserved_init_regions)
+		return 0;
 
-	return memblock_addrs_adjacent(base1, size1, base2, size2);
+	return memblock_reserve(__pa(memblock.reserved.regions),
+		 sizeof(struct memblock_region) * memblock.reserved.max);
 }
 
-static void memblock_remove_region(struct memblock_region *rgn, unsigned long r)
+static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
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
+static void __init_memblock memblock_coalesce_regions(struct memblock_type *type,
 		unsigned long r1, unsigned long r2)
 {
-	rgn->region[r1].size += rgn->region[r2].size;
-	memblock_remove_region(rgn, r2);
+	type->regions[r1].size += type->regions[r2].size;
+	memblock_remove_region(type, r2);
 }
 
-void __init memblock_init(void)
+/* Defined below but needed now */
+static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size);
+
+static int __init_memblock memblock_double_array(struct memblock_type *type)
 {
-	/* Create a dummy zero size MEMBLOCK which will get coalesced away later.
-	 * This simplifies the memblock_add() code below...
+	struct memblock_region *new_array, *old_array;
+	phys_addr_t old_size, new_size, addr;
+	int use_slab = slab_is_available();
+
+	/* We don't allow resizing until we know about the reserved regions
+	 * of memory that aren't suitable for allocation
 	 */
-	memblock.memory.region[0].base = 0;
-	memblock.memory.region[0].size = 0;
-	memblock.memory.cnt = 1;
+	if (!memblock_can_resize)
+		return -1;
 
-	/* Ditto. */
-	memblock.reserved.region[0].base = 0;
-	memblock.reserved.region[0].size = 0;
-	memblock.reserved.cnt = 1;
-}
+	/* Calculate new doubled size */
+	old_size = type->max * sizeof(struct memblock_region);
+	new_size = old_size << 1;
+
+	/* Try to find some space for it.
+	 *
+	 * WARNING: We assume that either slab_is_available() and we use it or
+	 * we use MEMBLOCK for allocations. That means that this is unsafe to use
+	 * when bootmem is currently active (unless bootmem itself is implemented
+	 * on top of MEMBLOCK which isn't the case yet)
+	 *
+	 * This should however not be an issue for now, as we currently only
+	 * call into MEMBLOCK while it's still active, or much later when slab is
+	 * active for memory hotplug operations
+	 */
+	if (use_slab) {
+		new_array = kmalloc(new_size, GFP_KERNEL);
+		addr = new_array == NULL ? MEMBLOCK_ERROR : __pa(new_array);
+	} else
+		addr = memblock_find_base(new_size, sizeof(phys_addr_t), 0, MEMBLOCK_ALLOC_ACCESSIBLE);
+	if (addr == MEMBLOCK_ERROR) {
+		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
+		       memblock_type_name(type), type->max, type->max * 2);
+		return -1;
+	}
+	new_array = __va(addr);
 
-void __init memblock_analyze(void)
-{
-	int i;
+	memblock_dbg("memblock: %s array is doubled to %ld at [%#010llx-%#010llx]",
+		 memblock_type_name(type), type->max * 2, (u64)addr, (u64)addr + new_size - 1);
 
-	memblock.memory.size = 0;
+	/* Found space, we now need to move the array over before
+	 * we add the reserved region since it may be our reserved
+	 * array itself that is full.
+	 */
+	memcpy(new_array, type->regions, old_size);
+	memset(new_array + type->max, 0, old_size);
+	old_array = type->regions;
+	type->regions = new_array;
+	type->max <<= 1;
+
+	/* If we use SLAB that's it, we are done */
+	if (use_slab)
+		return 0;
 
-	for (i = 0; i < memblock.memory.cnt; i++)
-		memblock.memory.size += memblock.memory.region[i].size;
+	/* Add the new reserved region now. Should not fail ! */
+	BUG_ON(memblock_add_region(&memblock.reserved, addr, new_size) < 0);
+
+	/* If the array wasn't our static init one, then free it. We only do
+	 * that before SLAB is available as later on, we don't know whether
+	 * to use kfree or free_bootmem_pages(). Shouldn't be a big deal
+	 * anyways
+	 */
+	if (old_array != memblock_memory_init_regions &&
+	    old_array != memblock_reserved_init_regions)
+		memblock_free(__pa(old_array), old_size);
+
+	return 0;
 }
 
-static long memblock_add_region(struct memblock_region *rgn, u64 base, u64 size)
+extern int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+					  phys_addr_t addr2, phys_addr_t size2)
+{
+	return 1;
+}
+
+static long __init_memblock memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
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
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
 
 		if ((rgnbase == base) && (rgnsize == size))
 			/* Already have this region, so we're done */
 			return 0;
 
 		adjacent = memblock_addrs_adjacent(base, size, rgnbase, rgnsize);
+		/* Check if arch allows coalescing */
+		if (adjacent != 0 && type == &memblock.memory &&
+		    !memblock_memory_can_coalesce(base, size, rgnbase, rgnsize))
+			break;
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
+	/* If we plugged a hole, we may want to also coalesce with the
+	 * next region
+	 */
+	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1) &&
+	    ((type != &memblock.memory || memblock_memory_can_coalesce(type->regions[i].base,
+							     type->regions[i].size,
+							     type->regions[i+1].base,
+							     type->regions[i+1].size)))) {
+		memblock_coalesce_regions(type, i, i+1);
 		coalesced++;
 	}
 
 	if (coalesced)
 		return coalesced;
-	if (rgn->cnt >= MAX_MEMBLOCK_REGIONS)
+
+	/* If we are out of space, we fail. It's too late to resize the array
+	 * but then this shouldn't have happened in the first place.
+	 */
+	if (WARN_ON(type->cnt >= type->max))
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
+	}
+	type->cnt++;
+
+	/* The array is full ? Try to resize it. If that fails, we undo
+	 * our allocation and return an error
+	 */
+	if (type->cnt == type->max && memblock_double_array(type)) {
+		type->cnt--;
+		return -1;
 	}
-	rgn->cnt++;
 
 	return 0;
 }
 
-long memblock_add(u64 base, u64 size)
+long __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	struct memblock_region *_rgn = &memblock.memory;
-
-	/* On pSeries LPAR systems, the first MEMBLOCK is our RMO region. */
-	if (base == 0)
-		memblock.rmo_size = size;
-
-	return memblock_add_region(_rgn, base, size);
+	return memblock_add_region(&memblock.memory, base, size);
 
 }
 
-static long __memblock_remove(struct memblock_region *rgn, u64 base, u64 size)
+static long __init_memblock __memblock_remove(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
-	u64 rgnbegin, rgnend;
-	u64 end = base + size;
+	phys_addr_t rgnbegin, rgnend;
+	phys_addr_t end = base + size;
 	int i;
 
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
 
@@ -249,208 +435,189 @@ static long __memblock_remove(struct memblock_region *rgn, u64 base, u64 size)
 	 * We need to split the entry -  adjust the current one to the
 	 * beginging of the hole and add the region after hole.
 	 */
-	rgn->region[i].size = base - rgn->region[i].base;
-	return memblock_add_region(rgn, end, rgnend - end);
+	type->regions[i].size = base - type->regions[i].base;
+	return memblock_add_region(type, end, rgnend - end);
 }
 
-long memblock_remove(u64 base, u64 size)
+long __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 {
 	return __memblock_remove(&memblock.memory, base, size);
 }
 
-long __init memblock_free(u64 base, u64 size)
+long __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	return __memblock_remove(&memblock.reserved, base, size);
 }
 
-long __init memblock_reserve(u64 base, u64 size)
+long __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
-	struct memblock_region *_rgn = &memblock.reserved;
+	struct memblock_type *_rgn = &memblock.reserved;
 
 	BUG_ON(0 == size);
 
 	return memblock_add_region(_rgn, base, size);
 }
 
-long memblock_overlaps_region(struct memblock_region *rgn, u64 base, u64 size)
+phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	unsigned long i;
+	phys_addr_t found;
 
-	for (i = 0; i < rgn->cnt; i++) {
-		u64 rgnbase = rgn->region[i].base;
-		u64 rgnsize = rgn->region[i].size;
-		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
-			break;
-	}
+	/* We align the size to limit fragmentation. Without this, a lot of
+	 * small allocs quickly eat up the whole reserve array on sparc
+	 */
+	size = memblock_align_up(size, align);
 
-	return (i < rgn->cnt) ? i : -1;
+	found = memblock_find_base(size, align, 0, max_addr);
+	if (found != MEMBLOCK_ERROR &&
+	    memblock_add_region(&memblock.reserved, found, size) >= 0)
+		return found;
+
+	return 0;
 }
 
-static u64 memblock_align_down(u64 addr, u64 size)
+phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return addr & ~(size - 1);
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
 
-static u64 memblock_align_up(u64 addr, u64 size)
+phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
-	return (addr + (size - 1)) & ~(size - 1);
+	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
-static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
-					   u64 size, u64 align)
+
+/*
+ * Additional node-local allocators. Search for node memory is bottom up
+ * and walks memblock regions within that node bottom-up as well, but allocation
+ * within an memblock region is top-down. XXX I plan to fix that at some stage
+ *
+ * WARNING: Only available after early_node_map[] has been populated,
+ * on some architectures, that is after all the calls to add_active_range()
+ * have been done to populate it.
+ */
+
+phys_addr_t __weak __init memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
-	u64 base, res_base;
-	long j;
+#ifdef CONFIG_ARCH_POPULATES_NODE_MAP
+	/*
+	 * This code originates from sparc which really wants use to walk by addresses
+	 * and returns the nid. This is not very convenient for early_pfn_map[] users
+	 * as the map isn't sorted yet, and it really wants to be walked by nid.
+	 *
+	 * For now, I implement the inefficient method below which walks the early
+	 * map multiple times. Eventually we may want to use an ARCH config option
+	 * to implement a completely different method for both case.
+	 */
+	unsigned long start_pfn, end_pfn;
+	int i;
 
-	base = memblock_align_down((end - size), align);
-	while (start <= base) {
-		j = memblock_overlaps_region(&memblock.reserved, base, size);
-		if (j < 0) {
-			/* this area isn't reserved, take it */
-			if (memblock_add_region(&memblock.reserved, base, size) < 0)
-				base = ~(u64)0;
-			return base;
-		}
-		res_base = memblock.reserved.region[j].base;
-		if (res_base < size)
-			break;
-		base = memblock_align_down(res_base - size, align);
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		get_pfn_range_for_nid(i, &start_pfn, &end_pfn);
+		if (start < PFN_PHYS(start_pfn) || start >= PFN_PHYS(end_pfn))
+			continue;
+		*nid = i;
+		return min(end, PFN_PHYS(end_pfn));
 	}
+#endif
+	*nid = 0;
 
-	return ~(u64)0;
+	return end;
 }
 
-static u64 __init memblock_alloc_nid_region(struct memblock_property *mp,
-				       u64 (*nid_range)(u64, u64, int *),
-				       u64 size, u64 align, int nid)
+static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
+					       phys_addr_t size,
+					       phys_addr_t align, int nid)
 {
-	u64 start, end;
+	phys_addr_t start, end;
 
 	start = mp->base;
 	end = start + mp->size;
 
 	start = memblock_align_up(start, align);
 	while (start < end) {
-		u64 this_end;
+		phys_addr_t this_end;
 		int this_nid;
 
-		this_end = nid_range(start, end, &this_nid);
+		this_end = memblock_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			u64 ret = memblock_alloc_nid_unreserved(start, this_end,
-							   size, align);
-			if (ret != ~(u64)0)
+			phys_addr_t ret = memblock_find_region(start, this_end, size, align);
+			if (ret != MEMBLOCK_ERROR &&
+			    memblock_add_region(&memblock.reserved, ret, size) >= 0)
 				return ret;
 		}
 		start = this_end;
 	}
 
-	return ~(u64)0;
+	return MEMBLOCK_ERROR;
 }
 
-u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
-			 u64 (*nid_range)(u64 start, u64 end, int *nid))
+phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	struct memblock_region *mem = &memblock.memory;
+	struct memblock_type *mem = &memblock.memory;
 	int i;
 
 	BUG_ON(0 == size);
 
+	/* We align the size to limit fragmentation. Without this, a lot of
+	 * small allocs quickly eat up the whole reserve array on sparc
+	 */
 	size = memblock_align_up(size, align);
 
+	/* We do a bottom-up search for a region with the right
+	 * nid since that's easier considering how memblock_nid_range()
+	 * works
+	 */
 	for (i = 0; i < mem->cnt; i++) {
-		u64 ret = memblock_alloc_nid_region(&mem->region[i],
-					       nid_range,
+		phys_addr_t ret = memblock_alloc_nid_region(&mem->regions[i],
 					       size, align, nid);
-		if (ret != ~(u64)0)
+		if (ret != MEMBLOCK_ERROR)
 			return ret;
 	}
 
-	return memblock_alloc(size, align);
-}
-
-u64 __init memblock_alloc(u64 size, u64 align)
-{
-	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ANYWHERE);
+	return 0;
 }
 
-u64 __init memblock_alloc_base(u64 size, u64 align, u64 max_addr)
+phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	u64 alloc;
-
-	alloc = __memblock_alloc_base(size, align, max_addr);
+	phys_addr_t res = memblock_alloc_nid(size, align, nid);
 
-	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
-
-	return alloc;
+	if (res)
+		return res;
+	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ANYWHERE);
 }
 
-u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
-{
-	long i, j;
-	u64 base = 0;
-	u64 res_base;
-
-	BUG_ON(0 == size);
 
-	size = memblock_align_up(size, align);
-
-	/* On some platforms, make sure we allocate lowmem */
-	/* Note that MEMBLOCK_REAL_LIMIT may be MEMBLOCK_ALLOC_ANYWHERE */
-	if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
-		max_addr = MEMBLOCK_REAL_LIMIT;
-
-	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
-		u64 memblockbase = memblock.memory.region[i].base;
-		u64 memblocksize = memblock.memory.region[i].size;
-
-		if (memblocksize < size)
-			continue;
-		if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
-			base = memblock_align_down(memblockbase + memblocksize - size, align);
-		else if (memblockbase < max_addr) {
-			base = min(memblockbase + memblocksize, max_addr);
-			base = memblock_align_down(base - size, align);
-		} else
-			continue;
-
-		while (base && memblockbase <= base) {
-			j = memblock_overlaps_region(&memblock.reserved, base, size);
-			if (j < 0) {
-				/* this area isn't reserved, take it */
-				if (memblock_add_region(&memblock.reserved, base, size) < 0)
-					return 0;
-				return base;
-			}
-			res_base = memblock.reserved.region[j].base;
-			if (res_base < size)
-				break;
-			base = memblock_align_down(res_base - size, align);
-		}
-	}
-	return 0;
-}
+/*
+ * Remaining API functions
+ */
 
 /* You must call memblock_analyze() before this. */
-u64 __init memblock_phys_mem_size(void)
+phys_addr_t __init memblock_phys_mem_size(void)
 {
-	return memblock.memory.size;
+	return memblock.memory_size;
 }
 
-u64 memblock_end_of_DRAM(void)
+phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 {
 	int idx = memblock.memory.cnt - 1;
 
-	return (memblock.memory.region[idx].base + memblock.memory.region[idx].size);
+	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
 }
 
 /* You must call memblock_analyze() after this. */
-void __init memblock_enforce_memory_limit(u64 memory_limit)
+void __init memblock_enforce_memory_limit(phys_addr_t memory_limit)
 {
 	unsigned long i;
-	u64 limit;
-	struct memblock_property *p;
+	phys_addr_t limit;
+	struct memblock_region *p;
 
 	if (!memory_limit)
 		return;
@@ -458,24 +625,21 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
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
-
 	memory_limit = memblock_end_of_DRAM();
 
 	/* And truncate any reserves above the limit also. */
 	for (i = 0; i < memblock.reserved.cnt; i++) {
-		p = &memblock.reserved.region[i];
+		p = &memblock.reserved.regions[i];
 
 		if (p->base > memory_limit)
 			p->size = 0;
@@ -489,53 +653,190 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 	}
 }
 
-int __init memblock_is_reserved(u64 addr)
+static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
+{
+	unsigned int left = 0, right = type->cnt;
+
+	do {
+		unsigned int mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else
+			return mid;
+	} while (left < right);
+	return -1;
+}
+
+int __init memblock_is_reserved(phys_addr_t addr)
+{
+	return memblock_search(&memblock.reserved, addr) != -1;
+}
+
+int __init_memblock memblock_is_memory(phys_addr_t addr)
+{
+	return memblock_search(&memblock.memory, addr) != -1;
+}
+
+int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
+{
+	int idx = memblock_search(&memblock.reserved, base);
+
+	if (idx == -1)
+		return 0;
+	return memblock.reserved.regions[idx].base <= base &&
+		(memblock.reserved.regions[idx].base +
+		 memblock.reserved.regions[idx].size) >= (base + size);
+}
+
+int __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
+}
+
+
+void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 {
+	memblock.current_limit = limit;
+}
+
+static void __init_memblock memblock_dump(struct memblock_type *region, char *name)
+{
+	unsigned long long base, size;
 	int i;
 
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		u64 upper = memblock.reserved.region[i].base +
-			memblock.reserved.region[i].size - 1;
-		if ((addr >= memblock.reserved.region[i].base) && (addr <= upper))
-			return 1;
+	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
+
+	for (i = 0; i < region->cnt; i++) {
+		base = region->regions[i].base;
+		size = region->regions[i].size;
+
+		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes\n",
+		    name, i, base, base + size - 1, size);
 	}
-	return 0;
 }
 
-int memblock_is_region_reserved(u64 base, u64 size)
+void __init_memblock memblock_dump_all(void)
 {
-	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
+	if (!memblock_debug)
+		return;
+
+	pr_info("MEMBLOCK configuration:\n");
+	pr_info(" memory size = 0x%llx\n", (unsigned long long)memblock.memory_size);
+
+	memblock_dump(&memblock.memory, "memory");
+	memblock_dump(&memblock.reserved, "reserved");
 }
 
-/*
- * Given a <base, len>, find which memory regions belong to this range.
- * Adjust the request and return a contiguous chunk.
- */
-int memblock_find(struct memblock_property *res)
+void __init memblock_analyze(void)
 {
 	int i;
-	u64 rstart, rend;
 
-	rstart = res->base;
-	rend = rstart + res->size - 1;
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
+
+	/* We allow resizing from there */
+	memblock_can_resize = 1;
+}
+
+void __init memblock_init(void)
+{
+	static int init_done __initdata = 0;
+
+	if (init_done)
+		return;
+	init_done = 1;
+
+	/* Hookup the initial arrays */
+	memblock.memory.regions	= memblock_memory_init_regions;
+	memblock.memory.max		= INIT_MEMBLOCK_REGIONS;
+	memblock.reserved.regions	= memblock_reserved_init_regions;
+	memblock.reserved.max	= INIT_MEMBLOCK_REGIONS;
+
+	/* Write a marker in the unused last array entry */
+	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+
+	/* Create a dummy zero size MEMBLOCK which will get coalesced away later.
+	 * This simplifies the memblock_add() code below...
+	 */
+	memblock.memory.regions[0].base = 0;
+	memblock.memory.regions[0].size = 0;
+	memblock.memory.cnt = 1;
+
+	/* Ditto. */
+	memblock.reserved.regions[0].base = 0;
+	memblock.reserved.regions[0].size = 0;
+	memblock.reserved.cnt = 1;
+
+	memblock.current_limit = MEMBLOCK_ALLOC_ANYWHERE;
+}
+
+static int __init early_memblock(char *p)
+{
+	if (p && strstr(p, "debug"))
+		memblock_debug = 1;
+	return 0;
+}
+early_param("memblock", early_memblock);
+
+#if defined(CONFIG_DEBUG_FS) && !defined(ARCH_DISCARD_MEMBLOCK)
+
+static int memblock_debug_show(struct seq_file *m, void *private)
+{
+	struct memblock_type *type = m->private;
+	struct memblock_region *reg;
+	int i;
+
+	for (i = 0; i < type->cnt; i++) {
+		reg = &type->regions[i];
+		seq_printf(m, "%4d: ", i);
+		if (sizeof(phys_addr_t) == 4)
+			seq_printf(m, "0x%08lx..0x%08lx\n",
+				   (unsigned long)reg->base,
+				   (unsigned long)(reg->base + reg->size - 1));
+		else
+			seq_printf(m, "0x%016llx..0x%016llx\n",
+				   (unsigned long long)reg->base,
+				   (unsigned long long)(reg->base + reg->size - 1));
 
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		u64 start = memblock.memory.region[i].base;
-		u64 end = start + memblock.memory.region[i].size - 1;
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
 	}
-	return -1;
+	return 0;
+}
+
+static int memblock_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, memblock_debug_show, inode->i_private);
 }
+
+static const struct file_operations memblock_debug_fops = {
+	.open = memblock_debug_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int __init memblock_init_debugfs(void)
+{
+	struct dentry *root = debugfs_create_dir("memblock", NULL);
+	if (!root)
+		return -ENXIO;
+	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
+	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
+
+	return 0;
+}
+__initcall(memblock_init_debugfs);
+
+#endif /* CONFIG_DEBUG_FS */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f12ad18..2a362c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -21,6 +21,7 @@
 #include <linux/pagemap.h>
 #include <linux/jiffies.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/compiler.h>
 #include <linux/kernel.h>
 #include <linux/kmemcheck.h>
@@ -3636,6 +3637,41 @@ void __init free_bootmem_with_active_regions(int nid,
 	}
 }
 
+#ifdef CONFIG_HAVE_MEMBLOCK
+u64 __init find_memory_core_early(int nid, u64 size, u64 align,
+					u64 goal, u64 limit)
+{
+	int i;
+
+	/* Need to go over early_node_map to find out good range for node */
+	for_each_active_range_index_in_nid(i, nid) {
+		u64 addr;
+		u64 ei_start, ei_last;
+		u64 final_start, final_end;
+
+		ei_last = early_node_map[i].end_pfn;
+		ei_last <<= PAGE_SHIFT;
+		ei_start = early_node_map[i].start_pfn;
+		ei_start <<= PAGE_SHIFT;
+
+		final_start = max(ei_start, goal);
+		final_end = min(ei_last, limit);
+
+		if (final_start >= final_end)
+			continue;
+
+		addr = memblock_find_in_range(final_start, final_end, size, align);
+
+		if (addr == MEMBLOCK_ERROR)
+			continue;
+
+		return addr;
+	}
+
+	return MEMBLOCK_ERROR;
+}
+#endif
+
 int __init add_from_early_node_map(struct range *range, int az,
 				   int nr_range, int nid)
 {
@@ -3655,46 +3691,26 @@ int __init add_from_early_node_map(struct range *range, int az,
 void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 					u64 goal, u64 limit)
 {
-	int i;
 	void *ptr;
+	u64 addr;
 
-	if (limit > get_max_mapped())
-		limit = get_max_mapped();
-
-	/* need to go over early_node_map to find out good range for node */
-	for_each_active_range_index_in_nid(i, nid) {
-		u64 addr;
-		u64 ei_start, ei_last;
-
-		ei_last = early_node_map[i].end_pfn;
-		ei_last <<= PAGE_SHIFT;
-		ei_start = early_node_map[i].start_pfn;
-		ei_start <<= PAGE_SHIFT;
-		addr = find_early_area(ei_start, ei_last,
-					 goal, limit, size, align);
-
-		if (addr == -1ULL)
-			continue;
+	if (limit > memblock.current_limit)
+		limit = memblock.current_limit;
 
-#if 0
-		printk(KERN_DEBUG "alloc (nid=%d %llx - %llx) (%llx - %llx) %llx %llx => %llx\n",
-				nid,
-				ei_start, ei_last, goal, limit, size,
-				align, addr);
-#endif
+	addr = find_memory_core_early(nid, size, align, goal, limit);
 
-		ptr = phys_to_virt(addr);
-		memset(ptr, 0, size);
-		reserve_early_without_check(addr, addr + size, "BOOTMEM");
-		/*
-		 * The min_count is set to 0 so that bootmem allocated blocks
-		 * are never reported as leaks.
-		 */
-		kmemleak_alloc(ptr, size, 0, 0);
-		return ptr;
-	}
+	if (addr == MEMBLOCK_ERROR)
+		return NULL;
 
-	return NULL;
+	ptr = phys_to_virt(addr);
+	memset(ptr, 0, size);
+	memblock_x86_reserve_range(addr, addr + size, "BOOTMEM");
+	/*
+	 * The min_count is set to 0 so that bootmem allocated blocks
+	 * are never reported as leaks.
+	 */
+	kmemleak_alloc(ptr, size, 0, 0);
+	return ptr;
 }
 #endif
 
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index aa33fd6..29d6cbf 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -220,18 +220,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 	if (vmemmap_buf_start) {
 		/* need to free left buf */
-#ifdef CONFIG_NO_BOOTMEM
-		free_early(__pa(vmemmap_buf_start), __pa(vmemmap_buf_end));
-		if (vmemmap_buf_start < vmemmap_buf) {
-			char name[15];
-
-			snprintf(name, sizeof(name), "MEMMAP %d", nodeid);
-			reserve_early_without_check(__pa(vmemmap_buf_start),
-						    __pa(vmemmap_buf), name);
-		}
-#else
 		free_bootmem(__pa(vmemmap_buf), vmemmap_buf_end - vmemmap_buf);
-#endif
 		vmemmap_buf = NULL;
 		vmemmap_buf_end = NULL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
