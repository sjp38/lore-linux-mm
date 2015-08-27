Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 91AAF6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:03:10 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so18956355pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:03:10 -0700 (PDT)
Received: from unicom146.biz-email.net (unicom146.biz-email.net. [210.51.26.146])
        by mx.google.com with ESMTPS id f5si2469030pdh.195.2015.08.27.01.55.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 02:03:09 -0700 (PDT)
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH V3] mm: memory hot-add: memory can not be added to movable zone defaultly
Date: Thu, 27 Aug 2015 04:54:01 -0400
Message-ID: <1440665641-3839-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz
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
Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>i
Tested-by: Dongdong Fan <fandd@inspur.com>
---
 mm/memory_hotplug.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..b5f14fa 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1198,6 +1198,9 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 
+	if (movable_node_is_enabled())
+		return 1;
+
 	if (zone_is_empty(movable_zone))
 		return 0;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
