Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 74C396B003C
	for <linux-mm@kvack.org>; Mon, 13 May 2013 04:12:53 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 8/9] mm: vmscan: Check if kswapd should writepage once per pgdat scan
Date: Mon, 13 May 2013 09:12:39 +0100
Message-Id: <1368432760-21573-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1368432760-21573-1-git-send-email-mgorman@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently kswapd checks if it should start writepage as it shrinks
each zone without taking into consideration if the zone is balanced or
not. This is not wrong as such but it does not make much sense either.
This patch checks once per pgdat scan if kswapd should be writing pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 911c9cd..e65fe46 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2849,6 +2849,13 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		}
 
 		/*
+		 * If we're getting trouble reclaiming, start doing writepage
+		 * even in laptop mode.
+		 */
+		if (sc.priority < DEF_PRIORITY - 2)
+			sc.may_writepage = 1;
+
+		/*
 		 * Now scan the zone in the dma->highmem direction, stopping
 		 * at the last zone which needs scanning.
 		 *
@@ -2919,13 +2926,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 					raise_priority = false;
 			}
 
-			/*
-			 * If we're getting trouble reclaiming, start doing
-			 * writepage even in laptop mode.
-			 */
-			if (sc.priority < DEF_PRIORITY - 2)
-				sc.may_writepage = 1;
-
 			if (zone->all_unreclaimable) {
 				if (end_zone && end_zone == i)
 					end_zone--;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
