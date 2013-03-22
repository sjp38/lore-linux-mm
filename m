Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 7F2DC6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 23:56:28 -0400 (EDT)
Message-ID: <514BD656.2060307@huawei.com>
Date: Fri, 22 Mar 2013 11:56:06 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hotplug: use -EPERM instead of -1 for return value in
 online_pages()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, linux-mm@kvack.org, qiuxishi <qiuxishi@huawei.com>

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/memory_hotplug.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b81a367b..07b6263 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -332,7 +332,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 	return 0;
 out_fail:
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-	return -1;
+	return -EPERM;
 }
 
 static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
@@ -374,7 +374,7 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 	return 0;
 out_fail:
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-	return -1;
+	return -EPERM;
 }
 
 static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
@@ -924,19 +924,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
 	    !can_online_high_movable(zone)) {
 		unlock_memory_hotplug();
-		return -1;
+		return -EPERM;
 	}
 
 	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
 		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
-			return -1;
+			return -EPERM;
 		}
 	}
 	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
 		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
-			return -1;
+			return -EPERM;
 		}
 	}
 
-- 
1.7.6.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
