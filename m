Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CF5EC6B0121
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:45:35 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id 3so7129837pdj.5
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:45:35 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 06/13] mm/metag: prepare for killing free_all_bootmem_node()
Date: Wed, 29 May 2013 22:44:45 +0800
Message-Id: <1369838692-26860-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
References: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/metag/mm/init.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index e0862b7..28813f1 100644
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
