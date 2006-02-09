From: Nigel Cunningham <ncunningham@cyclades.com>
Subject: Re: [PATCH] Dynamically allocated pageflags
Date: Thu, 9 Feb 2006 17:08:50 +1000
References: <200602022111.32930.ncunningham@cyclades.com> <aec7e5c30602082300i6257606csdc005e6a442bfec5@mail.gmail.com>
In-Reply-To: <aec7e5c30602082300i6257606csdc005e6a442bfec5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1677869.3OgWD5gCV2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200602091708.55203.ncunningham@cyclades.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

--nextPart1677869.3OgWD5gCV2
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi.

On Thursday 09 February 2006 17:00, Magnus Damm wrote:
> Hi Nigel,
>=20
> On 2/2/06, Nigel Cunningham <ncunningham@cyclades.com> wrote:
> > Hi everyone.
> >
> > This is my latest revision of the dynamically allocated pageflags patch.
> >
> > The patch is useful for kernel space applications that sometimes need t=
o flag
> > pages for some purpose, but don't otherwise need the retain the state. =
A prime
> > example is suspend-to-disk, which needs to flag pages as unsaveable, al=
located
> > by suspend-to-disk and the like while it is working, but doesn't need to
> > retain any of this state between cycles.
> >
> > Since the last revision, I have switched to using per-zone bitmaps with=
in each
> > bitmap.
> >
> > I know that I could still add hotplug memory support. Is there anything=
 else
> > missing?
>=20
> I like the idea of the patch, but the code looks a bit too complicated
> IMO. What is wrong with using vmalloc() to allocate a virtual
> contiguous range of 0-order pages (one bit per page), and then use the
> functions in linux/bitmap.h...? Or maybe I'm misunderstanding.
>=20
> A system that has 2 GB RAM and 4 KB pages would use 64 KB per bitmap
> (one bitmap per node), which is not so bad memory wise if you plan to
> use all bits.
>=20
> OTOH, if your plan is to use a single bit here and there, and leave
> most of the bits unused then some kind of tree is probably better.
>=20
> Or does the kernel already implement some kind of data structure that
> never consumes _that_ much more space than a bitmap when fully used,
> and saves a lot of memory when just sparsely populated?

Thanks for the suggestion - I'll look into it too.

Part of my reason for implementing them in this way was to make serialising
the data in an image header easy, when suspending to disk. I use the
bitmaps to record which pages were atomically copied, and generate a
similar bitmap for addresses of the freshly loaded pages prior to restoring
the image at resume time. Of course the routines that does the atomic
restore also iterates through these bitmaps. I'm not sure whether that
changes anything, but thought it was worth mentioning.

Regards,

Nigel

--nextPart1677869.3OgWD5gCV2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD6uqHN0y+n1M3mo0RAuN8AJ0Tj2oyCYl75j7nX4FeVfaAV8C4rACfTy7D
IVrUAY5iDiPHloiSzGVLtBU=
=yYbh
-----END PGP SIGNATURE-----

--nextPart1677869.3OgWD5gCV2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
