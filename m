Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60F846B0267
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:08:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a140so13220402wma.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:08:59 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id b4si39045744wmc.89.2016.04.15.02.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:08:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 70D951C1B3D
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:08:57 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/28] mm, page_alloc: Shorten the page allocator fast path
Date: Fri, 15 Apr 2016 10:07:45 +0100
Message-Id: <1460711275-1130-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The page allocator fast path checks page multiple times unnecessarily.
This patch avoids all the slowpath checks if the first allocation attempt
succeeds.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 835a1c434832..7a5f6ff4ea06 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3392,22 +3392,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
-	if (unlikely(!page)) {
-		/*
-		 * Runtime PM, block IO and its error handling path
-		 * can deadlock because I/O on the device might not
-		 * complete.
-		 */
-		alloc_mask = memalloc_noio_flags(gfp_mask);
-		ac.spread_dirty_pages = false;
-
-		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
-	}
+	if (likely(page))
+		goto out;
 
-	if (kmemcheck_enabled && page)
-		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
+	/*
+	 * Runtime PM, block IO and its error handling path can deadlock
+	 * because I/O on the device might not complete.
+	 */
+	alloc_mask = memalloc_noio_flags(gfp_mask);
+	ac.spread_dirty_pages = false;
 
-	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
+	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
 	/*
 	 * When updating a task's mems_allowed, it is possible to race with
@@ -3420,6 +3415,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		goto retry_cpuset;
 	}
 
+out:
+	if (kmemcheck_enabled && page)
+		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
+
+	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
