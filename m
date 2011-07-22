Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BF42A6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:16 -0400 (EDT)
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110721071459.GA2961@breakpoint.cc>
References: <20110716211850.GA23917@breakpoint.cc>
	 <alpine.LFD.2.02.1107172333340.2702@ionos>
	 <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins>
	 <alpine.DEB.2.00.1107201642500.4921@tiger>
	 <1311176680.29152.20.camel@twins>  <20110721071459.GA2961@breakpoint.cc>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 22 Jul 2011 15:26:05 +0200
Message-ID: <1311341165.27400.58.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Siewior <sebastian@breakpoint.cc>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 2011-07-21 at 09:14 +0200, Sebastian Siewior wrote:
> * Thus spake Peter Zijlstra (peterz@infradead.org):
> > We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
> > key. Something like the below, except that doesn't quite cover cpu
> > hotplug yet I think.. /me pokes more
> >=20
> > Completely untested, hasn't even seen a compiler etc..
>=20
> This fix on-top passes the compiler and the splash on boot is also gone.

Thanks!
=20
> +static void slab_each_set_lock_classes(struct kmem_cache *cachep)
> +{
> +	int node;
> +
> +	for_each_online_node(node) {
> +		slab_set_lock_classes(cachep, &debugobj_l3_key,
> +				&debugobj_alc_key, node);
> +	}
> +}

Hmm, O(nr_nodes^2), sounds about right for alien crap, right?

Still needs some hotplug love though, maybe something like the below...
Sebastian, would you be willing to give the thing another spin to see if
I didnt (again) break anything silly?

---
Subject: slab, lockdep: Annotate debug object slabs

Lockdep thinks there's lock recursion through:

	kmem_cache_free()
	  cache_flusharray()
	    spin_lock(&l3->list_lock)  <----------------\
	    free_block()                                |
	      slab_destroy()                            |
		call_rcu()                              |
		  debug_object_activate()               |
		    debug_object_init()                 |
		      __debug_object_init()             |
			kmem_cache_alloc()              |
			  cache_alloc_refill()          |
			    spin_lock(&l3->list_lock) --/

Now debug objects doesn't use SLAB_DESTROY_BY_RCU and hence there is no
actual possibility of recursing. Luckily debug objects marks it slab
with SLAB_DEBUG_OBJECTS so we can identify the thing.

Mark all SLAB_DEBUG_OBJECTS (all one!) slab caches with a special
lockdep key so that lockdep sees its a different cachep.

Also add a WARN on trying to create a SLAB_DESTROY_BY_RCU |
SLAB_DEBUG_OBJECTS cache, to avoid possible future trouble.

Reported-by: Sebastian Siewior <sebastian@breakpoint.cc>
[ fixes to the initial patch ]
Reported-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/slab.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++++---------=
----
 1 files changed, 68 insertions(+), 18 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d96e223..2175d45 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -620,6 +620,51 @@ int slab_is_available(void)
 static struct lock_class_key on_slab_l3_key;
 static struct lock_class_key on_slab_alc_key;
=20
+static struct lock_class_key debugobj_l3_key;
+static struct lock_class_key debugobj_alc_key;
+
+static void slab_set_lock_classes(struct kmem_cache *cachep,
+		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
+		int q)
+{
+	struct array_cache **alc;
+	struct kmem_list3 *l3;
+	int r;
+
+	l3 =3D cachep->nodelists[q];
+	if (!l3)
+		return;
+
+	lockdep_set_class(&l3->list_lock, l3_key);
+	alc =3D l3->alien;
+	/*
+	 * FIXME: This check for BAD_ALIEN_MAGIC
+	 * should go away when common slab code is taught to
+	 * work even without alien caches.
+	 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
+	 * for alloc_alien_cache,
+	 */
+	if (!alc || (unsigned long)alc =3D=3D BAD_ALIEN_MAGIC)
+		return;
+	for_each_node(r) {
+		if (alc[r])
+			lockdep_set_class(&alc[r]->lock, alc_key);
+	}
+}
+
+static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep,=
 int node)
+{
+	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, node);
+}
+
+static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep)
+{
+	int node;
+
+	for_each_online_node(node)
+		slab_set_debugobj_lock_classes_node(cachep, node);
+}
+
 static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s =3D malloc_sizes;
@@ -628,29 +673,14 @@ static void init_node_lock_keys(int q)
 		return;
=20
 	for (s =3D malloc_sizes; s->cs_size !=3D ULONG_MAX; s++) {
-		struct array_cache **alc;
 		struct kmem_list3 *l3;
-		int r;
=20
 		l3 =3D s->cs_cachep->nodelists[q];
 		if (!l3 || OFF_SLAB(s->cs_cachep))
 			continue;
-		lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
-		alc =3D l3->alien;
-		/*
-		 * FIXME: This check for BAD_ALIEN_MAGIC
-		 * should go away when common slab code is taught to
-		 * work even without alien caches.
-		 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
-		 * for alloc_alien_cache,
-		 */
-		if (!alc || (unsigned long)alc =3D=3D BAD_ALIEN_MAGIC)
-			continue;
-		for_each_node(r) {
-			if (alc[r])
-				lockdep_set_class(&alc[r]->lock,
-					&on_slab_alc_key);
-		}
+
+		slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
+				&on_slab_alc_key, q);
 	}
 }
=20
@@ -669,6 +699,14 @@ static void init_node_lock_keys(int q)
 static inline void init_lock_keys(void)
 {
 }
+
+static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep,=
 int node)
+{
+}
+
+static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep, int =
node)
+{
+}
 #endif
=20
 /*
@@ -1262,6 +1300,8 @@ static int __cpuinit cpuup_prepare(long cpu)
 		spin_unlock_irq(&l3->list_lock);
 		kfree(shared);
 		free_alien_cache(alien);
+		if (cachep->flags & SLAB_DEBUG_OBJECTS)
+			slab_set_debugobj_lock_classes_node(cachep, node);
 	}
 	init_node_lock_keys(node);
=20
@@ -2424,6 +2464,16 @@ kmem_cache_create (const char *name, size_t size, si=
ze_t align,
 		goto oops;
 	}
=20
+	if (flags & SLAB_DEBUG_OBJECTS) {
+		/*
+		 * Would deadlock through slab_destroy()->call_rcu()->
+		 * debug_object_activate()->kmem_cache_alloc().
+		 */
+		WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
+
+		slab_set_debugobj_lock_classes(cachep);
+	}
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
