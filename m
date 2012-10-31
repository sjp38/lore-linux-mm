Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8CF816B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 01:35:17 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART1 Patch 2/3] memory_hotplug: handle empty zone when online_movable/online_kernel
Date: Wed, 31 Oct 2012 13:40:35 +0800
Message-Id: <1351662036-7435-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351662036-7435-1-git-send-email-wency@cn.fujitsu.com>
References: <1351662036-7435-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

make online_movable/online_kernel can empty a zone
or can move memory to a empty zone.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 51 +++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 45 insertions(+), 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4900025..e6ec8c2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -227,8 +227,17 @@ static void resize_zone(struct zone *zone, unsigned long start_pfn,
 
 	zone_span_writelock(zone);
 
-	zone->zone_start_pfn = start_pfn;
-	zone->spanned_pages = end_pfn - start_pfn;
+	if (end_pfn - start_pfn) {
+		zone->zone_start_pfn = start_pfn;
+		zone->spanned_pages = end_pfn - start_pfn;
+	} else {
+		/*
+		 * make it consist as free_area_init_core(),
+		 * if spanned_pages = 0, then keep start_pfn = 0
+		 */
+		zone->zone_start_pfn = 0;
+		zone->spanned_pages = 0;
+	}
 
 	zone_span_writeunlock(zone);
 }
@@ -244,10 +253,19 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
 }
 
-static int move_pfn_range_left(struct zone *z1, struct zone *z2,
+static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
+	int ret;
 	unsigned long flags;
+	unsigned long z1_start_pfn;
+
+	if (!z1->wait_table) {
+		ret = init_currently_empty_zone(z1, start_pfn,
+			end_pfn - start_pfn, MEMMAP_HOTPLUG);
+		if (ret)
+			return ret;
+	}
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -261,7 +279,13 @@ static int move_pfn_range_left(struct zone *z1, struct zone *z2,
 	if (end_pfn <= z2->zone_start_pfn)
 		goto out_fail;
 
-	resize_zone(z1, z1->zone_start_pfn, end_pfn);
+	/* use start_pfn for z1's start_pfn if z1 is empty */
+	if (z1->spanned_pages)
+		z1_start_pfn = z1->zone_start_pfn;
+	else
+		z1_start_pfn = start_pfn;
+
+	resize_zone(z1, z1_start_pfn, end_pfn);
 	resize_zone(z2, end_pfn, z2->zone_start_pfn + z2->spanned_pages);
 
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
@@ -274,10 +298,19 @@ out_fail:
 	return -1;
 }
 
-static int move_pfn_range_right(struct zone *z1, struct zone *z2,
+static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
+	int ret;
 	unsigned long flags;
+	unsigned long z2_end_pfn;
+
+	if (!z2->wait_table) {
+		ret = init_currently_empty_zone(z2, start_pfn,
+			end_pfn - start_pfn, MEMMAP_HOTPLUG);
+		if (ret)
+			return ret;
+	}
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -291,8 +324,14 @@ static int move_pfn_range_right(struct zone *z1, struct zone *z2,
 	if (start_pfn >= z1->zone_start_pfn + z1->spanned_pages)
 		goto out_fail;
 
+	/* use end_pfn for z2's end_pfn if z2 is empty */
+	if (z2->spanned_pages)
+		z2_end_pfn = z2->zone_start_pfn + z2->spanned_pages;
+	else
+		z2_end_pfn = end_pfn;
+
 	resize_zone(z1, z1->zone_start_pfn, start_pfn);
-	resize_zone(z2, start_pfn, z2->zone_start_pfn + z2->spanned_pages);
+	resize_zone(z2, start_pfn, z2_end_pfn);
 
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
