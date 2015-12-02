Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 923886B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:09:01 -0500 (EST)
Received: by wmuu63 with SMTP id u63so218858193wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:09:01 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id t206si43609704wmt.109.2015.12.02.07.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 07:09:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 3038C1C1B29
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 15:09:00 +0000 (GMT)
Date: Wed, 2 Dec 2015 15:08:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: page_alloc: Remove unnecessary parameter from __rmqueue
Message-ID: <20151202150858.GD2015@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Commit 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for high-order
atomic allocations on demand") added an unnecessary and unused parameter
to __rmqueue. It was a parameter that was used in an earlier version of
the patch and then left behind. This patch cleans it up.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a3c66639a9..3f9918616777 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1788,7 +1788,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-				int migratetype, gfp_t gfp_flags)
+				int migratetype)
 {
 	struct page *page;
 
@@ -1818,7 +1818,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype, 0);
+		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2241,7 +2241,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				trace_mm_page_alloc_zone_locked(page, order, migratetype);
 		}
 		if (!page)
-			page = __rmqueue(zone, order, migratetype, gfp_flags);
+			page = __rmqueue(zone, order, migratetype);
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
