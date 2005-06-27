Subject: Re: [PATCH] 2/2 swap token tuning
From: Martin Schlemmer <azarah@nosferatu.za.org>
Reply-To: azarah@nosferatu.za.org
In-Reply-To: <Pine.LNX.4.61.0506261835000.18834@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
	 <Pine.LNX.4.61.0506261835000.18834@chimarrao.boston.redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-M4gTGr63h7h4Xz00N2GD"
Date: Mon, 27 Jun 2005 15:04:25 +0200
Message-Id: <1119877465.25717.4.camel@lycan.lan>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Song Jiang <sjiang@lanl.gov>
List-ID: <linux-mm.kvack.org>

--=-M4gTGr63h7h4Xz00N2GD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2005-06-26 at 18:35 -0400, Rik Van Riel wrote:

<snip>

> This patch should have the effect of automatically, and gradually,
> disabling the enforcement of the swap token when there is little
> or no paging going on, and "turning up" the intensity of the swap
> token code the more the task holding the token is thrashing.
>=20
> Thanks to Song Jiang for pointing out this aspect of the token
> based thrashing control concept.
>=20
> Signed-off-by: Rik van Riel
>=20

<snip>

I might be missing something here, but shouldn't this rather be:

> --- 2.6.12-swaptoken/mm/rmap.c.orig	2005-06-26 17:16:50.000000000 -0400
> +++ 2.6.12-swaptoken/mm/rmap.c	2005-06-26 17:13:17.000000000 -0400
> @@ -301,7 +301,11 @@ static int page_referenced_one(struct pa
>  		if (ptep_clear_flush_young(vma, address, pte))
>  			referenced++;
> =20
> -		if (mm !=3D current->mm && !ignore_token && has_swap_token(mm))
> +		/* Pretend the page is referenced if the task has the
> +		   swap token and is in the middle of a page fault. */
> +		if (mm !=3D current->mm && !ignore_token &&
> +				has_swap_token(mm) &&
-+				sem_is_read_locked(mm->mmap_sem))
+                               sem_is_read_locked(&mm->mmap_sem))

As mm is a pointer, but mm->mmap_sem is not a pointer?  This is with
2.6.12-mm2 though ...


Thanks,

--=20
Martin Schlemmer


--=-M4gTGr63h7h4Xz00N2GD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCv/lYqburzKaJYLYRAsfSAJ4hm/JypAiLnDDDH6lDbsIPc8h6ugCdGcPR
vuqd+Qa1yF/i/nKhcVOusf0=
=C0C0
-----END PGP SIGNATURE-----

--=-M4gTGr63h7h4Xz00N2GD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
