Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 637CC6B048B
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 18:27:18 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so278703659pgx.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:27:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w188si10295616pgb.210.2016.11.18.15.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 15:27:17 -0800 (PST)
Date: Fri, 18 Nov 2016 15:27:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mm PATCH v3 21/23] mm: Add support for releasing multiple
 instances of a page
Message-Id: <20161118152716.3f7acf6e25f142846909b2f6@linux-foundation.org>
In-Reply-To: <20161110113606.76501.70752.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
	<20161110113606.76501.70752.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 10 Nov 2016 06:36:06 -0500 Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> This patch adds a function that allows us to batch free a page that has
> multiple references outstanding.  Specifically this function can be used to
> drop a page being used in the page frag alloc cache.  With this drivers can
> make use of functionality similar to the page frag alloc cache without
> having to do any workarounds for the fact that there is no function that
> frees multiple references.
> 
> ...
>
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -506,6 +506,8 @@ extern void free_hot_cold_page(struct page *page, bool cold);
>  extern void free_hot_cold_page_list(struct list_head *list, bool cold);
>  
>  struct page_frag_cache;
> +extern void __page_frag_drain(struct page *page, unsigned int order,
> +			      unsigned int count);
>  extern void *__alloc_page_frag(struct page_frag_cache *nc,
>  			       unsigned int fragsz, gfp_t gfp_mask);
>  extern void __free_page_frag(void *addr);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0fbfead..54fea40 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3912,6 +3912,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
>  	return page;
>  }
>  
> +void __page_frag_drain(struct page *page, unsigned int order,
> +		       unsigned int count)
> +{
> +	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> +
> +	if (page_ref_sub_and_test(page, count)) {
> +		if (order == 0)
> +			free_hot_cold_page(page, false);
> +		else
> +			__free_pages_ok(page, order);
> +	}
> +}
> +EXPORT_SYMBOL(__page_frag_drain);

It's an exported-to-modules library function.  It should be documented,
please?  The page-frag API is only partially documented, but that's no
excuse.

And perhaps documentation will help explain the naming choice.  Why
"drain"?  I'd have expected "put"?

And why the leading underscores.  The page-frag API is pretty weird :(

And inconsistent.  __alloc_page_frag -> page_frag_alloc,
__free_page_frag -> page_frag_free(), etc.  I must have been asleep
when I let that lot through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
