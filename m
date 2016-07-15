Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E30806B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so15445523wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:27 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id q185si5212162wmg.57.2016.07.15.06.09.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 06:09:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 748B199270
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:09:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/5] mm, vmscan: make shrink_node decisions more node-centric -fix
Date: Fri, 15 Jul 2016 14:09:21 +0100
Message-Id: <1468588165-12461-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The patch "mm, vmscan: make shrink_node decisions more node-centric"
checks whether compaction is suitable on empty nodes. This is expensive
rather than wrong but is worth fixing.

This is a fix to the mmotm patch
mm-vmscan-make-shrink_node-decisions-more-node-centric.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 864a3b1e5f8b..4fdb9e419588 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2408,6 +2408,8 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
+		if (!populated_zone(zone))
+			continue;
 
 		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
 		case COMPACT_PARTIAL:
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
