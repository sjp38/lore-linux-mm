Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 345B96B004D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 16:19:42 -0500 (EST)
Message-ID: <1322515158.2921.179.camel@twins>
Subject: Re: possible slab deadlock while doing ifenslave
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 22:19:18 +0100
References: <201110121019.53100.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
	 <201110131019.58397.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Fri, 2011-10-14 at 01:21 +0200, Peter Zijlstra wrote:
> On Thu, 2011-10-13 at 16:03 -0700, David Rientjes wrote:
>=20
> > Ok, I think this may be related to what Sitsofe reported in the "lockde=
p=20
> > recursive locking detected" thread on LKML (see=20
> > http://marc.info/?l=3Dlinux-kernel&m=3D131805699106560).
> >=20
> > Peter and Christoph hypothesized that 056c62418cc6 ("slab: fix lockdep=
=20
> > warnings") may not have had full coverage when setting lockdep classes =
for=20
> > kmem_list3 locks that may be called inside of each other because of=20
> > off-slab metadata.
> >=20
> > I think it's safe to say there is no deadlock possibility here or we wo=
uld=20
> > have seen it since 2006 and this is just a matter of lockdep annotation=
=20
> > that needs to be done.  So don't worry too much about the warning even=
=20
> > though I know it's annoying and it suppresses future lockdep output (ev=
en=20
> > more annoying!).
> >=20
> > I'm not sure if there's a patch to address that yet, I think one was in=
=20
> > the works.  If not, I'll take a look at rewriting that lockdep annotati=
on.
>=20
> Urgh, I so totally forgot about that.. :-/ So no, no patch yet.

---
Subject: slab, lockdep: Fix silly bug
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon Nov 28 21:12:40 CET 2011

Commit 30765b92 ("slab, lockdep: Annotate the locks before using
them") moves the init_lock_keys() call from after g_cpucache_up =3D
FULL, to before it. And overlooks the fact that init_node_lock_keys()
tests for it and ignores everything !FULL.

Introduce a LATE stage and change the lockdep test to be <LATE.

Cc: stable@kernel.org
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Link: http://lkml.kernel.org/n/tip-gadqbdfxorhia1w5ewmoiodd@git.kernel.org
---
Index: linux-2.6/mm/slab.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -595,6 +595,7 @@ static enum {
 	PARTIAL_AC,
 	PARTIAL_L3,
 	EARLY,
+	LATE,
 	FULL
 } g_cpucache_up;
=20
@@ -671,7 +672,7 @@ static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s =3D malloc_sizes;
=20
-	if (g_cpucache_up !=3D FULL)
+	if (g_cpucache_up < LATE)
 		return;
=20
 	for (s =3D malloc_sizes; s->cs_size !=3D ULONG_MAX; s++) {
@@ -1666,6 +1667,8 @@ void __init kmem_cache_init_late(void)
 {
 	struct kmem_cache *cachep;
=20
+	g_cpucache_up =3D LATE;
+
 	/* Annotate slab for lockdep -- annotate the malloc caches */
 	init_lock_keys();
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
