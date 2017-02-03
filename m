Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEA96B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 15:32:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so6077708wme.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 12:32:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si33545071wrg.265.2017.02.03.12.32.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 12:32:28 -0800 (PST)
Date: Fri, 3 Feb 2017 20:32:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, vmscan: Clear PGDAT_WRITEBACK when zone is balanced
Message-ID: <20170203203222.gq7hk66yc36lpgtb@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Michal Hocko' <mhocko@suse.com>, 'Minchan Kim' <minchan.kim@gmail.com>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hillf Danton pointed out that since commit 1d82de618dd ("mm, vmscan:
make kswapd reclaim in terms of nodes") that PGDAT_WRITEBACK is no longer
cleared. It was not noticed as triggering it requires pages under writeback
to cycle twice through the LRU and before kswapd gets stalled. Historically,
such issues tended to occur on small machines writing heavily to slow
storage such as a USB stick. Once kswapd stalls, direct reclaim stalls may
be higher but due to the fact that memory pressure is requires, it would not
be very noticable. Michal Hocko suggested removing the flag entirely but
the conservative fix is to restore the intended PGDAT_WRITEBACK behaviour
and clear the flag when a suitable zone is balanced.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 532a2a750952..3379fa5ce6d8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3103,6 +3103,7 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 	 */
 	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
 	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
+	clear_bit(PGDAT_WRITEBACK, &zone->zone_pgdat->flags);
 
 	return true;
 }

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
