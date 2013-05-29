Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1EFA26B00E3
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:15 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so216088pad.2
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:14 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 18/41] mm/cris: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:36 +0800
Message-Id: <1369835879-23553-19-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, linux-cris-kernel@axis.com

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Mikael Starvik <starvik@axis.com>
Cc: linux-cris-kernel@axis.com
Cc: linux-kernel@vger.kernel.org
---
 arch/cris/mm/init.c | 33 ++-------------------------------
 1 file changed, 2 insertions(+), 31 deletions(-)

diff --git a/arch/cris/mm/init.c b/arch/cris/mm/init.c
index 52b8b56..c81af5b 100644
--- a/arch/cris/mm/init.c
+++ b/arch/cris/mm/init.c
@@ -19,9 +19,6 @@ unsigned long empty_zero_page;
 void __init
 mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-	unsigned long tmp;
-
 	BUG_ON(!mem_map);
 
 	/* max/min_low_pfn was set by setup.c
@@ -29,35 +26,9 @@ mem_init(void)
 	 *
 	 * high_memory was also set in setup.c
 	 */
-
-	max_mapnr = num_physpages = max_low_pfn - min_low_pfn;
- 
-	/* this will put all memory onto the freelists */
+	max_mapnr = max_low_pfn - min_low_pfn;
         free_all_bootmem();
-
-	reservedpages = 0;
-	for (tmp = 0; tmp < max_mapnr; tmp++) {
-		/*
-                 * Only count reserved RAM pages
-                 */
-		if (PageReserved(mem_map + tmp))
-			reservedpages++;
-	}
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_stext;
-        datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-        initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-	
-        printk(KERN_INFO
-               "Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, "
-	       "%dk init)\n" ,
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       max_mapnr << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10
-               );
+	mem_init_print_info(NULL);
 }
 
 /* free the pages occupied by initialization code */
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
