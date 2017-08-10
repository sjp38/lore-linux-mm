Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 340216B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:01:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v49so3023095qtc.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:01:12 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id n13si5693327qtn.540.2017.08.10.06.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 06:01:10 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id d145so582715qkc.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:01:10 -0700 (PDT)
Date: Thu, 10 Aug 2017 09:01:06 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v5 03/10] swiotlb: Map the buffer if it was unmapped by
 XPFO
Message-ID: <20170810130104.GB2413@localhost.localdomain>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-4-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809200755.11234-4-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Wed, Aug 09, 2017 at 02:07:48PM -0600, Tycho Andersen wrote:
> From: Juerg Haefliger <juerg.haefliger@hpe.com>
> 
> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Tested-by: Tycho Andersen <tycho@docker.com>
> ---
>  include/linux/xpfo.h | 4 ++++
>  lib/swiotlb.c        | 3 ++-
>  mm/xpfo.c            | 9 +++++++++
>  3 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> index 1ff2d1976837..6b61f7b820f4 100644
> --- a/include/linux/xpfo.h
> +++ b/include/linux/xpfo.h
> @@ -27,6 +27,8 @@ void xpfo_kunmap(void *kaddr, struct page *page);
>  void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
>  void xpfo_free_pages(struct page *page, int order);
>  
> +bool xpfo_page_is_unmapped(struct page *page);
> +
>  #else /* !CONFIG_XPFO */
>  
>  static inline void xpfo_kmap(void *kaddr, struct page *page) { }
> @@ -34,6 +36,8 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
>  static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
>  static inline void xpfo_free_pages(struct page *page, int order) { }
>  
> +static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
> +
>  #endif /* CONFIG_XPFO */
>  
>  #endif /* _LINUX_XPFO_H */
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index a8d74a733a38..d4fee5ca2d9e 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -420,8 +420,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
>  {
>  	unsigned long pfn = PFN_DOWN(orig_addr);
>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> +	struct page *page = pfn_to_page(pfn);
>  
> -	if (PageHighMem(pfn_to_page(pfn))) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		/* The buffer does not have a mapping.  Map it in and copy */
>  		unsigned int offset = orig_addr & ~PAGE_MASK;
>  		char *buffer;
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> index 3cd45f68b5ad..3f305f31a072 100644
> --- a/mm/xpfo.c
> +++ b/mm/xpfo.c
> @@ -206,3 +206,12 @@ void xpfo_kunmap(void *kaddr, struct page *page)
>  	spin_unlock_irqrestore(&xpfo->maplock, flags);
>  }
>  EXPORT_SYMBOL(xpfo_kunmap);
> +
> +inline bool xpfo_page_is_unmapped(struct page *page)
> +{
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return false;
> +
> +	return test_bit(XPFO_PAGE_UNMAPPED, &lookup_xpfo(page)->flags);
> +}
> +EXPORT_SYMBOL(xpfo_page_is_unmapped);

How can it be inline and 'EXPORT_SYMBOL' ? And why make it inline? It
surely does not need to be access that often?

> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
