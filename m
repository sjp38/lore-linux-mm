Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEFC6B0150
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:36:00 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so9394542wgb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:35:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id cu9si5436171wib.124.2015.05.22.00.35.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:35:58 -0700 (PDT)
Date: Fri, 22 May 2015 09:35:59 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 7/10] x86, mm, asm: Add WT support to
 set_page_memtype()
In-Reply-To: <1431551151-19124-8-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220919070.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-8-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:
> + * X86 PAT uses page flags arch_1 and uncached together to keep track of
> + * memory type of pages that have backing page struct. X86 PAT supports 4
> + * different memory types, _PAGE_CACHE_MODE_WT, _PAGE_CACHE_MODE_WC,
> + * _PAGE_CACHE_MODE_UC_MINUS and _PAGE_CACHE_MODE_WB where page's memory
> + * type has not been changed from its default.

This is a horrible sentence.

 * X86 PAT supports 4 different memory types:
 *  - _PAGE_CACHE_MODE_WB
 *  - _PAGE_CACHE_MODE_WC
 *  - _PAGE_CACHE_MODE_UC_MINUS
 *  - _PAGE_CACHE_MODE_WT
 *
 * _PAGE_CACHE_MODE_WB is the default type.
 */
Hmm?

>   * Note we do not support _PAGE_CACHE_MODE_UC here.

This can be removed as it is completely redundant.

>   */
>  
> -#define _PGMT_DEFAULT		0
> +#define _PGMT_WB		0	/* default */

We just established two lines above that this is the default

>  #define _PGMT_WC		(1UL << PG_arch_1)
>  #define _PGMT_UC_MINUS		(1UL << PG_uncached)
> -#define _PGMT_WB		(1UL << PG_uncached | 1UL << PG_arch_1)
> +#define _PGMT_WT		(1UL << PG_uncached | 1UL << PG_arch_1)
>  #define _PGMT_MASK		(1UL << PG_uncached | 1UL << PG_arch_1)
>  #define _PGMT_CLEAR_MASK	(~_PGMT_MASK)
>  
> @@ -88,14 +88,14 @@ static inline enum page_cache_mode get_page_memtype(struct page *pg)
>  {
>  	unsigned long pg_flags = pg->flags & _PGMT_MASK;
>  
> -	if (pg_flags == _PGMT_DEFAULT)
> -		return -1;
> +	if (pg_flags == _PGMT_WB)
> +		return _PAGE_CACHE_MODE_WB;
>  	else if (pg_flags == _PGMT_WC)
>  		return _PAGE_CACHE_MODE_WC;
>  	else if (pg_flags == _PGMT_UC_MINUS)
>  		return _PAGE_CACHE_MODE_UC_MINUS;
>  	else
> -		return _PAGE_CACHE_MODE_WB;
> +		return _PAGE_CACHE_MODE_WT;
>  }
>  
>  static inline void set_page_memtype(struct page *pg,
> @@ -112,11 +112,12 @@ static inline void set_page_memtype(struct page *pg,
>  	case _PAGE_CACHE_MODE_UC_MINUS:
>  		memtype_flags = _PGMT_UC_MINUS;
>  		break;
> -	case _PAGE_CACHE_MODE_WB:
> -		memtype_flags = _PGMT_WB;
> +	case _PAGE_CACHE_MODE_WT:
> +		memtype_flags = _PGMT_WT;
>  		break;
> +	case _PAGE_CACHE_MODE_WB:
>  	default:
> -		memtype_flags = _PGMT_DEFAULT;
> +		memtype_flags = _PGMT_WB;	/* default */

What's the value of that  comment?

       default:
		 /* default */

Aside of the, please do not use tail comments. They make code harder
to parse.

>  /*
>   * For RAM pages, we use page flags to mark the pages with appropriate type.
> - * The page flags are limited to three types, WB, WC and UC-.
> - * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
> + * The page flags are limited to four types, WB (default), WC, WT and UC-.
> + * WP request fails with -EINVAL, and UC gets redirected to UC-.

> + * A new memtype can only be set to the default memtype WB.

I have no idea what that line means.

> @@ -582,13 +583,6 @@ static enum page_cache_mode lookup_memtype(u64 paddr)
>  		struct page *page;
>  		page = pfn_to_page(paddr >> PAGE_SHIFT);
>  		rettype = get_page_memtype(page);

		return get_page_memtype(page);

And while you are at it please add the missing newline between the
variable declaration and code.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
