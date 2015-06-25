Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CBEEF6B0071
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:02 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so38709844pac.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:02 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id t13si42253367pdl.149.2015.06.24.17.42.54
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 03/10] mm/compaction: always update cached pfn
Date: Thu, 25 Jun 2015 09:45:14 +0900
Message-Id: <1435193121-25880-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9c5d43c..2d8e211 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -510,6 +510,10 @@ isolate_fail:
 	if (locked)
 		spin_unlock_irqrestore(&cc->zone->lock, flags);
 
+	if (blockpfn == end_pfn &&
+		blockpfn > cc->zone->compact_cached_free_pfn)
+		cc->zone->compact_cached_free_pfn = blockpfn;
+
 	update_pageblock_skip(cc, valid_page, total_isolated,
 			*start_pfn, end_pfn, blockpfn, false);
 
@@ -811,6 +815,13 @@ isolate_success:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	if (low_pfn == end_pfn && cc->mode != MIGRATE_ASYNC) {
+		int sync = cc->mode != MIGRATE_ASYNC;
+
+		if (low_pfn > zone->compact_cached_migrate_pfn[sync])
+			zone->compact_cached_migrate_pfn[sync] = low_pfn;
+	}
+
 	update_pageblock_skip(cc, valid_page, nr_isolated,
 			start_pfn, end_pfn, low_pfn, true);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
