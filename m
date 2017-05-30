Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 284426B0314
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so20578802wmh.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x30si14148950edx.87.2017.05.30.11.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:17:54 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/6] mm: memcontrol: account slab stats per lruvec
Date: Tue, 30 May 2017 14:17:24 -0400
Message-Id: <20170530181724.27197-7-hannes@cmpxchg.org>
In-Reply-To: <20170530181724.27197-1-hannes@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Josef's redesign of the balancing between slab caches and the page
cache requires slab cache statistics at the lruvec level.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/slab.c | 12 ++++--------
 mm/slab.h | 18 +-----------------
 mm/slub.c |  4 ++--
 3 files changed, 7 insertions(+), 27 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b55853399559..908908aa8250 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1425,11 +1425,9 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		add_node_page_state(page_pgdat(page),
-			NR_SLAB_RECLAIMABLE, nr_pages);
+		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
 	else
-		add_node_page_state(page_pgdat(page),
-			NR_SLAB_UNRECLAIMABLE, nr_pages);
+		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_pages);
 
 	__SetPageSlab(page);
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
@@ -1459,11 +1457,9 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	kmemcheck_free_shadow(page, order);
 
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		sub_node_page_state(page_pgdat(page),
-				NR_SLAB_RECLAIMABLE, nr_freed);
+		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_freed);
 	else
-		sub_node_page_state(page_pgdat(page),
-				NR_SLAB_UNRECLAIMABLE, nr_freed);
+		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_freed);
 
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
diff --git a/mm/slab.h b/mm/slab.h
index 7b84e3839dfe..6885e1192ec5 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -274,22 +274,11 @@ static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
-	int ret;
-
 	if (!memcg_kmem_enabled())
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-
-	ret = memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
-	if (ret)
-		return ret;
-
-	mod_memcg_page_state(page,
-			     (s->flags & SLAB_RECLAIM_ACCOUNT) ?
-			     NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-			     1 << order);
-	return 0;
+	return memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
 }
 
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
@@ -297,11 +286,6 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 {
 	if (!memcg_kmem_enabled())
 		return;
-
-	mod_memcg_page_state(page,
-			     (s->flags & SLAB_RECLAIM_ACCOUNT) ?
-			     NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-			     -(1 << order));
 	memcg_kmem_uncharge(page, order);
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 673e72698d9b..edaf102284e8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1615,7 +1615,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_node_page_state(page_pgdat(page),
+	mod_lruvec_page_state(page,
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		1 << oo_order(oo));
@@ -1655,7 +1655,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	kmemcheck_free_shadow(page, compound_order(page));
 
-	mod_node_page_state(page_pgdat(page),
+	mod_lruvec_page_state(page,
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
