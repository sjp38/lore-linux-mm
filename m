Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB5E6B01F7
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:34:09 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q58so532486wes.40
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:34:08 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id df2si1261064wjc.28.2014.03.20.05.34.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 05:34:07 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 20 Mar 2014 12:34:06 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3394F17D805C
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:34:48 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2KCXrOT44433510
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:33:53 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2KCY4S6003944
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 06:34:04 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/3] mm/memblock: Do some refactoring, enhance API
Date: Thu, 20 Mar 2014 13:33:48 +0100
Message-Id: <1395318830-7435-2-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
References: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, grygorii.strashko@ti.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Refactor the memblock code and extend the memblock API to make it
more flexible. With the extended API it is simple to define and
work with additional memory lists.

The static functions memblock_add_region and __memblock_remove are
renamed to memblock_add_range and meblock_remove_range and added to
the memblock API.

The __next_free_mem_range and __next_free_mem_range_rev functions
are replaced with calls to the more generic list walkers
__next_mem_range and __next_mem_range_rev.

To walk an arbitrary memory list two new macros for_each_mem_range
and for_each_mem_range_rev are added. These new macros are used
to define for_each_free_mem_range and for_each_free_mem_range_reverse.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/memblock.h |   75 ++++++++++++++----
 mm/memblock.c            |  193 +++++++++++++++++++++++++++++-----------------
 2 files changed, 183 insertions(+), 85 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1ef6636..9ddd0ef 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -71,6 +71,63 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
+
+/* Low level functions */
+int memblock_add_range(struct memblock_type *type,
+		       phys_addr_t base, phys_addr_t size,
+		       int nid, unsigned long flags);
+
+int memblock_remove_range(struct memblock_type *type,
+			  phys_addr_t base,
+			  phys_addr_t size);
+
+void __next_mem_range(u64 *idx, int nid, struct memblock_type *type_a,
+		      struct memblock_type *type_b, phys_addr_t *out_start,
+		      phys_addr_t *out_end, int *out_nid);
+
+void __next_mem_range_rev(u64 *idx, int nid, struct memblock_type *type_a,
+			  struct memblock_type *type_b, phys_addr_t *out_start,
+			  phys_addr_t *out_end, int *out_nid);
+
+/**
+ * for_each_mem_range - iterate through memblock areas from type_a and not
+ * included in type_b. Or just type_a if type_b is NULL.
+ * @i: u64 used as loop variable
+ * @type_a: ptr to memblock_type to iterate
+ * @type_b: ptr to memblock_type which excludes from the iteration
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @p_nid: ptr to int for nid of the range, can be %NULL
+ */
+#define for_each_mem_range(i, type_a, type_b, nid,			\
+			   p_start, p_end, p_nid)			\
+	for (i = 0, __next_mem_range(&i, nid, type_a, type_b,		\
+				     p_start, p_end, p_nid);		\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_mem_range(&i, nid, type_a, type_b,			\
+			      p_start, p_end, p_nid))
+
+/**
+ * for_each_mem_range_rev - reverse iterate through memblock areas from
+ * type_a and not included in type_b. Or just type_a if type_b is NULL.
+ * @i: u64 used as loop variable
+ * @type_a: ptr to memblock_type to iterate
+ * @type_b: ptr to memblock_type which excludes from the iteration
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @p_nid: ptr to int for nid of the range, can be %NULL
+ */
+#define for_each_mem_range_rev(i, type_a, type_b, nid,			\
+			       p_start, p_end, p_nid)			\
+	for (i = (u64)ULLONG_MAX,					\
+		     __next_mem_range_rev(&i, nid, type_a, type_b,	\
+					 p_start, p_end, p_nid);	\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_mem_range_rev(&i, nid, type_a, type_b,		\
+				  p_start, p_end, p_nid))
+
 #ifdef CONFIG_MOVABLE_NODE
 static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 {
@@ -113,9 +170,6 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
-			   phys_addr_t *out_end, int *out_nid);
-
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
@@ -128,13 +182,8 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
  * soon as memblock is initialized.
  */
 #define for_each_free_mem_range(i, nid, p_start, p_end, p_nid)		\
-	for (i = 0,							\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid);	\
-	     i != (u64)ULLONG_MAX;					\
-	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid))
-
-void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
-			       phys_addr_t *out_end, int *out_nid);
+	for_each_mem_range(i, &memblock.memory, &memblock.reserved,	\
+			   nid, p_start, p_end, p_nid)
 
 /**
  * for_each_free_mem_range_reverse - rev-iterate through free memblock areas
@@ -148,10 +197,8 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
  * order.  Available as soon as memblock is initialized.
  */
 #define for_each_free_mem_range_reverse(i, nid, p_start, p_end, p_nid)	\
-	for (i = (u64)ULLONG_MAX,					\
-	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid);	\
-	     i != (u64)ULLONG_MAX;					\
-	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
+	for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved,	\
+			       nid, p_start, p_end, p_nid)
 
 static inline void memblock_set_region_flags(struct memblock_region *r,
 					     unsigned long flags)
diff --git a/mm/memblock.c b/mm/memblock.c
index 39a31e7..f2e9aa0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -472,7 +472,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
 }
 
 /**
- * memblock_add_region - add new memblock region
+ * memblock_add_range - add new memblock region
  * @type: memblock type to add new region into
  * @base: base address of the new region
  * @size: size of the new region
@@ -487,7 +487,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-static int __init_memblock memblock_add_region(struct memblock_type *type,
+int __init_memblock memblock_add_range(struct memblock_type *type,
 				phys_addr_t base, phys_addr_t size,
 				int nid, unsigned long flags)
 {
@@ -569,12 +569,12 @@ repeat:
 int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 				       int nid)
 {
-	return memblock_add_region(&memblock.memory, base, size, nid, 0);
+	return memblock_add_range(&memblock.memory, base, size, nid, 0);
 }
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_add_region(&memblock.memory, base, size,
+	return memblock_add_range(&memblock.memory, base, size,
 				   MAX_NUMNODES, 0);
 }
 
@@ -654,8 +654,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 	return 0;
 }
 
-static int __init_memblock __memblock_remove(struct memblock_type *type,
-					     phys_addr_t base, phys_addr_t size)
+int __init_memblock memblock_remove_range(struct memblock_type *type,
+					  phys_addr_t base, phys_addr_t size)
 {
 	int start_rgn, end_rgn;
 	int i, ret;
@@ -671,9 +671,10 @@ static int __init_memblock __memblock_remove(struct memblock_type *type,
 
 int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 {
-	return __memblock_remove(&memblock.memory, base, size);
+	return memblock_remove_range(&memblock.memory, base, size);
 }
 
+
 int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
@@ -681,7 +682,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
-	return __memblock_remove(&memblock.reserved, base, size);
+	return memblock_remove_range(&memblock.reserved, base, size);
 }
 
 static int __init_memblock memblock_reserve_region(phys_addr_t base,
@@ -696,7 +697,7 @@ static int __init_memblock memblock_reserve_region(phys_addr_t base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
 
-	return memblock_add_region(_rgn, base, size, nid, flags);
+	return memblock_add_range(_rgn, base, size, nid, flags);
 }
 
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
@@ -758,17 +759,19 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 }
 
 /**
- * __next_free_mem_range - next function for for_each_free_mem_range()
+ * __next__mem_range - next function for for_each_free_mem_range() etc.
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @type_a: pointer to memblock_type from where the range is taken
+ * @type_b: pointer to memblock_type which excludes memory from being taken
  * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
- * Find the first free area from *@idx which matches @nid, fill the out
+ * Find the first area from *@idx which matches @nid, fill the out
  * parameters, and update *@idx for the next iteration.  The lower 32bit of
- * *@idx contains index into memory region and the upper 32bit indexes the
- * areas before each reserved region.  For example, if reserved regions
+ * *@idx contains index into type_a and the upper 32bit indexes the
+ * areas before each region in type_b.	For example, if type_b regions
  * look like the following,
  *
  *	0:[0-16), 1:[32-48), 2:[128-130)
@@ -780,53 +783,77 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
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
 
-	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+	if (WARN_ONCE(nid == MAX_NUMNODES,
+	"Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
 
-	for ( ; mi < mem->cnt; mi++) {
-		struct memblock_region *m = &mem->regions[mi];
+	for (; idx_a < type_a->cnt; idx_a++) {
+		struct memblock_region *m = &type_a->regions[idx_a];
+
 		phys_addr_t m_start = m->base;
 		phys_addr_t m_end = m->base + m->size;
+		int	    m_nid = memblock_get_region_node(m);
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != m_nid)
 			continue;
 
-		/* scan areas before each reservation for intersection */
-		for ( ; ri < rsv->cnt + 1; ri++) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
+		if (!type_b) {
+			if (out_start)
+				*out_start = m_start;
+			if (out_end)
+				*out_end = m_end;
+			if (out_nid)
+				*out_nid = m_nid;
+			idx_a++;
+			*idx = (u32)idx_a | (u64)idx_b << 32;
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
+			 * if idx_b advanced past idx_a,
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
@@ -837,57 +864,80 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
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
+
 		phys_addr_t m_start = m->base;
 		phys_addr_t m_end = m->base + m->size;
+		int m_nid = memblock_get_region_node(m);
 
 		/* only memory regions are associated with nodes, check it */
-		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != m_nid)
 			continue;
 
 		/* skip hotpluggable memory regions if needed */
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
 
-		/* scan areas before each reservation for intersection */
-		for ( ; ri >= 0; ri--) {
-			struct memblock_region *r = &rsv->regions[ri];
-			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
-			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
+		if (!type_b) {
+			if (out_start)
+				*out_start = m_start;
+			if (out_end)
+				*out_end = m_end;
+			if (out_nid)
+				*out_nid = m_nid;
+			idx_a++;
+			*idx = (u32)idx_a | (u64)idx_b << 32;
+			return;
+		}
+
+		/* scan areas before each reservation */
+		for (; idx_b >= 0; idx_b--) {
+			struct memblock_region *r;
+			phys_addr_t r_start;
+			phys_addr_t r_end;
+
+			r = &type_b->regions[idx_b];
+			r_start = idx_b ? r[-1].base + r[-1].size : 0;
+			r_end = idx_b < type_b->cnt ?
+				r->base : ULLONG_MAX;
+			/*
+			 * if idx_b advanced past idx_a,
+			 * break out to advance idx_a
+			 */
 
-			/* if ri advanced past mi, break out to advance mi */
 			if (r_end <= m_start)
 				break;
 			/* if the two regions intersect, we're done */
@@ -897,18 +947,17 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
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
 
@@ -1201,7 +1250,7 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
-	__memblock_remove(&memblock.reserved, base, size);
+	memblock_remove_range(&memblock.reserved, base, size);
 }
 
 /*
@@ -1289,8 +1338,10 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 	}
 
 	/* truncate both memory and reserved regions */
-	__memblock_remove(&memblock.memory, max_addr, (phys_addr_t)ULLONG_MAX);
-	__memblock_remove(&memblock.reserved, max_addr, (phys_addr_t)ULLONG_MAX);
+	memblock_remove_range(&memblock.memory, max_addr,
+			      (phys_addr_t)ULLONG_MAX);
+	memblock_remove_range(&memblock.reserved, max_addr,
+			      (phys_addr_t)ULLONG_MAX);
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
