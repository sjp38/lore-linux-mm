Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id DEF676B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:56:30 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 17:56:30 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8DF4D19D8043
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 17:56:27 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0V0uR0r362170
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 17:56:27 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0V0uHta023908
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 17:56:17 -0700
Subject: [RFC][PATCH] rip out x86_32 NUMA remapping code
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 16:56:16 -0800
Message-Id: <20130131005616.1C79F411@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>


This code was an optimization for 32-bit NUMA systems.

It has probably been the cause of a number of subtle bugs over
the years, although the conditions to excite them would have
been hard to trigger.  Essentially, we remap part of the kernel
linear mapping area, and then sometimes part of that area gets
freed back in to the bootmem allocator.  If those pages get
used by kernel data structures (say mem_map[] or a dentry),
there's no big deal.  But, if anyone ever tried to use the
linear mapping for these pages _and_ cared about their physical
address, bad things happen.

For instance, say you passed __GFP_ZERO to the page allocator
and then happened to get handed one of these pages, it zero the
remapped page, but it would make a pte to the _old_ page.
There are probably a hundred other ways that it could screw
with things.

We don't need to hang on to performance optimizations for
these old boxes any more.  All my 32-bit NUMA systems are long
dead and buried, and I probably had access to more than most
people.

This code is causing real things to break today:

	https://lkml.org/lkml/2013/1/9/376

I looked in to actually fixing this, but it requires surgery
to way too much brittle code, as well as stuff like
per_cpu_ptr_to_phys().


---

 linux-2.6.git-dave/arch/x86/Kconfig            |    4 
 linux-2.6.git-dave/arch/x86/mm/numa.c          |    3 
 linux-2.6.git-dave/arch/x86/mm/numa_32.c       |  161 -------------------------
 linux-2.6.git-dave/arch/x86/mm/numa_internal.h |    6 
 4 files changed, 174 deletions(-)

diff -puN arch/x86/Kconfig~rip-out-i386-NUMA-remapping-code arch/x86/Kconfig
--- linux-2.6.git/arch/x86/Kconfig~rip-out-i386-NUMA-remapping-code	2013-01-30 16:25:36.792338332 -0800
+++ linux-2.6.git-dave/arch/x86/Kconfig	2013-01-30 16:25:36.800338399 -0800
@@ -1253,10 +1253,6 @@ config NODES_SHIFT
 	  Specify the maximum number of NUMA Nodes available on the target
 	  system.  Increases memory reserved to accommodate various tables.
 
-config HAVE_ARCH_ALLOC_REMAP
-	def_bool y
-	depends on X86_32 && NUMA
-
 config ARCH_HAVE_MEMORY_PRESENT
 	def_bool y
 	depends on X86_32 && DISCONTIGMEM
diff -puN arch/x86/mm/numa_32.c~rip-out-i386-NUMA-remapping-code arch/x86/mm/numa_32.c
--- linux-2.6.git/arch/x86/mm/numa_32.c~rip-out-i386-NUMA-remapping-code	2013-01-30 16:25:36.796338365 -0800
+++ linux-2.6.git-dave/arch/x86/mm/numa_32.c	2013-01-30 16:25:36.800338399 -0800
@@ -73,167 +73,6 @@ unsigned long node_memmap_size_bytes(int
 
 extern unsigned long highend_pfn, highstart_pfn;
 
-#define LARGE_PAGE_BYTES (PTRS_PER_PTE * PAGE_SIZE)
-
-static void *node_remap_start_vaddr[MAX_NUMNODES];
-void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
-
-/*
- * Remap memory allocator
- */
-static unsigned long node_remap_start_pfn[MAX_NUMNODES];
-static void *node_remap_end_vaddr[MAX_NUMNODES];
-static void *node_remap_alloc_vaddr[MAX_NUMNODES];
-
-/**
- * alloc_remap - Allocate remapped memory
- * @nid: NUMA node to allocate memory from
- * @size: The size of allocation
- *
- * Allocate @size bytes from the remap area of NUMA node @nid.  The
- * size of the remap area is predetermined by init_alloc_remap() and
- * only the callers considered there should call this function.  For
- * more info, please read the comment on top of init_alloc_remap().
- *
- * The caller must be ready to handle allocation failure from this
- * function and fall back to regular memory allocator in such cases.
- *
- * CONTEXT:
- * Single CPU early boot context.
- *
- * RETURNS:
- * Pointer to the allocated memory on success, %NULL on failure.
- */
-void *alloc_remap(int nid, unsigned long size)
-{
-	void *allocation = node_remap_alloc_vaddr[nid];
-
-	size = ALIGN(size, L1_CACHE_BYTES);
-
-	if (!allocation || (allocation + size) > node_remap_end_vaddr[nid])
-		return NULL;
-
-	node_remap_alloc_vaddr[nid] += size;
-	memset(allocation, 0, size);
-
-	return allocation;
-}
-
-#ifdef CONFIG_HIBERNATION
-/**
- * resume_map_numa_kva - add KVA mapping to the temporary page tables created
- *                       during resume from hibernation
- * @pgd_base - temporary resume page directory
- */
-void resume_map_numa_kva(pgd_t *pgd_base)
-{
-	int node;
-
-	for_each_online_node(node) {
-		unsigned long start_va, start_pfn, nr_pages, pfn;
-
-		start_va = (unsigned long)node_remap_start_vaddr[node];
-		start_pfn = node_remap_start_pfn[node];
-		nr_pages = (node_remap_end_vaddr[node] -
-			    node_remap_start_vaddr[node]) >> PAGE_SHIFT;
-
-		printk(KERN_DEBUG "%s: node %d\n", __func__, node);
-
-		for (pfn = 0; pfn < nr_pages; pfn += PTRS_PER_PTE) {
-			unsigned long vaddr = start_va + (pfn << PAGE_SHIFT);
-			pgd_t *pgd = pgd_base + pgd_index(vaddr);
-			pud_t *pud = pud_offset(pgd, vaddr);
-			pmd_t *pmd = pmd_offset(pud, vaddr);
-
-			set_pmd(pmd, pfn_pmd(start_pfn + pfn,
-						PAGE_KERNEL_LARGE_EXEC));
-
-			printk(KERN_DEBUG "%s: %08lx -> pfn %08lx\n",
-				__func__, vaddr, start_pfn + pfn);
-		}
-	}
-}
-#endif
-
-/**
- * init_alloc_remap - Initialize remap allocator for a NUMA node
- * @nid: NUMA node to initizlie remap allocator for
- *
- * NUMA nodes may end up without any lowmem.  As allocating pgdat and
- * memmap on a different node with lowmem is inefficient, a special
- * remap allocator is implemented which can be used by alloc_remap().
- *
- * For each node, the amount of memory which will be necessary for
- * pgdat and memmap is calculated and two memory areas of the size are
- * allocated - one in the node and the other in lowmem; then, the area
- * in the node is remapped to the lowmem area.
- *
- * As pgdat and memmap must be allocated in lowmem anyway, this
- * doesn't waste lowmem address space; however, the actual lowmem
- * which gets remapped over is wasted.  The amount shouldn't be
- * problematic on machines this feature will be used.
- *
- * Initialization failure isn't fatal.  alloc_remap() is used
- * opportunistically and the callers will fall back to other memory
- * allocation mechanisms on failure.
- */
-void __init init_alloc_remap(int nid, u64 start, u64 end)
-{
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long end_pfn = end >> PAGE_SHIFT;
-	unsigned long size, pfn;
-	u64 node_pa, remap_pa;
-	void *remap_va;
-
-	/*
-	 * The acpi/srat node info can show hot-add memroy zones where
-	 * memory could be added but not currently present.
-	 */
-	printk(KERN_DEBUG "node %d pfn: [%lx - %lx]\n",
-	       nid, start_pfn, end_pfn);
-
-	/* calculate the necessary space aligned to large page size */
-	size = node_memmap_size_bytes(nid, start_pfn, end_pfn);
-	size += ALIGN(sizeof(pg_data_t), PAGE_SIZE);
-	size = ALIGN(size, LARGE_PAGE_BYTES);
-
-	/* allocate node memory and the lowmem remap area */
-	node_pa = memblock_find_in_range(start, end, size, LARGE_PAGE_BYTES);
-	if (!node_pa) {
-		pr_warning("remap_alloc: failed to allocate %lu bytes for node %d\n",
-			   size, nid);
-		return;
-	}
-	memblock_reserve(node_pa, size);
-
-	remap_pa = memblock_find_in_range(min_low_pfn << PAGE_SHIFT,
-					  max_low_pfn << PAGE_SHIFT,
-					  size, LARGE_PAGE_BYTES);
-	if (!remap_pa) {
-		pr_warning("remap_alloc: failed to allocate %lu bytes remap area for node %d\n",
-			   size, nid);
-		memblock_free(node_pa, size);
-		return;
-	}
-	memblock_reserve(remap_pa, size);
-	remap_va = phys_to_virt(remap_pa);
-
-	/* perform actual remap */
-	for (pfn = 0; pfn < size >> PAGE_SHIFT; pfn += PTRS_PER_PTE)
-		set_pmd_pfn((unsigned long)remap_va + (pfn << PAGE_SHIFT),
-			    (node_pa >> PAGE_SHIFT) + pfn,
-			    PAGE_KERNEL_LARGE);
-
-	/* initialize remap allocator parameters */
-	node_remap_start_pfn[nid] = node_pa >> PAGE_SHIFT;
-	node_remap_start_vaddr[nid] = remap_va;
-	node_remap_end_vaddr[nid] = remap_va + size;
-	node_remap_alloc_vaddr[nid] = remap_va;
-
-	printk(KERN_DEBUG "remap_alloc: node %d [%08llx-%08llx) -> [%p-%p)\n",
-	       nid, node_pa, node_pa + size, remap_va, remap_va + size);
-}
-
 void __init initmem_init(void)
 {
 	x86_numa_init();
diff -puN arch/x86/mm/numa.c~rip-out-i386-NUMA-remapping-code arch/x86/mm/numa.c
--- linux-2.6.git/arch/x86/mm/numa.c~rip-out-i386-NUMA-remapping-code	2013-01-30 16:25:36.796338365 -0800
+++ linux-2.6.git-dave/arch/x86/mm/numa.c	2013-01-30 16:25:36.800338399 -0800
@@ -205,9 +205,6 @@ static void __init setup_node_data(int n
 	if (end && (end - start) < NODE_MIN_SIZE)
 		return;
 
-	/* initialize remap allocator before aligning to ZONE_ALIGN */
-	init_alloc_remap(nid, start, end);
-
 	start = roundup(start, ZONE_ALIGN);
 
 	printk(KERN_INFO "Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
diff -puN arch/x86/mm/numa_internal.h~rip-out-i386-NUMA-remapping-code arch/x86/mm/numa_internal.h
--- linux-2.6.git/arch/x86/mm/numa_internal.h~rip-out-i386-NUMA-remapping-code	2013-01-30 16:25:36.796338365 -0800
+++ linux-2.6.git-dave/arch/x86/mm/numa_internal.h	2013-01-30 16:25:36.800338399 -0800
@@ -21,12 +21,6 @@ void __init numa_reset_distance(void);
 
 void __init x86_numa_init(void);
 
-#ifdef CONFIG_X86_64
-static inline void init_alloc_remap(int nid, u64 start, u64 end)	{ }
-#else
-void __init init_alloc_remap(int nid, u64 start, u64 end);
-#endif
-
 #ifdef CONFIG_NUMA_EMU
 void __init numa_emulation(struct numa_meminfo *numa_meminfo,
 			   int numa_dist_cnt);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
