Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2072F6B02FD
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 21:11:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m68so11778729pfj.11
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:11:30 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 9si279777pld.127.2017.08.27.18.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 18:11:29 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id q16so5177459pgc.0
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:11:29 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/2] mm/slub: don't use reserved highatomic pageblock for optimistic try
Date: Mon, 28 Aug 2017 10:11:15 +0900
Message-Id: <1503882675-17910-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

High-order atomic allocation is difficult to succeed since we cannot
reclaim anything in this context. So, we reserves the pageblock for
this kind of request.

In slub, we try to allocate higher-order page more than it actually
needs in order to get the best performance. If this optimistic try is
used with GFP_ATOMIC, alloc_flags will be set as ALLOC_HARDER and
the pageblock reserved for high-order atomic allocation would be used.
Moreover, this request would reserve the MIGRATE_HIGHATOMIC pageblock
,if succeed, to prepare further request. It would not be good to use
MIGRATE_HIGHATOMIC pageblock in terms of fragmentation management
since it unconditionally set a migratetype to request's migratetype
when unreserving the pageblock without considering the migratetype of
used pages in the pageblock.

This is not what we don't intend so fix it by unconditionally setting
__GFP_NOMEMALLOC in order to not set ALLOC_HARDER.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e1e442c..fd8dd89 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1579,10 +1579,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 	if (oo_order(oo) > oo_order(s->min)) {
-		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
-			alloc_gfp |= __GFP_NOMEMALLOC;
-			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
-		}
+		alloc_gfp |= __GFP_NOMEMALLOC;
+		alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
 	}
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
