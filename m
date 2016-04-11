Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 08EB16B0262
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:15:54 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id f198so134635464wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:15:53 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 195si17093787wmh.23.2016.04.11.01.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:15:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id AF0561C17BD
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:15:52 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/22] mm, page_alloc: Reduce cost of fair zone allocation policy retry
Date: Mon, 11 Apr 2016 09:13:40 +0100
Message-Id: <1460362424-26369-18-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
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
                                       decstat-v1r11              optfair-v1r12
Min      alloc-odr0-1               382.00 (  0.00%)           370.00 (  3.14%)
Min      alloc-odr0-2               275.00 (  0.00%)           271.00 (  1.45%)
Min      alloc-odr0-4               228.00 (  0.00%)           227.00 (  0.44%)
Min      alloc-odr0-8               199.00 (  0.00%)           197.00 (  1.01%)
Min      alloc-odr0-16              186.00 (  0.00%)           182.00 (  2.15%)
Min      alloc-odr0-32              178.00 (  0.00%)           175.00 (  1.69%)
Min      alloc-odr0-64              174.00 (  0.00%)           171.00 (  1.72%)
Min      alloc-odr0-128             172.00 (  0.00%)           169.00 (  1.74%)
Min      alloc-odr0-256             181.00 (  0.00%)           179.00 (  1.10%)
Min      alloc-odr0-512             193.00 (  0.00%)           192.00 (  0.52%)
Min      alloc-odr0-1024            200.00 (  0.00%)           201.00 ( -0.50%)
Min      alloc-odr0-2048            206.00 (  0.00%)           205.00 (  0.49%)
Min      alloc-odr0-4096            212.00 (  0.00%)           211.00 (  0.47%)
Min      alloc-odr0-8192            215.00 (  0.00%)           214.00 (  0.47%)
Min      alloc-odr0-16384           215.00 (  0.00%)           214.00 (  0.47%)

One of the most important benefits -- avoiding a second search when
falling back to another node is not triggered by this particular test so
the benefit for some corner cases is understated.

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
