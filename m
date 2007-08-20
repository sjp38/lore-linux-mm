Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070806103658.603735000@chello.nl>
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.603735000@chello.nl>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fvqvlzrbS4K4s4R46Pu0"
Date: Mon, 20 Aug 2007 09:38:33 +0200
Message-Id: <1187595513.6114.176.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

--=-fvqvlzrbS4K4s4R46Pu0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Ok, so I got rid of the global stuff, this also obsoletes 3/10.


---
Subject: mm: slub: add knowledge of reserve pages

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it.

Care is taken to only touch the SLUB slow path.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++--------=
-----
 1 file changed, 69 insertions(+), 18 deletions(-)

Index: linux-2.6-2/mm/slub.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6-2.orig/mm/slub.c
+++ linux-2.6-2/mm/slub.c
@@ -20,11 +20,12 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
=20
 /*
  * Lock order:
  *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   2. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -1069,7 +1070,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(object, s, 0);
 }
=20
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, =
int *reserve)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -1087,6 +1088,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
=20
+	*reserve =3D page->reserve;
 	n =3D get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1403,12 +1405,36 @@ static inline void flush_slab(struct kme
 }
=20
 /*
+ * cpu slab reserve magic
+ *
+ * we mark reserve status in the lsb of the ->cpu_slab[] pointer.
+ */
+static inline unsigned long cpu_slab_reserve(struct kmem_cache *s, int cpu=
)
+{
+	return unlikely((unsigned long)s->cpu_slab[cpu] & 1);
+}
+
+static inline void
+cpu_slab_set(struct kmem_cache *s, int cpu, struct page *page, int reserve=
)
+{
+	if (unlikely(reserve))
+		page =3D (struct page *)((unsigned long)page | 1);
+
+	s->cpu_slab[cpu] =3D page;
+}
+
+static inline struct page *cpu_slab(struct kmem_cache *s, int cpu)
+{
+	return (struct page *)((unsigned long)s->cpu_slab[cpu] & ~1UL);
+}
+
+/*
  * Flush cpu slab.
  * Called from IPI handler with interrupts disabled.
  */
 static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
-	struct page *page =3D s->cpu_slab[cpu];
+	struct page *page =3D cpu_slab(s, cpu);
=20
 	if (likely(page))
 		flush_slab(s, page, cpu);
@@ -1457,10 +1483,22 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	int cpu =3D smp_processor_id();
+	int reserve =3D 0;
=20
 	if (!page)
 		goto new_slab;
=20
+	if (cpu_slab_reserve(s, cpu)) {
+		/*
+		 * If the current slab is a reserve slab and the current
+		 * allocation context does not allow access to the reserves
+		 * we must force an allocation to test the current levels.
+		 */
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+			goto alloc_slab;
+		reserve =3D 1;
+	}
+
 	slab_lock(page);
 	if (unlikely(node !=3D -1 && page_to_nid(page) !=3D node))
 		goto another_slab;
@@ -1468,10 +1506,9 @@ load_freelist:
 	object =3D page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SlabDebug(page)))
+	if (unlikely(SlabDebug(page) || reserve))
 		goto debug;
=20
-	object =3D page->freelist;
 	page->lockless_freelist =3D object[page->offset];
 	page->inuse =3D s->objects;
 	page->freelist =3D NULL;
@@ -1484,14 +1521,28 @@ another_slab:
 new_slab:
 	page =3D get_partial(s, gfpflags, node);
 	if (page) {
-		s->cpu_slab[cpu] =3D page;
+		cpu_slab_set(s, cpu, page, reserve);
 		goto load_freelist;
 	}
=20
-	page =3D new_slab(s, gfpflags, node);
+alloc_slab:
+	page =3D new_slab(s, gfpflags, node, &reserve);
 	if (page) {
+		struct page *slab;
+
 		cpu =3D smp_processor_id();
-		if (s->cpu_slab[cpu]) {
+		slab =3D cpu_slab(s, cpu);
+
+		if (cpu_slab_reserve(s, cpu) && !reserve) {
+			/*
+			 * If the current cpu_slab is a reserve slab but we
+			 * managed to allocate a new slab the pressure is
+			 * lifted and we can unmark the current one.
+			 */
+			cpu_slab_set(s, cpu, slab, 0);
+		}
+
+		if (slab) {
 			/*
 			 * Someone else populated the cpu_slab while we
 			 * enabled interrupts, or we have gotten scheduled
@@ -1499,29 +1550,28 @@ new_slab:
 			 * requested node even if __GFP_THISNODE was
 			 * specified. So we need to recheck.
 			 */
-			if (node =3D=3D -1 ||
-				page_to_nid(s->cpu_slab[cpu]) =3D=3D node) {
+			if (node =3D=3D -1 || page_to_nid(slab) =3D=3D node) {
 				/*
 				 * Current cpuslab is acceptable and we
 				 * want the current one since its cache hot
 				 */
 				discard_slab(s, page);
-				page =3D s->cpu_slab[cpu];
+				page =3D slab;
 				slab_lock(page);
 				goto load_freelist;
 			}
 			/* New slab does not fit our expectations */
-			flush_slab(s, s->cpu_slab[cpu], cpu);
+			flush_slab(s, slab, cpu);
 		}
 		slab_lock(page);
 		SetSlabFrozen(page);
-		s->cpu_slab[cpu] =3D page;
+		cpu_slab_set(s, cpu, page, reserve);
 		goto load_freelist;
 	}
 	return NULL;
 debug:
-	object =3D page->freelist;
-	if (!alloc_debug_processing(s, page, object, addr))
+	if (SlabDebug(page) &&
+			!alloc_debug_processing(s, page, object, addr))
 		goto another_slab;
=20
 	page->inuse++;
@@ -1548,7 +1598,7 @@ static void __always_inline *slab_alloc(
 	unsigned long flags;
=20
 	local_irq_save(flags);
-	page =3D s->cpu_slab[smp_processor_id()];
+	page =3D cpu_slab(s, smp_processor_id());
 	if (unlikely(!page || !page->lockless_freelist ||
 			(node !=3D -1 && page_to_nid(page) !=3D node)))
=20
@@ -1873,10 +1923,11 @@ static struct kmem_cache_node * __init e
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	int reserve;
=20
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
=20
-	page =3D new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	page =3D new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node, &reserve=
);
=20
 	BUG_ON(!page);
 	n =3D page->freelist;
@@ -3189,7 +3240,7 @@ static unsigned long slab_objects(struct
 	per_cpu =3D nodes + nr_node_ids;
=20
 	for_each_possible_cpu(cpu) {
-		struct page *page =3D s->cpu_slab[cpu];
+		struct page *page =3D cpu_slab(s, cpu);
 		int node;
=20
 		if (page) {


--=-fvqvlzrbS4K4s4R46Pu0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD4DBQBGyUT5XA2jU0ANEf4RAvUfAJ4zJcLhDEHbStArCdGFdSQfPvj9LQCY8eWn
b+jq8LV6plwZp+Utr/1SjA==
=CSqn
-----END PGP SIGNATURE-----

--=-fvqvlzrbS4K4s4R46Pu0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
