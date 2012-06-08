Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4D7456B0073
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 05:47:09 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 3/4] don't do __ClearPageSlab before freeing slab page.
Date: Fri,  8 Jun 2012 13:43:20 +0400
Message-Id: <1339148601-20096-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1339148601-20096-1-git-send-email-glommer@parallels.com>
References: <1339148601-20096-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbeck@gmail.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

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
index 918330f..a884a9c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -697,8 +697,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	for (i = 0; i < (1 << order); i++)
+	for (i = 0; i < (1 << order); i++) {
+		__ClearPageSlab(page + i);
 		bad += free_pages_check(page + i);
+	}
 	if (bad)
 		return false;
 
@@ -2505,6 +2507,7 @@ EXPORT_SYMBOL(get_zeroed_page);
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
+		__ClearPageSlab(page);
 		if (order == 0)
 			free_hot_cold_page(page, 0);
 		else
diff --git a/mm/slab.c b/mm/slab.c
index d7dfd26..66ef370 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1794,11 +1794,6 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
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
index 61b1845..b03d65e 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -360,7 +360,6 @@ static void slob_free(void *block, int size)
 		if (slob_page_free(sp))
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
-		__ClearPageSlab(sp);
 		reset_page_mapcount(sp);
 		slob_free_pages(b, 0);
 		return;
diff --git a/mm/slub.c b/mm/slub.c
index ed01be5..a0eeb4a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1399,7 +1399,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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
