Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 555B56B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 20:47:59 -0500 (EST)
Message-Id: <20111203014755.214257772@goodmis.org>
Date: Fri, 02 Dec 2011 20:46:49 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 08/10] slab, lockdep: Fix silly bug
References: <20111203014641.165123482@goodmis.org>
Content-Disposition: inline; filename=0008-slab-lockdep-Fix-silly-bug.patch
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="00GvhwF7k39YY"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-rt-users <linux-rt-users@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Carsten Emde <C.Emde@osadl.org>, John Kacur <jkacur@redhat.com>, stable@kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--00GvhwF7k39YY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Commit 30765b92 ("slab, lockdep: Annotate the locks before using
them") moves the init_lock_keys() call from after g_cpucache_up =3D
FULL, to before it. And overlooks the fact that init_node_lock_keys()
tests for it and ignores everything !FULL.

Introduce a LATE stage and change the lockdep test to be <LATE.

Cc: stable@kernel.org
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hans Schillstrom <hans@schillstrom.com>
Cc: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Sitsofe Wheeler <sitsofe@yahoo.com>
Cc: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/n/tip-gadqbdfxorhia1w5ewmoiodd@git.kernel.org
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 mm/slab.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 015cd76..433b9a2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -594,6 +594,7 @@ static enum {
 	PARTIAL_AC,
 	PARTIAL_L3,
 	EARLY,
+	LATE,
 	FULL
 } g_cpucache_up;
=20
@@ -670,7 +671,7 @@ static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s =3D malloc_sizes;
=20
-	if (g_cpucache_up !=3D FULL)
+	if (g_cpucache_up < LATE)
 		return;
=20
 	for (s =3D malloc_sizes; s->cs_size !=3D ULONG_MAX; s++) {
@@ -1725,6 +1726,8 @@ void __init kmem_cache_init_late(void)
 {
 	struct kmem_cache *cachep;
=20
+	g_cpucache_up =3D LATE;
+
 	/* Annotate slab for lockdep -- annotate the malloc caches */
 	init_lock_keys();
=20
--=20
1.7.7.1



--00GvhwF7k39YY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJO2X/LAAoJEIy3vGnGbaoAAakQALIaYLRzYWHnxmLDJLB/F+V6
BdEYC929d/NO/j5xFgnvWc198nuwxRD2nkojIQ5hvikRaE/H2Yhq32zEkQtSnyXh
FCe5I6aAF1LE6mN6uek5uJ6xWwJ09MPDiJrwldrB6aLrLxZZNg9Pl5P3jaCYD724
p81d5o/Qv8PjIM++WizDq2G6QoiZwxkeMOO52eSUjUdtxuTmTQSDlcWOGZPnB4l1
7OjffArfQhFZV5YJv5brrd09xMKJ+coj8CXPlAE7MPOdNKZhvNewREmWEsbmLI6M
id1W/H3x22WObUQHVSPvM1xTzhX9ZB0+IykjbBjpSMXykBfnnA3rgGqNUKPHy2rJ
Kqps1/GDSYPaHZ/QSeV6pXy+CC/D+rrTC/54n+C5p55ALRav7gYVkMJ6/ubSVY7Z
4G17zgcPzjVQ6jzvC2DQJVYo2FcYCPgZxUV6OCEJCi+HaH/RzPHSUmadYAq87+Pq
KK5qlqcMq6EcFNsnK4VNcmp9bkI3Pu5OcJpNPnboNCEMO+RXEtgf0oOHEJu1MuLO
LGF/hG6jIXkRru8bygIWuvvAsNjfOsp4hIO/xVbg5KUXHwgdZWgoP2i8ZWcYoxpz
8IxSKfc1zantrhMdv17HNEjtocUuFsrDTbZlYnzyWhd4xvoT3A0R5hWDXR76ngYw
wAXuZpE/PiUAU6q6NXHp
=4OyZ
-----END PGP SIGNATURE-----

--00GvhwF7k39YY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
