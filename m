Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 774056B0035
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 09:34:27 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so12280843wev.41
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 06:34:26 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id hk5si51489481wjb.112.2014.08.24.06.34.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 06:34:26 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id k48so12388878wev.27
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 06:34:25 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: cma: adjust address limit to avoid hitting low/high memory boundary
In-Reply-To: <1408610714-16204-2-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com> <1408610714-16204-2-git-send-email-m.szyprowski@samsung.com>
Date: Sun, 24 Aug 2014 15:34:21 +0200
Message-ID: <xa1ty4ueui3m.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 21 2014, Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> Automatically allocated regions should not cross low/high memory boundary,
> because such regions cannot be later correctly initialized due to spanning
> across two memory zones. This patch adds a check for this case and a simp=
le
> code for moving region to low memory if automatically selected address mi=
ght
> not fit completely into high memory.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c0dcaf..4acc6aa4a086 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -32,6 +32,7 @@
>  #include <linux/slab.h>
>  #include <linux/log2.h>
>  #include <linux/cma.h>
> +#include <linux/highmem.h>
>=20=20
>  struct cma {
>  	unsigned long	base_pfn;
> @@ -163,6 +164,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  			bool fixed, struct cma **res_cma)
>  {
>  	struct cma *cma;
> +	phys_addr_t memblock_end =3D memblock_end_of_DRAM();
> +	phys_addr_t highmem_start =3D __pa(high_memory);
>  	int ret =3D 0;
>=20=20
>  	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
> @@ -196,6 +199,24 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
>  		return -EINVAL;
>=20=20
> +	/*
> +	 * adjust limit to avoid crossing low/high memory boundary for
> +	 * automatically allocated regions
> +	 */
> +	if (((limit =3D=3D 0 || limit > memblock_end) &&
> +	     (memblock_end - size < highmem_start &&
> +	      memblock_end > highmem_start)) ||
> +	    (!fixed && limit > highmem_start && limit - size < highmem_start)) {
> +		limit =3D highmem_start;
> +	}
> +
> +	if (fixed && base < highmem_start && base+size > highmem_start) {
> +		ret =3D -EINVAL;
> +		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
> +			(unsigned long)base, (unsigned long)highmem_start);
> +		goto err;
> +	}
> +
>  	/* Reserve memory */
>  	if (base && fixed) {
>  		if (memblock_is_region_reserved(base, size) ||
> --=20
> 1.9.2
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
