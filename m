Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 8D2E26B00FE
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:00:05 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id um15so9241761pbc.39
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:00:04 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 32/41] mm/s390: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:50 +0800
Message-Id: <1369835879-23553-33-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/s390/mm/init.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index a2aafe1..ce36ea8 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -135,9 +135,7 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize;
-
-        max_mapnr = num_physpages = max_low_pfn;
+        max_mapnr = max_low_pfn;
         high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 	/* Setup guest page hinting */
@@ -147,18 +145,7 @@ void __init mem_init(void)
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
