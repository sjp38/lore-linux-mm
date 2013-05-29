Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 03DF46B00CD
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:58:49 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so216988pad.16
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:58:49 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 11/41] mm/alpha: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:29 +0800
Message-Id: <1369835879-23553-12-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: David Howells <dhowells@redhat.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/alpha/mm/init.c | 32 ++------------------------------
 arch/alpha/mm/numa.c | 34 ++--------------------------------
 2 files changed, 4 insertions(+), 62 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index eee47a4..af91010 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -277,42 +277,14 @@ srm_paging_stop (void)
 #endif
 
 #ifndef CONFIG_DISCONTIGMEM
-static void __init
-printk_memory_info(void)
-{
-	unsigned long codesize, reservedpages, datasize, initsize, tmp;
-	extern int page_is_ram(unsigned long) __init;
-
-	/* printk all informations */
-	reservedpages = 0;
-	for (tmp = 0; tmp < max_low_pfn; tmp++)
-		/*
-		 * Only count reserved RAM pages
-		 */
-		if (page_is_ram(tmp) && PageReserved(mem_map+tmp))
-			reservedpages++;
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_data;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk("Memory: %luk/%luk available (%luk kernel code, %luk reserved, %luk data, %luk init)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       max_mapnr << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10);
-}
-
 void __init
 mem_init(void)
 {
-	max_mapnr = num_physpages = max_low_pfn;
+	max_mapnr = max_low_pfn;
 	free_all_bootmem();
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
-	printk_memory_info();
+	mem_init_print_info(NULL);
 }
 #endif /* CONFIG_DISCONTIGMEM */
 
diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
index 857452c..0894b3a8 100644
--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -129,8 +129,6 @@ setup_memory_node(int nid, void *kernel_end)
 	if (node_max_pfn > max_low_pfn)
 		max_pfn = max_low_pfn = node_max_pfn;
 
-	num_physpages += node_max_pfn - node_min_pfn;
-
 #if 0 /* we'll try this one again in a little while */
 	/* Cute trick to make sure our local node data is on local memory */
 	node_data[nid] = (pg_data_t *)(__va(node_min_pfn << PAGE_SHIFT));
@@ -324,37 +322,9 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize, pfn;
-	extern int page_is_ram(unsigned long) __init;
-	unsigned long nid, i;
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
-
-	reservedpages = 0;
-	for_each_online_node(nid) {
-		/*
-		 * This will free up the bootmem, ie, slot 0 memory
-		 */
-		free_all_bootmem_node(NODE_DATA(nid));
-
-		pfn = NODE_DATA(nid)->node_start_pfn;
-		for (i = 0; i < node_spanned_pages(nid); i++, pfn++)
-			if (page_is_ram(pfn) &&
-			    PageReserved(nid_page_nr(nid, i)))
-				reservedpages++;
-	}
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_data;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk("Memory: %luk/%luk available (%luk kernel code, %luk reserved, "
-	       "%luk data, %luk init)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       num_physpages << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10);
+	free_all_bootmem();
+	mem_init_print_info(NULL);
 #if 0
 	mem_stress();
 #endif
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
