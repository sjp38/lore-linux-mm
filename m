Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5124A6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 12:34:01 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so1096371wiv.16
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 09:33:59 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id uy7si11763958wjc.123.2014.06.20.09.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 09:33:58 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] mm: vmscan: remove remains of kswapd-managed zone->all_unreclaimable
Date: Fri, 20 Jun 2014 12:33:47 -0400
Message-Id: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

shrink_zones() has a special branch to skip the all_unreclaimable()
check during hibernation, because a frozen kswapd can't mark a zone
unreclaimable.

But ever since 6e543d5780e3 ("mm: vmscan: fix do_try_to_free_pages()
livelock"), determining a zone to be unreclaimable is done by directly
looking at its scan history and no longer relies on kswapd setting the
per-zone flag.

Remove this branch and let shrink_zones() check the reclaimability of
the target zones regardless of hibernation state.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe8eb67..19b5b8016209 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2534,14 +2534,6 @@ out:
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
 
-	/*
-	 * As hibernation is going on, kswapd is freezed so that it can't mark
-	 * the zone into all_unreclaimable. Thus bypassing all_unreclaimable
-	 * check.
-	 */
-	if (oom_killer_disabled)
-		return 0;
-
 	/* Aborted reclaim to try compaction? don't OOM, then */
 	if (aborted_reclaim)
 		return 1;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
