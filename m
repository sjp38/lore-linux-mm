Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5336B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 04:51:50 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so4623110pad.41
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 01:51:50 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id sw1si17143149pab.131.2014.06.22.01.51.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 22 Jun 2014 01:51:49 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so4662717pad.10
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 01:51:49 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm:vmscan:replace zone_watermark_ok with zone_balanced for determining if kswapd will call compaction
Date: Sun, 22 Jun 2014 16:51:00 +0800
Message-Id: <1403427060-16711-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

According to the commit messages of "mm: vmscan: fix endless loop in kswapd balancing"
and "mm: vmscan: decide whether to compact the pgdat based on reclaim progress", minor
change is required to the following snippet.

        /*
         * If any zone is currently balanced then kswapd will
         * not call compaction as it is expected that the
         * necessary pages are already available.
         */
        if (pgdat_needs_compaction &&
                zone_watermark_ok(zone, order,
                                        low_wmark_pages(zone),
                                        *classzone_idx, 0))
                pgdat_needs_compaction = false;

zone_watermark_ok() should be replaced by zone_balanced() in the above snippet. That's
because zone_balanced() is more suitable for the context.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..e1004ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3157,9 +3157,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * necessary pages are already available.
 			 */
 			if (pgdat_needs_compaction &&
-					zone_watermark_ok(zone, order,
-						low_wmark_pages(zone),
-						*classzone_idx, 0))
+					zone_balanced(zone, order, 0,
+						*classzone_idx))
 				pgdat_needs_compaction = false;
 		}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
