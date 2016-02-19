Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8C81C6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 16:23:26 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so94930581wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 13:23:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 189si15349492wmh.90.2016.02.19.13.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 13:23:25 -0800 (PST)
Date: Fri, 19 Feb 2016 13:23:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: cma: split out in_cma check to separate
 function
Message-Id: <20160219132323.d3c6bfb8cf1a420b4cb1b508@linux-foundation.org>
In-Reply-To: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>
Cc: linux@arm.linux.org.uk, mina86@mina86.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Fri, 19 Feb 2016 09:12:03 +0100 Rabin Vincent <rabin.vincent@axis.com> wrote:

> Split out the logic in cma_release() which checks if the page is in the
> contiguous area to a new function which can be called separately.  ARM
> will use this.
> 
> ...
>
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -27,5 +27,17 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
>  					unsigned int order_per_bit,
>  					struct cma **res_cma);
>  extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
> +
>  extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
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

Calling it "pages" is weird.  I immediately read it as a `struct page **'. 
Drop the 's' please.  Or call it `start_page' if you wish to retain the
"we're dealing with more than one page here" info.

And `nr_pages' is a better name than `count'.  

And `in_cma' seems rather ...  brief.  And it breaks the convention that
interface identifiers start with the name of the subsystem.  Look at the rest
of cma.h: cma_get_base(), cma_get_size() cma_declare_contiguous(), etc -
let's not break that.

>  #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index ea506eb..55cda16 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -426,6 +426,23 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>  	return page;
>  }
>  
> +bool in_cma(struct cma *cma, const struct page *pages, unsigned int count)

A bit of documentation would be nice.

> +{
> +	unsigned long pfn;
> +
> +	if (!cma || !pages)
> +		return false;

Is this actually needed?  If there's no good reason for the test, let's leave
it out because it will just be hiding bugs in the caller.

> +	pfn = page_to_pfn(pages);
> +
> +	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
> +		return false;
> +
> +	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> +
> +	return true;
> +}
> +
>  /**
>   * cma_release() - release allocated pages
>   * @cma:   Contiguous memory region for which the allocation is performed.

Apart from those cosmeticish things, no objections from me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
