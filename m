Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id A2F206B01A3
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:45:26 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v14so2234321pde.32
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:45:25 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 24/41] mm/m68k: prepare for removing num_physpages and simplify mem_init()
Date: Sat,  6 Apr 2013 22:32:23 +0800
Message-Id: <1365258760-30821-25-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@uclinux.org>, linux-m68k@lists.linux-m68k.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Ungerer <gerg@uclinux.org>
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-kernel@vger.kernel.org
---
 arch/m68k/mm/init.c |   31 ++-----------------------------
 1 file changed, 2 insertions(+), 29 deletions(-)

diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 2485a8c..0723141 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -149,33 +149,11 @@ void __init print_memmap(void)
 void __init mem_init(void)
 {
 	pg_data_t *pgdat;
-	int codepages = 0;
-	int datapages = 0;
-	int initpages = 0;
 	int i;
 
 	/* this will put all memory onto the freelists */
-	num_physpages = 0;
-	for_each_online_pgdat(pgdat) {
-		num_physpages += pgdat->node_present_pages;
-
+	for_each_online_pgdat(pgdat)
 		free_all_bootmem_node(pgdat);
-		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page = pgdat->node_mem_map + i;
-			char *addr = page_to_virt(page);
-
-			if (!PageReserved(page))
-				continue;
-			if (addr >= _text &&
-			    addr < _etext)
-				codepages++;
-			else if (addr >= __init_begin &&
-				 addr < __init_end)
-				initpages++;
-			else
-				datapages++;
-		}
-	}
 
 #if defined(CONFIG_MMU) && !defined(CONFIG_SUN3) && !defined(CONFIG_COLDFIRE)
 	/* insert pointer tables allocated so far into the tablelist */
@@ -190,12 +168,7 @@ void __init mem_init(void)
 		init_pointer_table((unsigned long)zero_pgtable);
 #endif
 
-	pr_info("Memory: %luk/%luk available (%dk kernel code, %dk data, %dk init)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       totalram_pages << (PAGE_SHIFT-10),
-	       codepages << (PAGE_SHIFT-10),
-	       datapages << (PAGE_SHIFT-10),
-	       initpages << (PAGE_SHIFT-10));
+	mem_init_print_info(NULL);
 	print_memmap();
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
