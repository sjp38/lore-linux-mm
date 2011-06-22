Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA56990015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 02:54:02 -0400 (EDT)
Received: by yxn22 with SMTP id 22so266720yxn.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:53:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308556213-24970-9-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-9-git-send-email-m.szyprowski@samsung.com>
Date: Wed, 22 Jun 2011 15:53:55 +0900
Message-ID: <BANLkTikE6qziSZhcyx4HxWqpmg0eZhR+wg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 8/8] ARM: dma-mapping: use alloc, mmap,
 free from dma_ops
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>

Hi.

On Mon, Jun 20, 2011 at 4:50 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:

> -extern void *dma_alloc_coherent(struct device *, size_t, dma_addr_t *, g=
fp_t);
> +extern void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *=
handle,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp, struct dm=
a_attrs *attrs);
> +
> +#define dma_alloc_coherent(d,s,h,f) dma_alloc_attrs(d,s,h,f,NULL)
> +
> +static inline void *dma_alloc_attrs(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0dma_addr_t *dma_handle, gfp_t flag,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct dma_attrs *attrs)
> +{
> + =A0 =A0 =A0 struct dma_map_ops *ops =3D get_dma_ops(dev);
> + =A0 =A0 =A0 void *cpu_addr;
> + =A0 =A0 =A0 BUG_ON(!ops);
> +
> + =A0 =A0 =A0 cpu_addr =3D ops->alloc(dev, size, dma_handle, flag, attrs)=
;
> + =A0 =A0 =A0 debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
> + =A0 =A0 =A0 return cpu_addr;
> +}
>

Apart from the necessity of alloc_attr,
I hope the callback implementations to check if a function pointer is NULL.
Suppose that a system want to use default ARM implementation of dma_alloc_*=
()
while it uses its own implementations of dma_map_*().


With your suggestion,
we have only one option:

void *my_alloc(...) {
return dma_alloc_coherent(NULL, ...);
}

struct dma_map_ops ops =3D {
.alloc_coherent =3D &my_alloc,
...
};



I think the following method is simpler:

struct dma_map_ops ops =3D {
.alloc_coherent =3D NULL,
...
};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
