Date: Fri, 1 Jun 2007 13:13:17 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] slab: Fix slab debug for non alien caches.
Message-ID: <20070601041317.GA8490@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently when slab debugging is enabled, the WARN_ON() nodeid checks
trigger if we boot with 'noaliencache'. In the noaliencache case the
WARN_ON()'s seem to be superfluous, so only bother doing the nodeid
comparison if use_alien_caches is set.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2e71a32..88db26b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2663,7 +2663,7 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
 	next = slab_bufctl(slabp)[slabp->free];
 #if DEBUG
 	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-	WARN_ON(slabp->nodeid != nodeid);
+	WARN_ON(use_alien_caches && slabp->nodeid != nodeid);
 #endif
 	slabp->free = next;
 
@@ -2677,7 +2677,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 
 #if DEBUG
 	/* Verify that the slab belongs to the intended node */
-	WARN_ON(slabp->nodeid != nodeid);
+	WARN_ON(use_alien_caches && slabp->nodeid != nodeid);
 
 	if (slab_bufctl(slabp)[objnr] + 1 <= SLAB_LIMIT + 1) {
 		printk(KERN_ERR "slab: double free detected in cache "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
