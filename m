Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3E48D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 14:12:07 -0500 (EST)
From: Mariusz Kozlowski <mk@lab.zgora.pl>
Subject: [PATCH] slub: fix ksize() build error
Date: Sat, 26 Feb 2011 20:10:26 +0100
Message-Id: <1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
In-Reply-To: <20110225105205.5a1309bb.randy.dunlap@oracle.com>
References: <20110225105205.5a1309bb.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Eric Dumazet <eric.dumazet@gmail.com>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mariusz Kozlowski <mk@lab.zgora.pl>

mm/slub.c: In function 'ksize':
mm/slub.c:2728: error: implicit declaration of function 'slab_ksize'

slab_ksize() needs to go out of CONFIG_SLUB_DEBUG section.

Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
---
Maybe something like this? Compile tested for slub debug enabled/disabled.

 mm/slub.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 217b5b5..ea6f039 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -281,6 +281,30 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 	return (p - addr) / s->size;
 }
 
+static inline size_t slab_ksize(const struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_DEBUG
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->objsize;
+
+#endif
+	/*
+	 * If we have the need to store the freelist pointer
+	 * back there or track user information then we can
+	 * only use the space before that information.
+	 */
+	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+		return s->inuse;
+	/*
+	 * Else we can use all the padding etc for the allocation
+	 */
+	return s->size;
+}
+
 static inline struct kmem_cache_order_objects oo_make(int order,
 						unsigned long size)
 {
@@ -797,30 +821,6 @@ static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 	return should_failslab(s->objsize, flags, s->flags);
 }
 
-static inline size_t slab_ksize(const struct kmem_cache *s)
-{
-#ifdef CONFIG_SLUB_DEBUG
-	/*
-	 * Debugging requires use of the padding between object
-	 * and whatever may come after it.
-	 */
-	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
-		return s->objsize;
-
-#endif
-	/*
-	 * If we have the need to store the freelist pointer
-	 * back there or track user information then we can
-	 * only use the space before that information.
-	 */
-	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
-		return s->inuse;
-	/*
-	 * Else we can use all the padding etc for the allocation
-	 */
-	return s->size;
-}
-
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
 {
 	flags &= gfp_allowed_mask;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
