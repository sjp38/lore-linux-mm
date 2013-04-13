Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E61826B003C
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:41:58 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id 10so1875856pdc.14
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:41:58 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 10/19] mm/SH: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:30 +0800
Message-Id: <1365867399-21323-11-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>, Tang Chen <tangchen@cn.fujitsu.com>, linux-sh@vger.kernel.org

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-sh@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sh/mm/init.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 3826596..485c858 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -412,19 +412,11 @@ void __init mem_init(void)
 	iommu_init();
 
 	high_memory = NULL;
+	for_each_online_pgdat(pgdat)
+		high_memory = max_t(void *, high_memory,
+			(void *)__va(pgdat_end_pfn(pgdat) << PAGE_SHIFT));
 
-	for_each_online_pgdat(pgdat) {
-		void *node_high_memory;
-
-		if (pgdat->node_spanned_pages)
-			free_all_bootmem_node(pgdat);
-
-		node_high_memory = (void *)__va((pgdat->node_start_pfn +
-						 pgdat->node_spanned_pages) <<
-						 PAGE_SHIFT);
-		if (node_high_memory > high_memory)
-			high_memory = node_high_memory;
-	}
+	free_all_bootmem();
 
 	/* Set this up early, so we can take care of the zero page */
 	cpu_cache_init();
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
