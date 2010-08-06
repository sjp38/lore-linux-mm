Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADFF600298
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FT9A025349
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FW5i1245396
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FW8o016724
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 20/43] memblock: Change u64 to phys_addr_t
Date: Fri,  6 Aug 2010 15:15:01 +1000
Message-Id: <1281071724-28740-21-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Let's not waste space and cycles on archs that don't support >32-bit
physical address space.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |   48 +++++++++---------
 mm/memblock.c            |  118 +++++++++++++++++++++++----------------------
 2 files changed, 84 insertions(+), 82 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 71b8edc..b65045a 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -21,19 +21,19 @@
 #define MAX_MEMBLOCK_REGIONS 128
 
 struct memblock_region {
-	u64 base;
-	u64 size;
+	phys_addr_t base;
+	phys_addr_t size;
 };
 
 struct memblock_type {
 	unsigned long cnt;
-	u64 size;
+	phys_addr_t size;
 	struct memblock_region regions[MAX_MEMBLOCK_REGIONS+1];
 };
 
 struct memblock {
 	unsigned long debug;
-	u64 current_limit;
+	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
 };
@@ -42,34 +42,34 @@ extern struct memblock memblock;
 
 extern void __init memblock_init(void);
 extern void __init memblock_analyze(void);
-extern long memblock_add(u64 base, u64 size);
-extern long memblock_remove(u64 base, u64 size);
-extern long __init memblock_free(u64 base, u64 size);
-extern long __init memblock_reserve(u64 base, u64 size);
+extern long memblock_add(phys_addr_t base, phys_addr_t size);
+extern long memblock_remove(phys_addr_t base, phys_addr_t size);
+extern long __init memblock_free(phys_addr_t base, phys_addr_t size);
+extern long __init memblock_reserve(phys_addr_t base, phys_addr_t size);
 
-extern u64 __init memblock_alloc_nid(u64 size, u64 align, int nid);
-extern u64 __init memblock_alloc(u64 size, u64 align);
+extern phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
+extern phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align);
 
 /* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
-#define MEMBLOCK_ALLOC_ANYWHERE	(~(u64)0)
+#define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define MEMBLOCK_ALLOC_ACCESSIBLE	0
 
-extern u64 __init memblock_alloc_base(u64 size,
-		u64, u64 max_addr);
-extern u64 __init __memblock_alloc_base(u64 size,
-		u64 align, u64 max_addr);
-extern u64 __init memblock_phys_mem_size(void);
-extern u64 memblock_end_of_DRAM(void);
-extern void __init memblock_enforce_memory_limit(u64 memory_limit);
-extern int memblock_is_memory(u64 addr);
-extern int memblock_is_region_memory(u64 base, u64 size);
-extern int __init memblock_is_reserved(u64 addr);
-extern int memblock_is_region_reserved(u64 base, u64 size);
+extern phys_addr_t __init memblock_alloc_base(phys_addr_t size,
+		phys_addr_t, phys_addr_t max_addr);
+extern phys_addr_t __init __memblock_alloc_base(phys_addr_t size,
+		phys_addr_t align, phys_addr_t max_addr);
+extern phys_addr_t __init memblock_phys_mem_size(void);
+extern phys_addr_t memblock_end_of_DRAM(void);
+extern void __init memblock_enforce_memory_limit(phys_addr_t memory_limit);
+extern int memblock_is_memory(phys_addr_t addr);
+extern int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
+extern int __init memblock_is_reserved(phys_addr_t addr);
+extern int memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
 
 extern void memblock_dump_all(void);
 
 /* Provided by the architecture */
-extern u64 memblock_nid_range(u64 start, u64 end, int *nid);
+extern phys_addr_t memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid);
 
 /**
  * memblock_set_current_limit - Set the current allocation limit to allow
@@ -77,7 +77,7 @@ extern u64 memblock_nid_range(u64 start, u64 end, int *nid);
  *                         accessible during boot
  * @limit: New limit value (physical address)
  */
-extern void memblock_set_current_limit(u64 limit);
+extern void memblock_set_current_limit(phys_addr_t limit);
 
 
 /*
diff --git a/mm/memblock.c b/mm/memblock.c
index 73d903e..81da635 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -55,13 +55,14 @@ void memblock_dump_all(void)
 	memblock_dump(&memblock.reserved, "reserved");
 }
 
-static unsigned long memblock_addrs_overlap(u64 base1, u64 size1, u64 base2,
-					u64 size2)
+static unsigned long memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
+				       phys_addr_t base2, phys_addr_t size2)
 {
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-static long memblock_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
+static long memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
+			       phys_addr_t base2, phys_addr_t size2)
 {
 	if (base2 == base1 + size1)
 		return 1;
@@ -72,12 +73,12 @@ static long memblock_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
 }
 
 static long memblock_regions_adjacent(struct memblock_type *type,
-		unsigned long r1, unsigned long r2)
+				 unsigned long r1, unsigned long r2)
 {
-	u64 base1 = type->regions[r1].base;
-	u64 size1 = type->regions[r1].size;
-	u64 base2 = type->regions[r2].base;
-	u64 size2 = type->regions[r2].size;
+	phys_addr_t base1 = type->regions[r1].base;
+	phys_addr_t size1 = type->regions[r1].size;
+	phys_addr_t base2 = type->regions[r2].base;
+	phys_addr_t size2 = type->regions[r2].size;
 
 	return memblock_addrs_adjacent(base1, size1, base2, size2);
 }
@@ -128,7 +129,7 @@ void __init memblock_analyze(void)
 		memblock.memory.size += memblock.memory.regions[i].size;
 }
 
-static long memblock_add_region(struct memblock_type *type, u64 base, u64 size)
+static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
 	long adjacent, i;
@@ -141,8 +142,8 @@ static long memblock_add_region(struct memblock_type *type, u64 base, u64 size)
 
 	/* First try and coalesce this MEMBLOCK with another. */
 	for (i = 0; i < type->cnt; i++) {
-		u64 rgnbase = type->regions[i].base;
-		u64 rgnsize = type->regions[i].size;
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
 
 		if ((rgnbase == base) && (rgnsize == size))
 			/* Already have this region, so we're done */
@@ -192,16 +193,16 @@ static long memblock_add_region(struct memblock_type *type, u64 base, u64 size)
 	return 0;
 }
 
-long memblock_add(u64 base, u64 size)
+long memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	return memblock_add_region(&memblock.memory, base, size);
 
 }
 
-static long __memblock_remove(struct memblock_type *type, u64 base, u64 size)
+static long __memblock_remove(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
-	u64 rgnbegin, rgnend;
-	u64 end = base + size;
+	phys_addr_t rgnbegin, rgnend;
+	phys_addr_t end = base + size;
 	int i;
 
 	rgnbegin = rgnend = 0; /* supress gcc warnings */
@@ -246,17 +247,17 @@ static long __memblock_remove(struct memblock_type *type, u64 base, u64 size)
 	return memblock_add_region(type, end, rgnend - end);
 }
 
-long memblock_remove(u64 base, u64 size)
+long memblock_remove(phys_addr_t base, phys_addr_t size)
 {
 	return __memblock_remove(&memblock.memory, base, size);
 }
 
-long __init memblock_free(u64 base, u64 size)
+long __init memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	return __memblock_remove(&memblock.reserved, base, size);
 }
 
-long __init memblock_reserve(u64 base, u64 size)
+long __init memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
 
@@ -265,13 +266,13 @@ long __init memblock_reserve(u64 base, u64 size)
 	return memblock_add_region(_rgn, base, size);
 }
 
-long memblock_overlaps_region(struct memblock_type *type, u64 base, u64 size)
+long memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 
 	for (i = 0; i < type->cnt; i++) {
-		u64 rgnbase = type->regions[i].base;
-		u64 rgnsize = type->regions[i].size;
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
 		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
 			break;
 	}
@@ -279,20 +280,20 @@ long memblock_overlaps_region(struct memblock_type *type, u64 base, u64 size)
 	return (i < type->cnt) ? i : -1;
 }
 
-static u64 memblock_align_down(u64 addr, u64 size)
+static phys_addr_t memblock_align_down(phys_addr_t addr, phys_addr_t size)
 {
 	return addr & ~(size - 1);
 }
 
-static u64 memblock_align_up(u64 addr, u64 size)
+static phys_addr_t memblock_align_up(phys_addr_t addr, phys_addr_t size)
 {
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static u64 __init memblock_alloc_region(u64 start, u64 end,
-				   u64 size, u64 align)
+static phys_addr_t __init memblock_alloc_region(phys_addr_t start, phys_addr_t end,
+					   phys_addr_t size, phys_addr_t align)
 {
-	u64 base, res_base;
+	phys_addr_t base, res_base;
 	long j;
 
 	base = memblock_align_down((end - size), align);
@@ -301,7 +302,7 @@ static u64 __init memblock_alloc_region(u64 start, u64 end,
 		if (j < 0) {
 			/* this area isn't reserved, take it */
 			if (memblock_add_region(&memblock.reserved, base, size) < 0)
-				base = ~(u64)0;
+				base = ~(phys_addr_t)0;
 			return base;
 		}
 		res_base = memblock.reserved.regions[j].base;
@@ -310,42 +311,43 @@ static u64 __init memblock_alloc_region(u64 start, u64 end,
 		base = memblock_align_down(res_base - size, align);
 	}
 
-	return ~(u64)0;
+	return ~(phys_addr_t)0;
 }
 
-u64 __weak __init memblock_nid_range(u64 start, u64 end, int *nid)
+phys_addr_t __weak __init memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
 	*nid = 0;
 
 	return end;
 }
 
-static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
-				       u64 size, u64 align, int nid)
+static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
+					       phys_addr_t size,
+					       phys_addr_t align, int nid)
 {
-	u64 start, end;
+	phys_addr_t start, end;
 
 	start = mp->base;
 	end = start + mp->size;
 
 	start = memblock_align_up(start, align);
 	while (start < end) {
-		u64 this_end;
+		phys_addr_t this_end;
 		int this_nid;
 
 		this_end = memblock_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			u64 ret = memblock_alloc_region(start, this_end, size, align);
-			if (ret != ~(u64)0)
+			phys_addr_t ret = memblock_alloc_region(start, this_end, size, align);
+			if (ret != ~(phys_addr_t)0)
 				return ret;
 		}
 		start = this_end;
 	}
 
-	return ~(u64)0;
+	return ~(phys_addr_t)0;
 }
 
-u64 __init memblock_alloc_nid(u64 size, u64 align, int nid)
+phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	struct memblock_type *mem = &memblock.memory;
 	int i;
@@ -359,23 +361,23 @@ u64 __init memblock_alloc_nid(u64 size, u64 align, int nid)
 	size = memblock_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
-		u64 ret = memblock_alloc_nid_region(&mem->regions[i],
+		phys_addr_t ret = memblock_alloc_nid_region(&mem->regions[i],
 					       size, align, nid);
-		if (ret != ~(u64)0)
+		if (ret != ~(phys_addr_t)0)
 			return ret;
 	}
 
 	return memblock_alloc(size, align);
 }
 
-u64 __init memblock_alloc(u64 size, u64 align)
+phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
-u64 __init memblock_alloc_base(u64 size, u64 align, u64 max_addr)
+phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	u64 alloc;
+	phys_addr_t alloc;
 
 	alloc = __memblock_alloc_base(size, align, max_addr);
 
@@ -386,11 +388,11 @@ u64 __init memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 	return alloc;
 }
 
-u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
+phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	long i;
-	u64 base = 0;
-	u64 res_base;
+	phys_addr_t base = 0;
+	phys_addr_t res_base;
 
 	BUG_ON(0 == size);
 
@@ -405,26 +407,26 @@ u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 	 * top of memory
 	 */
 	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
-		u64 memblockbase = memblock.memory.regions[i].base;
-		u64 memblocksize = memblock.memory.regions[i].size;
+		phys_addr_t memblockbase = memblock.memory.regions[i].base;
+		phys_addr_t memblocksize = memblock.memory.regions[i].size;
 
 		if (memblocksize < size)
 			continue;
 		base = min(memblockbase + memblocksize, max_addr);
 		res_base = memblock_alloc_region(memblockbase, base, size, align);
-		if (res_base != ~(u64)0)
+		if (res_base != ~(phys_addr_t)0)
 			return res_base;
 	}
 	return 0;
 }
 
 /* You must call memblock_analyze() before this. */
-u64 __init memblock_phys_mem_size(void)
+phys_addr_t __init memblock_phys_mem_size(void)
 {
 	return memblock.memory.size;
 }
 
-u64 memblock_end_of_DRAM(void)
+phys_addr_t memblock_end_of_DRAM(void)
 {
 	int idx = memblock.memory.cnt - 1;
 
@@ -432,10 +434,10 @@ u64 memblock_end_of_DRAM(void)
 }
 
 /* You must call memblock_analyze() after this. */
-void __init memblock_enforce_memory_limit(u64 memory_limit)
+void __init memblock_enforce_memory_limit(phys_addr_t memory_limit)
 {
 	unsigned long i;
-	u64 limit;
+	phys_addr_t limit;
 	struct memblock_region *p;
 
 	if (!memory_limit)
@@ -472,7 +474,7 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 	}
 }
 
-static int memblock_search(struct memblock_type *type, u64 addr)
+static int memblock_search(struct memblock_type *type, phys_addr_t addr)
 {
 	unsigned int left = 0, right = type->cnt;
 
@@ -490,17 +492,17 @@ static int memblock_search(struct memblock_type *type, u64 addr)
 	return -1;
 }
 
-int __init memblock_is_reserved(u64 addr)
+int __init memblock_is_reserved(phys_addr_t addr)
 {
 	return memblock_search(&memblock.reserved, addr) != -1;
 }
 
-int memblock_is_memory(u64 addr)
+int memblock_is_memory(phys_addr_t addr)
 {
 	return memblock_search(&memblock.memory, addr) != -1;
 }
 
-int memblock_is_region_memory(u64 base, u64 size)
+int memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
 {
 	int idx = memblock_search(&memblock.reserved, base);
 
@@ -511,13 +513,13 @@ int memblock_is_region_memory(u64 base, u64 size)
 		 memblock.reserved.regions[idx].size) >= (base + size);
 }
 
-int memblock_is_region_reserved(u64 base, u64 size)
+int memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
 {
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
 
-void __init memblock_set_current_limit(u64 limit)
+void __init memblock_set_current_limit(phys_addr_t limit)
 {
 	memblock.current_limit = limit;
 }
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
