Message-Id: <20080530194739.835841447@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:33 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 13/14] bootmem: revisit alloc_bootmem_section
Content-Disposition: inline; filename=bootmem-revisit-alloc_bootmem_section.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Since alloc_bootmem_core does no goal-fallback anymore and just
returns NULL if the allocation fails, we might now use it in
alloc_bootmem_section without all the fixup code for a misplaced
allocation.

Also, the limit can be the first PFN of the next section as the
semantics is that the limit is _above_ the allocated region, not
within.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Yasunori Goto <y-goto@jp.fujitsu.com>
---

 mm/bootmem.c |   27 ++++++---------------------
 1 file changed, 6 insertions(+), 21 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -662,29 +662,14 @@ void * __init __alloc_bootmem_low_node(p
 void * __init alloc_bootmem_section(unsigned long size,
 				    unsigned long section_nr)
 {
-	void *ptr;
-	unsigned long limit, goal, start_nr, end_nr, pfn;
-	struct pglist_data *pgdat;
+	bootmem_data_t *bdata;
+	unsigned long pfn, goal, limit;
 
 	pfn = section_nr_to_pfn(section_nr);
-	goal = PFN_PHYS(pfn);
-	limit = PFN_PHYS(section_nr_to_pfn(section_nr + 1)) - 1;
-	pgdat = NODE_DATA(early_pfn_to_nid(pfn));
-	ptr = alloc_bootmem_core(pgdat->bdata, size, SMP_CACHE_BYTES, goal,
-				limit);
+	goal = pfn << PAGE_SHIFT;
+	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
+	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
 
-	if (!ptr)
-		return NULL;
-
-	start_nr = pfn_to_section_nr(PFN_DOWN(__pa(ptr)));
-	end_nr = pfn_to_section_nr(PFN_DOWN(__pa(ptr) + size));
-	if (start_nr != section_nr || end_nr != section_nr) {
-		printk(KERN_WARNING "alloc_bootmem failed on section %ld.\n",
-		       section_nr);
-		free_bootmem_node(pgdat, __pa(ptr), size);
-		ptr = NULL;
-	}
-
-	return ptr;
+	return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, goal, limit);
 }
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
