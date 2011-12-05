Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 22B4F6B005A
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 18:03:09 -0500 (EST)
Message-Id: <20111205230305.723773088@goodmis.org>
Date: Mon, 05 Dec 2011 18:00:56 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH RT 10/12 rc3] slab, lockdep: Annotate all slab caches
References: <20111205230046.736851081@goodmis.org>
Content-Disposition: inline; filename=0010-slab-lockdep-Annotate-all-slab-caches.patch
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="00GvhwF7k39YY"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-rt-users <linux-rt-users@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Carsten Emde <C.Emde@osadl.org>, John Kacur <jkacur@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--00GvhwF7k39YY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Currently we only annotate the kmalloc caches, annotate all of them.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hans Schillstrom <hans@schillstrom.com>
Cc: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Sitsofe Wheeler <sitsofe@yahoo.com>
Cc: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/n/tip-10bey2cgpcvtbdkgigaoab8w@git.kernel.org
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 mm/slab.c |   52 ++++++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 433b9a2..5251b99 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -606,6 +606,12 @@ int slab_is_available(void)
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
@@ -667,38 +673,41 @@ static void slab_set_debugobj_lock_classes(struct kme=
m_cache *cachep)
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
@@ -711,12 +720,6 @@ static void slab_set_debugobj_lock_classes(struct kmem=
_cache *cachep)
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
 static DEFINE_PER_CPU(struct list_head, slab_free_list);
 static DEFINE_LOCAL_IRQ_LOCK(slab_lock);
@@ -1728,14 +1731,13 @@ void __init kmem_cache_init_late(void)
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
@@ -2546,6 +2548,8 @@ kmem_cache_create (const char *name, size_t size, siz=
e_t align,
 		slab_set_debugobj_lock_classes(cachep);
 	}
=20
+	init_cachep_lock_keys(cachep);
+
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->next, &cache_chain);
 oops:
--=20
1.7.7.1



--00GvhwF7k39YY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJO3U2pAAoJEIy3vGnGbaoAGMgP/RQTtz4hfVPII4oopKDxPKZj
pstWMSFh9TLFhTd2rQJvG7EcE93myoRm7z7iQjiJuRFFhYdjn4r6ipsaXfx1Sdz9
ma4TrknUPy8BDUldwtuwri/mMuW3uANA4UBzThEQLM9wkXtXsSIsI/pOwBQCgrpL
RW5R24TQNekPZe1tgURx56ri2oGLfgp8eMagZ8/hb0EHQS1lGA0XFoIjszj3z5eC
rYn0KUUjzpt06Amd7bItu92vG9By0dhauY/GhIO6gwngI2Oe6BdtYU9xpkj6yD2h
EtQNByXTkcT3KB0xc24lKE4TBjya5rRdwqY6yOxi3WfqYcY1Mn36Psd4On6Hx9bH
BA980/SXVjT4mFslWDooyjGJL8eXoBWJ4J7pppp4TRaUCKVEeIfniW0mQtoFrdCd
FqVjGe/0iD7tdA6kNYJ+VRGUb7FHP5+lUEboh0hn2aCV6NIUoKrp/NdJ2la+H8UY
GKKFB/XFv0UEyEy8+i8lr/Z70GrEVg52WEpZbyx8xU3tTywDwVKIDbEthGYJ5qzz
wA1knGg4WahtpLYkO83W22VXcgbz/NK8DsZ0ctLzTGre8/VI/YIwpWvzkWUmfP+l
dH+V7j7mqcfLDJ7k5pPToYIpHTlOt6w56zOKm//xrbEriAQOPWZXJ9+OZX/TNnrZ
tH5Vs85cO4h5MVcCqvHZ
=UxZI
-----END PGP SIGNATURE-----

--00GvhwF7k39YY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
