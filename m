Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D03216B0037
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:30:44 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so2625361pbc.26
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:30:44 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 07/29] mm/cris: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:26:50 +0800
Message-Id: <1362896833-21104-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>

Use common help functions to free reserved pages.
Also include <asm/sections.h> to avoid local declaration.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mikael Starvik <starvik@axis.com>
---
 arch/cris/mm/init.c |   16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/arch/cris/mm/init.c b/arch/cris/mm/init.c
index d72ab58..9ac8094 100644
--- a/arch/cris/mm/init.c
+++ b/arch/cris/mm/init.c
@@ -12,12 +12,10 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
 #include <asm/tlb.h>
+#include <asm/sections.h>
 
 unsigned long empty_zero_page;
 
-extern char _stext, _edata, _etext; /* From linkerscript */
-extern char __init_begin, __init_end;
-
 void __init
 mem_init(void)
 {
@@ -67,15 +65,5 @@ mem_init(void)
 void 
 free_initmem(void)
 {
-        unsigned long addr;
-
-        addr = (unsigned long)(&__init_begin);
-        for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
-                ClearPageReserved(virt_to_page(addr));
-                init_page_count(virt_to_page(addr));
-                free_page(addr);
-                totalram_pages++;
-        }
-        printk (KERN_INFO "Freeing unused kernel memory: %luk freed\n",
-		(unsigned long)((&__init_end - &__init_begin) >> 10));
+	free_initmem_default(0);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
