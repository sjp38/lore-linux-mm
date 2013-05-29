Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2B79F6B00DC
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:04 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so217232pad.16
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:03 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 15/41] mm/AVR32: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:33 +0800
Message-Id: <1369835879-23553-16-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/avr32/mm/init.c | 29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index af6890f..0fc04b9 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -100,26 +100,16 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-	int nid, i;
+	pg_data_t *pgdat;
 
-	reservedpages = 0;
 	high_memory = NULL;
 
 	/* this will put all low memory onto the freelists */
-	for_each_online_node(nid) {
-		pg_data_t *pgdat = NODE_DATA(nid);
-		unsigned long node_pages = 0;
+	for_each_online_pgdat(pgdat) {
 		void *node_high_memory;
 
-		num_physpages += pgdat->node_present_pages;
-
 		if (pgdat->node_spanned_pages != 0)
-			node_pages = free_all_bootmem_node(pgdat);
-
-		for (i = 0; i < node_pages; i++)
-			if (PageReserved(pgdat->node_mem_map + i))
-				reservedpages++;
+			free_all_bootmem_node(pgdat);
 
 		node_high_memory = (void *)((pgdat->node_start_pfn
 					     + pgdat->node_spanned_pages)
@@ -130,18 +120,7 @@ void __init mem_init(void)
 
 	max_mapnr = MAP_NR(high_memory);
 
-	codesize = (unsigned long)_etext - (unsigned long)_text;
-	datasize = (unsigned long)_edata - (unsigned long)_data;
-	initsize = (unsigned long)__init_end - (unsigned long)__init_begin;
-
-	printk ("Memory: %luk/%luk available (%dk kernel code, "
-		"%dk reserved, %dk data, %dk init)\n",
-		nr_free_pages() << (PAGE_SHIFT - 10),
-		totalram_pages << (PAGE_SHIFT - 10),
-		codesize >> 10,
-		reservedpages << (PAGE_SHIFT - 10),
-		datasize >> 10,
-		initsize >> 10);
+	mem_init_print_info(NULL);
 }
 
 void free_initmem(void)
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
