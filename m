Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43C1D6B025F
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 08:04:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 26so11646647pfs.22
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 05:04:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si11232960plk.103.2017.11.21.05.04.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 05:04:23 -0800 (PST)
Date: Tue, 21 Nov 2017 14:04:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential
 leak
Message-ID: <20171121130418.ythozkqb4phpwth4@dhcp22.suse.cz>
References: <20171120193930.23428-1-mike.kravetz@oracle.com>
 <20171120193930.23428-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120193930.23428-2-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Mon 20-11-17 11:39:30, Mike Kravetz wrote:
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

I find the description in 0/0 much more easier to grasp so I would
vote for merging it into the changelog. It took me a while to realize
that we are talking about the success path just from staring into the
diff which doesn't have a sufficient scope to tell the whole story.

Btw. I find embeded description in the diffstat area much more easier to
follow for single patches. Having a cover for a single patch sounds more
like a distraction. Just my 2c

> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

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
