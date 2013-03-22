Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id F00E46B0081
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 05:54:55 -0400 (EDT)
Message-ID: <514C2A43.3020008@huawei.com>
Date: Fri, 22 Mar 2013 17:54:11 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hotplug: only free wait_table if it's allocated by vmalloc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, qiuxishi <qiuxishi@huawei.com>, linux-mm@kvack.org

zone->wait_table may be allocated from bootmem, it can not be freed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: linux-mm@kvack.org
Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/memory_hotplug.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 07b6263..91ed7cd 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1779,7 +1779,11 @@ void try_offline_node(int nid)
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
-		if (zone->wait_table)
+		/*
+		 * wait_table may be allocated from boot memory,
+		 * here only free if it's allocated by vmalloc.
+		 */
+		if (is_vmalloc_addr(zone->wait_table))
 			vfree(zone->wait_table);
 	}
 
-- 
1.7.6.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
