Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43BDC6B0268
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:50 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so68816638wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:50 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id b77si3197968wmf.115.2016.04.06.04.21.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:21:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 93A3398EE4
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:21:44 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/27] mm, vmscan: Update classzone_idx if buffer_heads_over_limit
Date: Wed,  6 Apr 2016 12:20:19 +0100
Message-Id: <1459941626-3290-21-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

If buffer heads are over the limit then the direct reclaim gfp_mask
is promoted to __GFP_HIGHMEM so that lowmem is indirectly freed. With
node-based reclaim, it is also required that the classzone_idx be updated
or the pages will be skipped.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f2072bc6884..0298c0977eac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2575,8 +2575,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	 * highmem pages could be pinning lowmem pages storing buffer_heads
 	 */
 	orig_mask = sc->gfp_mask;
-	if (buffer_heads_over_limit)
+	if (buffer_heads_over_limit) {
 		sc->gfp_mask |= __GFP_HIGHMEM;
+		classzone_idx = gfp_zone(sc->gfp_mask);
+	}
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					classzone_idx, sc->nodemask) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
