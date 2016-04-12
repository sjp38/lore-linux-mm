Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A0F8A6B026D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:14:01 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l6so181219170wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:14:01 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id w195si23064950wmd.112.2016.04.12.03.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:14:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 3DB3C1C1E05
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:14:00 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/24] mm, page_alloc: Reduce cost of fair zone allocation policy retry
Date: Tue, 12 Apr 2016 11:12:18 +0100
Message-Id: <1460455945-29644-18-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index 219e0d05ed88..25a8ab07b287 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2675,12 +2675,10 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2700,13 +2698,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2795,18 +2796,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
