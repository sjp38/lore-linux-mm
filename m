From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070404230635.20292.81141.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/4] IA64: SPARSE_VIRTUAL 16M page size support
Date: Wed,  4 Apr 2007 16:06:35 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[IA64] Large vmemmap support

This implements granule page sized vmemmap support for IA64. This is
important because the traditional vmemmap on IA64 uses page size for
mapping the TLB. For a typical 8GB node on IA64 we need about
(33 - 14 + 6 = 25) = 32 MB of page structs.

Using page size we will end up with (25 - 14 = 11) 2048 page table entries.

This patch will reduce this to two 16MB TLBs. So its a factor
of 1000 less TLBs for the virtual memory map.

We modify the alt_dtlb_miss handler to branch to a vmemmap TLB lookup
function if bit 60 is set. The vmemmap will start with 0xF000xxx so its
going be very distinctive in dumps and can be distinguished easily from
0xE000xxx (kernel 1-1 area) and 0xA000xxx (kernel text, data and vmalloc).

We use a 1 level page table to do lookups for the vmemmap TLBs. Since
we need to cover 1 Petabyte we need to reserve 1 megabyte just for
the table but we can statically allocate it in the data segment. This
simplifies lookups and handling. The fault handler only has to do
a single lookup in contrast to 4 for the current vmalloc/vmemmap
implementation.

Problems with this patchset are:

1. Large 1M array required to cover all of possible memory (1 Petabyte).
   Maybe reduce this to actually supported HW sizes? 16TB or 64TB?

2. For systems with small nodes there is a significant chance of
   large overlaps. We could dynamically determine the TLB size
   but that would make the code more complex.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm4/arch/ia64/kernel/ivt.S
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/kernel/ivt.S	2007-04-04 15:45:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/kernel/ivt.S	2007-04-04 15:49:24.000000000 -0700
@@ -391,9 +391,11 @@ ENTRY(alt_dtlb_miss)
 	tbit.z p12,p0=r16,61			// access to region 6?
 	mov r25=PERCPU_PAGE_SHIFT << 2
 	mov r26=PERCPU_PAGE_SIZE
-	nop.m 0
-	nop.b 0
+	tbit.nz p6,p0=r16,60			// Access to VMEMMAP?
+(p6)	br.cond.dptk vmemmap
 	;;
+dtlb_continue:
+	.pred.rel "mutex", p11, p10
 (p10)	mov r19=IA64_KR(PER_CPU_DATA)
 (p11)	and r19=r19,r16				// clear non-ppn fields
 	extr.u r23=r21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
@@ -416,6 +418,37 @@ ENTRY(alt_dtlb_miss)
 (p7)	itc.d r19		// insert the TLB entry
 	mov pr=r31,-1
 	rfi
+
+vmemmap:
+	//
+	// Granule lookup via vmemmap_table for
+	// the virtual memory map.
+	//
+	tbit.nz p6,p0=r16,59			// more top bits set?
+(p6)	br.cond.spnt dtlb_continue		// then its mmu bootstrap
+	;;
+	rsm psr.dt				// switch to using physical data addressing
+	extr.u r25=r16, IA64_GRANULE_SHIFT, 32
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r26, vmemmap_table)
+	shl r25=r25,2
+	;;
+	add r26=r26,r25				// Index into vmemmap table
+	;;
+	ld4 r25=[r26]				// Get 32 bit descriptor */
+	;;
+	dep.z r19=r25, 0, 31			// Isolate ppn
+	tbit.z p6,p0=r25, 31			// Present bit set?
+(p6)	br.cond.spnt page_fault			// Page not present
+	;;
+	shl r19=r19, IA64_GRANULE_SHIFT		// Shift ppn in place
+	;;
+	or r19=r19,r17		// insert PTE control bits into r19
+	;;
+	itc.d r19		// insert the TLB entry
+	mov pr=r31,-1
+	rfi
 END(alt_dtlb_miss)
 
 	.org ia64_ivt+0x1400
Index: linux-2.6.21-rc5-mm4/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/mm/discontig.c	2007-04-04 15:45:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/mm/discontig.c	2007-04-04 15:53:02.000000000 -0700
@@ -8,6 +8,8 @@
  *	Russ Anderson <rja@sgi.com>
  *	Jesse Barnes <jbarnes@sgi.com>
  *	Jack Steiner <steiner@sgi.com>
+ * Copyright (C) 2007 sgi
+ *	Christoph Lameter <clameter@sgi.com>
  */
 
 /*
@@ -44,6 +46,79 @@ struct early_node_data {
 	unsigned long max_pfn;
 };
 
+#ifdef CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP
+
+/*
+ * The vmemmap_table contains the number of the granule used to map
+ * that section of the virtual memmap.
+ *
+ * We support 50 address bits, 14 bits are used for the page size. This
+ * leaves 36 bits (64G) for the pfn. Using page structs the memmap is going
+ * to take up a bit less than 4TB of virtual space.
+ *
+ * We are mapping these 4TB using 16M granule size which makes us end up
+ * with a bit less than 256k entries.
+ *
+ * Thus the common size of the needed vmemmap_table will be less than 1M.
+ */
+
+#define VMEMMAP_SIZE GRANULEROUNDUP((1UL << (MAX_PHYSMEM_BITS - PAGE_SHIFT)) \
+			* sizeof(struct page))
+
+/*
+ * Each vmemma_table entry describes a 16M block of memory. We have
+ * 32 bit here and use one bit to indicate that a page is present.
+ * 31 bit ppn + 24 index in the page = 55 bits which is larger than
+ * the current maximum of memory (1 Petabyte) supported by IA64.
+ */
+
+#define VMEMMAP_PRESENT (1UL << 31)
+
+u32 vmemmap_table[VMEMMAP_SIZE >> IA64_GRANULE_SHIFT];
+
+int vmemmap_populate(struct page *start, unsigned long nr, int node)
+{
+	unsigned long phys_start = __pa(start) & ~VMEMMAP_FLAG;
+	unsigned long phys_end = __pa(start + nr) & ~VMEMMAP_FLAG;
+	unsigned long addr = GRANULEROUNDDOWN(phys_start);
+	unsigned long end = GRANULEROUNDUP(phys_end);
+
+	for(; addr < end; addr += IA64_GRANULE_SIZE) {
+		u32 *vmem_pp =
+			vmemmap_table + (addr >> IA64_GRANULE_SHIFT);
+		void *block;
+
+		if (*vmem_pp & VMEMMAP_PRESENT) {
+			unsigned long addr = *vmem_pp & ~VMEMMAP_PRESENT;
+			int actual_node;
+
+			actual_node =  early_pfn_to_nid(addr >> PAGE_SHIFT);
+			if (actual_node != node)
+				printk(KERN_WARNING "Virtual memory segments on node %d instead "
+				"of %d", actual_node, node);
+
+		} else {
+
+			block = vmemmap_alloc_block(IA64_GRANULE_SIZE, node);
+			if (!block)
+				return -ENOMEM;
+
+			*vmem_pp = VMEMMAP_PRESENT |
+				(__pa(block) >> IA64_GRANULE_SHIFT);
+
+			printk(KERN_INFO "[%p-%p] page_structs=%lu "
+				"node=%d entry=%lu/%lu\n", start, block, nr, node,
+				addr >> IA64_GRANULE_SHIFT,
+				VMEMMAP_SIZE >> IA64_GRANULE_SHIFT);
+		}
+	}
+	return 0;
+}
+#else
+/* Satisfy reference in arch/ia64/kernel/ivt.S */
+u32 vmemmap_table[0];
+#endif
+
 static struct early_node_data mem_data[MAX_NUMNODES] __initdata;
 static nodemask_t memory_less_mask __initdata;
 
Index: linux-2.6.21-rc5-mm4/include/asm-ia64/page.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-ia64/page.h	2007-04-04 15:49:18.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-ia64/page.h	2007-04-04 15:49:24.000000000 -0700
@@ -106,8 +106,13 @@ extern int ia64_pfn_valid (unsigned long
 # define ia64_pfn_valid(pfn) 1
 #endif
 
+#ifdef CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP
+#define VMEMMAP_FLAG (1UL << 60)
+#define vmemmap ((struct page *)(RGN_BASE(RGN_KERNEL) | VMEMMAP_FLAG))
+#else
 #define vmemmap ((struct page *)(RGN_BASE(RGN_GATE) + \
 				(1UL << (4*PAGE_SHIFT - 10))))
+#endif
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 extern struct page *vmem_map;
Index: linux-2.6.21-rc5-mm4/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-ia64/pgtable.h	2007-04-04 15:49:18.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-ia64/pgtable.h	2007-04-04 15:49:24.000000000 -0700
@@ -236,8 +236,9 @@ ia64_phys_addr_valid (unsigned long addr
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;
 #else
-#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_SPARSE_VIRTUAL)
-/* SPARSE_VIRTUAL uses half of vmalloc... */
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_SPARSE_VIRTUAL) && \
+	!defined(CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP)
+/* Standard SPARSE_VIRTUAL uses half of vmalloc... */
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 10)))
 #else
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
Index: linux-2.6.21-rc5-mm4/arch/ia64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/Kconfig	2007-04-04 15:49:18.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/Kconfig	2007-04-04 15:49:24.000000000 -0700
@@ -330,6 +330,17 @@ config PREEMPT
           Say Y here if you are building a kernel for a desktop, embedded
           or real-time system.  Say N if you are unsure.
 
+config ARCH_POPULATES_VIRTUAL_MEMMAP
+	bool "Use 16M TLB for virtual memory map"
+	depends on SPARSE_VIRTUAL
+	help
+	  Enables large page virtual memmap support. Each virtual memmap
+	  page will be 16MB in size. That size of vmemmap can cover 4GB
+	  of memory. We only use a single TLB per node. However, if nodes
+	  are small and the distance between the memory of the nodes is
+	  < 4GB then the page struct for some of the early pages in the
+	  node may end up on the prior node.
+
 source "mm/Kconfig"
 
 config ARCH_SELECT_MEMORY_MODEL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
