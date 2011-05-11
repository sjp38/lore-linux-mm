Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD586B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 11:29:44 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] mm: slub: Do not take expensive steps for SLUBs speculative high-order allocations
Date: Wed, 11 May 2011 16:29:32 +0100
Message-Id: <1305127773-10570-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1305127773-10570-1-git-send-email-mgorman@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

To avoid locking and per-cpu overhead, SLUB optimisically uses
high-order allocations and falls back to lower allocations if they
fail. However, by simply trying to allocate, the caller can enter
compaction or reclaim - both of which are likely to cost more than the
benefit of using high-order pages in SLUB. On a desktop system, two
users report that the system is getting stalled with kswapd using large
amounts of CPU.

This patch prevents SLUB taking any expensive steps when trying to
use high-order allocations. Instead, it is expected to fall back to
smaller orders more aggressively. Testing from users was somewhat
inconclusive on how much this helped but local tests showed it made
a positive difference. It makes sense that falling back to order-0
allocations is faster than entering compaction or direct reclaim.

Signed-off-yet: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    3 ++-
 mm/slub.c       |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f8a97b..057f1e2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1972,6 +1972,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	const gfp_t can_wake_kswapd = !(gfp_mask & __GFP_NO_KSWAPD);
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
 	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
@@ -1984,7 +1985,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 */
 	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
 
-	if (!wait) {
+	if (!wait && can_wake_kswapd) {
 		/*
 		 * Not worth trying to allocate harder for
 		 * __GFP_NOMEMALLOC even if it can't schedule.
diff --git a/mm/slub.c b/mm/slub.c
index 98c358d..1071723 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1170,7 +1170,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * Let the initial higher-order allocation fail under memory pressure
 	 * so we fall-back to the minimum order allocation.
 	 */
-	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;
+	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) &
+			~(__GFP_NOFAIL | __GFP_WAIT);
 
 	page = alloc_slab_page(alloc_gfp, node, oo);
 	if (unlikely(!page)) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
