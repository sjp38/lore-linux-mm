Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id BA79F6B006C
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:38 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id un15so2677427pbc.10
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:37 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 08/10] mm/SPARC: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:08 +0800
Message-Id: <1362902470-25787-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, sparclinux@vger.kernel.org

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: sparclinux@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sparc/mm/init_32.c |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 13d6fee..6a7eb68 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -282,14 +282,8 @@ static void map_high_region(unsigned long start_pfn, unsigned long end_pfn)
 	printk("mapping high region %08lx - %08lx\n", start_pfn, end_pfn);
 #endif
 
-	for (tmp = start_pfn; tmp < end_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
-	}
+	for (tmp = start_pfn; tmp < end_pfn; tmp++)
+		free_higmem_page(pfn_to_page(tmp));
 }
 
 void __init mem_init(void)
@@ -347,8 +341,6 @@ void __init mem_init(void)
 		map_high_region(start_pfn, end_pfn);
 	}
 	
-	totalram_pages += totalhigh_pages;
-
 	codepages = (((unsigned long) &_etext) - ((unsigned long)&_start));
 	codepages = PAGE_ALIGN(codepages) >> PAGE_SHIFT;
 	datapages = (((unsigned long) &_edata) - ((unsigned long)&_etext));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
