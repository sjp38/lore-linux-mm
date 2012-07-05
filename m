Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8962F6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 05:52:30 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH 2/4] mm/hotplug: correctly add new zone to all other nodes' zone lists
Date: Thu, 5 Jul 2012 17:45:30 +0800
Message-ID: <1341481532-1700-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

When online_pages() is called to add new memory to an empty zone,
it rebuilds all zone lists by calling build_all_zonelists().
But there's a bug which prevents the new zone to be added to other
nodes' zone lists.

online_pages() {
	build_all_zonelists()
	.....
	node_set_state(zone_to_nid(zone), N_HIGH_MEMORY)
}

Here the node of the zone is put into N_HIGH_MEMORY state after calling
build_all_zonelists(), but build_all_zonelists() only adds zones from
nodes in N_HIGH_MEMORY state to the fallback zone lists.
build_all_zonelists()
    ->__build_all_zonelists()
	->build_zonelists()
	    ->find_next_best_node()
		->for_each_node_state(n, N_HIGH_MEMORY)

So memory in the new zone will never be used by other nodes, and it may
cause strange behavor when system is under memory pressure.  So put node
into N_HIGH_MEMORY state before calling build_all_zonelists().

Signed-Off: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/memory_hotplug.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f93c5b5..bce80c7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -512,19 +512,20 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
-	if (need_zonelists_rebuild)
-		build_all_zonelists(NULL, zone);
-	else
-		zone_pcp_update(zone);
+	if (onlined_pages) {
+		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
+		if (need_zonelists_rebuild)
+			build_all_zonelists(NULL, zone);
+		else
+			zone_pcp_update(zone);
+	}
 
 	mutex_unlock(&zonelists_mutex);
 
 	init_per_zone_wmark_min();
 
-	if (onlined_pages) {
+	if (onlined_pages)
 		kswapd_run(zone_to_nid(zone));
-		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
-	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
