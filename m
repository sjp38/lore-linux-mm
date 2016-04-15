Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19B5B6B026A
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:09:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so13115966wmw.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:09:09 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id i4si39053258wmd.11.2016.04.15.02.09.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:09:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8FE021DC2A4
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:09:07 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/28] mm, page_alloc: Reduce cost of fair zone allocation policy retry
Date: Fri, 15 Apr 2016 10:07:46 +0100
Message-Id: <1460711275-1130-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The fair zone allocation policy is not without cost but it can be reduced
slightly. This patch removes an unnecessary local variable, checks the
likely conditions of the fair zone policy first, uses a bool instead of
a flags check and falls through when a remote node is encountered instead
of doing a full restart. The benefit is marginal but it's there

                                           4.6.0-rc2                  4.6.0-rc2
                                       decstat-v1r20              optfair-v1r20
Min      alloc-odr0-1               377.00 (  0.00%)           380.00 ( -0.80%)
Min      alloc-odr0-2               273.00 (  0.00%)           273.00 (  0.00%)
Min      alloc-odr0-4               226.00 (  0.00%)           227.00 ( -0.44%)
Min      alloc-odr0-8               196.00 (  0.00%)           196.00 (  0.00%)
Min      alloc-odr0-16              183.00 (  0.00%)           183.00 (  0.00%)
Min      alloc-odr0-32              175.00 (  0.00%)           173.00 (  1.14%)
Min      alloc-odr0-64              172.00 (  0.00%)           169.00 (  1.74%)
Min      alloc-odr0-128             170.00 (  0.00%)           169.00 (  0.59%)
Min      alloc-odr0-256             183.00 (  0.00%)           180.00 (  1.64%)
Min      alloc-odr0-512             191.00 (  0.00%)           190.00 (  0.52%)
Min      alloc-odr0-1024            199.00 (  0.00%)           198.00 (  0.50%)
Min      alloc-odr0-2048            204.00 (  0.00%)           204.00 (  0.00%)
Min      alloc-odr0-4096            210.00 (  0.00%)           209.00 (  0.48%)
Min      alloc-odr0-8192            213.00 (  0.00%)           213.00 (  0.00%)
Min      alloc-odr0-16384           214.00 (  0.00%)           214.00 (  0.00%)

The benefit is marginal at best but one of the most important benefits,
avoiding a second search when falling back to another node is not triggered
by this particular test so the benefit for some corner cases is understated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7a5f6ff4ea06..98b443c97be6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2676,12 +2676,10 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 {
 	struct zoneref *z;
 	struct zone *zone;
-	bool fair_skipped;
-	bool zonelist_rescan;
+	bool fair_skipped = false;
+	bool apply_fair = (alloc_flags & ALLOC_FAIR);
 
 zonelist_scan:
-	zonelist_rescan = false;
-
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2701,13 +2699,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		 * page was allocated in should have no effect on the
 		 * time the page has in memory before being reclaimed.
 		 */
-		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(ac->preferred_zone, zone))
-				break;
+		if (apply_fair) {
 			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
 				fair_skipped = true;
 				continue;
 			}
+			if (!zone_local(ac->preferred_zone, zone)) {
+				if (fair_skipped)
+					goto reset_fair;
+				apply_fair = false;
+			}
 		}
 		/*
 		 * When allocating a page cache page for writing, we
@@ -2796,18 +2797,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * include remote zones now, before entering the slowpath and waking
 	 * kswapd: prefer spilling to a remote zone over swapping locally.
 	 */
-	if (alloc_flags & ALLOC_FAIR) {
-		alloc_flags &= ~ALLOC_FAIR;
-		if (fair_skipped) {
-			zonelist_rescan = true;
-			reset_alloc_batches(ac->preferred_zone);
-		}
-		if (nr_online_nodes > 1)
-			zonelist_rescan = true;
-	}
-
-	if (zonelist_rescan)
+	if (fair_skipped) {
+reset_fair:
+		apply_fair = false;
+		fair_skipped = false;
+		reset_alloc_batches(ac->preferred_zone);
 		goto zonelist_scan;
+	}
 
 	return NULL;
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
