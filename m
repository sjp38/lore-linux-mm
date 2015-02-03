Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C69E36B0070
	for <linux-mm@kvack.org>; Mon,  4 May 2015 16:57:47 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so171009134pab.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 13:57:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ci15si21269750pdb.234.2015.05.04.13.57.46
        for <linux-mm@kvack.org>;
        Mon, 04 May 2015 13:57:46 -0700 (PDT)
Message-Id: <ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
In-Reply-To: <cover.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 3 Feb 2015 14:38:02 -0800
Subject: [PATCH 2/3] mm/memblock: Allocate boot time data structures from
 mirrored memory
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Try to allocate all boot time kernel data structures from mirrored
memory. If we run out of mirrored memory print warnings, but fall
back to using non-mirrored memory to make sure that we still boot.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 include/linux/memblock.h |  8 ++++++
 mm/memblock.c            | 71 ++++++++++++++++++++++++++++++++++++++++++------
 mm/nobootmem.c           | 10 ++++++-
 3 files changed, 79 insertions(+), 10 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1d448879caae..20bf3dfab564 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -22,6 +22,7 @@
 
 /* Definition of memblock flags. */
 #define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
+#define MEMBLOCK_MIRROR		0x2	/* mirrored region */
 
 struct memblock_region {
 	phys_addr_t base;
@@ -75,6 +76,8 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
+int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
+u32 memblock_has_mirror(void);
 
 /* Low level functions */
 int memblock_add_range(struct memblock_type *type,
@@ -155,6 +158,11 @@ static inline bool movable_node_is_enabled(void)
 }
 #endif
 
+static inline bool memblock_is_mirror(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_MIRROR;
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
diff --git a/mm/memblock.c b/mm/memblock.c
index ac3c94fff97c..7a0769555474 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -54,10 +54,16 @@ int memblock_debug __initdata_memblock;
 #ifdef CONFIG_MOVABLE_NODE
 bool movable_node_enabled __initdata_memblock = false;
 #endif
+static bool memblock_have_mirror __initdata_memblock = false;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;
 
+u32 __init_memblock memblock_has_mirror(void)
+{
+	return memblock_have_mirror ? MEMBLOCK_MIRROR : 0;
+}
+
 /* inline so we don't get a warning when pr_debug is compiled out */
 static __init_memblock const char *
 memblock_type_name(struct memblock_type *type)
@@ -257,8 +263,19 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align)
 {
-	return memblock_find_in_range_node(size, align, start, end,
+	phys_addr_t ret;
+	u32 flag = memblock_has_mirror();
+
+	ret = memblock_find_in_range_node(size, align, start, end,
+					    NUMA_NO_NODE, flag);
+
+	if (!ret && flag) {
+		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);
+		ret = memblock_find_in_range_node(size, align, start, end,
 					    NUMA_NO_NODE, 0);
+	}
+
+	return ret;
 }
 
 static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
@@ -784,6 +801,21 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * memblock_mark_mirror - Mark mirrored memory with flag MEMBLOCK_MIRROR.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * Return 0 on succees, -errno on failure.
+ */
+int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
+{
+	memblock_have_mirror = true;
+
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
+}
+
+
+/**
  * __next__mem_range - next function for for_each_free_mem_range() etc.
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
@@ -837,6 +869,10 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, u32 flags,
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
 
+		/* if we want mirror memory skip non-mirror memory regions */
+		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
+			continue;
+
 		if (!type_b) {
 			if (out_start)
 				*out_start = m_start;
@@ -942,6 +978,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, u32 flags,
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
 
+		/* if we want mirror memory skip non-mirror memory regions */
+		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
+			continue;
+
 		if (!type_b) {
 			if (out_start)
 				*out_start = m_start;
@@ -1092,7 +1132,17 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
 
 phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	return memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE, nid, 0);
+	u32 flag = memblock_has_mirror();
+	phys_addr_t ret;
+
+again:
+	ret = memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE, nid, flag);
+
+	if (!ret && flag) {
+		flag = 0;
+		goto again;
+	}
+	return ret;
 }
 
 phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
@@ -1161,6 +1211,7 @@ static void * __init memblock_virt_alloc_internal(
 {
 	phys_addr_t alloc;
 	void *ptr;
+	u32 flag = memblock_has_mirror();
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
@@ -1181,13 +1232,13 @@ static void * __init memblock_virt_alloc_internal(
 
 again:
 	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
-					    nid, 0);
+					    nid, flag);
 	if (alloc)
 		goto done;
 
 	if (nid != NUMA_NO_NODE) {
 		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr,  NUMA_NO_NODE, 0);
+						    max_addr,  NUMA_NO_NODE, flag);
 		if (alloc)
 			goto done;
 	}
@@ -1195,10 +1246,15 @@ again:
 	if (min_addr) {
 		min_addr = 0;
 		goto again;
-	} else {
-		goto error;
 	}
 
+	if (flag) {
+		flag = 0;
+		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);
+		goto again;
+	}
+
+	return NULL;
 done:
 	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
@@ -1213,9 +1269,6 @@ done:
 	kmemleak_alloc(ptr, size, 0, 0);
 
 	return ptr;
-
-error:
-	return NULL;
 }
 
 /**
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index a4903046bcba..35423c935a46 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -37,11 +37,19 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 {
 	void *ptr;
 	u64 addr;
+	u32 flag = memblock_has_mirror();
 
 	if (limit > memblock.current_limit)
 		limit = memblock.current_limit;
 
-	addr = memblock_find_in_range_node(size, align, goal, limit, nid, 0);
+again:
+	addr = memblock_find_in_range_node(size, align, goal, limit, nid, flag);
+
+	if (flag && !addr) {
+		flag = 0;
+		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);
+		goto again;
+	}
 	if (!addr)
 		return NULL;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
