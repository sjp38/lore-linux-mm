Message-Id: <20080530194738.582992063@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:27 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 07/14] bootmem: clean up free_all_bootmem_core
Content-Disposition: inline; filename=bootmem-cleanup-free_all_bootmem.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rewrite the code in a more concise way using less variables.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
---

 mm/bootmem.c |   83 +++++++++++++++++++++++++++--------------------------------
 1 file changed, 38 insertions(+), 45 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -144,66 +144,59 @@ unsigned long __init init_bootmem(unsign
 
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
+	int aligned;
 	struct page *page;
-	unsigned long pfn;
-	unsigned long i, count;
-	unsigned long idx, pages;
-	unsigned long *map;
-	int gofast = 0;
-
-	BUG_ON(!bdata->node_bootmem_map);
-
-	count = 0;
-	/* first extant page of the node */
-	pfn = PFN_DOWN(bdata->node_boot_start);
-	idx = bdata->node_low_pfn - pfn;
-	map = bdata->node_bootmem_map;
+	unsigned long start, end, pages, count = 0;
+
+	if (!bdata->node_bootmem_map)
+		return 0;
+
+	start = PFN_DOWN(bdata->node_boot_start);
+	end = bdata->node_low_pfn;
+
 	/*
-	 * Check if we are aligned to BITS_PER_LONG pages.  If so, we might
-	 * be able to free page orders of that size at once.
+	 * If the start is aligned to the machines wordsize, we might
+	 * be able to free pages in bulks of that order.
 	 */
-	if (!(pfn & (BITS_PER_LONG-1)))
-		gofast = 1;
+	aligned = !(start & (BITS_PER_LONG - 1));
+
+	bdebug("nid=%d start=%lx end=%lx aligned=%d\n",
+		bdata - bootmem_node_data, start, end, aligned);
+
+	while (start < end) {
+		unsigned long *map, idx, vec;
 
-	for (i = 0; i < idx; ) {
-		unsigned long v = ~map[i / BITS_PER_LONG];
+		map = bdata->node_bootmem_map;
+		idx = start - PFN_DOWN(bdata->node_boot_start);
+		vec = ~map[idx / BITS_PER_LONG];
 
-		if (gofast && v == ~0UL) {
-			int order;
+		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
+			int order = ilog2(BITS_PER_LONG);
 
-			page = pfn_to_page(pfn);
+			__free_pages_bootmem(pfn_to_page(start), order);
 			count += BITS_PER_LONG;
-			order = ffs(BITS_PER_LONG) - 1;
-			__free_pages_bootmem(page, order);
-			i += BITS_PER_LONG;
-			page += BITS_PER_LONG;
-		} else if (v) {
-			unsigned long m;
-
-			page = pfn_to_page(pfn);
-			for (m = 1; m && i < idx; m<<=1, page++, i++) {
-				if (v & m) {
-					count++;
+		} else {
+			unsigned long off = 0;
+
+			while (vec && off < BITS_PER_LONG) {
+				if (vec & 1) {
+					page = pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
+					count++;
 				}
+				vec >>= 1;
+				off++;
 			}
-		} else {
-			i += BITS_PER_LONG;
 		}
-		pfn += BITS_PER_LONG;
+		start += BITS_PER_LONG;
 	}
 
-	/*
-	 * Now free the allocator bitmap itself, it's not
-	 * needed anymore:
-	 */
 	page = virt_to_page(bdata->node_bootmem_map);
 	pages = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
-	idx = bootmem_bootmap_pages(pages);
-	for (i = 0; i < idx; i++, page++)
-		__free_pages_bootmem(page, 0);
-	count += i;
-	bdata->node_bootmem_map = NULL;
+	pages = bootmem_bootmap_pages(pages);
+	count += pages;
+	while (pages--)
+		__free_pages_bootmem(page++, 0);
 
 	bdebug("nid=%d released=%ld\n", bdata - bootmem_node_data, count);
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
