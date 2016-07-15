Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A33E76B0261
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so15117993wma.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:30 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id pp7si669585wjb.32.2016.07.15.06.09.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 06:09:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id AF106992D0
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:09:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/5] mm, vmscan: avoid passing in classzone_idx unnecessarily to compaction_ready -fix
Date: Fri, 15 Jul 2016 14:09:22 +0100
Message-Id: <1468588165-12461-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As pointed out by Vlastimil, there is a redundant check in shrink_zones
since commit "mm, vmscan: avoid passing in classzone_idx unnecessarily to
compaction_ready".  The zonelist iterator only returns zones that already
meet the requirements of the allocation request.

This is a fix to the mmotm patch
mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-compaction_ready.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4fdb9e419588..c2ad4263f965 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2606,7 +2606,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			 */
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-			    zonelist_zone_idx(z) <= sc->reclaim_idx &&
 			    compaction_ready(zone, sc)) {
 				sc->compaction_ready = true;
 				continue;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
