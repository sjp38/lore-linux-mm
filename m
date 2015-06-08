Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id BC2EA900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:26 -0400 (EDT)
Received: by lbcue7 with SMTP id ue7so81325374lbc.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si1310553wif.77.2015.06.08.06.57.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:06 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 21/25] mm, page_alloc: Defer zlc_setup until it is known it is required
Date: Mon,  8 Jun 2015 14:56:27 +0100
Message-Id: <1433771791-30567-22-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The zonelist cache (zlc) records if zone_reclaim() is necessary but it is
setup before it is checked if zone_reclaim is even enabled.  This patch
defers the setup until after zone_reclaim is checked.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6b3a78420a5e..637b293cd5d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2076,6 +2076,10 @@ zonelist_scan:
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
 				goto try_this_zone;
 
+			if (zone_reclaim_mode == 0 ||
+			    !zone_allows_reclaim(ac->preferred_zone, zone))
+				goto this_zone_full;
+
 			if (IS_ENABLED(CONFIG_NUMA) &&
 					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
@@ -2088,10 +2092,6 @@ zonelist_scan:
 				did_zlc_setup = 1;
 			}
 
-			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(ac->preferred_zone, zone))
-				goto this_zone_full;
-
 			/*
 			 * As we may have just activated ZLC, check if the first
 			 * eligible zone has failed zone_reclaim recently.
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
