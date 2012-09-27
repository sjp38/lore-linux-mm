Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 0F14E6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 03:00:19 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 3/3] memory_hotplug: Don't modify the zone_start_pfn outside of zone_span_writelock()
Date: Thu, 27 Sep 2012 14:47:50 +0800
Message-Id: <1348728470-5580-4-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com>
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

The __add_zone() maybe call sleep-able init_currently_empty_zone()
to init wait_table,

But this function also modifies the zone_start_pfn without any lock.
It is bugy.

So we move this modification out, and we ensure the modification
of zone_start_pfn is only done with zone_span_writelock() held or in booting.

Since zone_start_pfn is not modified by init_currently_empty_zone()
grow_zone_span() needs to check zone_start_pfn before update it.

CC: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reported-by: Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>
Tested-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    2 +-
 mm/page_alloc.c     |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b62d429b..790561f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -205,7 +205,7 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 	zone_span_writelock(zone);
 
 	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	if (start_pfn < zone->zone_start_pfn)
+	if (!zone->zone_start_pfn || start_pfn < zone->zone_start_pfn)
 		zone->zone_start_pfn = start_pfn;
 
 	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c13ea75..2545013 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3997,8 +3997,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 		return ret;
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
-	zone->zone_start_pfn = zone_start_pfn;
-
 	mminit_dprintk(MMINIT_TRACE, "memmap_init",
 			"Initialising map node %d zone %lu pfns %lu -> %lu\n",
 			pgdat->node_id,
@@ -4465,6 +4463,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
 		BUG_ON(ret);
+		zone->zone_start_pfn = zone_start_pfn;
 		memmap_init(size, nid, j, zone_start_pfn);
 		zone_start_pfn += size;
 	}
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
