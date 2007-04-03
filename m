Message-ID: <4612DE38.1020002@redhat.com>
Date: Tue, 03 Apr 2007 16:07:36 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403135154.61e1b5f3.akpm@linux-foundation.org> <4612C059.8070702@redhat.com> <4612C2B6.3010302@cosmosbay.com> <4612CB21.9020005@redhat.com> <20070403225155.GA26567@one.firstfloor.org>
In-Reply-To: <20070403225155.GA26567@one.firstfloor.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFBE1A50B6ABF9512D9461CED"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFBE1A50B6ABF9512D9461CED
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Andi Kleen wrote:
> If you know in advance you need them it might be possible to=20
> batch that. e.g. MADV_WILLNEED could be extended to
> work on anonymous memory and establish the mappings in the syscall.=20
> Would that be useful?=20

Not in the exact way you think.  The problem is that not all pages would
be needed right away.  An allocator requests address space from the
kernel in larger chunks and then uses it piece by piece.  The so-far
unused memory remains untouched and therefore not mapped.  It would be
wasteful to allocate all pages.  It would mean the allocator has to
request smaller blocks from the kernel which in turn means more system
calls.

The behavior is also not good for the malloc()'ed blocks.  A large block
might also not be used fully or at least not necessary.

But I definitely could see cases where I would want that functionality.
 For instance, for memory regions which contain only administrative data
and where every page is used right away.  Substituting N page faults for
one madvise call probably is a win.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigFBE1A50B6ABF9512D9461CED
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGEt442ijCOnn/RHQRAmB8AJ9NlbBKQyOXChbNp02FAzQ+zm+GOwCgl8jV
CiIpOQyOD2zBlOlmkTzA3m0=
=9G5t
-----END PGP SIGNATURE-----

--------------enigFBE1A50B6ABF9512D9461CED--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
