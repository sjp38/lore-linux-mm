Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id CD62D6B0038
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 09:15:49 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id p10so679009wes.2
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 06:15:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bl1si17094990wjb.144.2014.09.09.06.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 06:15:48 -0700 (PDT)
Date: Tue, 9 Sep 2014 09:15:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch resend] mm: page_alloc: fix zone allocation fairness on UP
Message-ID: <20140909131540.GA10568@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The zone allocation batches can easily underflow due to higher-order
allocations or spills to remote nodes.  On SMP that's fine, because
underflows are expected from concurrency and dealt with by returning
0.  But on UP, zone_page_state will just return a wrapped unsigned
long, which will get past the <= 0 check and then consider the zone
eligible until its watermarks are hit.

3a025760fc15 ("mm: page_alloc: spill to remote nodes before waking
kswapd") already made the counter-resetting use atomic_long_read() to
accomodate underflows from remote spills, but it didn't go all the way
with it.  Make it clear that these batches are expected to go negative
regardless of concurrency, and use atomic_long_read() everywhere.

Fixes: 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Leon Romanovsky <leon@leon.nu>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: "3.12+" <stable@kernel.org>
---
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Sorry I forgot to CC you, Leon.  Resend with updated Tags.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d4c8a2..eee961958021 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1612,7 +1612,7 @@ again:
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
+	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
 	    !zone_is_fair_depleted(zone))
 		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
 
@@ -5701,9 +5701,8 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
 		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-				      high_wmark_pages(zone) -
-				      low_wmark_pages(zone) -
-				      zone_page_state(zone, NR_ALLOC_BATCH));
+			high_wmark_pages(zone) - low_wmark_pages(zone) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
 
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
