Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 816316B006C
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:12 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2867515pab.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:12 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id l1si4088298pde.14.2015.02.11.23.30.08
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:10 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 02/16] mm/writeback: correct dirty page calculation for highmem
Date: Thu, 12 Feb 2015 16:32:06 +0900
Message-Id: <1423726340-4084-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

ZONE_MOVABLE could be treated as highmem so we need to consider it for
accurate calculation of dirty pages. And, in following patches, ZONE_CMA
will be introduced and it can be treated as highmem, too. So, instead of
manually adding stat of ZONE_MOVABLE, looping all zones and check whether
the zone is highmem or not and add stat of the zone which can be treated
as highmem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page-writeback.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 19ceae8..942f6b3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -198,11 +198,15 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
