Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 655366B00DE
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 07:38:17 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so410014wev.20
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 04:38:16 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id v8si26557146wix.35.2014.06.12.04.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 04:38:16 -0700 (PDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so1093541wgg.21
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 04:38:15 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 09/10] mm, cma: move output param to the end of param list
In-Reply-To: <1402543307-29800-10-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-10-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 12 Jun 2014 13:38:11 +0200
Message-ID: <xa1twqcmicik.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Conventionally, we put output param to the end of param list.
> cma_declare_contiguous() doesn't look like that, so change it.

Perhaps the function should be changed to return an error-pointer?

> Additionally, move down cma_areas reference code to the position
> where it is really needed.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

>
> diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book=
3s_hv_builtin.c
> index 28ec226..97613ea 100644
> --- a/arch/powerpc/kvm/book3s_hv_builtin.c
> +++ b/arch/powerpc/kvm/book3s_hv_builtin.c
> @@ -184,7 +184,7 @@ void __init kvm_cma_reserve(void)
>=20=20
>  		align_size =3D max(kvm_rma_pages << PAGE_SHIFT, align_size);
>  		cma_declare_contiguous(selected_size, 0, 0, align_size,
> -			KVM_CMA_CHUNK_ORDER - PAGE_SHIFT, &kvm_cma, false);
> +			KVM_CMA_CHUNK_ORDER - PAGE_SHIFT, false, &kvm_cma);
>  	}
>  }
>=20=20
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index f177f73..bfd4553 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -149,7 +149,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t si=
ze, phys_addr_t base,
>  {
>  	int ret;
>=20=20
> -	ret =3D cma_declare_contiguous(size, base, limit, 0, 0, res_cma, fixed);
> +	ret =3D cma_declare_contiguous(size, base, limit, 0, 0, fixed, res_cma);
>  	if (ret)
>  		return ret;
>=20=20
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index e38efe9..e53eead 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -6,7 +6,7 @@ struct cma;
>  extern int __init cma_declare_contiguous(phys_addr_t size,
>  				phys_addr_t base, phys_addr_t limit,
>  				phys_addr_t alignment, int order_per_bit,
> -				struct cma **res_cma, bool fixed);
> +				bool fixed, struct cma **res_cma);
>  extern struct page *cma_alloc(struct cma *cma, int count, unsigned int a=
lign);
>  extern bool cma_release(struct cma *cma, struct page *pages, int count);
>  #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index 01a0713..22a5b23 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -142,8 +142,8 @@ core_initcall(cma_init_reserved_areas);
>   * @limit: End address of the reserved memory (optional, 0 for any).
>   * @alignment: Alignment for the contiguous memory area, should be power=
 of 2
>   * @order_per_bit: Order of pages represented by one bit on bitmap.
> - * @res_cma: Pointer to store the created cma region.
>   * @fixed: hint about where to place the reserved area
> + * @res_cma: Pointer to store the created cma region.
>   *
>   * This function reserves memory from early allocator. It should be
>   * called by arch specific code once the early allocator (memblock or bo=
otmem)
> @@ -156,9 +156,9 @@ core_initcall(cma_init_reserved_areas);
>  int __init cma_declare_contiguous(phys_addr_t size,
>  				phys_addr_t base, phys_addr_t limit,
>  				phys_addr_t alignment, int order_per_bit,
> -				struct cma **res_cma, bool fixed)
> +				bool fixed, struct cma **res_cma)
>  {
> -	struct cma *cma =3D &cma_areas[cma_area_count];
> +	struct cma *cma;
>  	int ret =3D 0;
>=20=20
>  	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
> @@ -214,6 +214,7 @@ int __init cma_declare_contiguous(phys_addr_t size,
>  	 * Each reserved area must be initialised later, when more kernel
>  	 * subsystems (like slab allocator) are available.
>  	 */
> +	cma =3D &cma_areas[cma_area_count];
>  	cma->base_pfn =3D PFN_DOWN(base);
>  	cma->count =3D size >> PAGE_SHIFT;
>  	cma->order_per_bit =3D order_per_bit;
> --=20
> 1.7.9.5
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
