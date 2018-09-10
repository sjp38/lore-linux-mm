Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E31748E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:23:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m197-v6so25985589oig.18
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 02:23:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h133-v6si10167854oif.446.2018.09.10.02.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 02:23:32 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8A9JpX0063301
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:23:30 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mdnmqrrp6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:23:30 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 10 Sep 2018 10:23:27 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2] mips: switch to NO_BOOTMEM
Date: Mon, 10 Sep 2018 12:23:18 +0300
Message-Id: <1536571398-29194-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@mips.com>
Cc: Serge Semin <fancer.lancer@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

MIPS already has memblock support and all the memory is already registered
with it.

This patch replaces bootmem memory reservations with memblock ones and
removes the bootmem initialization.

Since memblock allocates memory in top-down mode, we ensure that memblock
limit is max_low_pfn to prevent allocations from the high memory.

To have the exceptions base in the lower 512M of the physical memory, its
allocation in arch/mips/kernel/traps.c::traps_init() is using bottom-up
mode.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
v2:
* set memblock limit to max_low_pfn to avoid allocation attempts from high
memory
* use boottom-up mode for allocation of the exceptions base

Build tested with *_defconfig.
Boot tested with qemu-system-mips64el for 32r6el, 64r6el and fuloong2e
defconfigs.
Boot tested with qemu-system-mipsel for malta defconfig.

 arch/mips/Kconfig                      |  1 +
 arch/mips/kernel/setup.c               | 99 ++++++++--------------------------
 arch/mips/kernel/traps.c               |  3 ++
 arch/mips/loongson64/loongson-3/numa.c | 34 ++++++------
 arch/mips/sgi-ip27/ip27-memory.c       | 11 ++--
 5 files changed, 46 insertions(+), 102 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 3551199..b8c5fea 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -78,6 +78,7 @@ config MIPS
 	select RTC_LIB if !MACH_LOONGSON64
 	select SYSCTL_EXCEPTION_TRACE
 	select VIRT_TO_BUS
+	select NO_BOOTMEM
 
 menu "Machine selection"
 
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index c71d1eb..0b728b7 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -333,7 +333,7 @@ static void __init finalize_initrd(void)
 
 	maybe_bswap_initrd();
 
-	reserve_bootmem(__pa(initrd_start), size, BOOTMEM_DEFAULT);
+	memblock_reserve(__pa(initrd_start), size);
 	initrd_below_start_ok = 1;
 
 	pr_info("Initial ramdisk at: 0x%lx (%lu bytes)\n",
@@ -370,20 +370,10 @@ static void __init bootmem_init(void)
 
 #else  /* !CONFIG_SGI_IP27 */
 
-static unsigned long __init bootmap_bytes(unsigned long pages)
-{
-	unsigned long bytes = DIV_ROUND_UP(pages, 8);
-
-	return ALIGN(bytes, sizeof(long));
-}
-
 static void __init bootmem_init(void)
 {
 	unsigned long reserved_end;
-	unsigned long mapstart = ~0UL;
-	unsigned long bootmap_size;
 	phys_addr_t ramstart = PHYS_ADDR_MAX;
-	bool bootmap_valid = false;
 	int i;
 
 	/*
@@ -395,6 +385,8 @@ static void __init bootmem_init(void)
 	init_initrd();
 	reserved_end = (unsigned long) PFN_UP(__pa_symbol(&_end));
 
+	memblock_reserve(PHYS_OFFSET, reserved_end << PAGE_SHIFT);
+
 	/*
 	 * max_low_pfn is not a number of pages. The number of pages
 	 * of the system is given by 'max_low_pfn - min_low_pfn'.
@@ -442,9 +434,6 @@ static void __init bootmem_init(void)
 		if (initrd_end && end <= (unsigned long)PFN_UP(__pa(initrd_end)))
 			continue;
 #endif
-		if (start >= mapstart)
-			continue;
-		mapstart = max(reserved_end, start);
 	}
 
 	if (min_low_pfn >= max_low_pfn)
@@ -456,9 +445,11 @@ static void __init bootmem_init(void)
 	/*
 	 * Reserve any memory between the start of RAM and PHYS_OFFSET
 	 */
-	if (ramstart > PHYS_OFFSET)
+	if (ramstart > PHYS_OFFSET) {
 		add_memory_region(PHYS_OFFSET, ramstart - PHYS_OFFSET,
 				  BOOT_MEM_RESERVED);
+		memblock_reserve(PHYS_OFFSET, ramstart - PHYS_OFFSET);
+	}
 
 	if (min_low_pfn > ARCH_PFN_OFFSET) {
 		pr_info("Wasting %lu bytes for tracking %lu unused pages\n",
@@ -483,52 +474,6 @@ static void __init bootmem_init(void)
 		max_low_pfn = PFN_DOWN(HIGHMEM_START);
 	}
 
-#ifdef CONFIG_BLK_DEV_INITRD
-	/*
-	 * mapstart should be after initrd_end
-	 */
-	if (initrd_end)
-		mapstart = max(mapstart, (unsigned long)PFN_UP(__pa(initrd_end)));
-#endif
-
-	/*
-	 * check that mapstart doesn't overlap with any of
-	 * memory regions that have been reserved through eg. DTB
-	 */
-	bootmap_size = bootmap_bytes(max_low_pfn - min_low_pfn);
-
-	bootmap_valid = memory_region_available(PFN_PHYS(mapstart),
-						bootmap_size);
-	for (i = 0; i < boot_mem_map.nr_map && !bootmap_valid; i++) {
-		unsigned long mapstart_addr;
-
-		switch (boot_mem_map.map[i].type) {
-		case BOOT_MEM_RESERVED:
-			mapstart_addr = PFN_ALIGN(boot_mem_map.map[i].addr +
-						boot_mem_map.map[i].size);
-			if (PHYS_PFN(mapstart_addr) < mapstart)
-				break;
-
-			bootmap_valid = memory_region_available(mapstart_addr,
-								bootmap_size);
-			if (bootmap_valid)
-				mapstart = PHYS_PFN(mapstart_addr);
-			break;
-		default:
-			break;
-		}
-	}
-
-	if (!bootmap_valid)
-		panic("No memory area to place a bootmap bitmap");
-
-	/*
-	 * Initialize the boot-time allocator with low memory only.
-	 */
-	if (bootmap_size != init_bootmem_node(NODE_DATA(0), mapstart,
-					 min_low_pfn, max_low_pfn))
-		panic("Unexpected memory size required for bootmap");
-
 	for (i = 0; i < boot_mem_map.nr_map; i++) {
 		unsigned long start, end;
 
@@ -577,9 +522,9 @@ static void __init bootmem_init(void)
 		default:
 			/* Not usable memory */
 			if (start > min_low_pfn && end < max_low_pfn)
-				reserve_bootmem(boot_mem_map.map[i].addr,
-						boot_mem_map.map[i].size,
-						BOOTMEM_DEFAULT);
+				memblock_reserve(boot_mem_map.map[i].addr,
+						boot_mem_map.map[i].size);
+
 			continue;
 		}
 
@@ -602,15 +547,9 @@ static void __init bootmem_init(void)
 		size = end - start;
 
 		/* Register lowmem ranges */
-		free_bootmem(PFN_PHYS(start), size << PAGE_SHIFT);
 		memory_present(0, start, end);
 	}
 
-	/*
-	 * Reserve the bootmap memory.
-	 */
-	reserve_bootmem(PFN_PHYS(mapstart), bootmap_size, BOOTMEM_DEFAULT);
-
 #ifdef CONFIG_RELOCATABLE
 	/*
 	 * The kernel reserves all memory below its _end symbol as bootmem,
@@ -908,21 +847,29 @@ static void __init arch_mem_init(char **cmdline_p)
 	early_init_fdt_scan_reserved_mem();
 
 	bootmem_init();
+
+	/*
+	 * Prevent memblock from allocating high memory.
+	 * This cannot be done before max_low_pfn is detected, so up
+	 * to this point is possible to only reserve physical memory
+	 * with memblock_reserve; memblock_virt_alloc* can be used
+	 * only after this point
+	 */
+	memblock_set_current_limit(PFN_PHYS(max_low_pfn));
+
 #ifdef CONFIG_PROC_VMCORE
 	if (setup_elfcorehdr && setup_elfcorehdr_size) {
 		printk(KERN_INFO "kdump reserved memory at %lx-%lx\n",
 		       setup_elfcorehdr, setup_elfcorehdr_size);
-		reserve_bootmem(setup_elfcorehdr, setup_elfcorehdr_size,
-				BOOTMEM_DEFAULT);
+		memblock_reserve(setup_elfcorehdr, setup_elfcorehdr_size);
 	}
 #endif
 
 	mips_parse_crashkernel();
 #ifdef CONFIG_KEXEC
 	if (crashk_res.start != crashk_res.end)
-		reserve_bootmem(crashk_res.start,
-				crashk_res.end - crashk_res.start + 1,
-				BOOTMEM_DEFAULT);
+		memblock_reserve(crashk_res.start,
+				 crashk_res.end - crashk_res.start + 1);
 #endif
 	device_tree_init();
 	sparse_init();
@@ -932,7 +879,7 @@ static void __init arch_mem_init(char **cmdline_p)
 	/* Tell bootmem about cma reserved memblock section */
 	for_each_memblock(reserved, reg)
 		if (reg->size != 0)
-			reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
+			memblock_reserve(reg->base, reg->size);
 
 	reserve_bootmem_region(__pa_symbol(&__nosave_begin),
 			__pa_symbol(&__nosave_end)); /* Reserve for hibernation */
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 9dab0ed..05270d0 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -29,6 +29,7 @@
 #include <linux/spinlock.h>
 #include <linux/kallsyms.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/interrupt.h>
 #include <linux/ptrace.h>
 #include <linux/kgdb.h>
@@ -2260,8 +2261,10 @@ void __init trap_init(void)
 		unsigned long size = 0x200 + VECTORSPACING*64;
 		phys_addr_t ebase_pa;
 
+		memblock_set_bottom_up(true);
 		ebase = (unsigned long)
 			__alloc_bootmem(size, 1 << fls(size), 0);
+		memblock_set_bottom_up(false);
 
 		/*
 		 * Try to ensure ebase resides in KSeg0 if possible.
diff --git a/arch/mips/loongson64/loongson-3/numa.c b/arch/mips/loongson64/loongson-3/numa.c
index 9717106..c1e6ec5 100644
--- a/arch/mips/loongson64/loongson-3/numa.c
+++ b/arch/mips/loongson64/loongson-3/numa.c
@@ -180,43 +180,39 @@ static void __init szmem(unsigned int node)
 
 static void __init node_mem_init(unsigned int node)
 {
-	unsigned long bootmap_size;
 	unsigned long node_addrspace_offset;
-	unsigned long start_pfn, end_pfn, freepfn;
+	unsigned long start_pfn, end_pfn;
 
 	node_addrspace_offset = nid_to_addroffset(node);
 	pr_info("Node%d's addrspace_offset is 0x%lx\n",
 			node, node_addrspace_offset);
 
 	get_pfn_range_for_nid(node, &start_pfn, &end_pfn);
-	freepfn = start_pfn;
-	if (node == 0)
-		freepfn = PFN_UP(__pa_symbol(&_end)); /* kernel end address */
-	pr_info("Node%d: start_pfn=0x%lx, end_pfn=0x%lx, freepfn=0x%lx\n",
-		node, start_pfn, end_pfn, freepfn);
+	pr_info("Node%d: start_pfn=0x%lx, end_pfn=0x%lx\n",
+		node, start_pfn, end_pfn);
 
 	__node_data[node] = prealloc__node_data + node;
 
-	NODE_DATA(node)->bdata = &bootmem_node_data[node];
 	NODE_DATA(node)->node_start_pfn = start_pfn;
 	NODE_DATA(node)->node_spanned_pages = end_pfn - start_pfn;
 
-	bootmap_size = init_bootmem_node(NODE_DATA(node), freepfn,
-					start_pfn, end_pfn);
 	free_bootmem_with_active_regions(node, end_pfn);
-	if (node == 0) /* used by finalize_initrd() */
+
+	if (node == 0) {
+		/* kernel end address */
+		unsigned long kernel_end_pfn = PFN_UP(__pa_symbol(&_end));
+
+		/* used by finalize_initrd() */
 		max_low_pfn = end_pfn;
 
-	/* This is reserved for the kernel and bdata->node_bootmem_map */
-	reserve_bootmem_node(NODE_DATA(node), start_pfn << PAGE_SHIFT,
-		((freepfn - start_pfn) << PAGE_SHIFT) + bootmap_size,
-		BOOTMEM_DEFAULT);
+		/* Reserve the kernel text/data/bss */
+		memblock_reserve(start_pfn << PAGE_SHIFT,
+				 ((kernel_end_pfn - start_pfn) << PAGE_SHIFT));
 
-	if (node == 0 && node_end_pfn(0) >= (0xffffffff >> PAGE_SHIFT)) {
 		/* Reserve 0xfe000000~0xffffffff for RS780E integrated GPU */
-		reserve_bootmem_node(NODE_DATA(node),
-				(node_addrspace_offset | 0xfe000000),
-				32 << 20, BOOTMEM_DEFAULT);
+		if (node_end_pfn(0) >= (0xffffffff >> PAGE_SHIFT))
+			memblock_reserve((node_addrspace_offset | 0xfe000000),
+					 32 << 20);
 	}
 
 	sparse_memory_present_with_active_regions(node);
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index 59133d0a..6f7bef0 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -389,7 +389,6 @@ static void __init node_mem_init(cnodeid_t node)
 {
 	unsigned long slot_firstpfn = slot_getbasepfn(node, 0);
 	unsigned long slot_freepfn = node_getfirstfree(node);
-	unsigned long bootmap_size;
 	unsigned long start_pfn, end_pfn;
 
 	get_pfn_range_for_nid(node, &start_pfn, &end_pfn);
@@ -400,7 +399,6 @@ static void __init node_mem_init(cnodeid_t node)
 	__node_data[node] = __va(slot_freepfn << PAGE_SHIFT);
 	memset(__node_data[node], 0, PAGE_SIZE);
 
-	NODE_DATA(node)->bdata = &bootmem_node_data[node];
 	NODE_DATA(node)->node_start_pfn = start_pfn;
 	NODE_DATA(node)->node_spanned_pages = end_pfn - start_pfn;
 
@@ -409,12 +407,11 @@ static void __init node_mem_init(cnodeid_t node)
 	slot_freepfn += PFN_UP(sizeof(struct pglist_data) +
 			       sizeof(struct hub_data));
 
-	bootmap_size = init_bootmem_node(NODE_DATA(node), slot_freepfn,
-					start_pfn, end_pfn);
 	free_bootmem_with_active_regions(node, end_pfn);
-	reserve_bootmem_node(NODE_DATA(node), slot_firstpfn << PAGE_SHIFT,
-		((slot_freepfn - slot_firstpfn) << PAGE_SHIFT) + bootmap_size,
-		BOOTMEM_DEFAULT);
+
+	memblock_reserve(slot_firstpfn << PAGE_SHIFT,
+			 ((slot_freepfn - slot_firstpfn) << PAGE_SHIFT));
+
 	sparse_memory_present_with_active_regions(node);
 }
 
-- 
2.7.4
