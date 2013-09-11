Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CF9666B00A5
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 20:02:53 -0400 (EDT)
Message-ID: <1378857771.15187.4.camel@joe-AO722>
Subject: [PATCH] slab: Make allocations with GFP_ZERO slightly more efficient
From: Joe Perches <joe@perches.com>
Date: Tue, 10 Sep 2013 17:02:51 -0700
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Use the likely mechanism already around valid
pointer tests to better choose when to memset
to 0 allocations with __GFP_ZERO

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slab.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2580db0..94e7e54 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3392,11 +3392,11 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	kmemleak_alloc_recursive(ptr, cachep->object_size, 1, cachep->flags,
 				 flags);
 
-	if (likely(ptr))
+	if (likely(ptr)) {
 		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
-
-	if (unlikely((flags & __GFP_ZERO) && ptr))
-		memset(ptr, 0, cachep->object_size);
+		if (unlikely(flags & __GFP_ZERO))
+			memset(ptr, 0, cachep->object_size);
+	}
 
 	return ptr;
 }
@@ -3457,11 +3457,11 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 				 flags);
 	prefetchw(objp);
 
-	if (likely(objp))
+	if (likely(objp)) {
 		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
-
-	if (unlikely((flags & __GFP_ZERO) && objp))
-		memset(objp, 0, cachep->object_size);
+		if (unlikely(flags & __GFP_ZERO))
+			memset(objp, 0, cachep->object_size);
+	}
 
 	return objp;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
