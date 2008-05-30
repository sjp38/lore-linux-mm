Message-Id: <20080530194739.209985293@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:30 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 10/14] bootmem: factor out the marking of a PFN range
Content-Disposition: inline; filename=bootmem-refactor-range-marking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce new helpers that mark a range that resides completely on a
node or node-agnostic ranges that might also span node boundaries.

The free/reserve API functions will then directly use these helpers.

Note that the free/reserve semantics become more strict: while the
prior code took basically arbitrary range arguments and marked the
PFNs that happen to fall into that range, the new code requires
node-specific ranges to be completely on the node.  The node-agnostic
requests might span node boundaries as long as the nodes are
contiguous.

Passing ranges that do not satisfy these criteria is a bug.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
---

Sorry, this diff is still not really readable.  Any ideas how to split
that stuff properly?

 include/linux/bootmem.h |    2 
 mm/bootmem.c            |  191 ++++++++++++++++++------------------------------
 2 files changed, 73 insertions(+), 120 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -228,12 +228,16 @@ unsigned long __init free_all_bootmem(vo
 static void __init __free(bootmem_data_t *bdata,
 			unsigned long sidx, unsigned long eidx)
 {
-	unsigned long idx;
+	unsigned long idx, start;
 
 	bdebug("nid=%d start=%lx end=%lx\n", bdata - bootmem_node_data,
 		sidx + PFN_DOWN(bdata->node_boot_start),
 		eidx + PFN_DOWN(bdata->node_boot_start));
 
+	start = bdata->node_boot_start + PFN_PHYS(sidx);
+	if (bdata->last_success > start)
+		bdata->last_success = start;
+
 	for (idx = sidx; idx < eidx; idx++)
 		if (!test_and_clear_bit(idx, bdata->node_bootmem_map))
 			BUG();
@@ -263,39 +267,57 @@ static int __init __reserve(bootmem_data
 	return 0;
 }
 
-static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr,
-				     unsigned long size)
+static int __init mark_bootmem_node(bootmem_data_t *bdata,
+				unsigned long start, unsigned long end,
+				int reserve, int flags)
 {
 	unsigned long sidx, eidx;
-	unsigned long i;
 
-	BUG_ON(!size);
+	bdebug("nid=%d start=%lx end=%lx reserve=%d flags=%x\n",
+		bdata - bootmem_node_data, start, end, reserve, flags);
 
-	/* out range */
-	if (addr + size < bdata->node_boot_start ||
-		PFN_DOWN(addr) > bdata->node_low_pfn)
-		return;
-	/*
-	 * round down end of usable mem, partially free pages are
-	 * considered reserved.
-	 */
+	BUG_ON(start < PFN_DOWN(bdata->node_boot_start));
+	BUG_ON(end > bdata->node_low_pfn);
 
-	if (addr >= bdata->node_boot_start && addr < bdata->last_success)
-		bdata->last_success = addr;
+	sidx = start - PFN_DOWN(bdata->node_boot_start);
+	eidx = end - PFN_DOWN(bdata->node_boot_start);
 
-	/*
-	 * Round up to index to the range.
-	 */
-	if (PFN_UP(addr) > PFN_DOWN(bdata->node_boot_start))
-		sidx = PFN_UP(addr) - PFN_DOWN(bdata->node_boot_start);
+	if (reserve)
+		return __reserve(bdata, sidx, eidx, flags);
 	else
-		sidx = 0;
+		__free(bdata, sidx, eidx);
+	return 0;
+}
+
+static int __init mark_bootmem(unsigned long start, unsigned long end,
+				int reserve, int flags)
+{
+	unsigned long pos;
+	bootmem_data_t *bdata;
 
-	eidx = PFN_DOWN(addr + size - bdata->node_boot_start);
-	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
-		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
+	pos = start;
+	list_for_each_entry(bdata, &bdata_list, list) {
+		int err;
+		unsigned long max;
+
+		if (pos < PFN_DOWN(bdata->node_boot_start)) {
+			BUG_ON(pos != start);
+			continue;
+		}
 
-	__free(bdata, sidx, eidx);
+		max = min(bdata->node_low_pfn, end);
+
+		err = mark_bootmem_node(bdata, pos, max, reserve, flags);
+		if (reserve && err) {
+			mark_bootmem(start, pos, 0, 0);
+			return err;
+		}
+
+		if (max == end)
+			return 0;
+		pos = bdata->node_low_pfn;
+	}
+	BUG();
 }
 
 /**
@@ -306,12 +328,17 @@ static void __init free_bootmem_core(boo
  *
  * Partial pages will be considered reserved and left as they are.
  *
- * Only physical pages that actually reside on @pgdat are marked.
+ * The range must reside completely on the specified node.
  */
 void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
-	free_bootmem_core(pgdat->bdata, physaddr, size);
+	unsigned long start, end;
+
+	start = PFN_UP(physaddr);
+	end = PFN_DOWN(physaddr + size);
+
+	mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
 }
 
 /**
@@ -321,83 +348,16 @@ void __init free_bootmem_node(pg_data_t 
  *
  * Partial pages will be considered reserved and left as they are.
  *
- * All physical pages within the range are marked, no matter what
- * node they reside on.
+ * The range must be contiguous but may span node boundaries.
  */
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
-	bootmem_data_t *bdata;
-	list_for_each_entry(bdata, &bdata_list, list)
-		free_bootmem_core(bdata, addr, size);
-}
-
-/*
- * Marks a particular physical memory range as unallocatable. Usable RAM
- * might be used for boot-time allocations - or it might get added
- * to the free page pool later on.
- */
-static int __init can_reserve_bootmem_core(bootmem_data_t *bdata,
-			unsigned long addr, unsigned long size, int flags)
-{
-	unsigned long sidx, eidx;
-	unsigned long i;
-
-	BUG_ON(!size);
+	unsigned long start, end;
 
-	/* out of range, don't hold other */
-	if (addr + size < bdata->node_boot_start ||
-		PFN_DOWN(addr) > bdata->node_low_pfn)
-		return 0;
+	start = PFN_UP(addr);
+	end = PFN_DOWN(addr + size);
 
-	/*
-	 * Round up to index to the range.
-	 */
-	if (addr > bdata->node_boot_start)
-		sidx= PFN_DOWN(addr - bdata->node_boot_start);
-	else
-		sidx = 0;
-
-	eidx = PFN_UP(addr + size - bdata->node_boot_start);
-	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
-		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
-
-	for (i = sidx; i < eidx; i++) {
-		if (test_bit(i, bdata->node_bootmem_map)) {
-			if (flags & BOOTMEM_EXCLUSIVE)
-				return -EBUSY;
-		}
-	}
-
-	return 0;
-
-}
-
-static void __init reserve_bootmem_core(bootmem_data_t *bdata,
-			unsigned long addr, unsigned long size, int flags)
-{
-	unsigned long sidx, eidx;
-	unsigned long i;
-
-	BUG_ON(!size);
-
-	/* out of range */
-	if (addr + size < bdata->node_boot_start ||
-		PFN_DOWN(addr) > bdata->node_low_pfn)
-		return;
-
-	/*
-	 * Round up to index to the range.
-	 */
-	if (addr > bdata->node_boot_start)
-		sidx= PFN_DOWN(addr - bdata->node_boot_start);
-	else
-		sidx = 0;
-
-	eidx = PFN_UP(addr + size - bdata->node_boot_start);
-	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
-		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
-
-	return __reserve(bdata, sidx, eidx, flags);
+	mark_bootmem(start, end, 0, 0);
 }
 
 /**
@@ -407,17 +367,17 @@ static void __init reserve_bootmem_core(
  *
  * Partial pages will be reserved.
  *
- * Only physical pages that actually reside on @pgdat are marked.
+ * The range must reside completely on the specified node.
  */
-void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 				 unsigned long size, int flags)
 {
-	int ret;
+	unsigned long start, end;
 
-	ret = can_reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
-	if (ret < 0)
-		return;
-	reserve_bootmem_core(pgdat->bdata, physaddr, size, flags);
+	start = PFN_DOWN(physaddr);
+	end = PFN_UP(physaddr + size);
+
+	return mark_bootmem_node(pgdat->bdata, start, end, 1, flags);
 }
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
@@ -428,24 +388,17 @@ void __init reserve_bootmem_node(pg_data
  *
  * Partial pages will be reserved.
  *
- * All physical pages within the range are marked, no matter what
- * node they reside on.
+ * The range must be contiguous but may span node boundaries.
  */
 int __init reserve_bootmem(unsigned long addr, unsigned long size,
 			    int flags)
 {
-	bootmem_data_t *bdata;
-	int ret;
+	unsigned long start, end;
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ret = can_reserve_bootmem_core(bdata, addr, size, flags);
-		if (ret < 0)
-			return ret;
-	}
-	list_for_each_entry(bdata, &bdata_list, list)
-		reserve_bootmem_core(bdata, addr, size, flags);
+	start = PFN_DOWN(addr);
+	end = PFN_UP(addr + size);
 
-	return 0;
+	return mark_bootmem(start, end, 1, flags);
 }
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
@@ -716,7 +669,7 @@ void * __init alloc_bootmem_section(unsi
 	if (start_nr != section_nr || end_nr != section_nr) {
 		printk(KERN_WARNING "alloc_bootmem failed on section %ld.\n",
 		       section_nr);
-		free_bootmem_core(pgdat->bdata, __pa(ptr), size);
+		free_bootmem_node(pgdat, __pa(ptr), size);
 		ptr = NULL;
 	}
 
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -66,7 +66,7 @@ extern void free_bootmem(unsigned long a
 #define BOOTMEM_DEFAULT		0
 #define BOOTMEM_EXCLUSIVE	(1<<0)
 
-extern void reserve_bootmem_node(pg_data_t *pgdat,
+extern int reserve_bootmem_node(pg_data_t *pgdat,
 				 unsigned long physaddr,
 				 unsigned long size,
 				 int flags);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
