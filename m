Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8980F6B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:39:14 -0400 (EDT)
From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH for -3.5] memblock: free allocated memblock_reserved_regions later
Date: Fri, 29 Jun 2012 11:38:55 -0700
Message-Id: <1340995135-11488-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <20120629183233.GC21048@google.com>
References: <20120629183233.GC21048@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Tejun Heo <tj@kernel.org>, Sasha Levin <levinsasha928@gmail.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Yinghai Lu <yinghai@kernel.org>

In memblock_free_reserved_regions, will call memblock_free(),
but memblock_free() would double reserved.regions too, so we could free
old range for reserved.regions.

Also tj said there is another bug could be related to this too.

| I don't think we're saving any noticeable
| amount by doing this "free - give it to page allocator - reserve
| again" dancing.  We should just allocate regions aligned to page
| boundaries and free them later when memblock is no longer in use.

So try to allocate that in PAGE_SIZE alignment and free that later.

-v5: Use new_alloc_size, and old_alloc_size to simplify it according to tj.
-v6: update one comment according to tj.

Repored-by: Sasha Levin <levinsasha928@gmail.com>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 include/linux/memblock.h |    4 ---
 mm/memblock.c            |   51 +++++++++++++++++++++--------------------------
 mm/nobootmem.c           |   36 ++++++++++++++++++++-------------
 3 files changed, 46 insertions(+), 45 deletions(-)

Index: linux-2.6/include/linux/memblock.h
===================================================================
--- linux-2.6.orig/include/linux/memblock.h
+++ linux-2.6/include/linux/memblock.h
@@ -50,9 +50,7 @@ phys_addr_t memblock_find_in_range_node(
 				phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
-int memblock_free_reserved_regions(void);
-int memblock_reserve_reserved_regions(void);
-
+phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
Index: linux-2.6/mm/memblock.c
===================================================================
--- linux-2.6.orig/mm/memblock.c
+++ linux-2.6/mm/memblock.c
@@ -143,30 +143,6 @@ phys_addr_t __init_memblock memblock_fin
 					   MAX_NUMNODES);
 }
 
-/*
- * Free memblock.reserved.regions
- */
-int __init_memblock memblock_free_reserved_regions(void)
-{
-	if (memblock.reserved.regions == memblock_reserved_init_regions)
-		return 0;
-
-	return memblock_free(__pa(memblock.reserved.regions),
-		 sizeof(struct memblock_region) * memblock.reserved.max);
-}
-
-/*
- * Reserve memblock.reserved.regions
- */
-int __init_memblock memblock_reserve_reserved_regions(void)
-{
-	if (memblock.reserved.regions == memblock_reserved_init_regions)
-		return 0;
-
-	return memblock_reserve(__pa(memblock.reserved.regions),
-		 sizeof(struct memblock_region) * memblock.reserved.max);
-}
-
 static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
 {
 	type->total_size -= type->regions[r].size;
@@ -184,6 +160,18 @@ static void __init_memblock memblock_rem
 	}
 }
 
+phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
+					phys_addr_t *addr)
+{
+	if (memblock.reserved.regions == memblock_reserved_init_regions)
+		return 0;
+
+	*addr = __pa(memblock.reserved.regions);
+
+	return PAGE_ALIGN(sizeof(struct memblock_region) *
+			  memblock.reserved.max);
+}
+
 /**
  * memblock_double_array - double the size of the memblock regions array
  * @type: memblock type of the regions array being doubled
@@ -204,6 +192,7 @@ static int __init_memblock memblock_doub
 						phys_addr_t new_area_size)
 {
 	struct memblock_region *new_array, *old_array;
+	phys_addr_t old_alloc_size, new_alloc_size;
 	phys_addr_t old_size, new_size, addr;
 	int use_slab = slab_is_available();
 	int *in_slab;
@@ -217,6 +206,12 @@ static int __init_memblock memblock_doub
 	/* Calculate new doubled size */
 	old_size = type->max * sizeof(struct memblock_region);
 	new_size = old_size << 1;
+	/*
+	 * We need to allocated new one align to PAGE_SIZE,
+	 *   so we can free them completely later.
+	 */
+	old_alloc_size = PAGE_ALIGN(old_size);
+	new_alloc_size = PAGE_ALIGN(new_size);
 
 	/* Retrieve the slab flag */
 	if (type == &memblock.memory)
@@ -245,11 +240,11 @@ static int __init_memblock memblock_doub
 
 		addr = memblock_find_in_range(new_area_start + new_area_size,
 						memblock.current_limit,
-						new_size, sizeof(phys_addr_t));
+						new_alloc_size, PAGE_SIZE);
 		if (!addr && new_area_size)
 			addr = memblock_find_in_range(0,
 					min(new_area_start, memblock.current_limit),
-					new_size, sizeof(phys_addr_t));
+					new_alloc_size, PAGE_SIZE);
 
 		new_array = addr ? __va(addr) : 0;
 	}
@@ -279,13 +274,13 @@ static int __init_memblock memblock_doub
 		kfree(old_array);
 	else if (old_array != memblock_memory_init_regions &&
 		 old_array != memblock_reserved_init_regions)
-		memblock_free(__pa(old_array), old_size);
+		memblock_free(__pa(old_array), old_alloc_size);
 
 	/* Reserve the new array if that comes from the memblock.
 	 * Otherwise, we needn't do it
 	 */
 	if (!use_slab)
-		BUG_ON(memblock_reserve(addr, new_size));
+		BUG_ON(memblock_reserve(addr, new_alloc_size));
 
 	/* Update slab flag */
 	*in_slab = use_slab;
Index: linux-2.6/mm/nobootmem.c
===================================================================
--- linux-2.6.orig/mm/nobootmem.c
+++ linux-2.6/mm/nobootmem.c
@@ -105,27 +105,35 @@ static void __init __free_pages_memory(u
 		__free_pages_bootmem(pfn_to_page(i), 0);
 }
 
+static unsigned long __init __free_memory_core(phys_addr_t start,
+				 phys_addr_t end)
+{
+	unsigned long start_pfn = PFN_UP(start);
+	unsigned long end_pfn = min_t(unsigned long,
+				      PFN_DOWN(end), max_low_pfn);
+
+	if (start_pfn > end_pfn)
+		return 0;
+
+	__free_pages_memory(start_pfn, end_pfn);
+
+	return end_pfn - start_pfn;
+}
+
 unsigned long __init free_low_memory_core_early(int nodeid)
 {
 	unsigned long count = 0;
-	phys_addr_t start, end;
+	phys_addr_t start, end, size;
 	u64 i;
 
-	/* free reserved array temporarily so that it's treated as free area */
-	memblock_free_reserved_regions();
+	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
+		count += __free_memory_core(start, end);
 
-	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
-		unsigned long start_pfn = PFN_UP(start);
-		unsigned long end_pfn = min_t(unsigned long,
-					      PFN_DOWN(end), max_low_pfn);
-		if (start_pfn < end_pfn) {
-			__free_pages_memory(start_pfn, end_pfn);
-			count += end_pfn - start_pfn;
-		}
-	}
+	/* free range that is used for reserved array if we allocate it */
+	size = get_allocated_memblock_reserved_regions_info(&start);
+	if (size)
+		count += __free_memory_core(start, start + size);
 
-	/* put region array back? */
-	memblock_reserve_reserved_regions();
 	return count;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
