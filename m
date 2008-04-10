From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 6/8] powerpc: mem_map/max_mapnr -- definition is specific to FLATMEM
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:19 +0100
Message-Id: <1207824079.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The max_mapnr variable is only used FLATMEM memory model, use the
appropriate defines.  Note that HIGHMEM is only valid on PPC32, and that
only supports FLATMEM.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/powerpc/mm/mem.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index fcbae37..09d275e 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -319,9 +319,11 @@ void __init mem_init(void)
 		}
 	}
 #else
-	max_mapnr = max_pfn;
 	totalram_pages += free_all_bootmem();
 #endif
+#ifdef CONFIG_FLATMEM
+	max_mapnr = max_pfn;
+#endif
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
 			if (!pfn_valid(pgdat->node_start_pfn + i))
@@ -337,7 +339,7 @@ void __init mem_init(void)
 	initsize = (unsigned long)&__init_end - (unsigned long)&__init_begin;
 	bsssize = (unsigned long)&__bss_stop - (unsigned long)&__bss_start;
 
-#ifdef CONFIG_HIGHMEM
+#if defined(CONFIG_FLATMEM) && defined(CONFIG_HIGHMEM)
 	{
 		unsigned long pfn, highmem_mapnr;
 
@@ -356,7 +358,7 @@ void __init mem_init(void)
 		printk(KERN_DEBUG "High memory: %luk\n",
 		       totalhigh_pages << (PAGE_SHIFT-10));
 	}
-#endif /* CONFIG_HIGHMEM */
+#endif /* CONFIG_FLATMEM/CONFIG_HIGHMEM */
 
 	printk(KERN_INFO "Memory: %luk/%luk available (%luk kernel code, "
 	       "%luk reserved, %luk data, %luk bss, %luk init)\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
