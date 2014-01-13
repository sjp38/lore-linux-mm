Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 19D706B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 07:49:11 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so3372232eaj.9
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 04:49:10 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id l2si28490526een.209.2014.01.13.04.49.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 04:49:10 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 13 Jan 2014 12:49:09 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 42F762190059
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:49:05 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0DCmsJL62849162
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:48:54 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0DCn5sa015484
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 05:49:06 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V2 2/2] mm/memblock: Add support for excluded memory areas
Date: Mon, 13 Jan 2014 13:49:01 +0100
Message-Id: <1389617341-568-3-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1389617341-568-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389617341-568-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, phacht@linux.vnet.ibm.com, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com

Add a new memory state "nomap" to memblock. This can be used to truncate
the usable memory in the system without forgetting about what is really
installed.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 include/linux/memblock.h |  50 +++++++--
 mm/Kconfig               |   3 +
 mm/memblock.c            | 259 +++++++++++++++++++++++++++++++++++------------
 mm/nobootmem.c           |   9 ++
 4 files changed, 251 insertions(+), 70 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1ef6636..2333d3f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 
 #define INIT_MEMBLOCK_REGIONS	128
+#define INIT_MEMBLOCK_NOMAP_REGIONS 4
 
 /* Definition of memblock flags. */
 #define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
@@ -43,6 +44,9 @@ struct memblock {
 	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	struct memblock_type nomap;
+#endif
 };
 
 extern struct memblock memblock;
@@ -68,6 +72,10 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+int memblock_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_remap(phys_addr_t base, phys_addr_t size);
+#endif
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
@@ -113,8 +121,9 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
-			   phys_addr_t *out_end, int *out_nid);
+void __next_mem_range(u64 *idx, int nid, struct memblock_type *type_a,
+		      struct memblock_type *type_b, phys_addr_t *out_start,
+		      phys_addr_t *out_end, int *out_nid);
 
 /**
  * for_each_free_mem_range - iterate through free memblock areas
@@ -129,12 +138,31 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
  */
 #define for_each_free_mem_range(i, nid, p_start, p_end, p_nid)		\
 	for (i = 0,							\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid);	\
+		     __next_mem_range(&i, nid, &memblock.memory,	\
+				      &memblock.reserved, p_start,	\
+				      p_end, p_nid);			\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_mem_range(&i, nid, &memblock.memory,		\
+			       &memblock.reserved,			\
+			       p_start, p_end, p_nid))
+
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+#define for_each_mapped_mem_range(i, nid, p_start, p_end, p_nid)	\
+	for (i = 0,							\
+		     __next_mem_range(&i, nid, &memblock.memory,	\
+				      &memblock.nomap, p_start,		\
+				      p_end, p_nid);			\
 	     i != (u64)ULLONG_MAX;					\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid))
+	     __next_mem_range(&i, nid, &memblock.memory,		\
+			       &memblock.nomap,				\
+			       p_start, p_end, p_nid))
+#endif
 
-void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
-			       phys_addr_t *out_end, int *out_nid);
+void __next_mem_range_rev(u64 *idx, int nid,
+			  struct memblock_type *type_a,
+			  struct memblock_type *type_b,
+			  phys_addr_t *out_start,
+			  phys_addr_t *out_end, int *out_nid);
 
 /**
  * for_each_free_mem_range_reverse - rev-iterate through free memblock areas
@@ -149,9 +177,15 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
  */
 #define for_each_free_mem_range_reverse(i, nid, p_start, p_end, p_nid)	\
 	for (i = (u64)ULLONG_MAX,					\
-	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid);	\
+		     __next_mem_range_rev(&i, nid,			\
+					  &memblock.memory,		\
+					  &memblock.reserved,		\
+					  p_start, p_end, p_nid);	\
 	     i != (u64)ULLONG_MAX;					\
-	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
+	     __next_mem_range_rev(&i, nid,				\
+				  &memblock.memory,			\
+				  &memblock.reserved,			\
+				  p_start, p_end, p_nid))
 
 static inline void memblock_set_region_flags(struct memblock_region *r,
 					     unsigned long flags)
diff --git a/mm/Kconfig b/mm/Kconfig
index 2d9f150..6907654 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config ARCH_DISCARD_MEMBLOCK
 	boolean
 
+config ARCH_MEMBLOCK_NOMAP
+	boolean
+
 config NO_BOOTMEM
 	boolean
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 9c0aeef..36070fa 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -28,6 +28,11 @@
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+static struct memblock_region
+memblock_nomap_init_regions[INIT_MEMBLOCK_NOMAP_REGIONS] __initdata_memblock;
+#endif
+
 struct memblock memblock __initdata_memblock = {
 	.memory.regions		= memblock_memory_init_regions,
 	.memory.cnt		= 1,	/* empty dummy entry */
@@ -37,6 +42,11 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	.nomap.regions       = memblock_nomap_init_regions,
+	.nomap.cnt           = 1,	/* empty dummy entry */
+	.nomap.max           = INIT_MEMBLOCK_NOMAP_REGIONS,
+#endif
 	.bottom_up		= false,
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
@@ -292,7 +302,21 @@ phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
 			  memblock.memory.max);
 }
 
-#endif
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+phys_addr_t __init_memblock get_allocated_memblock_nomap_regions_info(
+					phys_addr_t *addr)
+{
+	if (memblock.memory.regions == memblock_memory_init_regions)
+		return 0;
+
+	*addr = __pa(memblock.memory.regions);
+
+	return PAGE_ALIGN(sizeof(struct memblock_region) *
+			  memblock.memory.max);
+}
+
+#endif /* CONFIG_ARCH_MEMBLOCK_NOMAP */
+#endif /* CONFIG_ARCH_DISCARD_MEMBLOCK */
 
 /**
  * memblock_double_array - double the size of the memblock regions array
@@ -757,18 +781,76 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 	return 0;
 }
 
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+/*
+ * memblock_nomap() - mark a memory range as completely unusable
+ *
+ * This can be used to exclude memory regions from every further treatment
+ * in the running system. Ranges which are added to the nomap list will
+ * also be marked as reserved. So they won't either be allocated by memblock
+ * nor freed to the page allocator.
+ *
+ * The usable (i.e. not in nomap list) memory can be iterated
+ * via for_each_mapped_mem_range().
+ *
+ * memblock_start_of_DRAM() and memblock_end_of_DRAM() still refer to the
+ * whole system memory.
+ */
+int __init_memblock memblock_nomap(phys_addr_t base, phys_addr_t size)
+{
+	int ret;
+	memblock_dbg("memblock_nomap: [%#016llx-%#016llx] %pF\n",
+		     (unsigned long long)base,
+		     (unsigned long long)base + size,
+		     (void *)_RET_IP_);
+
+	ret = memblock_add_region(&memblock.reserved, base, size, MAX_NUMNODES);
+	if (ret)
+		return ret;
+
+	return memblock_add_region(&memblock.nomap, base, size, MAX_NUMNODES);
+}
+
+/*
+ * memblock_remap() - remove a memory range from the nomap list
+ *
+ * This is the inverse function to memblock_nomap().
+ */
+int __init_memblock memblock_remap(phys_addr_t base, phys_addr_t size)
+{
+	int ret;
+	memblock_dbg("memblock_remap: [%#016llx-%#016llx] %pF\n",
+		     (unsigned long long)base,
+		     (unsigned long long)base + size,
+		     (void *)_RET_IP_);
+
+	ret = __memblock_remove(&memblock.reserved, base, size);
+	if (ret)
+		return ret;
+
+	return __memblock_remove(&memblock.nomap, base, size);
+}
+
+#endif
+
 /**
- * __next_free_mem_range - next function for for_each_free_mem_range()
+ * __next_mem_range - generic next function for for_each_*_range()
+ *
+ * Finds the next range from type_a which is not marked as unsuitable
+ * in type_b.
+ *
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @type_a: pointer to memblock_type from where the range is taken
+ * @type_b: pointer to memblock_type which excludes memory from being taken
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
- * Find the first free area from *@idx which matches @nid, fill the out
+ * Find the first present area from *@idx which matches @nid, fill the out
  * parameters, and update *@idx for the next iteration.  The lower 32bit of
- * *@idx contains index into memory region and the upper 32bit indexes the
- * areas before each reserved region.  For example, if reserved regions
+ * *@idx contains index into type_a region and the upper 32bit indexes the
+ * areas before each type_b region.  For example, if type_a regions
  * look like the following,
  *
  *	0:[0-16), 1:[32-48), 2:[128-130)
@@ -780,96 +862,120 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
  * As both region arrays are sorted, the function advances the two indices
  * in lockstep and returns each intersection.
  */
-void __init_memblock __next_free_mem_range(u64 *idx, int nid,
-					   phys_addr_t *out_start,
-					   phys_addr_t *out_end, int *out_nid)
+void __init_memblock __next_mem_range(u64 *idx, int nid,
+				      struct memblock_type *type_a,
+				      struct memblock_type *type_b,
+				      phys_addr_t *out_start,
+				      phys_addr_t *out_end, int *out_nid)
 {
-	struct memblock_type *mem = &memblock.memory;
-	struct memblock_type *rsv = &memblock.reserved;
-	int mi = *idx & 0xffffffff;
-	int ri = *idx >> 32;
+	int idx_a = *idx & 0xffffffff;
+	int idx_b = *idx >> 32;
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
 
-	for ( ; mi < mem->cnt; mi++) {
-		struct memblock_region *m = &mem->regions[mi];
+	for (; idx_a < type_a->cnt; idx_a++) {
+		struct memblock_region *m = &type_a->regions[idx_a];
 		phys_addr_t m_start = m->base;
 		phys_addr_t m_end = m->base + m->size;
+		int         m_nid = memblock_get_region_node(m);
 
 		/* only memory regions are associated with nodes, check it */
 		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
-		/* scan areas before each reservation for intersection */
-		for ( ; ri < rsv->cnt + 1; ri++) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
+		/* With type_b NULL we only iterate through type_a */
+		if (type_b == NULL) {
+			if (out_start)
+				*out_start = m_start;
+			if (out_end)
+				*out_end = m_end;
+			if (out_nid)
+				*out_nid = m_nid;
+			idx_a++;
+			*idx = (u32)idx_a;
+			return;
+		}
+
+		/* scan areas before each reservation */
+		for (; idx_b < type_b->cnt + 1; idx_b++) {
+			struct memblock_region *r;
+			phys_addr_t r_start;
+			phys_addr_t r_end;
 
-			/* if ri advanced past mi, break out to advance mi */
+			r = &type_b->regions[idx_b];
+			r_start = idx_b ? r[-1].base + r[-1].size : 0;
+			r_end = idx_b < type_b->cnt ?
+				r->base : ULLONG_MAX;
+
+			/*
+			 *if idx_b advanced past idx_a,
+			 * break out to advance idx_a
+			 */
 			if (r_start >= m_end)
 				break;
 			/* if the two regions intersect, we're done */
 			if (m_start < r_end) {
 				if (out_start)
-					*out_start = max(m_start, r_start);
+					*out_start =
+						max(m_start, r_start);
 				if (out_end)
 					*out_end = min(m_end, r_end);
 				if (out_nid)
-					*out_nid = memblock_get_region_node(m);
+					*out_nid = m_nid;
+
 				/*
-				 * The region which ends first is advanced
-				 * for the next iteration.
+				 * The region which ends first is
+				 * advanced for the next iteration.
 				 */
 				if (m_end <= r_end)
-					mi++;
+					idx_a++;
 				else
-					ri++;
-				*idx = (u32)mi | (u64)ri << 32;
+					idx_b++;
+				*idx = (u32)idx_a | (u64)idx_b << 32;
 				return;
 			}
 		}
 	}
-
 	/* signal end of iteration */
 	*idx = ULLONG_MAX;
 }
 
 /**
- * __next_free_mem_range_rev - next function for for_each_free_mem_range_reverse()
+ * __next_mem_range_rev - generic next function for for_each_*_range_rev()
+ *
+ * Finds the next range from type_a which is not marked as unsuitable
+ * in type_b.
+ *
  * @idx: pointer to u64 loop variable
  * @nid: nid: node selector, %NUMA_NO_NODE for all nodes
+ * @type_a: pointer to memblock_type from where the range is taken
+ * @type_b: pointer to memblock_type which excludes memory from being taken
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
- * Reverse of __next_free_mem_range().
- *
- * Linux kernel cannot migrate pages used by itself. Memory hotplug users won't
- * be able to hot-remove hotpluggable memory used by the kernel. So this
- * function skip hotpluggable regions if needed when allocating memory for the
- * kernel.
+ * Reverse of __next_mem_range().
  */
-void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
-					   phys_addr_t *out_start,
-					   phys_addr_t *out_end, int *out_nid)
+void __init_memblock __next_mem_range_rev(u64 *idx, int nid,
+					  struct memblock_type *type_a,
+					  struct memblock_type *type_b,
+					  phys_addr_t *out_start,
+					  phys_addr_t *out_end, int *out_nid)
 {
-	struct memblock_type *mem = &memblock.memory;
-	struct memblock_type *rsv = &memblock.reserved;
-	int mi = *idx & 0xffffffff;
-	int ri = *idx >> 32;
+	int idx_a = *idx & 0xffffffff;
+	int idx_b = *idx >> 32;
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
 
 	if (*idx == (u64)ULLONG_MAX) {
-		mi = mem->cnt - 1;
-		ri = rsv->cnt;
+		idx_a = type_a->cnt - 1;
+		idx_b = type_b->cnt;
 	}
 
-	for ( ; mi >= 0; mi--) {
-		struct memblock_region *m = &mem->regions[mi];
+	for (; idx_a >= 0; idx_a--) {
+		struct memblock_region *m = &type_a->regions[idx_a];
 		phys_addr_t m_start = m->base;
 		phys_addr_t m_end = m->base + m->size;
 
@@ -877,17 +983,34 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
-		/* skip hotpluggable memory regions if needed */
-		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
-			continue;
-
-		/* scan areas before each reservation for intersection */
-		for ( ; ri >= 0; ri--) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
+		/* With type_b NULL we only iterate through type_a */
+		if (type_b == NULL) {
+			if (out_start)
+				*out_start = m_start;
+			if (out_end)
+				*out_end = m_end;
+			if (out_nid)
+				*out_nid = memblock_get_region_node(m);
+			idx_a--;
+			*idx = (u32)idx_a;
+			return;
+		}
 
-			/* if ri advanced past mi, break out to advance mi */
+		/* scan areas before each reservation */
+		for (; idx_b >= 0; idx_b--) {
+			struct memblock_region *r;
+			phys_addr_t r_start;
+			phys_addr_t r_end;
+			int m_nid = memblock_get_region_node(m);
+
+			r = &type_b->regions[idx_b];
+			r_start = idx_b ? r[-1].base + r[-1].size : 0;
+			r_end = idx_b < type_b->cnt ?
+				r->base : ULLONG_MAX;
+			/*
+			 * if idx_b advanced past idx_a,
+			 * break out to advance idx_a
+			 */
 			if (r_end <= m_start)
 				break;
 			/* if the two regions intersect, we're done */
@@ -897,18 +1020,17 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 				if (out_end)
 					*out_end = min(m_end, r_end);
 				if (out_nid)
-					*out_nid = memblock_get_region_node(m);
-
+					*out_nid = m_nid;
 				if (m_start >= r_start)
-					mi--;
+					idx_a--;
 				else
-					ri--;
-				*idx = (u32)mi | (u64)ri << 32;
+					idx_b--;
+				*idx = (u32)idx_a | (u64)idx_b << 32;
 				return;
 			}
 		}
 	}
-
+	/* signal end of iteration */
 	*idx = ULLONG_MAX;
 }
 
@@ -1294,6 +1416,9 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 	/* truncate both memory and reserved regions */
 	__memblock_remove(&memblock.memory, max_addr, (phys_addr_t)ULLONG_MAX);
 	__memblock_remove(&memblock.reserved, max_addr, (phys_addr_t)ULLONG_MAX);
+#ifdef ARCH_MEMBLOCK_NOMAP
+	__memblock_remove(&memblock.nomap, max_addr, (phys_addr_t)ULLONG_MAX);
+#endif
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
@@ -1438,12 +1563,22 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 void __init_memblock __memblock_dump_all(void)
 {
 	pr_info("MEMBLOCK configuration:\n");
+#ifndef CONFIG_ARCH_MEMBLOCK_NOMAP
 	pr_info(" memory size = %#llx reserved size = %#llx\n",
 		(unsigned long long)memblock.memory.total_size,
 		(unsigned long long)memblock.reserved.total_size);
+#else
+	pr_info(" memory size = %#llx reserved size = %#llx\n",
+		(unsigned long long)memblock.memory.total_size,
+		(unsigned long long)memblock.reserved.total_size);
+		(unsigned long long)memblock.nomap.total_size);
+#endif
 
 	memblock_dump(&memblock.memory, "memory");
 	memblock_dump(&memblock.reserved, "reserved");
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	memblock_dump(&memblock.nomap, "nomap");
+#endif
 }
 
 void __init memblock_allow_resize(void)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e2906a5..c57d5e3 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -133,6 +133,15 @@ static unsigned long __init free_low_memory_core_early(void)
 	size = get_allocated_memblock_memory_regions_info(&start);
 	if (size)
 		count += __free_memory_core(start, start + size);
+
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+
+	/* Free memblock.nomap array if it was allocated */
+	size = get_allocated_memblock_memory_regions_info(&start);
+	if (size)
+		count += __free_memory_core(start, start + size);
+
+#endif
 #endif
 
 	return count;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
