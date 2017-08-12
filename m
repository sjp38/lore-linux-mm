Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA0666B02B4
	for <linux-mm@kvack.org>; Sat, 12 Aug 2017 07:35:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so9004076wmg.3
        for <linux-mm@kvack.org>; Sat, 12 Aug 2017 04:35:18 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id b23si2381169wra.151.2017.08.12.04.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Aug 2017 04:35:17 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH] mm: Reward slab shrinkers that reclaim more than they were asked
Date: Sat, 12 Aug 2017 12:34:37 +0100
Message-Id: <20170812113437.7397-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

Some shrinkers may only be able to free a bunch of objects at a time, and
so free more than the requested nr_to_scan in one pass. Account for the
extra freed objects against the total number of objects we intend to
free, otherwise we may end up penalising the slab far more than intended.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org
---
 mm/vmscan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1af041930a6..8bf6f41f94fb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -398,6 +398,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 			break;
 		freed += ret;
 
+		nr_to_scan = max(nr_to_scan, ret);
 		count_vm_events(SLABS_SCANNED, nr_to_scan);
 		total_scan -= nr_to_scan;
 		scanned += nr_to_scan;
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
