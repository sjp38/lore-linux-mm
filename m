Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86C2D6B73FF
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q130-v6so8964691oic.22
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e131-v6si1309338oia.206.2018.09.05.09.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:21 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85Fx02Z023221
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:21 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2magkt527n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:14 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:12 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 06/29] memblock: rename memblock_alloc{_nid,_try_nid} to memblock_phys_alloc*
Date: Wed,  5 Sep 2018 18:59:21 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

This will allow using memblock_alloc for memblock allocations returning
virtual address.

The conversion is done using the following semantic patch:

@@
expression e1, e2, e3;
@@
(
- memblock_alloc(e1, e2)
+ memblock_phys_alloc(e1, e2)
|
- memblock_alloc_nid(e1, e2, e3)
+ memblock_phys_alloc_nid(e1, e2, e3)
|
- memblock_alloc_try_nid(e1, e2, e3)
+ memblock_phys_alloc_try_nid(e1, e2, e3)
)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/arm/mm/mmu.c                     |  2 +-
 arch/arm64/mm/mmu.c                   |  2 +-
 arch/arm64/mm/numa.c                  |  2 +-
 arch/c6x/mm/dma-coherent.c            |  4 ++--
 arch/nds32/mm/init.c                  |  8 ++++----
 arch/openrisc/mm/init.c               |  2 +-
 arch/openrisc/mm/ioremap.c            |  2 +-
 arch/powerpc/kernel/dt_cpu_ftrs.c     |  4 +---
 arch/powerpc/kernel/paca.c            |  2 +-
 arch/powerpc/kernel/prom.c            |  2 +-
 arch/powerpc/kernel/setup-common.c    |  3 +--
 arch/powerpc/kernel/setup_32.c        | 10 +++++-----
 arch/powerpc/mm/numa.c                |  2 +-
 arch/powerpc/mm/pgtable_32.c          |  2 +-
 arch/powerpc/mm/ppc_mmu_32.c          |  2 +-
 arch/powerpc/platforms/pasemi/iommu.c |  2 +-
 arch/powerpc/platforms/powernv/opal.c |  2 +-
 arch/powerpc/sysdev/dart_iommu.c      |  2 +-
 arch/s390/kernel/crash_dump.c         |  2 +-
 arch/s390/kernel/setup.c              |  3 ++-
 arch/s390/mm/vmem.c                   |  4 ++--
 arch/s390/numa/numa.c                 |  2 +-
 arch/sparc/kernel/mdesc.c             |  2 +-
 arch/sparc/kernel/prom_64.c           |  2 +-
 arch/sparc/mm/init_64.c               | 11 ++++++-----
 arch/unicore32/mm/mmu.c               |  2 +-
 arch/x86/mm/numa.c                    |  2 +-
 drivers/firmware/efi/memmap.c         |  2 +-
 include/linux/memblock.h              |  6 +++---
 mm/memblock.c                         |  8 ++++----
 30 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index e46a6a4..f5cc1cc 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -721,7 +721,7 @@ EXPORT_SYMBOL(phys_mem_access_prot);
 
 static void __init *early_alloc_aligned(unsigned long sz, unsigned long align)
 {
-	void *ptr = __va(memblock_alloc(sz, align));
+	void *ptr = __va(memblock_phys_alloc(sz, align));
 	memset(ptr, 0, sz);
 	return ptr;
 }
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 65f8627..33558f4 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -83,7 +83,7 @@ static phys_addr_t __init early_pgtable_alloc(void)
 	phys_addr_t phys;
 	void *ptr;
 
-	phys = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	phys = memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE);
 
 	/*
 	 * The FIX_{PGD,PUD,PMD} slots may be in active use, but the FIX_PTE
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 146c04c..e5aacd6 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -237,7 +237,7 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	if (start_pfn >= end_pfn)
 		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
 
-	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
 	nd = __va(nd_pa);
 
 	/* report and initialize */
diff --git a/arch/c6x/mm/dma-coherent.c b/arch/c6x/mm/dma-coherent.c
index d0a8e0c..01305c7 100644
--- a/arch/c6x/mm/dma-coherent.c
+++ b/arch/c6x/mm/dma-coherent.c
@@ -135,8 +135,8 @@ void __init coherent_mem_init(phys_addr_t start, u32 size)
 	if (dma_size & (PAGE_SIZE - 1))
 		++dma_pages;
 
-	bitmap_phys = memblock_alloc(BITS_TO_LONGS(dma_pages) * sizeof(long),
-				     sizeof(long));
+	bitmap_phys = memblock_phys_alloc(BITS_TO_LONGS(dma_pages) * sizeof(long),
+					  sizeof(long));
 
 	dma_bitmap = phys_to_virt(bitmap_phys);
 	memset(dma_bitmap, 0, dma_pages * PAGE_SIZE);
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index c713d2a..5af81b8 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -81,7 +81,7 @@ static void __init map_ram(void)
 		}
 
 		/* Alloc one page for holding PTE's... */
-		pte = (pte_t *) __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+		pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 		memset(pte, 0, PAGE_SIZE);
 		set_pmd(pme, __pmd(__pa(pte) + _PAGE_KERNEL_TABLE));
 
@@ -114,7 +114,7 @@ static void __init fixedrange_init(void)
 	pgd = swapper_pg_dir + pgd_index(vaddr);
 	pud = pud_offset(pgd, vaddr);
 	pmd = pmd_offset(pud, vaddr);
-	fixmap_pmd_p = (pmd_t *) __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+	fixmap_pmd_p = (pmd_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 	memset(fixmap_pmd_p, 0, PAGE_SIZE);
 	set_pmd(pmd, __pmd(__pa(fixmap_pmd_p) + _PAGE_KERNEL_TABLE));
 
@@ -127,7 +127,7 @@ static void __init fixedrange_init(void)
 	pgd = swapper_pg_dir + pgd_index(vaddr);
 	pud = pud_offset(pgd, vaddr);
 	pmd = pmd_offset(pud, vaddr);
-	pte = (pte_t *) __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+	pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 	memset(pte, 0, PAGE_SIZE);
 	set_pmd(pmd, __pmd(__pa(pte) + _PAGE_KERNEL_TABLE));
 	pkmap_page_table = pte;
@@ -153,7 +153,7 @@ void __init paging_init(void)
 	fixedrange_init();
 
 	/* allocate space for empty_zero_page */
-	zero_page = __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+	zero_page = __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 	memset(zero_page, 0, PAGE_SIZE);
 	zone_sizes_init();
 
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index 6972d5d..b7670de 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -106,7 +106,7 @@ static void __init map_ram(void)
 			}
 
 			/* Alloc one page for holding PTE's... */
-			pte = (pte_t *) __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+			pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 			set_pmd(pme, __pmd(_KERNPG_TABLE + __pa(pte)));
 
 			/* Fill the newly allocated page with PTE'S */
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 2175e4b..c969752 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -126,7 +126,7 @@ pte_t __ref *pte_alloc_one_kernel(struct mm_struct *mm,
 	if (likely(mem_init_done)) {
 		pte = (pte_t *) __get_free_page(GFP_KERNEL);
 	} else {
-		pte = (pte_t *) __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+		pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 	}
 
 	if (pte)
diff --git a/arch/powerpc/kernel/dt_cpu_ftrs.c b/arch/powerpc/kernel/dt_cpu_ftrs.c
index f432054..8be3721 100644
--- a/arch/powerpc/kernel/dt_cpu_ftrs.c
+++ b/arch/powerpc/kernel/dt_cpu_ftrs.c
@@ -1008,9 +1008,7 @@ static int __init dt_cpu_ftrs_scan_callback(unsigned long node, const char
 	/* Count and allocate space for cpu features */
 	of_scan_flat_dt_subnodes(node, count_cpufeatures_subnodes,
 						&nr_dt_cpu_features);
-	dt_cpu_features = __va(
-		memblock_alloc(sizeof(struct dt_cpu_feature)*
-				nr_dt_cpu_features, PAGE_SIZE));
+	dt_cpu_features = __va(memblock_phys_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE));
 
 	cpufeatures_setup_start(isa);
 
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 0ee3e6d..f331a00 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -198,7 +198,7 @@ void __init allocate_paca_ptrs(void)
 	paca_nr_cpu_ids = nr_cpu_ids;
 
 	paca_ptrs_size = sizeof(struct paca_struct *) * nr_cpu_ids;
-	paca_ptrs = __va(memblock_alloc(paca_ptrs_size, 0));
+	paca_ptrs = __va(memblock_phys_alloc(paca_ptrs_size, 0));
 	memset(paca_ptrs, 0x88, paca_ptrs_size);
 }
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index c4d7078..fe758ce 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -126,7 +126,7 @@ static void __init move_device_tree(void)
 	if ((memory_limit && (start + size) > PHYSICAL_START + memory_limit) ||
 			overlaps_crashkernel(start, size) ||
 			overlaps_initrd(start, size)) {
-		p = __va(memblock_alloc(size, PAGE_SIZE));
+		p = __va(memblock_phys_alloc(size, PAGE_SIZE));
 		memcpy(p, initial_boot_params, size);
 		initial_boot_params = p;
 		DBG("Moved device tree to 0x%p\n", p);
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 93fa0c9..710ff98 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -459,8 +459,7 @@ void __init smp_setup_cpu_maps(void)
 
 	DBG("smp_setup_cpu_maps()\n");
 
-	cpu_to_phys_id = __va(memblock_alloc(nr_cpu_ids * sizeof(u32),
-							__alignof__(u32)));
+	cpu_to_phys_id = __va(memblock_phys_alloc(nr_cpu_ids * sizeof(u32), __alignof__(u32)));
 	memset(cpu_to_phys_id, 0, nr_cpu_ids * sizeof(u32));
 
 	for_each_node_by_type(dn, "cpu") {
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 8c507be..8190960 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -206,9 +206,9 @@ void __init irqstack_early_init(void)
 	 * as the memblock is limited to lowmem by default */
 	for_each_possible_cpu(i) {
 		softirq_ctx[i] = (struct thread_info *)
-			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
+			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
 		hardirq_ctx[i] = (struct thread_info *)
-			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
+			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
 	}
 }
 
@@ -227,12 +227,12 @@ void __init exc_lvl_early_init(void)
 #endif
 
 		critirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
+			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
 #ifdef CONFIG_BOOKE
 		dbgirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
+			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
 		mcheckirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_alloc(THREAD_SIZE, THREAD_SIZE));
+			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
 #endif
 	}
 }
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 35ac542..5fc0587 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -788,7 +788,7 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	void *nd;
 	int tnid;
 
-	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
 	nd = __va(nd_pa);
 
 	/* report and initialize */
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index 120a49b..989a1c2 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -50,7 +50,7 @@ __ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 	if (slab_is_available()) {
 		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	} else {
-		pte = __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
+		pte = __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
 		if (pte)
 			clear_page(pte);
 	}
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index bea6c54..9ee0357 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -224,7 +224,7 @@ void __init MMU_init_hw(void)
 	 * Find some memory for the hash table.
 	 */
 	if ( ppc_md.progress ) ppc_md.progress("hash:find piece", 0x322);
-	Hash = __va(memblock_alloc(Hash_size, Hash_size));
+	Hash = __va(memblock_phys_alloc(Hash_size, Hash_size));
 	memset(Hash, 0, Hash_size);
 	_SDR1 = __pa(Hash) | SDR1_LOW_BITS;
 
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index f06c83f..f297152 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -213,7 +213,7 @@ static int __init iob_init(struct device_node *dn)
 	pr_info("IOBMAP L2 allocated at: %p\n", iob_l2_base);
 
 	/* Allocate a spare page to map all invalid IOTLB pages. */
-	tmp = memblock_alloc(IOBMAP_PAGE_SIZE, IOBMAP_PAGE_SIZE);
+	tmp = memblock_phys_alloc(IOBMAP_PAGE_SIZE, IOBMAP_PAGE_SIZE);
 	if (!tmp)
 		panic("IOBMAP: Cannot allocate spare page!");
 	/* Empty l1 is marked invalid */
diff --git a/arch/powerpc/platforms/powernv/opal.c b/arch/powerpc/platforms/powernv/opal.c
index 38fe408..9431921 100644
--- a/arch/powerpc/platforms/powernv/opal.c
+++ b/arch/powerpc/platforms/powernv/opal.c
@@ -171,7 +171,7 @@ int __init early_init_dt_scan_recoverable_ranges(unsigned long node,
 	/*
 	 * Allocate a buffer to hold the MC recoverable ranges.
 	 */
-	mc_recoverable_range =__va(memblock_alloc(size, __alignof__(u64)));
+	mc_recoverable_range =__va(memblock_phys_alloc(size, __alignof__(u64)));
 	memset(mc_recoverable_range, 0, size);
 
 	for (i = 0; i < mc_recoverable_range_len; i++) {
diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index 5ca3e22..a5b40d1 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -261,7 +261,7 @@ static void allocate_dart(void)
 	 * that to work around what looks like a problem with the HT bridge
 	 * prefetching into invalid pages and corrupting data
 	 */
-	tmp = memblock_alloc(DART_PAGE_SIZE, DART_PAGE_SIZE);
+	tmp = memblock_phys_alloc(DART_PAGE_SIZE, DART_PAGE_SIZE);
 	dart_emptyval = DARTMAP_VALID | ((tmp >> DART_PAGE_SHIFT) &
 					 DARTMAP_RPNMASK);
 
diff --git a/arch/s390/kernel/crash_dump.c b/arch/s390/kernel/crash_dump.c
index 376f6b6..d17566a 100644
--- a/arch/s390/kernel/crash_dump.c
+++ b/arch/s390/kernel/crash_dump.c
@@ -61,7 +61,7 @@ struct save_area * __init save_area_alloc(bool is_boot_cpu)
 {
 	struct save_area *sa;
 
-	sa = (void *) memblock_alloc(sizeof(*sa), 8);
+	sa = (void *) memblock_phys_alloc(sizeof(*sa), 8);
 	if (is_boot_cpu)
 		list_add(&sa->list, &dump_save_areas);
 	else
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index c637c12..2f2ee43 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -843,7 +843,8 @@ static void __init setup_randomness(void)
 {
 	struct sysinfo_3_2_2 *vmms;
 
-	vmms = (struct sysinfo_3_2_2 *) memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	vmms = (struct sysinfo_3_2_2 *) memblock_phys_alloc(PAGE_SIZE,
+							    PAGE_SIZE);
 	if (stsi(vmms, 3, 2, 2) == 0 && vmms->count)
 		add_device_randomness(&vmms->vm, sizeof(vmms->vm[0]) * vmms->count);
 	memblock_free((unsigned long) vmms, PAGE_SIZE);
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index db55561..04638b0 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -36,7 +36,7 @@ static void __ref *vmem_alloc_pages(unsigned int order)
 
 	if (slab_is_available())
 		return (void *)__get_free_pages(GFP_KERNEL, order);
-	return (void *) memblock_alloc(size, size);
+	return (void *) memblock_phys_alloc(size, size);
 }
 
 void *vmem_crst_alloc(unsigned long val)
@@ -57,7 +57,7 @@ pte_t __ref *vmem_pte_alloc(void)
 	if (slab_is_available())
 		pte = (pte_t *) page_table_alloc(&init_mm);
 	else
-		pte = (pte_t *) memblock_alloc(size, size);
+		pte = (pte_t *) memblock_phys_alloc(size, size);
 	if (!pte)
 		return NULL;
 	memset64((u64 *)pte, _PAGE_INVALID, PTRS_PER_PTE);
diff --git a/arch/s390/numa/numa.c b/arch/s390/numa/numa.c
index 5bd3744..297f5d8 100644
--- a/arch/s390/numa/numa.c
+++ b/arch/s390/numa/numa.c
@@ -64,7 +64,7 @@ static __init pg_data_t *alloc_node_data(void)
 {
 	pg_data_t *res;
 
-	res = (pg_data_t *) memblock_alloc(sizeof(pg_data_t), 8);
+	res = (pg_data_t *) memblock_phys_alloc(sizeof(pg_data_t), 8);
 	memset(res, 0, sizeof(pg_data_t));
 	return res;
 }
diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 39a2503..59131e7 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -170,7 +170,7 @@ static struct mdesc_handle * __init mdesc_memblock_alloc(unsigned int mdesc_size
 		       mdesc_size);
 	alloc_size = PAGE_ALIGN(handle_size);
 
-	paddr = memblock_alloc(alloc_size, PAGE_SIZE);
+	paddr = memblock_phys_alloc(alloc_size, PAGE_SIZE);
 
 	hp = NULL;
 	if (paddr) {
diff --git a/arch/sparc/kernel/prom_64.c b/arch/sparc/kernel/prom_64.c
index baeaeed..c37955d 100644
--- a/arch/sparc/kernel/prom_64.c
+++ b/arch/sparc/kernel/prom_64.c
@@ -34,7 +34,7 @@
 
 void * __init prom_early_alloc(unsigned long size)
 {
-	unsigned long paddr = memblock_alloc(size, SMP_CACHE_BYTES);
+	unsigned long paddr = memblock_phys_alloc(size, SMP_CACHE_BYTES);
 	void *ret;
 
 	if (!paddr) {
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index f396048..578ec3d 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -1092,7 +1092,8 @@ static void __init allocate_node_data(int nid)
 #ifdef CONFIG_NEED_MULTIPLE_NODES
 	unsigned long paddr;
 
-	paddr = memblock_alloc_try_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
+	paddr = memblock_phys_alloc_try_nid(sizeof(struct pglist_data),
+					    SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -1266,8 +1267,8 @@ static int __init grab_mlgroups(struct mdesc_handle *md)
 	if (!count)
 		return -ENOENT;
 
-	paddr = memblock_alloc(count * sizeof(struct mdesc_mlgroup),
-			  SMP_CACHE_BYTES);
+	paddr = memblock_phys_alloc(count * sizeof(struct mdesc_mlgroup),
+				    SMP_CACHE_BYTES);
 	if (!paddr)
 		return -ENOMEM;
 
@@ -1307,8 +1308,8 @@ static int __init grab_mblocks(struct mdesc_handle *md)
 	if (!count)
 		return -ENOENT;
 
-	paddr = memblock_alloc(count * sizeof(struct mdesc_mblock),
-			  SMP_CACHE_BYTES);
+	paddr = memblock_phys_alloc(count * sizeof(struct mdesc_mblock),
+				    SMP_CACHE_BYTES);
 	if (!paddr)
 		return -ENOMEM;
 
diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
index 0c94b7b..18b355a 100644
--- a/arch/unicore32/mm/mmu.c
+++ b/arch/unicore32/mm/mmu.c
@@ -144,7 +144,7 @@ static void __init build_mem_type_table(void)
 
 static void __init *early_alloc(unsigned long sz)
 {
-	void *ptr = __va(memblock_alloc(sz, sz));
+	void *ptr = __va(memblock_phys_alloc(sz, sz));
 	memset(ptr, 0, sz);
 	return ptr;
 }
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index fa15085..16e37d7 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -196,7 +196,7 @@ static void __init alloc_node_data(int nid)
 	 * Allocate node data.  Try node-local memory and then any node.
 	 * Never allocate in DMA zone.
 	 */
-	nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_phys_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
 	if (!nd_pa) {
 		nd_pa = __memblock_alloc_base(nd_size, SMP_CACHE_BYTES,
 					      MEMBLOCK_ALLOC_ACCESSIBLE);
diff --git a/drivers/firmware/efi/memmap.c b/drivers/firmware/efi/memmap.c
index 5fc7052..ef618bc 100644
--- a/drivers/firmware/efi/memmap.c
+++ b/drivers/firmware/efi/memmap.c
@@ -15,7 +15,7 @@
 
 static phys_addr_t __init __efi_memmap_alloc_early(unsigned long size)
 {
-	return memblock_alloc(size, 0);
+	return memblock_phys_alloc(size, 0);
 }
 
 static phys_addr_t __init __efi_memmap_alloc_late(unsigned long size)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 3c96a16..ab5f11b 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -317,10 +317,10 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-phys_addr_t memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
-phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
+phys_addr_t memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
+phys_addr_t memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
-phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
+phys_addr_t memblock_phys_alloc(phys_addr_t size, phys_addr_t align);
 
 /*
  * Set the allocation direction to bottom-up or top-down.
diff --git a/mm/memblock.c b/mm/memblock.c
index 2a5940c..0ab9507 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1344,7 +1344,7 @@ phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
 	return memblock_alloc_range_nid(size, align, 0, max_addr, nid, flags);
 }
 
-phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
+phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	enum memblock_flags flags = choose_memblock_flags();
 	phys_addr_t ret;
@@ -1379,14 +1379,14 @@ phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys
 	return alloc;
 }
 
-phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
+phys_addr_t __init memblock_phys_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
-phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
+phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	phys_addr_t res = memblock_alloc_nid(size, align, nid);
+	phys_addr_t res = memblock_phys_alloc_nid(size, align, nid);
 
 	if (res)
 		return res;
-- 
2.7.4
