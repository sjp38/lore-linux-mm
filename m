Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6140E6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 14:00:25 -0500 (EST)
Message-Id: <20111204190021.812654254@goodmis.org>
Date: Sun, 04 Dec 2011 13:54:53 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 09/11] slab, lockdep: Fix silly bug
References: <20111204185444.411298317@goodmis.org>
Content-Disposition: inline; filename=0009-slab-lockdep-Fix-silly-bug.patch
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

iQIcBAABAgAGBQJO28NGAAoJEIy3vGnGbaoANzwQALOUi9UkALY1D28YBcIlR5sK
MqZqVvFaQglf0wMSxehfvvwopXqb1il8+tZMFcuLHk3wZ0fnwUQbjmvSmw4fDq19
uIhCzqLjZpmFW+OrwofQ9dV9NvYJdP2TiXY3y0RIvmJDweYoz4AssafyV7XRurCP
yHvAzlMR0n4ZpLyNrnesytch+yWYVE+OEbQLswQZJ79THEgntBMOkNiJ1CMiNXFD
Cpv9ip4dd+KrvhKoX8dPOyfpH88C2wN6qW3HcPs+JP04WRDx4hmtHB1o/BVdx0pa
YJALTkGsYRdM569v3TrVABdy8+R+DG4Qja2GjCZ0jRliDsiwvtRlEvZojTWxhWc+
Td1qqb+c/HTBtQ/EdR8QOZecVQ/kIsLDEQiiYn1kZisgh4lm4Bhsrx1T1YNx4/Zm
POxB1vKBvsO0aBWNrB0ZFj5kMuVQJVz1s0JTHJg65k6g9h9A9e+iovSGfw8ByWeu
wthClWgb0DU9id62RoMmvTrVjcwEiZRrbogScIatZTGhdnAt6cuB78czvgsZi0qg
W82Fx/p4UhfrG1J00Wxj6dLwRE8UzOcwahHVaQdpkGEUqWCVq7wPIspxidhWOmwy
ehg9sxSIknv9DiAxQMBX9klkz+4t4lelJc+yTpt3dGnHNQP6lu6171qUm6ro8dXR
cOfSkCbsKOsFktaCVmnd
=Rjgy
-----END PGP SIGNATURE-----

--00GvhwF7k39YY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
