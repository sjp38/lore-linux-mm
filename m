Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2A8856B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:58:31 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so4516639pbc.22
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:58:30 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 03/33] mm/ARM: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:46 +0800
Message-Id: <1362495317-32682-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/mm/init.c   |   48 ++++++++++++++++--------------------------------
 arch/arm64/mm/init.c |   26 ++------------------------
 2 files changed, 18 insertions(+), 56 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index ad722f1..40a5bc2 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -424,24 +424,6 @@ void __init bootmem_init(void)
 	max_pfn = max_high - PHYS_PFN_OFFSET;
 }
 
-static inline int free_area(unsigned long pfn, unsigned long end, char *s)
-{
-	unsigned int pages = 0, size = (end - pfn) << (PAGE_SHIFT - 10);
-
-	for (; pfn < end; pfn++) {
-		struct page *page = pfn_to_page(pfn);
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		pages++;
-	}
-
-	if (size && s)
-		printk(KERN_INFO "Freeing %s memory: %dK\n", s, size);
-
-	return pages;
-}
-
 /*
  * Poison init memory with an undefined instruction (ARM) or a branch to an
  * undefined instruction (Thumb).
@@ -534,6 +516,16 @@ static void __init free_unused_memmap(struct meminfo *mi)
 #endif
 }
 
+#ifdef CONFIG_HIGHMEM
+static inline void free_area_high(unsigned long pfn, unsigned long end)
+{
+	for (; pfn < end; pfn++) {
+		__free_reserved_page(pfn_to_page(pfn));
+		totalhigh_pages++;
+	}
+}
+#endif
+
 static void __init free_highpages(void)
 {
 #ifdef CONFIG_HIGHMEM
@@ -569,8 +561,7 @@ static void __init free_highpages(void)
 			if (res_end > end)
 				res_end = end;
 			if (res_start != start)
-				totalhigh_pages += free_area(start, res_start,
-							     NULL);
+				free_area_high(start, res_start);
 			start = res_end;
 			if (start == end)
 				break;
@@ -578,7 +569,7 @@ static void __init free_highpages(void)
 
 		/* And now free anything which remains */
 		if (start < end)
-			totalhigh_pages += free_area(start, end, NULL);
+			free_area_high(start, end);
 	}
 	totalram_pages += totalhigh_pages;
 #endif
@@ -609,8 +600,7 @@ void __init mem_init(void)
 
 #ifdef CONFIG_SA1111
 	/* now that our DMA memory is actually so designated, we can free it */
-	totalram_pages += free_area(PHYS_PFN_OFFSET,
-				    __phys_to_pfn(__pa(swapper_pg_dir)), NULL);
+	free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, 0, NULL);
 #endif
 
 	free_highpages();
@@ -738,16 +728,12 @@ void free_initmem(void)
 	extern char __tcm_start, __tcm_end;
 
 	poison_init_mem(&__tcm_start, &__tcm_end - &__tcm_start);
-	totalram_pages += free_area(__phys_to_pfn(__pa(&__tcm_start)),
-				    __phys_to_pfn(__pa(&__tcm_end)),
-				    "TCM link");
+	free_reserved_area(&__tcm_start, &__tcm_end, 0, "TCM link");
 #endif
 
 	poison_init_mem(__init_begin, __init_end - __init_begin);
 	if (!machine_is_integrator() && !machine_is_cintegrator())
-		totalram_pages += free_area(__phys_to_pfn(__pa(__init_begin)),
-					    __phys_to_pfn(__pa(__init_end)),
-					    "init");
+		free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -758,9 +744,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		totalram_pages += free_area(__phys_to_pfn(__pa(start)),
-					    __phys_to_pfn(__pa(end)),
-					    "initrd");
+		free_reserved_area(start, end, 0, "initrd");
 	}
 }
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 800aac3..f497ca7 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -197,24 +197,6 @@ void __init bootmem_init(void)
 	max_pfn = max_low_pfn = max;
 }
 
-static inline int free_area(unsigned long pfn, unsigned long end, char *s)
-{
-	unsigned int pages = 0, size = (end - pfn) << (PAGE_SHIFT - 10);
-
-	for (; pfn < end; pfn++) {
-		struct page *page = pfn_to_page(pfn);
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		pages++;
-	}
-
-	if (size && s)
-		pr_info("Freeing %s memory: %dK\n", s, size);
-
-	return pages;
-}
-
 /*
  * Poison init memory with an undefined instruction (0x0).
  */
@@ -405,9 +387,7 @@ void __init mem_init(void)
 void free_initmem(void)
 {
 	poison_init_mem(__init_begin, __init_end - __init_begin);
-	totalram_pages += free_area(__phys_to_pfn(__pa(__init_begin)),
-				    __phys_to_pfn(__pa(__init_end)),
-				    "init");
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -418,9 +398,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		totalram_pages += free_area(__phys_to_pfn(__pa(start)),
-					    __phys_to_pfn(__pa(end)),
-					    "initrd");
+		free_reserved_area(start, end, 0, "initrd");
 	}
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
