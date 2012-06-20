Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E69666B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 17:03:19 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
Date: Thu, 21 Jun 2012 00:59:19 +0400
Message-Id: <1340225959-1966-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1340225959-1966-1-git-send-email-glommer@parallels.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

This will give the oportunity to the page allocator to
determine that a given page was previously a slab page, and
take action accordingly.

If memcg kmem is present, this means that that page needs to
be unaccounted. The page allocator will now have the responsibility
to clear that bit upon free_pages().

It is not uncommon to have the page allocator to check page flags.
Mlock flag, for instance, is checked pervasively all over the place.
So I hope this is okay for the slab as well.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 mm/page_alloc.c |    5 ++++-
 mm/slab.c       |    5 -----
 mm/slob.c       |    1 -
 mm/slub.c       |    1 -
 4 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6092f33..fdec73e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -698,8 +698,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	for (i = 0; i < (1 << order); i++)
+	for (i = 0; i < (1 << order); i++) {
+		__ClearPageSlab(page + i);
 		bad += free_pages_check(page + i);
+	}
 	if (bad)
 		return false;
 
@@ -2561,6 +2563,7 @@ EXPORT_SYMBOL(get_zeroed_page);
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
+		__ClearPageSlab(page);
 		if (order == 0)
 			free_hot_cold_page(page, 0);
 		else
diff --git a/mm/slab.c b/mm/slab.c
index cb6da05..3e578fc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1821,11 +1821,6 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	else
 		sub_zone_page_state(page_zone(page),
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
-	while (i--) {
-		BUG_ON(!PageSlab(page));
-		__ClearPageSlab(page);
-		page++;
-	}
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
diff --git a/mm/slob.c b/mm/slob.c
index 95d1c7d..48b9a79 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -359,7 +359,6 @@ static void slob_free(void *block, int size)
 		if (slob_page_free(sp))
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
-		__ClearPageSlab(sp);
 		reset_page_mapcount(sp);
 		slob_free_pages(b, 0);
 		return;
diff --git a/mm/slub.c b/mm/slub.c
index f96d8bc..b0ac04a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1413,7 +1413,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
-	__ClearPageSlab(page);
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
