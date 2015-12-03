Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 555686B0259
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:45 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so64991535pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:45 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id s79si10183717pfs.6.2015.12.02.23.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:44 -0800 (PST)
Received: by padhx2 with SMTP id hx2so63238239pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:44 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 3/7] mm/compaction: initialize compact_order_failed to MAX_ORDER
Date: Thu,  3 Dec 2015 16:11:17 +0900
Message-Id: <1449126681-19647-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If compact_order_failed is initialized to 0 and order-9
compaction is continually failed, defer counter will be updated
to activate deferring. Although other defer counters will be properly
updated, compact_order_failed will not be updated because failed order
cannot be lower than compact_order_failed, 0. In this case,
low order compaction such as 2, 3 could be deferred due to
this wrongly initialized compact_order_failed value. This patch
removes this possibility by initializing it to MAX_ORDER.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0499ff..7002c66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5273,6 +5273,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 		zone_pcp_init(zone);
+#ifdef CONFIG_COMPACTION
+		zone->compact_order_failed = MAX_ORDER;
+#endif
 
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
