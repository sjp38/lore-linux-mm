Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 31AB96B0037
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:03:10 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id xb4so4553506pbc.15
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:03:09 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 28/33] mm: introduce free_highmem_page() helper to free highmem pages inti buddy system
Date: Tue,  5 Mar 2013 22:55:11 +0800
Message-Id: <1362495317-32682-29-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Introduce helper function free_highmem_page(), which will be used by
architectures with HIGHMEM enabled to free highmem pages into the buddy
system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/arm/mm/init.c        |    6 ++----
 arch/microblaze/mm/init.c |    5 +----
 arch/mips/mm/init.c       |    5 +----
 arch/powerpc/mm/mem.c     |    5 +----
 arch/sparc/mm/init_32.c   |   10 ++--------
 arch/um/kernel/mem.c      |   15 +++------------
 arch/x86/mm/init_32.c     |   10 +---------
 include/linux/mm.h        |    3 +++
 mm/page_alloc.c           |    8 ++++++++
 9 files changed, 22 insertions(+), 45 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 40a5bc2..400a383 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -519,10 +519,8 @@ static void __init free_unused_memmap(struct meminfo *mi)
 #ifdef CONFIG_HIGHMEM
 static inline void free_area_high(unsigned long pfn, unsigned long end)
 {
-	for (; pfn < end; pfn++) {
-		__free_reserved_page(pfn_to_page(pfn));
-		totalhigh_pages++;
-	}
+	for (; pfn < end; pfn++)
+		free_highmem_page(pfn_to_page(pfn));
 }
 #endif
 
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 9be5302..d0fe2a8 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -82,10 +82,7 @@ static unsigned long highmem_setup(void)
 		/* FIXME not sure about */
 		if (memblock_is_reserved(pfn << PAGE_SHIFT))
 			continue;
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 		reservedpages++;
 	}
 	totalram_pages += totalhigh_pages;
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 60f7c61..3105494 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -393,10 +393,7 @@ void __init mem_init(void)
 			SetPageReserved(page);
 			continue;
 		}
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 	}
 	totalram_pages += totalhigh_pages;
 	num_physpages += totalhigh_pages;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c756713..79eb16b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -352,10 +352,7 @@ void __init mem_init(void)
 			struct page *page = pfn_to_page(pfn);
 			if (memblock_is_reserved(paddr))
 				continue;
-			ClearPageReserved(page);
-			init_page_count(page);
-			__free_page(page);
-			totalhigh_pages++;
+			free_higmem_page(page);
 			reservedpages--;
 		}
 		totalram_pages += totalhigh_pages;
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 2a7b6eb..cd4c78c 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -282,14 +282,8 @@ static void map_high_region(unsigned long start_pfn, unsigned long end_pfn)
 	printk("mapping high region %08lx - %08lx\n", start_pfn, end_pfn);
 #endif
 
-	for (tmp = start_pfn; tmp < end_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
-	}
+	for (tmp = start_pfn; tmp < end_pfn; tmp++)
+		free_higmem_page(pfn_to_page(tmp));
 }
 
 void __init mem_init(void)
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index d5ac802..fea5c9d 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -42,17 +42,12 @@ static unsigned long brk_end;
 static void setup_highmem(unsigned long highmem_start,
 			  unsigned long highmem_len)
 {
-	struct page *page;
 	unsigned long highmem_pfn;
 	int i;
 
 	highmem_pfn = __pa(highmem_start) >> PAGE_SHIFT;
-	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++) {
-		page = &mem_map[highmem_pfn + i];
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-	}
+	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++)
+		free_highmem_page(&mem_map[highmem_pfn + i]);
 }
 #endif
 
@@ -73,7 +68,7 @@ void __init mem_init(void)
 	totalram_pages = free_all_bootmem();
 	max_low_pfn = totalram_pages;
 #ifdef CONFIG_HIGHMEM
-	totalhigh_pages = highmem >> PAGE_SHIFT;
+	setup_highmem(end_iomem, highmem);
 	totalram_pages += totalhigh_pages;
 #endif
 	num_physpages = totalram_pages;
@@ -81,10 +76,6 @@ void __init mem_init(void)
 	printk(KERN_INFO "Memory: %luk available\n",
 	       nr_free_pages() << (PAGE_SHIFT-10));
 	kmalloc_ok = 1;
-
-#ifdef CONFIG_HIGHMEM
-	setup_highmem(end_iomem, highmem);
-#endif
 }
 
 /*
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 2d19001..3ac7e31 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -427,14 +427,6 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
 	pkmap_page_table = pte;
 }
 
-static void __init add_one_highpage_init(struct page *page)
-{
-	ClearPageReserved(page);
-	init_page_count(page);
-	__free_page(page);
-	totalhigh_pages++;
-}
-
 void __init add_highpages_with_active_regions(int nid,
 			 unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -448,7 +440,7 @@ void __init add_highpages_with_active_regions(int nid,
 					      start_pfn, end_pfn);
 		for ( ; pfn < e_pfn; pfn++)
 			if (pfn_valid(pfn))
-				add_one_highpage_init(pfn_to_page(pfn));
+				free_highmem_page(pfn_to_page(pfn));
 	}
 }
 #else
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 881461c..4d1509b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1296,6 +1296,9 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 extern void free_initmem(void);
 
 /* Help functions to deal with reserved/managed pages. */
+#ifdef	CONFIG_HIGHMEM
+extern void free_highmem_page(struct page *page);
+#endif
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
 					int poison, char *s);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fadb09..ad2f619 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5133,6 +5133,14 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	return pages;
 }
 
+#ifdef	CONFIG_HIGHMEM
+void free_highmem_page(struct page *page)
+{
+	__free_reserved_page(page);
+	totalhigh_pages++;
+}
+#endif
+
 /**
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
