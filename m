Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCF26B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:19 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so201692387wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:19 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id m26si39671733wmh.101.2016.02.23.05.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:17 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id E94E21C18DB
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:16 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/27] mm, page_alloc: Use ac->classzone_idx instead of zone_idx(preferred_zone)
Date: Tue, 23 Feb 2016 13:44:50 +0000
Message-Id: <1456235116-32385-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

ac->classzone_idx is determined by the index of the preferred zone and cached
to avoid repeated calculations. wake_all_kswapds() should use it instead of
using zone_idx() within a loop.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c849a202b6f1..46ecbfa5b228 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3022,7 +3022,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
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
