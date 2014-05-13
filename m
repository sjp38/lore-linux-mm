Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D44B6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 06:00:34 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so219704eek.7
        for <linux-mm@kvack.org>; Tue, 13 May 2014 03:00:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si12708112eem.180.2014.05.13.03.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 03:00:33 -0700 (PDT)
Message-ID: <5371ED3F.6070505@suse.cz>
Date: Tue, 13 May 2014 12:00:31 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch -mm] mm, thp: avoid excessive compaction latency during
 fault fix
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405072229390.19108@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405072229390.19108@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/08/2014 07:30 AM, David Rientjes wrote:
> mm-thp-avoid-excessive-compaction-latency-during-fault.patch excludes sync
> compaction for all high order allocations other than thp.  What we really
> want to do is suppress sync compaction for thp, but only during the page
> fault path.
>
> Orders greater than PAGE_ALLOC_COSTLY_ORDER aren't necessarily going to
> loop again so this is the only way to exhaust our capabilities before
> declaring that we can't allocate.
>
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   mm/page_alloc.c | 17 +++++++----------
>   1 file changed, 7 insertions(+), 10 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2585,16 +2585,13 @@ rebalance:
>   	if (page)
>   		goto got_pg;
>
> -	if (gfp_mask & __GFP_NO_KSWAPD) {
> -		/*
> -		 * Khugepaged is allowed to try MIGRATE_SYNC_LIGHT, the latency
> -		 * of this allocation isn't critical.  Everything else, however,
> -		 * should only be allowed to do MIGRATE_ASYNC to avoid excessive
> -		 * stalls during fault.
> -		 */
> -		if ((current->flags & (PF_KTHREAD | PF_KSWAPD)) == PF_KTHREAD)
> -			migration_mode = MIGRATE_SYNC_LIGHT;
> -	}
> +	/*
> +	 * It can become very expensive to allocate transparent hugepages at
> +	 * fault, so use asynchronous memory compaction for THP unless it is
> +	 * khugepaged trying to collapse.
> +	 */
> +	if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
> +		migration_mode = MIGRATE_SYNC_LIGHT;

I wonder what about a process doing e.g. mmap() with MAP_POPULATE. It 
seems to me that it would get only MIGRATE_ASYNC here, right? Since 
gfp_mask would include __GFP_NO_KSWAPD and it won't have PF_KTHREAD.
I think that goes against the idea that with MAP_POPULATE you say you 
are willing to wait to have everything in place before you actually use 
the memory. So I guess you are also willing to wait for hugepages in 
that situation?

>
>   	/*
>   	 * If compaction is deferred for high-order allocations, it is because
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
