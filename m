Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 4534D6B003B
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:04:04 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md12so5127742pbc.2
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:04:03 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 04/12] mm/tile: use common help functions to free reserved pages
Date: Sun, 17 Mar 2013 01:03:25 +0800
Message-Id: <1363453413-8139-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
References: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/tile/mm/init.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 2749515..ccfeb3f 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -720,7 +720,7 @@ static void __init init_free_pfn_range(unsigned long start, unsigned long end)
 		}
 		init_page_count(page);
 		__free_pages(page, order);
-		totalram_pages += count;
+		adjust_managed_page_count(page, count);
 
 		page += count;
 		pfn += count;
@@ -1024,16 +1024,13 @@ static void free_init_pages(char *what, unsigned long begin, unsigned long end)
 			pte_clear(&init_mm, addr, ptep);
 			continue;
 		}
-		__ClearPageReserved(page);
-		init_page_count(page);
 		if (pte_huge(*ptep))
 			BUG_ON(!kdata_huge);
 		else
 			set_pte_at(&init_mm, addr, ptep,
 				   pfn_pte(pfn, PAGE_KERNEL));
 		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		free_page(addr);
-		totalram_pages++;
+		free_reserved_page(page);
 	}
 	pr_info("Freeing %s: %ldk freed\n", what, (end - begin) >> 10);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
