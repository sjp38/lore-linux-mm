Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 072F06B0070
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:01 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so19345838pdb.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:00 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id on7si42252024pdb.188.2015.06.24.17.42.54
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 04/10] mm/compaction: clean-up restarting condition check
Date: Thu, 25 Jun 2015 09:45:15 +0900
Message-Id: <1435193121-25880-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Rename check function and move one outer condition check to this function.
There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 2d8e211..dd2063b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -188,8 +188,11 @@ void compaction_defer_reset(struct zone *zone, int order,
 }
 
 /* Returns true if restarting compaction after many failures */
-bool compaction_restarting(struct zone *zone, int order)
+static bool compaction_direct_restarting(struct zone *zone, int order)
 {
+	if (current_is_kswapd())
+		return false;
+
 	if (order < zone->compact_order_failed)
 		return false;
 
@@ -1327,7 +1330,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 * is about to be retried after being deferred. kswapd does not do
 	 * this reset as it'll reset the cached information when going to sleep.
 	 */
-	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+	if (compaction_direct_restarting(zone, cc->order))
 		__reset_isolation_suitable(zone);
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
