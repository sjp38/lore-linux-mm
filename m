Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DC2E06B00BD
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:33:23 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id bh4so316930pad.40
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:33:23 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 29/39] mm/s390: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:15 +0800
Message-Id: <1364109934-7851-50-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/s390/mm/init.c |   17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 4a72888..07e6df6 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -125,9 +125,7 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize;
-
-        max_mapnr = num_physpages = max_low_pfn;
+        max_mapnr = max_low_pfn;
         high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 	/* Setup guest page hinting */
@@ -137,18 +135,7 @@ void __init mem_init(void)
 	free_all_bootmem();
 	setup_zero_pages();	/* Setup zeroed pages. */
 
-	reservedpages = 0;
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-        printk("Memory: %luk/%luk available (%ldk kernel code, %ldk reserved, %ldk data, %ldk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-                max_mapnr << (PAGE_SHIFT-10),
-                codesize >> 10,
-                reservedpages << (PAGE_SHIFT-10),
-                datasize >>10,
-                initsize >> 10);
+	mem_init_print_info(NULL);
 	printk("Write protected kernel read-only data: %#lx - %#lx\n",
 	       (unsigned long)&_stext,
 	       PFN_ALIGN((unsigned long)&_eshared) - 1);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
