Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1A36B0038
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 06:33:08 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so3066782eaj.12
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:33:08 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id t5si1797735eeo.106.2014.01.20.03.33.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 03:33:07 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 20 Jan 2014 11:33:07 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8F17C219005E
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:33:03 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0KBWrld62718028
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:32:53 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0KBX3X3018825
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:33:04 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V5 3/3] mm/memblock: Cleanup and refactoring after addition of nomap
Date: Mon, 20 Jan 2014 12:32:39 +0100
Message-Id: <1390217559-14691-4-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 include/linux/memblock.h |  50 ++++++-----
 mm/memblock.c            | 214 +++++++++++++++++------------------------------
 2 files changed, 107 insertions(+), 157 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index be1c819..ec2da3b 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -121,8 +121,9 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
-			   phys_addr_t *out_end, int *out_nid);
+void __next_mem_range(u64 *idx, int nid, struct memblock_type *type_a,
+		      struct memblock_type *type_b, phys_addr_t *out_start,
+		      phys_addr_t *out_end, int *out_nid);
 
 /**
  * for_each_free_mem_range - iterate through free memblock areas
@@ -137,29 +138,31 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
  */
 #define for_each_free_mem_range(i, nid, p_start, p_end, p_nid)		\
 	for (i = 0,							\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid);	\
+		     __next_mem_range(&i, nid, &memblock.memory,	\
+				      &memblock.reserved, p_start,	\
+				      p_end, p_nid);			\
 	     i != (u64)ULLONG_MAX;					\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid))
-
+	     __next_mem_range(&i, nid, &memblock.memory,		\
+			      &memblock.reserved,			\
+			      p_start, p_end, p_nid))
 
 #ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
 #define for_each_mapped_mem_range(i, nid, p_start, p_end, p_nid)	\
 	for (i = 0,							\
-		     __next_mapped_mem_range(&i, nid, &memblock.memory,	\
+		     __next_mem_range(&i, nid, &memblock.memory,	\
 				      &memblock.nomap, p_start,		\
 				      p_end, p_nid);			\
 	     i != (u64)ULLONG_MAX;					\
-	     __next_mapped_mem_range(&i, nid, &memblock.memory,		\
-				     &memblock.nomap,			\
-				     p_start, p_end, p_nid))
-
-void __next_mapped_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
-			     phys_addr_t *out_end, int *out_nid);
-
+	     __next_mem_range(&i, nid, &memblock.memory,		\
+			      &memblock.nomap,				\
+			      p_start, p_end, p_nid))
 #endif
 
-void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
-			       phys_addr_t *out_end, int *out_nid);
+void __next_mem_range_rev(u64 *idx, int nid,
+					  struct memblock_type *type_a,
+					  struct memblock_type *type_b,
+					  phys_addr_t *out_start,
+					  phys_addr_t *out_end, int *out_nid);
 
 /**
  * for_each_free_mem_range_reverse - rev-iterate through free memblock areas
@@ -174,9 +177,15 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
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
@@ -321,12 +330,11 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	return PFN_UP(reg->base + reg->size);
 }
 
-#define for_each_memblock(memblock_type, region)					\
-	for (region = memblock.memblock_type.regions;				\
-	     region < (memblock.memblock_type.regions + memblock.memblock_type.cnt);	\
+#define for_each_memblock(type_name, region)				\
+	for (region = memblock.type_name.regions;			\
+	     region < (memblock.type_name.regions + memblock.type_name.cnt); \
 	     region++)
 
-
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 #define __init_memblock __meminit
 #define __initdata_memblock __meminitdata
diff --git a/mm/memblock.c b/mm/memblock.c
index b36f5d3..dd6fd6f 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -836,97 +836,23 @@ int __init_memblock memblock_remap(phys_addr_t base, phys_addr_t size)
 #endif
 
 /**
- * __next_free_mem_range - next function for for_each_free_mem_range()
- * @idx: pointer to u64 loop variable
- * @nid: node selector, %NUMA_NO_NODE for all nodes
- * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
- * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
- * @out_nid: ptr to int for nid of the range, can be %NULL
- *
- * Find the first free area from *@idx which matches @nid, fill the out
- * parameters, and update *@idx for the next iteration.  The lower 32bit of
- * *@idx contains index into memory region and the upper 32bit indexes the
- * areas before each reserved region.  For example, if reserved regions
- * look like the following,
- *
- *	0:[0-16), 1:[32-48), 2:[128-130)
+ * __next_mem_range - generic next function for for_each_*_range()
  *
- * The upper 32bit indexes the following regions.
+ * Finds the next range from type_a which is not marked as unsuitable
+ * in type_b.
  *
- *	0:[0-0), 1:[16-32), 2:[48-128), 3:[130-MAX)
- *
- * As both region arrays are sorted, the function advances the two indices
- * in lockstep and returns each intersection.
- */
-void __init_memblock __next_free_mem_range(u64 *idx, int nid,
-					   phys_addr_t *out_start,
-					   phys_addr_t *out_end, int *out_nid)
-{
-	struct memblock_type *mem = &memblock.memory;
-	struct memblock_type *rsv = &memblock.reserved;
-	int mi = *idx & 0xffffffff;
-	int ri = *idx >> 32;
-
-	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
-		nid = NUMA_NO_NODE;
-
-	for ( ; mi < mem->cnt; mi++) {
-		struct memblock_region *m = &mem->regions[mi];
-		phys_addr_t m_start = m->base;
-		phys_addr_t m_end = m->base + m->size;
-
-		/* only memory regions are associated with nodes, check it */
-		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
-			continue;
-
-		/* scan areas before each reservation for intersection */
-		for ( ; ri < rsv->cnt + 1; ri++) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
-
-			/* if ri advanced past mi, break out to advance mi */
-			if (r_start >= m_end)
-				break;
-			/* if the two regions intersect, we're done */
-			if (m_start < r_end) {
-				if (out_start)
-					*out_start = max(m_start, r_start);
-				if (out_end)
-					*out_end = min(m_end, r_end);
-				if (out_nid)
-					*out_nid = memblock_get_region_node(m);
-				/*
-				 * The region which ends first is advanced
-				 * for the next iteration.
-				 */
-				if (m_end <= r_end)
-					mi++;
-				else
-					ri++;
-				*idx = (u32)mi | (u64)ri << 32;
-				return;
-			}
-		}
-	}
-
-	/* signal end of iteration */
-	*idx = ULLONG_MAX;
-}
-
-#ifdef ARCH_MEMBLOCK_NOMAP
-/**
- * __next_mapped_mem_range - next function for for_each_free_mem_range()
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
@@ -938,98 +864,107 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
  * As both region arrays are sorted, the function advances the two indices
  * in lockstep and returns each intersection.
  */
-void __init_memblock __next_mapped_mem_range(u64 *idx, int nid,
-					   phys_addr_t *out_start,
-					   phys_addr_t *out_end, int *out_nid)
+void __init_memblock __next_mem_range(u64 *idx, int nid,
+				      struct memblock_type *type_a,
+				      struct memblock_type *type_b,
+				      phys_addr_t *out_start,
+				      phys_addr_t *out_end, int *out_nid)
 {
-	struct memblock_type *mem = &memblock.memory;
-	struct memblock_type *rsv = &memblock.nomap;
-	int mi = *idx & 0xffffffff;
-	int ri = *idx >> 32;
+	int idx_a = *idx & 0xffffffff;
+	int idx_b = *idx >> 32;
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
 
-	for (; mi < mem->cnt; mi++) {
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
-		for (; ri < rsv->cnt + 1; ri++) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ?
+		/* scan areas before each reservation */
+		for (; idx_b < type_b->cnt + 1; idx_b++) {
+			struct memblock_region *r;
+			phys_addr_t r_start;
+			phys_addr_t r_end;
+
+			r = &type_b->regions[idx_b];
+			r_start = idx_b ? r[-1].base + r[-1].size : 0;
+			r_end = idx_b < type_b->cnt ?
 				r->base : ULLONG_MAX;
 
-			/* if ri advanced past mi, break out to advance mi */
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
-#endif
 
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
 
@@ -1041,13 +976,21 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
 
-		/* scan areas before each reservation for intersection */
-		for ( ; ri >= 0; ri--) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
+		/* scan areas before each reservation */
+		for (; idx_b >= 0; idx_b--) {
+			struct memblock_region *r;
+			phys_addr_t r_start;
+			phys_addr_t r_end;
+			int m_nid = memblock_get_region_node(m);
 
-			/* if ri advanced past mi, break out to advance mi */
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
@@ -1057,18 +1000,17 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
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
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
