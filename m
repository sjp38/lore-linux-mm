Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17A926B0010
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so12177264wrl.6
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b3-v6si252612wrm.170.2018.06.18.10.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:25 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwrt5045986
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:23 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpfx8t5dj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:21 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:18 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 06/11] mm/memblock: add a name for memblock flags enumeration
Date: Mon, 18 Jun 2018 19:59:54 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Since kernel-doc does not like anonymous enums the name is required for
adding documentation. While on it, I've also updated all the function
declarations to use 'enum memblock_flags' instead of unsigned long.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/memblock.h | 22 +++++++++++-----------
 mm/memblock.c            | 37 +++++++++++++++++++++----------------
 mm/nobootmem.c           |  2 +-
 3 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index ca59883..8b8fbce 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -21,7 +21,7 @@
 #define INIT_PHYSMEM_REGIONS	4
 
 /* Definition of memblock flags. */
-enum {
+enum memblock_flags {
 	MEMBLOCK_NONE		= 0x0,	/* No special request */
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
@@ -31,7 +31,7 @@ enum {
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
-	unsigned long flags;
+	enum memblock_flags flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	int nid;
 #endif
@@ -72,7 +72,7 @@ void memblock_discard(void);
 
 phys_addr_t memblock_find_in_range_node(phys_addr_t size, phys_addr_t align,
 					phys_addr_t start, phys_addr_t end,
-					int nid, ulong flags);
+					int nid, enum memblock_flags flags);
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
 void memblock_allow_resize(void);
@@ -89,19 +89,19 @@ int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
-ulong choose_memblock_flags(void);
+enum memblock_flags choose_memblock_flags(void);
 
 /* Low level functions */
 int memblock_add_range(struct memblock_type *type,
 		       phys_addr_t base, phys_addr_t size,
-		       int nid, unsigned long flags);
+		       int nid, enum memblock_flags flags);
 
-void __next_mem_range(u64 *idx, int nid, ulong flags,
+void __next_mem_range(u64 *idx, int nid, enum memblock_flags flags,
 		      struct memblock_type *type_a,
 		      struct memblock_type *type_b, phys_addr_t *out_start,
 		      phys_addr_t *out_end, int *out_nid);
 
-void __next_mem_range_rev(u64 *idx, int nid, ulong flags,
+void __next_mem_range_rev(u64 *idx, int nid, enum memblock_flags flags,
 			  struct memblock_type *type_a,
 			  struct memblock_type *type_b, phys_addr_t *out_start,
 			  phys_addr_t *out_end, int *out_nid);
@@ -253,13 +253,13 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			   NUMA_NO_NODE, MEMBLOCK_NONE, p_start, p_end, NULL)
 
 static inline void memblock_set_region_flags(struct memblock_region *r,
-					     unsigned long flags)
+					     enum memblock_flags flags)
 {
 	r->flags |= flags;
 }
 
 static inline void memblock_clear_region_flags(struct memblock_region *r,
-					       unsigned long flags)
+					       enum memblock_flags flags)
 {
 	r->flags &= ~flags;
 }
@@ -317,10 +317,10 @@ static inline bool memblock_bottom_up(void)
 
 phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 					phys_addr_t start, phys_addr_t end,
-					ulong flags);
+					enum memblock_flags flags);
 phys_addr_t memblock_alloc_base_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t max_addr,
-					int nid, ulong flags);
+					int nid, enum memblock_flags flags);
 phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
 				phys_addr_t max_addr);
 phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
diff --git a/mm/memblock.c b/mm/memblock.c
index 5108356..fc5d966 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -60,7 +60,7 @@ static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;
 
-ulong __init_memblock choose_memblock_flags(void)
+enum memblock_flags __init_memblock choose_memblock_flags(void)
 {
 	return system_has_some_mirror ? MEMBLOCK_MIRROR : MEMBLOCK_NONE;
 }
@@ -109,7 +109,7 @@ bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
 static phys_addr_t __init_memblock
 __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
 				phys_addr_t size, phys_addr_t align, int nid,
-				ulong flags)
+				enum memblock_flags flags)
 {
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
@@ -143,7 +143,7 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
 static phys_addr_t __init_memblock
 __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
 			       phys_addr_t size, phys_addr_t align, int nid,
-			       ulong flags)
+			       enum memblock_flags flags)
 {
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
@@ -188,7 +188,8 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  */
 phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
-					phys_addr_t end, int nid, ulong flags)
+					phys_addr_t end, int nid,
+					enum memblock_flags flags)
 {
 	phys_addr_t kernel_end, ret;
 
@@ -251,7 +252,7 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 					phys_addr_t align)
 {
 	phys_addr_t ret;
-	ulong flags = choose_memblock_flags();
+	enum memblock_flags flags = choose_memblock_flags();
 
 again:
 	ret = memblock_find_in_range_node(size, align, start, end,
@@ -472,7 +473,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 static void __init_memblock memblock_insert_region(struct memblock_type *type,
 						   int idx, phys_addr_t base,
 						   phys_addr_t size,
-						   int nid, unsigned long flags)
+						   int nid,
+						   enum memblock_flags flags)
 {
 	struct memblock_region *rgn = &type->regions[idx];
 
@@ -504,7 +506,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  */
 int __init_memblock memblock_add_range(struct memblock_type *type,
 				phys_addr_t base, phys_addr_t size,
-				int nid, unsigned long flags)
+				int nid, enum memblock_flags flags)
 {
 	bool insert = false;
 	phys_addr_t obase = base;
@@ -868,7 +870,8 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
  * As both region arrays are sorted, the function advances the two indices
  * in lockstep and returns each intersection.
  */
-void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
+void __init_memblock __next_mem_range(u64 *idx, int nid,
+				      enum memblock_flags flags,
 				      struct memblock_type *type_a,
 				      struct memblock_type *type_b,
 				      phys_addr_t *out_start,
@@ -977,7 +980,8 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
  *
  * Reverse of __next_mem_range().
  */
-void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
+void __init_memblock __next_mem_range_rev(u64 *idx, int nid,
+					  enum memblock_flags flags,
 					  struct memblock_type *type_a,
 					  struct memblock_type *type_b,
 					  phys_addr_t *out_start,
@@ -1135,7 +1139,8 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 
 static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
-					phys_addr_t end, int nid, ulong flags)
+					phys_addr_t end, int nid,
+					enum memblock_flags flags)
 {
 	phys_addr_t found;
 
@@ -1157,7 +1162,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 
 phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 					phys_addr_t start, phys_addr_t end,
-					ulong flags)
+					enum memblock_flags flags)
 {
 	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE,
 					flags);
@@ -1165,14 +1170,14 @@ phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 
 phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t max_addr,
-					int nid, ulong flags)
+					int nid, enum memblock_flags flags)
 {
 	return memblock_alloc_range_nid(size, align, 0, max_addr, nid, flags);
 }
 
 phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	ulong flags = choose_memblock_flags();
+	enum memblock_flags flags = choose_memblock_flags();
 	phys_addr_t ret;
 
 again:
@@ -1253,7 +1258,7 @@ static void * __init memblock_virt_alloc_internal(
 {
 	phys_addr_t alloc;
 	void *ptr;
-	ulong flags = choose_memblock_flags();
+	enum memblock_flags flags = choose_memblock_flags();
 
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
@@ -1728,7 +1733,7 @@ phys_addr_t __init_memblock memblock_get_current_limit(void)
 static void __init_memblock memblock_dump(struct memblock_type *type)
 {
 	phys_addr_t base, end, size;
-	unsigned long flags;
+	enum memblock_flags flags;
 	int idx;
 	struct memblock_region *rgn;
 
@@ -1746,7 +1751,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
-		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s flags: %#lx\n",
+		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s flags: %#x\n",
 			type->name, idx, &base, &end, &size, nid_buf, flags);
 	}
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index c2cfa04..439af3b 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -42,7 +42,7 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 {
 	void *ptr;
 	u64 addr;
-	ulong flags = choose_memblock_flags();
+	enum memblock_flags flags = choose_memblock_flags();
 
 	if (limit > memblock.current_limit)
 		limit = memblock.current_limit;
-- 
2.7.4
