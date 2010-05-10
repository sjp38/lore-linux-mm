Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7226E0002
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:45:29 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 18/25] lmb: Move functions around into a more sensible order
Date: Mon, 10 May 2010 19:38:52 +1000
Message-Id: <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Some shuffling is needed for doing array resize so we may as well
put some sense into the ordering of the functions in the whole lmb.c
file. No code change. Added some comments.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |  295 ++++++++++++++++++++++++++++++++----------------------------
 1 files changed, 157 insertions(+), 138 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 95ef5b6..4977888 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -24,40 +24,18 @@ static struct lmb_region lmb_reserved_init_regions[INIT_LMB_REGIONS + 1];
 
 #define LMB_ERROR	(~(phys_addr_t)0)
 
-static int __init early_lmb(char *p)
-{
-	if (p && strstr(p, "debug"))
-		lmb_debug = 1;
-	return 0;
-}
-early_param("lmb", early_lmb);
+/*
+ * Address comparison utilities
+ */
 
-static void lmb_dump(struct lmb_type *region, char *name)
+static phys_addr_t lmb_align_down(phys_addr_t addr, phys_addr_t size)
 {
-	unsigned long long base, size;
-	int i;
-
-	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
-
-	for (i = 0; i < region->cnt; i++) {
-		base = region->regions[i].base;
-		size = region->regions[i].size;
-
-		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
-		    name, i, base, base + size - 1, size);
-	}
+	return addr & ~(size - 1);
 }
 
-void lmb_dump_all(void)
+static phys_addr_t lmb_align_up(phys_addr_t addr, phys_addr_t size)
 {
-	if (!lmb_debug)
-		return;
-
-	pr_info("LMB configuration:\n");
-	pr_info(" memory size = 0x%llx\n", (unsigned long long)lmb.memory_size);
-
-	lmb_dump(&lmb.memory, "memory");
-	lmb_dump(&lmb.reserved, "reserved");
+	return (addr + (size - 1)) & ~(size - 1);
 }
 
 static unsigned long lmb_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
@@ -88,6 +66,77 @@ static long lmb_regions_adjacent(struct lmb_type *type,
 	return lmb_addrs_adjacent(base1, size1, base2, size2);
 }
 
+long lmb_overlaps_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
+{
+	unsigned long i;
+
+	for (i = 0; i < type->cnt; i++) {
+		phys_addr_t rgnbase = type->regions[i].base;
+		phys_addr_t rgnsize = type->regions[i].size;
+		if (lmb_addrs_overlap(base, size, rgnbase, rgnsize))
+			break;
+	}
+
+	return (i < type->cnt) ? i : -1;
+}
+
+/*
+ * Find, allocate, deallocate or reserve unreserved regions. All allocations
+ * are top-down.
+ */
+
+static phys_addr_t __init lmb_find_region(phys_addr_t start, phys_addr_t end,
+					  phys_addr_t size, phys_addr_t align)
+{
+	phys_addr_t base, res_base;
+	long j;
+
+	base = lmb_align_down((end - size), align);
+	while (start <= base) {
+		j = lmb_overlaps_region(&lmb.reserved, base, size);
+		if (j < 0)
+			return base;
+		res_base = lmb.reserved.regions[j].base;
+		if (res_base < size)
+			break;
+		base = lmb_align_down(res_base - size, align);
+	}
+
+	return LMB_ERROR;
+}
+
+static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{
+	long i;
+	phys_addr_t base = 0;
+	phys_addr_t res_base;
+
+	BUG_ON(0 == size);
+
+	size = lmb_align_up(size, align);
+
+	/* Pump up max_addr */
+	if (max_addr == LMB_ALLOC_ACCESSIBLE)
+		max_addr = lmb.current_limit;
+	
+	/* We do a top-down search, this tends to limit memory
+	 * fragmentation by keeping early boot allocs near the
+	 * top of memory
+	 */
+	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
+		phys_addr_t lmbbase = lmb.memory.regions[i].base;
+		phys_addr_t lmbsize = lmb.memory.regions[i].size;
+
+		if (lmbsize < size)
+			continue;
+		base = min(lmbbase + lmbsize, max_addr);
+		res_base = lmb_find_region(lmbbase, base, size, align);		
+		if (res_base != LMB_ERROR)
+			return res_base;
+	}
+	return 0;
+}
+
 static void lmb_remove_region(struct lmb_type *type, unsigned long r)
 {
 	unsigned long i;
@@ -107,22 +156,6 @@ static void lmb_coalesce_regions(struct lmb_type *type,
 	lmb_remove_region(type, r2);
 }
 
-void __init lmb_analyze(void)
-{
-	int i;
-
-	/* Check marker in the unused last array entry */
-	WARN_ON(lmb_memory_init_regions[INIT_LMB_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
-	WARN_ON(lmb_reserved_init_regions[INIT_LMB_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
-
-	lmb.memory_size = 0;
-
-	for (i = 0; i < lmb.memory.cnt; i++)
-		lmb.memory_size += lmb.memory.regions[i].size;
-}
-
 static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -260,50 +293,42 @@ long __init lmb_reserve(phys_addr_t base, phys_addr_t size)
 	return lmb_add_region(_rgn, base, size);
 }
 
-long lmb_overlaps_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
+phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	unsigned long i;
+	phys_addr_t found = lmb_find_base(size, align, max_addr);
 
-	for (i = 0; i < type->cnt; i++) {
-		phys_addr_t rgnbase = type->regions[i].base;
-		phys_addr_t rgnsize = type->regions[i].size;
-		if (lmb_addrs_overlap(base, size, rgnbase, rgnsize))
-			break;
-	}
+	if (found != LMB_ERROR &&
+	    lmb_add_region(&lmb.reserved, found, size) >= 0)
+		return found;
 
-	return (i < type->cnt) ? i : -1;
+	return 0;
 }
 
-static phys_addr_t lmb_align_down(phys_addr_t addr, phys_addr_t size)
+phys_addr_t __init lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return addr & ~(size - 1);
-}
+	phys_addr_t alloc;
 
-static phys_addr_t lmb_align_up(phys_addr_t addr, phys_addr_t size)
-{
-	return (addr + (size - 1)) & ~(size - 1);
-}
+	alloc = __lmb_alloc_base(size, align, max_addr);
 
-static phys_addr_t __init lmb_find_region(phys_addr_t start, phys_addr_t end,
-					  phys_addr_t size, phys_addr_t align)
-{
-	phys_addr_t base, res_base;
-	long j;
+	if (alloc == 0)
+		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
+		      (unsigned long long) size, (unsigned long long) max_addr);
 
-	base = lmb_align_down((end - size), align);
-	while (start <= base) {
-		j = lmb_overlaps_region(&lmb.reserved, base, size);
-		if (j < 0)
-			return base;
-		res_base = lmb.reserved.regions[j].base;
-		if (res_base < size)
-			break;
-		base = lmb_align_down(res_base - size, align);
-	}
+	return alloc;
+}
 
-	return LMB_ERROR;
+phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align)
+{
+	return lmb_alloc_base(size, align, LMB_ALLOC_ACCESSIBLE);
 }
 
+
+/*
+ * Additional node-local allocators. Search for node memory is bottom up
+ * and walks lmb regions within that node bottom-up as well, but allocation
+ * within an lmb region is top-down.
+ */
+ 
 phys_addr_t __weak __init lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
 	*nid = 0;
@@ -361,67 +386,9 @@ phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 	return lmb_alloc(size, align);
 }
 
-phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align)
-{
-	return lmb_alloc_base(size, align, LMB_ALLOC_ACCESSIBLE);
-}
-
-static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	long i;
-	phys_addr_t base = 0;
-	phys_addr_t res_base;
-
-	BUG_ON(0 == size);
-
-	size = lmb_align_up(size, align);
-
-	/* Pump up max_addr */
-	if (max_addr == LMB_ALLOC_ACCESSIBLE)
-		max_addr = lmb.current_limit;
-	
-	/* We do a top-down search, this tends to limit memory
-	 * fragmentation by keeping early boot allocs near the
-	 * top of memory
-	 */
-	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
-		phys_addr_t lmbbase = lmb.memory.regions[i].base;
-		phys_addr_t lmbsize = lmb.memory.regions[i].size;
-
-		if (lmbsize < size)
-			continue;
-		base = min(lmbbase + lmbsize, max_addr);
-		res_base = lmb_find_region(lmbbase, base, size, align);		
-		if (res_base != LMB_ERROR)
-			return res_base;
-	}
-	return 0;
-}
-
-phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	phys_addr_t found = lmb_find_base(size, align, max_addr);
-
-	if (found != LMB_ERROR &&
-	    lmb_add_region(&lmb.reserved, found, size) >= 0)
-		return found;
-
-	return 0;
-}
-
-phys_addr_t __init lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	phys_addr_t alloc;
-
-	alloc = __lmb_alloc_base(size, align, max_addr);
-
-	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
-
-	return alloc;
-}
-
+/*
+ * Remaining API functions
+ */
 
 /* You must call lmb_analyze() before this. */
 phys_addr_t __init lmb_phys_mem_size(void)
@@ -501,6 +468,50 @@ void __init lmb_set_current_limit(phys_addr_t limit)
 	lmb.current_limit = limit;
 }
 
+static void lmb_dump(struct lmb_type *region, char *name)
+{
+	unsigned long long base, size;
+	int i;
+
+	pr_info(" %s.cnt  = 0x%lx\n", name, region->cnt);
+
+	for (i = 0; i < region->cnt; i++) {
+		base = region->regions[i].base;
+		size = region->regions[i].size;
+
+		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
+		    name, i, base, base + size - 1, size);
+	}
+}
+
+void lmb_dump_all(void)
+{
+	if (!lmb_debug)
+		return;
+
+	pr_info("LMB configuration:\n");
+	pr_info(" memory size = 0x%llx\n", (unsigned long long)lmb.memory_size);
+
+	lmb_dump(&lmb.memory, "memory");
+	lmb_dump(&lmb.reserved, "reserved");
+}
+
+void __init lmb_analyze(void)
+{
+	int i;
+
+	/* Check marker in the unused last array entry */
+	WARN_ON(lmb_memory_init_regions[INIT_LMB_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+	WARN_ON(lmb_reserved_init_regions[INIT_LMB_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+
+	lmb.memory_size = 0;
+
+	for (i = 0; i < lmb.memory.cnt; i++)
+		lmb.memory_size += lmb.memory.regions[i].size;
+}
+
 void __init lmb_init(void)
 {
 	/* Hookup the initial arrays */
@@ -528,3 +539,11 @@ void __init lmb_init(void)
 	lmb.current_limit = LMB_ALLOC_ANYWHERE;
 }
 
+static int __init early_lmb(char *p)
+{
+	if (p && strstr(p, "debug"))
+		lmb_debug = 1;
+	return 0;
+}
+early_param("lmb", early_lmb);
+
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
