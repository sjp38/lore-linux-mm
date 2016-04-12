Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 86D6B6B0288
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:45:33 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id v188so121566907wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:45:33 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id a145si23199993wmd.61.2016.04.12.03.45.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:45:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D11819901D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:45:31 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/28] mm, vmscan: Update classzone_idx if buffer_heads_over_limit
Date: Tue, 12 Apr 2016 11:44:57 +0100
Message-Id: <1460457904-754-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
 <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
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
index e2238ab6ae53..9f2376ad4ce3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2573,8 +2573,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
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
