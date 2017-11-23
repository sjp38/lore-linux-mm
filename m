Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B49F6B025E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:05:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id o16so2234216wmf.4
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 00:05:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si887354edh.30.2017.11.23.00.05.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 00:05:33 -0800 (PST)
Subject: Re: [PATCH v2] mm/cma: fix alloc_contig_range ret code/potential leak
References: <15cf0f39-43f9-8287-fcfe-f2502af59e8a@oracle.com>
 <20171122185214.25285-1-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bde01dfd-3b32-a6cd-6cce-96f6fd395d0d@suse.cz>
Date: Thu, 23 Nov 2017 09:05:30 +0100
MIME-Version: 1.0
In-Reply-To: <20171122185214.25285-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 11/22/2017 07:52 PM, Mike Kravetz wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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

             ^ missing space
>  
>  	/*
>  	 * Pages from [start, end) are within a MAX_ORDER_NR_PAGES
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
