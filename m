Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 30B1F6B0027
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 09:04:31 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/10] mm: vmscan: Check if kswapd should writepage once per priority
Date: Sun, 17 Mar 2013 13:04:15 +0000
Message-Id: <1363525456-10448-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently kswapd checks if it should start writepage as it shrinks
each zone without taking into consideration if the zone is balanced or
not. This is not wrong as such but it does not make much sense either.
This patch checks once per priority if kswapd should be writing pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84375b2..8c66e5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2804,6 +2804,13 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
@@ -2876,13 +2883,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				nr_to_reclaim += sc.nr_to_reclaim;
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
