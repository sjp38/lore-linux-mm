Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 84DDB6B0120
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:01:26 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so1051218pab.10
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 09:01:26 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 26/39] mm/openrisc: prepare for removing num_physpages and simplify mem_init()
Date: Tue, 26 Mar 2013 23:54:45 +0800
Message-Id: <1364313298-17336-27-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Jonas Bonn <jonas@southpole.se>, Arnd Bergmann <arnd@arndb.de>, linux@lists.openrisc.net

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: David Howells <dhowells@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux@lists.openrisc.net
Cc: linux-kernel@vger.kernel.org
---
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
---
 arch/openrisc/mm/init.c |   44 ++++----------------------------------------
 1 file changed, 4 insertions(+), 40 deletions(-)

diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index 71d6b40..f3c8f47 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -191,56 +191,20 @@ void __init paging_init(void)
 
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
