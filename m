Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id D731A6B00F8
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:51:59 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so3285414qeb.6
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:51:59 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id cz10si4227964qcb.12.2013.12.09.13.51.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:51:59 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v3 07/23] mm/memblock: switch to use NUMA_NO_NODE instead of MAX_NUMNODES
Date: Mon, 9 Dec 2013 16:50:40 -0500
Message-ID: <1386625856-12942-8-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

It's recommended to use NUMA_NO_NODE everywhere to select
"process any node" behavior or to indicate that "no node id specified".

Hence, update __next_free_mem_range*() API's to accept both NUMA_NO_NODE
and MAX_NUMNODES, but emit warning once on MAX_NUMNODES, and correct
corresponding API's documentation to describe new behavior.
Also, update other memblock/nobootmem APIs where MAX_NUMNODES is used
dirrectly.

The change was suggested by Tejun Heo <tj@kernel.org>.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 include/linux/memblock.h |    4 ++--
 mm/memblock.c            |   28 +++++++++++++++++++---------
 mm/nobootmem.c           |    8 ++++----
 3 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index dca4533..8607429 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -88,7 +88,7 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
@@ -108,7 +108,7 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 /**
  * for_each_free_mem_range_reverse - rev-iterate through free memblock areas
  * @i: u64 used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
diff --git a/mm/memblock.c b/mm/memblock.c
index 8786503..900057b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -91,7 +91,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Utility called from memblock_find_in_range_node(), find free area bottom-up.
  *
@@ -123,7 +123,7 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Utility called from memblock_find_in_range_node(), find free area top-down.
  *
@@ -158,7 +158,7 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  * @align: alignment of free area to find
  * @start: start of candidate range
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
@@ -239,7 +239,7 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 					phys_addr_t align)
 {
 	return memblock_find_in_range_node(size, align, start, end,
-					    MAX_NUMNODES);
+					    NUMA_NO_NODE);
 }
 
 static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
@@ -677,7 +677,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
@@ -705,6 +705,11 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 	struct memblock_type *rsv = &memblock.reserved;
 	int mi = *idx & 0xffffffff;
 	int ri = *idx >> 32;
+	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
+
+	if (nid == MAX_NUMNODES)
+		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
+			     __func__);
 
 	for ( ; mi < mem->cnt; mi++) {
 		struct memblock_region *m = &mem->regions[mi];
@@ -712,7 +717,7 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
+		if (check_node && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -753,7 +758,7 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 /**
  * __next_free_mem_range_rev - next function for for_each_free_mem_range_reverse()
  * @idx: pointer to u64 loop variable
- * @nid: nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: nid: node selector, %NUMA_NO_NODE for all nodes
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
@@ -768,6 +773,11 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 	struct memblock_type *rsv = &memblock.reserved;
 	int mi = *idx & 0xffffffff;
 	int ri = *idx >> 32;
+	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
+
+	if (nid == MAX_NUMNODES)
+		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
+			     __func__);
 
 	if (*idx == (u64)ULLONG_MAX) {
 		mi = mem->cnt - 1;
@@ -780,7 +790,7 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
+		if (check_node && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -903,7 +913,7 @@ phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int n
 
 phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return memblock_alloc_base_nid(size, align, max_addr, MAX_NUMNODES);
+	return memblock_alloc_base_nid(size, align, max_addr, NUMA_NO_NODE);
 }
 
 phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 59777e0..19121ce 100644
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
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
