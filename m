Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id F3F886B0044
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:49 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1702797eek.30
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si40622686eew.78.2014.04.18.07.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:48 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/16] mm: page_alloc: Take the ALLOC_NO_WATERMARK check out of the fast path
Date: Fri, 18 Apr 2014 15:50:36 +0100
Message-Id: <1397832643-14275-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

ALLOC_NO_WATERMARK is set in a few cases. Always by kswapd, always for
__GFP_MEMALLOC, sometimes for swap-over-nfs, tasks etc. Each of these cases
are relatively rare events but the ALLOC_NO_WATERMARK check is an unlikely
branch in the fast path.  This patch moves the check out of the fast path
and after it has been determined that the watermarks have not been met. This
helps the common fast path at the cost of making the slow path slower and
hitting kswapd with a performance cost. It's a reasonable tradeoff.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 770735a..737577c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1930,9 +1930,6 @@ zonelist_scan:
 			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
-		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
-			goto try_this_zone;
 		/*
 		 * Distribute pages in proportion to the individual
 		 * zone size to ensure fair page aging.  The zone a
@@ -1979,6 +1976,11 @@ zonelist_scan:
 				       classzone_idx, alloc_flags)) {
 			int ret;
 
+			/* Checked here to keep the fast path fast */
+			BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
+			if (alloc_flags & ALLOC_NO_WATERMARKS)
+				goto try_this_zone;
+
 			if (IS_ENABLED(CONFIG_NUMA) &&
 					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
