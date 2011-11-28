Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07B4F6B004D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 16:20:37 -0500 (EST)
Message-ID: <1322515222.2921.180.camel@twins>
Subject: Re: possible slab deadlock while doing ifenslave
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 22:20:22 +0100
In-Reply-To: <1322515158.2921.179.camel@twins>
References: <201110121019.53100.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
	 <201110131019.58397.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
	 <1322515158.2921.179.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Mon, 2011-11-28 at 22:19 +0100, Peter Zijlstra wrote:

> > Urgh, I so totally forgot about that.. :-/ So no, no patch yet.

On top of the previous patch I've got this, which is probably less
critical but makes it all more comprehensive or so..

---
Subject: slab, lockdep: Annotate all slab caches
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon Nov 28 19:51:51 CET 2011

Currently we only annotate the kmalloc caches, annotate all of them.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Link: http://lkml.kernel.org/n/tip-10bey2cgpcvtbdkgigaoab8w@git.kernel.org
---
 mm/slab.c |   52 ++++++++++++++++++++++++++++------------------------
 1 file changed, 28 insertions(+), 24 deletions(-)
Index: linux-2.6/mm/slab.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -607,6 +607,12 @@ int slab_is_available(void)
 	return g_cpucache_up >=3D EARLY;
 }
=20
+/*
+ * Guard access to the cache-chain.
+ */
+static DEFINE_MUTEX(cache_chain_mutex);
+static struct list_head cache_chain;
+
 #ifdef CONFIG_LOCKDEP
=20
 /*
@@ -668,38 +674,41 @@ static void slab_set_debugobj_lock_class
 		slab_set_debugobj_lock_classes_node(cachep, node);
 }
=20
-static void init_node_lock_keys(int q)
+static void init_lock_keys(struct kmem_cache *cachep, int node)
 {
-	struct cache_sizes *s =3D malloc_sizes;
+	struct kmem_list3 *l3;
=20
 	if (g_cpucache_up < LATE)
 		return;
=20
-	for (s =3D malloc_sizes; s->cs_size !=3D ULONG_MAX; s++) {
-		struct kmem_list3 *l3;
+	l3 =3D cachep->nodelists[node];
+	if (!l3 || OFF_SLAB(cachep))
+		return;
=20
-		l3 =3D s->cs_cachep->nodelists[q];
-		if (!l3 || OFF_SLAB(s->cs_cachep))
-			continue;
+	slab_set_lock_classes(cachep, &on_slab_l3_key, &on_slab_alc_key, node);
+}
=20
-		slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
-				&on_slab_alc_key, q);
-	}
+static void init_node_lock_keys(int node)
+{
+	struct kmem_cache *cachep;
+
+	list_for_each_entry(cachep, &cache_chain, next)
+		init_lock_keys(cachep, node);
 }
=20
-static inline void init_lock_keys(void)
+static inline void init_cachep_lock_keys(struct kmem_cache *cachep)
 {
 	int node;
=20
 	for_each_node(node)
-		init_node_lock_keys(node);
+		init_lock_keys(cachep, node);
 }
 #else
-static void init_node_lock_keys(int q)
+static void init_node_lock_keys(int node)
 {
 }
=20
-static inline void init_lock_keys(void)
+static void init_cachep_lock_keys(struct kmem_cache *cachep)
 {
 }
=20
@@ -712,12 +721,6 @@ static void slab_set_debugobj_lock_class
 }
 #endif
=20
-/*
- * Guard access to the cache-chain.
- */
-static DEFINE_MUTEX(cache_chain_mutex);
-static struct list_head cache_chain;
-
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
=20
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -1669,14 +1672,13 @@ void __init kmem_cache_init_late(void)
=20
 	g_cpucache_up =3D LATE;
=20
-	/* Annotate slab for lockdep -- annotate the malloc caches */
-	init_lock_keys();
-
 	/* 6) resize the head arrays to their final sizes */
 	mutex_lock(&cache_chain_mutex);
-	list_for_each_entry(cachep, &cache_chain, next)
+	list_for_each_entry(cachep, &cache_chain, next) {
+		init_cachep_lock_keys(cachep);
 		if (enable_cpucache(cachep, GFP_NOWAIT))
 			BUG();
+	}
 	mutex_unlock(&cache_chain_mutex);
=20
 	/* Done! */
@@ -2479,6 +2481,8 @@ kmem_cache_create (const char *name, siz
 		slab_set_debugobj_lock_classes(cachep);
 	}
=20
+	init_cachep_lock_keys(cachep);
+
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->next, &cache_chain);
 oops:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
