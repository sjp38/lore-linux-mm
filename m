Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 34FF46B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/10] mm: vmscan: Check if kswapd should writepage once per pgdat scan
Date: Tue,  9 Apr 2013 12:07:04 +0100
Message-Id: <1365505625-9460-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently kswapd checks if it should start writepage as it shrinks
each zone without taking into consideration if the zone is balanced or
not. This is not wrong as such but it does not make much sense either.
This patch checks once per pgdat scan if kswapd should be writing pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c929d1e..6cd6435 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2836,6 +2836,13 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
@@ -2907,13 +2914,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
