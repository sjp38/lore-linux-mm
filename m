Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC0566B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 15:53:08 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q13-v6so15544156qtk.8
        for <linux-mm@kvack.org>; Mon, 21 May 2018 12:53:08 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id r8-v6si14735173qkr.151.2018.05.21.12.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 12:53:07 -0700 (PDT)
Message-ID: <1526932382.7898.25.camel@surriel.com>
Subject: Re: [PATCH] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
From: Rik van Riel <riel@surriel.com>
Date: Mon, 21 May 2018 15:53:02 -0400
In-Reply-To: <20180521193853.3089484-1-songliubraving@fb.com>
References: <20180521193853.3089484-1-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-gFG4TwXSJeSRiOik4kOd"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>


--=-gFG4TwXSJeSRiOik4kOd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-05-21 at 12:38 -0700, Song Liu wrote:

> This patch fixes these problems by reusing hugepage_vma_check() in
> khugepaged_enter_vma_merge().

Lets take a look at this in more detail. This effectively
adds the following conditions to khugepaged_enter_vma_merge:
- fail if MMF_DISABLE_THP bit is set in mm->flags (good)
- allow if merging a tmpfs file and THP tmpfs is enabled (good)
- disallow if is_vma_temporary_stack (good)
- otherwise, allow if !VM_NO_KHUGEPAGED flag (good)

Looks like this covers all the conditions I can think
of, and if I missed any, chances are that condition
should be added to hugepage_vma_check()...

> Signed-off-by: Song Liu <songliubraving@fb.com>

Reviewed-by: Rik van Riel <riel@surriel.com>

> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index d7b2a4b..e50c2bd 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -430,18 +430,14 @@ int __khugepaged_enter(struct mm_struct *mm)
>  	return 0;
>  }
> =20
> +static bool hugepage_vma_check(struct vm_area_struct *vma);
> +
>  int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>  			       unsigned long vm_flags)
>  {
>  	unsigned long hstart, hend;
> -	if (!vma->anon_vma)
> -		/*
> -		 * Not yet faulted in so we will register later in
> the
> -		 * page fault if needed.
> -		 */
> -		return 0;
> -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
> -		/* khugepaged not yet working on file or special
> mappings */
> +
> +	if (!hugepage_vma_check(vma))
>  		return 0;
>  	hstart =3D (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>  	hend =3D vma->vm_end & HPAGE_PMD_MASK;
--=20
All Rights Reversed.
--=-gFG4TwXSJeSRiOik4kOd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlsDI54ACgkQznnekoTE
3oMCiwf/eCQXtvuRmecOTXmKDXTdWl4r0FV4dg+yCU2DrxjNF1PP6FzKZa2jKwHd
MapKKr6jOt3ezevqOmO/Z1/9OHVqmW5cSzxo9iavl/aYB5WtcL8Ks29NIFidYWBu
Q5vzOldZhEH5X7uZ0NP1dz0zNbAKBfvVKMQze6c6QqV9puk97glyK1mRJBw9Vw45
kC30OP5XhCT/Nm3pFLJudb/XM3rCCrvFqOrO1/9Lhg0Mh9EwkTzAk5XwDiMq45sv
GKnjf+gSQzPiLTr3wE6iIOm7OLY6NWWUJVdcfzcMyFYreD9KY3mGveTi2Bj86aVQ
2QMk3YwhEyOEnbkWx8JoBOKRZwuIGw==
=H/U/
-----END PGP SIGNATURE-----

--=-gFG4TwXSJeSRiOik4kOd--
