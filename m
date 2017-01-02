Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7B96B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 01:46:23 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id y21so167123514lfa.0
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 22:46:23 -0800 (PST)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id x23si37903028lfi.44.2017.01.01.22.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jan 2017 22:46:21 -0800 (PST)
Received: by mail-lf0-x22a.google.com with SMTP id y21so265853637lfa.1
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 22:46:21 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
In-Reply-To: <5869E849.1040605@samsung.com>
References: <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com> <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com> <20161229091449.GG29208@dhcp22.suse.cz> <xa1th95m7r6w.fsf@mina86.com> <58660BBE.1040807@samsung.com> <20161230094411.GD13301@dhcp22.suse.cz> <xa1tpok6igqb.fsf@mina86.com> <5869E849.1040605@samsung.com>
Date: Mon, 02 Jan 2017 07:46:16 +0100
Message-ID: <xa1tmvfahscn.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Mon, Jan 02 2017, Jaewon Kim wrote:
> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, E=
INTR.
> But we did not know error reason so far. This patch prints the error valu=
e.
>
> Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap stat=
us to
> know available pages. Actually CMA internally tries on all available regi=
ons
> because some regions can be failed because of EBUSY. Bitmap status is use=
ful to
> know in detail on both ENONEM and EBUSY;
>  ENOMEM: not tried at all because of no available region
>          it could be too small total region or could be fragmentation iss=
ue
>  EBUSY:  tried some region but all failed
>
> This is an ENOMEM example with this patch.
> [   12.415458]  [2:   Binder:714_1:  744] cma: cma_alloc: alloc failed, r=
eq-size: 256 pages, ret: -12
> If CONFIG_CMA_DEBUG is enabled, avabile pages also will be shown as conca=
tenated
> size@position format. So 4@572 means that there are 4 available pages at =
572
> position starting from 0 position.
> [   12.415503]  [2:   Binder:714_1:  744] cma: number of available pages:=
 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=3D> 357 free of 2048 tota=
l pages
>
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> ---
>  mm/cma.c | 34 +++++++++++++++++++++++++++++++++-
>  1 file changed, 33 insertions(+), 1 deletion(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c960459..9e037541 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -353,6 +353,32 @@ int __init cma_declare_contiguous(phys_addr_t base,
>      return ret;
>  }
>=20=20
> +#ifdef CONFIG_CMA_DEBUG
> +static void debug_show_cma_areas(struct cma *cma)

Make it =E2=80=98cma_debug_show_areas=E2=80=99.  All other functions have =
=E2=80=98cma=E2=80=99 as
prefix so that=E2=80=99s more consistent.

> +{
> +    unsigned long next_zero_bit, next_set_bit;
> +    unsigned long start =3D 0;
> +    unsigned int nr_zero, nr_total =3D 0;
> +
> +    mutex_lock(&cma->lock);
> +    pr_info("number of available pages: ");
> +    for (;;) {
> +        next_zero_bit =3D find_next_zero_bit(cma->bitmap, cma->count, st=
art);
> +        if (next_zero_bit >=3D cma->count)
> +            break;
> +        next_set_bit =3D find_next_bit(cma->bitmap, cma->count, next_zer=
o_bit);
> +        nr_zero =3D next_set_bit - next_zero_bit;
> +        pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
> +        nr_total +=3D nr_zero;
> +        start =3D next_zero_bit + nr_zero;
> +    }
> +    pr_cont("=3D> %u free of %lu total pages\n", nr_total, cma->count);
> +    mutex_unlock(&cma->lock);
> +}
> +#else
> +static inline void debug_show_cma_areas(struct cma *cma) { }
> +#endif
> +
>  /**
>   * cma_alloc() - allocate pages from contiguous area
>   * @cma:   Contiguous memory region for which the allocation is performe=
d.
> @@ -369,7 +395,7 @@ struct page *cma_alloc(struct cma *cma, size_t count,=
 unsigned int align)
>      unsigned long start =3D 0;
>      unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>      struct page *page =3D NULL;
> -    int ret;
> +    int ret =3D -ENOMEM;
>=20=20
>      if (!cma || !cma->count)
>          return NULL;
> @@ -426,6 +452,12 @@ struct page *cma_alloc(struct cma *cma, size_t count=
, unsigned int align)
>=20=20
>      trace_cma_alloc(pfn, page, count, align);
>=20=20
> +    if (ret) {
> +        pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
> +            __func__, count, ret);
> +        debug_show_cma_areas(cma);
> +    }
> +
>      pr_debug("%s(): returned %p\n", __func__, page);
>      return page;
>  }
> --=20
>

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
