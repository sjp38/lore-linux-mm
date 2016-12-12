Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B07836B0253
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:59:12 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id x190so72043067qkb.5
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 21:59:12 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 131si25574186qki.334.2016.12.11.21.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 21:59:12 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id n204so9412065qke.2
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 21:59:12 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics data
Date: Mon, 12 Dec 2016 13:59:07 +0800
Message-Id: <1481522347-20393-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Jia He <hejianet@gmail.com>

In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
zone_statistics"), it reconstructed codes to reduce the branch miss rate.
Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
 z->node would not be equal to preferred_zone->node. That seems to be
incorrect.

Fixes: commit b9f00e147f27 ("mm, page_alloc: reduce branches in
zone_statistics")

Signed-off-by: Jia He <hejianet@gmail.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..474757e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2568,6 +2568,9 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
 	if (z->node == local_nid) {
 		__inc_zone_state(z, NUMA_HIT);
 		__inc_zone_state(z, local_stat);
+	} else if (z->node == preferred_zone->node) {
+		__inc_zone_state(z, NUMA_HIT);
+		__inc_zone_state(z, NUMA_OTHER);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
