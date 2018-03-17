Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B91EB6B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 22:04:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n67so64423qkn.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 19:04:11 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a130si8861346qkg.40.2018.03.16.19.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 19:04:10 -0700 (PDT)
Subject: Re: [PATCH 04/14] mm/hmm: hmm_pfns_bad() was accessing wrong struct
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-5-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <88cd1c14-f4eb-cfc3-4f6a-ba669832dad7@nvidia.com>
Date: Fri, 16 Mar 2018 19:04:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-5-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> The private field of mm_walk struct point to an hmm_vma_walk struct and
> not to the hmm_range struct desired. Fix to get proper struct pointer.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: stable@vger.kernel.org
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6088fa6ed137..64d9e7dae712 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -293,7 +293,8 @@ static int hmm_pfns_bad(unsigned long addr,
>  			unsigned long end,
>  			struct mm_walk *walk)
>  {
> -	struct hmm_range *range =3D walk->private;
> +	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	struct hmm_range *range =3D hmm_vma_walk->range;
>  	hmm_pfn_t *pfns =3D range->pfns;
>  	unsigned long i;
> =20

This fix looks good. I also checked the other uses of walk->private, of cou=
rse,=20
but it was only this one that was wrong.

I think this patch also belongs in -stable, because it is a simple bug fix.

For the description, well...actually, because ->range is the first element =
in
struct hmm_vma_walk, you probably end up with the same pointer value, both
before and after this fix. So maybe there are no symptoms to see. Maybe tha=
t's
an argument for *not* putting it in -stable, too. I'll leave that question
to more experienced people.

Either way, you can add:=20

Reviewed by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA
=20
