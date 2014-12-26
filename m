Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 14B4D6B0071
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 11:10:52 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so17337507wiv.6
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:10:51 -0800 (PST)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id i17si43101980wiv.21.2014.12.26.08.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 08:10:51 -0800 (PST)
Received: by mail-wg0-f46.google.com with SMTP id x13so14656550wgg.19
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:10:51 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
In-Reply-To: <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
Date: Fri, 26 Dec 2014 17:10:47 +0100
Message-ID: <xa1twq5ez914.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

On Fri, Dec 26 2014, "Stefan I. Strogin" <s.strogin@partner.samsung.com> wr=
ote:
> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region.
> Added that information in cmainfo.
>
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/linux/cma.h |  2 ++
>  mm/cma.c            | 34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 36 insertions(+)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 9384ba6..855e6f2 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -18,6 +18,8 @@ struct cma;
>  extern unsigned long totalcma_pages;
>  extern phys_addr_t cma_get_base(struct cma *cma);
>  extern unsigned long cma_get_size(struct cma *cma);
> +extern unsigned long cma_get_used(struct cma *cma);
> +extern unsigned long cma_get_maxchunk(struct cma *cma);
>=20=20
>  extern int __init cma_declare_contiguous(phys_addr_t base,
>  			phys_addr_t size, phys_addr_t limit,
> diff --git a/mm/cma.c b/mm/cma.c
> index ffaea26..5e560ed 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -78,6 +78,36 @@ unsigned long cma_get_size(struct cma *cma)
>  	return cma->count << PAGE_SHIFT;
>  }
>=20=20
> +unsigned long cma_get_used(struct cma *cma)
> +{
> +	unsigned long ret =3D 0;
> +
> +	mutex_lock(&cma->lock);
> +	/* pages counter is smaller than sizeof(int) */
> +	ret =3D bitmap_weight(cma->bitmap, (int)cma->count);
> +	mutex_unlock(&cma->lock);
> +
> +	return ret << (PAGE_SHIFT + cma->order_per_bit);
> +}
> +
> +unsigned long cma_get_maxchunk(struct cma *cma)
> +{
> +	unsigned long maxchunk =3D 0;
> +	unsigned long start, end =3D 0;
> +
> +	mutex_lock(&cma->lock);
> +	for (;;) {
> +		start =3D find_next_zero_bit(cma->bitmap, cma->count, end);
> +		if (start >=3D cma->count)
> +			break;
> +		end =3D find_next_bit(cma->bitmap, cma->count, start);
> +		maxchunk =3D max(end - start, maxchunk);
> +	}
> +	mutex_unlock(&cma->lock);
> +
> +	return maxchunk << (PAGE_SHIFT + cma->order_per_bit);
> +}
> +
>  static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_=
order)
>  {
>  	if (align_order <=3D cma->order_per_bit)
> @@ -591,6 +621,10 @@ static int s_show(struct seq_file *m, void *p)
>  	struct cma_buffer *cmabuf;
>  	struct stack_trace trace;
>=20=20
> +	seq_printf(m, "CMARegion stat: %8lu kB total, %8lu kB used, %8lu kB max=
 contiguous chunk\n\n",
> +		   cma_get_size(cma) >> 10,
> +		   cma_get_used(cma) >> 10,
> +		   cma_get_maxchunk(cma) >> 10);
>  	mutex_lock(&cma->list_lock);
>=20=20
>  	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
> --=20
> 2.1.0
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
