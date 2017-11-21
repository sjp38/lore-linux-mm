Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2866B0284
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 02:53:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c83so11062237pfj.11
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 23:53:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e92si9397252pld.705.2017.11.20.23.53.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 23:53:14 -0800 (PST)
Subject: Re: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential
 leak
References: <20171120193930.23428-1-mike.kravetz@oracle.com>
 <20171120193930.23428-2-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b63d2f48-ee19-20ca-e870-76fb4cd9e09f@suse.cz>
Date: Tue, 21 Nov 2017 08:53:11 +0100
MIME-Version: 1.0
In-Reply-To: <20171120193930.23428-2-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 11/20/2017 08:39 PM, Mike Kravetz wrote:
> If the call __alloc_contig_migrate_range() in alloc_contig_range
> returns -EBUSY, processing continues so that test_pages_isolated()
> is called where there is a tracepoint to identify the busy pages.
> However, it is possible for busy pages to become available between
> the calls to these two routines.  In this case, the range of pages
> may be allocated.   Unfortunately, the original return code (ret
> == -EBUSY) is still set and returned to the caller.  Therefore,
> the caller believes the pages were not allocated and they are leaked.
> 
> Update the return code with the value from test_pages_isolated().

Good catch and seems ok for a stable fix. But it's another indication
that this area needs some larger rewrite.

For example, it seems that the tracepoints in test_pages_isolated() will
report not only pages which were busy during migration attempt, but also
pages that were not at all attempted, because
__alloc_contig_migrate_range() gave up?

> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77e4d3c5c57b..3605ca82fd29 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7632,10 +7632,10 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	}
>  
>  	/* Make sure the range is really isolated. */
> -	if (test_pages_isolated(outer_start, end, false)) {
> +	ret = test_pages_isolated(outer_start, end, false);
> +	if (ret) {
>  		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>  			__func__, outer_start, end);
> -		ret = -EBUSY;
>  		goto done;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
