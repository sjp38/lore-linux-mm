Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 148C96B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 14:39:17 -0400 (EDT)
Message-ID: <4DC6E342.3030906@kernel.org>
Date: Sun, 08 May 2011 11:38:58 -0700
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: [PATCH] memblock/nobootmem: remove code for alloc_bootmem_node_high()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Olaf Hering <olaf@aepfle.de>, Tejun Heo <tj@kernel.org>, Lucas De Marchi <lucas.demarchi@profusion.mobi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


bootmem wrapper with memblock support top-down now, So do not need this trick now.

Signed-off-by: Yinghai LU <yinghai@kernel.org>

---
 mm/nobootmem.c |   23 -----------------------
 1 file changed, 23 deletions(-)

Index: linux-2.6/mm/nobootmem.c
===================================================================
--- linux-2.6.orig/mm/nobootmem.c
+++ linux-2.6/mm/nobootmem.c
@@ -307,30 +307,7 @@ void * __init __alloc_bootmem_node(pg_da
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
-#ifdef MAX_DMA32_PFN
-	unsigned long end_pfn;
-
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
-	/* update goal according ...MAX_DMA32_PFN */
-	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
-
-	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
-	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
-		void *ptr;
-		unsigned long new_goal;
-
-		new_goal = MAX_DMA32_PFN << PAGE_SHIFT;
-		ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
-						 new_goal, -1ULL);
-		if (ptr)
-			return ptr;
-	}
-#endif
-
 	return __alloc_bootmem_node(pgdat, size, align, goal);
-
 }
 
 #ifdef CONFIG_SPARSEMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
