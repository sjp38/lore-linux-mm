Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA5266B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:20:32 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id v188so19158074wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:20:32 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id y9si2670484wje.220.2016.04.06.04.20.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:20:31 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 33B9A98EE6
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:20:31 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/27] mm, page_alloc: Use ac->classzone_idx instead of zone_idx(preferred_zone)
Date: Wed,  6 Apr 2016 12:20:00 +0100
Message-Id: <1459941626-3290-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

ac->classzone_idx is determined by the index of the preferred zone and cached
to avoid repeated calculations. wake_all_kswapds() should use it instead of
using zone_idx() within a loop.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..2643d10dee98 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3049,7 +3049,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
+		wakeup_kswapd(zone, order, ac->classzone_idx);
 }
 
 static inline int
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
