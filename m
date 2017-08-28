Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 327B36B02FA
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 21:11:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c28so11751466pfe.4
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:11:27 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id m14si8707686pgd.185.2017.08.27.18.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 18:11:26 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id g13so3080351pfm.2
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:11:25 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/2] mm/slub: wake up kswapd for initial high order allocation
Date: Mon, 28 Aug 2017 10:11:14 +0900
Message-Id: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

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

Note that this patch does some clean up, too.
__GFP_NOFAIL is cleared twice so remove one.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 0dc7397..e1e442c 100644
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
