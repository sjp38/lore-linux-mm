Date: Thu, 10 Apr 2003 12:24:21 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <20030410122421.A17889@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is from the IA64 tree, with some minor cleanups by me.
David described it as:

  This is a performance speed up and some minor indendation fixups.

  The problem is that the bootmem code is (a) hugely slow and (b) has
  execution that grow quadratically with the size of the bootmap bitmap.
  This causes noticable slowdowns, especially on machines with (relatively)
  large holes in the physical memory map.  Issue (b) is addressed by
  maintaining the "last_success" cache, so that we start the next search
  from the place where we last found some memory (this part of the patch
  could stand additional reviewing/testing).  Issue (a) is addressed by
  using find_next_zero_bit() instead of the slow bit-by-bit testing.


--- 1.14/mm/bootmem.c	Sat Dec 14 12:42:15 2002
+++ edited/mm/bootmem.c	Thu Apr 10 07:28:20 2003
@@ -135,26 +135,24 @@
  * is not a problem.
  *
  * On low memory boxes we get it right in 100% of the cases.
- */
-
-/*
+ *
  * alignment has to be a power of 2 value.
+ *
+ * NOTE:  This function is _not_ reenetrant.
  */
-static void * __init __alloc_bootmem_core (bootmem_data_t *bdata, 
-	unsigned long size, unsigned long align, unsigned long goal)
+static void * __init
+__alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
+		unsigned long align, unsigned long goal)
 {
-	unsigned long i, start = 0;
+	unsigned long offset, remaining_size, areasize, preferred;
+	unsigned long i, start = 0, incr, eidx;
+	static unsigned long last_success;
 	void *ret;
-	unsigned long offset, remaining_size;
-	unsigned long areasize, preferred, incr;
-	unsigned long eidx = bdata->node_low_pfn - (bdata->node_boot_start >>
-							PAGE_SHIFT);
-
-	if (!size) BUG();
 
-	if (align & (align-1))
-		BUG();
+	BUG_ON(!size);
+	BUG_ON(align & (align-1));
 
+	eidx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
 	offset = 0;
 	if (align &&
 	    (bdata->node_boot_start & (align - 1UL)) != 0)
@@ -166,8 +164,11 @@
 	 * first, then we try to allocate lower pages.
 	 */
 	if (goal && (goal >= bdata->node_boot_start) && 
-			((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
+	    ((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
 		preferred = goal - bdata->node_boot_start;
+
+		if (last_success >= preferred)
+			preferred = last_success;
 	} else
 		preferred = 0;
 
@@ -179,6 +180,8 @@
 restart_scan:
 	for (i = preferred; i < eidx; i += incr) {
 		unsigned long j;
+		i = find_next_zero_bit(bdata->node_bootmem_map, eidx, i);
+		i = (i + incr - 1) & -incr;
 		if (test_bit(i, bdata->node_bootmem_map))
 			continue;
 		for (j = i + 1; j < i + areasize; ++j) {
@@ -189,31 +192,33 @@
 		}
 		start = i;
 		goto found;
-	fail_block:;
+	fail_block:
+		;
 	}
+
 	if (preferred) {
 		preferred = offset;
 		goto restart_scan;
 	}
 	return NULL;
+
 found:
-	if (start >= eidx)
-		BUG();
+	last_success = start << PAGE_SHIFT;
+	BUG_ON(start >= eidx);
 
 	/*
 	 * Is the next page of the previous allocation-end the start
 	 * of this allocation's buffer? If yes then we can 'merge'
 	 * the previous partial page with this allocation.
 	 */
-	if (align < PAGE_SIZE
-	    && bdata->last_offset && bdata->last_pos+1 == start) {
+	if (align < PAGE_SIZE &&
+	    bdata->last_offset && bdata->last_pos+1 == start) {
 		offset = (bdata->last_offset+align-1) & ~(align-1);
-		if (offset > PAGE_SIZE)
-			BUG();
+		BUG_ON(offset > PAGE_SIZE);
 		remaining_size = PAGE_SIZE-offset;
 		if (size < remaining_size) {
 			areasize = 0;
-			// last_pos unchanged
+			/* last_pos unchanged */
 			bdata->last_offset = offset+size;
 			ret = phys_to_virt(bdata->last_pos*PAGE_SIZE + offset +
 						bdata->node_boot_start);
@@ -231,11 +236,12 @@
 		bdata->last_offset = size & ~PAGE_MASK;
 		ret = phys_to_virt(start * PAGE_SIZE + bdata->node_boot_start);
 	}
+
 	/*
 	 * Reserve the area now:
 	 */
 	for (i = start; i < start+areasize; i++)
-		if (test_and_set_bit(i, bdata->node_bootmem_map))
+		if (unlikely(test_and_set_bit(i, bdata->node_bootmem_map)))
 			BUG();
 	memset(ret, 0, size);
 	return ret;
@@ -256,21 +262,21 @@
 	map = bdata->node_bootmem_map;
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
-		if (v) { 
+		if (v) {
 			unsigned long m;
-			for (m = 1; m && i < idx; m<<=1, page++, i++) { 
+			for (m = 1; m && i < idx; m<<=1, page++, i++) {
 				if (v & m) {
-			count++;
-			ClearPageReserved(page);
-			set_page_count(page, 1);
-			__free_page(page);
-		}
-	}
+					count++;
+					ClearPageReserved(page);
+					set_page_count(page, 1);
+					__free_page(page);
+				}
+			}
 		} else {
 			i+=BITS_PER_LONG;
-			page+=BITS_PER_LONG; 
-		} 	
-	}	
+			page += BITS_PER_LONG;
+		}
+	}
 	total += count;
 
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
