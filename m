Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id B751B6B0254
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:57:36 -0400 (EDT)
Received: by oiev17 with SMTP id v17so90445832oie.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:57:36 -0700 (PDT)
Received: from unicom154.biz-email.net (bgp252.corp-email.cn. [112.65.243.252])
        by mx.google.com with ESMTPS id t4si898494oes.21.2015.09.15.00.57.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:57:35 -0700 (PDT)
Received: from unicom146.biz-email.net ([192.168.0.146])
        by unicom154.biz-email.net ((Trust)) with ESMTP (SSL) id CGT00024
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 15:56:24 +0800
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH V5] mm: memory hot-add: memory can not be added to movable zone defaultly
Date: Tue, 15 Sep 2015 03:49:58 -0400
Message-ID: <1442303398-45536-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, liuchangsheng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

From: Changsheng Liu <liuchangcheng@inspur.com>

After the user config CONFIG_MOVABLE_NODE and movable_node kernel option,
When the memory is hot added, should_add_memory_movable() return 0
because all zones including movable zone are empty,
so the memory that was hot added will be added  to the normal zone
and the normal zone will be created firstly.
But we want the whole node to be added to movable zone defaultly.

So we change should_add_memory_movable(): if the user config
CONFIG_MOVABLE_NODE and movable_node kernel option
it will always return 1 and all zones is empty at the same time,
so that the movable zone will be created firstly
and then the whole node will be added to movable zone defaultly.
If we want the node to be added to normal zone,
we can do it as follows:
"echo online_kernel > /sys/devices/system/memory/memoryXXX/state"

Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
Tested-by: Dongdong Fan <fandd@inspur.com>
---
 mm/memory_hotplug.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..d39dbb0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1190,6 +1190,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
 /*
  * If movable zone has already been setup, newly added memory should be check.
  * If its address is higher than movable zone, it should be added as movable.
+ * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
+ * added memory does not overlap the zone before MOVABLE_ZONE,
+ * the memory is added as movable
  * Without this check, movable zone may overlap with other zone.
  */
 static int should_add_memory_movable(int nid, u64 start, u64 size)
@@ -1197,6 +1200,11 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
+	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
+
+	if (movable_node_is_enabled()
+	&& zone_end_pfn(pre_zone) <= start_pfn)
+		return 1;
 
 	if (zone_is_empty(movable_zone))
 		return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
