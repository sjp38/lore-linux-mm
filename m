Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEE58E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 09:27:12 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so3945127pgq.12
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 06:27:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si4355015pgi.324.2018.12.14.06.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 06:27:10 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc.c: Allow error injection
References: <20181214074330.18917-1-bpoirier@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f9dd5000-f83a-a102-2695-362e93fdfdea@suse.cz>
Date: Fri, 14 Dec 2018 15:24:06 +0100
MIME-Version: 1.0
In-Reply-To: <20181214074330.18917-1-bpoirier@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Poirier <bpoirier@suse.com>, linux-mm@kvack.org
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Nicolas Saenz Julienne <nsaenzjulienne@suse.de>

On 12/14/18 8:43 AM, Benjamin Poirier wrote:
> Model call chain after should_failslab(). Likewise, we can now use a kprobe
> to override the return value of should_fail_alloc_page() and inject
> allocation failures into alloc_page*().

I'd be more explicit about both the advantages and disadvantages, as we
discussed internally. E.g. something along:

This will allow injecting allocation failures using the BCC tools even
without building kernel with CONFIG_FAIL_PAGE_ALLOC and booting it with
a fail_page_alloc= parameter, which incurs some overhead even when
failures are not being injected. On the other hand, this patch adds an
unconditional call to should_fail_alloc_page() from page allocation
hotpath. That overhead should be rather negligible with
CONFIG_FAIL_PAGE_ALLOC=n when there's no kprobe attached, though.

> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/asm-generic/error-injection.h |  1 +
>  mm/page_alloc.c                       | 10 ++++++++--
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/include/asm-generic/error-injection.h b/include/asm-generic/error-injection.h
> index 296c65442f00..95a159a4137f 100644
> --- a/include/asm-generic/error-injection.h
> +++ b/include/asm-generic/error-injection.h
> @@ -8,6 +8,7 @@ enum {
>  	EI_ETYPE_NULL,		/* Return NULL if failure */
>  	EI_ETYPE_ERRNO,		/* Return -ERRNO if failure */
>  	EI_ETYPE_ERRNO_NULL,	/* Return -ERRNO or NULL if failure */
> +	EI_ETYPE_TRUE,		/* Return true if failure */
>  };
>  
>  struct error_injection_entry {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2ec9cc407216..64861d79dc2d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3053,7 +3053,7 @@ static int __init setup_fail_page_alloc(char *str)
>  }
>  __setup("fail_page_alloc=", setup_fail_page_alloc);
>  
> -static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> +static bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  {
>  	if (order < fail_page_alloc.min_order)
>  		return false;
> @@ -3103,13 +3103,19 @@ late_initcall(fail_page_alloc_debugfs);
>  
>  #else /* CONFIG_FAIL_PAGE_ALLOC */
>  
> -static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> +static inline bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  {
>  	return false;
>  }
>  
>  #endif /* CONFIG_FAIL_PAGE_ALLOC */
>  
> +static noinline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> +{
> +	return __should_fail_alloc_page(gfp_mask, order);
> +}
> +ALLOW_ERROR_INJECTION(should_fail_alloc_page, TRUE);
> +
>  /*
>   * Return true if free base pages are above 'mark'. For high-order checks it
>   * will return true of the order-0 watermark is reached and there is at least
> 
