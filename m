Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D16596B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 07:14:20 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] vmscan: Fix use of delta in zone_pagecache_reclaimable()
Date: Mon, 15 Jun 2009 12:14:41 +0100
Message-Id: <1245064482-19245-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1245064482-19245-1-git-send-email-mel@csn.ul.ie>
References: <1245064482-19245-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

zone_pagecache_reclaimable() works out how many pages are in a state
that zone_reclaim() can reclaim based on the current zone_reclaim_mode.
As part of this, it calculates a delta to the number of unmapped pages.
The code was meant to check delta would not cause underflows and then apply
it but it got accidentally removed.

This patch properly uses delta. It's excessively paranoid at the moment
because it's impossible to underflow but the current form will make future
patches to zone_pagecache_reclaimable() fixing any other scan-heuristic
breakage easier to read and acts as self-documentation reminding authors
of future patches to consider underflow.

This is a fix to patch
vmscan-properly-account-for-the-number-of-page-cache-pages-zone_reclaim-can-reclaim.patch
and they should be merged together.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 026f452..bd8e3ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2398,7 +2398,11 @@ static long zone_pagecache_reclaimable(struct zone *zone)
 	if (!(zone_reclaim_mode & RECLAIM_WRITE))
 		delta += zone_page_state(zone, NR_FILE_DIRTY);
 
-	return nr_pagecache_reclaimable;
+	/* Watch for any possible underflows due to delta */
+	if (unlikely(delta > nr_pagecache_reclaimable))
+		delta = nr_pagecache_reclaimable;
+
+	return nr_pagecache_reclaimable - delta;
 }
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
