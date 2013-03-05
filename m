Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 74A746B000D
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:59:53 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so4545006pbc.2
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:59:52 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 10/33] mm/IA64: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:53 +0800
Message-Id: <1362495317-32682-11-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/mm/init.c |   23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 20bc967..d1fe4b4 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -154,25 +154,14 @@ ia64_init_addr_space (void)
 void
 free_initmem (void)
 {
-	unsigned long addr, eaddr;
-
-	addr = (unsigned long) ia64_imva(__init_begin);
-	eaddr = (unsigned long) ia64_imva(__init_end);
-	while (addr < eaddr) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		++totalram_pages;
-		addr += PAGE_SIZE;
-	}
-	printk(KERN_INFO "Freeing unused kernel memory: %ldkB freed\n",
-	       (__init_end - __init_begin) >> 10);
+	free_reserved_area((unsigned long)ia64_imva(__init_begin),
+			   (unsigned long)ia64_imva(__init_end),
+			   0, "unused kernel");
 }
 
 void __init
 free_initrd_mem (unsigned long start, unsigned long end)
 {
-	struct page *page;
 	/*
 	 * EFI uses 4KB pages while the kernel can use 4KB or bigger.
 	 * Thus EFI and the kernel may have different page sizes. It is
@@ -213,11 +202,7 @@ free_initrd_mem (unsigned long start, unsigned long end)
 	for (; start < end; start += PAGE_SIZE) {
 		if (!virt_addr_valid(start))
 			continue;
-		page = virt_to_page(start);
-		ClearPageReserved(page);
-		init_page_count(page);
-		free_page(start);
-		++totalram_pages;
+		free_reserved_page(virt_to_page(start));
 	}
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
