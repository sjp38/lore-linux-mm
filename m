Message-Id: <20070525051947.529560112@sgi.com>
References: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:20 -0700
From: clameter@sgi.com
Subject: [patch 4/6] compound pages: Use new compound vmstat functions in SLUB
Content-Disposition: inline; filename=compound_vmstat_slub
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Use the new dec/inc functions to simplify SLUB's accounting
of pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-24 20:54:31.000000000 -0700
+++ slub/mm/slub.c	2007-05-24 21:03:45.000000000 -0700
@@ -965,7 +965,6 @@ static inline void kmem_cache_open_debug
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page * page;
-	int pages = 1 << s->order;
 
 	if (s->order)
 		flags |= __GFP_COMP;
@@ -984,10 +983,9 @@ static struct page *allocate_slab(struct
 	if (!page)
 		return NULL;
 
-	mod_zone_page_state(page_zone(page),
+	inc_zone_page_state(page,
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		pages);
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE);
 
 	return page;
 }
@@ -1054,8 +1052,6 @@ out:
 
 static void __free_slab(struct kmem_cache *s, struct page *page)
 {
-	int pages = 1 << s->order;
-
 	if (unlikely(SlabDebug(page))) {
 		void *p;
 
@@ -1064,10 +1060,9 @@ static void __free_slab(struct kmem_cach
 			check_object(s, page, p, 0);
 	}
 
-	mod_zone_page_state(page_zone(page),
+	dec_zone_page_state(page,
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		- pages);
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE);
 
 	page->mapping = NULL;
 	__free_pages(page, s->order);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
