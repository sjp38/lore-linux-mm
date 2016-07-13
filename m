Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCC836B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:00:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so31951243wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:00:08 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id y200si9809337wme.141.2016.07.13.03.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:00:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 694FC1C1A97
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:00:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/4] mm, vmscan: Have kswapd reclaim from all zones if reclaiming and buffer_heads_over_limit -fix
Date: Wed, 13 Jul 2016 11:00:01 +0100
Message-Id: <1468404004-5085-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Johannes reported that the comment about buffer_heads_over_limit in
balance_pgdat only made sense in the context of the patch. This patch
clarifies the reasoning and how it applies to 32 and 64 bit systems.

This is a fix to the mmotm patch
mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d079210d46ee..21eae17ee730 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3131,12 +3131,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		/*
 		 * If the number of buffer_heads exceeds the maximum allowed
-		 * then consider reclaiming from all zones. This is not
-		 * specific to highmem which may not exist but it is it is
-		 * expected that buffer_heads are stripped in writeback.
-		 * Reclaim may still not go ahead if all eligible zones
-		 * for the original allocation request are balanced to
-		 * avoid excessive reclaim from kswapd.
+		 * then consider reclaiming from all zones. This has a dual
+		 * purpose -- on 64-bit systems it is expected that
+		 * buffer_heads are stripped during active rotation. On 32-bit
+		 * systems, highmem pages can pin lowmem memory and shrinking
+		 * buffers can relieve lowmem pressure. Reclaim may still not
+		 * go ahead if all eligible zones for the original allocation
+		 * request are balanced to avoid excessive reclaim from kswapd.
 		 */
 		if (buffer_heads_over_limit) {
 			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
