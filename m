Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 372AE6B0264
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:13:04 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id a140so47115785wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:13:04 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id iw2si33530754wjb.101.2016.04.12.03.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:13:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id C182C98FD4
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:13:02 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 06/24] mm, page_alloc: Use __dec_zone_state for order-0 page allocation
Date: Tue, 12 Apr 2016 11:12:07 +0100
Message-Id: <1460455945-29644-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

__dec_zone_state is cheaper to use for removing an order-0 page as it
has fewer conditions to check.

The performance difference on a page allocator microbenchmark is;

                                           4.6.0-rc2                  4.6.0-rc2
                                       optiter-v1r20              decstat-v1r20
Min      alloc-odr0-1               382.00 (  0.00%)           381.00 (  0.26%)
Min      alloc-odr0-2               282.00 (  0.00%)           275.00 (  2.48%)
Min      alloc-odr0-4               233.00 (  0.00%)           229.00 (  1.72%)
Min      alloc-odr0-8               203.00 (  0.00%)           199.00 (  1.97%)
Min      alloc-odr0-16              188.00 (  0.00%)           186.00 (  1.06%)
Min      alloc-odr0-32              182.00 (  0.00%)           179.00 (  1.65%)
Min      alloc-odr0-64              177.00 (  0.00%)           174.00 (  1.69%)
Min      alloc-odr0-128             175.00 (  0.00%)           172.00 (  1.71%)
Min      alloc-odr0-256             184.00 (  0.00%)           181.00 (  1.63%)
Min      alloc-odr0-512             197.00 (  0.00%)           193.00 (  2.03%)
Min      alloc-odr0-1024            203.00 (  0.00%)           201.00 (  0.99%)
Min      alloc-odr0-2048            209.00 (  0.00%)           206.00 (  1.44%)
Min      alloc-odr0-4096            214.00 (  0.00%)           212.00 (  0.93%)
Min      alloc-odr0-8192            218.00 (  0.00%)           215.00 (  1.38%)
Min      alloc-odr0-16384           219.00 (  0.00%)           216.00 (  1.37%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e9acc0b0f787..ab16560b76e6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2414,6 +2414,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		else
 			page = list_first_entry(list, struct page, lru);
 
+		__dec_zone_state(zone, NR_ALLOC_BATCH);
 		list_del(&page->lru);
 		pcp->count--;
 	} else {
@@ -2435,11 +2436,11 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
+		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 		__mod_zone_freepage_state(zone, -(1 << order),
 					  get_pcppage_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
 	    !test_bit(ZONE_FAIR_DEPLETED, &zone->flags))
 		set_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
