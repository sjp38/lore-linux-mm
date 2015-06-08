Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3A496900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:37 -0400 (EDT)
Received: by wgv5 with SMTP id 5so104188670wgv.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si5325633wjw.88.2015.06.08.06.57.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:11 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 25/25] mm: page_alloc: Take fewer passes when allocating to the low watermark
Date: Mon,  8 Jun 2015 14:56:31 +0100
Message-Id: <1433771791-30567-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 886102cc9b09..58f6330ec3e2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1927,6 +1927,27 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
 				goto try_this_zone;
 
+			/*
+			 * If checking the low watermark, see if we meet the
+			 * min watermark and if so, try the zone and wake
+			 * kswapd instead of falling back to a remote zone
+			 * or having to take a second pass
+			 */
+			if (alloc_flags & ALLOC_WMARK_LOW) {
+				int min_flags = alloc_flags;
+
+				min_flags &= ~ALLOC_WMARK_LOW;
+				min_flags |= ALLOC_WMARK_MIN;
+
+				if (zone_watermark_ok(zone, order,
+						zone->watermark[min_flags & ALLOC_WMARK_MASK],
+						ac->classzone_idx,
+						min_flags)) {
+					wakeup_kswapd(zone, order, ac->classzone_idx);
+					goto try_this_zone;
+				}
+			}
+
 			if (node_reclaim_mode == 0 ||
 			    !zone_allows_reclaim(ac->preferred_zone, zone))
 				goto this_zone_full;
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
