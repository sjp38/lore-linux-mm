Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3B3E6B026E
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:57:24 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 09/25] lmb: Change u64 to phys_addr_t
Date: Mon, 10 May 2010 19:38:43 +1000
Message-Id: <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Let's not waste space and cycles on archs that don't support >32-bit
physical address space.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/lmb.h |   44 ++++++++++----------
 lib/lmb.c           |  114 ++++++++++++++++++++++++++-------------------------
 2 files changed, 80 insertions(+), 78 deletions(-)

diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 6912ae2..042250c 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -21,19 +21,19 @@
 #define MAX_LMB_REGIONS 128
 
 struct lmb_region {
-	u64 base;
-	u64 size;
+	phys_addr_t base;
+	phys_addr_t size;
 };
 
 struct lmb_type {
 	unsigned long cnt;
-	u64 size;
+	phys_addr_t size;
 	struct lmb_region regions[MAX_LMB_REGIONS+1];
 };
 
 struct lmb {
 	unsigned long debug;
-	u64 current_limit;
+	phys_addr_t current_limit;
 	struct lmb_type memory;
 	struct lmb_type reserved;
 };
@@ -42,32 +42,32 @@ extern struct lmb lmb;
 
 extern void __init lmb_init(void);
 extern void __init lmb_analyze(void);
-extern long lmb_add(u64 base, u64 size);
-extern long lmb_remove(u64 base, u64 size);
-extern long __init lmb_free(u64 base, u64 size);
-extern long __init lmb_reserve(u64 base, u64 size);
+extern long lmb_add(phys_addr_t base, phys_addr_t size);
+extern long lmb_remove(phys_addr_t base, phys_addr_t size);
+extern long __init lmb_free(phys_addr_t base, phys_addr_t size);
+extern long __init lmb_reserve(phys_addr_t base, phys_addr_t size);
 
-extern u64 __init lmb_alloc_nid(u64 size, u64 align, int nid);
-extern u64 __init lmb_alloc(u64 size, u64 align);
+extern phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
+extern phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align);
 
 /* Flags for lmb_alloc_base() amd __lmb_alloc_base() */
-#define LMB_ALLOC_ANYWHERE	(~(u64)0)
+#define LMB_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define LMB_ALLOC_ACCESSIBLE	0
 
-extern u64 __init lmb_alloc_base(u64 size,
-		u64, u64 max_addr);
-extern u64 __init __lmb_alloc_base(u64 size,
-		u64 align, u64 max_addr);
-extern u64 __init lmb_phys_mem_size(void);
-extern u64 lmb_end_of_DRAM(void);
-extern void __init lmb_enforce_memory_limit(u64 memory_limit);
-extern int __init lmb_is_reserved(u64 addr);
-extern int lmb_is_region_reserved(u64 base, u64 size);
+extern phys_addr_t __init lmb_alloc_base(phys_addr_t size,
+		phys_addr_t, phys_addr_t max_addr);
+extern phys_addr_t __init __lmb_alloc_base(phys_addr_t size,
+		phys_addr_t align, phys_addr_t max_addr);
+extern phys_addr_t __init lmb_phys_mem_size(void);
+extern phys_addr_t lmb_end_of_DRAM(void);
+extern void __init lmb_enforce_memory_limit(phys_addr_t memory_limit);
+extern int __init lmb_is_reserved(phys_addr_t addr);
+extern int lmb_is_region_reserved(phys_addr_t base, phys_addr_t size);
 
 extern void lmb_dump_all(void);
 
 /* Provided by the architecture */
-extern u64 lmb_nid_range(u64 start, u64 end, int *nid);
+extern phys_addr_t lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid);
 
 /**
  * lmb_set_current_limit - Set the current allocation limit to allow
@@ -75,7 +75,7 @@ extern u64 lmb_nid_range(u64 start, u64 end, int *nid);
  *                         accessible during boot
  * @limit: New limit value (physical address)
  */
-extern void lmb_set_current_limit(u64 limit);
+extern void lmb_set_current_limit(phys_addr_t limit);
 
 
 /*
diff --git a/lib/lmb.c b/lib/lmb.c
index e7a7842..2995673 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -55,13 +55,14 @@ void lmb_dump_all(void)
 	lmb_dump(&lmb.reserved, "reserved");
 }
 
-static unsigned long lmb_addrs_overlap(u64 base1, u64 size1, u64 base2,
-					u64 size2)
+static unsigned long lmb_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
+				       phys_addr_t base2, phys_addr_t size2)
 {
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-static long lmb_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
+static long lmb_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
+			       phys_addr_t base2, phys_addr_t size2)
 {
 	if (base2 == base1 + size1)
 		return 1;
@@ -72,12 +73,12 @@ static long lmb_addrs_adjacent(u64 base1, u64 size1, u64 base2, u64 size2)
 }
 
 static long lmb_regions_adjacent(struct lmb_type *type,
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
 
 	return lmb_addrs_adjacent(base1, size1, base2, size2);
 }
@@ -128,7 +129,7 @@ void __init lmb_analyze(void)
 		lmb.memory.size += lmb.memory.regions[i].size;
 }
 
-static long lmb_add_region(struct lmb_type *type, u64 base, u64 size)
+static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
 	long adjacent, i;
@@ -141,8 +142,8 @@ static long lmb_add_region(struct lmb_type *type, u64 base, u64 size)
 
 	/* First try and coalesce this LMB with another. */
 	for (i = 0; i < type->cnt; i++) {
-		u64 rgnbase = type->regions[i].base;
-		u64 rgnsize = type->regions[i].size;
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
 
 		if ((rgnbase == base) && (rgnsize == size))
 			/* Already have this region, so we're done */
@@ -192,16 +193,16 @@ static long lmb_add_region(struct lmb_type *type, u64 base, u64 size)
 	return 0;
 }
 
-long lmb_add(u64 base, u64 size)
+long lmb_add(phys_addr_t base, phys_addr_t size)
 {
 	return lmb_add_region(&lmb.memory, base, size);
 
 }
 
-static long __lmb_remove(struct lmb_type *type, u64 base, u64 size)
+static long __lmb_remove(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
-	u64 rgnbegin, rgnend;
-	u64 end = base + size;
+	phys_addr_t rgnbegin, rgnend;
+	phys_addr_t end = base + size;
 	int i;
 
 	rgnbegin = rgnend = 0; /* supress gcc warnings */
@@ -246,17 +247,17 @@ static long __lmb_remove(struct lmb_type *type, u64 base, u64 size)
 	return lmb_add_region(type, end, rgnend - end);
 }
 
-long lmb_remove(u64 base, u64 size)
+long lmb_remove(phys_addr_t base, phys_addr_t size)
 {
 	return __lmb_remove(&lmb.memory, base, size);
 }
 
-long __init lmb_free(u64 base, u64 size)
+long __init lmb_free(phys_addr_t base, phys_addr_t size)
 {
 	return __lmb_remove(&lmb.reserved, base, size);
 }
 
-long __init lmb_reserve(u64 base, u64 size)
+long __init lmb_reserve(phys_addr_t base, phys_addr_t size)
 {
 	struct lmb_type *_rgn = &lmb.reserved;
 
@@ -265,13 +266,13 @@ long __init lmb_reserve(u64 base, u64 size)
 	return lmb_add_region(_rgn, base, size);
 }
 
-long lmb_overlaps_region(struct lmb_type *type, u64 base, u64 size)
+long lmb_overlaps_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 
 	for (i = 0; i < type->cnt; i++) {
-		u64 rgnbase = type->regions[i].base;
-		u64 rgnsize = type->regions[i].size;
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
 		if (lmb_addrs_overlap(base, size, rgnbase, rgnsize))
 			break;
 	}
@@ -279,20 +280,20 @@ long lmb_overlaps_region(struct lmb_type *type, u64 base, u64 size)
 	return (i < type->cnt) ? i : -1;
 }
 
-static u64 lmb_align_down(u64 addr, u64 size)
+static phys_addr_t lmb_align_down(phys_addr_t addr, phys_addr_t size)
 {
 	return addr & ~(size - 1);
 }
 
-static u64 lmb_align_up(u64 addr, u64 size)
+static phys_addr_t lmb_align_up(phys_addr_t addr, phys_addr_t size)
 {
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static u64 __init lmb_alloc_region(u64 start, u64 end,
-				   u64 size, u64 align)
+static phys_addr_t __init lmb_alloc_region(phys_addr_t start, phys_addr_t end,
+					   phys_addr_t size, phys_addr_t align)
 {
-	u64 base, res_base;
+	phys_addr_t base, res_base;
 	long j;
 
 	base = lmb_align_down((end - size), align);
@@ -301,7 +302,7 @@ static u64 __init lmb_alloc_region(u64 start, u64 end,
 		if (j < 0) {
 			/* this area isn't reserved, take it */
 			if (lmb_add_region(&lmb.reserved, base, size) < 0)
-				base = ~(u64)0;
+				base = ~(phys_addr_t)0;
 			return base;
 		}
 		res_base = lmb.reserved.regions[j].base;
@@ -310,42 +311,43 @@ static u64 __init lmb_alloc_region(u64 start, u64 end,
 		base = lmb_align_down(res_base - size, align);
 	}
 
-	return ~(u64)0;
+	return ~(phys_addr_t)0;
 }
 
-u64 __weak __init lmb_nid_range(u64 start, u64 end, int *nid)
+phys_addr_t __weak __init lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
 	*nid = 0;
 
 	return end;
 }
 
-static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
-				       u64 size, u64 align, int nid)
+static phys_addr_t __init lmb_alloc_nid_region(struct lmb_region *mp,
+					       phys_addr_t size,
+					       phys_addr_t align, int nid)
 {
-	u64 start, end;
+	phys_addr_t start, end;
 
 	start = mp->base;
 	end = start + mp->size;
 
 	start = lmb_align_up(start, align);
 	while (start < end) {
-		u64 this_end;
+		phys_addr_t this_end;
 		int this_nid;
 
 		this_end = lmb_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			u64 ret = lmb_alloc_region(start, this_end, size, align);
-			if (ret != ~(u64)0)
+			phys_addr_t ret = lmb_alloc_region(start, this_end, size, align);
+			if (ret != ~(phys_addr_t)0)
 				return ret;
 		}
 		start = this_end;
 	}
 
-	return ~(u64)0;
+	return ~(phys_addr_t)0;
 }
 
-u64 __init lmb_alloc_nid(u64 size, u64 align, int nid)
+phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	struct lmb_type *mem = &lmb.memory;
 	int i;
@@ -359,23 +361,23 @@ u64 __init lmb_alloc_nid(u64 size, u64 align, int nid)
 	size = lmb_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
-		u64 ret = lmb_alloc_nid_region(&mem->regions[i],
+		phys_addr_t ret = lmb_alloc_nid_region(&mem->regions[i],
 					       size, align, nid);
-		if (ret != ~(u64)0)
+		if (ret != ~(phys_addr_t)0)
 			return ret;
 	}
 
 	return lmb_alloc(size, align);
 }
 
-u64 __init lmb_alloc(u64 size, u64 align)
+phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return lmb_alloc_base(size, align, LMB_ALLOC_ACCESSIBLE);
 }
 
-u64 __init lmb_alloc_base(u64 size, u64 align, u64 max_addr)
+phys_addr_t __init lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	u64 alloc;
+	phys_addr_t alloc;
 
 	alloc = __lmb_alloc_base(size, align, max_addr);
 
@@ -386,11 +388,11 @@ u64 __init lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 	return alloc;
 }
 
-u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
+phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	long i;
-	u64 base = 0;
-	u64 res_base;
+	phys_addr_t base = 0;
+	phys_addr_t res_base;
 
 	BUG_ON(0 == size);
 
@@ -405,26 +407,26 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 	 * top of memory
 	 */
 	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
-		u64 lmbbase = lmb.memory.regions[i].base;
-		u64 lmbsize = lmb.memory.regions[i].size;
+		phys_addr_t lmbbase = lmb.memory.regions[i].base;
+		phys_addr_t lmbsize = lmb.memory.regions[i].size;
 
 		if (lmbsize < size)
 			continue;
 		base = min(lmbbase + lmbsize, max_addr);
 		res_base = lmb_alloc_region(lmbbase, base, size, align);
-		if (res_base != ~(u64)0)
+		if (res_base != ~(phys_addr_t)0)
 			return res_base;
 	}
 	return 0;
 }
 
 /* You must call lmb_analyze() before this. */
-u64 __init lmb_phys_mem_size(void)
+phys_addr_t __init lmb_phys_mem_size(void)
 {
 	return lmb.memory.size;
 }
 
-u64 lmb_end_of_DRAM(void)
+phys_addr_t lmb_end_of_DRAM(void)
 {
 	int idx = lmb.memory.cnt - 1;
 
@@ -432,10 +434,10 @@ u64 lmb_end_of_DRAM(void)
 }
 
 /* You must call lmb_analyze() after this. */
-void __init lmb_enforce_memory_limit(u64 memory_limit)
+void __init lmb_enforce_memory_limit(phys_addr_t memory_limit)
 {
 	unsigned long i;
-	u64 limit;
+	phys_addr_t limit;
 	struct lmb_region *p;
 
 	if (!memory_limit)
@@ -472,12 +474,12 @@ void __init lmb_enforce_memory_limit(u64 memory_limit)
 	}
 }
 
-int __init lmb_is_reserved(u64 addr)
+int __init lmb_is_reserved(phys_addr_t addr)
 {
 	int i;
 
 	for (i = 0; i < lmb.reserved.cnt; i++) {
-		u64 upper = lmb.reserved.regions[i].base +
+		phys_addr_t upper = lmb.reserved.regions[i].base +
 			lmb.reserved.regions[i].size - 1;
 		if ((addr >= lmb.reserved.regions[i].base) && (addr <= upper))
 			return 1;
@@ -485,13 +487,13 @@ int __init lmb_is_reserved(u64 addr)
 	return 0;
 }
 
-int lmb_is_region_reserved(u64 base, u64 size)
+int lmb_is_region_reserved(phys_addr_t base, phys_addr_t size)
 {
 	return lmb_overlaps_region(&lmb.reserved, base, size);
 }
 
 
-void __init lmb_set_current_limit(u64 limit)
+void __init lmb_set_current_limit(phys_addr_t limit)
 {
 	lmb.current_limit = limit;
 }
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
