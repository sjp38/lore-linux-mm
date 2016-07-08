Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB5D6B0273
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:39:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so8336380wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:39:08 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id ub2si2068821wjc.93.2016.07.08.02.39.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:39:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id E7546C3FA
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:39:06 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/34] mm, page_alloc: wake kswapd based on the highest eligible zone
Date: Fri,  8 Jul 2016 10:34:58 +0100
Message-Id: <1467970510-21195-23-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The ac_classzone_idx is used as the basis for waking kswapd and that is based
on the preferred zoneref. If the preferred zoneref's first zone is lower
than what is available on other nodes, it's possible that kswapd is woken
on a zone with only higher, but still eligible, zones. As classzone_idx
is strictly adhered to now, it causes a problem because eligible pages
are skipped.

For example, node 0 has only DMA32 and node 1 has only NORMAL. An allocating
context running on node 0 may wake kswapd on node 1 telling it to skip
all NORMAL pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb261885c121..e6ee52f1c15f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3415,7 +3415,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 					ac->high_zoneidx, ac->nodemask) {
 		if (last_pgdat != zone->zone_pgdat)
-			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
+			wakeup_kswapd(zone, order, ac->high_zoneidx);
 		last_pgdat = zone->zone_pgdat;
 	}
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
