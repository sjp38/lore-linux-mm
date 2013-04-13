Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id BC5276B0036
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:40:47 -0400 (EDT)
Received: by mail-da0-f54.google.com with SMTP id p1so1508392dad.41
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:40:46 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 03/19] mm/IA64: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:23 +0800
Message-Id: <1365867399-21323-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-ia64@vger.kernel.org

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/ia64/mm/init.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d4382dc..26eeb74 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -584,7 +584,6 @@ __setup("nolwsys", nolwsys_setup);
 void __init
 mem_init (void)
 {
-	pg_data_t *pgdat;
 	int i;
 
 	BUG_ON(PTRS_PER_PGD * sizeof(pgd_t) != PAGE_SIZE);
@@ -602,15 +601,11 @@ mem_init (void)
 
 #ifdef CONFIG_FLATMEM
 	BUG_ON(!mem_map);
-	max_mapnr = max_low_pfn;
 #endif
 
+	set_max_mapnr(max_low_pfn);
 	high_memory = __va(max_low_pfn * PAGE_SIZE);
-
-	for_each_online_pgdat(pgdat)
-		if (pgdat->bdata->node_bootmem_map)
-			free_all_bootmem_node(pgdat);
-
+	free_all_bootmem();
 	mem_init_print_info(NULL);
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
