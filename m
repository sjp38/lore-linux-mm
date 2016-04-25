Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8FCA6B0261
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:36:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so97744056lfg.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:36:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a194si19370012wma.76.2016.04.25.06.35.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 06:35:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4.6 1/3] mm, cma: prevent nr_isolated_* counters from going negative
Date: Mon, 25 Apr 2016 15:35:48 +0200
Message-Id: <1461591350-28700-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1461591350-28700-1-git-send-email-vbabka@suse.cz>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

From: Hugh Dickins <hughd@google.com>

/proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
go increasingly negative under compaction: which would add delay when
should be none, or no delay when should delay. The bug in compaction was
due to a recent mmotm patch, but much older instance of the bug was also
noticed in isolate_migratepages_range() which is used for CMA and
gigantic hugepage allocations.

The bug is caused by putback_movable_pages() in an error path decrementing
the isolated counters without them being previously incremented by
acct_isolated(). Fix isolate_migratepages_range() by removing the error-path
putback, thus reaching acct_isolated() with migratepages still isolated, and
leaving putback to caller like most other places do.

[vbabka@suse.cz: expanded the changelog]
Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
Cc: stable@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 2427fe547a20..759c3ac73ced 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -924,16 +924,8 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
 							ISOLATE_UNEVICTABLE);
 
-		/*
-		 * In case of fatal failure, release everything that might
-		 * have been isolated in the previous iteration, and signal
-		 * the failure back to caller.
-		 */
-		if (!pfn) {
-			putback_movable_pages(&cc->migratepages);
-			cc->nr_migratepages = 0;
+		if (!pfn)
 			break;
-		}
 
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
 			break;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
