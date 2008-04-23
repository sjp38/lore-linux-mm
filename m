Message-Id: <20080423015429.942777000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:05 +1000
From: npiggin@suse.de
Subject: [patch 03/18] mm: offset align in alloc_bootmem
Content-Disposition: inline; filename=mm-offset-align-in-alloc_bootmem.patch
Sender: owner-linux-mm@kvack.org
From: Yinghai Lu <yhlu.kernel.send@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Need offset alignment when node_boot_start's alignment is less than align
required

Use local node_boot_start to match align.  so don't add extra opteration in
search loop.

[this is in -mm already, but needs to be applied to mainline to run this
patchset]

Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
---

 mm/bootmem.c |   60 +++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -206,9 +206,11 @@ void * __init
 __alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
 	      unsigned long align, unsigned long goal, unsigned long limit)
 {
-	unsigned long offset, remaining_size, areasize, preferred;
+	unsigned long areasize, preferred;
 	unsigned long i, start = 0, incr, eidx, end_pfn;
 	void *ret;
+	unsigned long node_boot_start;
+	void *node_bootmem_map;
 
 	if (!size) {
 		printk("__alloc_bootmem_core(): zero-sized request\n");
@@ -216,54 +218,61 @@ __alloc_bootmem_core(struct bootmem_data
 	}
 	BUG_ON(align & (align-1));
 
-	if (limit && bdata->node_boot_start >= limit)
-		return NULL;
-
 	/* on nodes without memory - bootmem_map is NULL */
 	if (!bdata->node_bootmem_map)
 		return NULL;
 
+	/* bdata->node_boot_start is supposed to be (12+6)bits alignment on x86_64 ? */
+	node_boot_start = bdata->node_boot_start;
+	node_bootmem_map = bdata->node_bootmem_map;
+	if (align) {
+		node_boot_start = ALIGN(bdata->node_boot_start, align);
+		if (node_boot_start > bdata->node_boot_start)
+			node_bootmem_map = (unsigned long *)bdata->node_bootmem_map +
+			    PFN_DOWN(node_boot_start - bdata->node_boot_start)/BITS_PER_LONG;
+	}
+
+	if (limit && node_boot_start >= limit)
+		return NULL;
+
 	end_pfn = bdata->node_low_pfn;
 	limit = PFN_DOWN(limit);
 	if (limit && end_pfn > limit)
 		end_pfn = limit;
 
-	eidx = end_pfn - PFN_DOWN(bdata->node_boot_start);
-	offset = 0;
-	if (align && (bdata->node_boot_start & (align - 1UL)) != 0)
-		offset = align - (bdata->node_boot_start & (align - 1UL));
-	offset = PFN_DOWN(offset);
+	eidx = end_pfn - PFN_DOWN(node_boot_start);
 
 	/*
 	 * We try to allocate bootmem pages above 'goal'
 	 * first, then we try to allocate lower pages.
 	 */
-	if (goal && goal >= bdata->node_boot_start && PFN_DOWN(goal) < end_pfn) {
-		preferred = goal - bdata->node_boot_start;
+	if (goal && goal >= node_boot_start && PFN_DOWN(goal) < end_pfn) {
+		preferred = goal - node_boot_start;
 
-		if (bdata->last_success >= preferred)
+		if (bdata->last_success > node_boot_start &&
+			bdata->last_success - node_boot_start >= preferred)
 			if (!limit || (limit && limit > bdata->last_success))
-				preferred = bdata->last_success;
+				preferred = bdata->last_success - node_boot_start;
 	} else
 		preferred = 0;
 
-	preferred = PFN_DOWN(ALIGN(preferred, align)) + offset;
+	preferred = PFN_DOWN(ALIGN(preferred, align));
 	areasize = (size + PAGE_SIZE-1) / PAGE_SIZE;
 	incr = align >> PAGE_SHIFT ? : 1;
 
 restart_scan:
 	for (i = preferred; i < eidx; i += incr) {
 		unsigned long j;
-		i = find_next_zero_bit(bdata->node_bootmem_map, eidx, i);
+		i = find_next_zero_bit(node_bootmem_map, eidx, i);
 		i = ALIGN(i, incr);
 		if (i >= eidx)
 			break;
-		if (test_bit(i, bdata->node_bootmem_map))
+		if (test_bit(i, node_bootmem_map))
 			continue;
 		for (j = i + 1; j < i + areasize; ++j) {
 			if (j >= eidx)
 				goto fail_block;
-			if (test_bit(j, bdata->node_bootmem_map))
+			if (test_bit(j, node_bootmem_map))
 				goto fail_block;
 		}
 		start = i;
@@ -272,14 +281,14 @@ restart_scan:
 		i = ALIGN(j, incr);
 	}
 
-	if (preferred > offset) {
-		preferred = offset;
+	if (preferred > 0) {
+		preferred = 0;
 		goto restart_scan;
 	}
 	return NULL;
 
 found:
-	bdata->last_success = PFN_PHYS(start);
+	bdata->last_success = PFN_PHYS(start) + node_boot_start;
 	BUG_ON(start >= eidx);
 
 	/*
@@ -289,6 +298,7 @@ found:
 	 */
 	if (align < PAGE_SIZE &&
 	    bdata->last_offset && bdata->last_pos+1 == start) {
+		unsigned long offset, remaining_size;
 		offset = ALIGN(bdata->last_offset, align);
 		BUG_ON(offset > PAGE_SIZE);
 		remaining_size = PAGE_SIZE - offset;
@@ -297,14 +307,12 @@ found:
 			/* last_pos unchanged */
 			bdata->last_offset = offset + size;
 			ret = phys_to_virt(bdata->last_pos * PAGE_SIZE +
-					   offset +
-					   bdata->node_boot_start);
+					   offset + node_boot_start);
 		} else {
 			remaining_size = size - remaining_size;
 			areasize = (remaining_size + PAGE_SIZE-1) / PAGE_SIZE;
 			ret = phys_to_virt(bdata->last_pos * PAGE_SIZE +
-					   offset +
-					   bdata->node_boot_start);
+					   offset + node_boot_start);
 			bdata->last_pos = start + areasize - 1;
 			bdata->last_offset = remaining_size;
 		}
@@ -312,14 +320,14 @@ found:
 	} else {
 		bdata->last_pos = start + areasize - 1;
 		bdata->last_offset = size & ~PAGE_MASK;
-		ret = phys_to_virt(start * PAGE_SIZE + bdata->node_boot_start);
+		ret = phys_to_virt(start * PAGE_SIZE + node_boot_start);
 	}
 
 	/*
 	 * Reserve the area now:
 	 */
 	for (i = start; i < start + areasize; i++)
-		if (unlikely(test_and_set_bit(i, bdata->node_bootmem_map)))
+		if (unlikely(test_and_set_bit(i, node_bootmem_map)))
 			BUG();
 	memset(ret, 0, size);
 	return ret;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
