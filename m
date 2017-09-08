Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 970616B032F
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 03:51:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so3853094pgb.3
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 00:51:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s2si1272103plj.508.2017.09.08.00.51.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 00:51:41 -0700 (PDT)
Date: Fri, 8 Sep 2017 00:51:40 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170908075140.GB4957@infradead.org>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

I think this patch needs to be split into the generic mm code, and
the x86 arch code at least.

> +/*
> + * The current flushing context - we pass it instead of 5 arguments:
> + */
> +struct cpa_data {
> +	unsigned long	*vaddr;
> +	pgd_t		*pgd;
> +	pgprot_t	mask_set;
> +	pgprot_t	mask_clr;
> +	unsigned long	numpages;
> +	int		flags;
> +	unsigned long	pfn;
> +	unsigned	force_split : 1;
> +	int		curpage;
> +	struct page	**pages;
> +};

Fitting these 10 variables into 5 arguments would require an awesome
compression scheme anyway :)

> +			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr, base) < 0)

Overly long line.

> +#include <linux/xpfo.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -55,24 +56,34 @@ static inline struct page *kmap_to_page(void *addr)
>  #ifndef ARCH_HAS_KMAP
>  static inline void *kmap(struct page *page)
>  {
> +	void *kaddr;
> +
>  	might_sleep();
> -	return page_address(page);
> +	kaddr = page_address(page);
> +	xpfo_kmap(kaddr, page);
> +	return kaddr;
>  }
>  
>  static inline void kunmap(struct page *page)
>  {
> +	xpfo_kunmap(page_address(page), page);
>  }
>  
>  static inline void *kmap_atomic(struct page *page)
>  {
> +	void *kaddr;
> +
>  	preempt_disable();
>  	pagefault_disable();
> -	return page_address(page);
> +	kaddr = page_address(page);
> +	xpfo_kmap(kaddr, page);
> +	return kaddr;
>  }

It seems to me like we should simply direct to pure xpfo
implementations for the !HIGHMEM && XPFO case. - that is
just have the prototypes for kmap, kunmap and co in
linux/highmem.h and implement them in xpfo under those names.

Instead of sprinkling them around.

> +DEFINE_STATIC_KEY_FALSE(xpfo_inited);

s/inited/initialized/g ?

> +	bool "Enable eXclusive Page Frame Ownership (XPFO)"
> +	default n

default n is the default, so you can remove this line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
