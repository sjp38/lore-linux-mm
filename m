Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D3A6B0260
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 10:50:32 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so116812567lfi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:50:32 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id o74si15240383wme.16.2016.07.18.07.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 07:50:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 268471C1C39
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 15:50:27 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/3] mm, vmscan: Remove redundant check in shrink_zones()
Date: Mon, 18 Jul 2016 15:50:24 +0100
Message-Id: <1468853426-12858-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As pointed out by Minchan Kim, shrink_zones() checks for populated
zones in a zonelist but a zonelist can never contain unpopulated
zones. While it's not related to the node-lru series, it can be
cleaned up now.

Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f06a7a0d135..45344acf52ba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2605,9 +2605,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					sc->reclaim_idx, sc->nodemask) {
-		if (!populated_zone(zone))
-			continue;
-
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
