Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAF76B005A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:30:42 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5PJQUZK001618
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:26:30 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5PJVcgS250648
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:31:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5PJVbD2027132
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:31:37 -0400
Date: Thu, 25 Jun 2009 12:31:37 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem in
	sl[aou]b
Message-ID: <20090625193137.GA16861@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

Hello!

Jesper noted that kmem_cache_destroy() invokes synchronize_rcu() rather
than rcu_barrier() in the SLAB_DESTROY_BY_RCU case, which could result
in RCU callbacks accessing a kmem_cache after it had been destroyed.

The following untested (might not even compile) patch proposes a fix.

Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 slab.c |    2 +-
 slob.c |    2 ++
 slub.c |    2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index e74a16e..5241b65 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2547,7 +2547,7 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 	}
 
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
-		synchronize_rcu();
+		rcu_barrier();
 
 	__kmem_cache_destroy(cachep);
 	mutex_unlock(&cache_chain_mutex);
diff --git a/mm/slob.c b/mm/slob.c
index c78742d..9641da3 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -595,6 +595,8 @@ EXPORT_SYMBOL(kmem_cache_create);
 void kmem_cache_destroy(struct kmem_cache *c)
 {
 	kmemleak_free(c);
+	if (c->flags & SLAB_DESTROY_BY_RCU)
+		rcu_barrier();
 	slob_free(c, sizeof(struct kmem_cache));
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
diff --git a/mm/slub.c b/mm/slub.c
index 819f056..a9201d8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2595,6 +2595,8 @@ static inline int kmem_cache_close(struct kmem_cache *s)
  */
 void kmem_cache_destroy(struct kmem_cache *s)
 {
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		rcu_barrier();
 	down_write(&slub_lock);
 	s->refcount--;
 	if (!s->refcount) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
