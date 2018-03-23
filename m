Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9BDE6B0025
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 04:38:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 65so5543517wrn.7
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 01:38:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b102si6661531wrd.490.2018.03.23.01.38.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 01:38:50 -0700 (PDT)
Date: Fri, 23 Mar 2018 09:38:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: help the ALLOC_HARDER allocation pass the
 watermarki when CMA on
Message-ID: <20180323083847.GJ23100@dhcp22.suse.cz>
References: <1521791852-7048-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521791852-7048-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, vel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

On Fri 23-03-18 15:57:32, Zhaoyang Huang wrote:
> For the type of 'ALLOC_HARDER' page allocation, there is an express
> highway for the whole process which lead the allocation reach __rmqueue_xxx
> easier than other type.
> However, when CMA is enabled, the free_page within zone_watermark_ok() will
> be deducted for number the pages in CMA type, which may cause the watermark
> check fail, but there are possible enough HighAtomic or Unmovable and
> Reclaimable pages in the zone. So add 'alloc_harder' here to
> count CMA pages in to clean the obstacles on the way to the final.

This is no longer the case in the current mmotm tree. Have a look at
Joonsoo's zone movable based CMA patchset http://lkml.kernel.org/r/1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com

> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  mm/page_alloc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 635d7dd..cc18620 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3045,8 +3045,11 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  
>  
>  #ifdef CONFIG_CMA
> -	/* If allocation can't use CMA areas don't use free CMA pages */
> -	if (!(alloc_flags & ALLOC_CMA))
> +	/*
> +	 * If allocation can't use CMA areas and no alloc_harder set for none
> +	 * order0 allocation, don't use free CMA pages.
> +	 */
> +	if (!(alloc_flags & ALLOC_CMA) && (!alloc_harder || !order))
>  		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>  #endif
>  
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs
