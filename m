Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 97AAE6B0039
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:41:17 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id jt11so1877206pbb.37
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:41:16 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 06/19] mm/metag: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:26 +0800
Message-Id: <1365867399-21323-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/metag/mm/init.c |   14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index e00586f..096d022 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -376,31 +376,21 @@ void __init paging_init(unsigned long mem_end)
 
 void __init mem_init(void)
 {
-	int nid;
-
 #ifdef CONFIG_HIGHMEM
 	unsigned long tmp;
 
 	/*
 	 * Explicitly reset zone->managed_pages because highmem pages are
-	 * freed before calling free_all_bootmem_node();
+	 * freed before calling free_all_bootmem();
 	 */
 	reset_all_zones_managed_pages();
 	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++)
 		free_highmem_page(pfn_to_page(tmp));
 #endif /* CONFIG_HIGHMEM */
 
-	for_each_online_node(nid) {
-		pg_data_t *pgdat = NODE_DATA(nid);
-
-		if (pgdat->node_spanned_pages)
-			free_all_bootmem_node(pgdat);
-	}
-
+	free_all_bootmem();
 	mem_init_print_info(NULL);
 	show_mem(0);
-
-	return;
 }
 
 void free_initmem(void)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
