Message-Id: <20080530194738.789921715@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:28 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 08/14] bootmem: clean up alloc_bootmem_core
Content-Disposition: inline; filename=bootmem-cleanup-alloc_bootmem_core.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_bootmem_core has become quite nasty to read over time.  This is
a clean rewrite that keeps the semantics.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 include/linux/bootmem.h |    1 
 mm/bootmem.c            |  208 ++++++++++++++++--------------------------------
 2 files changed, 72 insertions(+), 137 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -427,36 +427,16 @@ int __init reserve_bootmem(unsigned long
 }
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
-/*
- * We 'merge' subsequent allocations to save space. We might 'lose'
- * some fraction of a page if allocations cannot be satisfied due to
- * size constraints on boxes where there is physical RAM space
- * fragmentation - in these cases (mostly large memory boxes) this
- * is not a problem.
- *
- * On low memory boxes we get it right in 100% of the cases.
- *
- * alignment has to be a power of 2 value.
- *
- * NOTE:  This function is _not_ reentrant.
- */
-static void * __init
-alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
-		unsigned long align, unsigned long goal, unsigned long limit)
+static void * __init alloc_bootmem_core(struct bootmem_data *bdata,
+				unsigned long size, unsigned long align,
+				unsigned long goal, unsigned long limit)
 {
-	unsigned long areasize, preferred;
-	unsigned long i, start = 0, incr, eidx, end_pfn;
-	void *ret;
-	unsigned long node_boot_start;
-	void *node_bootmem_map;
-
-	if (!size) {
-		printk("alloc_bootmem_core(): zero-sized request\n");
-		BUG();
-	}
-	BUG_ON(align & (align-1));
+	unsigned long min, max, start, step;
+
+	BUG_ON(!size);
+	BUG_ON(align & (align - 1));
+	BUG_ON(limit && goal + size > limit);
 
-	/* on nodes without memory - bootmem_map is NULL */
 	if (!bdata->node_bootmem_map)
 		return NULL;
 
@@ -464,126 +444,82 @@ alloc_bootmem_core(struct bootmem_data *
 		bdata - bootmem_node_data, size, PAGE_ALIGN(size) >> PAGE_SHIFT,
 		align, goal, limit);
 
-	/* bdata->node_boot_start is supposed to be (12+6)bits alignment on x86_64 ? */
-	node_boot_start = bdata->node_boot_start;
-	node_bootmem_map = bdata->node_bootmem_map;
-	if (align) {
-		node_boot_start = ALIGN(bdata->node_boot_start, align);
-		if (node_boot_start > bdata->node_boot_start)
-			node_bootmem_map = (unsigned long *)bdata->node_bootmem_map +
-			    PFN_DOWN(node_boot_start - bdata->node_boot_start)/BITS_PER_LONG;
-	}
+	min = PFN_DOWN(bdata->node_boot_start);
+	max = bdata->node_low_pfn;
 
-	if (limit && node_boot_start >= limit)
-		return NULL;
+	goal >>= PAGE_SHIFT;
+	limit >>= PAGE_SHIFT;
 
-	end_pfn = bdata->node_low_pfn;
-	limit = PFN_DOWN(limit);
-	if (limit && end_pfn > limit)
-		end_pfn = limit;
+	if (limit && max > limit)
+		max = limit;
+	if (max <= min)
+		return NULL;
 
-	eidx = end_pfn - PFN_DOWN(node_boot_start);
+	step = max(align >> PAGE_SHIFT, 1UL);
 
-	/*
-	 * We try to allocate bootmem pages above 'goal'
-	 * first, then we try to allocate lower pages.
-	 */
-	preferred = 0;
-	if (goal && PFN_DOWN(goal) < end_pfn) {
-		if (goal > node_boot_start)
-			preferred = goal - node_boot_start;
-
-		if (bdata->last_success > node_boot_start &&
-			bdata->last_success - node_boot_start >= preferred)
-			if (!limit || (limit && limit > bdata->last_success))
-				preferred = bdata->last_success - node_boot_start;
+	if (goal && goal < max)
+		start = ALIGN(goal, step);
+	else
+		start = ALIGN(min, step);
+
+	if (bdata->last_success > start) {
+		/* Set goal here to trigger a retry on failure */
+		start = goal = ALIGN(bdata->last_success, step);
 	}
 
-	preferred = PFN_DOWN(ALIGN(preferred, align));
-	areasize = (size + PAGE_SIZE-1) / PAGE_SIZE;
-	incr = align >> PAGE_SHIFT ? : 1;
-
-restart_scan:
-	for (i = preferred; i < eidx;) {
-		unsigned long j;
-
-		i = find_next_zero_bit(node_bootmem_map, eidx, i);
-		i = ALIGN(i, incr);
-		if (i >= eidx)
-			break;
-		if (test_bit(i, node_bootmem_map)) {
-			i += incr;
-			continue;
-		}
-		for (j = i + 1; j < i + areasize; ++j) {
-			if (j >= eidx)
-				goto fail_block;
-			if (test_bit(j, node_bootmem_map))
-				goto fail_block;
-		}
-		start = i;
-		goto found;
-	fail_block:
-		i = ALIGN(j, incr);
-		if (i == j)
-			i += incr;
-	}
+	max -= PFN_DOWN(bdata->node_boot_start);
+	start -= PFN_DOWN(bdata->node_boot_start);
 
-	if (preferred > 0) {
-		preferred = 0;
-		goto restart_scan;
-	}
-	return NULL;
+	while (1) {
+		int merge;
+		void *region;
+		unsigned long end, i, new_start, new_end;
+find_block:
+		start = find_next_zero_bit(bdata->node_bootmem_map, max, start);
+		start = ALIGN(start, step);
+		end = start + PFN_UP(size);
 
-found:
-	bdata->last_success = PFN_PHYS(start) + node_boot_start;
-	BUG_ON(start >= eidx);
+		if (start >= max || end > max)
+			break;
 
-	/*
-	 * Is the next page of the previous allocation-end the start
-	 * of this allocation's buffer? If yes then we can 'merge'
-	 * the previous partial page with this allocation.
-	 */
-	if (align < PAGE_SIZE &&
-	    bdata->last_offset && bdata->last_pos+1 == start) {
-		unsigned long offset, remaining_size;
-		offset = ALIGN(bdata->last_offset, align);
-		BUG_ON(offset > PAGE_SIZE);
-		remaining_size = PAGE_SIZE - offset;
-		if (size < remaining_size) {
-			areasize = 0;
-			/* last_pos unchanged */
-			bdata->last_offset = offset + size;
-			ret = phys_to_virt(bdata->last_pos * PAGE_SIZE +
-					   offset + node_boot_start);
-		} else {
-			remaining_size = size - remaining_size;
-			areasize = (remaining_size + PAGE_SIZE-1) / PAGE_SIZE;
-			ret = phys_to_virt(bdata->last_pos * PAGE_SIZE +
-					   offset + node_boot_start);
-			bdata->last_pos = start + areasize - 1;
-			bdata->last_offset = remaining_size;
-		}
-		bdata->last_offset &= ~PAGE_MASK;
-	} else {
-		bdata->last_pos = start + areasize - 1;
-		bdata->last_offset = size & ~PAGE_MASK;
-		ret = phys_to_virt(start * PAGE_SIZE + node_boot_start);
+		for (i = start; i < end; i++)
+			if (test_bit(i, bdata->node_bootmem_map)) {
+				start = ALIGN(i, step);
+				if (start == i)
+					start += step;
+				goto find_block;
+			}
+
+		if (bdata->last_offset &&
+				PFN_DOWN(bdata->last_offset) + 1 == start)
+			new_start = ALIGN(bdata->last_offset, align);
+		else
+			new_start = PFN_PHYS(start);
+
+		merge = PFN_DOWN(new_start) < start;
+		new_end = new_start + size;
+
+		bdata->last_offset = new_end;
+
+		/*
+		 * Reserve the area now:
+		 */
+		for (i = PFN_DOWN(new_start) + merge; i < PFN_UP(new_end); i++)
+			if (test_and_set_bit(i, bdata->node_bootmem_map))
+				BUG();
+
+		region = phys_to_virt(bdata->node_boot_start + new_start);
+		memset(region, 0, size);
+		return region;
 	}
 
-	bdebug("nid=%d start=%lx end=%lx\n",
-		bdata - bootmem_node_data,
-		start + PFN_DOWN(bdata->node_boot_start),
-		start + areasize + PFN_DOWN(bdata->node_boot_start));
+	if (goal) {
+		goal = 0;
+		start = 0;
+		goto find_block;
+	}
 
-	/*
-	 * Reserve the area now:
-	 */
-	for (i = start; i < start + areasize; i++)
-		if (unlikely(test_and_set_bit(i, node_bootmem_map)))
-			BUG();
-	memset(ret, 0, size);
-	return ret;
+	return NULL;
 }
 
 /**
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -32,7 +32,6 @@ typedef struct bootmem_data {
 	unsigned long node_low_pfn;
 	void *node_bootmem_map;
 	unsigned long last_offset;
-	unsigned long last_pos;
 	unsigned long last_success;	/* Previous allocation point.  To speed
 					 * up searching */
 	struct list_head list;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
