Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 28933900018
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:52:23 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so124621996pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 03:52:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id dk4si16136532pbb.219.2015.04.17.03.52.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 03:52:22 -0700 (PDT)
Message-ID: <5530E57C.9080303@huawei.com>
Date: Fri, 17 Apr 2015 18:50:36 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2 V2] memory-hotplug: remove reset_node_managed_pages()
 and reset_node_managed_pages() in hotadd_new_pgdat()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

After hotadd_new_pgdat()->free_area_init_node(), pgdat's spanned/present are 0,
and zone's spanned/present/managed are 0, so remove reset_node_managed_pages()
and reset_node_managed_pages().

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 457bde5..82c67ee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1064,16 +1064,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
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
@@ -1108,21 +1098,6 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
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
1.7.1 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
