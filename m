Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6F76B6B00F8
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:54 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id um15so9169142pbc.25
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:53 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 29/41] mm/openrisc: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:47 +0800
Message-Id: <1369835879-23553-30-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux@lists.openrisc.net

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Jonas Bonn <jonas@southpole.se>
Cc: David Howells <dhowells@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux@lists.openrisc.net
Cc: linux-kernel@vger.kernel.org
---
 arch/openrisc/mm/init.c | 44 ++++----------------------------------------
 1 file changed, 4 insertions(+), 40 deletions(-)

diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index 16c1e13..7f94652 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -202,56 +202,20 @@ void __init paging_init(void)
 
 /* References to section boundaries */
 
-static int __init free_pages_init(void)
-{
-	int reservedpages, pfn;
-
-	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
-
-	reservedpages = 0;
-	for (pfn = 0; pfn < max_low_pfn; pfn++) {
-		/*
-		 * Only count reserved RAM pages
-		 */
-		if (PageReserved(mem_map + pfn))
-			reservedpages++;
-	}
-
-	return reservedpages;
-}
-
-static void __init set_max_mapnr_init(void)
-{
-	max_mapnr = num_physpages = max_low_pfn;
-}
-
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-
 	BUG_ON(!mem_map);
 
-	set_max_mapnr_init();
-
+	max_mapnr = max_low_pfn;
 	high_memory = (void *)__va(max_low_pfn * PAGE_SIZE);
 
 	/* clear the zero-page */
 	memset((void *)empty_zero_page, 0, PAGE_SIZE);
 
-	reservedpages = free_pages_init();
-
-	codesize = (unsigned long)&_etext - (unsigned long)&_stext;
-	datasize = (unsigned long)&_edata - (unsigned long)&_etext;
-	initsize = (unsigned long)&__init_end - (unsigned long)&__init_begin;
+	/* this will put all low memory onto the freelists */
+	free_all_bootmem();
 
-	printk(KERN_INFO
-	       "Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, %dk init, %ldk highmem)\n",
-	       (unsigned long)nr_free_pages() << (PAGE_SHIFT - 10),
-	       max_mapnr << (PAGE_SHIFT - 10), codesize >> 10,
-	       reservedpages << (PAGE_SHIFT - 10), datasize >> 10,
-	       initsize >> 10, (unsigned long)(0 << (PAGE_SHIFT - 10))
-	    );
+	mem_init_print_info(NULL);
 
 	printk("mem_init_done ...........................................\n");
 	mem_init_done = 1;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
