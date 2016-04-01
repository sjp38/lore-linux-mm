Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BAE9A6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:10:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id td3so78789561pab.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:18 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id kd12si17784319pad.15.2016.03.31.19.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:10:18 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id fe3so79188540pab.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:17 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/4] mm/writeback: correct dirty page calculation for highmem
Date: Fri,  1 Apr 2016 11:10:07 +0900
Message-Id: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

ZONE_MOVABLE could be treated as highmem so we need to consider it for
accurate calculation of dirty pages. And, in following patches, ZONE_CMA
will be introduced and it can be treated as highmem, too. So, instead of
manually adding stat of ZONE_MOVABLE, looping all zones and check whether
the zone is highmem or not and add stat of the zone which can be treated
as highmem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page-writeback.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f7..6a72809 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -296,11 +296,15 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 #ifdef CONFIG_HIGHMEM
 	int node;
 	unsigned long x = 0;
+	int i;
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
-		struct zone *z = &NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			struct zone *z = &NODE_DATA(node)->node_zones[i];
 
-		x += zone_dirtyable_memory(z);
+			if (is_highmem(z))
+				x += zone_dirtyable_memory(z);
+		}
 	}
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
