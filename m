From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/8] mips: mem_map/max_mapnr -- definition is specific to FLATMEM
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:16 +0100
Message-Id: <1207824076.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The max_mapnr variable is only used FLATMEM memory model, use the
appropriate defines.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/mips/mm/init.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index c7aed13..68c90b5 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -389,19 +389,22 @@ static struct kcore_list kcore_mem, kcore_vmalloc;
 static struct kcore_list kcore_kseg0;
 #endif
 
+#if defined(CONFIG_HIGHMEM) && defined(CONFIG_DISCONTIGMEM)
+#error "CONFIG_HIGHMEM and CONFIG_DISCONTIGMEM dont work together yet"
+#endif
+
 void __init mem_init(void)
 {
 	unsigned long codesize, reservedpages, datasize, initsize;
 	unsigned long tmp, ram;
 
+#ifdef CONFIG_FLATMEM
 #ifdef CONFIG_HIGHMEM
-#ifdef CONFIG_DISCONTIGMEM
-#error "CONFIG_HIGHMEM and CONFIG_DISCONTIGMEM dont work together yet"
-#endif
 	max_mapnr = highend_pfn;
 #else
 	max_mapnr = max_low_pfn;
 #endif
+#endif
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 
 	totalram_pages += free_all_bootmem();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
