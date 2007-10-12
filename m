Subject: [PATCH] mm: avoid dirtying shared mappings on mlock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <69AF9B2A-6AA7-4078-B0A2-BE3D4914AEDC@FreeBSD.org>
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org>
	 <20070726172330.d3409b57.akpm@linux-foundation.org>
	 <1185518010.15205.36.camel@lappy>
	 <69AF9B2A-6AA7-4078-B0A2-BE3D4914AEDC@FreeBSD.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wiKc4oSMgthoYDncv+YZ"
Date: Fri, 12 Oct 2007 11:03:25 +0200
Message-Id: <1192179805.27435.6.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

--=-wiKc4oSMgthoYDncv+YZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Subject: mm: avoid dirtying shared mappings on mlock

Suleiman noticed that shared mappings get dirtied when mlocked.
Avoid this by teaching make_pages_present about this case.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Suleiman Souhlal <suleiman@google.com>
---
 mm/memory.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/memory.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2719,7 +2719,12 @@ int make_pages_present(unsigned long add
 	vma =3D find_vma(current->mm, addr);
 	if (!vma)
 		return -1;
-	write =3D (vma->vm_flags & VM_WRITE) !=3D 0;
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	write =3D (vma->vm_flags & (VM_WRITE|VM_SHARED)) =3D=3D VM_WRITE;
 	BUG_ON(addr >=3D end);
 	BUG_ON(end > vma->vm_end);
 	len =3D DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;


--=-wiKc4oSMgthoYDncv+YZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHDzhdXA2jU0ANEf4RAn8rAJ9khXjsR7JcWWTW2jb4djrhInvFkACdEQ3a
LKTBRB+oYBWtkLOYtEu9TtM=
=bub7
-----END PGP SIGNATURE-----

--=-wiKc4oSMgthoYDncv+YZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
