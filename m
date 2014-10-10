Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id BBBAB6B0038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 10:19:01 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so3349371lab.33
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 07:19:01 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id k3si9473738lag.80.2014.10.10.07.18.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Oct 2014 07:18:59 -0700 (PDT)
Received: by mail-la0-f42.google.com with SMTP id mk6so3296224lab.15
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 07:18:59 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm/cma: fix cma bitmap aligned mask computing
In-Reply-To: <000301cfe430$504b0290$f0e107b0$%yang@samsung.com>
References: <000301cfe430$504b0290$f0e107b0$%yang@samsung.com>
Date: Fri, 10 Oct 2014 16:18:54 +0200
Message-ID: <xa1tvbns2ek1.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com
Cc: aneesh.kumar@linux.vnet.ibm.com, m.szyprowski@samsung.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Fri, Oct 10 2014, Weijie Yang wrote:
> The current cma bitmap aligned mask compute way is incorrect, it could
> cause an unexpected align when using cma_alloc() if wanted align order
> is bigger than cma->order_per_bit.
>
> Take kvm for example (PAGE_SHIFT =3D 12), kvm_cma->order_per_bit is set t=
o 6,
> when kvm_alloc_rma() tries to alloc kvm_rma_pages, it will input 15 as
> expected align value, after using current computing, however, we get 0 as
> cma bitmap aligned mask other than 511.
>
> This patch fixes the cma bitmap aligned mask compute way.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

Should that also get:

Cc: <stable@vger.kernel.org> # v3.17

> ---
>  mm/cma.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..f6207ef 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -57,7 +57,10 @@ unsigned long cma_get_size(struct cma *cma)
>=20=20
>  static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_=
order)
>  {
> -	return (1UL << (align_order >> cma->order_per_bit)) - 1;
> +	if (align_order <=3D cma->order_per_bit)
> +		return 0;
> +	else
> +		return (1UL << (align_order - cma->order_per_bit)) - 1;
>  }
>=20=20
>  static unsigned long cma_bitmap_maxno(struct cma *cma)
> --=20
> 1.7.10.4
>
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
