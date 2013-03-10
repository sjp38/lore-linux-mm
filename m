Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 20FBA6B008A
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:33:16 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so2632431pbc.12
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:33:15 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 25/29] mm/x86: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:08 +0800
Message-Id: <1362896833-21104-26-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/mm/init.c    |    5 +----
 arch/x86/mm/init_64.c |    5 ++---
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 4903a03..4a705e6 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -516,11 +516,8 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	printk(KERN_INFO "Freeing %s: %luk freed\n", what, (end - begin) >> 10);
 
 	for (; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
 		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		free_page(addr);
-		totalram_pages++;
+		free_reserved_page(virt_to_page(addr));
 	}
 #endif
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..2ef81f1 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1067,10 +1067,9 @@ void __init mem_init(void)
 
 	/* clear_bss() already clear the empty_zero_page */
 
-	reservedpages = 0;
-
-	/* this will put all low memory onto the freelists */
 	register_page_bootmem_info();
+
+	/* this will put all memory onto the freelists */
 	totalram_pages = free_all_bootmem();
 
 	absent_pages = absent_pages_in_range(0, max_pfn);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
