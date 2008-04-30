Message-Id: <20080430170839.566764928@symbol.fehenstaub.lan>
References: <20080430170521.246745395@symbol.fehenstaub.lan>
Date: Wed, 30 Apr 2008 19:05:23 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 2/4] mm: Fix free_all_bootmem_core alignment check
Content-Disposition: inline; filename=mm-fix-free_all_bootmem_core-alignment-check.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The check for node_boot_start is bogus because we start freeing at the
corresponding pfn.  So check if the pfn is properly aligned instead in
a more readable way and adjust the documentation.

Also remove an unneeded accounting variable.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
---

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -376,7 +376,7 @@ static unsigned long __init free_all_boo
 	struct page *page;
 	unsigned long pfn;
 	bootmem_data_t *bdata = pgdat->bdata;
-	unsigned long i, count, total = 0;
+	unsigned long i, count;
 	unsigned long idx;
 	unsigned long *map; 
 	int gofast = 0;
@@ -388,10 +388,13 @@ static unsigned long __init free_all_boo
 	pfn = PFN_DOWN(bdata->node_boot_start);
 	idx = bdata->node_low_pfn - pfn;
 	map = bdata->node_bootmem_map;
-	/* Check physaddr is O(LOG2(BITS_PER_LONG)) page aligned */
-	if (bdata->node_boot_start == 0 ||
-	    ffs(bdata->node_boot_start) - PAGE_SHIFT > ffs(BITS_PER_LONG))
+	/*
+	 * Check if we are aligned to BITS_PER_LONG pages.  If so, we might
+	 * be able to free page orders of that size at once.
+	 */
+	if (!(pfn & (BITS_PER_LONG-1)))
 		gofast = 1;
+
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
 
@@ -419,23 +422,19 @@ static unsigned long __init free_all_boo
 		}
 		pfn += BITS_PER_LONG;
 	}
-	total += count;
 
 	/*
 	 * Now free the allocator bitmap itself, it's not
 	 * needed anymore:
 	 */
 	page = virt_to_page(bdata->node_bootmem_map);
-	count = 0;
 	idx = (get_mapsize(bdata) + PAGE_SIZE-1) >> PAGE_SHIFT;
-	for (i = 0; i < idx; i++, page++) {
+	for (i = 0; i < idx; i++, page++)
 		__free_pages_bootmem(page, 0);
-		count++;
-	}
-	total += count;
+	count += i;
 	bdata->node_bootmem_map = NULL;
 
-	return total;
+	return count;
 }
 
 unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
