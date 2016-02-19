Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C6EFD6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:46:12 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so71716861wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 05:46:12 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id es11si17961734wjb.139.2016.02.19.05.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 05:46:10 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id a4so71411376wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 05:46:10 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: cma: split out in_cma check to separate function
In-Reply-To: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
Date: Fri, 19 Feb 2016 14:46:08 +0100
Message-ID: <xa1tlh6gzucf.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Fri, Feb 19 2016, Rabin Vincent wrote:
> Split out the logic in cma_release() which checks if the page is in the
> contiguous area to a new function which can be called separately.  ARM
> will use this.
>
> Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>
> ---
>  include/linux/cma.h | 12 ++++++++++++
>  mm/cma.c            | 27 +++++++++++++++++++--------
>  2 files changed, 31 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 29f9e77..6e7fd2d 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -27,5 +27,17 @@ extern int cma_init_reserved_mem(phys_addr_t base, phy=
s_addr_t size,
>  					unsigned int order_per_bit,
>  					struct cma **res_cma);
>  extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned in=
t align);
> +
>  extern bool cma_release(struct cma *cma, const struct page *pages, unsig=
ned int count);
> +#ifdef CONFIG_CMA
> +extern bool in_cma(struct cma *cma, const struct page *pages,
> +		   unsigned int count);
> +#else
> +static inline bool in_cma(struct cma *cma, const struct page *pages,
> +			  unsigned int count)
> +{
> +	return false;
> +}
> +#endif
> +
>  #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index ea506eb..55cda16 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -426,6 +426,23 @@ struct page *cma_alloc(struct cma *cma, size_t count=
, unsigned int align)
>  	return page;
>  }
>=20=20
> +bool in_cma(struct cma *cma, const struct page *pages, unsigned int coun=
t)

Should it instead take pfn as an argument instead of a page?  IIRC
page_to_pfn may be expensive on some architectures and with this patch,
cma_release will call it twice.

Or maybe in_cma could return a pfn, something like (error checking
stripped):

unsigned long pfn in_cma(struct cma *cma, const struct page *page,
			 unsgined count)
{
	unsigned long pfn =3D page_to_pfn(page);
	if (pfn < cma->base_pfn || pfn >=3D cma->base_pfn + cma->count)
		return 0;
	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
	return pfn;
}

Is pfn =3D=3D 0 guaranteed to be invalid?

> +{
> +	unsigned long pfn;
> +
> +	if (!cma || !pages)
> +		return false;
> +
> +	pfn =3D page_to_pfn(pages);
> +
> +	if (pfn < cma->base_pfn || pfn >=3D cma->base_pfn + cma->count)
> +		return false;
> +
> +	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> +
> +	return true;
> +}
> +
>  /**
>   * cma_release() - release allocated pages
>   * @cma:   Contiguous memory region for which the allocation is performe=
d.
> @@ -440,18 +457,12 @@ bool cma_release(struct cma *cma, const struct page=
 *pages, unsigned int count)
>  {
>  	unsigned long pfn;
>=20=20
> -	if (!cma || !pages)
> -		return false;
> -
>  	pr_debug("%s(page %p)\n", __func__, (void *)pages);
>=20=20
> -	pfn =3D page_to_pfn(pages);
> -
> -	if (pfn < cma->base_pfn || pfn >=3D cma->base_pfn + cma->count)
> +	if (!in_cma(cma, pages, count))
>  		return false;
>=20=20
> -	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> -
> +	pfn =3D page_to_pfn(pages);
>  	free_contig_range(pfn, count);
>  	cma_clear_bitmap(cma, pfn, count);
>  	trace_cma_release(pfn, pages, count);
> --=20
> 2.7.0
>

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
