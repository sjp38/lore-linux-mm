Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 262FB828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:19:43 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so14965802lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:19:43 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id uw2si34531712wjb.55.2016.06.21.07.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:19:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 8D9761C19B1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:19:41 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/27] mm, vmscan: Update classzone_idx if buffer_heads_over_limit
Date: Tue, 21 Jun 2016 15:15:59 +0100
Message-Id: <1466518566-30034-21-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

If buffer heads are over the limit then the direct reclaim gfp_mask
is promoted to __GFP_HIGHMEM so that lowmem is indirectly freed. With
node-based reclaim, it is also required that the classzone_idx be updated
or the pages will be skipped.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1f7c1262c0a3..f4c759b3581b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2571,8 +2571,10 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	 * highmem pages could be pinning lowmem pages storing buffer_heads
 	 */
 	orig_mask = sc->gfp_mask;
-	if (buffer_heads_over_limit)
+	if (buffer_heads_over_limit) {
 		sc->gfp_mask |= __GFP_HIGHMEM;
+		classzone_idx = gfp_zone(sc->gfp_mask);
+	}
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
