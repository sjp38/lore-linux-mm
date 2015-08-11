Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB956B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 03:38:21 -0400 (EDT)
Received: by qgj62 with SMTP id 62so109015504qgj.2
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 00:38:21 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f23si1897742qge.2.2015.08.11.00.38.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 00:38:19 -0700 (PDT)
Message-ID: <55C9A554.4090509@huawei.com>
Date: Tue, 11 Aug 2015 15:33:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] memory-hotplug: remove reset_node_managed_pages() and
 reset_node_managed_pages() in hotadd_new_pgdat()
References: <55C9A3A9.5090300@huawei.com>
In-Reply-To: <55C9A3A9.5090300@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

After hotadd_new_pgdat()->free_area_init_node(), the pgdat and zone's spanned/present 
are both 0, so remove reset_node_managed_pages() and reset_node_managed_pages().

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c | 25 -------------------------
 1 file changed, 25 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 11f26cc..997dfad 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1065,16 +1065,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
-static void reset_node_present_pages(pg_data_t *pgdat)
-{
-	struct zone *z;
-
-	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		z->present_pages = 0;
-
-	pgdat->node_present_pages = 0;
-}
-
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
@@ -1109,21 +1099,6 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	build_all_zonelists(pgdat, NULL);
 	mutex_unlock(&zonelists_mutex);
 
-	/*
-	 * zone->managed_pages is set to an approximate value in
-	 * free_area_init_core(), which will cause
-	 * /sys/device/system/node/nodeX/meminfo has wrong data.
-	 * So reset it to 0 before any memory is onlined.
-	 */
-	reset_node_managed_pages(pgdat);
-
-	/*
-	 * When memory is hot-added, all the memory is in offline state. So
-	 * clear all zones' present_pages because they will be updated in
-	 * online_pages() and offline_pages().
-	 */
-	reset_node_present_pages(pgdat);
-
 	return pgdat;
 }
 
-- 
2.0.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
