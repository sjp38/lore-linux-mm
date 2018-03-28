Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE9AE6B0261
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:53 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s23-v6so2108209plr.15
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:53 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k1-v6si3829279pld.267.2018.03.28.09.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID through page allocator
Date: Wed, 28 Mar 2018 19:55:32 +0300
Message-Id: <20180328165540.648-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Modify several page allocation routines to pass down encryption KeyID to
be used for the allocated page.

There are two basic use cases:

 - alloc_page_vma() use VMA's KeyID to allocate the page.

 - Page migration and NUMA balancing path use KeyID of original page as
   KeyID for newly allocated page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/ia64/hp/common/sba_iommu.c                    |  2 +-
 arch/ia64/include/asm/thread_info.h                |  2 +-
 arch/ia64/kernel/uncached.c                        |  2 +-
 arch/ia64/sn/pci/pci_dma.c                         |  2 +-
 arch/ia64/sn/pci/tioca_provider.c                  |  2 +-
 arch/powerpc/kernel/dma.c                          |  2 +-
 arch/powerpc/kernel/iommu.c                        |  4 +--
 arch/powerpc/perf/imc-pmu.c                        |  4 +--
 arch/powerpc/platforms/cell/iommu.c                |  6 ++--
 arch/powerpc/platforms/cell/ras.c                  |  2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c          |  6 ++--
 arch/powerpc/sysdev/xive/common.c                  |  2 +-
 arch/sparc/kernel/iommu.c                          |  6 ++--
 arch/sparc/kernel/pci_sun4v.c                      |  2 +-
 arch/tile/kernel/machine_kexec.c                   |  2 +-
 arch/tile/mm/homecache.c                           |  2 +-
 arch/x86/events/intel/ds.c                         |  2 +-
 arch/x86/events/intel/pt.c                         |  2 +-
 arch/x86/kernel/espfix_64.c                        |  6 ++--
 arch/x86/kernel/irq_32.c                           |  4 +--
 arch/x86/kvm/vmx.c                                 |  2 +-
 block/blk-mq.c                                     |  2 +-
 drivers/char/agp/sgi-agp.c                         |  2 +-
 drivers/edac/thunderx_edac.c                       |  2 +-
 drivers/hv/channel.c                               |  2 +-
 drivers/iommu/dmar.c                               |  3 +-
 drivers/iommu/intel-iommu.c                        |  2 +-
 drivers/iommu/intel_irq_remapping.c                |  2 +-
 drivers/misc/sgi-gru/grufile.c                     |  2 +-
 drivers/misc/sgi-xp/xpc_uv.c                       |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  5 ++--
 drivers/net/ethernet/mellanox/mlx4/icm.c           |  2 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  2 +-
 include/linux/gfp.h                                | 29 +++++++++----------
 include/linux/migrate.h                            |  2 +-
 include/linux/mm.h                                 |  7 +++++
 include/linux/skbuff.h                             |  2 +-
 kernel/events/ring_buffer.c                        |  4 +--
 kernel/fork.c                                      |  2 +-
 kernel/profile.c                                   |  2 +-
 kernel/trace/ring_buffer.c                         |  6 ++--
 kernel/trace/trace.c                               |  2 +-
 kernel/trace/trace_uprobe.c                        |  2 +-
 lib/dma-direct.c                                   |  2 +-
 mm/filemap.c                                       |  2 +-
 mm/hugetlb.c                                       |  2 +-
 mm/khugepaged.c                                    |  2 +-
 mm/mempolicy.c                                     | 33 +++++++++++++---------
 mm/migrate.c                                       | 12 ++++----
 mm/page_alloc.c                                    | 10 +++----
 mm/percpu-vm.c                                     |  2 +-
 mm/slab.c                                          |  2 +-
 mm/slob.c                                          |  2 +-
 mm/slub.c                                          |  4 +--
 mm/sparse-vmemmap.c                                |  2 +-
 mm/vmalloc.c                                       |  8 ++++--
 net/core/pktgen.c                                  |  2 +-
 net/sunrpc/svc.c                                   |  2 +-
 62 files changed, 132 insertions(+), 113 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index aec4a3354abe..96e70dfaed2d 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1142,7 +1142,7 @@ sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	{
 		struct page *page;
 
-		page = alloc_pages_node(ioc->node, flags, get_order(size));
+		page = alloc_pages_node(ioc->node, flags, get_order(size), 0);
 		if (unlikely(!page))
 			return NULL;
 
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 64a1011f6812..ce022719683d 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -83,7 +83,7 @@ struct thread_info {
 #define alloc_task_struct_node(node)						\
 ({										\
 	struct page *page = alloc_pages_node(node, GFP_KERNEL | __GFP_COMP,	\
-					     KERNEL_STACK_SIZE_ORDER);		\
+					     KERNEL_STACK_SIZE_ORDER, 0);	\
 	struct task_struct *ret = page ? page_address(page) : NULL;		\
 										\
 	ret;									\
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 583f7ff6b589..fa1acce41f36 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -100,7 +100,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 
 	page = __alloc_pages_node(nid,
 				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
-				IA64_GRANULE_SHIFT-PAGE_SHIFT);
+				IA64_GRANULE_SHIFT-PAGE_SHIFT, 0);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);
 		return -1;
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 74c934a997bb..e301cbebe8fc 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -93,7 +93,7 @@ static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
 		struct page *p = __alloc_pages_node(node,
-						flags, get_order(size));
+						flags, get_order(size), 0);
 
 		if (likely(p))
 			cpuaddr = page_address(p);
diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index a70b11fd57d6..c5eff2e95f93 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -122,7 +122,7 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
 	tmp =
 	    alloc_pages_node(tioca_kern->ca_closest_node,
 			     GFP_KERNEL | __GFP_ZERO,
-			     get_order(tioca_kern->ca_gart_size));
+			     get_order(tioca_kern->ca_gart_size), 0);
 
 	if (!tmp) {
 		printk(KERN_ERR "%s:  Could not allocate "
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index da20569de9d4..5e2bee80cb04 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -105,7 +105,7 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 	};
 #endif /* CONFIG_FSL_SOC */
 
-	page = alloc_pages_node(node, flag, get_order(size));
+	page = alloc_pages_node(node, flag, get_order(size), 0);
 	if (page == NULL)
 		return NULL;
 	ret = page_address(page);
diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
index af7a20dc6e09..15f10353659d 100644
--- a/arch/powerpc/kernel/iommu.c
+++ b/arch/powerpc/kernel/iommu.c
@@ -662,7 +662,7 @@ struct iommu_table *iommu_init_table(struct iommu_table *tbl, int nid)
 	/* number of bytes needed for the bitmap */
 	sz = BITS_TO_LONGS(tbl->it_size) * sizeof(unsigned long);
 
-	page = alloc_pages_node(nid, GFP_KERNEL, get_order(sz));
+	page = alloc_pages_node(nid, GFP_KERNEL, get_order(sz), 0);
 	if (!page)
 		panic("iommu_init_table: Can't allocate %ld bytes\n", sz);
 	tbl->it_map = page_address(page);
@@ -857,7 +857,7 @@ void *iommu_alloc_coherent(struct device *dev, struct iommu_table *tbl,
 		return NULL;
 
 	/* Alloc enough pages (and possibly more) */
-	page = alloc_pages_node(node, flag, order);
+	page = alloc_pages_node(node, flag, order, 0);
 	if (!page)
 		return NULL;
 	ret = page_address(page);
diff --git a/arch/powerpc/perf/imc-pmu.c b/arch/powerpc/perf/imc-pmu.c
index d7532e7b9ab5..b1189ae1d991 100644
--- a/arch/powerpc/perf/imc-pmu.c
+++ b/arch/powerpc/perf/imc-pmu.c
@@ -565,7 +565,7 @@ static int core_imc_mem_init(int cpu, int size)
 	/* We need only vbase for core counters */
 	mem_info->vbase = page_address(alloc_pages_node(nid,
 					  GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE |
-					  __GFP_NOWARN, get_order(size)));
+					  __GFP_NOWARN, get_order(size), 0));
 	if (!mem_info->vbase)
 		return -ENOMEM;
 
@@ -834,7 +834,7 @@ static int thread_imc_mem_alloc(int cpu_id, int size)
 		 */
 		local_mem = page_address(alloc_pages_node(nid,
 				  GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE |
-				  __GFP_NOWARN, get_order(size)));
+				  __GFP_NOWARN, get_order(size), 0));
 		if (!local_mem)
 			return -ENOMEM;
 
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 12352a58072a..19e3b6b67b50 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -320,7 +320,7 @@ static void cell_iommu_setup_stab(struct cbe_iommu *iommu,
 
 	/* set up the segment table */
 	stab_size = segments * sizeof(unsigned long);
-	page = alloc_pages_node(iommu->nid, GFP_KERNEL, get_order(stab_size));
+	page = alloc_pages_node(iommu->nid, GFP_KERNEL, get_order(stab_size), 0);
 	BUG_ON(!page);
 	iommu->stab = page_address(page);
 	memset(iommu->stab, 0, stab_size);
@@ -345,7 +345,7 @@ static unsigned long *cell_iommu_alloc_ptab(struct cbe_iommu *iommu,
 	ptab_size = segments * pages_per_segment * sizeof(unsigned long);
 	pr_debug("%s: iommu[%d]: ptab_size: %lu, order: %d\n", __func__,
 			iommu->nid, ptab_size, get_order(ptab_size));
-	page = alloc_pages_node(iommu->nid, GFP_KERNEL, get_order(ptab_size));
+	page = alloc_pages_node(iommu->nid, GFP_KERNEL, get_order(ptab_size), 0);
 	BUG_ON(!page);
 
 	ptab = page_address(page);
@@ -519,7 +519,7 @@ cell_iommu_setup_window(struct cbe_iommu *iommu, struct device_node *np,
 	 * This code also assumes that we have a window that starts at 0,
 	 * which is the case on all spider based blades.
 	 */
-	page = alloc_pages_node(iommu->nid, GFP_KERNEL, 0);
+	page = alloc_pages_node(iommu->nid, GFP_KERNEL, 0, 0);
 	BUG_ON(!page);
 	iommu->pad_page = page_address(page);
 	clear_page(iommu->pad_page);
diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
index 2f704afe9af3..7828fe6d2799 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -125,7 +125,7 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 	area->order = order;
 	area->pages = __alloc_pages_node(area->nid,
 						GFP_KERNEL|__GFP_THISNODE,
-						area->order);
+						area->order, 0);
 
 	if (!area->pages) {
 		printk(KERN_WARNING "%s: no page on node %d\n",
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index a6c92c78c9b2..29c4dd645c6b 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -1811,7 +1811,7 @@ static int pnv_pci_ioda_dma_64bit_bypass(struct pnv_ioda_pe *pe)
 		table_size = PAGE_SIZE;
 
 	table_pages = alloc_pages_node(pe->phb->hose->node, GFP_KERNEL,
-				       get_order(table_size));
+				       get_order(table_size), 0);
 	if (!table_pages)
 		goto err;
 
@@ -2336,7 +2336,7 @@ static void pnv_pci_ioda1_setup_dma_pe(struct pnv_phb *phb,
 	 */
 	tce32_segsz = PNV_IODA1_DMA32_SEGSIZE >> (IOMMU_PAGE_SHIFT_4K - 3);
 	tce_mem = alloc_pages_node(phb->hose->node, GFP_KERNEL,
-				   get_order(tce32_segsz * segs));
+				   get_order(tce32_segsz * segs), 0);
 	if (!tce_mem) {
 		pe_err(pe, " Failed to allocate a 32-bit TCE memory\n");
 		goto fail;
@@ -2762,7 +2762,7 @@ static __be64 *pnv_pci_ioda2_table_do_alloc_pages(int nid, unsigned shift,
 	unsigned entries = 1UL << (shift - 3);
 	long i;
 
-	tce_mem = alloc_pages_node(nid, GFP_KERNEL, order);
+	tce_mem = alloc_pages_node(nid, GFP_KERNEL, order, 0);
 	if (!tce_mem) {
 		pr_err("Failed to allocate a TCE memory, order=%d\n", order);
 		return NULL;
diff --git a/arch/powerpc/sysdev/xive/common.c b/arch/powerpc/sysdev/xive/common.c
index 40c06110821c..c5c52046a56b 100644
--- a/arch/powerpc/sysdev/xive/common.c
+++ b/arch/powerpc/sysdev/xive/common.c
@@ -1471,7 +1471,7 @@ __be32 *xive_queue_page_alloc(unsigned int cpu, u32 queue_shift)
 	__be32 *qpage;
 
 	alloc_order = xive_alloc_order(queue_shift);
-	pages = alloc_pages_node(cpu_to_node(cpu), GFP_KERNEL, alloc_order);
+	pages = alloc_pages_node(cpu_to_node(cpu), GFP_KERNEL, alloc_order, 0);
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	qpage = (__be32 *)page_address(pages);
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index b08dc3416f06..d5c000368ffc 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -120,7 +120,7 @@ int iommu_table_init(struct iommu *iommu, int tsbsize,
 	/* Allocate and initialize the dummy page which we
 	 * set inactive IO PTEs to point to.
 	 */
-	page = alloc_pages_node(numa_node, GFP_KERNEL, 0);
+	page = alloc_pages_node(numa_node, GFP_KERNEL, 0, 0);
 	if (!page) {
 		printk(KERN_ERR "IOMMU: Error, gfp(dummy_page) failed.\n");
 		goto out_free_map;
@@ -131,7 +131,7 @@ int iommu_table_init(struct iommu *iommu, int tsbsize,
 
 	/* Now allocate and setup the IOMMU page table itself.  */
 	order = get_order(tsbsize);
-	page = alloc_pages_node(numa_node, GFP_KERNEL, order);
+	page = alloc_pages_node(numa_node, GFP_KERNEL, order, 0);
 	if (!page) {
 		printk(KERN_ERR "IOMMU: Error, gfp(tsb) failed.\n");
 		goto out_free_dummy_page;
@@ -212,7 +212,7 @@ static void *dma_4u_alloc_coherent(struct device *dev, size_t size,
 		return NULL;
 
 	nid = dev->archdata.numa_node;
-	page = alloc_pages_node(nid, gfp, order);
+	page = alloc_pages_node(nid, gfp, order, 0);
 	if (unlikely(!page))
 		return NULL;
 
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 249367228c33..28b52a8334a8 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -197,7 +197,7 @@ static void *dma_4v_alloc_coherent(struct device *dev, size_t size,
 		prot = HV_PCI_MAP_ATTR_RELAXED_ORDER;
 
 	nid = dev->archdata.numa_node;
-	page = alloc_pages_node(nid, gfp, order);
+	page = alloc_pages_node(nid, gfp, order, 0);
 	if (unlikely(!page))
 		return NULL;
 
diff --git a/arch/tile/kernel/machine_kexec.c b/arch/tile/kernel/machine_kexec.c
index 008aa2faef55..e304595ea3c4 100644
--- a/arch/tile/kernel/machine_kexec.c
+++ b/arch/tile/kernel/machine_kexec.c
@@ -215,7 +215,7 @@ static void kexec_find_and_set_command_line(struct kimage *image)
 struct page *kimage_alloc_pages_arch(gfp_t gfp_mask, unsigned int order)
 {
 	gfp_mask |= __GFP_THISNODE | __GFP_NORETRY;
-	return alloc_pages_node(0, gfp_mask, order);
+	return alloc_pages_node(0, gfp_mask, order, 0);
 }
 
 /*
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 4432f31e8479..99580091830b 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -398,7 +398,7 @@ struct page *homecache_alloc_pages_node(int nid, gfp_t gfp_mask,
 {
 	struct page *page;
 	BUG_ON(gfp_mask & __GFP_HIGHMEM);   /* must be lowmem */
-	page = alloc_pages_node(nid, gfp_mask, order);
+	page = alloc_pages_node(rch/x86/events/intel/pt.cnid, gfp_mask, order, 0);
 	if (page)
 		homecache_change_page_home(page, order, home);
 	return page;
diff --git a/arch/x86/events/intel/ds.c b/arch/x86/events/intel/ds.c
index da6780122786..2fbb76e62acc 100644
--- a/arch/x86/events/intel/ds.c
+++ b/arch/x86/events/intel/ds.c
@@ -321,7 +321,7 @@ static void *dsalloc_pages(size_t size, gfp_t flags, int cpu)
 	int node = cpu_to_node(cpu);
 	struct page *page;
 
-	page = __alloc_pages_node(node, flags | __GFP_ZERO, order);
+	page = __alloc_pages_node(node, flags | __GFP_ZERO, order, 0);
 	return page ? page_address(page) : NULL;
 }
 
diff --git a/arch/x86/events/intel/pt.c b/arch/x86/events/intel/pt.c
index 81fd41d5a0d9..85b6109680fd 100644
--- a/arch/x86/events/intel/pt.c
+++ b/arch/x86/events/intel/pt.c
@@ -586,7 +586,7 @@ static struct topa *topa_alloc(int cpu, gfp_t gfp)
 	struct topa *topa;
 	struct page *p;
 
-	p = alloc_pages_node(node, gfp | __GFP_ZERO, 0);
+	p = alloc_pages_node(node, gfp | __GFP_ZERO, 0, 0);
 	if (!p)
 		return NULL;
 
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index e5ec3cafa72e..ea8f4b19b10f 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -172,7 +172,7 @@ void init_espfix_ap(int cpu)
 	pud_p = &espfix_pud_page[pud_index(addr)];
 	pud = *pud_p;
 	if (!pud_present(pud)) {
-		struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
+		struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0, 0);
 
 		pmd_p = (pmd_t *)page_address(page);
 		pud = __pud(__pa(pmd_p) | (PGTABLE_PROT & ptemask));
@@ -184,7 +184,7 @@ void init_espfix_ap(int cpu)
 	pmd_p = pmd_offset(&pud, addr);
 	pmd = *pmd_p;
 	if (!pmd_present(pmd)) {
-		struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
+		struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0, 0);
 
 		pte_p = (pte_t *)page_address(page);
 		pmd = __pmd(__pa(pte_p) | (PGTABLE_PROT & ptemask));
@@ -194,7 +194,7 @@ void init_espfix_ap(int cpu)
 	}
 
 	pte_p = pte_offset_kernel(&pmd, addr);
-	stack_page = page_address(alloc_pages_node(node, GFP_KERNEL, 0));
+	stack_page = page_address(alloc_pages_node(node, GFP_KERNEL, 0, 0));
 	pte = __pte(__pa(stack_page) | ((__PAGE_KERNEL_RO | _PAGE_ENC) & ptemask));
 	for (n = 0; n < ESPFIX_PTE_CLONES; n++)
 		set_pte(&pte_p[n*PTE_STRIDE], pte);
diff --git a/arch/x86/kernel/irq_32.c b/arch/x86/kernel/irq_32.c
index c1bdbd3d3232..195a6df22780 100644
--- a/arch/x86/kernel/irq_32.c
+++ b/arch/x86/kernel/irq_32.c
@@ -117,12 +117,12 @@ void irq_ctx_init(int cpu)
 
 	irqstk = page_address(alloc_pages_node(cpu_to_node(cpu),
 					       THREADINFO_GFP,
-					       THREAD_SIZE_ORDER));
+					       THREAD_SIZE_ORDER, 0));
 	per_cpu(hardirq_stack, cpu) = irqstk;
 
 	irqstk = page_address(alloc_pages_node(cpu_to_node(cpu),
 					       THREADINFO_GFP,
-					       THREAD_SIZE_ORDER));
+					       THREAD_SIZE_ORDER, 0));
 	per_cpu(softirq_stack, cpu) = irqstk;
 
 	printk(KERN_DEBUG "CPU %u irqstacks, hard=%p soft=%p\n",
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index c29fe81d4209..ae2fd611efcc 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -3897,7 +3897,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = __alloc_pages_node(node, GFP_KERNEL, vmcs_config.order);
+	pages = __alloc_pages_node(node, GFP_KERNEL, vmcs_config.order, 0);
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 16e83e6df404..25ddcacdecd8 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -2113,7 +2113,7 @@ int blk_mq_alloc_rqs(struct blk_mq_tag_set *set, struct blk_mq_tags *tags,
 		do {
 			page = alloc_pages_node(node,
 				GFP_NOIO | __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO,
-				this_order);
+				this_order, 0);
 			if (page)
 				break;
 			if (!this_order--)
diff --git a/drivers/char/agp/sgi-agp.c b/drivers/char/agp/sgi-agp.c
index 3051c73bc383..383fb2e2826e 100644
--- a/drivers/char/agp/sgi-agp.c
+++ b/drivers/char/agp/sgi-agp.c
@@ -46,7 +46,7 @@ static struct page *sgi_tioca_alloc_page(struct agp_bridge_data *bridge)
 	    (struct tioca_kernel *)bridge->dev_private_data;
 
 	nid = info->ca_closest_node;
-	page = alloc_pages_node(nid, GFP_KERNEL, 0);
+	page = alloc_pages_node(nid, GFP_KERNEL, 0, 0);
 	if (!page)
 		return NULL;
 
diff --git a/drivers/edac/thunderx_edac.c b/drivers/edac/thunderx_edac.c
index 4803c6468bab..a4f935098b4c 100644
--- a/drivers/edac/thunderx_edac.c
+++ b/drivers/edac/thunderx_edac.c
@@ -417,7 +417,7 @@ static ssize_t thunderx_lmc_inject_ecc_write(struct file *file,
 
 	atomic_set(&lmc->ecc_int, 0);
 
-	lmc->mem = alloc_pages_node(lmc->node, GFP_KERNEL, 0);
+	lmc->mem = alloc_pages_node(lmc->node, GFP_KERNEL, 0, 0);
 
 	if (!lmc->mem)
 		return -ENOMEM;
diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index ba0a092ae085..31e99a9bb2de 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -98,7 +98,7 @@ int vmbus_open(struct vmbus_channel *newchannel, u32 send_ringbuffer_size,
 	page = alloc_pages_node(cpu_to_node(newchannel->target_cpu),
 				GFP_KERNEL|__GFP_ZERO,
 				get_order(send_ringbuffer_size +
-				recv_ringbuffer_size));
+				recv_ringbuffer_size), 0);
 
 	if (!page)
 		page = alloc_pages(GFP_KERNEL|__GFP_ZERO,
diff --git a/drivers/iommu/dmar.c b/drivers/iommu/dmar.c
index 9a7ffd13c7f0..7dc7252365e2 100644
--- a/drivers/iommu/dmar.c
+++ b/drivers/iommu/dmar.c
@@ -1449,7 +1449,8 @@ int dmar_enable_qi(struct intel_iommu *iommu)
 	qi = iommu->qi;
 
 
-	desc_page = alloc_pages_node(iommu->node, GFP_ATOMIC | __GFP_ZERO, 0);
+	desc_page = alloc_pages_node(iommu->node, GFP_ATOMIC | __GFP_ZERO,
+			0, 0);
 	if (!desc_page) {
 		kfree(qi);
 		iommu->qi = NULL;
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 24d1b1b42013..a0a2d71f4d4b 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -635,7 +635,7 @@ static inline void *alloc_pgtable_page(int node)
 	struct page *page;
 	void *vaddr = NULL;
 
-	page = alloc_pages_node(node, GFP_ATOMIC | __GFP_ZERO, 0);
+	page = alloc_pages_node(node, GFP_ATOMIC | __GFP_ZERO, 0, 0);
 	if (page)
 		vaddr = page_address(page);
 	return vaddr;
diff --git a/drivers/iommu/intel_irq_remapping.c b/drivers/iommu/intel_irq_remapping.c
index 66f69af2c219..528110205d18 100644
--- a/drivers/iommu/intel_irq_remapping.c
+++ b/drivers/iommu/intel_irq_remapping.c
@@ -513,7 +513,7 @@ static int intel_setup_irq_remapping(struct intel_iommu *iommu)
 		return -ENOMEM;
 
 	pages = alloc_pages_node(iommu->node, GFP_KERNEL | __GFP_ZERO,
-				 INTR_REMAP_PAGE_ORDER);
+				 INTR_REMAP_PAGE_ORDER, 0);
 	if (!pages) {
 		pr_err("IR%d: failed to allocate pages of order %d\n",
 		       iommu->seq_id, INTR_REMAP_PAGE_ORDER);
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index 104a05f6b738..7b29cc1f4072 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -276,7 +276,7 @@ static int gru_init_tables(unsigned long gru_base_paddr, void *gru_base_vaddr)
 	for_each_possible_blade(bid) {
 		pnode = uv_blade_to_pnode(bid);
 		nid = uv_blade_to_memory_nid(bid);/* -1 if no memory on blade */
-		page = alloc_pages_node(nid, GFP_KERNEL, order);
+		page = alloc_pages_node(nid, GFP_KERNEL, order, 0);
 		if (!page)
 			goto fail;
 		gru_base[bid] = page_address(page);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 340b44d9e8cf..4f7d15e6370d 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -241,7 +241,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 	nid = cpu_to_node(cpu);
 	page = __alloc_pages_node(nid,
 				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
-				      pg_order);
+				      pg_order, 0);
 	if (page == NULL) {
 		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
 			"bytes of memory on nid=%d for GRU mq\n", mq_size, nid);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index cc1e4f820e64..549daa8f7632 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -297,7 +297,7 @@ static int xgbe_alloc_pages(struct xgbe_prv_data *pdata,
 	/* Try to obtain pages, decreasing order if necessary */
 	gfp = GFP_ATOMIC | __GFP_COMP | __GFP_NOWARN;
 	while (order >= 0) {
-		pages = alloc_pages_node(node, gfp, order);
+		pages = alloc_pages_node(node, gfp, order, 0);
 		if (pages)
 			break;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 6e310a0da7c9..ec93ff44eec6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -592,7 +592,8 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	 * Prefer large buffers
 	 */
 	while (n) {
-		pg = alloc_pages_node(node, gfp | __GFP_COMP, s->fl_pg_order);
+		pg = alloc_pages_node(node, gfp | __GFP_COMP,
+				s->fl_pg_order, 0);
 		if (unlikely(!pg)) {
 			q->large_alloc_failed++;
 			break;       /* fall back to single pages */
@@ -623,7 +624,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 
 alloc_small_pages:
 	while (n--) {
-		pg = alloc_pages_node(node, gfp, 0);
+		pg = alloc_pages_node(node, gfp, 0, 0);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index a822f7a56bc5..f8281df897f3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -99,7 +99,7 @@ static int mlx4_alloc_icm_pages(struct scatterlist *mem, int order,
 {
 	struct page *page;
 
-	page = alloc_pages_node(node, gfp_mask, order);
+	page = alloc_pages_node(node, gfp_mask, order, 0);
 	if (!page) {
 		page = alloc_pages(gfp_mask, order);
 		if (!page)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index e36d3e3675f9..2c0b075e22bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -214,7 +214,7 @@ static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
 	int err;
 	int nid = dev_to_node(&dev->pdev->dev);
 
-	page = alloc_pages_node(nid, GFP_HIGHUSER, 0);
+	page = alloc_pages_node(nid, GFP_HIGHUSER, 0, 0);
 	if (!page) {
 		mlx5_core_warn(dev, "failed to allocate page\n");
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ec84edfda271..c7f5c50b2250 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1101,7 +1101,7 @@ int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages)
 	for (i = 0; i < npages; i++) {
 		p->ibp_pages[i] = alloc_pages_node(
 				    cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				    GFP_NOFS, 0);
+				    GFP_NOFS, 0, 0);
 		if (!p->ibp_pages[i]) {
 			CERROR("Can't allocate page %d of %d\n", i, npages);
 			kiblnd_free_pages(p);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 6504761ca598..5604da4bcc0e 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1320,7 +1320,7 @@ lnet_new_rtrbuf(struct lnet_rtrbufpool *rbp, int cpt)
 	for (i = 0; i < npages; i++) {
 		page = alloc_pages_node(
 				cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				GFP_KERNEL | __GFP_ZERO, 0);
+				GFP_KERNEL | __GFP_ZERO, 0, 0);
 		if (!page) {
 			while (--i >= 0)
 				__free_page(rb->rb_kiov[i].bv_page);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index f8198ad1046e..2bdf6bc716fe 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -142,7 +142,7 @@ srpc_alloc_bulk(int cpt, unsigned int bulk_off, unsigned int bulk_npg,
 		int nob;
 
 		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				      GFP_KERNEL, 0);
+				      GFP_KERNEL, 0, 0);
 		if (!pg) {
 			CERROR("Can't allocate page %d of %d\n", i, bulk_npg);
 			srpc_free_bulk(bk);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b44d32..d9d45f47447d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -447,13 +447,14 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask);
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int keyid,
+		int preferred_nid, nodemask_t *nodemask);
 
 static inline struct page *
-__alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
+__alloc_pages(gfp_t gfp_mask, unsigned int order, int keyid, int preferred_nid)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
+	return __alloc_pages_nodemask(gfp_mask, order, keyid, preferred_nid,
+			NULL);
 }
 
 /*
@@ -461,12 +462,12 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
  * online. For more general interface, see alloc_pages_node().
  */
 static inline struct page *
-__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
+__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order, int keyid)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
 	VM_WARN_ON(!node_online(nid));
 
-	return __alloc_pages(gfp_mask, order, nid);
+	return __alloc_pages(gfp_mask, order, keyid, nid);
 }
 
 /*
@@ -475,12 +476,12 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
  * online.
  */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
-						unsigned int order)
+						unsigned int order, int keyid)
 {
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
 
-	return __alloc_pages_node(nid, gfp_mask, order);
+	return __alloc_pages_node(nid, gfp_mask, order, keyid);
 }
 
 #ifdef CONFIG_NUMA
@@ -494,21 +495,19 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
-		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages(gfp_mask, order)
+	alloc_pages_node(numa_node_id(), gfp_mask, order, 0)
+#define alloc_pages_vma(gfp_mask, order, vma, addr, node, hugepage) \
+	alloc_pages_node(numa_node_id(), gfp_mask, order, vma_keyid(vma))
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2246cf670ba..b8e62d3b3200 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -51,7 +51,7 @@ static inline struct page *new_page_nodemask(struct page *page,
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, order,
+	new_page = __alloc_pages_nodemask(gfp_mask, order, page_keyid(page),
 				preferred_nid, nodemask);
 
 	if (new_page && PageTransHuge(new_page))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b6a72eb82f4b..1287d1a50abf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1493,6 +1493,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
 }
 #endif
 
+#ifndef page_keyid
+static inline int page_keyid(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 99df17109e1b..d785a7935770 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2669,7 +2669,7 @@ static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
 	 */
 	gfp_mask |= __GFP_COMP | __GFP_MEMALLOC;
 
-	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
+	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order, 0);
 }
 
 static inline struct page *dev_alloc_pages(unsigned int order)
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index 6c6b3c48db71..89b98a80817f 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -529,7 +529,7 @@ static struct page *rb_alloc_aux_page(int node, int order)
 		order = MAX_ORDER;
 
 	do {
-		page = alloc_pages_node(node, PERF_AUX_GFP, order);
+		page = alloc_pages_node(node, PERF_AUX_GFP, order, 0);
 	} while (!page && order--);
 
 	if (page && order) {
@@ -706,7 +706,7 @@ static void *perf_mmap_alloc_page(int cpu)
 	int node;
 
 	node = (cpu == -1) ? cpu : cpu_to_node(cpu);
-	page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+	page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0, 0);
 	if (!page)
 		return NULL;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index e5d9d405ae4e..6fb66ab00f18 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -240,7 +240,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 	return stack;
 #else
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
-					     THREAD_SIZE_ORDER);
+					     THREAD_SIZE_ORDER, 0);
 
 	return page ? page_address(page) : NULL;
 #endif
diff --git a/kernel/profile.c b/kernel/profile.c
index 9aa2a4445b0d..600b47951492 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -359,7 +359,7 @@ static int profile_prepare_cpu(unsigned int cpu)
 		if (per_cpu(cpu_profile_hits, cpu)[i])
 			continue;
 
-		page = __alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = __alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0, 0);
 		if (!page) {
 			profile_dead_cpu(cpu);
 			return -ENOMEM;
diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index dcf1c4dd3efe..68f10b4086ce 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1152,7 +1152,7 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 		list_add(&bpage->list, pages);
 
 		page = alloc_pages_node(cpu_to_node(cpu),
-					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
+					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0, 0);
 		if (!page)
 			goto free_pages;
 		bpage->page = page_address(page);
@@ -1227,7 +1227,7 @@ rb_allocate_cpu_buffer(struct ring_buffer *buffer, long nr_pages, int cpu)
 	rb_check_bpage(cpu_buffer, bpage);
 
 	cpu_buffer->reader_page = bpage;
-	page = alloc_pages_node(cpu_to_node(cpu), GFP_KERNEL, 0);
+	page = alloc_pages_node(cpu_to_node(cpu), GFP_KERNEL, 0, 0);
 	if (!page)
 		goto fail_free_reader;
 	bpage->page = page_address(page);
@@ -4406,7 +4406,7 @@ void *ring_buffer_alloc_read_page(struct ring_buffer *buffer, int cpu)
 		goto out;
 
 	page = alloc_pages_node(cpu_to_node(cpu),
-				GFP_KERNEL | __GFP_NORETRY, 0);
+				GFP_KERNEL | __GFP_NORETRY, 0, 0);
 	if (!page)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 300f4ea39646..f98c0062e946 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2176,7 +2176,7 @@ void trace_buffered_event_enable(void)
 
 	for_each_tracing_cpu(cpu) {
 		page = alloc_pages_node(cpu_to_node(cpu),
-					GFP_KERNEL | __GFP_NORETRY, 0);
+					GFP_KERNEL | __GFP_NORETRY, 0, 0);
 		if (!page)
 			goto failed;
 
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 2014f4351ae0..c31797eb7936 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -710,7 +710,7 @@ static int uprobe_buffer_init(void)
 
 	for_each_possible_cpu(cpu) {
 		struct page *p = alloc_pages_node(cpu_to_node(cpu),
-						  GFP_KERNEL, 0);
+						  GFP_KERNEL, 0, 0);
 		if (p == NULL) {
 			err_cpu = cpu;
 			goto err;
diff --git a/lib/dma-direct.c b/lib/dma-direct.c
index 1277d293d4da..687238f304b2 100644
--- a/lib/dma-direct.c
+++ b/lib/dma-direct.c
@@ -75,7 +75,7 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		}
 	}
 	if (!page)
-		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
+		page = alloc_pages_node(dev_to_node(dev), gfp, page_order, 0);
 
 	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 		__free_pages(page, page_order);
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f62212a59..89e32eb8bf9a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -937,7 +937,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = __alloc_pages_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp, 0, 0);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 976bbc5646fe..4a65099e1074 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1388,7 +1388,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
-	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
+	page = __alloc_pages_nodemask(gfp_mask, order, 0, nid, nmask);
 	if (page)
 		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	else
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 42f33fd526a0..2451a379c0ed 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -751,7 +751,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
+	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER, 0);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 32cba0332787..c2507aceef96 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -952,14 +952,16 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 
 		thp = alloc_pages_node(node,
 			(GFP_TRANSHUGE | __GFP_THISNODE),
-			HPAGE_PMD_ORDER);
+			HPAGE_PMD_ORDER, page_keyid(page));
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
 		return thp;
-	} else
-		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
+	} else {
+		return __alloc_pages_node(node,
+				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE,
+				0, page_keyid(page));
+	}
 }
 
 /*
@@ -1929,11 +1931,11 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+					unsigned nid, int keyid)
 {
 	struct page *page;
 
-	page = __alloc_pages(gfp, order, nid);
+	page = __alloc_pages(gfp, order, keyid, nid);
 	/* skip NUMA_INTERLEAVE_HIT counter update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return page;
@@ -1976,15 +1978,17 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	struct page *page;
 	int preferred_nid;
 	nodemask_t *nmask;
+	int keyid;
 
 	pol = get_vma_policy(vma, addr);
+	keyid = vma_keyid(vma);
 
 	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
+		page = alloc_page_interleave(gfp, order, nid, keyid);
 		goto out;
 	}
 
@@ -2009,14 +2013,15 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
 			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+						gfp | __GFP_THISNODE,
+						order, keyid);
 			goto out;
 		}
 	}
 
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
-	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
+	page = __alloc_pages_nodemask(gfp, order, keyid, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
 	return page;
@@ -2049,12 +2054,14 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
 	 */
-	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	else
-		page = __alloc_pages_nodemask(gfp, order,
+	if (pol->mode == MPOL_INTERLEAVE) {
+		page = alloc_page_interleave(gfp, order,
+				interleave_nodes(pol), 0);
+	} else {
+		page = __alloc_pages_nodemask(gfp, order, 0,
 				policy_node(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
+	}
 
 	return page;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 1e5525a25691..65d01c4479d6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1474,14 +1474,16 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 
 		thp = alloc_pages_node(pm->node,
 			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
-			HPAGE_PMD_ORDER);
+			HPAGE_PMD_ORDER, page_keyid(p));
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
 		return thp;
-	} else
+	} else {
 		return __alloc_pages_node(pm->node,
-				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
+				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE,
+				0, page_keyid(p));
+	}
 }
 
 /*
@@ -1845,7 +1847,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					 (GFP_HIGHUSER_MOVABLE |
 					  __GFP_THISNODE | __GFP_NOMEMALLOC |
 					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~__GFP_RECLAIM, 0);
+					 ~__GFP_RECLAIM, 0, page_keyid(page));
 
 	return newpage;
 }
@@ -2019,7 +2021,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	new_page = alloc_pages_node(node,
 		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
-		HPAGE_PMD_ORDER);
+		HPAGE_PMD_ORDER, page_keyid(page));
 	if (!new_page)
 		goto out_fail;
 	prep_transhuge_page(new_page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1741dd23e7c1..229cdab065ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4226,8 +4226,8 @@ static inline void finalise_ac(gfp_t gfp_mask,
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask)
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int keyid,
+		int preferred_nid, nodemask_t *nodemask)
 {
 	struct page *page;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
@@ -4346,11 +4346,11 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
 	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
 		    __GFP_NOMEMALLOC;
 	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
-				PAGE_FRAG_CACHE_MAX_ORDER);
+				PAGE_FRAG_CACHE_MAX_ORDER, 0);
 	nc->size = page ? PAGE_FRAG_CACHE_MAX_SIZE : PAGE_SIZE;
 #endif
 	if (unlikely(!page))
-		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
+		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0, 0);
 
 	nc->va = page ? page_address(page) : NULL;
 
@@ -4490,7 +4490,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
-	struct page *p = alloc_pages_node(nid, gfp_mask, order);
+	struct page *p = alloc_pages_node(nid, gfp_mask, order, 0);
 	if (!p)
 		return NULL;
 	return make_alloc_exact((unsigned long)page_address(p), order, size);
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index d8078de912de..9e19197f351c 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -92,7 +92,7 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 		for (i = page_start; i < page_end; i++) {
 			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
 
-			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
+			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0, 0);
 			if (!*pagep)
 				goto err;
 		}
diff --git a/mm/slab.c b/mm/slab.c
index 324446621b3e..56f42e4ba507 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1407,7 +1407,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 
 	flags |= cachep->allocflags;
 
-	page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
+	page = __alloc_pages_node(nodeid, flags, cachep->gfporder, 0);
 	if (!page) {
 		slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
diff --git a/mm/slob.c b/mm/slob.c
index 623e8a5c46ce..062f7acd7248 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -194,7 +194,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
-		page = __alloc_pages_node(node, gfp, order);
+		page = __alloc_pages_node(node, gfp, order, 0);
 	else
 #endif
 		page = alloc_pages(gfp, order);
diff --git a/mm/slub.c b/mm/slub.c
index e381728a3751..287a9b65da67 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1440,7 +1440,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-		page = __alloc_pages_node(node, flags, order);
+		page = __alloc_pages_node(node, flags, order, 0);
 
 	if (page && memcg_charge_slab(page, flags, order, s)) {
 		__free_pages(page, order);
@@ -3772,7 +3772,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	void *ptr = NULL;
 
 	flags |= __GFP_COMP;
-	page = alloc_pages_node(node, flags, get_order(size));
+	page = alloc_pages_node(node, flags, get_order(size), 0);
 	if (page)
 		ptr = page_address(page);
 
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index bd0276d5f66b..f6648ecb9837 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -58,7 +58,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 		static bool warned;
 		struct page *page;
 
-		page = alloc_pages_node(node, gfp_mask, order);
+		page = alloc_pages_node(node, gfp_mask, order, 0);
 		if (page)
 			return page_address(page);
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729cc956..33095a17c20e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1695,10 +1695,12 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
-		if (node == NUMA_NO_NODE)
+		if (node == NUMA_NO_NODE) {
 			page = alloc_page(alloc_mask|highmem_mask);
-		else
-			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
+		} else {
+			page = alloc_pages_node(node,
+					alloc_mask|highmem_mask, 0, 0);
+		}
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b8ab5c829511..4f8dd0467e1a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2651,7 +2651,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 
 				if (pkt_dev->node >= 0 && (pkt_dev->flags & F_NODE))
 					node = pkt_dev->node;
-				pkt_dev->page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+				pkt_dev->page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0, 0);
 				if (!pkt_dev->page)
 					break;
 			}
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 387cc4add6f6..a4bc01b6305f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -577,7 +577,7 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size, int node)
 	if (pages > RPCSVC_MAXPAGES)
 		pages = RPCSVC_MAXPAGES;
 	while (pages) {
-		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0);
+		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0, 0);
 		if (!p)
 			break;
 		rqstp->rq_pages[arghi++] = p;
-- 
2.16.2
