Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id E87306B0039
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 10:54:57 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x13so2315328qcv.15
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 07:54:57 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id lc9si36651951qeb.100.2013.12.04.07.54.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 07:54:56 -0800 (PST)
Message-ID: <529F5047.50309@ti.com>
Date: Wed, 4 Dec 2013 10:54:47 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org>
In-Reply-To: <20131203232445.GX8277@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Tuesday 03 December 2013 06:24 PM, Tejun Heo wrote:
> Hello,
> 
> On Mon, Dec 02, 2013 at 09:27:23PM -0500, Santosh Shilimkar wrote:
>> So we add equivalent APIs so that we can replace usage of bootmem
>> with memblock interfaces. Architectures already converted to NO_BOOTMEM
>> use these new interfaces and other which still uses bootmem, these new
>> APIs just fallback to exiting bootmem APIs. So no functional change as
>> such.
> 
> The last part of the second last sentence doesn't parse too well.  I
> think it'd be worthwhile to improve and preferably expand on it as
> this is a bit tricky to understand given the twisted state of early
> memory allocation.
> 
Ok. Will expand bit more. Also agree with rest of the comments and
will fix accordingly except one ;-)

> 
>> +/*
>> + * FIXME: use NUMA_NO_NODE instead of MAX_NUMNODES when bootmem/nobootmem code
>> + * will be removed.
>> + * It can't be done now, because when MEMBLOCK or NO_BOOTMEM are not enabled
>> + * all calls of the new API will be redirected to bottmem/nobootmem where
>> + * MAX_NUMNODES is widely used.
> 
> I don't know.  We're introducing a new API which will be used across
> the kernel.  I don't think it makes a lot of sense to use the wrong
> constant now to convert all the users later.  Wouldn't it be better to
> make the new interface take NUMA_NO_NODE and do whatever it needs to
> do to interface with bootmem?
> 
Well as you know there are architectures still using bootmem even after
this series. Changing MAX_NUMNODES to NUMA_NO_NODE is too invasive and
actually should be done in a separate series. As commented, the best
time to do that would be when all remaining architectures moves to
memblock.

Just to give you perspective, look at the patch end of the email which
Grygorrii cooked up. It doesn't cover all the users of MAX_NUMNODES
and we are bot even sure whether the change is correct and its
impact on the code which we can't even tests. I would really want to
avoid touching all the architectures and keep the scope of the series
to core code as we aligned initially.

May be you have better idea to handle this change so do
let us know how to proceed with it. With such a invasive change the
$subject series can easily get into circles again :-(

Regards,
Santosh

---
 arch/ia64/mm/discontig.c |    2 +-
 arch/powerpc/mm/numa.c   |    2 +-
 arch/s390/mm/init.c      |    2 +-
 arch/sparc/mm/init_64.c  |    2 +-
 arch/x86/kernel/check.c  |    2 +-
 arch/x86/kernel/e820.c   |    4 ++--
 arch/x86/mm/init.c       |    2 +-
 arch/x86/mm/init_32.c    |    2 +-
 arch/x86/mm/init_64.c    |    2 +-
 arch/x86/mm/memtest.c    |    2 +-
 arch/x86/mm/numa.c       |    2 +-
 include/linux/bootmem.h  |   20 ++++----------------
 include/linux/memblock.h |    6 +++---
 mm/memblock.c            |   43 ++++++++++++++++++++-----------------------
 mm/nobootmem.c           |    8 ++++----
 mm/page_alloc.c          |   18 +++++++++---------
 mm/percpu.c              |    4 ++--
 17 files changed, 54 insertions(+), 69 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 2de08f4..81ec37c 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -764,7 +764,7 @@ void __init paging_init(void)
 
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
-	sparse_memory_present_with_active_regions(MAX_NUMNODES);
+	sparse_memory_present_with_active_regions(NUMA_NO_NODE);
 	sparse_init();
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 078d3e0..817a8b5 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -142,7 +142,7 @@ static void __init get_node_active_region(unsigned long pfn,
 	unsigned long start_pfn, end_pfn;
 	int i, nid;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start_pfn, &end_pfn, &nid) {
 		if (pfn >= start_pfn && pfn < end_pfn) {
 			node_ar->nid = nid;
 			node_ar->start_pfn = start_pfn;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index ad446b0..f06220f 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -126,7 +126,7 @@ void __init paging_init(void)
 
 	atomic_set(&init_mm.context.attach_count, 1);
 
-	sparse_memory_present_with_active_regions(MAX_NUMNODES);
+	sparse_memory_present_with_active_regions(NUMA_NO_NODE);
 	sparse_init();
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 	max_zone_pfns[ZONE_DMA] = PFN_DOWN(MAX_DMA_ADDRESS);
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 5322e53..5b9458a 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -1346,7 +1346,7 @@ static unsigned long __init bootmem_init(unsigned long phys_base)
 
 	/* XXX cpu notifier XXX */
 
-	sparse_memory_present_with_active_regions(MAX_NUMNODES);
+	sparse_memory_present_with_active_regions(NUMA_NO_NODE);
 	sparse_init();
 
 	return end_pfn;
diff --git a/arch/x86/kernel/check.c b/arch/x86/kernel/check.c
index e2dbcb7..83a7995 100644
--- a/arch/x86/kernel/check.c
+++ b/arch/x86/kernel/check.c
@@ -91,7 +91,7 @@ void __init setup_bios_corruption_check(void)
 
 	corruption_check_size = round_up(corruption_check_size, PAGE_SIZE);
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
+	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL) {
 		start = clamp_t(phys_addr_t, round_up(start, PAGE_SIZE),
 				PAGE_SIZE, corruption_check_size);
 		end = clamp_t(phys_addr_t, round_down(end, PAGE_SIZE),
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 174da5f..050b01e 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1114,13 +1114,13 @@ void __init memblock_find_dma_reserve(void)
 	 * need to use memblock to get free size in [0, MAX_DMA_PFN]
 	 * at first, and assume boot_mem will not take below MAX_DMA_PFN
 	 */
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, NULL) {
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start_pfn, &end_pfn, NULL) {
 		start_pfn = min_t(unsigned long, start_pfn, MAX_DMA_PFN);
 		end_pfn = min_t(unsigned long, end_pfn, MAX_DMA_PFN);
 		nr_pages += end_pfn - start_pfn;
 	}
 
-	for_each_free_mem_range(u, MAX_NUMNODES, &start, &end, NULL) {
+	for_each_free_mem_range(u, NUMA_NO_NODE, &start, &end, NULL) {
 		start_pfn = min_t(unsigned long, PFN_UP(start), MAX_DMA_PFN);
 		end_pfn = min_t(unsigned long, PFN_DOWN(end), MAX_DMA_PFN);
 		if (start_pfn < end_pfn)
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index f971306..ce959fa 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -379,7 +379,7 @@ static unsigned long __init init_range_memory_mapping(
 	unsigned long mapped_ram_size = 0;
 	int i;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, NULL) {
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start_pfn, &end_pfn, NULL) {
 		u64 start = clamp_val(PFN_PHYS(start_pfn), r_start, r_end);
 		u64 end = clamp_val(PFN_PHYS(end_pfn), r_start, r_end);
 		if (start >= end)
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 4287f1f..920e3bc 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -706,7 +706,7 @@ void __init paging_init(void)
 	 * NOTE: at this point the bootmem allocator is fully available.
 	 */
 	olpc_dt_build_devicetree();
-	sparse_memory_present_with_active_regions(MAX_NUMNODES);
+	sparse_memory_present_with_active_regions(NUMA_NO_NODE);
 	sparse_init();
 	zone_sizes_init();
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 104d56a..3d5ab67 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -649,7 +649,7 @@ void __init initmem_init(void)
 
 void __init paging_init(void)
 {
-	sparse_memory_present_with_active_regions(MAX_NUMNODES);
+	sparse_memory_present_with_active_regions(NUMA_NO_NODE);
 	sparse_init();
 
 	/*
diff --git a/arch/x86/mm/memtest.c b/arch/x86/mm/memtest.c
index 8dabbed..1e9da79 100644
--- a/arch/x86/mm/memtest.c
+++ b/arch/x86/mm/memtest.c
@@ -74,7 +74,7 @@ static void __init do_one_pass(u64 pattern, u64 start, u64 end)
 	u64 i;
 	phys_addr_t this_start, this_end;
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &this_start, &this_end, NULL) {
+	for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) {
 		this_start = clamp_t(phys_addr_t, this_start, start, end);
 		this_end = clamp_t(phys_addr_t, this_end, start, end);
 		if (this_start < this_end) {
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 24aec58..b4ec91a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -561,7 +561,7 @@ static int __init numa_init(int (*init_func)(void))
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
-	WARN_ON(memblock_set_node(0, ULLONG_MAX, MAX_NUMNODES));
+	WARN_ON(memblock_set_node(0, ULLONG_MAX, NUMA_NO_NODE));
 	numa_reset_distance();
 
 	ret = init_func();
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index d333ac4..b518b75 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -148,18 +148,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define BOOTMEM_ALLOC_ACCESSIBLE	0
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
 
-/*
- * FIXME: use NUMA_NO_NODE instead of MAX_NUMNODES when bootmem/nobootmem code
- * will be removed.
- * It can't be done now, because when MEMBLOCK or NO_BOOTMEM are not enabled
- * all calls of the new API will be redirected to bottmem/nobootmem where
- * MAX_NUMNODES is widely used.
- * Also, memblock core APIs __next_free_mem_range_rev() and
- * __next_free_mem_range() would need to be updated, and as result we will
- * need to re-check/update all direct calls of memblock_alloc_xxx()
- * APIs (including nobootmem).
- */
-
 /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
 void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t from,
@@ -171,20 +159,20 @@ void __memblock_free_late(phys_addr_t base, phys_addr_t size);
 
 #define memblock_virt_alloc(x) \
 	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
-				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+				     BOOTMEM_ALLOC_ACCESSIBLE, NUMA_NO_NODE)
 #define memblock_virt_alloc_align(x, align) \
 	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
-				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+				     BOOTMEM_ALLOC_ACCESSIBLE, NUMA_NO_NODE)
 #define memblock_virt_alloc_nopanic(x) \
 	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
 					     BOOTMEM_LOW_LIMIT, \
 					     BOOTMEM_ALLOC_ACCESSIBLE, \
-					     MAX_NUMNODES)
+					     NUMA_NO_NODE)
 #define memblock_virt_alloc_align_nopanic(x, align) \
 	memblock_virt_alloc_try_nid_nopanic(x, align, \
 					     BOOTMEM_LOW_LIMIT, \
 					     BOOTMEM_ALLOC_ACCESSIBLE, \
-					     MAX_NUMNODES)
+					     NUMA_NO_NODE)
 #define memblock_virt_alloc_node(x, nid) \
 	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
 				     BOOTMEM_ALLOC_ACCESSIBLE, nid)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 77c60e5..c3b8c1f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -69,7 +69,7 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
  * @i: an integer used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to ulong for start pfn of the range, can be %NULL
  * @p_end: ptr to ulong for end pfn of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
@@ -87,7 +87,7 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
@@ -107,7 +107,7 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 /**
  * for_each_free_mem_range_reverse - rev-iterate through free memblock areas
  * @i: u64 used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
diff --git a/mm/memblock.c b/mm/memblock.c
index 3311fbb..e2de30f 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -94,7 +94,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Utility called from memblock_find_in_range_node(), find free area bottom-up.
  *
@@ -126,7 +126,7 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Utility called from memblock_find_in_range_node(), find free area top-down.
  *
@@ -161,7 +161,7 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
@@ -242,7 +242,7 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 					phys_addr_t align)
 {
 	return memblock_find_in_range_node(start, end, size, align,
-					   MAX_NUMNODES);
+					    NUMA_NO_NODE);
 }
 
 static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
@@ -258,7 +258,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 		type->cnt = 1;
 		type->regions[0].base = 0;
 		type->regions[0].size = 0;
-		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
+		memblock_set_region_node(&type->regions[0], NUMA_NO_NODE);
 	}
 }
 
@@ -558,7 +558,7 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_add_region(&memblock.memory, base, size, MAX_NUMNODES);
+	return memblock_add_region(&memblock.memory, base, size, NUMA_NO_NODE);
 }
 
 /**
@@ -674,13 +674,13 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
-	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+	return memblock_add_region(_rgn, base, size, NUMA_NO_NODE);
 }
 
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
@@ -715,7 +715,7 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -756,7 +756,7 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 /**
  * __next_free_mem_range_rev - next function for for_each_free_mem_range_reverse()
  * @idx: pointer to u64 loop variable
- * @nid: nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: nid: node selector, %NUMA_NO_NODE for all nodes
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
@@ -783,7 +783,7 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -833,7 +833,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 
 		if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
 			continue;
-		if (nid == MAX_NUMNODES || nid == r->nid)
+		if (nid == NUMA_NO_NODE || nid == r->nid)
 			break;
 	}
 	if (*idx >= type->cnt) {
@@ -906,7 +906,7 @@ phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int n
 
 phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return memblock_alloc_base_nid(size, align, max_addr, MAX_NUMNODES);
+	return memblock_alloc_base_nid(size, align, max_addr, NUMA_NO_NODE);
 }
 
 phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
@@ -945,7 +945,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * The @from limit is dropped if it can not be satisfied and the allocation
  * will fall back to memory below @from.
@@ -971,10 +971,7 @@ static void * __init _memblock_virt_alloc_try_nid_nopanic(
 	void *ptr;
 
 	if (WARN_ON_ONCE(slab_is_available())) {
-		if (nid == MAX_NUMNODES)
-			return kzalloc(size, GFP_NOWAIT);
-		else
-			return kzalloc_node(size, GFP_NOWAIT, nid);
+		return kzalloc_node(size, GFP_NOWAIT, nid);
 	}
 
 	if (!align)
@@ -988,9 +985,9 @@ again:
 	if (alloc)
 		goto done;
 
-	if (nid != MAX_NUMNODES) {
+	if (nid != NUMA_NO_NODE) {
 		alloc = memblock_find_in_range_node(from, max_addr, size,
-						    align, MAX_NUMNODES);
+						    align, NUMA_NO_NODE);
 		if (alloc)
 			goto done;
 	}
@@ -1028,7 +1025,7 @@ error:
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
  * additional debug information (including caller info), if enabled.
@@ -1057,7 +1054,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
@@ -1320,7 +1317,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 		base = rgn->base;
 		size = rgn->size;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-		if (memblock_get_region_node(rgn) != MAX_NUMNODES)
+		if (memblock_get_region_node(rgn) != NUMA_NO_NODE)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 2c254d3..3bf678c 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -117,7 +117,7 @@ static unsigned long __init free_low_memory_core_early(void)
 	phys_addr_t start, end, size;
 	u64 i;
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
+	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
 	/* free range that is used for reserved array if we allocate it */
@@ -161,7 +161,7 @@ unsigned long __init free_all_bootmem(void)
 	reset_all_zones_managed_pages();
 
 	/*
-	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
+	 * We need to use NUMA_NO_NODE instead of NODE_DATA(0)->node_id
 	 *  because in some case like Node0 doesn't have RAM installed
 	 *  low ram will be on Node1
 	 */
@@ -215,7 +215,7 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 
 restart:
 
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, limit);
+	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align, goal, limit);
 
 	if (ptr)
 		return ptr;
@@ -299,7 +299,7 @@ again:
 	if (ptr)
 		return ptr;
 
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align,
 					goal, limit);
 	if (ptr)
 		return ptr;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 68a30f6..fff0035 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4347,7 +4347,7 @@ bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 
 /**
  * free_bootmem_with_active_regions - Call memblock_free_early_nid for each active range
- * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
+ * @nid: The node to free memory on. If NUMA_NO_NODE, all nodes are freed.
  * @max_low_pfn: The highest PFN that will be passed to memblock_free_early_nid
  *
  * If an architecture guarantees that all ranges registered with
@@ -4373,7 +4373,7 @@ void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
 
 /**
  * sparse_memory_present_with_active_regions - Call memory_present for each active range
- * @nid: The node to call memory_present for. If MAX_NUMNODES, all nodes will be used.
+ * @nid: The node to call memory_present for. If NUMA_NO_NODE, all nodes will be used.
  *
  * If an architecture guarantees that all ranges registered with
  * add_active_ranges() contain no holes and may be freed, this
@@ -4390,7 +4390,7 @@ void __init sparse_memory_present_with_active_regions(int nid)
 
 /**
  * get_pfn_range_for_nid - Return the start and end page frames for a node
- * @nid: The nid to return the range for. If MAX_NUMNODES, the min and max PFN are returned.
+ * @nid: The nid to return the range for. If NUMA_NO_NODE, the min and max PFN are returned.
  * @start_pfn: Passed by reference. On return, it will have the node start_pfn.
  * @end_pfn: Passed by reference. On return, it will have the node end_pfn.
  *
@@ -4506,7 +4506,7 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 }
 
 /*
- * Return the number of holes in a range on a node. If nid is MAX_NUMNODES,
+ * Return the number of holes in a range on a node. If nid is NUMA_NO_NODE,
  * then all holes in the requested range will be accounted for.
  */
 unsigned long __meminit __absent_pages_in_range(int nid,
@@ -4535,7 +4535,7 @@ unsigned long __meminit __absent_pages_in_range(int nid,
 unsigned long __init absent_pages_in_range(unsigned long start_pfn,
 							unsigned long end_pfn)
 {
-	return __absent_pages_in_range(MAX_NUMNODES, start_pfn, end_pfn);
+	return __absent_pages_in_range(NUMA_NO_NODE, start_pfn, end_pfn);
 }
 
 /* Return the number of page frames in holes in a zone on a node */
@@ -4926,7 +4926,7 @@ unsigned long __init node_map_pfn_alignment(void)
 	int last_nid = -1;
 	int i, nid;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start, &end, &nid) {
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start, &end, &nid) {
 		if (!start || last_nid < 0 || last_nid == nid) {
 			last_nid = nid;
 			last_end = end;
@@ -4977,7 +4977,7 @@ static unsigned long __init find_min_pfn_for_node(int nid)
  */
 unsigned long __init find_min_pfn_with_active_regions(void)
 {
-	return find_min_pfn_for_node(MAX_NUMNODES);
+	return find_min_pfn_for_node(NUMA_NO_NODE);
 }
 
 /*
@@ -4991,7 +4991,7 @@ static unsigned long __init early_calculate_totalpages(void)
 	unsigned long start_pfn, end_pfn;
 	int i, nid;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start_pfn, &end_pfn, &nid) {
 		unsigned long pages = end_pfn - start_pfn;
 
 		totalpages += pages;
@@ -5231,7 +5231,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 	/* Print out the early node map */
 	printk("Early memory node ranges\n");
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
+	for_each_mem_pfn_range(i, NUMA_NO_NODE, &start_pfn, &end_pfn, &nid)
 		printk("  node %3d: [mem %#010lx-%#010lx]\n", nid,
 		       start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);
 
diff --git a/mm/percpu.c b/mm/percpu.c
index f74902c..f7cc387 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1853,7 +1853,7 @@ static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
 	return  memblock_virt_alloc_try_nid_nopanic(size, align,
 						     __pa(MAX_DMA_ADDRESS),
 						     BOOTMEM_ALLOC_ACCESSIBLE,
-						     MAX_NUMNODES);
+						     NUMA_NO_NODE);
 }
 
 static void __init pcpu_dfl_fc_free(void *ptr, size_t size)
@@ -1905,7 +1905,7 @@ void __init setup_per_cpu_areas(void)
 						 PAGE_SIZE,
 						 __pa(MAX_DMA_ADDRESS),
 						 BOOTMEM_ALLOC_ACCESSIBLE,
-						 MAX_NUMNODES);
+						 NUMA_NO_NODE);
 	if (!ai || !fc)
 		panic("Failed to allocate memory for percpu areas.");
 	/* kmemleak tracks the percpu allocations separately */
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
