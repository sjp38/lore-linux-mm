Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 863006B0127
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:45:49 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so9257746pbb.38
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:45:48 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 10/13] mm/SH: prepare for killing free_all_bootmem_node()
Date: Wed, 29 May 2013 22:44:49 +0800
Message-Id: <1369838692-26860-11-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
References: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>, Tang Chen <tangchen@cn.fujitsu.com>, linux-sh@vger.kernel.org

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-sh@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sh/mm/init.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index c9a517c..33890fd 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -412,19 +412,11 @@ void __init mem_init(void)
 	iommu_init();
 
 	high_memory = NULL;
+	for_each_online_pgdat(pgdat)
+		high_memory = max_t(void *, high_memory,
+				    __va(pgdat_end_pfn(pgdat) << PAGE_SHIFT));
 
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
