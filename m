Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7A1A76B0062
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:05 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un1so2664200pbc.26
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:04 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 04/10] mm/metag: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:04 +0800
Message-Id: <1362902470-25787-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/metag/mm/init.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index c6784fb..d05b845 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -380,14 +380,8 @@ void __init mem_init(void)
 
 #ifdef CONFIG_HIGHMEM
 	unsigned long tmp;
-	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
-	}
-	totalram_pages += totalhigh_pages;
+	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++)
+		free_highmem_page(pfn_to_page(tmp));
 	num_physpages += totalhigh_pages;
 #endif /* CONFIG_HIGHMEM */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
