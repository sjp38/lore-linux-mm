Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7E517900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:34 -0400 (EDT)
Received: by wifx6 with SMTP id x6so87848601wif.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kv9si5292968wjb.151.2015.06.08.06.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 24/25] mm, page_alloc: Use ac->classzone_idx instead of zone_idx(preferred_zone)
Date: Mon,  8 Jun 2015 14:56:30 +0100
Message-Id: <1433771791-30567-25-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

ac->classzone_idx is determined by the index of the preferred zone and cached
to avoid repeated calculations. wake_all_kswapds() should use it instead of
using zone_idx() within a loop.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4108743eb801..886102cc9b09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2307,7 +2307,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
+		wakeup_kswapd(zone, order, ac->classzone_idx);
 }
 
 static inline int
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
