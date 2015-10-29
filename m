Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF0F82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:17:37 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so45684260wic.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:17:36 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id ef7si2652265wjd.49.2015.10.29.08.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 08:17:34 -0700 (PDT)
Received: by wijp11 with SMTP id p11so290315237wij.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:17:34 -0700 (PDT)
From: mhocko@kernel.org
Subject: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order allocations
Date: Thu, 29 Oct 2015 16:17:15 +0100
Message-Id: <1446131835-3263-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_slowpath retries costly allocations until at least
order worth of pages were reclaimed or the watermark check for at least
one zone would succeed after all reclaiming all pages if the reclaim
hasn't made any progress.

The first condition was added by a41f24ea9fd6 ("page allocator: smarter
retry of costly-order allocations) and it assumed that lumpy reclaim
could have created a page of the sufficient order. Lumpy reclaim,
has been removed quite some time ago so the assumption doesn't hold
anymore. It would be more appropriate to check the compaction progress
instead but this patch simply removes the check and relies solely
on the watermark check.

To prevent from too many retries the stall_backoff is not reseted after
a reclaim which made progress because we cannot assume it helped high
order situation.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0518ca6a9776..0dc1ca9b1219 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2986,7 +2986,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
 	int alloc_flags;
-	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
@@ -3145,25 +3144,19 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;
 
-	/*
-	 * Do not retry high order allocations unless they are __GFP_REPEAT
-	 * and even then do not retry endlessly.
-	 */
-	pages_reclaimed += did_some_progress;
-	if (order > PAGE_ALLOC_COSTLY_ORDER) {
-		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
-			goto noretry;
-
-		if (did_some_progress)
-			goto retry;
-	}
+	/* Do not retry high order allocations unless they are __GFP_REPEAT */
+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+		goto noretry;
 
 	/*
 	 * Be optimistic and consider all pages on reclaimable LRUs as usable
 	 * but make sure we converge to OOM if we cannot make any progress after
 	 * multiple consecutive failed attempts.
+	 * Costly __GFP_REPEAT allocations might have made a progress but this
+	 * doesn't mean their order will become available due to high fragmentation
+	 * so do not reset the backoff for them
 	 */
-	if (did_some_progress)
+	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
 		stall_backoff = 0;
 	else
 		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
