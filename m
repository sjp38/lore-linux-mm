Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D41B6B027A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:39:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n127so8309367wme.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:39:49 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id gg6si1451897wjd.237.2016.07.08.02.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:39:48 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id DD8A41C24F0
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:39:47 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 26/34] mm, vmscan: avoid passing in remaining unnecessarily to prepare_kswapd_sleep
Date: Fri,  8 Jul 2016 10:35:02 +0100
Message-Id: <1467970510-21195-27-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As pointed out by Minchan Kim, the first call to prepare_kswapd_sleep
always passes in 0 for remaining and the second call can trivially
check the parameter in advance.

Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d5c78e2312b..8a67aa53aa7b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3020,15 +3020,10 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
  *
  * Returns true if kswapd is ready to sleep
  */
-static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
-					int classzone_idx)
+static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	int i;
 
-	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
-	if (remaining)
-		return false;
-
 	/*
 	 * The throttled processes are normally woken up in balance_pgdat() as
 	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
@@ -3243,7 +3238,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
-	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
 		/*
 		 * Compaction records what page blocks it recently failed to
 		 * isolate pages from and skips them in the future scanning.
@@ -3278,7 +3273,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
+	if (!remaining &&
+	    prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
