Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2B65B6B00E8
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:20:00 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so1025695wes.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:19:59 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id e17si26237705wiw.8.2014.06.12.03.19.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 03:19:58 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so6503249wiw.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:19:58 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 05/10] DMA, CMA: support arbitrary bitmap granularity
In-Reply-To: <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 12 Jun 2014 12:19:54 +0200
Message-ID: <xa1t61k6juph.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> ppc kvm's cma region management requires arbitrary bitmap granularity,
> since they want to reserve very large memory and manage this region
> with bitmap that one bit for several pages to reduce management overheads.
> So support arbitrary bitmap granularity for following generalization.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index bc4c171..9bc9340 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -38,6 +38,7 @@ struct cma {
>  	unsigned long	base_pfn;
>  	unsigned long	count;

Have you considered replacing count with maxno?

>  	unsigned long	*bitmap;
> +	int order_per_bit; /* Order of pages represented by one bit */

I'd make it unsigned.

>  	struct mutex	lock;
>  };
>=20=20
> +static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int
> count)

For consistency cma_clear_bitmap would make more sense I think.  On the
other hand, you're just moving stuff around so perhaps renaming the
function at this point is not worth it any more.

> +{
> +	unsigned long bitmapno, nr_bits;
> +
> +	bitmapno =3D (pfn - cma->base_pfn) >> cma->order_per_bit;
> +	nr_bits =3D cma_bitmap_pages_to_bits(cma, count);
> +
> +	mutex_lock(&cma->lock);
> +	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> +	mutex_unlock(&cma->lock);
> +}
> +
>  static int __init cma_activate_area(struct cma *cma)
>  {
> -	int bitmap_size =3D BITS_TO_LONGS(cma->count) * sizeof(long);
> +	int bitmap_maxno =3D cma_bitmap_maxno(cma);
> +	int bitmap_size =3D BITS_TO_LONGS(bitmap_maxno) * sizeof(long);
>  	unsigned long base_pfn =3D cma->base_pfn, pfn =3D base_pfn;
>  	unsigned i =3D cma->count >> pageblock_order;
>  	struct zone *zone;

bitmap_maxno is never used again, perhaps:

+	int bitmap_size =3D BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);

instead? Up to you.

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
