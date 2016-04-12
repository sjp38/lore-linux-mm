Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A14186B0277
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:26:31 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so181232721wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:26:31 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 71si23137077wme.57.2016.04.12.03.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:26:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 59A391C22AA
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:26:30 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/28] mm, page_alloc: Use ac->classzone_idx instead of zone_idx(preferred_zone)
Date: Tue, 12 Apr 2016 11:25:56 +0100
Message-Id: <1460456783-30996-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
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
index 4d4079309760..e551f697bc68 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3139,7 +3139,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zonelist_zone_idx(ac->preferred_zoneref));
+		wakeup_kswapd(zone, order, ac->classzone_idx);
 }
 
 static inline unsigned int
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
