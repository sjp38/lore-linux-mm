Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B62F96B0267
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:45:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e2so17432903pfc.7
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id o78si6981105pfa.62.2016.10.06.22.45.39
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/4] mm: prevent double decrease of nr_reserved_highatomic
Date: Fri,  7 Oct 2016 14:45:34 +0900
Message-Id: <1475819136-24358-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1475819136-24358-1-git-send-email-minchan@kernel.org>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

There is race between page freeing and unreserved highatomic.

 CPU 0				    CPU 1

    free_hot_cold_page
      mt = get_pfnblock_migratetype
      set_pcppage_migratetype(page, mt)
    				    unreserve_highatomic_pageblock
    				    spin_lock_irqsave(&zone->lock)
    				    move_freepages_block
    				    set_pageblock_migratetype(page)
    				    spin_unlock_irqrestore(&zone->lock)
      free_pcppages_bulk
        __free_one_page(mt) <- mt is stale

By above race, a page on CPU 0 could go non-highorderatomic free list
since the pageblock's type is changed. By that, unreserve logic of
highorderatomic can decrease reserved count on a same pageblock
several times and then it will make mismatch between
nr_reserved_highatomic and the number of reserved pageblock.

So, this patch verifies whether the pageblock is highatomic or not
and decrease the count only if the pageblock is highatomic.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e7cbb3cc22fa..d110cd640264 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2133,13 +2133,25 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 				continue;
 
 			/*
-			 * It should never happen but changes to locking could
-			 * inadvertently allow a per-cpu drain to add pages
-			 * to MIGRATE_HIGHATOMIC while unreserving so be safe
-			 * and watch for underflows.
+			 * In page freeing path, migratetype change is racy so
+			 * we can counter several free pages in a pageblock
+			 * in this loop althoug we changed the pageblock type
+			 * from highatomic to ac->migratetype. So we should
+			 * adjust the count once.
 			 */
-			zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
-				zone->nr_reserved_highatomic);
+			if (get_pageblock_migratetype(page) ==
+							MIGRATE_HIGHATOMIC) {
+				/*
+				 * It should never happen but changes to
+				 * locking could inadvertently allow a per-cpu
+				 * drain to add pages to MIGRATE_HIGHATOMIC
+				 * while unreserving so be safe and watch for
+				 * underflows.
+				 */
+				zone->nr_reserved_highatomic -= min(
+						pageblock_nr_pages,
+						zone->nr_reserved_highatomic);
+			}
 
 			/*
 			 * Convert to ac->migratetype and avoid the normal
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
