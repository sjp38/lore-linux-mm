Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CCE976B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:14:06 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so128359989pab.1
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 23:14:06 -0700 (PDT)
Received: from unicom154.biz-email.net (bgp252.corp-email.cn. [112.65.243.252])
        by mx.google.com with ESMTPS id d15si22243858pbu.155.2015.08.30.23.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 23:14:05 -0700 (PDT)
Received: from unicom146.biz-email.net ([192.168.0.146])
        by unicom154.biz-email.net ((Trust)) with ESMTP (SSL) id SEO00048
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 14:09:48 +0800
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH V4] mm: memory hot-add: memory can not be added to movable zone defaultly
Date: Mon, 31 Aug 2015 01:58:40 -0400
Message-ID: <1441000720-28506-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, liuchangsheng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

From: Changsheng Liu <liuchangcheng@inspur.com>

After the user config CONFIG_MOVABLE_NODE and movable_node kernel option,
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

If the memory is added to movable zone defaultly,
the user can offline it and add it to other zone again.
But if the memory is added to normal zone defaultly,
the user will not offline the memory used by kernel.

Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
Tested-by: Dongdong Fan <fandd@inspur.com>
---
 mm/memory_hotplug.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..d1149ff 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1197,6 +1197,11 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
+	struct zone *normal_zone = pgdat->node_zones + ZONE_NORMAL;
+
+	if (movable_node_is_enabled()
+	&& (zone_end_pfn(normal_zone) <= start_pfn))
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
