Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 91B946B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 08:51:20 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9683187pbb.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 05:51:19 -0700 (PDT)
Message-ID: <5033843E.8000902@gmail.com>
Date: Tue, 21 Aug 2012 20:51:10 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: add build zonelists when offline pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, liuj97@gmail.com, paul.gortmaker@windriver.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bessel.wang@huawei.com, wujianguo@huawei.com, qiuxishi@huawei.com, jiang.liu@huawei.com, guohanjun@huawei.com, chenkeping@huawei.com, yinghai@kernel.org, wency@cn.fujitsu.com

From: Xishi Qiu <qiuxishi@huawei.com>

online_pages() does build_all_zonelists() and zone_pcp_update(),
I think offline_pages() should do it too. The node has no memory
to allocate, so remove this node's zones form other nodes' zonelists.


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bc7e7a2..5172bd4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -979,7 +979,11 @@ repeat:
 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
 		kswapd_stop(node);
-	}
+		mutex_lock(&zonelists_mutex);
+		build_all_zonelists(NODE_DATA(node), NULL);
+		mutex_unlock(&zonelists_mutex);
+	} else
+		zone_pcp_update(zone);

 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
-- 
1.7.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
