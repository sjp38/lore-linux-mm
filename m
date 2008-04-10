Message-Id: <20080410171101.395469000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:42 +1000
From: npiggin@suse.de
Subject: [patch 10/17] mm: fix bootmem alignment
Content-Disposition: inline; filename=bootmem-fix-alignment.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Without this fix bootmem can return unaligned addresses when the start of a
node is not aligned to the align value. Needed for reliably allocating
gigabyte pages.

I removed the offset variable because all tests should align themself correctly
now. Slight drawback might be that the bootmem allocator will spend
some more time skipping bits in the bitmap initially, but that shouldn't
be a big issue.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 mm/bootmem.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -206,8 +206,9 @@ void * __init
 __alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
 	      unsigned long align, unsigned long goal, unsigned long limit)
 {
-	unsigned long offset, remaining_size, areasize, preferred;
-	unsigned long i, start = 0, incr, eidx, end_pfn;
+	unsigned long remaining_size, areasize, preferred;
+	unsigned long i, start, incr, eidx, end_pfn;
+	unsigned long pfn;
 	void *ret;
 
 	if (!size) {
@@ -229,10 +230,6 @@ __alloc_bootmem_core(struct bootmem_data
 		end_pfn = limit;
 
 	eidx = end_pfn - PFN_DOWN(bdata->node_boot_start);
-	offset = 0;
-	if (align && (bdata->node_boot_start & (align - 1UL)) != 0)
-		offset = align - (bdata->node_boot_start & (align - 1UL));
-	offset = PFN_DOWN(offset);
 
 	/*
 	 * We try to allocate bootmem pages above 'goal'
@@ -247,15 +244,18 @@ __alloc_bootmem_core(struct bootmem_data
 	} else
 		preferred = 0;
 
-	preferred = PFN_DOWN(ALIGN(preferred, align)) + offset;
+	start = bdata->node_boot_start;
+	preferred = PFN_DOWN(ALIGN(preferred + start, align) - start);
 	areasize = (size + PAGE_SIZE-1) / PAGE_SIZE;
 	incr = align >> PAGE_SHIFT ? : 1;
+	pfn = PFN_DOWN(start);
+	start = 0;
 
 restart_scan:
 	for (i = preferred; i < eidx; i += incr) {
 		unsigned long j;
 		i = find_next_zero_bit(bdata->node_bootmem_map, eidx, i);
-		i = ALIGN(i, incr);
+		i = ALIGN(pfn + i, incr) - pfn;
 		if (i >= eidx)
 			break;
 		if (test_bit(i, bdata->node_bootmem_map))
@@ -269,11 +269,11 @@ restart_scan:
 		start = i;
 		goto found;
 	fail_block:
-		i = ALIGN(j, incr);
+		i = ALIGN(j + pfn, incr) - pfn;
 	}
 
-	if (preferred > offset) {
-		preferred = offset;
+	if (preferred > 0) {
+		preferred = 0;
 		goto restart_scan;
 	}
 	return NULL;
@@ -289,7 +289,7 @@ found:
 	 */
 	if (align < PAGE_SIZE &&
 	    bdata->last_offset && bdata->last_pos+1 == start) {
-		offset = ALIGN(bdata->last_offset, align);
+		unsigned long offset = ALIGN(bdata->last_offset, align);
 		BUG_ON(offset > PAGE_SIZE);
 		remaining_size = PAGE_SIZE - offset;
 		if (size < remaining_size) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
