From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] mm,page_alloc: don't call __node_reclaim() without scoped allocation constraints.
Date: Fri,  1 Sep 2017 21:40:07 +0900
Message-ID: <1504269608-9202-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

We are doing the first allocation attempt before calling
current_gfp_context(). But since slab shrinker functions might depend on
__GFP_FS and/or __GFP_IO masking, calling slab shrinker functions from
node_reclaim() from get_page_from_freelist() without calling
current_gfp_context() has possibility of deadlock. Therefore, make sure
that the first memory allocation attempt does not call slab shrinker
functions.

Well, do we want to call node_reclaim() on the first allocation attempt?

If yes, I guess this patch will not be acceptable. But what is correct
flags passed to the first allocation attempt, for currently we ignore
gfp_allowed_mask masking for the first allocation attempt?

Maybe we can tolerate not calling node_reclaim() on the first allocation
attempt, for commit 31a6c1909f51dbe9 ("mm, page_alloc: set alloc_flags
only once in slowpath") says that the fastpath is trying to avoid the
cost of setting up alloc_flags precisely which sounds to me that falling
back to slowpath if node_reclaim() is needed is acceptable?

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6dbc49e..20af138 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4189,7 +4189,8 @@ struct page *
 	finalise_ac(gfp_mask, order, &ac);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask & ~__GFP_DIRECT_RECLAIM,
+				      order, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
 
-- 
1.8.3.1
