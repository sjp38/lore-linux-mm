Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 9EECA6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 03:34:03 -0500 (EST)
From: Namhyung Kim <namhyung.kim@lge.com>
Subject: [PATCH -next] slub: set PG_slab on all of slab pages
Date: Wed, 29 Feb 2012 17:54:34 +0900
Message-Id: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Unlike SLAB, SLUB doesn't set PG_slab on tail pages, so if a user would
call free_pages() incorrectly on a object in a tail page, she will get
confused with the undefined result. Setting the flag would help her by
emitting a warning on bad_page() in such a case.

Reported-by: Sangseok Lee <sangseok.lee@lge.com>
Signed-off-by: Namhyung Kim <namhyung.kim@lge.com>
---
 mm/slub.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 33bab2aca882..575baacbec9b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1287,6 +1287,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
+	int i;
 
 	flags &= gfp_allowed_mask;
 
@@ -1320,6 +1321,9 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
+	for (i = 0; i < 1 << oo_order(oo); i++)
+		__SetPageSlab(page + i);
+
 	if (kmemcheck_enabled
 		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
@@ -1369,7 +1373,6 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
-	page->flags |= 1 << PG_slab;
 
 	start = page_address(page);
 
@@ -1396,6 +1399,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 {
 	int order = compound_order(page);
 	int pages = 1 << order;
+	int i;
 
 	if (kmem_cache_debug(s)) {
 		void *p;
@@ -1413,7 +1417,11 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
-	__ClearPageSlab(page);
+	for (i = 0; i < pages; i++) {
+		BUG_ON(!PageSlab(page + i));
+		__ClearPageSlab(page + i);
+	}
+
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
