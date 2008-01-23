Date: Wed, 23 Jan 2008 10:23:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080123102332.GB21455@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (23/01/08 11:04), KOSAKI Motohiro didst pronounce:
> Hi mel
> 
> > Hi 
> > 
> > > A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> > > on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> > > at the restrictions on setting NUMA on x86 to see if they could be lifted.
> > 
> > Interesting!
> > 
> > I will test tomorrow.
> 
> Hmm...
> It doesn't works on my machine.
> 
> panic at booting at __free_pages_ok() with blow call trace.
> 
> [<hex number>] free_all_bootmem_core
> [<hex number>] mem_init
> [<hex number>] alloc_large_system_hash
> [<hex number>] inode_init_early
> [<hex number>] start_kernel
> [<hex number>] unknown_bootoption
> 
> my machine spec
> 	CPU:   Pentium4 with HT
> 	MEM:   512M
> 
> I will try more investigate.
> but I have no time for a while, sorry ;-)
> 
> 
> BTW:
> when config sparse mem turn on instead discontig mem.
> panic at booting at get_pageblock_flags_group() with below call stack.
> 
> free_initrd
> 	free_init_pages
> 		free_hot_cold_page
> 
> 

And the actual patch :/

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-010_any32bit_x86/arch/x86/mm/discontig_32.c linux-2.6.24-rc8-015_remap_discontigmem/arch/x86/mm/discontig_32.c
--- linux-2.6.24-rc8-010_any32bit_x86/arch/x86/mm/discontig_32.c	2008-01-17 15:40:21.000000000 +0000
+++ linux-2.6.24-rc8-015_remap_discontigmem/arch/x86/mm/discontig_32.c	2008-01-19 15:50:47.000000000 +0000
@@ -32,6 +32,7 @@
 #include <linux/kexec.h>
 #include <linux/pfn.h>
 #include <linux/swap.h>
+#include <linux/acpi.h>
 
 #include <asm/e820.h>
 #include <asm/setup.h>
@@ -103,14 +104,10 @@ extern unsigned long highend_pfn, highst
 
 #define LARGE_PAGE_BYTES (PTRS_PER_PTE * PAGE_SIZE)
 
-static unsigned long node_remap_start_pfn[MAX_NUMNODES];
 unsigned long node_remap_size[MAX_NUMNODES];
-static unsigned long node_remap_offset[MAX_NUMNODES];
 static void *node_remap_start_vaddr[MAX_NUMNODES];
 void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
 
-static void *node_remap_end_vaddr[MAX_NUMNODES];
-static void *node_remap_alloc_vaddr[MAX_NUMNODES];
 static unsigned long kva_start_pfn;
 static unsigned long kva_pages;
 /*
@@ -167,6 +164,22 @@ static void __init allocate_pgdat(int ni
 	}
 }
 
+#ifdef CONFIG_DISCONTIGMEM
+/*
+ * In the discontig memory model, a portion of the kernel virtual area (KVA)
+ * is reserved and portions of nodes are mapped using it. This is to allow
+ * node-local memory to be allocated for structures that would normally require
+ * ZONE_NORMAL. The memory is allocated with alloc_remap() and callers
+ * should be prepared to allocate from the bootmem allocator instead. This KVA
+ * mechanism is incompatible with SPARSEMEM as it makes assumptions about the
+ * layout of memory that are broken if alloc_remap() succeeds for some of the
+ * map and fails for others
+ */
+static unsigned long node_remap_start_pfn[MAX_NUMNODES];
+static void *node_remap_end_vaddr[MAX_NUMNODES];
+static void *node_remap_alloc_vaddr[MAX_NUMNODES];
+static unsigned long node_remap_offset[MAX_NUMNODES];
+
 void *alloc_remap(int nid, unsigned long size)
 {
 	void *allocation = node_remap_alloc_vaddr[nid];
@@ -263,6 +276,40 @@ static unsigned long calculate_numa_rema
 	return reserve_pages;
 }
 
+static void init_remap_allocator(int nid)
+{
+	node_remap_start_vaddr[nid] = pfn_to_kaddr(
+			kva_start_pfn + node_remap_offset[nid]);
+	node_remap_end_vaddr[nid] = node_remap_start_vaddr[nid] +
+		(node_remap_size[nid] * PAGE_SIZE);
+	node_remap_alloc_vaddr[nid] = node_remap_start_vaddr[nid] +
+		ALIGN(sizeof(pg_data_t), PAGE_SIZE);
+
+	printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
+		(ulong) node_remap_start_vaddr[nid],
+		(ulong) pfn_to_kaddr(highstart_pfn
+		   + node_remap_offset[nid] + node_remap_size[nid]));
+}
+#else
+void *alloc_remap(int nid, unsigned long size)
+{
+	return NULL;
+}
+
+static unsigned long calculate_numa_remap_pages(void)
+{
+	return 0;
+}
+
+static void init_remap_allocator(int nid)
+{
+}
+
+void __init remap_numa_kva(void)
+{
+}
+#endif /* CONFIG_DISCONTIGMEM */
+
 extern void setup_bootmem_allocator(void);
 unsigned long __init setup_memory(void)
 {
@@ -326,19 +373,9 @@ unsigned long __init setup_memory(void)
 	printk("Low memory ends at vaddr %08lx\n",
 			(ulong) pfn_to_kaddr(max_low_pfn));
 	for_each_online_node(nid) {
-		node_remap_start_vaddr[nid] = pfn_to_kaddr(
-				kva_start_pfn + node_remap_offset[nid]);
-		/* Init the node remap allocator */
-		node_remap_end_vaddr[nid] = node_remap_start_vaddr[nid] +
-			(node_remap_size[nid] * PAGE_SIZE);
-		node_remap_alloc_vaddr[nid] = node_remap_start_vaddr[nid] +
-			ALIGN(sizeof(pg_data_t), PAGE_SIZE);
+		init_remap_allocator(nid);
 
 		allocate_pgdat(nid);
-		printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
-			(ulong) node_remap_start_vaddr[nid],
-			(ulong) pfn_to_kaddr(highstart_pfn
-			   + node_remap_offset[nid] + node_remap_size[nid]));
 	}
 	printk("High memory starts at vaddr %08lx\n",
 			(ulong) pfn_to_kaddr(highstart_pfn));
@@ -439,3 +476,29 @@ int memory_add_physaddr_to_nid(u64 addr)
 
 EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
+
+#ifndef CONFIG_HAVE_ARCH_PARSE_SRAT
+/*
+ * XXX FIXME: Make SLIT table parsing available to 32-bit NUMA
+ *
+ * These stub functions are needed to compile 32-bit NUMA when SRAT is
+ * not set. There are functions in srat_64.c for parsing this table
+ * and it may be possible to make them common functions.
+ */
+void acpi_numa_slit_init (struct acpi_table_slit *slit)
+{
+	printk(KERN_INFO "ACPI: No support for parsing SLIT table\n");
+}
+
+void acpi_numa_processor_affinity_init (struct acpi_srat_cpu_affinity *pa)
+{
+}
+
+void acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma)
+{
+}
+
+void acpi_numa_arch_fixup(void)
+{
+}
+#endif /* CONFIG_HAVE_ARCH_PARSE_SRAT */

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
