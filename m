Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B20F58E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:46:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id o7so4387900pfi.23
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:46:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b6si6129587pgd.292.2019.01.16.05.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:46:25 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GDebmL079567
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:46:24 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q2303fxdn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:46:24 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 13:46:21 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 21/21] memblock: drop memblock_alloc_*_nopanic() variants
Date: Wed, 16 Jan 2019 15:44:21 +0200
In-Reply-To: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1547646261-32535-22-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

As all the memblock allocation functions return NULL in case of error
rather than panic(), the duplicates with _nopanic suffix can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arc/kernel/unwind.c       |  3 +--
 arch/sh/mm/init.c              |  2 +-
 arch/x86/kernel/setup_percpu.c | 10 +++++-----
 arch/x86/mm/kasan_init_64.c    | 14 ++++++++------
 drivers/firmware/memmap.c      |  2 +-
 drivers/usb/early/xhci-dbc.c   |  2 +-
 include/linux/memblock.h       | 35 -----------------------------------
 kernel/dma/swiotlb.c           |  2 +-
 kernel/printk/printk.c         | 17 +++++++----------
 mm/memblock.c                  | 35 -----------------------------------
 mm/page_alloc.c                | 10 +++++-----
 mm/page_ext.c                  |  2 +-
 mm/percpu.c                    | 11 ++++-------
 mm/sparse.c                    |  6 ++----
 14 files changed, 37 insertions(+), 114 deletions(-)

diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
index d34f69e..271e9fa 100644
--- a/arch/arc/kernel/unwind.c
+++ b/arch/arc/kernel/unwind.c
@@ -181,8 +181,7 @@ static void init_unwind_hdr(struct unwind_table *table,
  */
 static void *__init unw_hdr_alloc_early(unsigned long sz)
 {
-	return memblock_alloc_from_nopanic(sz, sizeof(unsigned int),
-					   MAX_DMA_ADDRESS);
+	return memblock_alloc_from(sz, sizeof(unsigned int), MAX_DMA_ADDRESS);
 }
 
 static void *unw_hdr_alloc(unsigned long sz)
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index fceefd9..7062132 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -202,7 +202,7 @@ void __init allocate_pgdat(unsigned int nid)
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	NODE_DATA(nid) = memblock_alloc_try_nid_nopanic(
+	NODE_DATA(nid) = memblock_alloc_try_nid(
 				sizeof(struct pglist_data),
 				SMP_CACHE_BYTES, MEMBLOCK_LOW_LIMIT,
 				MEMBLOCK_ALLOC_ACCESSIBLE, nid);
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index e8796fc..0c5e9bf 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -106,22 +106,22 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
 	void *ptr;
 
 	if (!node_online(node) || !NODE_DATA(node)) {
-		ptr = memblock_alloc_from_nopanic(size, align, goal);
+		ptr = memblock_alloc_from(size, align, goal);
 		pr_info("cpu %d has no node %d or node-local memory\n",
 			cpu, node);
 		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
 			 cpu, size, __pa(ptr));
 	} else {
-		ptr = memblock_alloc_try_nid_nopanic(size, align, goal,
-						     MEMBLOCK_ALLOC_ACCESSIBLE,
-						     node);
+		ptr = memblock_alloc_try_nid(size, align, goal,
+					     MEMBLOCK_ALLOC_ACCESSIBLE,
+					     node);
 
 		pr_debug("per cpu data for cpu%d %lu bytes on node%d at %016lx\n",
 			 cpu, size, node, __pa(ptr));
 	}
 	return ptr;
 #else
-	return memblock_alloc_from_nopanic(size, align, goal);
+	return memblock_alloc_from(size, align, goal);
 #endif
 }
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 462fde8..8dc0fc0 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -24,14 +24,16 @@ extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
 static p4d_t tmp_p4d_table[MAX_PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
 
-static __init void *early_alloc(size_t size, int nid, bool panic)
+static __init void *early_alloc(size_t size, int nid, bool should_panic)
 {
-	if (panic)
-		return memblock_alloc_try_nid(size, size,
-			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
-	else
-		return memblock_alloc_try_nid_nopanic(size, size,
+	void *ptr = memblock_alloc_try_nid(size, size,
 			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+
+	if (!ptr && should_panic)
+		panic("%pS: Failed to allocate page, nid=%d from=%lx\n",
+		      (void *)_RET_IP_, nid, __pa(MAX_DMA_ADDRESS));
+
+	return ptr;
 }
 
 static void __init kasan_populate_pmd(pmd_t *pmd, unsigned long addr,
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index ec4fd25..d168c87 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -333,7 +333,7 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
 
-	entry = memblock_alloc_nopanic(sizeof(struct firmware_map_entry),
+	entry = memblock_alloc(sizeof(struct firmware_map_entry),
 			       SMP_CACHE_BYTES);
 	if (WARN_ON(!entry))
 		return -ENOMEM;
diff --git a/drivers/usb/early/xhci-dbc.c b/drivers/usb/early/xhci-dbc.c
index d2652dc..c9cfb10 100644
--- a/drivers/usb/early/xhci-dbc.c
+++ b/drivers/usb/early/xhci-dbc.c
@@ -94,7 +94,7 @@ static void * __init xdbc_get_page(dma_addr_t *dma_addr)
 {
 	void *virt;
 
-	virt = memblock_alloc_nopanic(PAGE_SIZE, PAGE_SIZE);
+	virt = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
 	if (!virt)
 		return NULL;
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f5a83a1..71c9e32 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -379,9 +379,6 @@ static inline phys_addr_t memblock_phys_alloc(phys_addr_t size,
 void *memblock_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
 				 phys_addr_t min_addr, phys_addr_t max_addr,
 				 int nid);
-void *memblock_alloc_try_nid_nopanic(phys_addr_t size, phys_addr_t align,
-				     phys_addr_t min_addr, phys_addr_t max_addr,
-				     int nid);
 void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
 			     phys_addr_t min_addr, phys_addr_t max_addr,
 			     int nid);
@@ -408,36 +405,12 @@ static inline void * __init memblock_alloc_from(phys_addr_t size,
 				      MEMBLOCK_ALLOC_ACCESSIBLE, NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_alloc_nopanic(phys_addr_t size,
-						   phys_addr_t align)
-{
-	return memblock_alloc_try_nid_nopanic(size, align, MEMBLOCK_LOW_LIMIT,
-					      MEMBLOCK_ALLOC_ACCESSIBLE,
-					      NUMA_NO_NODE);
-}
-
 static inline void * __init memblock_alloc_low(phys_addr_t size,
 					       phys_addr_t align)
 {
 	return memblock_alloc_try_nid(size, align, MEMBLOCK_LOW_LIMIT,
 				      ARCH_LOW_ADDRESS_LIMIT, NUMA_NO_NODE);
 }
-static inline void * __init memblock_alloc_low_nopanic(phys_addr_t size,
-						       phys_addr_t align)
-{
-	return memblock_alloc_try_nid_nopanic(size, align, MEMBLOCK_LOW_LIMIT,
-					      ARCH_LOW_ADDRESS_LIMIT,
-					      NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_from_nopanic(phys_addr_t size,
-							phys_addr_t align,
-							phys_addr_t min_addr)
-{
-	return memblock_alloc_try_nid_nopanic(size, align, min_addr,
-					      MEMBLOCK_ALLOC_ACCESSIBLE,
-					      NUMA_NO_NODE);
-}
 
 static inline void * __init memblock_alloc_node(phys_addr_t size,
 						phys_addr_t align, int nid)
@@ -446,14 +419,6 @@ static inline void * __init memblock_alloc_node(phys_addr_t size,
 				      MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 }
 
-static inline void * __init memblock_alloc_node_nopanic(phys_addr_t size,
-							int nid)
-{
-	return memblock_alloc_try_nid_nopanic(size, SMP_CACHE_BYTES,
-					      MEMBLOCK_LOW_LIMIT,
-					      MEMBLOCK_ALLOC_ACCESSIBLE, nid);
-}
-
 static inline void __init memblock_free_early(phys_addr_t base,
 					      phys_addr_t size)
 {
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index e78835c8..659fc2a5 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -248,7 +248,7 @@ swiotlb_init(int verbose)
 	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
 
 	/* Get IO TLB memory from the low pages */
-	vstart = memblock_alloc_low_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
+	vstart = memblock_alloc_low(PAGE_ALIGN(bytes), PAGE_SIZE);
 	if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
 		return;
 
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index c4f0a41..ae65221 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1147,17 +1147,14 @@ void __init setup_log_buf(int early)
 	if (!new_log_buf_len)
 		return;
 
-	if (early) {
-		new_log_buf =
-			memblock_alloc(new_log_buf_len, LOG_ALIGN);
-	} else {
-		new_log_buf = memblock_alloc_nopanic(new_log_buf_len,
-							  LOG_ALIGN);
-	}
-
+	new_log_buf = memblock_alloc(new_log_buf_len, LOG_ALIGN);
 	if (unlikely(!new_log_buf)) {
-		pr_err("log_buf_len: %lu bytes not available\n",
-			new_log_buf_len);
+		if (early)
+			panic("log_buf_len: %lu bytes not available\n",
+				new_log_buf_len);
+		else
+			pr_err("log_buf_len: %lu bytes not available\n",
+			       new_log_buf_len);
 		return;
 	}
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 7164275..522a44e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1491,41 +1491,6 @@ void * __init memblock_alloc_try_nid_raw(
 }
 
 /**
- * memblock_alloc_try_nid_nopanic - allocate boot memory block
- * @size: size of memory block to be allocated in bytes
- * @align: alignment of the region and block's size
- * @min_addr: the lower bound of the memory region from where the allocation
- *	  is preferred (phys address)
- * @max_addr: the upper bound of the memory region from where the allocation
- *	      is preferred (phys address), or %MEMBLOCK_ALLOC_ACCESSIBLE to
- *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
- *
- * Public function, provides additional debug information (including caller
- * info), if enabled. This function zeroes the allocated memory.
- *
- * Return:
- * Virtual address of allocated memory block on success, NULL on failure.
- */
-void * __init memblock_alloc_try_nid_nopanic(
-				phys_addr_t size, phys_addr_t align,
-				phys_addr_t min_addr, phys_addr_t max_addr,
-				int nid)
-{
-	void *ptr;
-
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
-		     __func__, (u64)size, (u64)align, nid, &min_addr,
-		     &max_addr, (void *)_RET_IP_);
-
-	ptr = memblock_alloc_internal(size, align,
-					   min_addr, max_addr, nid);
-	if (ptr)
-		memset(ptr, 0, size);
-	return ptr;
-}
-
-/**
  * memblock_alloc_try_nid - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7a5219..cd5c593 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6556,8 +6556,8 @@ static void __ref setup_usemap(struct pglist_data *pgdat,
 	zone->pageblock_flags = NULL;
 	if (usemapsize)
 		zone->pageblock_flags =
-			memblock_alloc_node_nopanic(usemapsize,
-							 pgdat->node_id);
+			memblock_alloc_node(usemapsize, SMP_CACHE_BYTES,
+					    pgdat->node_id);
 }
 #else
 static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
@@ -6786,7 +6786,8 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
-		map = memblock_alloc_node_nopanic(size, pgdat->node_id);
+		map = memblock_alloc_node(size, SMP_CACHE_BYTES,
+					  pgdat->node_id);
 		pgdat->node_mem_map = map + offset;
 	}
 	pr_debug("%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
@@ -8064,8 +8065,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 		size = bucketsize << log2qty;
 		if (flags & HASH_EARLY) {
 			if (flags & HASH_ZERO)
-				table = memblock_alloc_nopanic(size,
-							       SMP_CACHE_BYTES);
+				table = memblock_alloc(size, SMP_CACHE_BYTES);
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 0cfaa06..a3db109 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -161,7 +161,7 @@ static int __init alloc_node_page_ext(int nid)
 
 	table_size = get_entry_size() * nr_pages;
 
-	base = memblock_alloc_try_nid_nopanic(
+	base = memblock_alloc_try_nid(
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 			MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	if (!base)
diff --git a/mm/percpu.c b/mm/percpu.c
index 5998b03..e302b81 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1905,7 +1905,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 			  __alignof__(ai->groups[0].cpu_map[0]));
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
 
-	ptr = memblock_alloc_nopanic(PFN_ALIGN(ai_size), PAGE_SIZE);
+	ptr = memblock_alloc(PFN_ALIGN(ai_size), PAGE_SIZE);
 	if (!ptr)
 		return NULL;
 	ai = ptr;
@@ -2496,7 +2496,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	areas_size = PFN_ALIGN(ai->nr_groups * sizeof(void *));
 
-	areas = memblock_alloc_nopanic(areas_size, SMP_CACHE_BYTES);
+	areas = memblock_alloc(areas_size, SMP_CACHE_BYTES);
 	if (!areas) {
 		rc = -ENOMEM;
 		goto out_free;
@@ -2729,8 +2729,7 @@ EXPORT_SYMBOL(__per_cpu_offset);
 static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
 				       size_t align)
 {
-	return  memblock_alloc_from_nopanic(
-			size, align, __pa(MAX_DMA_ADDRESS));
+	return  memblock_alloc_from(size, align, __pa(MAX_DMA_ADDRESS));
 }
 
 static void __init pcpu_dfl_fc_free(void *ptr, size_t size)
@@ -2778,9 +2777,7 @@ void __init setup_per_cpu_areas(void)
 	void *fc;
 
 	ai = pcpu_alloc_alloc_info(1, 1);
-	fc = memblock_alloc_from_nopanic(unit_size,
-					      PAGE_SIZE,
-					      __pa(MAX_DMA_ADDRESS));
+	fc = memblock_alloc_from(unit_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 	if (!ai || !fc)
 		panic("Failed to allocate memory for percpu areas.");
 	/* kmemleak tracks the percpu allocations separately */
diff --git a/mm/sparse.c b/mm/sparse.c
index ad94242..1471f06 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -330,9 +330,7 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	limit = goal + (1UL << PA_SECTION_SHIFT);
 	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
 again:
-	p = memblock_alloc_try_nid_nopanic(size,
-						SMP_CACHE_BYTES, goal, limit,
-						nid);
+	p = memblock_alloc_try_nid(size, SMP_CACHE_BYTES, goal, limit, nid);
 	if (!p && limit) {
 		limit = 0;
 		goto again;
@@ -386,7 +384,7 @@ static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
-	return memblock_alloc_node_nopanic(size, pgdat->node_id);
+	return memblock_alloc_node(size, SMP_CACHE_BYTES, pgdat->node_id);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
-- 
2.7.4
