Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2095F828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:41:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so84355147lfl.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:41:34 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id x192si1781921wmf.62.2016.07.01.08.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:41:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 8AF611C17D3
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:41:32 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/31] mm, page_alloc: Wake kswapd based on the highest eligible zone
Date: Fri,  1 Jul 2016 16:37:36 +0100
Message-Id: <1467387466-10022-22-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The ac_classzone_idx is used as the basis for waking kswapd and that is based
on the preferred zoneref. If the preferred zoneref's highest zone is lower
than what is available on other nodes, it's possible that kswapd is woken
on a zone with only higher, but still eligible, zones. As classzone_idx
is strictly adhered to now, it causes a problem because eligible pages
are skipped.

For example, node 0 has only DMA32 and node 1 has only NORMAL. An allocating
context running on node 0 may wake kswapd on node 1 telling it to skip
all NORMAL pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2fe2fbb4f2ad..b10bee2e5968 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3415,7 +3415,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 					ac->high_zoneidx, ac->nodemask) {
 		if (last_pgdat != zone->zone_pgdat)
-			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
+			wakeup_kswapd(zone, order, ac->high_zoneidx);
 		last_pgdat = zone->zone_pgdat;
 	}
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
