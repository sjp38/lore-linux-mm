Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 756096B0196
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:44:34 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id lj1so2492665pab.35
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:44:33 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 18/41] mm/cris: prepare for removing num_physpages and simplify mem_init()
Date: Sat,  6 Apr 2013 22:32:17 +0800
Message-Id: <1365258760-30821-19-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: linux-cris-kernel@axis.com
Cc: linux-kernel@vger.kernel.org
---
 arch/cris/mm/init.c |   33 ++-------------------------------
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
