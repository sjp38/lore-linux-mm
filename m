Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1B296B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:19:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 80so2302390wmb.7
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:19:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si12140489edd.60.2017.11.23.01.19.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 01:19:48 -0800 (PST)
Date: Thu, 23 Nov 2017 10:19:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/cma: fix alloc_contig_range ret code/potential leak
Message-ID: <20171123091946.uqlw5seolnwlfggl@dhcp22.suse.cz>
References: <15cf0f39-43f9-8287-fcfe-f2502af59e8a@oracle.com>
 <20171122185214.25285-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122185214.25285-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed 22-11-17 10:52:14, Mike Kravetz wrote:
> If the call __alloc_contig_migrate_range() in alloc_contig_range
> returns -EBUSY, processing continues so that test_pages_isolated()
> is called where there is a tracepoint to identify the busy pages.
> However, it is possible for busy pages to become available between
> the calls to these two routines.  In this case, the range of pages
> may be allocated.   Unfortunately, the original return code (ret
> == -EBUSY) is still set and returned to the caller.  Therefore,
> the caller believes the pages were not allocated and they are leaked.
> 
> Update comment to indicate that allocation is still possible even if
> __alloc_contig_migrate_range returns -EBUSY.  Also, clear return code
> in this case so that it is not accidentally used or returned to caller.
> 
> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

OK, this one looks reasonable as well.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_alloc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77e4d3c5c57b..25e81844d1aa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7582,11 +7582,18 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	/*
>  	 * In case of -EBUSY, we'd like to know which page causes problem.
> -	 * So, just fall through. We will check it in test_pages_isolated().
> +	 * So, just fall through. test_pages_isolated() has a tracepoint
> +	 * which will report the busy page.
> +	 *
> +	 * It is possible that busy pages could become available before
> +	 * the call to test_pages_isolated, and the range will actually be
> +	 * allocated.  So, if we fall through be sure to clear ret so that
> +	 * -EBUSY is not accidentally used or returned to caller.
>  	 */
>  	ret = __alloc_contig_migrate_range(&cc, start, end);
>  	if (ret && ret != -EBUSY)
>  		goto done;
> +	ret =0;
>  
>  	/*
>  	 * Pages from [start, end) are within a MAX_ORDER_NR_PAGES
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
