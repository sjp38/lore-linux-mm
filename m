Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 269C06B3E3D
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:45:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so7974201edm.18
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 13:45:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p8-v6si7474431ejq.121.2018.11.25.13.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 13:44:59 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAPLi5sh091902
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:44:57 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nymsk73dc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:44:57 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 25 Nov 2018 21:44:55 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/5] powerpc: prefer memblock APIs returning virtual address
Date: Sun, 25 Nov 2018 23:44:33 +0200
In-Reply-To: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1543182277-8819-2-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

There are a several places that allocate memory using memblock APIs that
return a physical address, convert the returned address to the virtual
address and frequently also memset(0) the allocated range.

Update these places to use memblock allocators already returning a virtual
address; use memblock functions that clear the allocated memory instead of
calling memset(0).

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/powerpc/kernel/paca.c             | 14 ++++++--------
 arch/powerpc/kernel/setup_64.c         | 21 ++++++++++-----------
 arch/powerpc/mm/hash_utils_64.c        |  6 +++---
 arch/powerpc/mm/pgtable-book3e.c       |  8 ++------
 arch/powerpc/mm/pgtable-book3s64.c     |  5 +----
 arch/powerpc/mm/pgtable-radix.c        | 24 +++++++++---------------
 arch/powerpc/platforms/pasemi/iommu.c  |  5 +++--
 arch/powerpc/platforms/pseries/setup.c | 11 +++++++----
 arch/powerpc/sysdev/dart_iommu.c       |  5 +++--
 9 files changed, 44 insertions(+), 55 deletions(-)

diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 913bfca..fa884ad 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -27,7 +27,7 @@
 static void *__init alloc_paca_data(unsigned long size, unsigned long align,
 				unsigned long limit, int cpu)
 {
-	unsigned long pa;
+	void *ptr;
 	int nid;
 
 	/*
@@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
 		nid = early_cpu_to_node(cpu);
 	}
 
-	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
-	if (!pa) {
-		pa = memblock_alloc_base(size, align, limit);
-		if (!pa)
-			panic("cannot allocate paca data");
-	}
+	ptr = memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
+					 limit, nid);
+	if (!ptr)
+		panic("cannot allocate paca data");
 
 	if (cpu == boot_cpuid)
 		memblock_set_bottom_up(false);
 
-	return __va(pa);
+	return ptr;
 }
 
 #ifdef CONFIG_PPC_PSERIES
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 236c115..d11ee7f 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -634,19 +634,17 @@ __init u64 ppc64_bolted_size(void)
 
 static void *__init alloc_stack(unsigned long limit, int cpu)
 {
-	unsigned long pa;
+	void *ptr;
 
 	BUILD_BUG_ON(STACK_INT_FRAME_SIZE % 16);
 
-	pa = memblock_alloc_base_nid(THREAD_SIZE, THREAD_SIZE, limit,
-					early_cpu_to_node(cpu), MEMBLOCK_NONE);
-	if (!pa) {
-		pa = memblock_alloc_base(THREAD_SIZE, THREAD_SIZE, limit);
-		if (!pa)
-			panic("cannot allocate stacks");
-	}
+	ptr = memblock_alloc_try_nid_raw(THREAD_SIZE, THREAD_SIZE,
+					 MEMBLOCK_LOW_LIMIT, limit,
+					 early_cpu_to_node(cpu));
+	if (!ptr)
+		panic("cannot allocate stacks");
 
-	return __va(pa);
+	return ptr;
 }
 
 void __init irqstack_early_init(void)
@@ -933,8 +931,9 @@ static void __ref init_fallback_flush(void)
 	 * hardware prefetch runoff. We don't have a recipe for load patterns to
 	 * reliably avoid the prefetcher.
 	 */
-	l1d_flush_fallback_area = __va(memblock_alloc_base(l1d_size * 2, l1d_size, limit));
-	memset(l1d_flush_fallback_area, 0, l1d_size * 2);
+	l1d_flush_fallback_area = memblock_alloc_try_nid(l1d_size * 2,
+						l1d_size, MEMBLOCK_LOW_LIMIT,
+						limit, NUMA_NO_NODE);
 
 	for_each_possible_cpu(cpu) {
 		struct paca_struct *paca = paca_ptrs[cpu];
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 0cc7fbc..bc6be44 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -908,9 +908,9 @@ static void __init htab_initialize(void)
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	if (debug_pagealloc_enabled()) {
 		linear_map_hash_count = memblock_end_of_DRAM() >> PAGE_SHIFT;
-		linear_map_hash_slots = __va(memblock_alloc_base(
-				linear_map_hash_count, 1, ppc64_rma_size));
-		memset(linear_map_hash_slots, 0, linear_map_hash_count);
+		linear_map_hash_slots = memblock_alloc_try_nid(
+				linear_map_hash_count, 1, MEMBLOCK_LOW_LIMIT,
+				ppc64_rma_size,	NUMA_NO_NODE);
 	}
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
diff --git a/arch/powerpc/mm/pgtable-book3e.c b/arch/powerpc/mm/pgtable-book3e.c
index e0ccf36..53cbc7d 100644
--- a/arch/powerpc/mm/pgtable-book3e.c
+++ b/arch/powerpc/mm/pgtable-book3e.c
@@ -57,12 +57,8 @@ void vmemmap_remove_mapping(unsigned long start,
 
 static __ref void *early_alloc_pgtable(unsigned long size)
 {
-	void *pt;
-
-	pt = __va(memblock_alloc_base(size, size, __pa(MAX_DMA_ADDRESS)));
-	memset(pt, 0, size);
-
-	return pt;
+	return memblock_alloc_try_nid(size, size, MEMBLOCK_LOW_LIMIT,
+				      __pa(MAX_DMA_ADDRESS), NUMA_NO_NODE);
 }
 
 /*
diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
index 9f93c9f..70d5478 100644
--- a/arch/powerpc/mm/pgtable-book3s64.c
+++ b/arch/powerpc/mm/pgtable-book3s64.c
@@ -195,11 +195,8 @@ void __init mmu_partition_table_init(void)
 	unsigned long ptcr;
 
 	BUILD_BUG_ON_MSG((PATB_SIZE_SHIFT > 36), "Partition table size too large.");
-	partition_tb = __va(memblock_alloc_base(patb_size, patb_size,
-						MEMBLOCK_ALLOC_ANYWHERE));
-
 	/* Initialize the Partition Table with no entries */
-	memset((void *)partition_tb, 0, patb_size);
+	partition_tb = memblock_alloc(patb_size, patb_size);
 
 	/*
 	 * update partition table control register,
diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
index 9311560..415a1eb0 100644
--- a/arch/powerpc/mm/pgtable-radix.c
+++ b/arch/powerpc/mm/pgtable-radix.c
@@ -51,24 +51,18 @@ static int native_register_process_table(unsigned long base, unsigned long pg_sz
 static __ref void *early_alloc_pgtable(unsigned long size, int nid,
 			unsigned long region_start, unsigned long region_end)
 {
-	unsigned long pa = 0;
+	phys_addr_t min_addr = MEMBLOCK_LOW_LIMIT;
+	phys_addr_t max_addr = MEMBLOCK_ALLOC_ANYWHERE;
 	void *pt;
 
-	if (region_start || region_end) /* has region hint */
-		pa = memblock_alloc_range(size, size, region_start, region_end,
-						MEMBLOCK_NONE);
-	else if (nid != -1) /* has node hint */
-		pa = memblock_alloc_base_nid(size, size,
-						MEMBLOCK_ALLOC_ANYWHERE,
-						nid, MEMBLOCK_NONE);
+	if (region_start)
+		min_addr = region_start;
+	if (region_end)
+		max_addr = region_end;
 
-	if (!pa)
-		pa = memblock_alloc_base(size, size, MEMBLOCK_ALLOC_ANYWHERE);
-
-	BUG_ON(!pa);
-
-	pt = __va(pa);
-	memset(pt, 0, size);
+	pt = memblock_alloc_try_nid_nopanic(size, size, min_addr, max_addr,
+					    nid);
+	BUG_ON(!pt);
 
 	return pt;
 }
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index f297152..f62930f 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -208,7 +208,9 @@ static int __init iob_init(struct device_node *dn)
 	pr_debug(" -> %s\n", __func__);
 
 	/* For 2G space, 8x64 pages (2^21 bytes) is max total l2 size */
-	iob_l2_base = (u32 *)__va(memblock_alloc_base(1UL<<21, 1UL<<21, 0x80000000));
+	iob_l2_base = memblock_alloc_try_nid_raw(1UL << 21, 1UL << 21,
+					MEMBLOCK_LOW_LIMIT, 0x80000000,
+					NUMA_NO_NODE);
 
 	pr_info("IOBMAP L2 allocated at: %p\n", iob_l2_base);
 
@@ -269,4 +271,3 @@ void __init iommu_init_early_pasemi(void)
 	pasemi_pci_controller_ops.dma_bus_setup = pci_dma_bus_setup_pasemi;
 	set_pci_dma_ops(&dma_iommu_ops);
 }
-
diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
index 0f553dc..715ed61 100644
--- a/arch/powerpc/platforms/pseries/setup.c
+++ b/arch/powerpc/platforms/pseries/setup.c
@@ -130,8 +130,10 @@ static void __init fwnmi_init(void)
 	 * It will be used in real mode mce handler, hence it needs to be
 	 * below RMA.
 	 */
-	mce_data_buf = __va(memblock_alloc_base(RTAS_ERROR_LOG_MAX * nr_cpus,
-					RTAS_ERROR_LOG_MAX, ppc64_rma_size));
+	mce_data_buf = memblock_alloc_try_nid_raw(RTAS_ERROR_LOG_MAX * nr_cpus,
+					RTAS_ERROR_LOG_MAX, MEMBLOCK_LOW_LIMIT,
+					ppc64_rma_size, NUMA_NO_NODE);
+
 	for_each_possible_cpu(i) {
 		paca_ptrs[i]->mce_data_buf = mce_data_buf +
 						(RTAS_ERROR_LOG_MAX * i);
@@ -140,8 +142,9 @@ static void __init fwnmi_init(void)
 #ifdef CONFIG_PPC_BOOK3S_64
 	/* Allocate per cpu slb area to save old slb contents during MCE */
 	size = sizeof(struct slb_entry) * mmu_slb_size * nr_cpus;
-	slb_ptr = __va(memblock_alloc_base(size, sizeof(struct slb_entry),
-					   ppc64_rma_size));
+	slb_ptr = memblock_alloc_try_nid_raw(size, sizeof(struct slb_entry),
+					MEMBLOCK_LOW_LIMIT, ppc64_rma_size,
+					NUMA_NO_NODE);
 	for_each_possible_cpu(i)
 		paca_ptrs[i]->mce_faulty_slbs = slb_ptr + (mmu_slb_size * i);
 #endif
diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index a5b40d1..ac6d235 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -251,8 +251,9 @@ static void allocate_dart(void)
 	 * 16MB (1 << 24) alignment. We allocate a full 16Mb chuck since we
 	 * will blow up an entire large page anyway in the kernel mapping.
 	 */
-	dart_tablebase = __va(memblock_alloc_base(1UL<<24,
-						  1UL<<24, 0x80000000L));
+	dart_tablebase = memblock_alloc_try_nid_raw(1UL << 24, 1UL << 24,
+					MEMBLOCK_LOW_LIMIT, 0x80000000L,
+					NUMA_NO_NODE);
 
 	/* There is no point scanning the DART space for leaks*/
 	kmemleak_no_scan((void *)dart_tablebase);
-- 
2.7.4
