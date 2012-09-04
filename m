Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3ED056B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 13:24:44 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] slab: do ClearSlabPfmemalloc() for all pages of slab
Date: Tue,  4 Sep 2012 18:24:36 +0100
Message-Id: <1346779479-1097-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1346779479-1097-1-git-send-email-mgorman@suse.de>
References: <1346779479-1097-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Chuck Lever <chuck.lever@oracle.com>, Joonsoo Kim <js1304@gmail.com>, Pekka@suse.de, "Enberg <penberg"@kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>

Right now, we call ClearSlabPfmemalloc() for first page of slab when we
clear SlabPfmemalloc flag. This is fine for most swap-over-network use
cases as it is expected that order-0 pages are in use. Unfortunately it
is possible that that __ac_put_obj() checks SlabPfmemalloc on a tail page
and while this is harmless, it is sloppy. This patch ensures that the head
page is always used.

This problem was originally identified by Joonsoo Kim.

[js1304@gmail.com: Original implementation and problem identification]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 811af03..d34a903 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1000,7 +1000,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		l3 = cachep->nodelists[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
-			ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
+			ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
 			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
 			return objp;
@@ -1032,7 +1032,7 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 {
 	if (unlikely(pfmemalloc_active)) {
 		/* Some pfmemalloc slabs exist, check if this is one */
-		struct page *page = virt_to_page(objp);
+		struct page *page = virt_to_head_page(objp);
 		if (PageSlabPfmemalloc(page))
 			set_obj_pfmemalloc(&objp);
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
