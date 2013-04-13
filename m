Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CBDCE6B0027
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:40:35 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so1922056pab.0
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:40:35 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 02/19] mm/AVR32: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:22 +0800
Message-Id: <1365867399-21323-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem() instead.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: linux-kernel@vger.kernel.org
---
 arch/avr32/mm/init.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index c1706a0..b25aba3 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -103,23 +103,12 @@ void __init mem_init(void)
 	pg_data_t *pgdat;
 
 	high_memory = NULL;
+	for_each_online_pgdat(pgdat)
+		high_memory = max_t(void *, high_memory,
+			(void *)__va(pgdat_end_pfn(pgdat) << PAGE_SHIFT));
 
-	/* this will put all low memory onto the freelists */
-	for_each_online_pgdat(pgdat) {
-		void *node_high_memory;
-
-		if (pgdat->node_spanned_pages != 0)
-			free_all_bootmem_node(pgdat);
-
-		node_high_memory = (void *)((pgdat->node_start_pfn
-					     + pgdat->node_spanned_pages)
-					    << PAGE_SHIFT);
-		if (node_high_memory > high_memory)
-			high_memory = node_high_memory;
-	}
-
-	max_mapnr = MAP_NR(high_memory);
-
+	set_max_mapnr(MAP_NR(high_memory));
+	free_all_bootmem();
 	mem_init_print_info(NULL);
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
