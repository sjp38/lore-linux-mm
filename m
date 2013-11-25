Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABF86B00BD
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:26:53 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so1989021bkz.5
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 06:26:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id yf5si9620845bkb.89.2013.11.25.06.26.52
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 06:26:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/5] mm: compaction: do not mark unmovable pageblocks as skipped in async compaction
Date: Mon, 25 Nov 2013 15:26:09 +0100
Message-Id: <1385389570-11393-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Compaction temporarily marks pageblocks where it fails to isolate pages as
to-be-skipped in further compactions, in order to improve efficiency. One of
the reasons to fail isolating pages is that isolation is not attempted in
pageblocks that are not of MIGRATE_MOVABLE (or CMA) type.

The problem is that blocks skipped due to not being MIGRATE_MOVABLE in async
compaction become skipped due to the temporary mark also in future sync
compaction. Moreover, this may follow quite soon during __alloc_page_slowpath,
without much time for kswapd to clear the pageblock skip marks. This goes
against the idea that sync compaction should try to scan these blocks more
thoroughly than the async compaction.

The fix is to ensure in async compaction that these !MIGRATE_MOVABLE blocks are
not marked to be skipped. Note this should not affect performance or locking
impact of further async compactions, as skipping a block due to being
!MIGRATE_MOVABLE is done soon after skipping a block marked to be skipped, both
without locking.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0702bdf..f481193 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -455,6 +455,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long flags;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
+	bool skipped_unmovable = false;
+
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -530,6 +532,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			cc->finished_update_migrate = true;
+			skipped_unmovable = true;
 			goto next_pageblock;
 		}
 
@@ -624,7 +627,7 @@ next_pageblock:
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
-	if (low_pfn == end_pfn)
+	if (low_pfn == end_pfn && !skipped_unmovable)
 		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
