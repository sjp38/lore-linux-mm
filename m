Message-ID: <4612B645.7030902@redhat.com>
Date: Tue, 03 Apr 2007 13:17:09 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org>
In-Reply-To: <20070403125903.3e8577f4.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1F502015307DB4390B232A30"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1F502015307DB4390B232A30
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Andrew Morton wrote:
> Ulrich, could you suggest a little test app which would demonstrate thi=
s
> behaviour?

It's not really reliably possible to demonstrate this with a small
program using malloc.  You'd need something like this mysql test case
which Rik said is not hard to run by yourself.

If somebody adds a kernel interface I can easily produce a glibc patch
so that the test can be run in the new environment.

But it's of course easy enough to simulate the specific problem in a
micro benchmark.  If you want that let me know.


> Question:
>=20
>>   - if an access to a page in the range happens in the future it must
>>     succeed.  The old page content can be provided or a new, empty pag=
e
>>    can be provided
>=20
> How important is this "use the old page if it is available" feature?  I=
f we
> were to simply implement a fast unconditional-free-the-page, so that
> subsequent accesses always returned a new, zeroed page, do we expect th=
at
> this will be a 90%-good-enough thing, or will it be significantly
> inefficient?

My guess is that the page fault you'd get for every single page is a
huge part of the problem.  If you don't free the pages and just leave
them in the process processes which quickly reuse the memory pool will
experience no noticeable slowdown.  The only difference between not
freeing the memory and and doing it is that one madvise() syscall.

If you unconditionally free the page you we have later mprotect() call
(one mmap_sem lock saved).  But does every page fault then later
requires the semaphore?  Even if not, the additional kernel entry is a
killer.


> So perhaps we can do something like chop swapper_space in half: the low=
er
> 50% represent offsets which have a swap mapping and the upper 50% are f=
ake
> swapcache pages which don't actually consume swapspace.  These pages ar=
e
> unmapped from pagetables, marked clean, added to the fake part of
> swapper_space and are deactivated.  Teach the low-level swap code to ig=
nore
> the request to free physical swapspace when these pages are released.

Sounds good to me.


> This would all halve the maximum amount of swap which can be used.  iir=
c
> i386 supports 27 bits of swapcache indexing, and 26 bits is 274GB, whic=
h
> is hopefully enough..

Boo hoo, poor 32-bit machines.  People with demands of > 274G should get
a real machine instead.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig1F502015307DB4390B232A30
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGErZF2ijCOnn/RHQRAu++AJ9FazwG4bmLpaj6xT8kwX5pDWXwIwCfSkpF
gYkCegV2XjzCBQFae+i4RkE=
=8yjW
-----END PGP SIGNATURE-----

--------------enig1F502015307DB4390B232A30--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
