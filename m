Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A9C016B003B
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:41:37 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so1854236pdj.40
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:41:36 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 08/19] mm/PARISC: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:28 +0800
Message-Id: <1365867399-21323-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-parisc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/parisc/mm/init.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index f80c175..ab76b84 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -585,18 +585,8 @@ void __init mem_init(void)
 			> BITS_PER_LONG);
 
 	high_memory = __va((max_pfn << PAGE_SHIFT));
-
-#ifndef CONFIG_DISCONTIGMEM
-	max_mapnr = page_to_pfn(virt_to_page(high_memory - 1)) + 1;
+	set_max_mapnr(page_to_pfn(virt_to_page(high_memory - 1)) + 1);
 	free_all_bootmem();
-#else
-	{
-		int i;
-
-		for (i = 0; i < npmem_ranges; i++)
-			free_all_bootmem_node(NODE_DATA(i));
-	}
-#endif
 
 #ifdef CONFIG_PA11
 	if (hppa_dma_ops == &pcxl_dma_ops) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
