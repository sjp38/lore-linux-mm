Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F528280407
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 00:38:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q76so10744291pfq.5
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 21:38:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g34sor279110pld.114.2017.09.05.21.38.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Sep 2017 21:38:01 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/2] mm/slub: don't use reserved memory for optimistic try
Date: Wed,  6 Sep 2017 13:37:46 +0900
Message-Id: <1504672666-19682-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

This is not what we don't intend so fix it by unconditionally masking
out __GFP_ATOMIC in order to not set ALLOC_HARDER.

And, it is also undesirable to use reserved memory for optimistic try
so mask out __GFP_HIGH. This patch also adds __GFP_NOMEMALLOC since
we don't want to use the reserved memory for optimistic try even if
the user has PF_MEMALLOC flag.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/gfp.h | 1 +
 mm/page_alloc.c     | 8 ++++++++
 mm/slub.c           | 6 ++----
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f780718..1f5658e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -568,6 +568,7 @@ extern gfp_t gfp_allowed_mask;
 
 /* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
+gfp_t gfp_drop_reserves(gfp_t gfp_mask);
 
 extern void pm_restrict_gfp_mask(void);
 extern void pm_restore_gfp_mask(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6dbc49e..0f34356 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3720,6 +3720,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return !!__gfp_pfmemalloc_flags(gfp_mask);
 }
 
+gfp_t gfp_drop_reserves(gfp_t gfp_mask)
+{
+	gfp_mask &= ~(__GFP_HIGH | __GFP_ATOMIC);
+	gfp_mask |= __GFP_NOMEMALLOC;
+
+	return gfp_mask;
+}
+
 /*
  * Checks whether it makes sense to retry the reclaim to make a forward progress
  * for the given allocation request.
diff --git a/mm/slub.c b/mm/slub.c
index 45f4a4b..3d75d30 100644
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
+		alloc_gfp = gfp_drop_reserves(alloc_gfp);
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
