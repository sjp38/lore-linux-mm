Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 935DB6B0266
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:41:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so109919606lfi.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:41:34 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w128si13632703wmw.47.2016.07.18.01.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 01:41:32 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so11572903wmg.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:41:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mempool: do not consume memory reserves from the reclaim path
Date: Mon, 18 Jul 2016 10:41:24 +0200
Message-Id: <1468831285-27242-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

There has been a report about OOM killer invoked when swapping out to
a dm-crypt device. The primary reason seems to be that the swapout
out IO managed to completely deplete memory reserves. Mikulas was
able to bisect and explained the issue by pointing to f9054c70d28b
("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements").

The reason is that the swapout path is not throttled properly because
the md-raid layer needs to allocate from the generic_make_request path
which means it allocates from the PF_MEMALLOC context. dm layer uses
mempool_alloc in order to guarantee a forward progress which used to
inhibit access to memory reserves when using page allocator. This has
changed by f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if
there are free elements") which has dropped the __GFP_NOMEMALLOC
protection when the memory pool is depleted.

If we are running out of memory and the only way forward to free memory
is to perform swapout we just keep consuming memory reserves rather than
throttling the mempool allocations and allowing the pending IO to
complete up to a moment when the memory is depleted completely and there
is no way forward but invoking the OOM killer. This is less than
optimal.

The original intention of f9054c70d28b was to help with the OOM
situations where the oom victim depends on mempool allocation to make a
forward progress. We can handle that case in a different way, though. We
can check whether the current task has access to memory reserves ad an
OOM victim (TIF_MEMDIE) and drop __GFP_NOMEMALLOC protection if the pool
is empty.

David Rientjes was objecting that such an approach wouldn't help if the
oom victim was blocked on a lock held by process doing mempool_alloc. This
is very similar to other oom deadlock situations and we have oom_reaper
to deal with them so it is reasonable to rely on the same mechanism
rather inventing a different one which has negative side effects.

Fixes: f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements")
Bisected-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mempool.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 8f65464da5de..ea26d75c8adf 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -322,20 +322,20 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
+	gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
 	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
 	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
 repeat_alloc:
-	if (likely(pool->curr_nr)) {
-		/*
-		 * Don't allocate from emergency reserves if there are
-		 * elements available.  This check is racy, but it will
-		 * be rechecked each loop.
-		 */
-		gfp_temp |= __GFP_NOMEMALLOC;
-	}
+	/*
+	 * Make sure that the OOM victim will get access to memory reserves
+	 * properly if there are no objects in the pool to prevent from
+	 * livelocks.
+	 */
+	if (!likely(pool->curr_nr) && test_thread_flag(TIF_MEMDIE))
+		gfp_temp &= ~__GFP_NOMEMALLOC;
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
 	if (likely(element != NULL))
@@ -359,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	 * We use gfp mask w/o direct reclaim or IO for the first round.  If
 	 * alloc failed with that and @pool was empty, retry immediately.
 	 */
-	if ((gfp_temp & ~__GFP_NOMEMALLOC) != gfp_mask) {
+	if ((gfp_temp & __GFP_DIRECT_RECLAIM) != (gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
 		gfp_temp = gfp_mask;
 		goto repeat_alloc;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
