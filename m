Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id F245A6B010E
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:56:22 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bg2so1421267pad.25
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:56:22 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 28/41] mm/mn10300: prepare for removing num_physpages and simplify mem_init()
Date: Wed,  8 May 2013 23:51:25 +0800
Message-Id: <1368028298-7401-29-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: linux-am33-list@redhat.com
Cc: linux-kernel@vger.kernel.org
---
 arch/mn10300/mm/init.c |   26 ++------------------------
 1 file changed, 2 insertions(+), 24 deletions(-)

diff --git a/arch/mn10300/mm/init.c b/arch/mn10300/mm/init.c
index d7312aa..f43d993 100644
--- a/arch/mn10300/mm/init.c
+++ b/arch/mn10300/mm/init.c
@@ -99,15 +99,12 @@ void __init paging_init(void)
  */
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-	int tmp;
-
 	BUG_ON(!mem_map);
 
 #define START_PFN	(contig_page_data.bdata->node_min_pfn)
 #define MAX_LOW_PFN	(contig_page_data.bdata->node_low_pfn)
 
-	max_mapnr = num_physpages = MAX_LOW_PFN - START_PFN;
+	max_mapnr = MAX_LOW_PFN - START_PFN;
 	high_memory = (void *) __va(MAX_LOW_PFN * PAGE_SIZE);
 
 	/* clear the zero-page */
@@ -116,26 +113,7 @@ void __init mem_init(void)
 	/* this will put all low memory onto the freelists */
 	free_all_bootmem();
 
-	reservedpages = 0;
-	for (tmp = 0; tmp < num_physpages; tmp++)
-		if (PageReserved(&mem_map[tmp]))
-			reservedpages++;
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_stext;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk(KERN_INFO
-	       "Memory: %luk/%luk available"
-	       " (%dk kernel code, %dk reserved, %dk data, %dk init,"
-	       " %ldk highmem)\n",
-	       nr_free_pages() << (PAGE_SHIFT - 10),
-	       max_mapnr << (PAGE_SHIFT - 10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT - 10),
-	       datasize >> 10,
-	       initsize >> 10,
-	       totalhigh_pages << (PAGE_SHIFT - 10));
+	mem_init_print_info(NULL);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
