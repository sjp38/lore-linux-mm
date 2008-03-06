From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Thu, 6 Mar 2008 22:07:34 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061151590.14140@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061151590.14140@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1270130.ioZNWOnPkE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803062207.37654.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart1270130.ioZNWOnPkE
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


Hi,

> > Call Trace:
> > [c00000003c187b68] [c00000000000f140] .show_stack+0x70/0x1bc (unreliabl=
e)
> > [c00000003c187c18] [c000000000052d0c] .__schedule_bug+0x64/0x80
> > [c00000003c187ca8] [c00000000036fa84] .schedule+0xc4/0x6b0
> > [c00000003c187d98] [c0000000003702d0] .schedule_timeout+0x3c/0xe8
> > [c00000003c187e68] [c00000000036f82c] .wait_for_common+0x150/0x22c
> > [c00000003c187f28] [c000000000074868] .kthreadd+0x12c/0x1f0
> > [c00000003c187fd8] [c000000000024864] .kernel_thread+0x4c/0x68
>=20
> But nothing slub wise here...

I had earlier biesected this to the following commit, should have mentioned=
 that,
sorry !

commit f0630fff54a239efbbd89faf6a62da071ef1ff78
Author: Christoph Lameter <clameter@sgi.com>
Date:   Sun Jul 15 23:38:14 2007 -0700

    SLUB: support slub_debug on by default

    [...]

> Could be the result of fallback under debug?? Looks like there is a hole=
=20
> in the fallback logic. But this could be something completely different.

What do you mean by fallback ?

> If this is slub related then we may not be reenabling interrupt somewhere=
=20
> if debug is on.
>=20
> diff --git a/mm/slub.c b/mm/slub.c
> index 96d63eb..6d0a103 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1536,8 +1536,14 @@ new_slab:
>  	 * That is only possible if certain conditions are met that are being
>  	 * checked when a slab is created.
>  	 */
> -	if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK))
> -		return kmalloc_large(s->objsize, gfpflags);
> +	if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK)) {
> +		if (gfpflags & __GFP_WAIT)
> +			local_irq_enable();
> +		object =3D  kmalloc_large(s->objsize, gfpflags);
> +		if (gfpflags & __GFP_WAIT)
> +			local_irq_disable();
> +		return object;
> +	}
> =20
>  	return NULL;
>  debug:

I just tried the patch, but the problem is still there...

Gru=DF,
	Jens

--nextPart1270130.ioZNWOnPkE
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0F0ZP1aZ9bkt7XMRAiYEAJ90Z/fiuRRhz90Z8Xxf5LRf/LFZ+ACfZAor
8ovHS0KkChxKF7GlfYOqvRQ=
=v1At
-----END PGP SIGNATURE-----

--nextPart1270130.ioZNWOnPkE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
