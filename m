Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 268856B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 03:15:19 -0400 (EDT)
Date: Thu, 21 Jul 2011 09:14:59 +0200
From: Sebastian Siewior <sebastian@breakpoint.cc>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
Message-ID: <20110721071459.GA2961@breakpoint.cc>
References: <20110716211850.GA23917@breakpoint.cc>
 <alpine.LFD.2.02.1107172333340.2702@ionos>
 <alpine.DEB.2.00.1107201619540.3528@tiger>
 <1311168638.5345.80.camel@twins>
 <alpine.DEB.2.00.1107201642500.4921@tiger>
 <1311176680.29152.20.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311176680.29152.20.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

* Thus spake Peter Zijlstra (peterz@infradead.org):
> We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
> key. Something like the below, except that doesn't quite cover cpu
> hotplug yet I think.. /me pokes more
> 
> Completely untested, hasn't even seen a compiler etc..

This fix on-top passes the compiler and the splash on boot is also gone.

---
 mm/slab.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c13f7e9..fcf8380 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -623,8 +623,9 @@ static struct lock_class_key on_slab_alc_key;
 static struct lock_class_key debugobj_l3_key;
 static struct lock_class_key debugobj_alc_key;
 
-static void slab_set_lock_classes(struct kmem_cache *cachep, 
-		struct lock_class_key *l3_key, struct lock_class_key *alc_key)
+static void slab_set_lock_classes(struct kmem_cache *cachep,
+		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
+		int q)
 {
 	struct array_cache **alc;
 	struct kmem_list3 *l3;
@@ -651,6 +652,16 @@ static void slab_set_lock_classes(struct kmem_cache *cachep,
 	}
 }
 
+static void slab_each_set_lock_classes(struct kmem_cache *cachep)
+{
+	int node;
+
+	for_each_online_node(node) {
+		slab_set_lock_classes(cachep, &debugobj_l3_key,
+				&debugobj_alc_key, node);
+	}
+}
+
 static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s = malloc_sizes;
@@ -665,8 +676,8 @@ static void init_node_lock_keys(int q)
 		if (!l3 || OFF_SLAB(s->cs_cachep))
 			continue;
 
-		slab_set_lock_classes(s->cs_cachep,
-				&on_slab_l3_key, &on_slab_alc_key)
+		slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
+				&on_slab_alc_key, q);
 	}
 }
 
@@ -685,6 +696,10 @@ static void init_node_lock_keys(int q)
 static inline void init_lock_keys(void)
 {
 }
+
+static void slab_each_set_lock_classes(struct kmem_cache *cachep)
+{
+}
 #endif
 
 /*
@@ -2447,10 +2462,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		 */
 		WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
 
-#ifdef CONFIG_LOCKDEP
-		slab_set_lock_classes(cachep, 
-				&debugobj_l3_key, &debugobj_alc_key);
-#endif
+		slab_each_set_lock_classes(cachep);
 	}
 
 	/* cache setup completed, link it into the list */
-- 
1.7.4.4

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
