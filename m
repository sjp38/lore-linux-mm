Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBB89280407
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 00:37:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so9034443pgr.0
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 21:37:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor241912pgu.184.2017.09.05.21.37.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Sep 2017 21:37:57 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/2] mm/slub: wake up kswapd for initial high order allocation
Date: Wed,  6 Sep 2017 13:37:45 +0900
Message-Id: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

slub uses higher order allocation than it actually needs. In this case,
we don't want to do direct reclaim to make such a high order page since
it causes a big latency to the user. Instead, we would like to fallback
lower order allocation that it actually needs.

However, we also want to get this higher order page in the next time
in order to get the best performance and it would be a role of
the background thread like as kswapd and kcompactd. To wake up them,
we should not clear __GFP_KSWAPD_RECLAIM.

Unlike this intention, current code clears __GFP_KSWAPD_RECLAIM so fix it.
Current unintended code is done by Mel's commit 444eb2a449ef ("mm: thp:
set THP defrag by default to madvise and add a stall-free defrag option")
for slub part. It removes a special case in __alloc_page_slowpath()
where including __GFP_THISNODE and lacking ~__GFP_DIRECT_RECLAIM
effectively means also lacking __GFP_KSWAPD_RECLAIM. However, slub
doesn't use __GFP_THISNODE so it is not the case for this purpose. So,
partially reverting this code in slub doesn't hurt Mel's intention.

Note that this patch does some clean up, too.
__GFP_NOFAIL is cleared twice so remove one.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 163352c..45f4a4b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1578,8 +1578,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * so we fall-back to the minimum order allocation.
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
-	if ((alloc_gfp & __GFP_DIRECT_RECLAIM) && oo_order(oo) > oo_order(s->min))
-		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
+	if (oo_order(oo) > oo_order(s->min)) {
+		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
+			alloc_gfp |= __GFP_NOMEMALLOC;
+			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
+		}
+	}
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
