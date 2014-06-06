Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3A36B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 07:56:25 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id a108so4202627qge.11
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 04:56:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s7si12770407qat.102.2014.06.06.04.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 04:56:24 -0700 (PDT)
Date: Fri, 6 Jun 2014 13:56:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: rmap: fix use-after-free in __put_anon_vma
Message-ID: <20140606115620.GS3213@twins.programming.kicks-ass.net>
References: <1402054255-4930-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZmeoGP/RI+eIV+cU"
Content-Disposition: inline
In-Reply-To: <1402054255-4930-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dvyukov@google.com, koct9i@gmail.com, v3.0+@samsung.com


--ZmeoGP/RI+eIV+cU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 06, 2014 at 03:30:55PM +0400, Andrey Ryabinin wrote:
> While working address sanitizer for kernel I've discovered use-after-free
> bug in __put_anon_vma.
> For the last anon_vma, anon_vma->root freed before child anon_vma.
> Later in anon_vma_free(anon_vma) we are referencing to already freed anon=
_vma->root
> to check rwsem.
> This patch puts freeing of child anon_vma before freeing of anon_vma->roo=
t.

Yes, I think that is right indeed.

Very hard to hit, but valid since not all callers hold rcu_read_lock().

>=20
> Cc: stable@vger.kernel.org # v3.0+
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  mm/rmap.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9c3e773..161bffc7 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1564,10 +1564,11 @@ void __put_anon_vma(struct anon_vma *anon_vma)
>  {
>  	struct anon_vma *root =3D anon_vma->root;
> =20
> -	if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount))
> +	if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount)) {
> +		anon_vma_free(anon_vma);
>  		anon_vma_free(root);
> -
> -	anon_vma_free(anon_vma);
> +	} else
> +		anon_vma_free(anon_vma);
>  }

Why not simply move the freeing of anon_vma before the root, like:

	anon_vma_free(anon_vma);
	if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount))
		anon_vma_free(root);

?

--ZmeoGP/RI+eIV+cU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTkaxjAAoJEHZH4aRLwOS6XegP/0dLJTOi+1Z3MD2hcFmdr5vl
Cjn3A7TqGmn3AUQU5PFXGUAFj5eT4mQewruH8za7tcME+M7iN/ReDf0OWMRlejae
Yaz2PzSusdiBuZ2qQKvLiPSzKDfx0sgi9ElbI24Yhvck1dFUrHZf1o6HcsuBlnFq
zjnbNnL6wZ0RwgP05WEd9cc1eCRGEsVXO1kZ/4bc/sFBH2YKxHgROEvNwErJxl6K
o+HIay3vINfYzPv9NNIk7V+HRFD79UJ+rbp7Su8zXcoBj/SyfkcwQxzPvXG7SV13
3z5RW/E6TNj9vUWM2uOdzUAhikmayLAog+fllM5Uq8mY8C/jiOeWFo3v3doUggux
PH2uDf11vhUESxNyd5Qg11XUcq407NuO3xlw4CzBsCaozivix1Hbedck2StiOdoB
LMH1QmwjZlUvR3Pyu+RSJMYBsEL+wlEn6o1OpaeWDEezaepoEG5ykiubMy7U2EWm
FXHoq9337NIWCiFYTnvpqMR5iFwSHHI5yEesFEh0MxSGTZkv39wVAQp0ZVyW8nmB
SHATVUf+FDFu4GST8WRFfBwzUayyiMMV7LrjYuLMpCbSNGk7Bu81TA5vmTbjuPL0
pivuSCMtnko0qslBC0PJAOMGiUURMGJt9/ZpeJVlB434dbjSttsIuE+q3odEOPPb
vO+WQlT9e7lS2VhiqTuS
=ZZYw
-----END PGP SIGNATURE-----

--ZmeoGP/RI+eIV+cU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
