Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 03ED76B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:28:47 -0400 (EDT)
Received: by qged69 with SMTP id d69so22907277qge.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:28:46 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id n48si6054211qgn.66.2015.08.20.00.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 00:28:46 -0700 (PDT)
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH V2] mm:memory hot-add: memory can not been added to movable zone
Date: Thu, 20 Aug 2015 03:28:05 -0400
Message-ID: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, liuchangsheng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

From: Changsheng Liu <liuchangcheng@inspur.com>

When memory is hot added, should_add_memory_movable() always returns 0
because the movable zone is empty, so the memory that was hot added will
add to the normal zone even if we want to remove the memory.

So we change should_add_memory_movable(): if the user config
CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.

Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
Tested-by: Dongdong Fan <fandd@inspur.com>
---
 mm/memory_hotplug.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..ff658f2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1199,8 +1199,7 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 
 	if (zone_is_empty(movable_zone))
-		return 0;
-
+		return IS_ENABLED(CONFIG_MOVABLE_NODE);
 	if (movable_zone->zone_start_pfn <= start_pfn)
 		return 1;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
