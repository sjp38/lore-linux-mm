Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 42E696B0085
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:33:07 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so12869164pad.13
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:33:07 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id ds15si15866597pdb.225.2014.12.15.15.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 15:33:05 -0800 (PST)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 99C003EE0B6
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:33:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id A6115AC0438
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:33:01 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 438BEE08009
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:33:01 +0900 (JST)
Message-ID: <548F6F94.2020209@jp.fujitsu.com>
Date: Tue, 16 Dec 2014 08:32:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't alter
 arg gfp_mask
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>
In-Reply-To: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

(2014/12/16 8:03), akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
>
> __alloc_pages_nodemask() strips __GFP_IO when retrying the page
> allocation.  But it does this by altering the function-wide variable
> gfp_mask.  This will cause subsequent allocation attempts to inadvertently
> use the modified gfp_mask.
>
> Cc: Ming Lei <ming.lei@canonical.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>   mm/page_alloc.c |    5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask
> +++ a/mm/page_alloc.c
> @@ -2918,8 +2918,9 @@ retry_cpuset:
>   		 * can deadlock because I/O on the device might not
>   		 * complete.
>   		 */
> -		gfp_mask = memalloc_noio_flags(gfp_mask);
> -		page = __alloc_pages_slowpath(gfp_mask, order,

> +		gfp_t mask = memalloc_noio_flags(gfp_mask);
> +
> +		page = __alloc_pages_slowpath(mask, order,
>   				zonelist, high_zoneidx, nodemask,
>   				preferred_zone, classzone_idx, migratetype);
>   	}

After allocating page, trace_mm_page_alloc(page, order, gfp_mask, migratetype)
is called. But mask is not passed to it. So trace_mm_page_alloc traces wrong
gfp_mask.

Thanks,
Yasuaki Ishimatsu

> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
