Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 846E682F60
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:17:10 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so64116428lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:17:10 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id d62si37471461wme.62.2016.04.15.02.17.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:17:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 11B2D98B28
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:17:09 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/27] mm, vmscan: Update classzone_idx if buffer_heads_over_limit
Date: Fri, 15 Apr 2016 10:13:26 +0100
Message-Id: <1460711613-2761-21-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
