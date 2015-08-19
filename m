Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 413F46B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 04:19:11 -0400 (EDT)
Received: by qgeg42 with SMTP id g42so137001302qge.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 01:19:11 -0700 (PDT)
Received: from bgp253.corp-email.cn (bgp253.corp-email.cn. [112.65.243.253])
        by mx.google.com with ESMTPS id e4si35998387qka.6.2015.08.19.01.19.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 01:19:10 -0700 (PDT)
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH] Memory hot added,The memory can not been added to movable zone
Date: Wed, 19 Aug 2015 04:18:26 -0400
Message-ID: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, liuchangsheng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

From: Changsheng Liu <liuchangcheng@inspur.com>

When memory hot added, the function should_add_memory_movable
always return 0,because the movable zone is empty,
so the memory that hot added will add to normal zone even if
we want to remove the memory.
So we change the function should_add_memory_movable,if the user
config CONFIG_MOVABLE_NODE it will return 1 when
movable zone is empty

Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
---
 mm/memory_hotplug.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..2b0aec4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1198,9 +1198,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 
-	if (zone_is_empty(movable_zone))
+	if (zone_is_empty(movable_zone)) {
+	#ifdef CONFIG_MOVABLE_NODE
+		return 1;
+	#else
 		return 0;
-
+	#endif
+	}
 	if (movable_zone->zone_start_pfn <= start_pfn)
 		return 1;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
