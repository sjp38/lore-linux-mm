Date: Sat, 19 Jan 2008 16:07:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080119160743.GA8352@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <p73hcha9vc5.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <p73hcha9vc5.fsf@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (19/01/08 07:35), Andi Kleen didst pronounce:
> Mel Gorman <mel@csn.ul.ie> writes:
> 
> > A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> > on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> > at the restrictions on setting NUMA on x86 to see if they could be lifted.
> 
> The problem with i386 CONFIG_NUMA previously was not that it didn't
> boot on normal non NUMA systems, but that it didn't boot on very
> common NUMA systems: Opterons.  Have you tested if that is fixed now?
> 

No, I hadn't but I can imagine how such an odd situation would occur for
distribution kernels even if it's a bit of a waste of hardware. I tested
this situation on a 4-node NUMA Opteron box. It didn't work very well based
on a few problems.

- alloc_remap() and SPARSEMEM on HIGHMEM4G explodes [1]
- Without SRAT, there is a build failure 
- Enabling SRAT requires BOOT_IOREMAP and it explodes early in boot

I have one fix for items 1 and 2 with the patch below. It probably should
be split in two but lets see if we want to pursue alternative fixes to this
problem first. In particular, this patch stops SPARSEMEM using alloc_remap()
because not enough memory is set aside. An alternative solution may be to
reserve more for alloc_remap() when SPARSEMEM is in use. 

With the patch applied, an x86-64 capable NUMA Opteron box will boot a 32
bit NUMA enabled kernel with DISCONTIGMEM or SPARSEMEM. Due to the lack of
SRAT parsing, there is only node 0 of course.

Based on this, I have no doubt there is going to be a series of broken boots
while stuff like this gets rattled out. For the moment, NUMA on x86
32-bit should remain CONFIG_EXPERIMENTAL.

[1] It happens to work on HIGHMEM64G and I'm guessing it's because
    alloc_remap() never succeeds although I did not verify that guess. I
    suspect there are a few more HIGHMEM4G oddities to rattle out and I
    didn't even try NOHIGHMEM.

=====

Subject: Fix boot-problems related to x86 32 bit with CONFIG_NUMA

The DISCONTIG memory model on x86 32 bit uses a remap allocator early
in boot. The objective is that portions of every node are mapped in to
the kernel virtual area (KVA) in place of ZONE_NORMAL so that node-local
allocations can be made for pgdat and mem_map structures.

With SPARSEMEM, the amount that is set aside is insufficient for all the
mem_maps to be allocated. During the boot process, it falls back to using
the bootmem allocator. This breaks assumptions that SPARSEMEM makes about
the layout of the mem_map in memory and results in a VM_BUG_ON triggering
due to pfn_to_page() returning garbage values.

This patch only enables the remap allocator for use with DISCONTIG.

Without SRAT support, a compile-error occurs because ACPI table parsing
functions are only available in x86-64. This patch also adds no-op stubs
and prints a warning message. What likely needs to be done is sharing
the table parsing functions between 32 and 64 bit if they are
compatible.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---

 arch/x86/mm/discontig_32.c |   93 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 78 insertions(+), 15 deletions(-)

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
+static inline void acpi_numa_slit_init (struct acpi_table_slit *slit)
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
