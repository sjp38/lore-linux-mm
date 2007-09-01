From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 14/26] SLUB: __GFP_MOVABLE and SLAB_TEMPORARY support
Date: Fri, 31 Aug 2007 18:41:21 -0700
Message-ID: <20070901014222.536517408@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0014-slab_defrag_movable.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Slabs that are reclaimable fit the definition of the objects in
ZONE_MOVABLE. So set __GFP_MOVABLE on them (this only works
on platforms where there is no HIGHMEM. Hopefully that restriction
will vanish at some point).

Also add the SLAB_TEMPORARY flag for slab caches that allocate objects with
a short lifetime. Slabs with SLAB_TEMPORARY also are allocated with
__GFP_MOVABLE. Reclaim on them works by isolating the slab for awhile and
waiting for the objects to expire.

The skbuff_head_cache is a prime example of such a slab. Add the
SLAB_TEMPORARY flag to it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h |    1 +
 mm/slub.c            |    8 +++++++-
 net/core/skbuff.c    |    2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2923861..daffc22 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -23,6 +23,7 @@
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
+#define SLAB_TEMPORARY		0x00008000UL	/* Only volatile objects */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
diff --git a/mm/slub.c b/mm/slub.c
index bad5291..85ba259 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1040,6 +1040,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (s->flags & SLAB_CACHE_DMA)
 		flags |= SLUB_DMA;
 
+#ifndef CONFIG_HIGHMEM
+	if (s->kick || s->flags & SLAB_TEMPORARY)
+		flags |= __GFP_MOVABLE;
+#endif
+
 	if (node == -1)
 		page = alloc_pages(flags, s->order);
 	else
@@ -1118,7 +1123,8 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
 		SetSlabDebug(page);
-	if (s->kick)
+
+	if (s->flags & SLAB_TEMPORARY || s->kick)
 		SetSlabReclaimable(page);
 
  out:
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 35021eb..51b2236 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2020,7 +2020,7 @@ void __init skb_init(void)
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
-					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+			      SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TEMPORARY,
 					      NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						(2*sizeof(struct sk_buff)) +
-- 
1.5.2.4

-- 
