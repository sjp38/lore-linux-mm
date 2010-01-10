Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E8FCE6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 18:50:30 -0500 (EST)
Received: by pzk34 with SMTP id 34so13228385pzk.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 15:50:29 -0800 (PST)
Date: Mon, 11 Jan 2010 08:48:16 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 -mmotm-2010-01-06-14-34] check high watermark after
 shrink zone
Message-Id: <20100111084816.81bc7ebd.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>



 * V2
  * Add reviewed-by singed-off (Thanks Kosaki, Wu)
  * Fix typo of changelog

== CUT HERE ==

Kswapd check that zone have enough free by zone_water_mark.
If any zone doesn't have enough page, it set all_zones_ok to zero.
!all_zone_ok makes kswapd retry not sleeping.

I think the watermark check before shrink zone is pointless.
Kswapd try to shrink zone then the check is meaninful.

This patch move the check after shrink zone.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 885207a..b81adf8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2057,9 +2057,6 @@ loop_again:
 					priority != DEF_PRIORITY)
 				continue;
 
-			if (!zone_watermark_ok(zone, order,
-					high_wmark_pages(zone), end_zone, 0))
-				all_zones_ok = 0;
 			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
@@ -2099,13 +2096,17 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
-			/*
-			 * We are still under min water mark. it mean we have
-			 * GFP_ATOMIC allocation failure risk. Hurry up!
-			 */
-			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
-					      end_zone, 0))
-				has_under_min_watermark_zone = 1;
+			if (!zone_watermark_ok(zone, order,
+					high_wmark_pages(zone), end_zone, 0)) {
+				all_zones_ok = 0;
+				/*
+				 * We are still under min water mark. it mean we have
+				 * GFP_ATOMIC allocation failure risk. Hurry up!
+				 */
+				if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
+						      end_zone, 0))
+					has_under_min_watermark_zone = 1;
+			}
 
 		}
 		if (all_zones_ok)
-- 
1.5.6.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
