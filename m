Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id EEA736B0037
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:46:12 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id e20so121635dak.33
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:12 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v7, part3 05/16] mm/tile: use common help functions to free reserved pages
Date: Fri, 17 May 2013 23:45:07 +0800
Message-Id: <1368805518-2634-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/tile/mm/init.c | 7 ++-----
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
