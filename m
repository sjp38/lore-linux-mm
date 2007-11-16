Date: Thu, 15 Nov 2007 19:55:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: x86_64: Make sparsemem/vmemmap the default memory model V2
In-Reply-To: <20071115185254.1177cede.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711151953500.1919@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
 <200711130059.34346.ak@suse.de> <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
 <200711130149.54852.ak@suse.de> <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com>
 <20071115141212.acb215f1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0711151824310.31691@schroedinger.engr.sgi.com>
 <20071115185254.1177cede.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, ak@suse.de, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Updated version against mainline. Looks even a bit cleaner.



x86_64: Make sparsemem/vmemmap the default memory model V2

V1->V2:
- Rediff against new upstream x86 code that unifies the Kconfig files.

Use sparsemem as the only memory model for UP, SMP and NUMA.
Measurements indicate that DISCONTIGMEM has a higher overhead
than sparsemem. And FLATMEMs benefits are minimal. So I think its
best to simply standardize on sparsemem.

Results of page allocator tests (test can be had via git from slab git
tree branch tests)

Measurements in cycle counts. 1000 allocations were performed and then the
average cycle count was calculated.

Order	FlatMem	Discontig	SparseMem
0	  639	  665		  641
1	  567	  647		  593
2	  679	  774		  692
3	  763	  967		  781
4	  961	 1501		  962
5	 1356	 2344		 1392
6	 2224	 3982		 2336
7	 4869	 7225		 5074
8	12500	14048		12732
9	27926	28223		28165
10	58578	58714		58682

(Note that FlatMem is an SMP config and the rest NUMA configurations)

Memory use:

SMP Sparsemem
-------------

Kernel size:

   text    data     bss     dec     hex filename
3849268  397739 1264856 5511863  541ab7 vmlinux

             total       used       free     shared    buffers     cached
Mem:       8242252      41164    8201088          0        352      11512
-/+ buffers/cache:      29300    8212952
Swap:      9775512          0    9775512

SMP Flatmem
-----------

Kernel size:

   text    data     bss     dec     hex filename
3844612  397739 1264536 5506887  540747 vmlinux

So 4.5k growth in text size vs. FLATMEM.

             total       used       free     shared    buffers     cached
Mem:       8244052      40544    8203508          0        352      11484
-/+ buffers/cache:      28708    8215344

2k growth in overall memory use after boot.



NUMA discontig:

   text    data     bss     dec     hex filename
3888124  470659 1276504 5635287  55fcd7 vmlinux

             total       used       free     shared    buffers     cached
Mem:       8256256      56908    8199348          0        352      11496
-/+ buffers/cache:      45060    8211196
Swap:      9775512          0    9775512

NUMA sparse:

   text    data     bss     dec     hex filename
3896428  470659 1276824 5643911  561e87 vmlinux


8k text growth. Given that we fully inline virt_to_page and friends now
that is rather good.

             total       used       free     shared    buffers     cached
Mem:       8264720      57240    8207480          0        352      11516
-/+ buffers/cache:      45372    8219348
Swap:      9775512          0    9775512

The total available memory is increased by 8k.


This patch makes sparsemem the default and removes discontig and
flatmem support from x86.

Acked-by: Andi Kleen <ak@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86/Kconfig                   |   20 +++++-------
 arch/x86/configs/x86_64_defconfig  |    9 -----
 arch/x86/kernel/machine_kexec_64.c |    5 ---
 arch/x86/mm/init_64.c              |   30 -------------------
 arch/x86/mm/ioremap_64.c           |   17 -----------
 arch/x86/mm/numa_64.c              |   21 -------------
 arch/x86/mm/srat_64.c              |   57 -------------------------------------
 include/asm-x86/mmzone_64.h        |    6 ---
 include/asm-x86/page_64.h          |    3 -
 include/asm-x86/sparsemem_64.h     |    4 --
 10 files changed, 8 insertions(+), 164 deletions(-)

Index: linux-2.6/arch/x86/configs/x86_64_defconfig
===================================================================
--- linux-2.6.orig/arch/x86/configs/x86_64_defconfig	2007-11-13 11:52:34.785633363 -0800
+++ linux-2.6/arch/x86/configs/x86_64_defconfig	2007-11-15 19:39:59.073745644 -0800
@@ -145,15 +145,6 @@ CONFIG_K8_NUMA=y
 CONFIG_NODES_SHIFT=6
 CONFIG_X86_64_ACPI_NUMA=y
 CONFIG_NUMA_EMU=y
-CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
-CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
-CONFIG_ARCH_SPARSEMEM_ENABLE=y
-CONFIG_SELECT_MEMORY_MODEL=y
-# CONFIG_FLATMEM_MANUAL is not set
-CONFIG_DISCONTIGMEM_MANUAL=y
-# CONFIG_SPARSEMEM_MANUAL is not set
-CONFIG_DISCONTIGMEM=y
-CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_NEED_MULTIPLE_NODES=y
 # CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_SPLIT_PTLOCK_CPUS=4
Index: linux-2.6/arch/x86/kernel/machine_kexec_64.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/machine_kexec_64.c	2007-11-13 11:52:34.793633597 -0800
+++ linux-2.6/arch/x86/kernel/machine_kexec_64.c	2007-11-15 19:39:59.126128308 -0800
@@ -234,10 +234,5 @@ NORET_TYPE void machine_kexec(struct kim
 void arch_crash_save_vmcoreinfo(void)
 {
 	VMCOREINFO_SYMBOL(init_level4_pgt);
-
-#ifdef CONFIG_ARCH_DISCONTIGMEM_ENABLE
-	VMCOREINFO_SYMBOL(node_data);
-	VMCOREINFO_LENGTH(node_data, MAX_NUMNODES);
-#endif
 }
 
Index: linux-2.6/arch/x86/mm/ioremap_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/ioremap_64.c	2007-11-13 11:52:34.801633088 -0800
+++ linux-2.6/arch/x86/mm/ioremap_64.c	2007-11-15 19:39:59.149995698 -0800
@@ -86,23 +86,6 @@ void __iomem * __ioremap(unsigned long p
 	if (phys_addr >= ISA_START_ADDRESS && last_addr < ISA_END_ADDRESS)
 		return (__force void __iomem *)phys_to_virt(phys_addr);
 
-#ifdef CONFIG_FLATMEM
-	/*
-	 * Don't allow anybody to remap normal RAM that we're using..
-	 */
-	if (last_addr < virt_to_phys(high_memory)) {
-		char *t_addr, *t_end;
- 		struct page *page;
-
-		t_addr = __va(phys_addr);
-		t_end = t_addr + (size - 1);
-	   
-		for(page = virt_to_page(t_addr); page <= virt_to_page(t_end); page++)
-			if(!PageReserved(page))
-				return NULL;
-	}
-#endif
-
 	pgprot = __pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_GLOBAL
 			  | _PAGE_DIRTY | _PAGE_ACCESSED | flags);
 	/*
Index: linux-2.6/arch/x86/mm/numa_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/numa_64.c	2007-11-13 11:52:34.805632772 -0800
+++ linux-2.6/arch/x86/mm/numa_64.c	2007-11-15 19:39:59.157245106 -0800
@@ -149,12 +149,10 @@ int __init compute_hash_shift(struct boo
 	return shift;
 }
 
-#ifdef CONFIG_SPARSEMEM
 int early_pfn_to_nid(unsigned long pfn)
 {
 	return phys_to_nid(pfn << PAGE_SHIFT);
 }
-#endif
 
 static void * __init
 early_node_mem(int nodeid, unsigned long start, unsigned long end,
@@ -626,23 +624,4 @@ EXPORT_SYMBOL(node_to_cpumask);
 EXPORT_SYMBOL(memnode);
 EXPORT_SYMBOL(node_data);
 
-#ifdef CONFIG_DISCONTIGMEM
-/*
- * Functions to convert PFNs from/to per node page addresses.
- * These are out of line because they are quite big.
- * They could be all tuned by pre caching more state.
- * Should do that.
- */
 
-int pfn_valid(unsigned long pfn)
-{
-	unsigned nid;
-	if (pfn >= num_physpages)
-		return 0;
-	nid = pfn_to_nid(pfn);
-	if (nid == 0xff)
-		return 0;
-	return pfn >= node_start_pfn(nid) && (pfn) < node_end_pfn(nid);
-}
-EXPORT_SYMBOL(pfn_valid);
-#endif
Index: linux-2.6/include/asm-x86/mmzone_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/mmzone_64.h	2007-11-13 11:52:34.825632852 -0800
+++ linux-2.6/include/asm-x86/mmzone_64.h	2007-11-15 19:39:59.173245524 -0800
@@ -41,12 +41,6 @@ static inline __attribute__((pure)) int 
 #define node_end_pfn(nid)       (NODE_DATA(nid)->node_start_pfn + \
 				 NODE_DATA(nid)->node_spanned_pages)
 
-#ifdef CONFIG_DISCONTIGMEM
-#define pfn_to_nid(pfn) phys_to_nid((unsigned long)(pfn) << PAGE_SHIFT)
-
-extern int pfn_valid(unsigned long pfn);
-#endif
-
 #ifdef CONFIG_NUMA_EMU
 #define FAKE_NODE_MIN_SIZE	(64*1024*1024)
 #define FAKE_NODE_MIN_HASH_MASK	(~(FAKE_NODE_MIN_SIZE - 1uL))
Index: linux-2.6/include/asm-x86/page_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/page_64.h	2007-11-13 11:52:34.833632806 -0800
+++ linux-2.6/include/asm-x86/page_64.h	2007-11-15 19:39:59.216745079 -0800
@@ -121,9 +121,6 @@ extern unsigned long __phys_addr(unsigne
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
 #define __boot_va(x)		__va(x)
 #define __boot_pa(x)		__pa(x)
-#ifdef CONFIG_FLATMEM
-#define pfn_valid(pfn)		((pfn) < end_pfn)
-#endif
 
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
Index: linux-2.6/arch/x86/mm/init_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/init_64.c	2007-11-15 12:19:14.820392365 -0800
+++ linux-2.6/arch/x86/mm/init_64.c	2007-11-15 19:39:59.228495304 -0800
@@ -484,34 +484,6 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to
 
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
-#ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
-/*
- * Memory Hotadd without sparsemem. The mem_maps have been allocated in advance,
- * just online the pages.
- */
-int __add_pages(struct zone *z, unsigned long start_pfn, unsigned long nr_pages)
-{
-	int err = -EIO;
-	unsigned long pfn;
-	unsigned long total = 0, mem = 0;
-	for (pfn = start_pfn; pfn < start_pfn + nr_pages; pfn++) {
-		if (pfn_valid(pfn)) {
-			online_page(pfn_to_page(pfn));
-			err = 0;
-			mem++;
-		}
-		total++;
-	}
-	if (!err) {
-		z->spanned_pages += total;
-		z->present_pages += mem;
-		z->zone_pgdat->node_spanned_pages += total;
-		z->zone_pgdat->node_present_pages += mem;
-	}
-	return err;
-}
-#endif
-
 static struct kcore_list kcore_mem, kcore_vmalloc, kcore_kernel, kcore_modules,
 			 kcore_vsyscall;
 
@@ -737,7 +709,6 @@ const char *arch_vma_name(struct vm_area
 	return NULL;
 }
 
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
  */
@@ -780,4 +751,3 @@ int __meminit vmemmap_populate(struct pa
 
 	return 0;
 }
-#endif
Index: linux-2.6/arch/x86/mm/srat_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/srat_64.c	2007-11-13 11:52:34.821633366 -0800
+++ linux-2.6/arch/x86/mm/srat_64.c	2007-11-15 19:39:59.228495304 -0800
@@ -151,62 +151,6 @@ acpi_numa_processor_affinity_init(struct
 	       pxm, pa->apic_id, node);
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
-/*
- * Protect against too large hotadd areas that would fill up memory.
- */
-static int hotadd_enough_memory(struct bootnode *nd)
-{
-	static unsigned long allocated;
-	static unsigned long last_area_end;
-	unsigned long pages = (nd->end - nd->start) >> PAGE_SHIFT;
-	long mem = pages * sizeof(struct page);
-	unsigned long addr;
-	unsigned long allowed;
-	unsigned long oldpages = pages;
-
-	if (mem < 0)
-		return 0;
-	allowed = (end_pfn - absent_pages_in_range(0, end_pfn)) * PAGE_SIZE;
-	allowed = (allowed / 100) * hotadd_percent;
-	if (allocated + mem > allowed) {
-		unsigned long range;
-		/* Give them at least part of their hotadd memory upto hotadd_percent
-		   It would be better to spread the limit out
-		   over multiple hotplug areas, but that is too complicated
-		   right now */
-		if (allocated >= allowed)
-			return 0;
-		range = allowed - allocated;
-		pages = (range / PAGE_SIZE);
-		mem = pages * sizeof(struct page);
-		nd->end = nd->start + range;
-	}
-	/* Not completely fool proof, but a good sanity check */
-	addr = find_e820_area(last_area_end, end_pfn<<PAGE_SHIFT, mem);
-	if (addr == -1UL)
-		return 0;
-	if (pages != oldpages)
-		printk(KERN_NOTICE "SRAT: Hotadd area limited to %lu bytes\n",
-			pages << PAGE_SHIFT);
-	last_area_end = addr + mem;
-	allocated += mem;
-	return 1;
-}
-
-static int update_end_of_memory(unsigned long end)
-{
-	found_add_area = 1;
-	if ((end >> PAGE_SHIFT) > end_pfn)
-		end_pfn = end >> PAGE_SHIFT;
-	return 1;
-}
-
-static inline int save_add_info(void)
-{
-	return hotadd_percent > 0;
-}
-#else
 int update_end_of_memory(unsigned long end) {return -1;}
 static int hotadd_enough_memory(struct bootnode *nd) {return 1;}
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
@@ -214,7 +158,6 @@ static inline int save_add_info(void) {r
 #else
 static inline int save_add_info(void) {return 0;}
 #endif
-#endif
 /*
  * Update nodes_add and decide if to include add are in the zone.
  * Both SPARSE and RESERVE need nodes_add infomation.
Index: linux-2.6/arch/x86/Kconfig
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig	2007-11-15 12:19:41.950157617 -0800
+++ linux-2.6/arch/x86/Kconfig	2007-11-15 19:39:59.240495606 -0800
@@ -889,19 +889,23 @@ config HAVE_ARCH_ALLOC_REMAP
 
 config ARCH_FLATMEM_ENABLE
 	def_bool y
-	depends on (X86_32 && ARCH_SELECT_MEMORY_MODEL && X86_PC) || (X86_64 && !NUMA)
+	depends on X86_32 && ARCH_SELECT_MEMORY_MODEL && X86_PC
 
 config ARCH_DISCONTIGMEM_ENABLE
 	def_bool y
-	depends on NUMA
+	depends on NUMA && X86_32
 
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y
-	depends on NUMA
+	depends on NUMA && X86_32
+
+config ARCH_SPARSEMEM_DEFAULT
+	def_bool y
+	depends on X86_64
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-	depends on NUMA || (EXPERIMENTAL && (X86_PC || X86_64))
+	depends on X86_64 || NUMA || (EXPERIMENTAL && X86_PC)
 	select SPARSEMEM_STATIC if X86_32
 	select SPARSEMEM_VMEMMAP_ENABLE if X86_64
 
@@ -1205,18 +1209,10 @@ config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)
 
-config MEMORY_HOTPLUG_RESERVE
-	def_bool X86_64
-	depends on (MEMORY_HOTPLUG && DISCONTIGMEM)
-
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool X86_64
 	depends on NUMA
 
-config OUT_OF_LINE_PFN_TO_PAGE
-	def_bool X86_64
-	depends on DISCONTIGMEM
-
 menu "Power management options"
 	depends on !X86_VOYAGER
 
Index: linux-2.6/include/asm-x86/sparsemem_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/sparsemem_64.h	2007-11-15 19:50:25.169427205 -0800
+++ linux-2.6/include/asm-x86/sparsemem_64.h	2007-11-15 19:50:32.165046504 -0800
@@ -1,8 +1,6 @@
 #ifndef _ASM_X86_64_SPARSEMEM_H
 #define _ASM_X86_64_SPARSEMEM_H 1
 
-#ifdef CONFIG_SPARSEMEM
-
 /*
  * generic non-linear memory support:
  *
@@ -21,6 +19,4 @@
 
 extern int early_pfn_to_nid(unsigned long pfn);
 
-#endif /* CONFIG_SPARSEMEM */
-
 #endif /* _ASM_X86_64_SPARSEMEM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
