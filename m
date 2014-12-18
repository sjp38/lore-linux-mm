Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 34D756B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 14:20:20 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so2849851wid.9
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:20:19 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id n1si34011619wix.100.2014.12.18.11.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 11:20:18 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so2858620wid.3
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:20:18 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH] mm: cma: add functions for getting allocation info
In-Reply-To: <1418854236-25140-1-git-send-email-gregory.0xf0@gmail.com>
References: <1418854236-25140-1-git-send-email-gregory.0xf0@gmail.com>
Date: Thu, 18 Dec 2014 20:20:13 +0100
Message-ID: <xa1th9wssr2q.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org
Cc: Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, open list <linux-kernel@vger.kernel.org>

On Wed, Dec 17 2014, Gregory Fong <gregory.0xf0@gmail.com> wrote:
> These functions allow for retrieval of information on what is allocated f=
rom
> within a given CMA region.  It can be useful to know the number of distin=
ct
> contiguous allocations and where in the region those allocations are loca=
ted.
>
> Based on an initial version by Marc Carino <marc.ceeeee@gmail.com> in a d=
river
> that used the CMA bitmap directly; this instead moves the logic into the =
core
> CMA API.
>
> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
> ---
> This has been really useful for us to determine allocation information fo=
r a
> CMA region.  We have had a separate driver that might not be appropriate =
for
> upstream, but allowed using a user program to run CMA unit tests to verif=
y that
> allocations end up where they we would expect.  This addition would allow=
 for
> that without needing to expose the CMA bitmap.  Wanted to put this out th=
ere to
> see if anyone else would be interested, comments and suggestions welcome.

I don't like it at all.  For example, cma_get_alloc_info has O(n^2)
complexity if one wishes to get information about all allocation.
Furthermore, it's prone to race conditions.  If all you need this for is
debugging and testing, why not have user space parse output of dmesg?
With debug messages enabled, CMA prints ranges it allocated and testing
tool can figure out CMA's behaviour based on that.

>  include/linux/cma.h |  3 ++
>  mm/cma.c            | 91 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  2 files changed, 94 insertions(+)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index a93438b..bc676e5 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -25,6 +25,9 @@ extern int __init cma_declare_contiguous(phys_addr_t ba=
se,
>  extern int cma_init_reserved_mem(phys_addr_t base,
>  					phys_addr_t size, int order_per_bit,
>  					struct cma **res_cma);
> +extern int cma_get_alloc_info(struct cma *cma, int index, phys_addr_t *b=
ase,
> +		phys_addr_t *size);
>  extern struct page *cma_alloc(struct cma *cma, int count, unsigned int a=
lign);
> +extern int cma_get_alloc_count(struct cma *cma);
>  extern bool cma_release(struct cma *cma, struct page *pages, int count);
>  #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index f891762..fc9a04a 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -447,3 +447,94 @@ bool cma_release(struct cma *cma, struct page *pages=
, int count)
>=20=20
>  	return true;
>  }
> +
> +enum cma_scan_type {
> +	GET_NUM_ALLOCS,
> +	GET_ALLOC_INFO,
> +};
> +
> +struct cma_scan_bitmap_res {
> +	int index;             /* index of allocation (input) */
> +	unsigned long offset;  /* offset into bitmap */
> +	unsigned long size;    /* size in bits */
> +	int num_allocs;        /* number of allocations */
> +};
> +
> +static int cma_scan_bitmap(struct cma *cma, enum cma_scan_type op,
> +		struct cma_scan_bitmap_res *res)
> +{
> +	unsigned long i =3D 0, pos_head =3D 0, pos_tail;
> +	int count =3D 0, head_found =3D 0;
> +
> +	if (!cma)
> +		return -EFAULT;
> +
> +	/* Count the number of contiguous chunks */
> +	do {
> +		if (head_found) {
> +			pos_tail =3D find_next_zero_bit(cma->bitmap, cma->count,
> +						      i);
> +
> +			if (op =3D=3D GET_ALLOC_INFO && count =3D=3D res->index) {
> +				res->offset =3D pos_head;
> +				res->size =3D pos_tail - pos_head;
> +				return 0;
> +			}
> +			count++;
> +
> +			head_found =3D 0;
> +			i =3D pos_tail + 1;
> +
> +		} else {
> +			pos_head =3D find_next_bit(cma->bitmap, cma->count, i);
> +			i =3D pos_head + 1;
> +			head_found =3D 1;
> +		}
> +	} while (i < cma->count);
> +
> +	if (op =3D=3D GET_NUM_ALLOCS) {
> +		res->num_allocs =3D count;
> +		return 0;
> +	} else {
> +		return -EINVAL;
> +	}
> +}
> +
> +/**
> + * cma_get_alloc_info() - Get info on the requested allocation
> + * @cma:   Contiguous memory region for which the allocation is performe=
d.
> + * @index: Index of the allocation to get info for
> + * @base:  Base address of the allocation
> + * @size:  Size of the allocation in bytes
> + *
> + * Return: 0 on success, negative on failure
> + */
> +int cma_get_alloc_info(struct cma *cma, int index, phys_addr_t *base,
> +		phys_addr_t *size)
> +{
> +	struct cma_scan_bitmap_res res;
> +	int ret;
> +
> +	res.index =3D index;
> +	ret =3D cma_scan_bitmap(cma, GET_ALLOC_INFO, &res);
> +	if (ret)
> +		return ret;
> +
> +	*base =3D cma_get_base(cma) + PFN_PHYS(res.offset << cma->order_per_bit=
);
> +	*size =3D PFN_PHYS(res.size << cma->order_per_bit);
> +	return 0;
> +}
> +
> +/**
> + * cma_get_alloc_count() - Get number of allocations
> + * @cma:   Contiguous memory region for which the allocation is performe=
d.
> + *
> + * Return: number of allocations on success, negative on failure
> + */
> +int cma_get_alloc_count(struct cma *cma)
> +{
> +	struct cma_scan_bitmap_res res;
> +	int ret =3D cma_scan_bitmap(cma, GET_NUM_ALLOCS, &res);
> +
> +	return (ret < 0) ? ret : res.num_allocs;
> +}
> --=20
> 1.9.1
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
