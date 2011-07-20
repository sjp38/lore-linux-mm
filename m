Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DECDC6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 11:45:05 -0400 (EDT)
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1107201642500.4921@tiger>
References: <20110716211850.GA23917@breakpoint.cc>
	 <alpine.LFD.2.02.1107172333340.2702@ionos>
	 <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins>
	 <alpine.DEB.2.00.1107201642500.4921@tiger>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Jul 2011 17:44:40 +0200
Message-ID: <1311176680.29152.20.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 2011-07-20 at 16:52 +0300, Pekka Enberg wrote:

> So what exactly is the lockdep complaint above telling us? We're holding=
=20
> on to l3->list_lock in cache_flusharray() (kfree path) but somehow we now=
=20
> entered cache_alloc_refill() (kmalloc path!) and attempt to take the same=
=20
> lock or lock in the same class.
>=20
> I am confused. How can that happen?

[   13.540663]  [<c106b54e>] print_deadlock_bug+0xce/0xe0
[   13.540663]  [<c106d5fa>] validate_chain+0x5aa/0x720
[   13.540663]  [<c106da07>] __lock_acquire+0x297/0x480
[   13.540663]  [<c106e15b>] lock_acquire+0x7b/0xa0
[   13.540663]  [<c10c66c6>] ? cache_alloc_refill+0x66/0x2e0
[   13.540663]  [<c13ca4e6>] _raw_spin_lock+0x36/0x70
[   13.540663]  [<c10c66c6>] ? cache_alloc_refill+0x66/0x2e0
[   13.540663]  [<c11f6ac6>] ? __debug_object_init+0x346/0x360
[   13.540663]  [<c10c66c6>] cache_alloc_refill+0x66/0x2e0
[   13.540663]  [<c106da25>] ? __lock_acquire+0x2b5/0x480
[   13.540663]  [<c11f6ac6>] ? __debug_object_init+0x346/0x360
[   13.540663]  [<c10c635f>] kmem_cache_alloc+0x11f/0x140
[   13.540663]  [<c11f6ac6>] __debug_object_init+0x346/0x360
[   13.540663]  [<c106df62>] ? __lock_release+0x72/0x180
[   13.540663]  [<c11f6365>] ? debug_object_activate+0x85/0x130
[   13.540663]  [<c11f6b17>] debug_object_init+0x17/0x20
[   13.540663]  [<c10543da>] rcuhead_fixup_activate+0x1a/0x60
[   13.540663]  [<c11f6375>] debug_object_activate+0x95/0x130
[   13.540663]  [<c10c60a0>] ? kmem_cache_shrink+0x50/0x50
[   13.540663]  [<c108e60a>] __call_rcu+0x2a/0x180
[   13.540663]  [<c10c48b0>] ? slab_destroy_debugcheck+0x70/0x110
[   13.540663]  [<c108e77d>] call_rcu_sched+0xd/0x10
[   13.540663]  [<c10c58d3>] slab_destroy+0x73/0x80
[   13.540663]  [<c10c591f>] free_block+0x3f/0x1b0
[   13.540663]  [<c10c5ad3>] ? cache_flusharray+0x43/0x110
[   13.540663]  [<c10c5b03>] cache_flusharray+0x73/0x110
[   13.540663]  [<c10c5847>] kmem_cache_free+0xb7/0xd0
[   13.540663]  [<c10bbfb9>] __put_anon_vma+0x49/0xa0
[   13.540663]  [<c10bc5dc>] unlink_anon_vmas+0xfc/0x160
[   13.540663]  [<c10b451c>] free_pgtables+0x3c/0x90
[   13.540663]  [<c10b9a8f>] exit_mmap+0xbf/0xf0
[   13.540663]  [<c1039d3c>] mmput+0x4c/0xc0
[   13.540663]  [<c103d9bc>] exit_mm+0xec/0x130
[   13.540663]  [<c13cadc2>] ? _raw_spin_unlock_irq+0x22/0x30
[   13.540663]  [<c103fa03>] do_exit+0x123/0x390
[   13.540663]  [<c10cb9c5>] ? fput+0x15/0x20
[   13.540663]  [<c10c7c2d>] ? filp_close+0x4d/0x80
[   13.540663]  [<c103fca9>] do_group_exit+0x39/0xa0
[   13.540663]  [<c103fd23>] sys_exit_group+0x13/0x20
[   13.540663]  [<c13cb70c>] sysenter_do_call+0x12/0x32

Shows quite clearly how it happens, now its a false-positive, since the
debug object slab doesn't use rcu-freeing and thus it can never be the
same slab.

We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
key. Something like the below, except that doesn't quite cover cpu
hotplug yet I think.. /me pokes more

Completely untested, hasn't even seen a compiler etc..

---
 mm/slab.c |   65 ++++++++++++++++++++++++++++++++++++++++++++-------------=
---
 1 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d96e223..c13f7e9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -620,6 +620,37 @@ int slab_is_available(void)
 static struct lock_class_key on_slab_l3_key;
 static struct lock_class_key on_slab_alc_key;
=20
+static struct lock_class_key debugobj_l3_key;
+static struct lock_class_key debugobj_alc_key;
+
+static void slab_set_lock_classes(struct kmem_cache *cachep,=20
+		struct lock_class_key *l3_key, struct lock_class_key *alc_key)
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
 static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s =3D malloc_sizes;
@@ -628,29 +659,14 @@ static void init_node_lock_keys(int q)
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
+		slab_set_lock_classes(s->cs_cachep,
+				&on_slab_l3_key, &on_slab_alc_key)
 	}
 }
=20
@@ -2424,6 +2440,19 @@ kmem_cache_create (const char *name, size_t size, si=
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
+#ifdef CONFIG_LOCKDEP
+		slab_set_lock_classes(cachep,=20
+				&debugobj_l3_key, &debugobj_alc_key);
+#endif
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
