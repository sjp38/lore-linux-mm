Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D4144900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:16 -0400 (EDT)
Received: by wiga1 with SMTP id a1so87455516wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id am6si5346095wjc.37.2015.06.08.06.57.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/25] mm, vmscan: Check if cpusets are enabled during direct reclaim
Date: Mon,  8 Jun 2015 14:56:23 +0100
Message-Id: <1433771791-30567-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Direct reclaim obeys cpusets but misses the cpusets_enabled() check.
The overhead is unlikely to be measurable in the direct reclaim
path which is expensive but there is no harm is doing it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 140aeefdebe1..e1fbd89ab750 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2522,7 +2522,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
-			if (!cpuset_zone_allowed(zone,
+			if (cpusets_enabled() && !cpuset_zone_allowed(zone,
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
