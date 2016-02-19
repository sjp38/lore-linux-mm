Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B1C0F6B0009
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:50:55 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id a4so71605408wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 05:50:55 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id b63si12876924wma.98.2016.02.19.05.50.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 05:50:54 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id a4so71604910wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 05:50:54 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] ARM: dma-mapping: fix alloc/free for coherent + CMA + gfp=0
In-Reply-To: <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com> <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
Date: Fri, 19 Feb 2016 14:50:52 +0100
Message-ID: <xa1tio1kzu4j.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Fri, Feb 19 2016, Rabin Vincent wrote:
> Given a device which uses arm_coherent_dma_ops and on which
> dev_get_cma_area(dev) returns non-NULL, the following usage of the DMA
> API with gfp=3D0 results in a memory leak and memory corruption.
>
>  p =3D dma_alloc_coherent(dev, sz, &dma, 0);
>  if (p)
>  	dma_free_coherent(dev, sz, p, dma);
>
> The memory leak is because the alloc allocates using
> __alloc_simple_buffer() but the free attempts
> dma_release_from_contiguous(), which does not do free anything since the
> page is not in the CMA area.
>
> The memory corruption is because the free calls __dma_remap() on a page
> which is backed by only first level page tables.  The
> apply_to_page_range() + __dma_update_pte() loop ends up interpreting the
> section mapping as the address to a second level page table and writing
> the new PTE to memory which is not used by page tables.
>
> We don't have access to the GFP flags used for allocation in the free
> function, so fix it by using the new in_cma() function to determine if a
> buffer was allocated with CMA, similar to how we check for
> __in_atomic_pool().
>
> Fixes: 21caf3a7 ("ARM: 8398/1: arm DMA: Fix allocation from CMA for coher=
ent DMA")
> Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>
> ---
>  arch/arm/mm/dma-mapping.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 0eca381..a4592c7 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -749,16 +749,16 @@ static void __arm_dma_free(struct device *dev, size=
_t size, void *cpu_addr,
>  		__dma_free_buffer(page, size);
>  	} else if (!is_coherent && __free_from_pool(cpu_addr, size)) {
>  		return;
> -	} else if (!dev_get_cma_area(dev)) {
> -		if (want_vaddr && !is_coherent)
> -			__dma_free_remap(cpu_addr, size);
> -		__dma_free_buffer(page, size);
> -	} else {
> +	} else if (in_cma(dev_get_cma_area(dev), page, size >> PAGE_SHIFT)) {
>  		/*
>  		 * Non-atomic allocations cannot be freed with IRQs disabled
>  		 */
>  		WARN_ON(irqs_disabled());
>  		__free_from_contiguous(dev, page, cpu_addr, size, want_vaddr);
> +	} else {
> +		if (want_vaddr && !is_coherent)
> +			__dma_free_remap(cpu_addr, size);
> +		__dma_free_buffer(page, size);
>  	}
>  }

I haven=E2=80=99t looked closely at the code, but why not:

	struct cma *cma =3D=20
        if (!cma_release(dev_get_cma_area(dev), page, size >> PAGE_SHIFT)) {
		// ... do whatever other non-CMA free
	}

--=20
Best regards
Liege of Serenely Enlightened Majesty of Computer Science,
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=9D =E3=83=8A=E3=82=B6=E3=
=83=AC=E3=83=B4=E3=82=A4=E3=83=84  <mpn@google.com> <xmpp:mina86@jabber.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
